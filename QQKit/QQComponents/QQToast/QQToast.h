//
//  QQToast.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/16.
//

#import <Foundation/Foundation.h>
#import "QQProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

/**
 QQToast 是 对 QQProgressHUD 的封装，方便使用
 这是只是一个参考，如果不满足需求，可以自己对 QQProgressHUD 封装
 */
@interface QQToast : NSObject

/**
 toast 显示文字消息，自动消失，可以点击到 toast 后面的内容
 */
+ (void)showWithText:(nullable NSString *)text;
+ (void)showWithText:(nullable NSString *)text time:(NSTimeInterval)time;

/**
 toast 显示成功消息，自动消失，可以点击到 toast 后面的内容
 */
+ (void)showSuccess:(nullable NSString *)text;
+ (void)showSuccess:(nullable NSString *)text time:(NSTimeInterval)time;

/**
 toast 显示错误消息，自动消失，可以点击到 toast 后面的内容
 */
+ (void)showError:(nullable NSString *)text;
+ (void)showError:(nullable NSString *)text time:(NSTimeInterval)time;

/**
 toast 显示信息消息，自动消失，可以点击到 toast 后面的内容
 */
+ (void)showInfo:(nullable NSString *)text;
+ (void)showInfo:(nullable NSString *)text time:(NSTimeInterval)time;

/**
 toast 显示 Loading，如果 time < 0 不会自动消失，需要手动隐藏，不能点击到 toast 后面的内容
 */
+ (void)showLoading:(nullable NSString*)text;
+ (void)showLoading:(nullable NSString *)text time:(NSTimeInterval)time;
+ (void)showLoading:(nullable NSString *)text time:(NSTimeInterval)time animationType:(QQProgressHUDAnimationType)animationType;

/**
 toast 显示 Progress，不会自动消失，需要手动隐藏，不能点击到 toast 后面的内容
 */
+ (void)showProgress:(CGFloat)progress;
+ (void)showProgress:(CGFloat)progress text:(nullable NSString *)text;

/**
 立即隐藏 toast
 */
+ (void)hideToast;

/**
 主题颜色
 */
+ (void)setTintColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
