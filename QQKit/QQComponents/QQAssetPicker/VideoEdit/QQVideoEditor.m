//
//  QQVideoEditor.m
//  QQKitDemo
//
//  Created by Mac on 2021/6/21.
//

#import "QQVideoEditor.h"

static char * const QQVideoEditorSessionQueueKey = "QQVideoEditorSessionQueueKey";
@interface QQVideoEditor ()

@property (nonatomic, copy) NSString *presetName;
@property (nonatomic, strong) NSMutableArray<AVAsset *> *assets;
@property (nonatomic, assign) CMTimeRange timeRange;

@property (nonatomic, strong) AVMutableComposition *mutableComposition;
@property (nonatomic, strong) AVMutableVideoComposition *mutableVideoComposition;
@property (nonatomic, strong) AVAssetExportSession *exportSession;

@property (nonatomic , copy) void (^progress)(double progress);
@property (nonatomic , copy) void (^completion)(NSError *error);
@property (nonatomic, strong) NSTimer *progressTimer;

@end

@implementation QQVideoEditor {
    dispatch_queue_t _sessionQueue;
}

- (instancetype)initWithURL:(NSURL *)url presetName:(NSString *)presetName {
    return [self initWithAsset:[AVAsset assetWithURL:url] presetName:presetName];
}

