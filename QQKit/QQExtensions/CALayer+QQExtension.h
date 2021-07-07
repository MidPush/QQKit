//
//  CALayer+QQExtension.h
//  QQKitDemo
//
//  Created by Mac on 2021/7/6.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS (NSUInteger, QQCornerMask) {
    QQLayerMinXMinYCorner = 1U << 0,
    QQLayerMaxXMinYCorner = 1U << 1,
    QQLayerMinXMaxYCorner = 1U << 2,
    QQLayerMaxXMaxYCorner = 1U << 3,
    QQLayerAllCorner = QQLayerMinXMinYCorner|QQLayerMaxXMinYCorner|QQLayerMinXMaxYCorner|QQLayerMaxXMaxYCorner,
};

@interface CALayer (QQExtension)

/**
 * 定义四个角中的哪个角使用“qq_cornerRadius”属性。默认为所有四个角。
 * iOS11 及以上会调用系统的接口 maskedCorners
 * @warning iOS11 以下使用 mask 实现圆角，所以超出 layer 范围内的内容都会被 clip 掉（比如：设置了border），系统的则不会
 */
@property (nonatomic, assign) QQCornerMask qq_maskedCorners;

/**
 * 设置圆角
 * iOS11 及以上会调用系统的接口 cornerRadius
 */
@property (nonatomic, assign) CGFloat qq_cornerRadius;

/**
 *  把某个 sublayer 移动到当前所有 sublayers 的最后面
 *  @param sublayer 要被移动的 layer
 *  @warning 要被移动的 sublayer 必须已经添加到当前 layer 上
 */
- (void)qq_sendSublayerToBack:(CALayer *)sublayer;

/**
 *  把某个 sublayer 移动到当前所有 sublayers 的最前面
 *  @param sublayer 要被移动的layer
 *  @warning 要被移动的 sublayer 必须已经添加到当前 layer 上
 */
- (void)qq_bringSublayerToFront:(CALayer *)sublayer;

/**
 * 移除 CALayer（包括 CAShapeLayer 和 CAGradientLayer）所有支持动画的属性的默认动画，方便需要一个不带动画的 layer 时使用。
 */
- (void)qq_removeDefaultAnimations;

@end

NS_ASSUME_NONNULL_END
