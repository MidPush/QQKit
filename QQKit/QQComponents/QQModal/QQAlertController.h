//
//  QQAlertController.h
//  QQKitDemo
//
//  Created by Mac on 2021/7/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 一个和系统 UIAlertViewController 相似的控制器
 比系统提供更多可自定义的功能
 */

@class QQButton;
@class QQTextField;
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

@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *buttonAttributes;
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *buttonDisabledAttributes;


@end


@interface QQAlertController : UIViewController<UIAppearance>

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(QQAlertControllerStyle)preferredStyle;

- (void)addAction:(QQAlertAction *)action;
@property (nonatomic, readonly) NSArray<QQAlertAction *> *actions;

@property (nonatomic, strong, nullable) QQAlertAction *preferredAction API_AVAILABLE(ios(9.0));

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(QQTextField *textField))configurationHandler;
@property (nullable, nonatomic, readonly) NSArray<QQTextField *> *textFields;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;

@property (nonatomic, assign, readonly) QQAlertControllerStyle preferredStyle;

@property (null_resettable, nonatomic, strong) UIView *mainVisualEffectView;
@property (null_resettable, nonatomic, strong) UIView *cancelButtonVisualEffectView;

#pragma mark - 设置 alertContent 样式

/// alert容器背景颜色, style为Alert时默认为RGBA(247, 247, 247, 1)
@property (nullable, nonatomic, strong) UIColor *alertContainerBackgroundColor;
/// alert头部（非按钮部分）背景色
@property (nullable, nonatomic, strong) UIColor *alertHeaderBackgroundColor;


/// alert最大宽度，默认为270
@property (nonatomic, assign) CGFloat alertContentMaximumWidth;
/// sheet大宽度，默认为设备的宽度减20
@property (nonatomic, assign) CGFloat sheetContentMaximumWidth;
/// alert圆角。默认13.0
@property (nonatomic, assign) CGFloat alertContentCornerRadius;
/// alert header 边距
@property (nonatomic, assign) UIEdgeInsets alertHeaderInsets;
/// alert 标题和信息之间间距
@property (nonatomic, assign) CGFloat alertTitleMessageSpacing;
/// alert TextFiled和标题或信息之间间距
@property (nonatomic, assign) CGFloat alertTextFieldMessageSpacing;
/// 标题
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertTitleAttributes;
/// 信息
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertMessageAttributes;

#pragma mark - 设置TextField样式
@property (nonatomic, assign) CGFloat alertTextFieldHeight;
@property (nonatomic, assign) CGFloat alertTextFieldsSpecing;
@property (nonatomic, strong) UIFont *alertTextFieldFont;
@property (nonatomic, strong) UIColor *alertTextFieldTextColor;
@property (nonatomic, strong) UIColor *alertTextFieldBackgroundColor;

#pragma mark - 设置按钮样式
/// alertButton 高度，默认44.0
@property (nonatomic, assign) CGFloat alertButtonHeight;
@property (nullable, nonatomic, strong) UIColor *alertButtonBackgroundColor;
@property (nullable, nonatomic, strong) UIColor *alertButtonHighlightBackgroundColor;
@property (nullable, nonatomic, strong) UIColor *alertSeparatorColor;
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertButtonAttributes UI_APPEARANCE_SELECTOR;

/// alert按钮disabled时的样式，默认@{NSForegroundColorAttributeName:UIColorMake(129, 129, 129),NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)}
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertButtonDisabledAttributes UI_APPEARANCE_SELECTOR;

/// alert cancel 按钮样式，默认@{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontBoldMake(17),NSKernAttributeName:@(0)}
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertCancelButtonAttributes UI_APPEARANCE_SELECTOR;

/// alert destructive 按钮样式，默认@{NSForegroundColorAttributeName:UIColorRed,NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)}
@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertDestructiveButtonAttributes UI_APPEARANCE_SELECTOR;


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