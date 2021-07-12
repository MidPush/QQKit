//
//  QQModalView.h
//  QQKitDemo
//
//  Created by xuze on 2021/7/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 一个弹出浮层View
 优点：可以显示在某个父View上
 缺点：不能处理屏幕旋转布局，需自己手动处理屏幕旋转时布局
 */
typedef NS_ENUM(NSInteger, QQModalAnimationStyle) {
    QQModalAnimationStyleFade,   // 渐隐渐现，默认
    QQModalAnimationStylePopup,  // 从中心点弹出
    QQModalAnimationStyleSheet   // 从下往上升起
};

@class QQModalView;
@protocol QQModalViewDelegate <NSObject>

@optional
- (void)willDismissModalView:(QQModalView *)modalView;
- (void)didDismissModalView:(QQModalView *)modalView;

@end

@interface QQModalView : UIView

/**
 * 要被弹出的浮层
 */
@property (nullable, nonatomic, strong) UIView *contentView;

/**
 * 背景遮罩，默认为一个普通的`UIView`
 * 可设置为自己的view，注意`dimmingView`的大小将会盖满整个控件
 */
@property (nullable, nonatomic, strong) UIView *dimmingView;

/**
 * 代理
 */
@property (nonatomic, weak) id<QQModalViewDelegate> delegate;

/**
 * 设置要使用的显示/隐藏动画的类型，默认为`QQModalAnimationStyleFade`。
 */
@property (nonatomic, assign) QQModalAnimationStyle modalAnimationStyle;

/**
 * 设置`contentView`布局时与外容器的间距，默认为(20, 20, 20, 20)
 */
@property (nonatomic, assign) UIEdgeInsets contentViewMargins;

/**
 * 控制点击dimmingView时是否隐藏浮层。
 * 默认为YES，也即点击 dimmingView 将会自动隐藏浮层。
 */
@property (nonatomic, assign) BOOL dismissWhenTapDimmingView;

/**
 * 控制当dismiss时是否移除浮层，默认为YES。
 * 当设置为NO时，注意自己手动移除
 */
@property (nonatomic, assign) BOOL removeWhenDismiss;

/**
 * 标志当前浮层的显示/隐藏状态
 */
@property (nonatomic, assign, readonly, getter=isVisible) BOOL visible;

/**
 * 管理自定义的浮层布局，将会在浮层显示前、控件的容器大小发生变化时（例如横竖屏、来电状态栏）被调用，请在 block 内主动为 contentView 设置期望的 frame，
 */
@property (nullable, nonatomic, copy) void (^layoutBlock)(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame);

/**
 * 显示浮层，会将浮层添加到当前的 keyWindow 上
 */
- (void)show;

/**
 * 显示浮层，将浮层添加到 指定的 view
 */
- (void)showInView:(UIView *)view completion:(void (^ _Nullable)(BOOL finished))completion;

/**
 * 隐藏浮层
 */
- (void)dismiss;

/**
 * 隐藏浮层
 */
- (void)dismissWithCompletion:(void (^ _Nullable)(BOOL finished))completion;

/**
 *  请求重新计算浮层的布局
 */
- (void)updateLayout;

@end

NS_ASSUME_NONNULL_END
