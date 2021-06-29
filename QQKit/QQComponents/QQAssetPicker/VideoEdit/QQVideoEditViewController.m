//
//  QQVideoEditViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/9.
//

#import "QQVideoEditViewController.h"
#import "QQVideoRangeSlider.h"
#import "QQSimpleVideoPlayerView.h"
#import "QQVideoEditToolBar.h"
#import "QQToast.h"
#import "UIView+QQExtension.h"
#import "QQUIHelper.h"
#import "QQVideoEditor.h"
#import "QQAssetsPickerHelper.h"

@interface QQVideoEditViewController ()<QQSimpleVideoPlayerViewDelegate,QQVideoRangeSliderDelegate>

@property (nonatomic, strong) QQSimpleVideoPlayerView *videoPlayerView;
@property (nonatomic, strong) QQVideoRangeSlider *videoRangeSlider;
@property (nonatomic, strong) QQVideoEditToolBar *toolBar;

@property (nonatomic, strong) QQAsset *asset;
@property (nonatomic, strong) AVAsset *videoAsset;
@property (nonatomic, strong) NSTimer *linePlayTimer;
@property (nonatomic, strong) NSTimer *repeatPlayTimer;

@property (nonatomic, assign) BOOL isDidAppear;
@property (nonatomic, assign) BOOL isWillDisappear;

@end

@implementation QQVideoEditViewController

- (instancetype)initWithAsset:(QQAsset *)asset videoAsset:(AVAsset *)videoAsset {
    if (self = [super init]) {
        _asset = asset;
        _videoAsset = videoAsset;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isDidAppear = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    if (!_videoPlayerView.videoAsset) {
        _videoPlayerView.videoAsset = self.videoAsset;
        self.videoRangeSlider.asset = self.videoAsset;
        [self playVideo];
        [self updateToolBar];
        [QQToast hideToast];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isWillDisappear = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopTimer];
    [self.videoRangeSlider cancelLoadVideoImageFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubviews];
    [QQToast showLoading:@"正在载入视频"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)initSubviews {
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    
    CGFloat toolBarHeight = self.view.qq_safeAreaInsets.bottom + 50;
    _toolBar = [[QQVideoEditToolBar alloc] initWithFrame:CGRectMake(0, self.view.qq_height - toolBarHeight, self.view.qq_width, toolBarHeight)];
    [_toolBar.cancelButton addTarget:self action:@selector(onCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar.doneButton addTarget:self action:@selector(onDoneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toolBar];
    
    _videoRangeSlider = [[QQVideoRangeSlider alloc] initWithFrame:CGRectMake((self.view.qq_width - QQUIHelper.deviceWidth + 20) / 2, _toolBar.qq_top - 50 - 20, QQUIHelper.deviceWidth, 50)];
    _videoRangeSlider.delegate = self;
    [self.view addSubview:_videoRangeSlider];
    
    _videoPlayerView = [[QQSimpleVideoPlayerView alloc] initWithFrame:CGRectMake(20, QQUIHelper.navigationBarMaxY, self.view.qq_width - 40, _videoRangeSlider.qq_top - QQUIHelper.navigationBarMaxY - 20)];
    _videoPlayerView.delegate = self;
    [self.view addSubview:_videoPlayerView];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat toolBarHeight = self.view.qq_safeAreaInsets.bottom + 50;
    _toolBar.frame = CGRectMake(0, self.view.qq_height - toolBarHeight, self.view.qq_width, toolBarHeight);
    
    _videoRangeSlider.frame = CGRectMake((self.view.qq_width - QQUIHelper.deviceWidth + 20) / 2, _toolBar.qq_top - 50 - 20, QQUIHelper.deviceWidth - 20, 50);
    
    _videoPlayerView.frame = CGRectMake(20, QQUIHelper.navigationBarMaxY, self.view.qq_width - 40, _videoRangeSlider.qq_top - QQUIHelper.navigationBarMaxY - 20);
}

- (void)applicationWillResignActiveNotification {
    [self videoRangeDidPanSliderLeft:_videoRangeSlider];
}

- (void)applicationDidBecomeActiveNotification {
    [self startTimer];
}

#pragma mark - NNVideoRangeSliderDelegate
- (void)videoRangeDidPanSliderLeft:(QQVideoRangeSlider *)videoRange {
    [self stopTimer];
    CMTime startTime = CMTimeMakeWithSeconds(_videoRangeSlider.leftSeconds, self.videoPlayerView.videoPlayer.currentTime.timescale);
    [self.videoPlayerView.videoPlayer seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self updateToolBar];
    
    _videoRangeSlider.playLine.qq_left = _videoRangeSlider.thumbWidth + _videoRangeSlider.leftPosition;
}

- (void)videoRangeDidPanSliderRight:(QQVideoRangeSlider *)videoRange {
    [self stopTimer];
    CMTime endTime = CMTimeMakeWithSeconds(_videoRangeSlider.rightSeconds, self.videoPlayerView.videoPlayer.currentTime.timescale);
    [self.videoPlayerView.videoPlayer seekToTime:endTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self updateToolBar];
    
    _videoRangeSlider.playLine.qq_right = _videoRangeSlider.thumbWidth + _videoRangeSlider.rightPosition;
}

- (void)videoRange:(QQVideoRangeSlider *)videoRange scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.leftSeconds, self.timescale);
    [self.videoPlayerView.videoPlayer seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self updateToolBar];
}

- (void)videoRange:(QQVideoRangeSlider *)videoRange scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _videoRangeSlider.playLine.qq_left =  videoRange.thumbWidth + _videoRangeSlider.leftPosition;
    [self stopTimer];
}

- (void)videoRange:(QQVideoRangeSlider *)videoRange scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self startTimer];
    }
}

