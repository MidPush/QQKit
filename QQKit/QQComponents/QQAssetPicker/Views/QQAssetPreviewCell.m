//
//  QQAssetPreviewCell.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQAssetPreviewCell.h"
#import <PhotosUI/PhotosUI.h>
#import "QQAssetsPicker.h"
#import "QQUIHelper.h"
#import "QQAssetsPickerHelper.h"

@interface QQAssetPreviewCell ()<UIScrollViewDelegate, PHLivePhotoViewDelegate, QQSimpleVideoPlayerViewDelegate>

@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView API_AVAILABLE(ios(9.1));
@property (nonatomic, assign) BOOL isPlayingHint;

@property (nonatomic, strong) QQSimpleVideoPlayerView *videoPlayerView;

@end

@implementation QQAssetPreviewCell

- (QQAssetPreviewScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[QQAssetPreviewScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 3;
        _scrollView.minimumZoomScale = 1;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (PHLivePhotoView *)livePhotoView API_AVAILABLE(ios(9.1)) {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] initWithFrame:CGRectZero];
        _livePhotoView.delegate = self;
        _livePhotoView.hidden = YES;
    }
    return _livePhotoView;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.font = [UIFont systemFontOfSize:13];
    }
    return _progressLabel;
}

- (UIButton *)playVideoButton {
    if (!_playVideoButton) {
        _playVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playVideoButton.userInteractionEnabled = NO;
        _playVideoButton.hidden = YES;
        [_playVideoButton setImage:[QQAssetsPicker sharedPicker].configuration.assetPickerPlayImage forState:UIControlStateNormal];
    }
    return _playVideoButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat padding = kQQAssetBetweenPadding;
        self.scrollView.frame = CGRectMake(padding / 2, 0, self.frame.size.width - padding, self.frame.size.height);
        [self.contentView addSubview:self.scrollView];
        
        [self.scrollView addSubview:self.imageView];
        
        if (@available(iOS 9.1, *)) {
            self.livePhotoView.frame = self.scrollView.bounds;
            [self.scrollView addSubview:self.livePhotoView];
        }
        
        [self.contentView addSubview:self.progressLabel];
        
        self.playVideoButton.frame = CGRectMake((self.frame.size.width - 85) / 2, (self.frame.size.height - 85) / 2, 85, 85);
        [self.contentView addSubview:self.playVideoButton];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureHandler:)];
        singleTap.numberOfTapsRequired = 1;
        [self.scrollView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.scrollView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat padding = kQQAssetBetweenPadding;
    BOOL isSizeChanged = !CGSizeEqualToSize(self.scrollView.frame.size, CGSizeMake(self.bounds.size.width - padding, self.bounds.size.height));
    self.scrollView.frame = CGRectMake(padding / 2, 0, self.frame.size.width - padding, self.frame.size.height);
    CGFloat navMaxY = [QQUIHelper navigationBarHeight] + [QQUIHelper statusBarHeightConstant];
    self.progressLabel.frame = CGRectMake(padding, navMaxY + 10, 280, 30);
    self.playVideoButton.frame = CGRectMake((self.frame.size.width - 85) / 2, (self.frame.size.height - 85) / 2, 85, 85);
    if (isSizeChanged) {
        [self resizeSubviewsSize];
        if (self.videoPlayerView) {
            self.videoPlayerView.frame = [self videoPlayerViewFrame];
        }
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (!self.window) {
        [self endPlayingVideo];
    }
}

- (void)setAsset:(QQAsset *)asset {
    _asset = asset;
    if (_scrollView.zoomScale != 1.0) {
        [_scrollView setZoomScale:1.0 animated:NO];
    }
    
    if (asset.editImage) {
        _imageView.image = asset.editImage;
    } else {
        _imageView.image = asset.thumbnailImage;
        [self requestAsset];
    }
    
    [self hideViews];
    if (self.asset.assetMediaType == QQAssetMediaTypeVideo) {
        _playVideoButton.hidden = NO;
    } else if (self.asset.assetMediaType != QQAssetMediaTypeAudio) {
        BOOL isLivePhoto = [self isLivePhoto];
        if (isLivePhoto) {
            _livePhotoView.hidden = NO;
        }
    }
    
    [self updateProgressLabelWithAsset:asset];
    [self resizeSubviewsSize];
}

- (void)resizeSubviewsSize {
    if (_scrollView.zoomScale != 1.0) {
        [_scrollView setZoomScale:1.0 animated:NO];
    }
    
    UIImage *image = _imageView.image;
    CGSize imageSize = image.size;
    if (@available(iOS 9.1, *)) {
        if ([self isLivePhoto] && _livePhotoView.livePhoto) {
            // 使用livePhoto.size有可能会抖动，可能跟transform有关，以后再说
            PHLivePhoto *livePhoto = _livePhotoView.livePhoto;
            imageSize = livePhoto.size;
        }
    }
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        return;
    }
    
    CGSize boundsSize = self.scrollView.frame.size;
    CGRect targetFrame = [QQAssetsPickerHelper scaleAspectFillImage:imageSize boundsSize:boundsSize];
    if (self.asset.assetMediaType == QQAssetMediaTypeVideo) {
        targetFrame = [QQAssetsPickerHelper scaleAspectFitImage:imageSize boundsSize:boundsSize];
    }
    _imageView.frame = targetFrame;
    
    if (@available(iOS 9.1, *)) {
        if ([self isLivePhoto] && _livePhotoView.livePhoto) {
            _livePhotoView.frame = targetFrame;
        }
    }

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, MAX(targetFrame.size.height, self.scrollView.frame.size.height));
}