- (instancetype)initWithAsset:(AVAsset *)asset presetName:(NSString *)presetName {
    if (self = [super init]) {
        if (asset) {
            [self.assets addObject:asset];
        }
        _presetName = presetName;
        if (!_presetName) {
            _presetName = AVAssetExportPresetMediumQuality;
        }
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    _outputFileType = AVFileTypeMPEG4;
    _outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"qq_edit_temp.mp4"]];
    _sessionQueue = dispatch_queue_create("qq.video.EditorSession", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_set_specific(_sessionQueue, QQVideoEditorSessionQueueKey, "ture", nil);
    dispatch_set_target_queue(_sessionQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    [self prepareComposition];
}

- (NSMutableArray<AVAsset *> *)assets {
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

- (AVMutableComposition *)mutableComposition {
    if (!_mutableComposition) {
        _mutableComposition = [AVMutableComposition composition];
    }
    return _mutableComposition;
}

- (AVMutableVideoComposition *)mutableVideoComposition {
    if (!_mutableVideoComposition) {
        _mutableVideoComposition  =[AVMutableVideoComposition videoComposition];
    }
    return _mutableVideoComposition;
}

- (AVAsset *)outputAsset {
    if (_outputURL) {
        return [AVAsset assetWithURL:_outputURL];
    }
    return nil;
}

- (void)prepareComposition {
    if (self.assets.count == 0) return;
    CGSize renderSize = [self autoAdapterRenderSize];
    NSMutableArray *instructions = [NSMutableArray array];
    
    CMTime nextClipStartTime = kCMTimeZero;
    for (NSInteger i = 0; i < self.assets.count; i++) {
        AVAsset *asset = self.assets[i];
        
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        
        // 可变视频轨道
        AVMutableCompositionTrack *compositionVideoTrack = nil;
        if (videoTrack) {
            compositionVideoTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        }
        
        // 可变音频轨道
        AVMutableCompositionTrack *compositionAudioTrack = nil;
        if (audioTrack) {
            compositionAudioTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        }
        
        // timeRange
        CMTimeRange timeRange = videoTrack.timeRange;
        
        
        if (compositionVideoTrack) {
            [compositionVideoTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:nextClipStartTime error:nil];
        }
        
        if (compositionAudioTrack) {
            [compositionAudioTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:nextClipStartTime error:nil];
        }
        
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = CMTimeRangeMake(nextClipStartTime, timeRange.duration);
        
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
        
        CGSize naturalSize = videoTrack.naturalSize;
        CGAffineTransform naturalTransform = videoTrack.preferredTransform;
        NSInteger rotateAngle = [self angleFromTransform:naturalTransform];
        if (rotateAngle == 90 || rotateAngle == 270) {
            naturalSize = CGSizeMake(naturalSize.height, naturalSize.width);
        }
        CGFloat scale = MIN(renderSize.width / naturalSize.width, renderSize.height / naturalSize.height);
        
        CGPoint translate = CGPointMake((renderSize.width - naturalSize.width * scale) / 2, (renderSize.height - naturalSize.height * scale) / 2);
        CGAffineTransform preferredTransform = naturalTransform;
        if (rotateAngle == 0) {
            preferredTransform = CGAffineTransformMake(naturalTransform.a * scale, naturalTransform.b * scale, naturalTransform.c * scale, naturalTransform.d * scale, translate.x, translate.y);
        } else if (rotateAngle == 90) {
            preferredTransform = CGAffineTransformMake(naturalTransform.a * scale, naturalTransform.b * scale, naturalTransform.c * scale, naturalTransform.d * scale, naturalSize.width + translate.x,  translate.y);
        } else if (rotateAngle == 180) {
            preferredTransform = CGAffineTransformMake(naturalTransform.a * scale, naturalTransform.b * scale, naturalTransform.c * scale, naturalTransform.d * scale, naturalSize.width + translate.x,  naturalSize.height + translate.y);
        } else if (rotateAngle == 270) {
            preferredTransform = CGAffineTransformMake(naturalTransform.a * scale, naturalTransform.b * scale, naturalTransform.c * scale, naturalTransform.d * scale, translate.x,  naturalSize.width + translate.y);
        }
        
        [layerInstruction setTransform:preferredTransform atTime:kCMTimeZero];
        instruction.layerInstructions = @[layerInstruction];
        [instructions addObject:instruction];
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRange.duration);
    }
    
    self.mutableComposition.naturalSize = renderSize;
    self.mutableVideoComposition.instructions = instructions;
    self.mutableVideoComposition.renderSize = renderSize;
    self.mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
}


- (void)addRotateTask:(CGFloat)rotateAngle {
    for (NSInteger i = 0; i < self.mutableVideoComposition.instructions.count; i++) {
        AVMutableVideoCompositionInstruction *instruction = (AVMutableVideoCompositionInstruction *)self.mutableVideoComposition.instructions.firstObject;
        
        AVMutableVideoCompositionLayerInstruction *layerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruction.layerInstructions.firstObject;
        
        CGAffineTransform t1;
        CGAffineTransform t2;
        CGSize renderSize = self.mutableVideoComposition.renderSize;
        if (rotateAngle == 90 || rotateAngle == -270) {
            t1 = CGAffineTransformMakeTranslation(renderSize.height, 0.0);
            renderSize = CGSizeMake(renderSize.height, renderSize.width);
        } else if (rotateAngle == 180 || rotateAngle == -180) {
            t1 = CGAffineTransformMakeTranslation(renderSize.width, renderSize.height);
            renderSize = CGSizeMake(renderSize.width, renderSize.height);
        } else if (rotateAngle == 270 || rotateAngle == -90){
            t1 = CGAffineTransformMakeTranslation(0.0, renderSize.width);
            renderSize = CGSizeMake(renderSize.height, renderSize.width);
        } else {
            t1 = CGAffineTransformMakeTranslation(0.0, 0.0);
            renderSize = CGSizeMake(renderSize.width, renderSize.height);
        }
        
        t2 = CGAffineTransformRotate(t1, (rotateAngle / 180.0) * M_PI );
        
        self.mutableComposition.naturalSize = self.mutableVideoComposition.renderSize = renderSize;
        
        CGAffineTransform existingTransform;
        if (![layerInstruction getTransformRampForTime:[self.mutableComposition duration] startTransform:&existingTransform endTransform:NULL timeRange:NULL]) {
            [layerInstruction setTransform:t2 atTime:kCMTimeZero];
        } else {
            CGAffineTransform newTransform =  CGAffineTransformConcat(existingTransform, t2);
            [layerInstruction setTransform:newTransform atTime:kCMTimeZero];
        }
        instruction.layerInstructions = @[layerInstruction];
    }
}

- (void)addCropRectTask:(CGRect)cropRect {
    CGSize renderSize = self.mutableVideoComposition.renderSize;
    CGSize targetSize = CGSizeMake(renderSize.width * cropRect.size.width, renderSize.height * cropRect.size.height);
    
    self.mutableComposition.naturalSize = self.mutableVideoComposition.renderSize = targetSize;
    
    for (NSInteger i = 0; i < self.mutableVideoComposition.instructions.count; i++) {
        AVMutableVideoCompositionInstruction *instruction = (AVMutableVideoCompositionInstruction *)self.mutableVideoComposition.instructions.firstObject;
        
        AVMutableVideoCompositionLayerInstruction *layerInstruction = (AVMutableVideoCompositionLayerInstruction *)instruction.layerInstructions.firstObject;
        
        CGAffineTransform t1 = CGAffineTransformMakeTranslation(cropRect.origin.x * renderSize.width, -cropRect.origin.y * renderSize.height);
        [layerInstruction setTransform:t1 atTime:kCMTimeZero];
        
        instruction.layerInstructions = @[layerInstruction];
    }
}

- (void)addCropTimeTask:(CMTimeRange)timeRange {
    _timeRange = timeRange;
}

- (void)addWatermarkTask:(UIImage *)image {
    if (!image) return;
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, self.mutableVideoComposition.renderSize.width, self.mutableVideoComposition.renderSize.height);
    videoLayer.frame = CGRectMake(0, 0, self.mutableVideoComposition.renderSize.width, self.mutableVideoComposition.renderSize.height);
    [parentLayer addSublayer:videoLayer];
    
    CALayer *exportWatermarkLayer = nil;
    if (image) {
        exportWatermarkLayer = [CALayer layer];
        exportWatermarkLayer.contents = (__bridge id)(image.CGImage);
        exportWatermarkLayer.frame = CGRectMake(0, 0, self.mutableVideoComposition.renderSize.width, self.mutableVideoComposition.renderSize.height);
        [parentLayer addSublayer:exportWatermarkLayer];
    }
    self.mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

- (void)addMixTask:(AVAsset *)asset {
    [self.assets addObject:asset];
    [self prepareComposition];
}

- (void)startTaskWithProgress:(void (^)(double))progress completion:(void (^)(NSError * _Nonnull))completion {
    [self dispatchSyncOnSessionQueue:^{
        self.progress = progress;
        self.completion = completion;
        [self exportSessionWithAsset:self.mutableComposition];
    }];
}

- (void)cancelTask {
    if (_exportSession) {
        [_exportSession cancelExport];
    }
}

- (void)exportSessionWithAsset:(AVAsset *)asset {
    // 删除之前的视频
    NSString *filePath = self.outputURL.path;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    _exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:_presetName];
    _exportSession.shouldOptimizeForNetworkUse = YES;
    _exportSession.videoComposition = self.mutableVideoComposition;
    _exportSession.outputFileType = self.outputFileType;
    _exportSession.outputURL = self.outputURL;
    if (CMTIMERANGE_IS_VALID(_timeRange)) {
        _exportSession.timeRange = _timeRange;
    }
    
    __weak typeof(self) weakSelf = self;
    [_exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (weakSelf.exportSession.status) {
            case AVAssetExportSessionStatusUnknown: {
                NSLog(@"AVAssetExportSessionStatusUnknown");
            }  break;
            case AVAssetExportSessionStatusWaiting: {
                NSLog(@"AVAssetExportSessionStatusWaiting");
            }  break;
            case AVAssetExportSessionStatusExporting: {
                NSLog(@"AVAssetExportSessionStatusExporting");
            }  break;
            case AVAssetExportSessionStatusFailed: {
                NSLog(@"AVAssetExportSessionStatusFailed");
                if (weakSelf.completion) {
                    weakSelf.completion(weakSelf.exportSession.error);
                }
                [weakSelf stopTimer];
            }  break;
            case AVAssetExportSessionStatusCancelled: {
                if (weakSelf.completion) {
                    weakSelf.completion(weakSelf.exportSession.error);
                }
                weakSelf.progress = nil;
                weakSelf.completion = nil;
                [weakSelf stopTimer];
            }  break;
            case AVAssetExportSessionStatusCompleted: {
                if (weakSelf.completion) {
                    weakSelf.completion(weakSelf.exportSession.error);
                }
                weakSelf.progress = nil;
                weakSelf.completion = nil;
                [weakSelf stopTimer];
            }  break;
            default: break;
        }
    }];
    [self startTimer];
}

