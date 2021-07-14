//
//  QQConfirmModalController.h
//  QQKitDemo
//
//  Created by Mac on 2021/7/12.
//

#import <UIKit/UIKit.h>
#import "QQButton.h"

NS_ASSUME_NONNULL_BEGIN
/**
 一个确认弹出框
 自带 titleView、取消和确认按钮、空白的contentView（contentView内容由自己实现）
 */
@interface QQConfirmModalController : UIViewController

/// alert距离屏幕四边的间距，默认UIEdgeInsetsMake(20, 20, 20, 20)。alert的宽度最终是通过屏幕宽度减去水平的 alertContentMargin 和 alertContentMaximumWidth 决定的。
@property (nonatomic, assign) UIEdgeInsets alertViewMargins;

/// alert的最大宽度，默认CGFLOAT_MAX。
@property (nonatomic, assign) CGFloat alertContentMaximumWidth;

/// alert的圆角，默认13.0。
@property (nonatomic, assign) CGFloat alertViewCornerRadius;

@property (nonatomic, strong, readonly) UIView *titleView;
@property (nonatomic, assign) CGFloat titleViewHeight;
@property (nullable, nonatomic, strong) NSAttributedString *attributedTitle;
@property (nonatomic, strong) UIColor *titleViewSeparatorColor;

@property (nonatomic, strong) UIView *contentView;
@property (nullable, nonatomic, copy) NSString *message;
@property (nullable, nonatomic, strong) NSAttributedString *attributedMessage;
@property (nonatomic, assign) UIEdgeInsets messageMargins;

@property (nonatomic, strong, readonly) UIView *actionsView;
@property (nonatomic, assign) CGFloat actionsViewHeight;
@property (nonatomic, strong, readonly) QQButton *cancelButton;
@property (nonatomic, strong, readonly) QQButton *submitButton;
@property (nonatomic, strong) UIColor *actionsViewSeparatorColor;

/**
 移除取消按钮
 */
- (void)removeCancelButton;

/**
 移除提交按钮
 */
- (void)removeSubmitButton;

/**
 取消和提交按钮点击事件
 isSubmit 为YES，点击了提交按钮，为NO则点击了取消按钮
 如果设置了此 block，QQConfirmModalController 不会自动隐藏，需用户自己手动隐藏
 */
@property (nullable, nonatomic, copy) void (^actionsHandler)(QQConfirmModalController *controller, BOOL isSubmit);

/**
 * 弹出 QQConfirmModalController，使用 window.rootViewController 弹出
 * 最好不要使用系统方法 presentViewController:animated:completion: 弹出控制器 ，可能会出现卡顿
 * 或者使用： dispatch_async(dispatch_get_main_queue(), ^{
              [viewController presentViewController:self animated:NO completion:nil];
            );
 */
- (void)show;

/**
 * 在指定的控制器里弹出 QQConfirmModalController
 * 最好不要使用系统方法 presentViewController:animated:completion: 弹出控制器 ，可能会出现卡顿
 * 或者使用： dispatch_async(dispatch_get_main_queue(), ^{
              [viewController presentViewController:self animated:NO completion:nil];
            );
 */
- (void)showFromController:(UIViewController *)viewController;

/**
 * dismiss viewController
 */
- (void)dismiss;
- (void)dismissWithCompletion:(void (^ _Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
