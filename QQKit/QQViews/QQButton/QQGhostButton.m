//
//  QQGhostButton.m
//  JiXinMei
//
//  Created by Mac on 2021/3/2.
//

#import "QQGhostButton.h"
#import "UIColor+QQExtension.h"
#import "QQUIConfiguration.h"

const CGFloat QQGhostButtonCornerRadiusAdjustsBounds = -1;

@implementation QQGhostButton

- (instancetype)initWithGhostColor:(UIColor *)ghostColor {
    return [self initWithGhostColor:ghostColor frame:CGRectZero];
}

- (instancetype)initWithGhostColor:(UIColor *)ghostColor frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.ghostColor = ghostColor;
        self.borderWidth = 1.0;
        self.cornerRadius = QQGhostButtonCornerRadiusAdjustsBounds;
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
    self.borderWidth = 1.0;
    self.cornerRadius = QQGhostButtonCornerRadiusAdjustsBounds;
    self.ghostColor = [QQUIConfiguration sharedInstance].buttonGhostColor;
}

- (void)setGhostColor:(UIColor *)ghostColor {
    _ghostColor = ghostColor;
    [self setTitleColor:_ghostColor forState:UIControlStateNormal];
    self.layer.borderColor = _ghostColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (self.cornerRadius != QQGhostButtonCornerRadiusAdjustsBounds) {
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
