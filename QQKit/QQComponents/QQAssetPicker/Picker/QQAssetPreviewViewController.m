//
//  QQAssetPreviewViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQAssetPreviewViewController.h"
#import "QQAssetPreviewCell.h"
#import "QQAssetGridCell.h"
#import "QQPreviewNavigationBar.h"
#import "QQSelectAssetToolBar.h"
#import "QQUIHelper.h"
#import "QQAssetsPickerHelper.h"
#import "UIView+QQExtension.h"
#import "QQAssetsPicker.h"
#import "QQToast.h"
#import "QQImageCropViewController.h"
#import "QQVideoEditViewController.h"

static NSString *kAssetPreviewCellID = @"NNAssetPreviewCell";
@interface QQAssetPreviewViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, QQAssetPreviewCellDelegate, QQImageCropViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) QQPreviewNavigationBar *navigationBar;
@property (nonatomic, strong) QQSelectAssetToolBar *toolBar;
@property (nonatomic, assign) BOOL barIsHidden;


@property (nonatomic, strong) NSMutableArray<QQAsset *> *assets;
@property (nonatomic, strong) NSMutableArray<QQAsset *> *selectedAssets;
@property (nonatomic, assign) NSInteger fromIndex;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger previousPage;

@property (nonatomic, assign) BOOL isPresented;
@property (nonatomic, assign) BOOL isDismissed;
@property (nonatomic, assign) BOOL isDraggingPhoto;
@property (nonatomic, assign) BOOL performingLayout;
@property (nonatomic, assign) CGPoint gestureBeganLocation;
@property (nonatomic, assign) CGAffineTransform imageViewBeginTransform;

@end

@implementation QQAssetPreviewViewController

