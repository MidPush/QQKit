//
//  QQSimpleVideoPlayerView.h
//  QQKitDemo
//
//  Created by Mac on 2021/6/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QQSimpleVideoPlayerViewDelegate <NSObject>

@optional
// 播放到结尾
- (void)playerItemDidPlayToEndTime;

@end

@interface QQSimpleVideoPlayerView : UIView

@property (nonatomic, strong, readonly, nullable) AVPlayer *videoPlayer;
@property (nonatomic, strong, nullable) AVAsset *videoAsset;
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, weak) id<QQSimpleVideoPlayerViewDelegate> delegate;

- (void)play;
- (void)pause;
- (void)stop;
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
