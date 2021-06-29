//
//  QQVideoRangeSlider.m
//  QQKitDemo
//
//  Created by Mac on 2021/6/22.
//

#import "QQVideoRangeSlider.h"
#import "QQSliderLeft.h"
#import "QQSliderRight.h"
#import "QQVideoImageFrameCell.h"
#import "UIView+QQExtension.h"
#import "UIImage+QQExtension.h"

static NSString *const kQQVideoImageFrameCellReuseID = @"QQVideoImageFrameCell";
static CGFloat kQQBorderHeight = 3.0;
static CGFloat kQQMarginTop = 3.0;
@interface QQVideoRangeSlider ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) QQSliderLeft *leftThumb;
@property (nonatomic, strong) QQSliderRight *rightThumb;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;

@property (nonatomic, strong) NSMutableArray<QQVideoImageFrameModel *> *imageFrames;

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@end

@implementation QQVideoRangeSlider

- (NSMutableArray<QQVideoImageFrameModel *> *)imageFrames {
    if (!_imageFrames) {
        _imageFrames = [NSMutableArray array];
    }
    return _imageFrames;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.thumbWidth, kQQBorderHeight + kQQMarginTop, self.qq_width - 2 * self.thumbWidth, self.itemSize.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
    [_collectionView registerClass:[QQVideoImageFrameCell class] forCellWithReuseIdentifier:kQQVideoImageFrameCellReuseID];
    
    _topBorder = [[UIView alloc] init];
    _topBorder.backgroundColor = [UIColor whiteColor];
    [self addSubview:_topBorder];
    
    _bottomBorder = [[UIView alloc] init];
    _bottomBorder.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bottomBorder];
    
    _leftThumb = [[QQSliderLeft alloc] init];
    _leftThumb.userInteractionEnabled = YES;
    [self addSubview:_leftThumb];
    
    _rightThumb = [[QQSliderRight alloc] init];
    _rightThumb.userInteractionEnabled = YES;
    [self addSubview:_rightThumb];
    
    _playLine = [[UIView alloc] init];
    _playLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:_playLine];
    
    
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [_leftThumb addGestureRecognizer:leftPan];
    
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [_rightThumb addGestureRecognizer:rightPan];
    
    _leftPosition = 0;
    _rightPosition = self.collectionView.qq_width;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    _collectionView.frame = CGRectMake(self.thumbWidth, kQQBorderHeight + kQQMarginTop, self.qq_width - 2 * self.thumbWidth, self.itemSize.height);
    
    _leftThumb.qq_width = self.thumbWidth;
    _leftThumb.qq_height = self.qq_height - 2 * kQQMarginTop;
    _leftThumb.center = CGPointMake(_leftPosition + self.thumbWidth / 2, self.qq_height / 2);
    
    _rightThumb.qq_width = self.thumbWidth;
    _rightThumb.qq_height = self.qq_height - 2 * kQQMarginTop;
    _rightThumb.center = CGPointMake(_rightPosition + self.thumbWidth + self.thumbWidth / 2, self.qq_height / 2);
    
    _topBorder.frame = CGRectMake(_leftThumb.qq_right, kQQMarginTop, _rightThumb.qq_left - _leftThumb.qq_right, kQQBorderHeight);
    
    _bottomBorder.frame = CGRectMake(_topBorder.qq_left, self.qq_height - kQQBorderHeight - kQQMarginTop, _topBorder.qq_width, kQQBorderHeight);
    
    _playLine.frame = CGRectMake(_leftThumb.qq_right, 0, 5, self.qq_height);
    _playLine.layer.cornerRadius = _playLine.qq_width / 2.0;
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageFrames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QQVideoImageFrameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQQVideoImageFrameCellReuseID forIndexPath:indexPath];
    cell.imageFrameModel = self.imageFrames[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(videoRange:scrollViewDidScroll:)]) {
        [self.delegate videoRange:self scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(videoRange:scrollViewWillBeginDragging:)]) {
        [self.delegate videoRange:self scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(videoRange:scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate videoRange:self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (!decelerate) {
        [self loadVideoImageFrame];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(videoRange:scrollViewDidEndDecelerating:)]) {
        [self.delegate videoRange:self scrollViewDidEndDecelerating:scrollView];
    }
    [self loadVideoImageFrame];
}

#pragma mark - Setter & Getter
- (CGFloat)thumbWidth {
    return ceil(self.qq_width * 0.05);
}

- (CGSize)itemSize {
    NSInteger count = 15;
    return CGSizeMake((self.qq_width - 2 * self.thumbWidth) / (CGFloat)count, self.qq_height - 2 * kQQBorderHeight - 2 * kQQMarginTop);
}

- (CGFloat)leftSeconds {
    CGFloat limitSeconds = (_leftPosition + _collectionView.contentOffset.x) / self.collectionView.contentSize.width * _duration;
    limitSeconds = MAX(MIN(_duration, limitSeconds), 0);
    return limitSeconds;
}

- (CGFloat)rightSeconds {
    CGFloat limitSeconds = (_rightPosition + _collectionView.contentOffset.x) / self.collectionView.contentSize.width * _duration;
    limitSeconds = MIN(MAX(0, limitSeconds), _duration);
    return limitSeconds;
}

- (CGFloat)frameWidth {
    return self.collectionView.qq_width;
}

- (void)setAsset:(AVAsset *)asset {
    _asset = asset;
    [self loadPlaceholderImage];
    [self.collectionView layoutIfNeeded];
    [self loadVideoImageFrame];
}

#pragma mark - Pan Gesture
- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPosition += translation.x;
        if (_leftPosition < 0) {
            _leftPosition = 0;
        }
        
        if (_rightPosition - _leftPosition <= self.itemSize.width) {
            _leftPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        if ([self.delegate respondsToSelector:@selector(videoRangeDidPanSliderLeft:)]) {
            [self.delegate videoRangeDidPanSliderLeft:self];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(videoRangeDidGestureStateEnded:)]) {
            [self.delegate videoRangeDidGestureStateEnded:self];
        }
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _rightPosition += translation.x;
        if (_rightPosition < 0) {
            _rightPosition = 0;
        }
        
        if (_rightPosition > self.frameWidth) {
            _rightPosition = self.frameWidth;
        }
        
        if (_rightPosition - _leftPosition <= 0){
            _rightPosition -= translation.x;
        }
        
        if (_rightPosition - _leftPosition <= self.itemSize.width) {
            _rightPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        if ([self.delegate respondsToSelector:@selector(videoRangeDidPanSliderRight:)]) {
            [self.delegate videoRangeDidPanSliderRight:self];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(videoRangeDidGestureStateEnded:)]) {
            [self.delegate videoRangeDidGestureStateEnded:self];
        }
    }
}

