//
//  QQPreviewNavigationBar.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQPreviewNavigationBar.h"
#import "QQUIHelper.h"
#import "UIView+QQExtension.h"
#import "QQAssetsPicker.h"

@interface QQPreviewNavigationBar ()

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation QQPreviewNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [self addSubview:_effectView];
        
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        
        _backButton = [[QQButton alloc] init];
        [_backButton setImage:[QQAssetsPicker sharedPicker].configuration.assetPickerNavBackImage forState:UIControlStateNormal];
        [_contentView addSubview:_backButton];
        
        _checkboxButton = [[QQCheckboxButton alloc] init];
        [_contentView addSubview:_checkboxButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _effectView.frame = self.bounds;
    CGFloat statusBarHeight = [QQUIHelper statusBarHeightConstant];
    CGFloat navigationBarHeight = [QQUIHelper navigationBarHeight];
    _contentView.frame = CGRectMake(0, statusBarHeight, self.qq_width, navigationBarHeight);
    _backButton.frame = CGRectMake(self.qq_safeAreaInsets.left, 0, 44, navigationBarHeight);
    _checkboxButton.frame = CGRectMake(self.frame.size.width - 44 - self.qq_safeAreaInsets.right, 0, 44, navigationBarHeight);
}


@end