- (UIView *)containerView {
    if (!_videoPlayerView.hidden && self.videoAsset) {
        return _videoPlayerView;
    }
    if (@available(iOS 9.1, *)) {
        if ([self isLivePhoto] && self.livePhoto) {
            return _livePhotoView;
        } else {
            return _imageView;
        }
    }
    if (_imageView) {
        return _imageView;
    }
    return nil;
}

#pragma mark - <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.videoAsset) {
        return _videoPlayerView;
    }
    if (@available(iOS 9.1, *)) {
        if ([self isLivePhoto] && self.livePhoto) {
            return _livePhotoView;
        }
    }
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = self.containerView;
    CGSize boundsSize = scrollView.bounds.size;
    CGSize contentSize = scrollView.contentSize;
    
    CGFloat offsetX = (boundsSize.width > contentSize.width)?
    (boundsSize.width - contentSize.width) * 0.5 : 0.0;

    CGFloat offsetY = (boundsSize.height > contentSize.height)?
    (boundsSize.height - contentSize.height) * 0.5 : 0.0;

    subView.center = CGPointMake(contentSize.width * 0.5 + offsetX,
                                 contentSize.height * 0.5 + offsetY);
}

#pragma mark - <PHLivePhotoViewDelegate>
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle  API_AVAILABLE(ios(9.1)) {
    _isPlayingHint = (playbackStyle == PHLivePhotoViewPlaybackStyleHint);
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle  API_AVAILABLE(ios(9.1)) {
    _isPlayingHint = (playbackStyle == PHLivePhotoViewPlaybackStyleHint);
    [livePhotoView stopPlayback];
}

- (BOOL)isLivePhoto {
    if (@available(iOS 9.1, *)) {
        if (self.asset.assetMediaType == QQAssetMediaTypeLivePhoto) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Gesture Handler
- (void)singleTapGestureHandler:(UITapGestureRecognizer *)gesture {
    if (self.asset.assetMediaType == QQAssetMediaTypeVideo) {
        if (!self.videoAsset) return;
        if (self.playVideoButton.hidden) {
            [self pauseVideo];
        } else {
            [self playVideo];
        }
    }
    if ([self.delegate respondsToSelector:@selector(singleTapForAssetPreviewCell:)]) {
        [self.delegate singleTapForAssetPreviewCell:self];
    }
}

- (void)doubleTapGestureHandler:(UITapGestureRecognizer *)gesture {
    if (self.scrollView.zoomScale > 1) {
        [self.scrollView setZoomScale:1 animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:_imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - AVPlayer
- (BOOL)isVideoAsset {
    return self.asset.assetMediaType == QQAssetMediaTypeVideo;
}

- (BOOL)isPlaying {
    return self.videoPlayerView.playing;
}

- (void)initVideoPlayerViewIfNeeded {
    if (![self isVideoAsset] || !self.videoAsset) {
        return;
    }
    
    if (self.videoPlayerView) {
        _videoPlayerView.frame = [self videoPlayerViewFrame];
        return;
    }
    
    self.videoPlayerView = [[QQSimpleVideoPlayerView alloc] initWithFrame:[self videoPlayerViewFrame]];
    self.videoPlayerView.delegate = self;
    [self.scrollView addSubview:self.videoPlayerView];
}

- (void)destroyVideoPlayerViewIfNeeded {
    if (self.videoPlayerView) {
        [self.videoPlayerView destroy];
        self.videoPlayerView = nil;
    }
}

- (void)playVideo {
    if (![self isVideoAsset]) return;
    
    [self.videoPlayerView play];
    self.playVideoButton.hidden = YES;
}

- (void)pauseVideo {
    if (![self isVideoAsset]) return;
    
    [self.videoPlayerView pause];
    self.playVideoButton.hidden = NO;
}

- (void)endPlayingVideo {
    if (![self isVideoAsset]) return;

    [self.videoPlayerView stop];
    self.playVideoButton.hidden = NO;
}

- (CGRect)videoPlayerViewFrame {
    if (!self.videoAsset || CGSizeEqualToSize(CGSizeZero, self.asset.naturalSize)) {
        return _imageView.frame;
    }
    return [QQAssetsPickerHelper scaleAspectFitImage:self.asset.naturalSize boundsSize:self.scrollView.bounds.size];
}

#pragma mark - QQSimpleVideoPlayerViewDelegate
- (void)playerItemDidPlayToEndTime {
    if (![self isVideoAsset]) return;
    [self.videoPlayerView stop];
    self.playVideoButton.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(videoDidPlayToEndEvent)]) {
        [self.delegate videoDidPlayToEndEvent];
    }
}

#pragma mark - Request
- (void)requestAsset {
    if (self.asset.assetMediaType == QQAssetMediaTypeVideo) {
        [[QQAssetsPicker sharedPicker] requestAVAssetWithAsset:self.asset progressHandler:^(QQAsset *asset, double downloadProgress) {
            [self updateProgressLabelWithAsset:asset];
        } completion:^(QQAsset *asset, AVAsset *avAsset) {
            [self updateProgressLabelWithAsset:asset];
            if ([self.asset.identifier isEqualToString:asset.identifier] && avAsset) {
                self.videoAsset = avAsset;
            }
        }];
    } else if (self.asset.assetMediaType != QQAssetMediaTypeAudio) {
        BOOL isLivePhoto = [self isLivePhoto];
        if (isLivePhoto) {
            if (@available(iOS 9.1, *)) {
                [[QQAssetsPicker sharedPicker] requestLivePhotoWithAsset:self.asset progressHandler:^(QQAsset *asset, double downloadProgress) {
                    [self updateProgressLabelWithAsset:asset];
                } completion:^(QQAsset *asset, PHLivePhoto *livePhoto) {
                    [self updateProgressLabelWithAsset:asset];
                    if ([self.asset.identifier isEqualToString:asset.identifier] && livePhoto) {
                        self.livePhoto = livePhoto;
                    }
                }];
            }
        } else if (self.asset.assetMediaType == QQAssetMediaTypeGIF) {
            [[QQAssetsPicker sharedPicker] requestOriginImageWithAsset:self.asset progressHandler:^(QQAsset *asset, double downloadProgress) {
                [self updateProgressLabelWithAsset:asset];
            } completion:^(QQAsset *asset, UIImage *result) {
                [self updateProgressLabelWithAsset:asset];
                if ([self.asset.identifier isEqualToString:asset.identifier] && result) {
                    self.image = result;
                }
            }];
        } else {
            [[QQAssetsPicker sharedPicker] requestPreviewImageWithAsset:self.asset synchronous:NO progressHandler:^(QQAsset *asset, double downloadProgress) {
                [self updateProgressLabelWithAsset:asset];
            } completion:^(QQAsset *asset, UIImage *result) {
                [self updateProgressLabelWithAsset:asset];
                if ([self.asset.identifier isEqualToString:asset.identifier] && result) {
                    self.image = result;
                }
            }];
        }
    }
}

#pragma mark - Setter Data
- (void)setImage:(UIImage *)image {
    _image = image;
    
    if (image) {
        if (@available(iOS 9.1, *)) {
            self.livePhoto = nil;
        }
        self.videoAsset = nil;
    }
    
    if (!image) {
        _imageView.image = nil;
        _imageView.hidden = YES;
        return;
    }
    
    self.imageView.image = image;
    [self resizeSubviewsSize];
    [self hideViews];
    self.imageView.hidden = NO;
}

- (void)setLivePhoto:(PHLivePhoto *)livePhoto {
    _livePhoto = livePhoto;
    
    if (!livePhoto) {
        _livePhotoView.livePhoto = nil;
        _livePhotoView.hidden = YES;
        return;
    }
    
    if (livePhoto) {
        _livePhotoView.livePhoto = livePhoto;
        [self resizeSubviewsSize];
        [self hideViews];
        _livePhotoView.hidden = NO;
        
        self.videoAsset = nil;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 延迟隐藏_imageView，不然显示视频
            self.image = nil;
        });
    }
}

- (void)setVideoAsset:(AVAsset *)videoAsset {
    _videoAsset = videoAsset;
    
    if (!videoAsset) {
        [self destroyVideoPlayerViewIfNeeded];
        return;
    }
    
    if (videoAsset) {
        [self initVideoPlayerViewIfNeeded];
        self.videoPlayerView.videoAsset = self.videoAsset;
        
        self.videoPlayerView.hidden = NO;
        self.playVideoButton.hidden = NO;
    
        if (@available(iOS 9.1, *)) {
            self.livePhoto = nil;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 延迟隐藏_imageView，不然显示视频
            self.image = nil;
        });
    }
}

- (void)hideViews {
    _livePhotoView.hidden = YES;
    _playVideoButton.hidden = YES;
    _videoPlayerView.hidden = YES;
}

#pragma mark - Update
- (void)updateProgressLabelWithAsset:(QQAsset *)asset {
    if (![self.asset.identifier isEqualToString:asset.identifier]) return;
    CGFloat progress = asset.downloadProgress;
    if (asset.downloadStatus == QQAssetDownloadStatusFailed) {
        self.progressLabel.hidden = NO;
        self.progressLabel.text = @"iCloud同步失败";
    } else if (asset.downloadStatus == QQAssetDownloadStatusSucceed || asset.downloadStatus == QQAssetDownloadStatusCanceled) {
        self.progressLabel.hidden = YES;
        self.progressLabel.text = @"";
    } else {
        self.progressLabel.text = [NSString stringWithFormat:@"iCloud同步中 %.0f%%", progress * 100];
        if (progress > 0.0 && progress < 1.0) {
            self.progressLabel.hidden = NO;
        } else {
            self.progressLabel.hidden = YES;
        }
    }
}

- (void)dealloc {
    [self destroyVideoPlayerViewIfNeeded];
}

@end
