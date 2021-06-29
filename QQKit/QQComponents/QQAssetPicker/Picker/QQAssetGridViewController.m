//
//  QQAssetGridViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQAssetGridViewController.h"
#import "QQAssetsPicker.h"
#import "QQAssetGridCell.h"
#import "QQNavigationBarAlbumTitleView.h"
#import "QQPermissionPromptView.h"
#import "QQSelectAssetToolBar.h"
#import "UIView+QQExtension.h"
#import "UIScrollView+QQExtension.h"
#import "QQAlbumsListView.h"
#import "QQAssetsPickerHelper.h"
#import "QQAssetPreviewViewController.h"
#import "QQImageCropViewController.h"
#import "QQVideoEditViewController.h"
#import "QQToast.h"

static NSString * const kQQAssetGridCellReuseID = @"QQAssetGridCell";
@interface QQAssetGridViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, QQAssetGridCellDelegate, QQAlbumsListViewDelegate, QQAssetPreviewViewControllerDelegate, QQImageCropViewControllerDelegate>

@property (nonatomic, strong) QQNavigationBarAlbumTitleView *titleView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) QQSelectAssetToolBar *toolBar;
@property (nonatomic, strong) QQPermissionPromptView *promptView;
@property (nonatomic, strong) QQAlbumsListView *albumsListView;

@property (nonatomic, strong) NSMutableArray<QQAsset *> *selectedAssets;
@property (nonatomic, strong) NSArray<QQAssetsGroup *> *albums;
@property (nonatomic, strong) QQAssetsGroup *currentAlbum;
@property (nonatomic, assign) BOOL alreadyScrollToBottom;
@property (nonatomic, assign) BOOL isAssetsLoaded;

@property (nonatomic, strong) QQAsset *toEditAsset;

@end

@implementation QQAssetGridViewController

- (NSMutableArray<QQAsset *> *)selectedAssets {
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    return _selectedAssets;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat spacing = 1 / [UIScreen mainScreen].scale * 2;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
        layout.minimumLineSpacing = spacing;
        layout.minimumInteritemSpacing = spacing;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = self.view.backgroundColor;
        [_collectionView registerClass:[QQAssetGridCell class] forCellWithReuseIdentifier:kQQAssetGridCellReuseID];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _collectionView;
}

