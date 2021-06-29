//
//  UIViewController+QQFakeNavigationBar.m
//  NNKit
//
//  Created by Mac on 2021/3/1.
//

#import "UIViewController+QQFakeNavigationBar.h"
#import "QQRuntime.h"
#import "UINavigationBarAppearanceProtocol.h"
#import "UINavigationBar+QQExtension.h"
#import "UIImage+QQExtension.h"

@interface QQFakeNavigationBar : UINavigationBar

@property (nonatomic, weak) UINavigationBar *originalNavigationBar;

@end

@implementation QQFakeNavigationBar

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // iOS 14 Beta 6 开始，UINavigationBar 无法直接初始化后使用，必须关联在某个 UINavigationController 里，否则内部的 subviews 不会被创建出来。
        if (@available(iOS 14.0, *)) {
            OverrideImplementation([QQFakeNavigationBar class], NSSelectorFromString([NSString stringWithFormat:@"_%@_%@", @"accessibility", @"navigationController"]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UINavigationController *(QQFakeNavigationBar *selfObject) {
                    if (selfObject.originalNavigationBar) {
                        #pragma clang diagnostic push
                        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        if ([selfObject.originalNavigationBar respondsToSelector:originCMD]) {
                            return [selfObject.originalNavigationBar performSelector:originCMD];
                        }
                        return nil;
                        #pragma clang diagnostic pop
                    }
                    
                    // call super
                    UINavigationController *(*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (UINavigationController *(*)(id, SEL))originalIMPProvider();
                    UINavigationController *result = originSelectorIMP(selfObject, originCMD);
                    return result;
                };
            });
        }
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11, *)) {
        // iOS 11 以前，自己 init 的 navigationBar，它的 backgroundView 默认会一直保持与 navigationBar 的高度相等，但 iOS 11 Beta 1-5 里，自己 init 的 navigationBar.backgroundView.height 默认一直是 44，所以才加上这个兼容
        self.qq_backgroundView.frame = self.bounds;
    }
}

- (void)setOriginalNavigationBar:(UINavigationBar *)originBar {
    _originalNavigationBar = originBar;
    
    if (self.barStyle != originBar.barStyle) {
        self.barStyle = originBar.barStyle;
    }
    
    if (self.translucent != originBar.translucent) {
        self.translucent = originBar.translucent;
    }
    
    if (![self.barTintColor isEqual:originBar.barTintColor]) {
        self.barTintColor = originBar.barTintColor;
    }
    
    if (![self.tintColor isEqual:originBar.tintColor]) {
        self.tintColor = originBar.tintColor;
    }

    self.titleTextAttributes = originBar.titleTextAttributes;
    
    UIImage *backgroundImage = [originBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    if (backgroundImage && backgroundImage.size.width <= 0 && backgroundImage.size.height <= 0) {
        // 假设这里的图片时通过`[UIImage new]`这种形式创建的，那么会navBar会奇怪地显示为系统默认navBar的样式。不知道为什么 navController 设置自己的 navBar 为 [UIImage new] 却没事，所以这里做个保护。
        backgroundImage = [UIImage qq_imageWithColor:[UIColor clearColor]];
    }
    [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    self.shadowImage = originBar.shadowImage;
}

@end

@implementation UIViewController (QQFakeNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        // 重写 viewWillAppear:
        OverrideImplementation([UIViewController class], @selector(viewWillAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
    
                // 在某些情况下，UIViewController并不会被当成一个完整的界面来使用，例如在浮层里、或者直接拿 vc.view 当成一个 subview 使用, 比如：QQPageViewController，此时不需要添加 FakeNavigationBar
                if (![selfObject.navigationController.viewControllers containsObject:selfObject]) {
                    return;
                }
                
                [selfObject renderNavigationBarStyleAnimated:firstArgv];
                [selfObject addFakeNavigationBarIfNeeded];
                
                selfObject.navigationController.navigationBar.qq_backgroundView.layer.mask = [CALayer layer];

                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });

        // 重写 viewDidAppear:
        OverrideImplementation([UIViewController class], @selector(viewDidAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {

                [selfObject removeFakeNavigationBar];
                selfObject.navigationController.navigationBar.qq_backgroundView.layer.mask = nil;

                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });

        // 重写 viewWillDisappear:
        OverrideImplementation([UIViewController class], @selector(viewWillDisappear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                [selfObject addFakeNavigationBarIfNeeded];
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });

        // 重写 viewWillLayoutSubviews:
        OverrideImplementation([UIViewController class], @selector(viewWillLayoutSubviews), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject) {
                
                [selfObject layoutFakeNavigationBarFrame];
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
            };
        });
    });
}

static const void * const kQQFakeNavigationBarKey = &kQQFakeNavigationBarKey;
- (UINavigationBar *)qq_fakeNavigationBar {
    return objc_getAssociatedObject(self, kQQFakeNavigationBarKey);
}

