//
//  QQSelectAssetToolBar.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQSelectAssetToolBar.h"
#import "UIView+QQExtension.h"
#import "UIColor+QQExtension.h"
#import "QQAssetsPicker.h"

@interface QQSelectAssetToolBar ()

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation QQSelectAssetToolBar

- (instancetype)initWithToolBarType:(ToolBarType)toolBarType {
    if (self = [super init]) {
        _toolBarType = toolBarType;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [self addSubview:_effectView];
        
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        
        BOOL needsLeftButton = NO;
        if (toolBarType == ToolBarTypeEdit) {
            if ([QQAssetsPicker sharedPicker].configuration.allowsImageEditing || [QQAssetsPicker sharedPicker].configuration.allowsVideoEditing) {
                needsLeftButton = YES;
            }
        } else if (toolBarType == ToolBarTypePreview) {
            needsLeftButton = YES;
        }
        
        if (needsLeftButton) {
            _leftButton = [[QQButton alloc] init];
            _leftButton.enabled = NO;
            _leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [_leftButton setTitle:(toolBarType == ToolBarTypePreview ? @"预览" : @"编辑") forState:UIControlStateNormal];
            [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            [_contentView addSubview:_leftButton];
        }
        
        _originImageButton = [[QQButton alloc] init];
        _originImageButton.spacingBetweenImageAndTitle = 8;
        _originImageButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originImageButton setTitle:@"原图" forState:UIControlStateNormal];
        [_originImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_originImageButton setImage:[QQAssetsPicker sharedPicker].configuration.assetPickerCheckMarkNormalImage forState:UIControlStateNormal];
        [_originImageButton setImage:[QQAssetsPicker sharedPicker].configuration.assetPickerCheckMarkSelectedImage forState:UIControlStateSelected];
        [_contentView addSubview:_originImageButton];
        
        _doneButton = [[QQButton alloc] init];
        _doneButton.enabled = NO;
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_contentView addSubview:_doneButton];
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont systemFontOfSize:15];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.backgroundColor = [UIColor qq_colorWithHexString:@"00CC68"];
        _countLabel.hidden = YES;
        [_contentView addSubview:_countLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _effectView.frame = self.bounds;
    _contentView.frame = CGRectMake(0, 0, self.qq_width, self.qq_height - self.qq_safeAreaInsets.bottom);
    CGSize contentSize = _contentView.frame.size;
    [_leftButton sizeToFit];
    _leftButton.frame = CGRectMake(16, 0, _leftButton.qq_width, contentSize.height);
    [_originImageButton sizeToFit];
    _originImageButton.frame = CGRectMake((contentSize.width - _originImageButton.qq_width) / 2, 0, _originImageButton.frame.size.width, contentSize.height);
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(contentSize.width - _doneButton.frame.size.width - 16, 0, _doneButton.frame.size.width, contentSize.height);
    CGFloat countLabelWidth = 25;
    _countLabel.frame = CGRectMake(CGRectGetMinX(_doneButton.frame) - countLabelWidth - 10, (contentSize.height - countLabelWidth) / 2, countLabelWidth, countLabelWidth);
    _countLabel.layer.cornerRadius = _countLabel.frame.size.height / 2;
    _countLabel.layer.masksToBounds = YES;
}

@end
