//
//  UINavigationBar+QQExtension.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/21.
//

#import "UINavigationBar+QQExtension.h"
#import "QQRuntime.h"
#import "UIBarButtonItem+QQExtension.h"
#import "NSObject+QQExtension.h"

@implementation UINavigationBar (QQExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 强制修改 contentView 的 directionalLayoutMargins.leading，在使用自定义返回按钮时靠左
        // Xcode11 beta2 修改私有 view 的 directionalLayoutMargins 会 crash，换个方式
        if (@available(iOS 11, *)) {
            NSString *barContentViewString = [NSString stringWithFormat:@"_%@%@", @"UINavigationBar", @"ContentView"];
            OverrideImplementation(NSClassFromString(barContentViewString), @selector(directionalLayoutMargins), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^NSDirectionalEdgeInsets(UIView *selfObject) {
                    
                    // call super
                    NSDirectionalEdgeInsets (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (NSDirectionalEdgeInsets (*)(id, SEL))originalIMPProvider();
                    NSDirectionalEdgeInsets originResult = originSelectorIMP(selfObject, originCMD);
                    
                    // get navbar
                    UINavigationBar *navBar = nil;
                    if ([NSStringFromClass([selfObject class]) isEqualToString:barContentViewString] &&
                        [selfObject.superview isKindOfClass:[UINavigationBar class]]) {
                        navBar = (UINavigationBar *)selfObject.superview;
                    }
                    
                    // change insets
                    if (navBar) {
                        BOOL customLeftBarButtonItem = ([navBar.topItem.leftBarButtonItem.customView isKindOfClass:[QQNavigationLeftItemButton class]]);
                        NSDirectionalEdgeInsets value = originResult;
                        if (customLeftBarButtonItem) {
                            value.leading -= 16;
                        }
                        return value;
                    }
                    
                    return originResult;
                };
            });
        } else {
            OverrideImplementation([QQNavigationLeftItemButton class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject, CGRect frame) {
                    // get navbar
                    UINavigationBar *navBar = nil;
                    if ([NSStringFromClass([selfObject class]) isEqualToString:NSStringFromClass([QQNavigationLeftItemButton class])] &&
                        [selfObject.superview isKindOfClass:[UINavigationBar class]]) {
                        navBar = (UINavigationBar *)selfObject.superview;
                    }
                    
                    // change insets
                    if (navBar) {
                        BOOL customLeftBarButtonItem = ([navBar.topItem.leftBarButtonItem.customView isKindOfClass:[QQNavigationLeftItemButton class]]);
                        if (customLeftBarButtonItem) {
                            frame.origin.x -= 16;
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, CGRect);
                    originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, frame);
                };
            });
        }
        
        // iOS 11 以下，如果 UINavigationBar backgroundImage 为 nil，则 navigationBar 会显示磨砂背景，此时不管怎么修改 shadowImage 都无效，都会显示系统默认的分隔线，导致无法很好地统一不同 iOS 版本的表现（iOS 11 及以上没有这个限制），所以这里做了兼容。
        if (@available(iOS 11.0, *)) {
        } else {
            OverrideImplementation([UINavigationBar class], NSSelectorFromString(@"_updateBackgroundView"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                
                return ^(UINavigationBar *selfObject) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD);
                    
                    UIImage *shadowImage = selfObject.shadowImage;// 就算 navigationBar 显示系统的分隔线，但依然能从 shadowImage 属性获取到业务自己设置的图片
                    UIImageView *shadowImageView = selfObject.qq_shadowImageView;
                    if (shadowImage && shadowImageView && shadowImageView.backgroundColor && !shadowImageView.image) {
                        shadowImageView.backgroundColor = nil;
                        shadowImageView.image = shadowImage;
                    }
                };
                
            });
        }
    });
}

- (UIView *)qq_backgroundView {
    return [self qq_valueForKey:@"_backgroundView"];
}

- (UIImageView *)qq_shadowImageView {
    // UINavigationBar 在 init 完就可以获取到 backgroundView 和 shadowView，无需关心调用时机的问题
    if (@available(iOS 13, *)) {
        return [self.qq_backgroundView qq_valueForKey:@"_shadowView1"];
    }
    return [self.qq_backgroundView qq_valueForKey:@"_shadowView"];
}

@end
