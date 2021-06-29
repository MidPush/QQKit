//
//  QQVideoRangeSlider.h
//  QQKitDemo
//
//  Created by Mac on 2021/6/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 QQVideoRangeSlider 是 第三方库 SAVideoRangeSlider 的修改版
 源码地址：https://github.com/andrei200287/SAVideoRangeSlider
 */
NS_ASSUME_NONNULL_BEGIN

@class QQVideoRangeSlider;
@protocol QQVideoRangeSliderDelegate <NSObject>

@optional
- (void)videoRangeDidGestureStateEnded:(QQVideoRangeSlider *)videoRange;

- (void)videoRangeDidPanSliderLeft:(QQVideoRangeSlider *)videoRange;

- (void)videoRangeDidPanSliderRight:(QQVideoRangeSlider *)videoRange;

- (void)videoRange:(QQVideoRangeSlider *)videoRange scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)videoRange:(QQVideoRangeSlider *)videoRange scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)videoRange:(QQVideoRangeSlider *)videoRange scrollViewDidEndDragging:(UIScrollView *)scrollView
    willDecelerate:(BOOL)decelerate;

- (void)videoRange:(QQVideoRangeSlider *)videoRange scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

@interface QQVideoRangeSlider : UIView

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign, readonly) NSTimeInterval duration;

@property (nonatomic, weak) id<QQVideoRangeSliderDelegate> delegate;

@property (nonatomic, assign) CGFloat leftPosition;
@property (nonatomic, assign) CGFloat rightPosition;

// position转换成秒
@property (nonatomic, assign, readonly) CGFloat leftSeconds;
@property (nonatomic, assign, readonly) CGFloat rightSeconds;

@property (nonatomic, strong) UIView *playLine;
@property (nonatomic, assign, readonly) CGFloat thumbWidth;
@property (nonatomic, assign, readonly) CGSize itemSize;

// 取消获取视频帧图片
- (void)cancelLoadVideoImageFrame;

@end

NS_ASSUME_NONNULL_END