- (QQSelectAssetToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[QQSelectAssetToolBar alloc] initWithToolBarType:ToolBarTypePreview];
        [_toolBar.leftButton addTarget:self action:@selector(onToolBarPreviewButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.originImageButton addTarget:self action:@selector(onToolBarOriginImageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.doneButton addTarget:self action:@selector(onToolBarDoneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolBar;
}

- (instancetype)init {
    if (self = [super init]) {
        self.alreadyScrollToBottom = NO;
        self.isAssetsLoaded = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self initSubviews];
    
    [QQAssetsPicker requestAuthorization:^(QQAuthorizationStatus status) {
        if (@available(iOS 14, *)) {
            if (status == QQAuthorizationStatusLimited) {
                [self showPromptView:status];
                [self loadAssetsData];
            } else if (status == QQAuthorizationStatusAuthorized) {
                [self loadAssetsData];
            } else {
                [self showPromptView:status];
            }
        } else {
            if (status == QQAuthorizationStatusAuthorized) {
                [self loadAssetsData];
            } else {
                [self showPromptView:status];
            }
        }
    }];
}

- (void)setupNavigationBar {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(onCancelItemClicked)];
    _titleView = [[QQNavigationBarAlbumTitleView alloc] initWithFrame:CGRectMake(0, 0, 210, 44)];
    [_titleView.actionButton addTarget:self action:@selector(onAlbumButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _titleView;
}

- (void)initSubviews {
    self.view.backgroundColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
    [self.view addSubview:self.collectionView];
    
    if ([QQAssetsPicker sharedPicker].configuration.allowsMultipleSelection) {
        [self.view addSubview:self.toolBar];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _collectionView.frame = self.view.bounds;
    
    CGFloat toolBarHeight = 0;
    if ([QQAssetsPicker sharedPicker].configuration.allowsMultipleSelection) {
        toolBarHeight = 50.0 + self.view.qq_safeAreaInsets.bottom;
        self.toolBar.frame = CGRectMake(0, self.view.qq_height - toolBarHeight, self.view.qq_width, toolBarHeight);
    }
    
    CGFloat navigationBarMaxY = self.navigationController.navigationBar.qq_bottom;
    UIEdgeInsets contentInset = UIEdgeInsetsMake(navigationBarMaxY, 0, MAX(toolBarHeight, self.view.qq_safeAreaInsets.bottom), 0);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, contentInset)) {
        self.collectionView.contentInset = contentInset;
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(contentInset.top, 0, contentInset.bottom, 0);
    }
    
    if (_albumsListView.superview) {
        _albumsListView.frame = CGRectMake(0, navigationBarMaxY, self.view.frame.size.width, self.view.frame.size.height - navigationBarMaxY);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentAlbum.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QQAssetGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQQAssetGridCellReuseID forIndexPath:indexPath];
    cell.delegate = self;
    QQAsset *asset = self.currentAlbum.assets[indexPath.item];
    BOOL isMaxLimit = (self.selectedAssets.count >= self.selectionLimit);
    [cell renderWithAsset:asset referenceSize:[self referenceImageSize] isMaxLimit:isMaxLimit];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self referenceImageSize];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QQAsset *asset = self.currentAlbum.assets[indexPath.item];
    QQPickerConfiguration *configuration = [QQAssetsPicker sharedPicker].configuration;
    if (configuration.allowsMultipleSelection) {
        if (self.selectedAssets.count >= self.selectionLimit && !asset.selected) {
            return;
        }
        [self presentToPreviewFromIndex:indexPath.item assets:self.currentAlbum.assets];
    } else {
        if (configuration.allowsImageEditing && (asset.assetMediaType == QQAssetMediaTypeStaticImage || asset.assetMediaType == QQAssetMediaTypeBurst)) {
            // 允许编辑
            self.toEditAsset = asset;
            if (asset.editImage) {
                [self pushToImageCropWithImage:asset.editImage];
            } else {
                [QQToast showLoading:@"加载中"];
                [[QQAssetsPicker sharedPicker] requestPreviewImageWithAsset:asset synchronous:YES progressHandler:^(QQAsset *asset, double downloadProgress) {
                                    
                } completion:^(QQAsset *asset, UIImage *result) {
                    if (asset.downloadStatus == QQAssetDownloadStatusSucceed) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [QQToast hideToast];
                            [self pushToImageCropWithImage:result];
                        });
                    } else {
                        [QQToast showError:@"iCloud同步失败"];
                    }
                }];
            }
        } else if (configuration.allowsVideoEditing && asset.assetMediaType == QQAssetMediaTypeVideo) {
            [QQToast showLoading:@"加载中"];
            [[QQAssetsPicker sharedPicker] requestAVAssetWithAsset:asset progressHandler:^(QQAsset *asset, double downloadProgress) {
                            
            } completion:^(QQAsset *asset, AVAsset *avAsset) {
                if (asset.downloadStatus == QQAssetDownloadStatusSucceed) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [QQToast hideToast];
                        [self pushToVideoEditWithAsset:asset videoAsset:avAsset];
                    });
                } else {
                    [QQToast showError:@"iCloud同步失败"];
                }
            }];
        } else {
            [self.selectedAssets addObject:asset];
            [[NSNotificationCenter defaultCenter] postNotificationName:QQPickerDidFinishPickingAssetsNotification object:nil userInfo:@{QQPickerSelectedAssetsInfoKey:self.selectedAssets, QQPickerUsingOriginalImageKey:@(self.toolBar.originImageButton.selected)}];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


#pragma mark - QQImageCropViewControllerDelegate
- (void)cropViewController:(nonnull QQImageCropViewController *)cropViewController
            didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle {
    [self updateEditAsset:image];
}

- (void)cropViewController:(nonnull QQImageCropViewController *)cropViewController
    didCropToCircularImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle {
    [self updateEditAsset:image];
}

- (void)updateEditAsset:(UIImage *)editImage {
    self.toEditAsset.editImage = editImage;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.currentAlbum.assets indexOfObject:self.toEditAsset] inSection:0]]];
    [self.selectedAssets addObject:self.toEditAsset];
    [self.navigationController popViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:QQPickerDidFinishPickingAssetsNotification object:nil userInfo:@{QQPickerSelectedAssetsInfoKey:self.selectedAssets, QQPickerUsingOriginalImageKey:@(self.toolBar.originImageButton.selected)}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - QQAlbumsListViewDelegate
- (void)albumsListView:(QQAlbumsListView *)albumsListView didSelectAlbum:(QQAssetsGroup *)album {
    self.currentAlbum = album;
    [self.titleView updateAlbumName:album.name animated:YES];
    [self.collectionView reloadData];
}

- (void)albumsListViewDidShow:(QQAlbumsListView *)albumsListView {
    [self.titleView rotateArrowIcon];
}

- (void)albumsListViewDidDismiss:(QQAlbumsListView *)albumsListView {
    [self.titleView rotateArrowIcon];
}

#pragma mark - QQAssetGridCellDelegate
- (void)onCheckboxButtonClicked:(QQAsset *)asset {
    NSInteger selectionLimit = self.selectionLimit;
    if (self.selectedAssets.count >= selectionLimit && !asset.selected) {
        NSString *msg = [NSString stringWithFormat:@"你最多只能选择%ld张照片", selectionLimit];
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
            [self requestOriginalAsset:asset];
        }
    } else {
        [self.selectedAssets removeObject:asset];
    }
    for (NSInteger i = 0; i < self.selectedAssets.count; i++) {
        QQAsset *selectedAsset = self.selectedAssets[i];
        selectedAsset.selectedIndex = i;
    }
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    [self updateToolBar];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        QQAssetGridCell *currentCell = (QQAssetGridCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self.currentAlbum.assets indexOfObject:asset] inSection:0]];
        if (currentCell.asset.selected) {
            [currentCell startSpringAnimation];
        } else {
            [currentCell removeSpringAnimation];
        }
    });
}

