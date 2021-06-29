//
//  QQAssetPickerController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQAssetPickerController.h"
#import "QQAssetGridViewController.h"
#import "QQToast.h"

@interface QQAssetPickerController ()

@end

@implementation QQAssetPickerController

- (instancetype)init {
    return [self initWithConfiguration:nil];
}

- (instancetype)initWithConfiguration:(QQPickerConfiguration *)configuration {
    return [self initWithConfiguration:configuration selectedAssets:nil];
}

- (instancetype)initWithConfiguration:(QQPickerConfiguration *)configuration selectedAssets:(NSArray<QQAsset *> *)selectedAssets {
    QQAssetGridViewController *gridVC = [[QQAssetGridViewController alloc] init];
    if (selectedAssets) {
        gridVC.defaultSelectedAssets = selectedAssets;
    }
    if (self = [super initWithRootViewController:gridVC]) {
        _configuration = configuration;
        if (configuration) {
            [QQAssetsPicker sharedPicker].configuration = configuration;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerDidFinishPickingAssetsNotification:) name:QQPickerDidFinishPickingAssetsNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerDidCancelPickingAssetsNotification:) name:QQPickerDidCancelPickingAssetsNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)pickerDidFinishPickingAssetsNotification:(NSNotification *)notification {
    NSArray *selectedAssets = notification.userInfo[QQPickerSelectedAssetsInfoKey];
    BOOL usingOriginalImage = [notification.userInfo[QQPickerUsingOriginalImageKey] boolValue];
    
    [QQToast showLoading:@"处理中..."];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block NSInteger downloadSuccessCount = 0;
    for (QQAsset *asset in selectedAssets) {
        dispatch_group_async(group, queue, ^{
            if (asset.assetMediaType == QQAssetMediaTypeVideo) {
                [[QQAssetsPicker sharedPicker] requestAVAssetWithAsset:asset progressHandler:^(QQAsset *asset, double downloadProgress) {
                    [self showProgressToast:selectedAssets];
                } completion:^(QQAsset *asset, AVAsset *avAsset) {
                    if (asset.downloadStatus == QQAssetDownloadStatusSucceed) {
                        asset.avAsset = avAsset;
                        downloadSuccessCount++;
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
            } else if (asset.assetMediaType != QQAssetMediaTypeAudio) {
                BOOL isLivePhoto = NO;
                if (@available(iOS 9.1, *)) {
                    if (asset.assetMediaType == QQAssetMediaTypeLivePhoto) {
                        isLivePhoto = YES;
                    }
                }
                if (isLivePhoto) {
                    if (@available(iOS 9.1, *)) {
                        [[QQAssetsPicker sharedPicker] requestLivePhotoWithAsset:asset progressHandler:^(QQAsset *asset, double downloadProgress) {
                            [self showProgressToast:selectedAssets];
                        } completion:^(QQAsset *asset, PHLivePhoto *livePhoto) {
                            if (asset.downloadStatus == QQAssetDownloadStatusSucceed) {
                                asset.livePhoto = livePhoto;
                                downloadSuccessCount++;
                            }
                            dispatch_semaphore_signal(semaphore);
                        }];
                    }
                } else if (asset.assetMediaType == QQAssetMediaTypeGIF) {
                    [[QQAssetsPicker sharedPicker] requestOriginImageWithAsset:asset progressHandler:^(QQAsset *asset, double downloadProgress) {
                        [self showProgressToast:selectedAssets];
                    } completion:^(QQAsset *asset, UIImage *result) {
                        if (asset.downloadStatus == QQAssetDownloadStatusSucceed) {
                            asset.GIFImage = result;
                            downloadSuccessCount++;
                        }
                        dispatch_semaphore_signal(semaphore);
                    }];
                } else {
                    if (usingOriginalImage) {
                        [[QQAssetsPicker sharedPicker] requestOriginImageWithAsset:asset progressHandler:^(QQAsset *asset, double downloadProgress) {
                            [self showProgressToast:selectedAssets];
                        } completion:^(QQAsset *asset, UIImage *result) {
                            if (asset.downloadStatus == QQAssetDownloadStatusSucceed) {
                                asset.originalImage = result;
                                downloadSuccessCount++;
                            }
                            dispatch_semaphore_signal(semaphore);
                        }];
                    } else {
                        [[QQAssetsPicker sharedPicker] requestPreviewImageWithAsset:asset synchronous:YES progressHandler:^(QQAsset *asset, double downloadProgress) {
                            [self showProgressToast:selectedAssets];
                        } completion:^(QQAsset *asset, UIImage *result) {
                            if (asset.downloadStatus == QQAssetDownloadStatusSucceed) {
                                asset.previewImage = result;
                                downloadSuccessCount++;
                            }
                            dispatch_semaphore_signal(semaphore);
                        }];
                    }
                }
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (downloadSuccessCount < selectedAssets.count) {
            [QQToast showError:@"iCloud同步失败"];
            return;
        }
        [QQToast hideToast];
        if ([self.pickerDelegate respondsToSelector:@selector(picker:didFinishPicking:usingOriginalImage:)]) {
            [self.pickerDelegate picker:self didFinishPicking:[selectedAssets copy] usingOriginalImage:usingOriginalImage];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)pickerDidCancelPickingAssetsNotification:(NSNotification *)notification {
    if ([self.pickerDelegate respondsToSelector:@selector(pickerDidCancel:)]) {
        [self.pickerDelegate pickerDidCancel:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showProgressToast:(NSArray *)selectedAssets {
    CGFloat dowlondProgress = 0.0;
    for (QQAsset *downloadAsset in selectedAssets) {
        dowlondProgress += downloadAsset.downloadProgress;
    }
    dowlondProgress = dowlondProgress / selectedAssets.count;
    [QQToast showProgress:dowlondProgress text:@"处理中..."];
}

#pragma mark - 状态栏
- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.topViewController) {
        return self.topViewController;
    }
    return [super childViewControllerForStatusBarHidden];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.topViewController) {
        return self.topViewController;
    }
    return [super childViewControllerForStatusBarStyle];
}

#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate {
    if (self.topViewController) {
        return [self.topViewController shouldAutorotate];
    }
    return [super shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    return [super supportedInterfaceOrientations];
}

#pragma mark - HomeIndicator
- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    if (self.topViewController) {
        return [self.topViewController childViewControllerForHomeIndicatorAutoHidden];
    }
    return [super childViewControllerForHomeIndicatorAutoHidden];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
