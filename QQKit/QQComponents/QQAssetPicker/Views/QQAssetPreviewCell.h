//
//  QQAssetPreviewCell.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "QQAsset.h"
#import "QQAssetPreviewScrollView.h"
#import "QQSimpleVideoPlayerView.h"

#define kQQAssetBetweenPadding 20

@class QQAssetPreviewCell;
@protocol QQAssetPreviewCellDelegate <NSObject>

@optional
- (void)singleTapForAssetPreviewCell:(QQAssetPreviewCell *)assetPreviewCell;
- (void)videoDidPlayToEndEvent;

@end

@interface QQAssetPreviewCell : UICollectionViewCell

@property (nonatomic, weak) id <QQAssetPreviewCellDelegate> delegate;
@property (nonatomic, strong) QQAssetPreviewScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *playVideoButton;
@property (nonatomic, strong, readonly) UIView *containerView;

@property (nonatomic, strong) QQAsset *asset;

@property (nonatomic, weak) AVAsset *videoAsset;
@property (nonatomic, weak) PHLivePhoto *livePhoto API_AVAILABLE(ios(9.1));
@property (nonatomic, weak) UIImage *image;

/// AVPlayer
@property (nonatomic, assign, readonly) BOOL isPlaying;
- (void)destroyVideoPlayerViewIfNeeded;
- (void)pauseVideo;
- (void)endPlayingVideo;
- (void)resizeSubviewsSize;

@end

