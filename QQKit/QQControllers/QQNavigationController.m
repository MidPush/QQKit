//
//  QQNavigationController.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "QQNavigationController.h"
#import "QQUIConfiguration.h"
#import "QQNavigationButton.h"
#import "QQViewController.h"
#import "QQUIHelper.h"

@interface QQNavigationController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *fullScreenPopGesture;

@end

@implementation QQNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurationFullScreenPopGesture];
    [self configurationNavigationBar];
}

/// 配置全屏返回手势
- (void)configurationFullScreenPopGesture {
    if ([QQUIConfiguration sharedInstance].fullScreenPopGestureEnabled) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self.interactivePopGestureRecognizer.delegate respondsToSelector:@selector(handleNavigationTransition:)]) {
            _fullScreenPopGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
            _fullScreenPopGesture.delegate= self;
            [self.view addGestureRecognizer:_fullScreenPopGesture];
            self.interactivePopGestureRecognizer.enabled = NO;
        }
        #pragma clang diagnostic pop
    }
}

/// 配置导航栏
- (void)configurationNavigationBar {
    QQUIConfiguration *configuration = [QQUIConfiguration sharedInstance];
    self.navigationBar.barStyle = configuration.navBarStyle;
    self.navigationBar.tintColor = configuration.navBarTintColor;
    self.navigationBar.barTintColor = configuration.navBarBarTintColor;
    self.navigationBar.shadowImage = configuration.navBarShadowImage;
    [self.navigationBar setBackgroundImage:configuration.navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    if (configuration.navBarTitleTextAttributes) {
        [self.navigationBar setTitleTextAttributes:[configuration.navBarTitleTextAttributes copy]];
    }
}

#pragma mark - 全屏返回手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.fullScreenPopGesture) {
        CGPoint point = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
        CGPoint location = [gestureRecognizer locationInView:self.view];
        CGFloat navigationBarMaxY = [QQUIHelper navigationBarMaxY];
        if (_popRectEdge == QQPopRectEdgeAll) {
            return point.x >= 0 && point.y == 0 && location.y > navigationBarMaxY;
        } else if (_popRectEdge == QQPopRectEdgeLeft) {
            return point.x >= 0 && point.y == 0 && location.x < 44.0 && location.y > navigationBarMaxY;
        } else if (_popRectEdge == QQPopRectEdgeNone) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 重要：使用自定义全屏返回手势时，一定要加这个条件，不然可能造成 app 假死的状态。
    if (gestureRecognizer == self.fullScreenPopGesture) {
        return self.childViewControllers.count > 1;
    }
    return YES;
}

#pragma mark - Overrides
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        QQUIConfiguration *configuration = [QQUIConfiguration sharedInstance];
        NSString *backTitle = nil;
        UIImage *backImage = configuration.navBarBackImage;
        if (configuration.needsBackBarButtonItemTitle) {
            backTitle = @"返回";
        }
        // 这里没用 backBarButtonItem 而是用 leftBarButtonItem，因为 leftBarButtonItem 更加灵活，比较好自定义
        // 使用 leftBarButtonItem 会使系统返回手势失效，这里使用 fullScreenPopGesture 替代
        // 这里没有传 target、action，而是在 QQViewController 里添加，方便拦截返回点击事件
        UIBarButtonItem *leftItem = nil;
        if ([viewController isKindOfClass:[QQViewController class]]) {
            leftItem = [UIBarButtonItem qq_leftItemWithImage:backImage title:backTitle titleColor:nil target:nil action:nil];
        } else {
            leftItem = [UIBarButtonItem qq_leftItemWithImage:backImage title:backTitle titleColor:nil target:self action:@selector(onBackBarButtonItemClicked)];
        }
        
        viewController.navigationItem.leftBarButtonItem = leftItem;
        
        // 一般只有首页才需要显示 UITabBar
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)onBackBarButtonItemClicked {
    [self popViewControllerAnimated:YES];
}

#pragma mark - 状态栏
- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.topViewController) {
        return self.topViewController;
    }
    return [super childViewControllerForStatusBarHidden];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.topViewController) {
        return self.topViewController;
    }
    return [super childViewControllerForStatusBarStyle];
}

#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate {
    if (self.topViewController) {
        return [self.topViewController shouldAutorotate];
    }
    return [super shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    return [super supportedInterfaceOrientations];
}

#pragma mark - HomeIndicator
- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    if (self.topViewController) {
        return [self.topViewController childViewControllerForHomeIndicatorAutoHidden];
    }
    return [super childViewControllerForHomeIndicatorAutoHidden];
}

@end
