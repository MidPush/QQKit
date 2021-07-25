//
//  QQViewController.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "QQViewController.h"
#import "QQUIConfiguration.h"

@interface QQViewController ()

@end

@implementation QQViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.supportedOrientationMask = [QQUIConfiguration sharedInstance].supportedOrientationMask;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QQUIConfiguration sharedInstance].commonViewControllerBackgroundColor;
    UIBarButtonItem *leftItem = self.navigationItem.leftBarButtonItem;
    if (leftItem) {
        UIButton *backButton = leftItem.customView;
        if ([backButton respondsToSelector:@selector(addTarget:action:forControlEvents:)]) {
            [backButton addTarget:self action:@selector(onBackBarButtonItemClicked) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [self setupNavigationBar];
    [self initSubviews];
}

- (void)onBackBarButtonItemClicked {
    // 返回上一个控制器
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupNavigationBar {
    // 子类重写
}

- (void)initSubviews {
    // 子类重写
}

- (void)setPopRectEdge:(QQPopRectEdge)popRectEdge {
    _popRectEdge = popRectEdge;
    if (self.navigationController && [self.navigationController isKindOfClass:[QQNavigationController class]]) {
        QQNavigationController *nav = (QQNavigationController *)self.navigationController;
        nav.popRectEdge = popRectEdge;
    }
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return [super shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientationMask;
}

#pragma mark - 状态栏

- (BOOL)prefersStatusBarHidden {
    return [super prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [super preferredStatusBarStyle];
}

#pragma mark - UINavigationBarAppearanceProtocol

/// 设置导航栏是否隐藏
- (BOOL)prefersNavigationBarHidden {
    return NO;
}

/// 设置导航栏的 barStyle
- (UIBarStyle)navBarBarStyle {
    return [QQUIConfiguration sharedInstance].navBarStyle;
}

/// 设置导航栏的背景图
- (UIImage *)navBarBackgroundImage {
    return [QQUIConfiguration sharedInstance].navBarBackgroundImage;
}

/// 设置导航栏底部的分隔线图片，必须在 navigationBar 设置了背景图后才有效（系统限制如此）
- (UIImage *)navBarShadowImage {
    return [QQUIConfiguration sharedInstance].navBarShadowImage;
}

/// 设置当前导航栏的 tintColor
- (UIColor *)navBarTintColor {
    return [QQUIConfiguration sharedInstance].navBarTintColor;
}

/// 设置导航栏的 barTintColor
- (UIColor *)navBarBarTintColor {
    return [QQUIConfiguration sharedInstance].navBarBarTintColor;
}

/// 设置导航栏的 title
- (NSDictionary<NSAttributedStringKey, id> *)navBarTitleTextAttributes {
    return [QQUIConfiguration sharedInstance].navBarTitleTextAttributes;
}

@end
