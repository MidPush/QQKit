//
//  QQToast.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/16.
//

#import "QQToast.h"

@implementation QQToast

+ (void)initialize {
    [QQProgressHUD setDefaultMaskType:QQProgressHUDMaskTypeClear];
    [QQProgressHUD setDefaultAnimationType:QQProgressHUDAnimationTypeFlat];
    [QQProgressHUD setTintColor:[UIColor whiteColor]];
    [QQProgressHUD setBackgroundColor:[UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0]];
    [QQProgressHUD setCornerRadius:8.0];
    [QQProgressHUD setMinimumSize:CGSizeMake(100, 100)];
}

+ (void)showWithText:(NSString *)text {
    [self showWithText:text time:[QQProgressHUD displayDurationForString:text]];
}

+ (void)showWithText:(NSString *)text time:(NSTimeInterval)time {
    [QQProgressHUD setDefaultMaskType:QQProgressHUDMaskTypeNone];
    [QQProgressHUD setMinimumSize:CGSizeMake(0, 0)];
    [QQProgressHUD showImage:nil status:text];
    [QQProgressHUD dismissWithDelay:time];
}

+ (void)showSuccess:(NSString *)text {
    [self showSuccess:text time:[QQProgressHUD displayDurationForString:text]];
}

+ (void)showSuccess:(NSString *)text time:(NSTimeInterval)time {
    [QQProgressHUD setDefaultMaskType:QQProgressHUDMaskTypeNone];
    [QQProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [QQProgressHUD showSuccessWithStatus:text];
    [QQProgressHUD dismissWithDelay:time];
}

+ (void)showError:(NSString *)text {
    [self showError:text time:[QQProgressHUD displayDurationForString:text]];
}

+ (void)showError:(NSString *)text time:(NSTimeInterval)time {
    [QQProgressHUD setDefaultMaskType:QQProgressHUDMaskTypeNone];
    [QQProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [QQProgressHUD showErrorWithStatus:text];
    [QQProgressHUD dismissWithDelay:time];
}

+ (void)showInfo:(NSString *)text {
    [self showInfo:text time:[QQProgressHUD displayDurationForString:text]];
}

+ (void)showInfo:(NSString *)text time:(NSTimeInterval)time {
    [QQProgressHUD setDefaultMaskType:QQProgressHUDMaskTypeNone];
    [QQProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [QQProgressHUD showInfoWithStatus:text];
    [QQProgressHUD dismissWithDelay:time];
}

+ (void)showLoading:(NSString*)text {
    [self showLoading:text time:-1];
}

+ (void)showLoading:(NSString *)text time:(NSTimeInterval)time {
    [self showLoading:text time:time animationType:QQProgressHUDAnimationTypeFlat];
}

+ (void)showLoading:(NSString *)text time:(NSTimeInterval)time animationType:(QQProgressHUDAnimationType)animationType {
    [QQProgressHUD setDefaultAnimationType:animationType];
    [QQProgressHUD setDefaultMaskType:QQProgressHUDMaskTypeClear];
    [QQProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [QQProgressHUD showWithStatus:text];
    if (time >= 0) {
        [QQProgressHUD dismissWithDelay:time];
    }
}

+ (void)showProgress:(CGFloat)progress {
    [self showProgress:progress text:nil];
}

+ (void)showProgress:(CGFloat)progress text:(NSString *)text {
    [QQProgressHUD setDefaultMaskType:QQProgressHUDMaskTypeClear];
    [QQProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [QQProgressHUD showProgress:progress status:text];
}

+ (void)hideToast {
    [QQProgressHUD dismiss];
}

+ (void)bringToastToFront {
    [QQProgressHUD bringHUDToFront];
}

+ (void)setTintColor:(UIColor *)color {
    [QQProgressHUD setTintColor:color];
}

@end
