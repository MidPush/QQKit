//
//  QQSliderRight.m
//  QQKitDemo
//
//  Created by Mac on 2021/6/22.
//

#import "QQSliderRight.h"
#import "UIView+QQExtension.h"

@interface QQSliderRight ()

@property (nonatomic, strong) UIView *line1;
@property (nonatomic, strong) UIView *line2;

@end

@implementation QQSliderRight

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    _fillColor = [UIColor whiteColor];
    _lineColor = [UIColor grayColor];
    
    self.backgroundColor = _fillColor;
    
    _line1 = [[UIView alloc] init];
    _line1.backgroundColor = _lineColor;
    [self addSubview:_line1];
    
    _line2 = [[UIView alloc] init];
    _line2.backgroundColor = _lineColor;
    [self addSubview:_line2];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat lineWidth = 1.0;
    CGFloat lineHeight = 5.0;
    CGFloat lineMargin = 2.0;
    
    _line1.frame = CGRectMake((self.qq_width - 2 * lineWidth - lineMargin) / 2, (self.qq_height - lineHeight) / 2, lineWidth, lineHeight);
    _line2.frame = CGRectMake(_line1.qq_right + lineMargin, _line1.qq_top, lineWidth, lineHeight);
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.backgroundColor = fillColor;
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    _line1.backgroundColor = lineColor;
    _line2.backgroundColor = lineColor;
}

@end
