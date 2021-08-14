//
//  QQNavigationButton.m
//  QQKitDemo
//
//  Created by Mac on 2021/7/2.
//

#import "QQNavigationButton.h"
#import "QQRuntime.h"
#import "QQUIConfiguration.h"
#import "QQUIHelper.h"
#import "UIView+QQExtension.h"

@implementation QQNavigationButton

- (instancetype)init {
    return [self initWithType:QQNavigationButtonTypeNormal];
}

- (instancetype)initWithType:(QQNavigationButtonType)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

@end

@implementation UIBarButtonItem (QQNavigationButton)

+ (UIBarButtonItem *)qq_leftItemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    return [self qq_leftItemWithImage:image title:nil titleColor:nil target:target action:action];
}

+ (UIBarButtonItem *)qq_leftItemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    return [self qq_leftItemWithImage:nil title:title titleColor:nil target:target action:action];
}

+ (UIBarButtonItem *)qq_leftItemWithTitle:(NSString *)title titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action {
    return [self qq_leftItemWithImage:nil title:title titleColor:titleColor target:target action:action];
}

+ (UIBarButtonItem *)qq_leftItemWithImage:(UIImage *)image title:(NSString *)title titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action {
    QQUIConfiguration *configuration = [QQUIConfiguration sharedInstance];
    QQNavigationButton *barButton = [[QQNavigationButton alloc] initWithType:QQNavigationButtonTypeBack];
    barButton.spacingBetweenImageAndTitle = configuration.navBarBackImageTitleSpacing;
    barButton.contentEdgeInsets = UIEdgeInsetsMake(0, configuration.navBarBackMarginOffset, 0, -configuration.navBarBackMarginOffset);
    barButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    if (image) {
        [barButton setImage:image forState:UIControlStateNormal];
    }
    if (title) {
        [barButton setTitle:title forState:UIControlStateNormal];
        if (titleColor) {
            [barButton setTitleColor:titleColor forState:UIControlStateNormal];
        } else {
            [barButton setTitleColor:configuration.navBarBackTitleColor forState:UIControlStateNormal];
        }
        barButton.titleLabel.font = configuration.navBarBackTitleFont;
    }
    if (target && action) {
        [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [barButton sizeToFit];
    barButton.qq_width += configuration.navBarBackMarginOffset;
    if (barButton.qq_width < 44.0) {
        // 增加响应区域
        barButton.qq_width = 44.0;
    }
    if (barButton.qq_height < QQUIHelper.navigationBarHeight) {
        barButton.qq_height = QQUIHelper.navigationBarHeight;
    }
    if (title) {
        barButton.qq_width += configuration.navBarBackImageTitleSpacing;
    }
    return [[UIBarButtonItem alloc] initWithCustomView:barButton];
}

+ (UIBarButtonItem *)qq_rightItemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action {
    QQNavigationButton *barButton = [[QQNavigationButton alloc] initWithType:QQNavigationButtonTypeNormal];
    barButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [barButton setImage:image forState:UIControlStateNormal];
    if (target && action) {
        [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [barButton sizeToFit];
    // 增加响应区域
    barButton.qq_width += 10;
    if (barButton.qq_height < QQUIHelper.navigationBarHeight) {
        barButton.qq_height = QQUIHelper.navigationBarHeight;
    }
    return [[UIBarButtonItem alloc] initWithCustomView:barButton];
}

+ (UIBarButtonItem *)qq_rightItemWithTitle:(nullable NSString *)title titleColor:(nullable UIColor *)titleColor font:(nullable UIFont *)font target:(nullable id)target action:(nullable SEL)action {
    QQNavigationButton *barButton = [[QQNavigationButton alloc] initWithType:QQNavigationButtonTypeNormal];
    barButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    barButton.titleLabel.font = font;
    [barButton setTitle:title forState:UIControlStateNormal];
    [barButton setTitleColor:titleColor forState:UIControlStateNormal];
    if (target && action) {
        [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [barButton sizeToFit];
    // 增加响应区域
    barButton.qq_width += 10;
    if (barButton.qq_height < QQUIHelper.navigationBarHeight) {
        barButton.qq_height = QQUIHelper.navigationBarHeight;
    }
    return [[UIBarButtonItem alloc] initWithCustomView:barButton];
}

+ (UIBarButtonItem *)qq_itemWithButton:(QQNavigationButton *)button target:(nullable id)target action:(nullable SEL)action {
    if (!button) return nil;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[self alloc] initWithCustomView:button];
}

@end

@implementation UINavigationBar (QQNavigationButton)

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
                        UIView *customView = navBar.topItem.leftBarButtonItem.customView;
                        NSDirectionalEdgeInsets value = originResult;
                        if ([customView isKindOfClass:[QQNavigationButton class]]) {
                            QQNavigationButton *backButton = (QQNavigationButton *)customView;
                            if (backButton.type == QQNavigationButtonTypeBack) {
                                value.leading -= 16;
                            }
                        }
                        return value;
                    }
                    
                    return originResult;
                };
            });
        } else {
            OverrideImplementation([QQNavigationButton class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject, CGRect frame) {
                    // get navbar
                    UINavigationBar *navBar = nil;
                    if ([NSStringFromClass([selfObject class]) isEqualToString:NSStringFromClass([QQNavigationButton class])] &&
                        [selfObject.superview isKindOfClass:[UINavigationBar class]]) {
                        navBar = (UINavigationBar *)selfObject.superview;
                    }
                    
                    // change insets
                    if (navBar) {
                        UIView *leftCustomView = navBar.topItem.leftBarButtonItem.customView;
                        if ([leftCustomView isKindOfClass:[QQNavigationButton class]]) {
                            QQNavigationButton *backButton = (QQNavigationButton *)leftCustomView;
                            if (backButton.type == QQNavigationButtonTypeBack) {
                                frame.origin.x -= 16;
                            }
                        }
                        
                        if (selfObject == leftCustomView) {
                            // call super
                            void (*originSelectorIMP)(id, SEL, CGRect);
                            originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                            originSelectorIMP(selfObject, originCMD, frame);
                            return;
                        }
                        
                        // iOS11之前 rightBarButtonItem 距离右边太远
                        UIView *rightCustomView = navBar.topItem.rightBarButtonItems.firstObject.customView;
                        if ([rightCustomView isKindOfClass:[QQNavigationButton class]]) {
                            QQNavigationButton *backButton = (QQNavigationButton *)rightCustomView;
                            if (backButton.type == QQNavigationButtonTypeNormal) {
                                frame.origin.x += 11;
                            }
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, CGRect);
                    originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, frame);
                };
            });
        }
    });
}

@end
