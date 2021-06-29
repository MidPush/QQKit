//
//  QQSimpleVideoPlayerView.m
//  QQKitDemo
//
//  Created by Mac on 2021/6/22.
//

#import "QQSimpleVideoPlayerView.h"

@interface QQSimpleVideoPlayerView ()

@property (nonatomic, strong) AVPlayerLayer *videoPlayerLayer;

@end

@implementation QQSimpleVideoPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setVideoAsset:(AVAsset *)videoAsset {
    _videoAsset = videoAsset;
    if (videoAsset) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
        _videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        self.videoPlayerLayer = (AVPlayerLayer *)self.layer;
        self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.videoPlayerLayer.player = self.videoPlayer;
        self.videoPlayerLayer.contentsScale = [UIScreen mainScreen].scale;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTimeNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    }
}

- (void)play {
    [self.videoPlayer play];
    _playing = YES;
}

- (void)pause {
    [self.videoPlayer pause];
    _playing = NO;
}

- (void)stop {
    if (self.videoPlayer) {
        [self.videoPlayer.currentItem seekToTime:kCMTimeZero];
        [self.videoPlayer pause];
        [self.videoPlayer cancelPendingPrerolls];
    }
    _playing = NO;
}

- (void)playerItemDidPlayToEndTimeNotification {
    [self stop];
    if ([self.delegate respondsToSelector:@selector(playerItemDidPlayToEndTime)]) {
        [self.delegate playerItemDidPlayToEndTime];
    }
}

- (void)applicationWillResignActiveNotification {
    [self pause];
}

- (void)destroy {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [self stop];
    _videoAsset = nil;
    _videoPlayer = nil;
    _videoPlayerLayer.player = nil;
    [self removeFromSuperview];
}

@end
