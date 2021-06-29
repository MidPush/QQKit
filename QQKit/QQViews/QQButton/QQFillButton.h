//
//  QQFillButton.h
//  JiXinMei
//
//  Created by Mac on 2021/3/2.
//

#import "QQButton.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat QQFillButtonCornerRadiusAdjustsBounds;

@interface QQFillButton : QQButton

@property (nonatomic, strong, nullable) IBInspectable UIColor *fillColor;

@property (nonatomic, strong, nullable) IBInspectable UIColor *titleTextColor;

@property (nonatomic, assign) CGFloat cornerRadius; // 默认为 QQFillButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。

- (instancetype)initWithFillColor:(nullable UIColor *)fillColor titleTextColor:(nullable UIColor *)textColor;
- (instancetype)initWithFillColor:(nullable UIColor *)fillColor titleTextColor:(nullable UIColor *)textColor frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