- (void)setQq_fakeNavigationBar:(UINavigationBar *)qq_fakeNavigationBar {
    objc_setAssociatedObject(self, kQQFakeNavigationBarKey, qq_fakeNavigationBar, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark -

- (void)renderNavigationBarStyleAnimated:(BOOL)animated {

    if (![self.navigationController.viewControllers containsObject:self]) {
        return;
    }

    if (![self conformsToProtocol:@protocol(UINavigationBarAppearanceProtocol)]) {
        QQFakeNavigationBar *fakeNavigationBar = (QQFakeNavigationBar *)self.qq_fakeNavigationBar;
        if (fakeNavigationBar) {
            UINavigationBar *navigationBar = self.navigationController.navigationBar;
            navigationBar.titleTextAttributes = [fakeNavigationBar.titleTextAttributes copy];
        }
        return;
    }

    UIViewController<UINavigationBarAppearanceProtocol> *vc = (UIViewController<UINavigationBarAppearanceProtocol> *)self;
    UINavigationController *navigationController = vc.navigationController;
    UINavigationBar *navigationBar = navigationController.navigationBar;

    // barHidden
    if ([vc respondsToSelector:@selector(prefersNavigationBarHidden)]) {
        BOOL hidden = [vc prefersNavigationBarHidden];
        if (hidden) {
            if (!navigationController.isNavigationBarHidden) {
                [navigationController setNavigationBarHidden:YES animated:animated];
            }
        } else {
            if (navigationController.isNavigationBarHidden) {
                [navigationController setNavigationBarHidden:NO animated:animated];
            }
        }
    }

    // barStyle
    if ([vc respondsToSelector:@selector(navBarBarStyle)]) {
        UIBarStyle barStyle = [vc navBarBarStyle];
        navigationBar.barStyle = barStyle;
    }

    // backgroundImage
    if ([vc respondsToSelector:@selector(navBarBackgroundImage)]) {
        UIImage *backgroundImage = [vc navBarBackgroundImage];
        [navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }

    // shadowImage
    if ([vc respondsToSelector:@selector(navBarShadowImage)]) {
        UIImage *shadowImage = [vc navBarShadowImage];
        navigationBar.shadowImage = shadowImage;
    }

    // tintColor
    if ([vc respondsToSelector:@selector(navBarTintColor)]) {
        UIColor *tintColor = [vc navBarTintColor];
        navigationBar.tintColor = tintColor;
    }

    // barTintColor
    if ([vc respondsToSelector:@selector(navBarBarTintColor)]) {
        UIColor *barTintColor = [vc navBarBarTintColor];
        navigationBar.barTintColor = barTintColor;
    }
    
    // title
    QQFakeNavigationBar *fakeNavigationBar = (QQFakeNavigationBar *)self.qq_fakeNavigationBar;
    if (!fakeNavigationBar.hidden) {
        if (fakeNavigationBar) {
            navigationBar.titleTextAttributes = [fakeNavigationBar.titleTextAttributes copy];
        } else {
            if ([vc respondsToSelector:@selector(navBarTitleTextAttributes)] && !self.navigationController.isNavigationBarHidden) {
                NSDictionary *titleTextAttributes = [vc navBarTitleTextAttributes];
                navigationBar.titleTextAttributes = titleTextAttributes;
            }
        }
    }
}

- (void)replaceNavigationBarStyle:(UINavigationBar *)navigationBar1 withNavigationBar:(UINavigationBar *)navigationBar2 {
    if (!navigationBar1 || !navigationBar2) return;
    navigationBar1.barStyle = navigationBar2.barStyle;
    navigationBar1.tintColor = navigationBar2.tintColor;
    navigationBar1.barTintColor = navigationBar2.barTintColor;
    [navigationBar1 setBackgroundImage:[navigationBar2 backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [navigationBar1 setShadowImage:navigationBar2.shadowImage];
    navigationBar1.titleTextAttributes = [navigationBar2.titleTextAttributes copy];
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        // 在某些情况下，UIViewController并不会被当成一个完整的界面来使用，例如在浮层里、或者直接拿 vc.view 当成一个 subview 使用, 比如：QQPageViewController
        return;
    }
    if (navigationBar2.hidden) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)addFakeNavigationBarIfNeeded {
    if (!self.navigationController.navigationBar) {
        return;
    }
    
    if (!self.qq_fakeNavigationBar) {
        QQFakeNavigationBar *fakeNavigationBar = [[QQFakeNavigationBar alloc] init];
        self.qq_fakeNavigationBar = fakeNavigationBar;
        UINavigationBar *originNavigationBar = self.navigationController.navigationBar;
        fakeNavigationBar.originalNavigationBar = originNavigationBar;
        if ([self respondsToSelector:@selector(prefersNavigationBarHidden)]) {
            BOOL hidden = [self performSelector:@selector(prefersNavigationBarHidden)];
            fakeNavigationBar.hidden = hidden;
        }
    }

    [self layoutFakeNavigationBarFrame];
    if (!self.navigationController.navigationBarHidden) {
        [self.view addSubview:self.qq_fakeNavigationBar];
    }
}

- (void)removeFakeNavigationBar {
    if (self.qq_fakeNavigationBar) {
        // 解决某些情况下，导航栏显隐设置时机比较晚，fakeNavigationBar得到错误的hidden值。如：系统的照相机
        self.qq_fakeNavigationBar.hidden = self.navigationController.navigationBarHidden;
        if ([self respondsToSelector:@selector(prefersNavigationBarHidden)]) {
            BOOL hidden = [self performSelector:@selector(prefersNavigationBarHidden)];
            self.qq_fakeNavigationBar.hidden = hidden;
        }
        [self replaceNavigationBarStyle:self.navigationController.navigationBar withNavigationBar:self.qq_fakeNavigationBar];
        [self.qq_fakeNavigationBar removeFromSuperview];
        self.qq_fakeNavigationBar = nil;
    }
}

- (void)layoutFakeNavigationBarFrame {
    if (!self.navigationController.navigationBar) {
        return;
    }
    UIView *backgroundView = self.navigationController.navigationBar.qq_backgroundView;
    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
    if (self.qq_fakeNavigationBar && backgroundView) {
        if (rect.origin.x != 0) {
            // 在 push 动画过程中 rect.origin.x可能不为0，backgroundView被隐藏。导致可以看到一部分导航栏后面的内容
            rect.origin.x = 0;
        }
        self.qq_fakeNavigationBar.frame = rect;
    }
}

@end
