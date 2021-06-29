//
//  QQCropToolBar.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/9.
//

#import "QQCropToolBar.h"
#import "UIView+QQExtension.h"

@interface QQCropToolBar ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *topLine;

@end

@implementation QQCropToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [self addSubview:_topLine];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contentView addSubview:_cancelButton];
        
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _resetButton.enabled = NO;
        _resetButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_resetButton setTitle:@"还原" forState:UIControlStateNormal];
        [_resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_resetButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_contentView addSubview:_resetButton];
        
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contentView addSubview:_doneButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentView.frame = CGRectMake(0, 0, self.qq_width, self.qq_height - self.qq_safeAreaInsets.bottom);
    _topLine.frame = CGRectMake(0, 0, self.qq_width, 1 / [UIScreen mainScreen].scale);
    CGSize contentSize = _contentView.frame.size;
    [_cancelButton sizeToFit];
    _cancelButton.frame = CGRectMake(16, 0, _cancelButton.qq_width, contentSize.height);
    [_resetButton sizeToFit];
    _resetButton.frame = CGRectMake((contentSize.width - _resetButton.qq_width) / 2, 0, _resetButton.qq_width, contentSize.height);
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(contentSize.width - _doneButton.qq_width - 16, 0, _doneButton.qq_width, contentSize.height);
}

- (void)setResetButtonEnabled:(BOOL)resetButtonEnabled {
    _resetButtonEnabled = resetButtonEnabled;
    _resetButton.enabled = resetButtonEnabled;
}

@end
