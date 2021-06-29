//
//  UIBarButtonItem+QQExtension.h
//  JiXinMei
//
//  Created by Mac on 2021/3/2.
//

#import <UIKit/UIKit.h>
#import "QQButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface QQNavigationLeftItemButton : QQButton

@end

@interface UIBarButtonItem (QQExtension)

/// LeftItem
+ (UIBarButtonItem *)qq_leftItemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action;

+ (UIBarButtonItem *)qq_leftItemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;

+ (UIBarButtonItem *)qq_leftItemWithTitle:(nullable NSString *)title titleColor:(nullable UIColor *)titleColor target:(nullable id)target action:(nullable SEL)action;

+ (UIBarButtonItem *)qq_leftItemWithImage:(nullable UIImage *)image title:(nullable NSString *)title titleColor:(nullable UIColor *)titleColor target:(nullable id)target action:(nullable SEL)action;

/// RightItem
+ (UIBarButtonItem *)qq_rightItemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action;

+ (UIBarButtonItem *)qq_rightItemWithTitle:(nullable NSString *)title titleColor:(nullable UIColor *)titleColor font:(nullable UIFont *)font target:(nullable id)target action:(nullable SEL)action;

@end

NS_ASSUME_NONNULL_END