#pragma mark - QQAssetPreviewViewControllerDelegate
- (void)selectedAssetsDidChange:(NSMutableArray *)selectedAssets {
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded]; //强制刷新
    [self updateToolBar];
}

- (void)needsUpdateSourceViewHideOrShow {
    // TODO: 这里可以只刷新当前Asset和上一个Asset，不用刷新全部
    [self.collectionView reloadData];
}

- (void)onPreviewToolBarOriginImageButtonClicked:(BOOL)selectedOriginImage {
    _toolBar.originImageButton.selected = selectedOriginImage;
}

#pragma mark - Load Data
- (void)loadAssetsData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QQAssetsPicker sharedPicker] fetchAssetsGroupsWithCompletion:^(NSArray<QQAssetsGroup *> *albums) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isAssetsLoaded = YES;
                self.albums = [albums copy];
                self.currentAlbum = self.albums.firstObject;
                
                // 默认选中
                if (self.defaultSelectedAssets.count > 0) {
                    for (QQAsset *selectedAsset in self.defaultSelectedAssets) {
                        for (QQAsset *asset in self.currentAlbum.assets) {
                            if ([asset.identifier isEqualToString:selectedAsset.identifier]) {
                                asset.selected = YES;
                                [self.selectedAssets addObject:asset];
                                break;
                            }
                        }
                    }
                    for (NSInteger i = 0; i < self.selectedAssets.count; i++) {
                        QQAsset *selectedAsset = self.selectedAssets[i];
                        selectedAsset.selectedIndex = i;
                    }
                    [self updateToolBar];
                }
                
                // refresh data
                [self.titleView updateAlbumName:self.currentAlbum.name animated:NO];
                [self.collectionView reloadData];
                [self.collectionView performBatchUpdates:^{
                                        
                } completion:^(BOOL finished) {
                    [self scrollToBottom];
                }];
            });
        }];
    });
}

- (void)requestOriginalAsset:(QQAsset *)asset {
    if (asset.assetMediaType == QQAssetMediaTypeVideo) {
        [[QQAssetsPicker sharedPicker] requestPlayerItemWithAsset:asset progressHandler:nil completion:nil];
    } else if (asset.assetMediaType != QQAssetMediaTypeAudio) {
        if (@available(iOS 9.1, *)) {
            if (asset.assetMediaType == QQAssetMediaTypeLivePhoto) {
                [[QQAssetsPicker sharedPicker] requestLivePhotoWithAsset:asset progressHandler:nil completion:nil];
            } else {
                [[QQAssetsPicker sharedPicker] requestOriginImageWithAsset:asset progressHandler:nil completion:nil];
            }
        } else {
            [[QQAssetsPicker sharedPicker] requestOriginImageWithAsset:asset progressHandler:nil completion:nil];
        }
    }
}

#pragma mark - Button Actions
- (void)onToolBarPreviewButtonClicked {
    [self presentToPreviewFromIndex:0 assets:[self.selectedAssets mutableCopy]];
}

- (void)onToolBarOriginImageButtonClicked {
    _toolBar.originImageButton.selected = !_toolBar.originImageButton.selected;
}

- (void)onToolBarDoneButtonClicked {
    [[NSNotificationCenter defaultCenter] postNotificationName:QQPickerDidFinishPickingAssetsNotification object:nil userInfo:@{QQPickerSelectedAssetsInfoKey:self.selectedAssets, QQPickerUsingOriginalImageKey:@(self.toolBar.originImageButton.selected)}];
}

