//
//  QQGhostButton.h
//  JiXinMei
//
//  Created by Mac on 2021/3/2.
//

#import "QQButton.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat QQGhostButtonCornerRadiusAdjustsBounds;

@interface QQGhostButton : QQButton

@property(nonatomic, strong, nullable) IBInspectable UIColor *ghostColor;

@property(nonatomic, assign) CGFloat borderWidth;    // 默认为 1pt
@property(nonatomic, assign) CGFloat cornerRadius;   // 默认为 QQGhostButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。

- (instancetype)initWithGhostColor:(nullable UIColor *)ghostColor;
- (instancetype)initWithGhostColor:(nullable UIColor *)ghostColor frame:(CGRect)frame;


@end

NS_ASSUME_NONNULL_END