#pragma mark - Init
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat padding = kQQAssetBetweenPadding;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(self.view.frame.size.width + padding, self.view.frame.size.height);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[QQAssetPreviewCell class] forCellWithReuseIdentifier:kAssetPreviewCellID];
        if (@available(iOS 11, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _collectionView;
}

- (QQPreviewNavigationBar *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [[QQPreviewNavigationBar alloc] init];
        [_navigationBar.backButton addTarget:self action:@selector(onBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_navigationBar.checkboxButton.actionButton addTarget:self action:@selector(onCheckboxButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navigationBar;
}

- (QQSelectAssetToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[QQSelectAssetToolBar alloc] initWithToolBarType:ToolBarTypeEdit];
        [_toolBar.leftButton addTarget:self action:@selector(onToolBarEditButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.originImageButton addTarget:self action:@selector(onToolBarOriginImageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.doneButton addTarget:self action:@selector(onToolBarDoneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:YES];
    [self toolBarAminationWithHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self toolBarAminationWithHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [self.currentCell endPlayingVideo];
        [self.currentCell destroyVideoPlayerViewIfNeeded];
    } else {
        [self.currentCell pauseVideo];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        self.isPresented = NO;
        self.isDismissed = NO;
        self.isDraggingPhoto = NO;
        self.performingLayout = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.navigationBar];
    [self.view addSubview:self.toolBar];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    panGesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGesture];
    
    [self updateNavigationBar];
    [self updateToolBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _performingLayout = YES;
    
    CGFloat padding = kQQAssetBetweenPadding;
    BOOL isSizeChanged = !CGSizeEqualToSize(self.collectionView.bounds.size, CGSizeMake(self.view.frame.size.width + padding, self.view.frame.size.height));
    if (isSizeChanged) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
    self.collectionView.frame = CGRectMake(-padding / 2, 0, self.view.frame.size.width + padding, self.view.frame.size.height);

    CGFloat statusBarHeight = [QQUIHelper statusBarHeightConstant];
    CGFloat navigationBarHeight = [QQUIHelper navigationBarHeight];
    self.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, statusBarHeight + navigationBarHeight);
    
    self.toolBar.frame = CGRectMake(0, self.view.frame.size.height - self.view.qq_safeAreaInsets.bottom - 50, self.view.frame.size.width, 50 + self.view.qq_safeAreaInsets.bottom);
    
    [self scrollToPage:_currentPage];
    
    if (isSizeChanged) {
        for (QQAssetPreviewCell *cell in self.collectionView.visibleCells) {
            cell.scrollView.zoomScale = 1.0;
            [cell resizeSubviewsSize];
        }
    }
    
    [self performPresentAnimation];
    
    _performingLayout = NO;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QQAssetPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAssetPreviewCellID forIndexPath:indexPath];
    cell.delegate = self;
    QQAsset *asset = self.assets[indexPath.item];
    cell.asset = asset;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat padding = kQQAssetBetweenPadding;
    return CGSizeMake(self.view.frame.size.width + padding, self.view.frame.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    QQAssetPreviewCell *previewCell = (QQAssetPreviewCell *)cell;
    [previewCell.scrollView setZoomScale:1.0 animated:NO];
    [previewCell endPlayingVideo];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _previousPage = self.currentPage;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_performingLayout) return;
    _currentPage = _collectionView.contentOffset.x / _collectionView.frame.size.width + 0.5;
    if (_currentPage >= _assets.count) _currentPage = _assets.count - 1;
    if (_currentPage < 0) _currentPage = 0;
    if (_previousPage != _currentPage) {
        QQAsset *previousAsset = self.assets[_previousPage];
        QQAsset *currentAsset = self.assets[_currentPage];
        previousAsset.isHidden = NO;
        currentAsset.isHidden = YES;
        if ([self.delegate respondsToSelector:@selector(needsUpdateSourceViewHideOrShow)]) {
            [self.delegate needsUpdateSourceViewHideOrShow];
        }
        _previousPage = _currentPage;
    }
    [self updateNavigationBar];
    [self updateToolBar];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.currentCell pauseVideo];
}

#pragma mark - QQImageCropViewControllerDelegate
- (void)cropViewController:(nonnull QQImageCropViewController *)cropViewController
            didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle {
    [self updateEditAsset:image cropViewController:cropViewController];
}

- (void)cropViewController:(nonnull QQImageCropViewController *)cropViewController
    didCropToCircularImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle {
    [self updateEditAsset:image cropViewController:cropViewController];
}

- (void)cropViewControllerDidDismiss:(nonnull QQImageCropViewController *)cropViewController {
    [self toolBarAminationWithHidden:NO];
}

- (void)updateEditAsset:(UIImage *)editImage cropViewController:(QQImageCropViewController *)cropViewController {
    QQAsset *currentAsset = self.assets[_currentPage];
    currentAsset.editImage = editImage;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_currentPage inSection:0]]];
    [self.currentCell resizeSubviewsSize];
}

#pragma mark - NNAssetPreviewCellDelegate
- (void)singleTapForAssetPreviewCell:(QQAssetPreviewCell *)assetPreviewCell {
    if (assetPreviewCell.asset.assetMediaType == QQAssetMediaTypeVideo) {
        [self toolBarAminationWithHidden:assetPreviewCell.isPlaying];
    } else {
        [self toolBarAminationWithHidden:!_barIsHidden];
    }
}

- (void)videoDidPlayToEndEvent {
    [self toolBarAminationWithHidden:NO];
}