- (void)onCancelItemClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onAlbumButtonClicked {
    QQAuthorizationStatus status = [QQAssetsPicker authorizationStatus];
    if (@available(iOS 14, *)) {
        if (status != QQAuthorizationStatusLimited && status != QQAuthorizationStatusAuthorized) {
            return;
        }
    } else {
        if (status != QQAuthorizationStatusAuthorized) {
            return;
        }
    }
    if (self.albums.count == 0) {
        return;
    }
    if (_albumsListView.isShow) {
        [_albumsListView dismiss];
    } else {
        CGFloat navigationBarMaxY = self.navigationController.navigationBar.qq_bottom;
        _albumsListView = [[QQAlbumsListView alloc] initWithFrame:CGRectMake(0, navigationBarMaxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - navigationBarMaxY) albums:self.albums];
        _albumsListView.delegate = self;
        [_albumsListView showInView:self.view];
    }
}

- (void)onPromptViewCloseButtonClicekd {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onPromptViewSettingButtonClicekd {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)onPromptViewLimitedButtonClicekd {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.promptView removeFromSuperview];
}

#pragma mark - Helps
- (void)presentToPreviewFromIndex:(NSInteger)index assets:(NSMutableArray *)assets {
    QQAssetPreviewViewController *vc = [[QQAssetPreviewViewController alloc] init];
    vc.delegate = self;
    vc.selectedOriginImage = self.toolBar.originImageButton.selected;
    [vc updateAssets:assets selectedAssets:self.selectedAssets currentPage:index];
    vc.sourceView = ^UIView *(QQAsset *asset) {
        NSInteger index = [self.currentAlbum.assets indexOfObject:asset];
        QQAssetGridCell *cell = (QQAssetGridCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        return cell;
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationCustom;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nav.view.backgroundColor = [UIColor clearColor];
    [self presentViewController:nav animated:NO completion:nil];
}

- (void)pushToImageCropWithImage:(UIImage *)image {
    QQPickerConfiguration *configuration = [QQAssetsPicker sharedPicker].configuration;
    QQImageCropViewController *cropController = [[QQImageCropViewController alloc] initWithCroppingStyle:configuration.croppingStyle image:image];
    cropController.delegate = self;
    cropController.aspectRatioLockEnabled = configuration.aspectRatioLockEnabled;
    cropController.aspectRatioPreset = configuration.aspectRatioPreset;
    [self.navigationController pushViewController:cropController animated:YES];
}

- (void)pushToVideoEditWithAsset:(QQAsset *)asset videoAsset:(AVAsset *)videoAsset {
    QQVideoEditViewController *vc = [[QQVideoEditViewController alloc] initWithAsset:asset videoAsset:videoAsset];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)selectionLimit {
    NSInteger selectionLimit = [QQAssetsPicker sharedPicker].configuration.selectionLimit;
    if (selectionLimit == 0) {
        selectionLimit = NSUIntegerMax;
    }
    return selectionLimit;
}

- (CGSize)referenceImageSize {
    NSInteger columnCount = 4;
    if (CGRectGetWidth(self.view.frame) > CGRectGetHeight(self.view.frame)) {
        columnCount = 5;
    }
    CGFloat spacing = 1 / [UIScreen mainScreen].scale * 2;
    CGFloat itemWidth = floor((self.view.frame.size.width - spacing * (columnCount + 1)) / columnCount);
    return CGSizeMake(itemWidth, itemWidth);
}

- (void)scrollToBottom {
    [self.collectionView qq_scrollToBottom];
}

- (void)showPromptView:(QQAuthorizationStatus)status {
    if (!_promptView) {
        _promptView = [[QQPermissionPromptView alloc] initWithFrame:self.view.bounds];
        [_promptView.closeButton addTarget:self action:@selector(onPromptViewCloseButtonClicekd) forControlEvents:UIControlEventTouchUpInside];
        [_promptView.toSettingButton addTarget:self action:@selector(onPromptViewSettingButtonClicekd) forControlEvents:UIControlEventTouchUpInside];
        [_promptView.limitedButton addTarget:self action:@selector(onPromptViewLimitedButtonClicekd) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_promptView];
    }
    _promptView.authorizationStatus = status;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)updateToolBar {
    NSInteger selectedCount = self.selectedAssets.count;
    BOOL enabled = (selectedCount > 0);
    _toolBar.leftButton.enabled = enabled;
    _toolBar.doneButton.enabled = enabled;
    _toolBar.countLabel.hidden = !enabled;
    _toolBar.countLabel.text = [NSString stringWithFormat:@"%ld", selectedCount];
    if (enabled) {
        [QQAssetsPickerHelper springAnimationForView:_toolBar.countLabel];
    } else {
        [QQAssetsPickerHelper removeSpringAnimationForView:_toolBar.countLabel];
    }
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *vc = self.presentedViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController prefersStatusBarHidden];
    }
    return [super prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