- (void)dispatchSyncOnSessionQueue:(void(^)(void))block {
    if ([self isSessionQueue]) {
        block();
    } else {
        dispatch_sync(_sessionQueue, block);
    }
}

- (void)updateProgress {
    if (_exportSession.status == AVAssetExportSessionStatusExporting) {
        if (self.progress) {
            self.progress(_exportSession.progress);
        }
    }
}

- (BOOL)isSessionQueue {
    return dispatch_get_specific(QQVideoEditorSessionQueueKey) != nil;
}

- (void)startTimer {
    if (!_progressTimer) {
        _progressTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_progressTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopTimer {
    if (_progressTimer) {
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
}

- (void)dealloc {
    [self stopTimer];
}

#pragma mark - Helper
- (CGSize)autoAdapterRenderSize {
    CGFloat firstVideoWidth = 0.0;
    CGFloat firstVideoHeight = 0.0;
    
    for (NSInteger i = 0; i < self.assets.count; i++) {
        AVAsset *asset = self.assets[i];
        AVAssetTrack *assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        CGSize naturalSize = assetVideoTrack.naturalSize;
        NSInteger angle = [self angleFromTransform:assetVideoTrack.preferredTransform];
        if (angle == 90 || angle == 270) {
            naturalSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
        }
        if (i == 0) {
            firstVideoWidth = naturalSize.width;
            firstVideoHeight = naturalSize.height;
        }
        if (naturalSize.height >= naturalSize.width) {
            firstVideoWidth = naturalSize.width;
            firstVideoHeight = naturalSize.height;
            break;
        }
    }
    return CGSizeMake(firstVideoWidth, firstVideoHeight);
}

- (NSInteger)angleFromTransform:(CGAffineTransform)transform {
    NSInteger angle = 0;
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
        angle = 90;
    } else if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
        angle = 270;
    } else if (transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
        angle = 0;
    } else if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
        angle = 180;
    }
    return angle;
}

@end
