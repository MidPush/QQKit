//
//  QQFillButton.m
//  JiXinMei
//
//  Created by Mac on 2021/3/2.
//

#import "QQFillButton.h"
#import "UIColor+QQExtension.h"
#import "QQUIConfiguration.h"

const CGFloat QQFillButtonCornerRadiusAdjustsBounds = -1;

@implementation QQFillButton

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor {
    return [self initWithFillColor:fillColor titleTextColor:textColor frame:CGRectZero];
}

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.fillColor = fillColor;
        self.titleTextColor = textColor;
        self.cornerRadius = QQFillButtonCornerRadiusAdjustsBounds;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupInitialize];
    }
    return self;
}

- (void)setupInitialize {
    self.titleTextColor = [UIColor whiteColor];
    self.cornerRadius = QQFillButtonCornerRadiusAdjustsBounds;
    self.fillColor = [QQUIConfiguration sharedInstance].buttonFillColor;
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.backgroundColor = fillColor;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    [self setTitleColor:titleTextColor forState:UIControlStateNormal];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (self.cornerRadius != QQFillButtonCornerRadiusAdjustsBounds) {
        self.layer.cornerRadius = self.cornerRadius;
    } else {
        self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

@end