- (void)loadPlaceholderImage {
    if (!_asset) return;
    _duration = CMTimeGetSeconds(_asset.duration);

    NSMutableArray *allTimes = [NSMutableArray array];
    if (_duration >= 15.0) {
        int totalCount = ceilf(_duration);
        for (NSInteger i = 0; i < totalCount; i++) {
            QQVideoImageFrameModel *model = [[QQVideoImageFrameModel alloc] init];
            model.image = [UIImage qq_imageWithColor:[UIColor whiteColor]];
            [self.imageFrames addObject:model];
        }
    } else {
        int totalCount = ceil(self.frameWidth / self.itemSize.width);
        for (int i = 0; i < totalCount; i++) {
            QQVideoImageFrameModel *model = [[QQVideoImageFrameModel alloc] init];
            model.image = [UIImage qq_imageWithColor:[UIColor whiteColor]];
            [self.imageFrames addObject:model];
        }
    }
    _collectionView.contentSize = CGSizeMake(self.itemSize.width * allTimes.count, 0);
    _rightPosition = self.collectionView.qq_width;
    _leftPosition = 0;
    [self resizeSubviews];
    [self.collectionView reloadData];
}

- (void)loadVideoImageFrame {
    if (!_asset) return;
    
    // 排序
    NSArray *visibleCells = [self.collectionView visibleCells];
    NSArray *sortedVisibleCells = [visibleCells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath *path1 = (NSIndexPath *)[self.collectionView indexPathForCell:obj1];
        NSIndexPath *path2 = (NSIndexPath *)[self.collectionView indexPathForCell:obj2];
        return [path1 compare:path2];
    }];
    
    NSMutableArray *allTimes = [NSMutableArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < sortedVisibleCells.count; i++) {
        QQVideoImageFrameCell *cell = sortedVisibleCells[i];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        QQVideoImageFrameModel *model = self.imageFrames[indexPath.item];
        if (!model.finish) {
            if (_duration > 15.0) {
                CMTime timeFrame = CMTimeMakeWithSeconds(indexPath.item, _asset.duration.timescale);
                [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
                dict[[NSValue valueWithCMTime:timeFrame]] = model;
            } else {
                CMTime timeFrame = CMTimeMakeWithSeconds(_duration * indexPath.item * self.itemSize.width / self.frameWidth, _asset.duration.timescale);
                [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
                dict[[NSValue valueWithCMTime:timeFrame]] = model;
            }
        }
    }
    
    if (allTimes.count == 0) {
        // 已经全部加载完成
        return;
    }
    
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_asset];
    _imageGenerator.appliesPreferredTrackTransform = YES;
    _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    _imageGenerator.maximumSize = CGSizeMake(self.frameWidth * [UIScreen mainScreen].scale, self.itemSize.height * [UIScreen mainScreen].scale);
    
    __weak typeof(self) weakSelf = self;
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:allTimes completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *imageFrame = [[UIImage alloc] initWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imageFrame) {
                    QQVideoImageFrameModel *model = dict[[NSValue valueWithCMTime:requestedTime]];
                    model.image = imageFrame;
                    model.finish = YES;
                    [weakSelf.collectionView reloadData];
                }
            });
        }
    }];
}

- (void)cancelLoadVideoImageFrame {
    if (_imageGenerator) {
        [_imageGenerator cancelAllCGImageGeneration];
    }
}

@end
