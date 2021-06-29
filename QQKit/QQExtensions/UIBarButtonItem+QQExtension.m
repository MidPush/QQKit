//
//  UIBarButtonItem+QQExtension.m
//  JiXinMei
//
//  Created by Mac on 2021/3/2.
//

#import "UIBarButtonItem+QQExtension.h"
#import "QQButton.h"
#import "QQUIConfiguration.h"
#import "QQUIHelper.h"
#import "UIView+QQExtension.h"

@implementation QQNavigationLeftItemButton

@end

@implementation UIBarButtonItem (QQExtension)

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
    QQNavigationLeftItemButton *barButton = [[QQNavigationLeftItemButton alloc] init];
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
    if (barButton.qq_width < (44.0 + configuration.navBarBackMarginOffset)) {
        // 增加响应区域
        barButton.qq_width = 44.0 + configuration.navBarBackMarginOffset;
    }
    if (barButton.qq_height < QQUIHelper.navigationBarHeight) {
        barButton.qq_height = QQUIHelper.navigationBarHeight;
    }
    if (title) {
        barButton.qq_width += configuration.navBarBackMarginOffset;
    }
    return [[UIBarButtonItem alloc] initWithCustomView:barButton];
}

+ (UIBarButtonItem *)qq_rightItemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action {
    QQButton *barButton = [[QQButton alloc] init];
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
    QQButton *barButton = [[QQButton alloc] init];
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

@end
