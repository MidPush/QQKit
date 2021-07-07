//
//  UIView+QQExtension.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, QQViewBorderPosition) {
    QQViewBorderPositionNone      = 0,
    QQViewBorderPositionTop       = 1 << 0,
    QQViewBorderPositionLeft      = 1 << 1,
    QQViewBorderPositionBottom    = 1 << 2,
    QQViewBorderPositionRight     = 1 << 3
};

typedef NS_ENUM(NSUInteger, QQViewBorderLocation) {
    QQViewBorderLocationInside,
    QQViewBorderLocationCenter,
    QQViewBorderLocationOutside
};

typedef NS_ENUM(NSUInteger, QQGradientDirection) {
    QQGradientDirectionLeftToRight,
    QQGradientDirectionTopToBottom
};

@interface UIView (QQExtension)

// Layout
@property (nonatomic, assign) CGFloat qq_top;
@property (nonatomic, assign) CGFloat qq_bottom;

@property (nonatomic, assign) CGFloat qq_left;
@property (nonatomic, assign) CGFloat qq_right;

@property (nonatomic, assign) CGFloat qq_width;
@property (nonatomic, assign) CGFloat qq_height;

@property (nonatomic, assign) CGFloat qq_centerX;
@property (nonatomic, assign) CGFloat qq_centerY;

/**
 在 iOS 11 及之后的版本，此属性将返回系统已有的 self.safeAreaInsets。在之前的版本此属性返回 UIEdgeInsetsZero
 */
@property (nonatomic, assign, readonly) UIEdgeInsets qq_safeAreaInsets;

/**
 获取当前 UIView 所在的控制器，可能为空
 最好不要经常用，会使代码逻辑很乱。
 */
- (nullable UIViewController *)qq_viewController;

/**
 将某个 UIView 截图并转成一个 UIImage
 */
- (UIImage *)qq_snapshotLayerImage;
- (UIImage *)qq_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates;


@end

#pragma mark - 边框 border

@interface UIView (QQBorder)

/// 设置边框的位置，默认为 QQViewBorderLocationInside，与 view.layer.border 一致。
@property (nonatomic, assign) QQViewBorderLocation qq_borderLocation;

/// 设置边框类型，默认为 QMUIViewBorderPositionNone。
@property (nonatomic, assign) QQViewBorderPosition qq_borderPosition;

/// 边框的大小，默认为 0
@property (nonatomic, assign) CGFloat qq_borderWidth;

/// 边框的颜色
@property (nonatomic, strong) UIColor *qq_borderColor;

/// 虚线 : dashPhase默认是0，且当dashPattern设置了才有效
/// qq_dashPhase 表示虚线起始的偏移，qq_dashPattern 可以传一个数组，表示“lineWidth，lineSpacing，lineWidth，lineSpacing...”的顺序，至少传 2 个。
@property (nonatomic, assign) CGFloat qq_dashPhase;
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *qq_dashPattern;

/// border 的 layer
@property (nonatomic, strong, readonly, nullable) CAShapeLayer *qq_borderLayer;

@end

#pragma mark - 渐变色
@interface UIView (QQGradientColor)

/// 渐变方向，默认QQGradientDirectionLeftToRight
@property (nonatomic, assign) QQGradientDirection qq_gradientDirection;

/// 起始颜色
@property (nonatomic, strong, nullable) UIColor *qq_startColor;

/// 结束颜色
@property (nonatomic, strong, nullable) UIColor *qq_endColor;

/// 渐变 layer
@property (nonatomic, strong, readonly, nullable) CAGradientLayer *qq_gradientLayer;

@end

NS_ASSUME_NONNULL_END
