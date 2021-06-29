//
//  QQAssetGridCell.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQAssetGridCell.h"
#import <PhotosUI/PhotosUI.h>
#import "QQCheckboxButton.h"
#import "QQVideoInfoBar.h"
#import "QQEditedInfoBar.h"
#import "QQAssetsPicker.h"
#import "UIView+QQExtension.h"
#import "QQAssetsPickerHelper.h"

@interface QQAssetGridCell ()

// checkbox
@property (nonatomic, strong) QQCheckboxButton *checkboxButton;
// livePhotoIcon
@property (nonatomic, strong) UIImageView *livePhotoBadgeIcon;
// 动图icon
@property (nonatomic, strong) UIImageView *GIFIcon;
// 快照
@property (nonatomic, strong) UIImageView *burstIcon;
// 视频
@property (nonatomic, strong) QQVideoInfoBar *videoInfoBar;
// 已编辑
@property (nonatomic, strong) QQEditedInfoBar *editedInfoBar;
// mask
@property (nonatomic, strong) UIView *maskView;

@end

@implementation QQAssetGridCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.clipsToBounds = YES;
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_thumbnailImageView];
        
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_maskView];
        
        if (@available(iOS 9.1, *)) {
            _livePhotoBadgeIcon = [[UIImageView alloc] initWithImage:[PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent]];
            _livePhotoBadgeIcon.hidden = YES;
            [self.contentView addSubview:_livePhotoBadgeIcon];
        }
        
        _GIFIcon = [[UIImageView alloc] initWithImage:[QQAssetsPicker sharedPicker].configuration.assetPickerGIFImage];
        _GIFIcon.hidden = YES;
        [self.contentView addSubview:_GIFIcon];
        
        _burstIcon = [[UIImageView alloc] initWithImage:[QQAssetsPicker sharedPicker].configuration.assetPickerBurstImage];
        _burstIcon.hidden = YES;
        [self.contentView addSubview:_burstIcon];
        
        _checkboxButton = [[QQCheckboxButton alloc] init];
        _checkboxButton.hidden = YES;
        [_checkboxButton.actionButton addTarget:self action:@selector(onCheckboxButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_checkboxButton];
        
        _videoInfoBar = [[QQVideoInfoBar alloc] init];
        _videoInfoBar.hidden = YES;
        [self.contentView addSubview:_videoInfoBar];
        
        _editedInfoBar = [[QQEditedInfoBar alloc] init];
        _editedInfoBar.hidden = YES;
        [self.contentView addSubview:_editedInfoBar];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _maskView.frame = self.bounds;
    _thumbnailImageView.frame = self.bounds;
    if (@available(iOS 9.1, *)) {
        _livePhotoBadgeIcon.frame = CGRectMake(0, 0, CGRectGetWidth(_livePhotoBadgeIcon.frame), CGRectGetHeight(_livePhotoBadgeIcon.frame));
    }
    _checkboxButton.frame = CGRectMake(self.qq_width - _checkboxButton.imageView.qq_width - 5, 5, _checkboxButton.imageView.qq_width, _checkboxButton.imageView.qq_height);
    _GIFIcon.frame = CGRectMake(3, self.qq_height - _GIFIcon.qq_height - 4, _GIFIcon.qq_width, _GIFIcon.qq_height);
    _burstIcon.frame = CGRectMake(3, self.qq_height - _burstIcon.qq_height - 3, _burstIcon.qq_width, _burstIcon.qq_height);
    _videoInfoBar.frame = CGRectMake(0, self.qq_height - 22, self.qq_width, 22);
    _editedInfoBar.frame = CGRectMake(0, self.qq_height - 22, self.qq_width, 22);
}

- (void)onCheckboxButtonClicked {
    if ([self.delegate respondsToSelector:@selector(onCheckboxButtonClicked:)]) {
        [self.delegate onCheckboxButtonClicked:self.asset];
    }
}

- (void)renderWithAsset:(QQAsset *)asset referenceSize:(CGSize)referenceSize isMaxLimit:(BOOL)isMaxLimit {
    _asset = asset;
    if (asset.editImage) {
        self.thumbnailImageView.image = asset.editImage;
    } else if (asset.thumbnailImage) {
        self.thumbnailImageView.image = asset.thumbnailImage;
    } else {
        // 异步请求资源对应的缩略图
        [[QQAssetsPicker sharedPicker] requestThumbnailImageWithAsset:asset size:referenceSize completion:^(QQAsset *asset, UIImage *result) {
            if ([self.asset.identifier isEqualToString:asset.identifier] && result) {
                self.thumbnailImageView.image = result;
            }
        }];
    }
    if (asset.selected) {
        _maskView.hidden = NO;
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    } else {
        if (isMaxLimit) {
            _maskView.hidden = NO;
            _maskView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        } else {
            _maskView.hidden = YES;
            _maskView.backgroundColor = [UIColor clearColor];
        }
    }

    if ([self isLivePhoto]) {
        if (@available(iOS 9.1, *)) {
            _livePhotoBadgeIcon.hidden = (asset.assetMediaType != QQAssetMediaTypeLivePhoto);
        } else {
            _livePhotoBadgeIcon.hidden = YES;
        }
    } else {
        _livePhotoBadgeIcon.hidden = YES;
    }
    
    if ([QQAssetsPicker sharedPicker].configuration.allowsMultipleSelection) {
        _checkboxButton.hidden = NO;
        if (asset.selected) {
            _checkboxButton.indexLabel.hidden = NO;
            _checkboxButton.indexLabel.text = [NSString stringWithFormat:@"%ld", asset.selectedIndex + 1];
        } else {
            _checkboxButton.indexLabel.hidden = YES;
            _checkboxButton.indexLabel.text = @"";
        }
    } else {
        _checkboxButton.hidden = YES;
    }
    
    _GIFIcon.hidden = (asset.assetMediaType != QQAssetMediaTypeGIF);
    _burstIcon.hidden = (asset.assetMediaType != QQAssetMediaTypeBurst);
    _videoInfoBar.hidden = (asset.assetMediaType != QQAssetMediaTypeVideo);
    _videoInfoBar.duration = asset.duration;
    _editedInfoBar.hidden = !asset.editImage;
    self.hidden = asset.isHidden;
}

- (void)startSpringAnimation {
    [QQAssetsPickerHelper springAnimationForView:self.checkboxButton];
}

- (void)removeSpringAnimation {
    [QQAssetsPickerHelper removeSpringAnimationForView:self.checkboxButton];
}

- (BOOL)isLivePhoto {
    if (@available(iOS 9.1, *)) {
        if (self.asset.assetMediaType == QQAssetMediaTypeLivePhoto) {
            return YES;
        }
    }
    return NO;
}


@end
