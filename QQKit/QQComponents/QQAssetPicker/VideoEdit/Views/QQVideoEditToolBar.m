//
//  QQVideoEditToolBar.m
//  QQKitDemo
//
//  Created by Mac on 2021/6/22.
//

#import "QQVideoEditToolBar.h"
#import "UIView+QQExtension.h"
#import "NSString+QQExtension.h"

@interface QQVideoEditToolBar ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *rangeLabel;

@end

@implementation QQVideoEditToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        
        _cancelButton = [[QQButton alloc] init];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contentView addSubview:_cancelButton];
        
        _doneButton = [[QQFillButton alloc] initWithFillColor:[UIColor colorWithRed:0 / 255.0 green:204 / 255.0 blue:104 / 255.0 alpha:1.0] titleTextColor:[UIColor whiteColor]];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_contentView addSubview:_doneButton];
        
        _rangeLabel = [[UILabel alloc] init];
        _rangeLabel.textColor = [UIColor whiteColor];
        _rangeLabel.font = [UIFont systemFontOfSize:16];
        [_contentView addSubview:_rangeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _contentView.frame = CGRectMake(0, 0, self.qq_width, self.qq_height - self.qq_safeAreaInsets.bottom);
    CGSize contentSize = _contentView.frame.size;
    
    [_cancelButton sizeToFit];
    _cancelButton.frame = CGRectMake(16, 0, _cancelButton.qq_width, contentSize.height);
    
    CGSize textSize = [_doneButton.titleLabel.text qq_sizeForFont:_doneButton.titleLabel.font size:_contentView.frame.size];
    CGFloat doneButtonWidth = textSize.width + 30;
    CGFloat doneButtonHeight = textSize.height + 10;
    _doneButton.frame = CGRectMake(_contentView.qq_width - doneButtonWidth - 16, (_contentView.qq_height - doneButtonHeight) / 2.0, doneButtonWidth, doneButtonHeight);
    
    [_rangeLabel sizeToFit];
    _rangeLabel.frame = CGRectMake((_contentView.qq_width - _rangeLabel.qq_width) / 2.0, (_contentView.qq_height - _rangeLabel.qq_height) / 2.0, _rangeLabel.qq_width, _rangeLabel.qq_height);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _rangeLabel.text = title;
    [_rangeLabel sizeToFit];
    _rangeLabel.frame = CGRectMake((_contentView.qq_width - _rangeLabel.qq_width) / 2.0, (_contentView.qq_height - _rangeLabel.qq_height) / 2.0, _rangeLabel.qq_width, _rangeLabel.qq_height);
}

@end
