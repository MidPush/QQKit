//
//  QQPermissionPromptView.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQPermissionPromptView.h"
#import "UIColor+QQExtension.h"
#import "UIView+QQExtension.h"
#import "QQAssetsPicker.h"

@interface QQPermissionPromptView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation QQPermissionPromptView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor qq_colorWithHexString:@"313233"];
        
        _closeButton = [[QQButton alloc] init];
        [_closeButton setImage:[QQAssetsPicker sharedPicker].configuration.assetPickerNavBackImage forState:UIControlStateNormal];
        _closeButton.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44);
        [self addSubview:_closeButton];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.font = [UIFont systemFontOfSize:16];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipsLabel];
        
        _toSettingButton = [[QQButton alloc] init];
        _toSettingButton.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:204 / 255.0 blue:104 / 255.0 alpha:1.0];
        _toSettingButton.layer.cornerRadius = 5.0;
        _toSettingButton.layer.masksToBounds = YES;
        _toSettingButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_toSettingButton setTitle:@"前往系统设置" forState:UIControlStateNormal];
        [_toSettingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_toSettingButton];
        
        _limitedButton = [[QQButton alloc] init];
        _limitedButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_limitedButton setTitle:@"继续访问部分照片" forState:UIControlStateNormal];
        [_limitedButton setTitleColor:[UIColor colorWithRed:124 / 255.0 green:139 / 255.0 blue:149 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        [self addSubview:_limitedButton];
    }
    return self;
}

- (void)setAuthorizationStatus:(QQAuthorizationStatus)authorizationStatus {
    _authorizationStatus = authorizationStatus;
    if (@available(iOS 14, *)) {
        if (authorizationStatus == QQAuthorizationStatusLimited) {
            _titleLabel.text = @"无法访问相册中所有照片";
            _tipsLabel.text = @"只能访问相册中的部分照片，建议前往系统设置，允许访问所有照片。";
            _limitedButton.hidden = NO;
        } else if (authorizationStatus != QQAuthorizationStatusAuthorized) {
            _titleLabel.text = @"无法访问相册中照片";
            _tipsLabel.text = @"当前无照片访问权限，建议前往系统设置，允许访问所有照片。";
            _limitedButton.hidden = YES;
        }
    } else {
        if (authorizationStatus != QQAuthorizationStatusAuthorized) {
            _titleLabel.text = @"无法访问相册中照片";
            _tipsLabel.text = @"当前无照片访问权限，建议前往系统设置，允许访问所有照片。";
            _limitedButton.hidden = YES;
        }
    }
    [self resizeSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    
    CGFloat selfWidth = self.frame.size.width;
    CGFloat selfHeight = self.frame.size.height;
    
    CGFloat titleTop = [UIApplication sharedApplication].statusBarFrame.size.height + 44 + 100 * [UIScreen mainScreen].bounds.size.width / 375.0;
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(0, titleTop, selfWidth, _titleLabel.frame.size.height);
    
    CGFloat tipsWidth = selfWidth - 60;
    CGSize tipsSize = [_tipsLabel.text boundingRectWithSize:CGSizeMake(tipsWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_tipsLabel.font} context:nil].size;
    _tipsLabel.frame = CGRectMake(30, CGRectGetMaxY(_titleLabel.frame) + 25, tipsWidth, tipsSize.height);
    
    [_limitedButton sizeToFit];
    _limitedButton.frame = CGRectMake((selfWidth - _limitedButton.frame.size.width) / 2, selfHeight - 60 - self.qq_safeAreaInsets.bottom, _limitedButton.frame.size.width, 40);
    
    _toSettingButton.frame = CGRectMake((selfWidth - 155) / 2, CGRectGetMinY(_limitedButton.frame) - 40 - 40, 155, 40);
}

@end