- (void)videoRange:(QQVideoRangeSlider *)videoRange scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self startTimer];
}

- (void)videoRangeDidGestureStateEnded:(QQVideoRangeSlider *)videoRange {
    [self startTimer];
}

- (CMTimeScale)timescale {
    return self.videoPlayerView.videoPlayer.currentTime.timescale;
}

- (void)updateToolBar {
    if (ceil(_videoRangeSlider.duration) < 15) {
        self.toolBar.title = [NSString stringWithFormat:@"%.2fs ~ %.2fs", _videoRangeSlider.leftSeconds, _videoRangeSlider.rightSeconds];
    } else {
        self.toolBar.title = [NSString stringWithFormat:@"%@ ~ %@", [QQAssetsPickerHelper formatTime:_videoRangeSlider.leftSeconds], [QQAssetsPickerHelper formatTime:_videoRangeSlider.rightSeconds]];
    }
}

- (void)updateLinePosition {
    NSTimeInterval duaration = _videoRangeSlider.rightSeconds - _videoRangeSlider.leftSeconds;
    CGFloat right = _videoRangeSlider.rightPosition - _videoRangeSlider.playLine.qq_width;
    CGFloat left = _videoRangeSlider.leftPosition;
    CGFloat offset = 0.01 * (right - left) / duaration;
    _videoRangeSlider.playLine.qq_left += offset;
}

- (void)playVideo {
    if (!_videoAsset) return;
    self.videoPlayerView.videoAsset = _videoAsset;
    [self startTimer];
}

- (void)repeatPlayVideo {
    [self.videoPlayerView play];
    CMTime time = CMTimeMakeWithSeconds(_videoRangeSlider.leftSeconds, _videoPlayerView.videoPlayer.currentTime.timescale);
    [_videoPlayerView.videoPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    _videoRangeSlider.playLine.qq_left = _videoRangeSlider.thumbWidth + _videoRangeSlider.leftPosition;
}

- (void)startTimer {
    NSTimeInterval duaration = _videoRangeSlider.rightSeconds - _videoRangeSlider.leftSeconds;
    _videoRangeSlider.playLine.qq_left = _videoRangeSlider.thumbWidth + _videoRangeSlider.leftPosition;
    
    [self repeatPlayVideo];
    
    if (!_linePlayTimer) {
        self.linePlayTimer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(updateLinePosition) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.linePlayTimer forMode:NSRunLoopCommonModes];
    }
    
    if (!_repeatPlayTimer) {
        self.repeatPlayTimer = [NSTimer timerWithTimeInterval:duaration target:self selector:@selector(repeatPlayVideo) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.repeatPlayTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    if (self.repeatPlayTimer) {
        [self.repeatPlayTimer invalidate];
        self.repeatPlayTimer = nil;
    }
    if (self.linePlayTimer) {
        [self.linePlayTimer invalidate];
        self.linePlayTimer = nil;
    }
}

- (void)onCancelButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onDoneButtonClicked {
    
    CGFloat leftSeconds = round(self.videoRangeSlider.leftSeconds);
    CGFloat rightSeconds = round(self.videoRangeSlider.rightSeconds);
    CMTime start = CMTimeMakeWithSeconds(leftSeconds, self.videoPlayerView.videoPlayer.currentTime.timescale);
    CMTime duration = CMTimeMakeWithSeconds(rightSeconds - leftSeconds, self.videoPlayerView.videoPlayer.currentTime.timescale);
    CMTimeRange timeRange = CMTimeRangeMake(start, duration);
    
    NSURL *outputVideoURL = nil;
    if (_asset) {
        NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", _asset.fileName]];
        outputVideoURL = [NSURL fileURLWithPath:outputFilePath];
    }
    
    QQVideoEditor *editor = [[QQVideoEditor alloc] initWithAsset:_videoAsset presetName:AVAssetExportPresetMediumQuality];
    if (outputVideoURL) {
        editor.outputURL = outputVideoURL;
    }
    [editor addCropTimeTask:timeRange];
    [QQToast showProgress:0 text:@"裁剪中..."];
    [editor startTaskWithProgress:^(double progress) {
        [QQToast showProgress:progress text:@"裁剪中..."];
    } completion:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [QQToast showError:@"裁剪失败"];
            } else {
                [QQToast showSuccess:@"裁剪成功"];
                self.asset.editVideoURL = outputVideoURL;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        });
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden {
    if ((_isWillDisappear || !_isDidAppear)) {
        return NO;
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersNavigationBarHidden {
    return YES;
}

@end
