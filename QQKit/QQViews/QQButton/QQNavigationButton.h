//
//  QQNavigationButton.h
//  QQKitDemo
//
//  Created by Mac on 2021/7/2.
//

#import "QQButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QQNavigationButtonType) {
    QQNavigationButtonTypeNormal,
    QQNavigationButtonTypeBack
};

@interface QQNavigationButton : QQButton

- (instancetype)initWithType:(QQNavigationButtonType)type;
@property (nonatomic, assign, readonly) QQNavigationButtonType type;

@end

@interface UIBarButtonItem (QQNavigationButton)

/// LeftItem
+ (UIBarButtonItem *)qq_leftItemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action;

+ (UIBarButtonItem *)qq_leftItemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;

+ (UIBarButtonItem *)qq_leftItemWithTitle:(nullable NSString *)title titleColor:(nullable UIColor *)titleColor target:(nullable id)target action:(nullable SEL)action;

+ (UIBarButtonItem *)qq_leftItemWithImage:(nullable UIImage *)image title:(nullable NSString *)title titleColor:(nullable UIColor *)titleColor target:(nullable id)target action:(nullable SEL)action;

/// RightItem
+ (UIBarButtonItem *)qq_rightItemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action;

+ (UIBarButtonItem *)qq_rightItemWithTitle:(nullable NSString *)title titleColor:(nullable UIColor *)titleColor font:(nullable UIFont *)font target:(nullable id)target action:(nullable SEL)action;

// CustomItem
+ (UIBarButtonItem *)qq_itemWithButton:(QQNavigationButton *)button target:(nullable id)target action:(nullable SEL)action;

@end

NS_ASSUME_NONNULL_END
