//
//  UITabBar+QQExtension.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/14.
//

#import "UITabBar+QQExtension.h"
#import "NSObject+QQExtension.h"
#import "QQRuntime.h"
#import "QQUIConfiguration.h"

@interface UITabBar (QQExtension)

/// 修复 iOS 14.0 ~ 14.1 UITabBar 在某种情况下无法正确显示出来的问题
@property (nonatomic, assign) BOOL qq_shouldCheckTabBarHidden;

@end

@implementation UITabBar (QQExtension)

static const void * const kQQShouldCheckTabBarHidden = &kQQShouldCheckTabBarHidden;
- (void)setQq_shouldCheckTabBarHidden:(BOOL)qq_shouldCheckTabBarHidden {
    objc_setAssociatedObject(self, kQQShouldCheckTabBarHidden, @(qq_shouldCheckTabBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)qq_shouldCheckTabBarHidden {
    return [((NSNumber *)objc_getAssociatedObject(self, kQQShouldCheckTabBarHidden)) boolValue];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // iOS 13 通过 UITabBarAppearance 修改 UITabBar 的 titleTextAttributes 字体大于10时，在某种情况下会导致 UITabBarItem 文字无法完整展示。这应该是系统BUG
        if (@available(iOS 13.0, *)) {
            NSString *buttonLabelClassString = [NSString stringWithFormat:@"%@%@", @"UITabBarButton", @"Label"];
            OverrideImplementation(NSClassFromString(buttonLabelClassString), @selector(setAttributedText:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UILabel *selfObject, NSAttributedString *firstArgv) {
                                        
                    // call super
                    void (*originSelectorIMP)(id, SEL, NSAttributedString *);
                    originSelectorIMP = (void (*)(id, SEL, NSAttributedString *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    CGFloat fontSize = selfObject.font.pointSize;
                    if (fontSize > 10) {
                        [selfObject sizeToFit];
                    }
                };
            });
        }
        
        // iOS 13 以下，如果 UITabBar backgroundImage 为 nil，则 tabBar 会显示磨砂背景，此时不管怎么修改 shadowImage 都无效，都会显示系统默认的分隔线，导致无法很好地统一不同 iOS 版本的表现（iOS 13 及以上没有这个限制），所以这里做了兼容
        if (@available(iOS 13.0, *)) {
        } else {
            NSString *className = [NSString stringWithFormat:@"_%@%@", @"UITabBar", @"VisualProviderLegacyIOS"];
            NSString *selName = [NSString stringWithFormat:@"_%@", @"updateBackground"];
            OverrideImplementation(NSClassFromString(className), NSSelectorFromString(selName), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(NSObject *selfObject) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD);
                    
                    UITabBar *tabBar = [selfObject qq_valueForKey:@"tabBar"];
                    if (!tabBar) return;
                    UIImage *shadowImage = tabBar.shadowImage;// 就算 tabBar 显示系统的分隔线，但依然能从 shadowImage 属性获取到业务自己设置的图片
                    UIImageView *shadowImageView = tabBar.qq_shadowImageView;
                    if (shadowImage && shadowImageView && shadowImageView.backgroundColor && !shadowImageView.image) {
                        shadowImageView.backgroundColor = nil;
                        shadowImageView.image = shadowImage;
                    }
                    
                };
            });
        }
        
        // 修复 iOS 14.0 ~ 14.1 UITabBar 在某种情况下无法正确显示出来的问题
        // 根据测试，iOS 14.2 开始，系统已修复该问题
        if (@available(iOS 14.0, *)) {
            if (@available(iOS 14.2, *)) {
            } else {
                // popToViewController:animated:
                OverrideImplementation([UINavigationController class], @selector(popToViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^NSArray<UIViewController *> *(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                        
                        // 系统的逻辑就是，在 push N 个 vc 的过程中，只要其中出现任意一个 vc.hidesBottomBarWhenPushed = YES，则 tabBar 不会再出现（不管后续有没有 vc.hidesBottomBarWhenPushed = NO），所以在 pop 回去的时候也要遵循这个规则
                        if (animated && selfObject.tabBarController && !viewController.hidesBottomBarWhenPushed) {
                            BOOL systemShouldHideTabBar = NO;
                            NSArray<UIViewController *> *viewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(0, [selfObject.viewControllers indexOfObject:viewController] + 1)];
                            for (UIViewController *vc in viewControllers) {
                                if (vc.hidesBottomBarWhenPushed) {
                                    systemShouldHideTabBar = YES;
                                }
                            }
                            if (!systemShouldHideTabBar) {
                                selfObject.tabBarController.tabBar.qq_shouldCheckTabBarHidden = YES;
                            }
                        }
                        
                        // call super
                        NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                        originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                        NSArray<UIViewController *> *result = originSelectorIMP(selfObject, originCMD, viewController, animated);
                
                        if (selfObject.tabBarController) {
                            selfObject.tabBarController.tabBar.qq_shouldCheckTabBarHidden = NO;
                        }
        
                        return result;
                    };
                });
                
                // popToRootViewControllerAnimated:
                OverrideImplementation([UINavigationController class], @selector(popToRootViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^NSArray<UIViewController *> *(UINavigationController *selfObject, BOOL animated) {
                        
                        // 相邻两个界面的 pop 是没问题的，要超过2个才需要处理
                        if (animated && selfObject.tabBarController && !selfObject.viewControllers.firstObject.hidesBottomBarWhenPushed && selfObject.viewControllers.count > 2) {
                            selfObject.tabBarController.tabBar.qq_shouldCheckTabBarHidden = YES;
                        }
                        
                        // call super
                        NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, BOOL);
                        originSelectorIMP = (NSArray<UIViewController *> *(*)(id, SEL, BOOL))originalIMPProvider();
                        NSArray<UIViewController *> *result = originSelectorIMP(selfObject, originCMD, animated);
                        
                        if (selfObject.tabBarController) {
                            selfObject.tabBarController.tabBar.qq_shouldCheckTabBarHidden = NO;
                        }
                        
                        return result;
                    };
                });
                
                // setViewControllers:animated:
                OverrideImplementation([UINavigationController class], @selector(setViewControllers:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UINavigationController *selfObject, NSArray<UIViewController *> *viewControllers, BOOL animated) {
                        
                        // 系统的逻辑就是，在 push N 个 vc 的过程中，只要其中出现任意一个 vc.hidesBottomBarWhenPushed = YES，则 tabBar 不会再出现（不管后续有没有 vc.hidesBottomBarWhenPushed = NO），所以在 pop 回去的时候也要遵循这个规则
                        UIViewController *viewController = viewControllers.lastObject;
                        if (animated && selfObject.tabBarController && !viewController.hidesBottomBarWhenPushed) {
                            BOOL systemShouldHideTabBar = NO;
                            for (UIViewController *vc in viewControllers) {
                                if (vc.hidesBottomBarWhenPushed) {
                                    systemShouldHideTabBar = YES;
                                }
                            }
                            if (!systemShouldHideTabBar) {
                                selfObject.tabBarController.tabBar.qq_shouldCheckTabBarHidden = YES;
                            }
                        }
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, NSArray<UIViewController *> *, BOOL);
                        originSelectorIMP = (void (*)(id, SEL, NSArray<UIViewController *> *, BOOL))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, viewControllers, animated);
                        
                        if (selfObject.tabBarController) {
                            selfObject.tabBarController.tabBar.qq_shouldCheckTabBarHidden = NO;
                        }
                    };
                });
                
                //
                NSString *tabBarHiddenClassString = [NSString stringWithFormat:@"_%@%@", @"shouldBottomBar", @"BeHidden"];
                OverrideImplementation([UINavigationController class], NSSelectorFromString(tabBarHiddenClassString), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^BOOL(UINavigationController *selfObject) {
                        // call super
                        BOOL (*originSelectorIMP)(id, SEL);
                        originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                        BOOL result = originSelectorIMP(selfObject, originCMD);
                        
                        if (selfObject.tabBarController && selfObject.tabBarController.tabBar.qq_shouldCheckTabBarHidden) {
                            if (result) {
                                // 走到这里意味着系统的值错了，把值改为NO
                                result = NO;
                            }
                        }
                        return result;
                    };
                });
            }
        }
    });
}

- (UIView *)qq_backgroundView {
    return [self qq_valueForKey:@"_backgroundView"];
}

- (UIImageView *)qq_shadowImageView {
    if (@available(iOS 13, *)) {
        return [self.qq_backgroundView qq_valueForKey:@"_shadowView1"];
    }
    // iOS 10 及以后，在 UITabBar 初始化之后就能获取到 backgroundView 和 shadowView 了
    return [self.qq_backgroundView qq_valueForKey:@"_shadowView"];
}

@end

@implementation UITabBarAppearance (QQExtension)

- (void)qq_applyItemAppearanceWithBlock:(void (^)(UITabBarItemAppearance * _Nonnull))block {
    block(self.stackedLayoutAppearance);
    block(self.inlineLayoutAppearance);
    block(self.compactInlineLayoutAppearance);
}

@end
