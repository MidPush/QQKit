//
//  QQModalViewController.h
//  QQKitDemo
//
//  Created by xuze on 2021/7/10.
//

#import <UIKit/UIKit.h>
#import "QQModalView.h"

NS_ASSUME_NONNULL_BEGIN
/**
 一个弹出浮层ViewController
 优点：可以处理屏幕旋转，控制状态栏
 缺点：不能显示在某个View上，只能使用控制器弹出
 */
@class QQModalViewController;
@protocol QQModalViewControllerDelegate <NSObject>

@optional
- (void)willDismissModalViewController:(QQModalViewController *)modalViewController;
- (void)didDismissModalViewController:(QQModalViewController *)modalViewController;

@end

@interface QQModalViewController : UIViewController

/**
 * 要被弹出的浮层，当设置了`contentView`时，不要再设置`contentViewController`
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
@property (nonatomic, weak) id<QQModalViewControllerDelegate> delegate;

/**
 * 控制点击dimmingView时是否隐藏浮层。
 * 默认为YES，也即点击 dimmingView 将会自动隐藏浮层。
 */
@property (nonatomic, assign) BOOL hidesWhenTapDimmingView;

/**
 * 标志当前浮层的显示/隐藏状态
 */
@property (nonatomic, assign, readonly, getter=isVisible) BOOL visible;

/**
 * 设置要使用的显示/隐藏动画的类型，默认为`QQModalAnimationStyleFade`。
 */
@property (nonatomic, assign) QQModalAnimationStyle modalAnimationStyle;

/**
 * 管理自定义的浮层布局，将会在浮层显示前、控件的容器大小发生变化时（例如横竖屏、来电状态栏）被调用，请在 block 内主动为 contentView 设置期望的 frame，
 */
@property (nullable, nonatomic, copy) void (^layoutBlock)(CGRect containerBounds,  CGFloat keyboardHeight, CGRect contentViewDefaultFrame);

/**
 * 修改当前界面要支持的横竖屏方向
 */
@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;

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