#pragma mark - Present & Dismiss
- (void)performPresentAnimation {
    if (_isPresented) return;
    
    if (_currentPage >= _assets.count) _currentPage = _assets.count - 1;
    if (_currentPage < 0) _currentPage = 0;
    [self scrollToPage:_currentPage];
    
    QQAsset *asset = self.currentAsset;
    QQAssetGridCell *fromView = [self sourceGridCellForAsset:asset];
    if (!fromView) {
        self.view.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.view.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.isPresented = YES;
            [self setNeedsStatusBarAppearanceUpdate];
        }];
        return;
    }
    fromView.hidden = YES;
    asset.isHidden = YES;
    self.collectionView.hidden = YES;
    CGRect fromFrame = [fromView convertRect:fromView.bounds toView:self.view];
    UIImage *image = nil;
    if (asset.editImage) {
        image = asset.editImage;
    } else if (asset.thumbnailImage) {
        image = asset.thumbnailImage;
    }
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithImage:image];
    animatedImageView.clipsToBounds = YES;
    animatedImageView.contentMode = fromView.thumbnailImageView.contentMode;
    animatedImageView.layer.cornerRadius = fromView.thumbnailImageView.layer.cornerRadius;
    animatedImageView.frame = fromFrame;
    [self.view insertSubview:animatedImageView atIndex:0];
    
    CGRect toFrame = [QQAssetsPickerHelper scaleAspectFillImage:animatedImageView.image.size boundsSize:self.view.frame.size];
    if (asset.assetMediaType == QQAssetMediaTypeVideo) {
        toFrame = [QQAssetsPickerHelper scaleAspectFitImage:animatedImageView.image.size boundsSize:self.view.frame.size];
    }
    [UIView animateWithDuration:0.25 animations:^{
        animatedImageView.frame = toFrame;
        animatedImageView.layer.cornerRadius = 0.0;
    } completion:^(BOOL finished) {
        [animatedImageView removeFromSuperview];
        self.collectionView.hidden = NO;
        self.isPresented = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}
    
- (void)performDismissAnimation:(BOOL)animated {
    self.isDismissed = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (!animated) {
        for (QQAsset *asset in self.assets) {
            asset.isHidden = NO;
        }
        if ([self.delegate respondsToSelector:@selector(needsUpdateSourceViewHideOrShow)]) {
            [self.delegate needsUpdateSourceViewHideOrShow];
        }
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }

    self.collectionView.hidden = YES;
    self.navigationBar.hidden = YES;
    self.toolBar.hidden = YES;
    
    QQAssetPreviewCell *cell = self.currentCell;
    QQAssetGridCell *sourceView = [self sourceGridCellForAsset:cell.asset];
    UIViewContentMode sourceContentMode = sourceView.thumbnailImageView.contentMode;
    UIView *animatedView = cell.containerView;
    if ([animatedView isKindOfClass:[QQSimpleVideoPlayerView class]]) {
        // VideoPlayerView
        AVPlayerLayer *playerLayer = (AVPlayerLayer *)animatedView.layer;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (sourceContentMode == UIViewContentModeScaleAspectFit) {
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        } else if (sourceContentMode == UIViewContentModeScaleAspectFill) {
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        } else if (sourceContentMode == UIViewContentModeScaleToFill) {
            playerLayer.videoGravity = AVLayerVideoGravityResize;
        }
        [CATransaction commit];
    } else if ([animatedView isKindOfClass:[UIImageView class]]) {
        // UIImageView
        animatedView.contentMode = sourceContentMode;
    } else {
        // PHLivePhotoView 使用 UIView Animation Block 会莫名其妙跳动，这里使用截图实现
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self snapshotImageWithContainerView:animatedView]];
        animatedView = imageView;
        animatedView.contentMode = sourceContentMode;
    }
    animatedView.clipsToBounds = YES;
    animatedView.layer.masksToBounds = YES;
    CGRect fromFrame = [cell.containerView convertRect:cell.containerView.bounds toView:self.view];
    animatedView.frame = fromFrame;
    [self.view addSubview:animatedView];
    
    CGRect toFrame = [sourceView convertRect:sourceView.bounds toView:self.view];
    UIColor *backgroundColor = self.view.backgroundColor;
    [UIView animateWithDuration:0.25 animations:^{
        self.view.backgroundColor = [backgroundColor colorWithAlphaComponent:0.0];
        if (sourceView) {
            animatedView.frame = toFrame;
            animatedView.layer.cornerRadius = sourceView.thumbnailImageView.layer.cornerRadius;
        } else {
            animatedView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        for (QQAsset *asset in self.assets) {
            asset.isHidden = NO;
        }
        if ([self.delegate respondsToSelector:@selector(needsUpdateSourceViewHideOrShow)]) {
            [self.delegate needsUpdateSourceViewHideOrShow];
        }
        [animatedView removeFromSuperview];
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - PanGesture
- (void)panGestureHandler:(UIPanGestureRecognizer *)gesture {
    if (!_isPresented) return;
    QQAssetPreviewCell *cell = self.currentCell;
    if (CGSizeEqualToSize(cell.containerView.frame.size, CGSizeZero)) return;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.isDraggingPhoto = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [self toolBarAminationWithHidden:YES];
            if (cell.asset.assetMediaType == QQAssetMediaTypeVideo) {
                cell.playVideoButton.hidden = YES;
            }
            CGPoint locationPoint = [gesture locationInView:self.view];
            _gestureBeganLocation = locationPoint;
            _imageViewBeginTransform = cell.containerView.transform;
            CGPoint convertPoint = [self.view convertPoint:locationPoint toView:cell.containerView];
            CGPoint anchorPoint = CGPointMake(convertPoint.x / cell.containerView.frame.size.width, convertPoint.y / cell.containerView.frame.size.height);
            [self setAnchorPoint:anchorPoint forView:cell.containerView scale:_imageViewBeginTransform.a];
            
            // TODO: 此时应该取消 iCloud 下载，在 cancelDismissGesture 时重新下载，否则在做 Dismiss 动画时突然下载完成，会调用[cell resizeSubviewsSize]重新布局，可能会有闪动的问题。
        } break;
        case UIGestureRecognizerStateChanged: {
            if (!self.isDraggingPhoto) {
                return;
            }
            CGFloat responsMinY = CGRectGetMaxY(self.navigationBar.frame);
            CGFloat responsMaxY = CGRectGetMinY(self.toolBar.frame);
            if (_gestureBeganLocation.y <= responsMinY || _gestureBeganLocation.y >= responsMaxY) {
                return;
            }
            
            CGPoint locationPoint = [gesture locationInView:self.view];
            CGFloat deltaX = locationPoint.x - _gestureBeganLocation.x;
            CGFloat deltaY = locationPoint.y - _gestureBeganLocation.y;
            CGFloat ratio = 1.0;
            CGFloat alpha = 1.0;
            
            if (deltaY > 0) {
                // 往下拉，图片缩小，背景越来越透明
                ratio = 1.0 - deltaY / CGRectGetHeight(self.view.bounds) / 2;
                alpha = 1.0 - deltaY / CGRectGetHeight(self.view.bounds) * 1.8;
            }
            
            CGFloat scale = MAX(ratio * _imageViewBeginTransform.a, 0.3);
            CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(deltaX / scale, deltaY / scale);
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
            cell.containerView.transform = CGAffineTransformConcat(translationTransform, scaleTransform);
            self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
            
        } break;
        case UIGestureRecognizerStateEnded: {
            CGPoint locationPoint = [gesture locationInView:self.view];
            CGPoint v = [gesture velocityInView:self.view];
            CGFloat deltaY = locationPoint.y - _gestureBeganLocation.y;
            if (v.y > 1000 || deltaY > CGRectGetHeight(self.view.bounds) / 2 / 3) {
                [self performDismissAnimation:YES];
            } else {
                [self cancelDismissGesture];
            }
        } break;
        default: {
            [self cancelDismissGesture];
        } break;
    }
}

- (void)cancelDismissGesture {
    QQAssetPreviewCell *cell = self.currentCell;
    [UIView animateWithDuration:0.25 animations:^{
        cell.containerView.transform = self.imageViewBeginTransform;
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    } completion:^(BOOL finished) {
        self.isDraggingPhoto = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:cell.containerView scale:1.0];
    }];
    [self toolBarAminationWithHidden:NO];
    [self setNavigationBarHidden:YES];
    if (cell.asset.assetMediaType == QQAssetMediaTypeVideo) {
        cell.playVideoButton.hidden = cell.isPlaying;
    }
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view scale:(CGFloat)scale {
    CGPoint newAnchorPoint = CGPointMake(anchorPoint.x * scale, anchorPoint.y * scale);
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = newAnchorPoint;
    CGPoint newOrigin = view.frame.origin;
    CGPoint transition = CGPointMake(newOrigin.x - oldOrigin.x, newOrigin.y - oldOrigin.y);
    view.center = CGPointMake(view.center.x - transition.x, view.center.y - transition.y);
}

#pragma mark - Button Actions
- (void)onToolBarEditButtonClicked {
    QQAsset *asset = self.currentAsset;
    if (asset.assetMediaType == QQAssetMediaTypeStaticImage || asset.assetMediaType == QQAssetMediaTypeBurst) {

        if (asset.downloadStatus == QQAssetDownloadStatusDownloading) {
            [QQToast showWithText:@"iCloud同步中，请稍后..."];
            return;
        } else if (asset.downloadStatus == QQAssetDownloadStatusFailed) {
            [QQToast showWithText:@"iCloud同步失败"];
            return;
        }
        
        UIImage *image = nil;
        if (asset.editImage) {
            image = asset.editImage;
        } else if (asset.downloadStatus == QQAssetDownloadStatusSucceed) {
            image = self.currentCell.imageView.image;
        }
        if (image) {
            QQPickerConfiguration *configuration = [QQAssetsPicker sharedPicker].configuration;
            QQImageCropViewController *cropController = [[QQImageCropViewController alloc] initWithCroppingStyle:configuration.croppingStyle image:image];
            cropController.delegate = self;
            cropController.aspectRatioLockEnabled = configuration.aspectRatioLockEnabled;
            cropController.aspectRatioPreset = configuration.aspectRatioPreset;
            [cropController presentFromViewController:self fromView:self.currentCell angle:0 toImageFrame:CGRectZero setup:nil completion:nil];
            [self toolBarAminationWithHidden:YES];
        } else {
            [QQToast showWithText:@"iCloud同步失败"];
        }
    } else if (asset.assetMediaType == QQAssetMediaTypeVideo) {
        if (self.currentCell.asset.downloadStatus == QQAssetDownloadStatusDownloading) {
            [QQToast showWithText:@"iCloud同步中，请稍后..."];
            return;
        } else if (!self.currentCell.videoAsset || self.currentCell.asset.downloadStatus == QQAssetDownloadStatusFailed) {
            [QQToast showWithText:@"iCloud同步失败"];
            return;
        }
        QQVideoEditViewController *vc = [[QQVideoEditViewController alloc] initWithAsset:asset videoAsset:self.currentCell.videoAsset];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onToolBarOriginImageButtonClicked {
    _toolBar.originImageButton.selected = !_toolBar.originImageButton.selected;
    _selectedOriginImage = _toolBar.originImageButton.selected;
    if ([self.delegate respondsToSelector:@selector(onPreviewToolBarOriginImageButtonClicked:)]) {
        [self.delegate onPreviewToolBarOriginImageButtonClicked:_toolBar.originImageButton.selected];
    }
}

- (void)onToolBarDoneButtonClicked {
    [self performDismissAnimation:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:QQPickerDidFinishPickingAssetsNotification object:nil userInfo:@{QQPickerSelectedAssetsInfoKey:self.selectedAssets, QQPickerUsingOriginalImageKey:@(self.toolBar.originImageButton.selected)}];
}

- (void)onBackButtonClicked {
    [self performDismissAnimation:YES];
}

- (void)onCheckboxButtonClicked {
    QQAsset *asset = self.assets[self.currentPage];
    NSInteger selectionLimit = [QQAssetsPicker sharedPicker].configuration.selectionLimit;
    if (selectionLimit == 0) {
        selectionLimit = NSUIntegerMax;
    }
    if (self.selectedAssets.count >= selectionLimit && !asset.selected) {
        NSString *msg = [NSString stringWithFormat:@"你最多只能选择%ld张图片", (long)selectionLimit];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    asset.selected = !asset.selected;
    if (asset.selected) {
        if (![self.selectedAssets containsObject:asset]) {
            [self.selectedAssets addObject:asset];
        }
        [QQAssetsPickerHelper springAnimationForView:self.navigationBar.checkboxButton];
    } else {
        [self.selectedAssets removeObject:asset];
        [QQAssetsPickerHelper removeSpringAnimationForView:self.navigationBar.checkboxButton];
    }
    for (NSInteger i = 0; i < self.selectedAssets.count; i++) {
        QQAsset *selectedAsset = self.selectedAssets[i];
        selectedAsset.selectedIndex = i;
    }
    [self updateNavigationBar];
    [self updateToolBar];
    if ([self.delegate respondsToSelector:@selector(selectedAssetsDidChange:)]) {
        [self.delegate selectedAssetsDidChange:self.selectedAssets];
    }
}

- (void)onOriginalImageButtonClicked:(UIButton *)originalImageButton {
    originalImageButton.selected = !originalImageButton.selected;
}

- (void)onDoneButtonClicked {
    [[NSNotificationCenter defaultCenter] postNotificationName:QQPickerDidFinishPickingAssetsNotification object:nil userInfo:@{QQPickerSelectedAssetsInfoKey:self.selectedAssets, QQPickerUsingOriginalImageKey:@(self.toolBar.originImageButton.selected)}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helps
- (void)updateAssets:(NSMutableArray<QQAsset *> *)assets selectedAssets:(NSMutableArray *)selectedAssets currentPage:(NSInteger)currentPage {
    _assets = assets;
    _selectedAssets = selectedAssets;
    _currentPage = currentPage;
    _previousPage = currentPage;
}

- (void)updateNavigationBar {
    QQAsset *asset = self.currentAsset;
    if (asset.selected) {
        self.navigationBar.checkboxButton.indexLabel.hidden = NO;
        self.navigationBar.checkboxButton.indexLabel.text = [NSString stringWithFormat:@"%ld", (long)(asset.selectedIndex + 1)];
    } else {
        self.navigationBar.checkboxButton.indexLabel.hidden = YES;
        self.navigationBar.checkboxButton.indexLabel.text = @"";
    }
}

- (void)updateToolBar {
    BOOL allowsImageEditing = [QQAssetsPicker sharedPicker].configuration.allowsImageEditing;
    BOOL allowsVideoEditing = [QQAssetsPicker sharedPicker].configuration.allowsVideoEditing;
    QQAssetMediaType currentMediaType = self.currentAsset.assetMediaType;
    BOOL editEnabled = NO;
    if (allowsImageEditing && allowsVideoEditing) {
        if (currentMediaType == QQAssetMediaTypeStaticImage || currentMediaType == QQAssetMediaTypeBurst || currentMediaType == QQAssetMediaTypeVideo) {
            editEnabled = YES;
        }
    } else if (allowsImageEditing && !allowsVideoEditing) {
        if (currentMediaType == QQAssetMediaTypeStaticImage || currentMediaType == QQAssetMediaTypeBurst) {
            editEnabled = YES;
        }
    } else if (!allowsImageEditing && allowsVideoEditing) {
        if (currentMediaType == QQAssetMediaTypeVideo) {
            editEnabled = YES;
        }
    }
    self.toolBar.leftButton.enabled = editEnabled;
    self.toolBar.originImageButton.selected = self.selectedOriginImage;
    self.toolBar.doneButton.enabled = (self.selectedAssets.count > 0);
}

- (void)toolBarAminationWithHidden:(BOOL)hidden {
    CGFloat alpha = hidden ? 0 : 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.navigationBar.alpha = alpha;
        self.toolBar.alpha = alpha;
    } completion:^(BOOL finished) {
        
    }];
    _barIsHidden = hidden;
}

- (void)setNavigationBarHidden:(BOOL)hidden {
    [self.navigationController setNavigationBarHidden:hidden animated:NO];
}

- (QQAssetPreviewCell *)currentCell {
    QQAssetPreviewCell *cell = (QQAssetPreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    return cell;
}

- (QQAsset *)currentAsset {
    return self.assets[self.currentPage];
}

- (QQAssetGridCell *)sourceGridCellForAsset:(QQAsset *)asset {
    if (asset && self.sourceView) {
        return (QQAssetGridCell *)self.sourceView(asset);
    }
    return nil;
}

- (void)scrollToPage:(NSInteger)page {
    if (page < self.assets.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:page inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (UIImage *)snapshotImageWithContainerView:(UIView *)containerView {
    UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, NO, [UIScreen mainScreen].scale);
    [containerView drawViewHierarchyInRect:containerView.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

#pragma mark - Status Bar
- (BOOL)prefersStatusBarHidden {
    if (_isDraggingPhoto || _isDismissed || !_isPresented) {
        return NO;
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - Screen Rotate
- (BOOL)shouldAutorotate {
    if (_isDraggingPhoto) {
        return NO;
    }
    return YES;
}

@end
