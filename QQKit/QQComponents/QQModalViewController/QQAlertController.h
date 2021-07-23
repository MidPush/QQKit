//
//  QQAlertController.h
//  QQKitDemo
//
//  Created by Mac on 2021/7/12.
//

#import <UIKit/UIKit.h>
#import "QQTextField.h"
#import "QQButton.h"

NS_ASSUME_NONNULL_BEGIN
/**
 一个和系统 UIAlertViewController 相似的控制器
 比系统提供更多可自定义的功能
 */
@class QQAlertController;

typedef NS_ENUM(NSInteger, QQAlertActionStyle) {
    QQAlertActionStyleDefault = 0,
    QQAlertActionStyleCancel,
    QQAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, QQAlertControllerStyle) {
    QQAlertControllerStyleActionSheet = 0,
    QQAlertControllerStyleAlert
};

@interface QQAlertAction : NSObject

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(QQAlertActionStyle)style handler:(void (^ __nullable)(QQAlertAction *action))handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) QQAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, strong, readonly) QQButton *button;

/// 点击 action button 是否隐藏 QQAlertController，默认为YES，当设置为NO时，需手动隐藏
@property (nonatomic, assign) BOOL dismissWhenTapButton;

@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *buttonAttributes;
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *buttonDisabledAttributes;

@end

@interface QQAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(QQAlertControllerStyle)preferredStyle;

- (void)addAction:(QQAlertAction *)action;
@property (nonatomic, readonly) NSArray<QQAlertAction *> *actions;

@property (nonatomic, strong, nullable) QQAlertAction *preferredAction;

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(QQTextField *textField))configurationHandler;
@property (nullable, nonatomic, readonly) NSArray<QQTextField *> *textFields;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;

@property (nonatomic, assign, readonly) QQAlertControllerStyle preferredStyle;

@property (null_resettable, nonatomic, strong) UIView *mainVisualEffectView;
@property (null_resettable, nonatomic, strong) UIView *cancelButtonVisualEffectView;

#pragma mark - 设置 alertContent 样式
/// alert 容器背景颜色, style为Alert时默认为RGBA(247, 247, 247, 1)，style为Sheet时默认为透明
@property (nullable, nonatomic, strong) UIColor *alertContainerBackgroundColor;
/// alert 头部（非按钮部分）背景色
@property (nullable, nonatomic, strong) UIColor *alertHeaderBackgroundColor;
/// alert 头部（非按钮部分）最新高度，默认为0，当有title或message或textFiled时才有效
@property (nonatomic, assign) CGFloat alertHeaderMinimumHeight;
/// alert 最大宽度，style为Alert时默认为270，style为Sheet时默认为设备的宽度减20
@property (nonatomic, assign) CGFloat alertContentMaximumWidth;
/// alert 圆角。默认13.0
@property (nonatomic, assign) CGFloat alertContentCornerRadius;
/// alert header 边距，默认(20, 16, 20, 16)
@property (nonatomic, assign) UIEdgeInsets alertHeaderInsets;
/// alert 线颜色
@property (nullable, nonatomic, strong) UIColor *alertSeparatorColor;
/// alert 标题和信息之间间距，默认3
@property (nonatomic, assign) CGFloat alertTitleMessageSpacing;
/// alert TextFiled和标题或信息之间间距，默认10
@property (nonatomic, assign) CGFloat alertTextFieldMessageSpacing;
/// 标题
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertTitleAttributes;
/// 信息
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertMessageAttributes;

#pragma mark - 设置TextField样式
// textField高度，默认35
@property (nonatomic, assign) CGFloat alertTextFieldHeight;
// textField之间间隙，默认2.0
@property (nonatomic, assign) CGFloat alertTextFieldsSpecing;
// textField字体大小
@property (nonatomic, strong) UIFont *alertTextFieldFont;
// textField字体颜色
@property (nonatomic, strong) UIColor *alertTextFieldTextColor;
// textField placehodler颜色
@property (nonatomic, strong) UIColor *alertTextFieldPlacehodlerColor;
// textField背景颜色
@property (nonatomic, strong) UIColor *alertTextFieldBackgroundColor;

#pragma mark - 设置按钮样式
/// alertButton 高度，Alert：44.0，Sheet：57
@property (nonatomic, assign) CGFloat alertButtonHeight;
/// 按钮普通状态背景颜色
@property (nullable, nonatomic, strong) UIColor *alertButtonBackgroundColor;
/// 按钮高亮状态背景颜色
@property (nullable, nonatomic, strong) UIColor *alertButtonHighlightBackgroundColor;
/// alert按钮normal时的样式
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertButtonAttributes;
/// alert按钮disabled时的样式
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertButtonDisabledAttributes;
/// alert cancel 按钮样式
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertCancelButtonAttributes;
/// alert destructive 按钮样式
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertDestructiveButtonAttributes;

/**
 * 弹出 QQAlertViewController，使用 window.rootViewController 弹出
 * 最好不要使用系统方法 presentViewController:animated:completion: 弹出控制器 ，可能会出现卡顿
 * 或者使用： dispatch_async(dispatch_get_main_queue(), ^{
              [viewController presentViewController:self animated:NO completion:nil];
            );
 */
- (void)show;

/**
 * 在指定的控制器里弹出 QQAlertViewController
 * 最好不要使用系统方法 presentViewController:animated:completion: 弹出控制器 ，可能会出现卡顿
 * 或者使用： dispatch_async(dispatch_get_main_queue(), ^{
              [viewController presentViewController:self animated:NO completion:nil];
            );
 */
- (void)showFromController:(UIViewController *)viewController;

/**
 * dismiss alert viewController
 */
- (void)dismiss;
- (void)dismissWithCompletion:(void (^ _Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
