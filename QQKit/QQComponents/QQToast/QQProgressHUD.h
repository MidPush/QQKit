//
//  QQProgressHUD.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 背景遮罩类型
typedef NS_ENUM(NSInteger, QQProgressHUDMaskType) {
    QQProgressHUDMaskTypeNone,
    QQProgressHUDMaskTypeClear
};

/// 动画类型
typedef NS_ENUM(NSInteger, QQProgressHUDAnimationType) {
    QQProgressHUDAnimationTypeFlat,
    QQProgressHUDAnimationTypeNative
};

@interface QQProgressHUD : UIView

+ (void)setDefaultMaskType:(QQProgressHUDMaskType)maskType;
+ (void)setDefaultAnimationType:(QQProgressHUDAnimationType)animationType;

+ (void)setContentInsets:(UIEdgeInsets)contentInsets;
+ (void)setCornerRadius:(CGFloat)cornerRadius;
+ (void)setMinimumSize:(CGSize)minimumSize;
+ (void)setBackgroundColor:(UIColor *)color;

+ (void)setRingRadius:(CGFloat)ringRadius;
+ (void)setRingThickness:(CGFloat)ringThickness;

+ (void)setTintColor:(UIColor *)tintColor;
+ (void)setFont:(UIFont *)font;
+ (void)setTextColor:(UIColor *)textColor;

+ (void)setInfoImage:(nullable UIImage *)image;
+ (void)setSuccessImage:(nullable UIImage *)image;
+ (void)setErrorImage:(nullable UIImage *)image;

+ (void)show;
+ (void)showWithStatus:(nullable NSString *)status;

+ (void)showProgress:(CGFloat)progress;
+ (void)showProgress:(CGFloat)progress status:(nullable NSString *)status;

+ (void)showInfoWithStatus:(nullable NSString *)status;
+ (void)showSuccessWithStatus:(nullable NSString *)status;
+ (void)showErrorWithStatus:(nullable NSString *)status;
+ (void)showImage:(nullable UIImage *)image status:(nullable NSString *)status;

+ (void)dismiss;
+ (void)dismissWithDelay:(NSTimeInterval)delay;

+ (NSTimeInterval)displayDurationForString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
