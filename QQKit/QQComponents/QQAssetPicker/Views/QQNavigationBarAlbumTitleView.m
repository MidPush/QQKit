//
//  QQNavigationBarAlbumTitleView.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/5.
//

#import "QQNavigationBarAlbumTitleView.h"
#import "UIView+QQExtension.h"
#import "QQAssetsPicker.h"

@interface QQNavigationBarAlbumTitleView ()

@property (nonatomic, strong) UIView *buttonWrapperView;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UIImageView *arrowIcon;

@end

@implementation QQNavigationBarAlbumTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _buttonWrapperView = [[UIView alloc] init];
        _buttonWrapperView.backgroundColor = [UIColor colorWithRed:73/255.0 green:73/255.0 blue:73/255.0 alpha:1.0];
        [self addSubview:_buttonWrapperView];
        
        _albumNameLabel = [[UILabel alloc] init];
        _albumNameLabel.font = [UIFont boldSystemFontOfSize:16];
        _albumNameLabel.textColor = [UIColor whiteColor];
        [_buttonWrapperView addSubview:_albumNameLabel];
        
        _arrowIcon = [[UIImageView alloc] initWithImage:[QQAssetsPicker sharedPicker].configuration.assetPickerNavArrowImage];
        [_buttonWrapperView addSubview:_arrowIcon];
        
        _actionButton = [[UIButton alloc] init];
        [_buttonWrapperView addSubview:_actionButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeSubviews:NO];
}

- (void)resizeSubviews:(BOOL)animated {
    [_albumNameLabel sizeToFit];
    CGSize contentMaxSize = CGSizeMake(210, 30);
    CGSize arrowSize = _arrowIcon.frame.size;
    CGSize albumNameSize = _albumNameLabel.frame.size;
    
    _buttonWrapperView.layer.cornerRadius = contentMaxSize.height / 2;
    _buttonWrapperView.layer.masksToBounds = YES;
    
    CGFloat totalWidth = 15 + albumNameSize.width + 10 + arrowSize.width + 5;
    CGRect contentFrame = CGRectZero;
    CGRect albumNameFrame = CGRectZero;
    CGRect arrowFrame = CGRectZero;
    if (totalWidth <= contentMaxSize.width) {
        contentFrame = CGRectMake((self.frame.size.width - totalWidth) / 2, (self.frame.size.height - contentMaxSize.height) / 2, totalWidth, contentMaxSize.height);
        albumNameFrame = CGRectMake(15, (contentMaxSize.height - albumNameSize.height) / 2, albumNameSize.width, albumNameSize.height);
        arrowFrame = CGRectMake(CGRectGetMaxX(albumNameFrame) + 10, (contentMaxSize.height - arrowSize.height) / 2, arrowSize.width, arrowSize.height);
    } else {
        contentFrame = CGRectMake(0, (self.frame.size.height - contentMaxSize.height) / 2, contentMaxSize.width, contentMaxSize.height);
        arrowFrame = CGRectMake(contentMaxSize.width - arrowSize.width - 5, (contentMaxSize.height - arrowSize.height) / 2, arrowSize.width, arrowSize.height);
        albumNameFrame = CGRectMake(15, (contentMaxSize.height - albumNameSize.height) / 2, contentMaxSize.width - 15 - arrowSize.width - 5 - 10, albumNameSize.height);
    }
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.buttonWrapperView.frame = contentFrame;
            self.albumNameLabel.frame = albumNameFrame;
            self.arrowIcon.frame = arrowFrame;
        }];
    } else {
        self.buttonWrapperView.frame = contentFrame;
        self.albumNameLabel.frame = albumNameFrame;
        self.arrowIcon.frame = arrowFrame;
    }
    _actionButton.frame = CGRectMake(0, 0, contentFrame.size.width, contentFrame.size.height);
}

- (void)updateAlbumName:(NSString *)albumName animated:(BOOL)animated {
    _albumNameLabel.text = albumName;
    [self resizeSubviews:animated];
}

- (void)rotateArrowIcon {
    [UIView animateWithDuration:0.25 animations:^{
        self.arrowIcon.transform = CGAffineTransformRotate(self.arrowIcon.transform, M_PI);
    }];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(210, 44);
}

@end
