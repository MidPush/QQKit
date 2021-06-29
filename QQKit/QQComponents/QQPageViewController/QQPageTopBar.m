//
//  QQPageTopBar.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/12.
//

#import "QQPageTopBar.h"
#import "QQButton.h"
#import "UIView+QQExtension.h"

@implementation QQTopBarAttributes

- (instancetype)init {
    if (self = [super init]) {
        _titles = nil;
        _titleColor = [UIColor blackColor];
        _selectedTitleColor = [UIColor redColor];
        _titleFont = [UIFont systemFontOfSize:15];
        _selectedTitleFont = [UIFont systemFontOfSize:15];
        
        _indicatorColor = [UIColor redColor];
        _indicatorWidth = 0;
        _indicatorHeight = 2.0;
        _indicatorCornerRadius = _indicatorHeight / 2;
        _indicatorOffsetY = 0;
        
        _topBarHeight = 44.0;
        _backgroundColor = [UIColor whiteColor];
        _contentInsets = UIEdgeInsetsZero;
        _fixedItemWidth = NO;
        _itemSpace = 10;
    }
    return self;
}

@end

@interface QQPageTopBar ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) NSMutableArray<QQButton *> *buttons;

@end

@implementation QQPageTopBar

- (NSMutableArray<QQButton *> *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = NO;
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    [self addSubview:self.scrollView];
    
    _indicatorView = [[UIView alloc] init];
    [self.scrollView addSubview:_indicatorView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeSubviews:NO];
}

- (void)resizeSubviews:(BOOL)aniamted {
    UIEdgeInsets contentInsets = _attributes.contentInsets;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    CGRect contentBounds = self.contentBounds;
    CGSize boundsSize = contentBounds.size;
    
    QQButton *lastButton = nil;
    BOOL fixedItemWidth = _attributes.fixedItemWidth;
    for (QQButton *itemButton in self.buttons) {
        [itemButton sizeToFit];
        if (fixedItemWidth) {
            itemButton.frame = CGRectMake(lastButton ? lastButton.qq_right : 0, 0, floorf(boundsSize.width / self.buttons.count), boundsSize.height);
        } else {
            itemButton.frame = CGRectMake(lastButton ? (lastButton.qq_right + _attributes.itemSpace) : 0, 0, itemButton.qq_width, boundsSize.height);
        }
        lastButton = itemButton;
    }
    
    self.scrollView.contentSize = CGSizeMake(lastButton.qq_right, boundsSize.height);
    
    [self layoutIndicator:aniamted];
}

- (void)setAttributes:(QQTopBarAttributes *)attributes {
    _attributes = attributes;
    
    // remove old item
    for (QQButton *itemButton in self.buttons) {
        [itemButton removeFromSuperview];
    }
    [self.buttons removeAllObjects];
    
    // add new item
    for (NSString *title in attributes.titles) {
        QQButton *itemButton = [[QQButton alloc] init];
        itemButton.clipsToBounds = YES;
        itemButton.titleLabel.font = attributes.titleFont;
        [itemButton setTitleColor:attributes.titleColor forState:UIControlStateNormal];
        [itemButton setTitleColor:attributes.selectedTitleColor forState:UIControlStateSelected];
        [itemButton setTitle:title forState:UIControlStateNormal];
        [itemButton addTarget:self action:@selector(onItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:itemButton];
        [self.buttons addObject:itemButton];
    }
    
    self.backgroundColor = _attributes.backgroundColor;
    self.indicatorView.backgroundColor = _attributes.indicatorColor;
    self.indicatorView.layer.cornerRadius = _attributes.indicatorCornerRadius;
    
    [self reloadItemButton];
    [self resizeSubviews:NO];
    
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self scrollToIndex:selectedIndex animated:NO];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    if (_selectedIndex != index) {
        _selectedIndex = index;
        [self reloadItemButton];
        [self resizeSubviews:animated];
    }
}

- (void)reloadItemButton {
    if (self.selectedIndex > (NSInteger)self.buttons.count - 1) return;
    QQButton *selectedItemButton = self.buttons[self.selectedIndex];
    for (QQButton *itemButton in self.buttons) {
        if (itemButton == selectedItemButton) {
            itemButton.selected = YES;
            itemButton.titleLabel.font = _attributes.selectedTitleFont;
        } else {
            itemButton.selected = NO;
            itemButton.titleLabel.font = _attributes.titleFont;
        }
    }
}

- (void)layoutIndicator:(BOOL)animated {
    if (self.selectedIndex > (NSInteger)self.buttons.count - 1) return;
    QQButton *selectedItemButton = self.buttons[self.selectedIndex];
    CGFloat indicatorWidth = (_attributes.indicatorWidth > 0 ? _attributes.indicatorWidth : selectedItemButton.qq_width);
    CGFloat indicatorHeight = _attributes.indicatorHeight;
    CGFloat indicatorX = selectedItemButton.qq_left + (selectedItemButton.qq_width - indicatorWidth) / 2;
    CGFloat indicatorY = selectedItemButton.qq_bottom + _attributes.indicatorOffsetY;
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.indicatorView.frame = CGRectMake(indicatorX, indicatorY, indicatorWidth, indicatorHeight);
        }];
    } else {
        self.indicatorView.frame = CGRectMake(indicatorX, indicatorY, indicatorWidth, indicatorHeight);
    }
    
    // 滚动到中心
    CGFloat boundsWidth = self.scrollView.frame.size.width;
    CGFloat contentWidth = self.scrollView.contentSize.width;
    CGFloat offsetX = selectedItemButton.center.x - boundsWidth / 2;
    if (offsetX > contentWidth - boundsWidth + self.scrollView.contentInset.right) {
        offsetX = contentWidth - boundsWidth + self.scrollView.contentInset.right;
    }
    if (offsetX < -self.scrollView.contentInset.left) {
        offsetX = -self.scrollView.contentInset.left;
    }
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (void)onItemButtonClicked:(QQButton *)itemButton {
    [self scrollToIndex:[self.buttons indexOfObject:itemButton] animated:YES];
    if ([self.delegate respondsToSelector:@selector(topBar:didSelectItemAtIndex:)]) {
        [self.delegate topBar:self didSelectItemAtIndex:self.selectedIndex];
    }
}

- (CGRect)contentBounds {
    UIEdgeInsets contentInsets = _attributes.contentInsets;
    CGRect bounds = CGRectMake(contentInsets.left, contentInsets.top, self.frame.size.width - (contentInsets.left + contentInsets.right), self.frame.size.height - (contentInsets.top + contentInsets.bottom) - _attributes.indicatorHeight);
    return bounds;
}

@end
