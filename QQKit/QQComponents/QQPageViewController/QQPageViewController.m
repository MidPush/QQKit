//
//  QQPageViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/12.
//

#import "QQPageViewController.h"

/**
 解决手势冲突
 */
@interface QQPageScrollView : UIScrollView<UIGestureRecognizerDelegate>

@end

@implementation QQPageScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self isScrollToMinOffset:gestureRecognizer]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self isScrollToMinOffset:gestureRecognizer]) {
        return YES;
    }
    return NO;
}

- (BOOL)isScrollToMinOffset:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [panGesture translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            if (point.x > 0 && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
}

@end

@interface QQPageViewController ()<UIScrollViewDelegate, QQPageTopBarDelegate>

@property (nonatomic, strong) QQPageTopBar *topBar;
@property (nonatomic, strong) QQPageScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *cache; //缓存，控制只显示左边、中间、右边3个控制器的view
@property (nonatomic, assign) BOOL firstTime;
@property (nonatomic, assign) NSInteger previousSelectedIndex;

@end

@implementation QQPageViewController

- (NSMutableDictionary *)cache {
    if (!_cache) {
        _cache = [NSMutableDictionary dictionary];
    }
    return _cache;
}

- (instancetype)init {
    if (self = [super init]) {
        _scrollAnimated = YES;
        _previousSelectedIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    _topBar = [[QQPageTopBar alloc] init];
    _topBar.delegate = self;
    [self.view addSubview:_topBar];
    
    _scrollView = [[QQPageScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _topBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), _topBarAttributes.topBarHeight);
    _scrollView.frame = CGRectMake(0, CGRectGetMaxY(_topBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(_topBar.frame));
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * self.viewControllers.count, CGRectGetHeight(_scrollView.frame));
    
    // 当屏幕旋转时，需要更新 childViewControllers 的frame 。
    [self scrollToIndex:self.selectedIndex animated:NO];
    for (NSNumber *indexNumber in self.cache.allKeys) {
        NSInteger index= [indexNumber integerValue];
        UIViewController *cacheVC = self.cache[indexNumber];
        cacheVC.view.frame = CGRectMake(index * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
    
    if (self.firstTime == NO) {
        self.firstTime = YES;
        self.topBar.selectedIndex = self.selectedIndex;
        [self reloadData];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger previousIndex = currentIndex - 1;
    NSInteger nextIndex = currentIndex + 1;
    previousIndex = previousIndex < 0 ? 0 : previousIndex;
    nextIndex = nextIndex > self.viewControllers.count - 1 ? self.viewControllers.count - 1 : nextIndex;
    
    [self preloadControllerFromCache:previousIndex];
    [self preloadControllerFromCache:nextIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.canLoadData) return;
    _selectedIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger previousIndex = self.selectedIndex - 1;
    NSInteger nextIndex = self.selectedIndex + 1;
    previousIndex = previousIndex < 0 ? 0 : previousIndex;
    nextIndex = nextIndex > self.viewControllers.count - 1 ? self.viewControllers.count - 1 : nextIndex;
    
    UIViewController *visibleVc = self.viewControllers[_selectedIndex];
    UIViewController *previousVc = self.viewControllers[previousIndex];
    UIViewController *nextVc = self.viewControllers[nextIndex];
    
    [self loadControllerAtIndex:self.selectedIndex];
    [self loadControllerAtIndex:previousIndex];
    [self loadControllerAtIndex:nextIndex];
    
    [self.topBar scrollToIndex:_selectedIndex animated:YES];
    
    if (_previousSelectedIndex != _selectedIndex) {
        _previousSelectedIndex = _selectedIndex;
        if ([self.delegate respondsToSelector:@selector(pageViewController:didSelectViewController:)]) {
            [self.delegate pageViewController:self didSelectViewController:self.viewControllers[self.selectedIndex]];
        }
    }
    
    for (UIView *view in scrollView.subviews) {
        UIViewController *viewController = [self controllerForView:view];
        if (viewController == visibleVc || viewController == previousVc || viewController == nextVc) {
            continue;
        } else {
            [view removeFromSuperview];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)preloadControllerFromCache:(NSInteger)index {
    UIViewController *visibleVc = self.viewControllers[index];
    if ([self.cache.allValues containsObject:visibleVc]) {
        if (visibleVc.view.superview) {
            return;
        }
        [self.scrollView addSubview:visibleVc.view];
    }
}

#pragma mark - QQPageTopBarDelegate
- (void)topBar:(QQPageTopBar *)topBar didSelectItemAtIndex:(NSUInteger)index {
    if (index == self.selectedIndex) return;
    self.selectedIndex = index;
}

#pragma mark -
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        if (self.canLoadData) {
            [self scrollToIndex:selectedIndex animated:_scrollAnimated];
        }
    }
}

- (void)setTopBarAttributes:(QQTopBarAttributes *)topBarAttributes {
    _topBarAttributes = topBarAttributes;
    if (self.canLoadData) {
        _topBar.attributes = topBarAttributes;
    }
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> * _Nullable)viewControllers {
    _viewControllers = [viewControllers copy];
    [self.cache removeAllObjects];
    self.selectedIndex = 0;
    [self reloadData];
}

- (__kindof UIViewController *)selectedViewController {
    if (!self.canLoadData || (self.selectedIndex > (NSInteger)self.viewControllers.count - 1)) {
        return nil;
    }
    return self.viewControllers[self.selectedIndex];
}

- (void)reloadData {
    if (!self.canLoadData) return;
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * self.viewControllers.count, CGRectGetHeight(_scrollView.frame));
    _topBar.attributes = _topBarAttributes;
    _topBar.hidden = (_topBarAttributes.topBarHeight == 0);
    [self loadControllerAtIndex:self.selectedIndex];
    [self scrollToIndex:self.selectedIndex animated:NO];
    
    if (_loadAll) {
        for (NSInteger i = 0; i < self.viewControllers.count; i++) {
            [self loadControllerAtIndex:i];
        }
    }
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    if (!self.canLoadData) return;
    if (animated) {
        [self.scrollView setContentOffset:CGPointMake(index * self.scrollView.frame.size.width, 0) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(index * self.scrollView.frame.size.width, 0) animated:NO];
        [self scrollViewDidEndDecelerating:self.scrollView];
    }
    [_topBar scrollToIndex:index animated:animated];
}

- (void)loadControllerAtIndex:(NSInteger)index {
    if (!self.canLoadData) return;
    if (index > (NSInteger)self.viewControllers.count - 1) return;
    UIViewController *visibleVc = self.viewControllers[index];
    if (index == self.selectedIndex || _loadAll) {
        if (!visibleVc.view.superview) {
            visibleVc.view.frame = CGRectMake(index * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            [self.scrollView addSubview:visibleVc.view];
        }
        if (![self.cache.allValues containsObject:visibleVc]) {
            self.cache[@(index)] = visibleVc;
        }
    } else {
        if ([self.cache.allValues containsObject:visibleVc]) {
            if (visibleVc.view.superview) {
                return;
            }
            [self.scrollView addSubview:visibleVc.view];
        }
    }
    if (![self.childViewControllers containsObject:visibleVc] && index == self.selectedIndex) {
        [self addChildViewController:visibleVc];
    }
}

- (UIViewController *)controllerForView:(UIView *)fromView {
    for (UIView *view = fromView; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (BOOL)canLoadData {
    if (!self.viewLoaded || self.viewControllers.count == 0) {
        return NO;
    }
    return YES;
}

@end
