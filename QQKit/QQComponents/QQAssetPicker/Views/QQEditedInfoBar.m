//
//  QQEditedInfoBar.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/10.
//

#import "QQEditedInfoBar.h"

@interface QQEditedInfoBar ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation QQEditedInfoBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"已编辑";
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    CGFloat titleLabelX = 3;
    CGFloat titleLabelY = 0;
    CGFloat titleLabelWidth = self.frame.size.width - titleLabelX * 2;
    CGFloat titleLabelHeight = self.frame.size.height;
    _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelWidth, titleLabelHeight);
}


@end
