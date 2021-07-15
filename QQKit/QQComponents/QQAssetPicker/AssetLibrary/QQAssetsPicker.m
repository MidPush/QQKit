//
//  QQAssetsPicker.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQAssetsPicker.h"
#import "UIImage+QQExtension.h"

NSNotificationName const QQPickerDidFinishPickingAssetsNotification = @"QQPickerDidFinishPickingAssetsNotification";
NSNotificationName const QQPickerDidCancelPickingAssetsNotification = @"QQPickerDidCancelPickingAssetsNotification";
NSString *const QQPickerSelectedAssetsInfoKey = @"QQPickerSelectedAssetsInfoKey";
NSString *const QQPickerUsingOriginalImageKey = @"QQPickerUsingOriginalImageKey";

@implementation QQPickerConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.selectionLimit = 9;
        self.filterType = QQPickerFilterTypeAll;
        self.allowsMultipleSelection = YES;
        self.allowsImageEditing = NO;
        self.allowsVideoEditing = NO;
        self.allowsSelectionLivePhoto = NO;
        self.allowsSelectionGIF = NO;
        
        self.aspectRatioLockEnabled = NO;
        self.croppingStyle = QQImageCropStyleDefault;
        self.aspectRatioPreset = QQCropViewControllerAspectRatioPresetOriginal;
        
        NSBundle *bundle = [NSBundle bundleForClass:[QQAssetsPicker class]];
        NSURL *url = [bundle URLForResource:@"QQUIKit" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        
        self.assetPickerBurstImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerBurst" ofType:@"png"]];
        self.assetPickerCheckMarkNormalImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerCheckMarkNormal" ofType:@"png"]];
        self.assetPickerCheckMarkSelectedImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerCheckMarkSelected" ofType:@"png"]];
        self.assetPickerGIFImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerGIF" ofType:@"png"]];
        self.assetPickerICloudImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerICloud" ofType:@"png"]];
        self.assetPickerNavArrowImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerNavArrow" ofType:@"png"]];
        self.assetPickerNavBackImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerNavBack" ofType:@"png"]];
        self.assetPickerNavCheckImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerNavCheck" ofType:@"png"]];
        self.assetPickerPlayImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerPlay" ofType:@"png"]];
        self.assetPickerRotateImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerRotate" ofType:@"png"]];
        self.assetPickerVideoImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"ImagePickerVideo" ofType:@"png"]];
    }
    return self;
}

@end

@implementation QQAssetsPicker {
    PHCachingImageManager *_cachingImageManager;
}

- (PHCachingImageManager *)cachingImageManager {
    if (!_cachingImageManager) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

+ (instancetype)sharedPicker {
    static QQAssetsPicker *picker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        picker = [[QQAssetsPicker alloc] init];
    });
    return picker;
}

- (instancetype)init {
    if (self = [super init]) {
        _configuration = [[QQPickerConfiguration alloc] init];
    }
    return self;
}

+ (QQAuthorizationStatus)authorizationStatus {
    QQAuthorizationStatus qqStatus = -1;
    PHAuthorizationStatus status = -1;
    if (@available(iOS 14, *)) {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        if (status == PHAuthorizationStatusNotDetermined) {
            qqStatus = QQAuthorizationStatusNotDetermined;
        } else if (status == PHAuthorizationStatusRestricted) {
            qqStatus = QQAuthorizationStatusRestricted;
        } else if (status == PHAuthorizationStatusDenied) {
            qqStatus = QQAuthorizationStatusDenied;
        } else if (status == PHAuthorizationStatusAuthorized) {
            qqStatus = QQAuthorizationStatusAuthorized;
        } else if (status == PHAuthorizationStatusLimited) {
            qqStatus = QQAuthorizationStatusLimited;
        }
    } else {
        status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            qqStatus = QQAuthorizationStatusNotDetermined;
        } else if (status == PHAuthorizationStatusRestricted) {
            qqStatus = QQAuthorizationStatusRestricted;
        } else if (status == PHAuthorizationStatusDenied) {
            qqStatus = QQAuthorizationStatusDenied;
        } else if (status == PHAuthorizationStatusAuthorized) {
            qqStatus = QQAuthorizationStatusAuthorized;
        }
    }
    return qqStatus;
}

+ (void)requestAuthorization:(void (^)(QQAuthorizationStatus))handler {
    if (@available(iOS 14, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
            QQAuthorizationStatus qqStatus = -1;
            if (status == PHAuthorizationStatusNotDetermined) {
                qqStatus = QQAuthorizationStatusNotDetermined;
            } else if (status == PHAuthorizationStatusRestricted) {
                qqStatus = QQAuthorizationStatusRestricted;
            } else if (status == PHAuthorizationStatusDenied) {
                qqStatus = QQAuthorizationStatusDenied;
            } else if (status == PHAuthorizationStatusAuthorized) {
                qqStatus = QQAuthorizationStatusAuthorized;
            } else if (status == PHAuthorizationStatusLimited) {
                qqStatus = QQAuthorizationStatusLimited;
            }
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(qqStatus);
                });
            }
        }];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            QQAuthorizationStatus qqStatus = -1;
            if (status == PHAuthorizationStatusNotDetermined) {
                qqStatus = QQAuthorizationStatusNotDetermined;
            } else if (status == PHAuthorizationStatusRestricted) {
                qqStatus = QQAuthorizationStatusRestricted;
            } else if (status == PHAuthorizationStatusDenied) {
                qqStatus = QQAuthorizationStatusDenied;
            } else if (status == PHAuthorizationStatusAuthorized) {
                qqStatus = QQAuthorizationStatusAuthorized;
            }
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(qqStatus);
                });
            }
        }];
    }
}

- (void)fetchAssetsGroupsWithCompletion:(void (^)(NSArray<QQAssetsGroup *> *albums))completion {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
//    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    if (self.configuration.filterType == QQPickerFilterTypeImage) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    } else if (self.configuration.filterType == QQPickerFilterTypeVideo) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeVideo];
    } else if (self.configuration.filterType == QQPickerFilterTypeAudio) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeAudio];
    }
    
    NSMutableArray<QQAssetsGroup *> *tempAlbumsArray = [NSMutableArray array];
    QQAssetsGroup *allAssetsGroup = nil;
    
    // 获取系统的“智能相册”
    PHFetchResult *smartAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    for (PHCollection *collection in smartAlbumsResult) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
            if (assetsResult.count) {
                QQAssetsGroup *group = [[QQAssetsGroup alloc] initWithCollection:assetCollection fetchResult:assetsResult];
                [tempAlbumsArray addObject:group];
                if (allAssetsGroup.result.count < group.result.count) {
                    allAssetsGroup = group;
                }
            }
        }
    }
    
    // 获取所有用户自己建立的相册
    PHFetchResult *userAlbumsResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    for (PHCollection *collection in userAlbumsResult) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
            if (assetsResult.count) {
                QQAssetsGroup *group = [[QQAssetsGroup alloc] initWithCollection:assetCollection fetchResult:assetsResult];
                [tempAlbumsArray addObject:group];
                if (allAssetsGroup.result.count < group.result.count) {
                    allAssetsGroup = group;
                }
            }
        }
    }
    
    if (allAssetsGroup) {
        [tempAlbumsArray removeObject:allAssetsGroup];
    }
    
    NSMutableArray *allAssetArray = [NSMutableArray arrayWithCapacity:allAssetsGroup.result.count];
    for (PHAsset *phAsset in allAssetsGroup.result) {
        QQAsset *asset = [[QQAsset alloc] initWithPHAsset:phAsset];
        [allAssetArray addObject:asset];
    }
    allAssetsGroup.assets = allAssetArray;
    
    for (QQAssetsGroup *group in tempAlbumsArray) {
        NSMutableArray *assetArray = [NSMutableArray arrayWithCapacity:group.result.count];
        for (PHAsset *phAsset in group.result) {
            if ([allAssetsGroup.result containsObject:phAsset]) {
                NSInteger index = [allAssetsGroup.result indexOfObject:phAsset];
                [assetArray addObject:allAssetArray[index]];
            } else {
                QQAsset *asset = [[QQAsset alloc] initWithPHAsset:phAsset];
                [assetArray addObject:asset];
            }
        }
        group.assets = assetArray;
    }
    if (allAssetsGroup) {
        [tempAlbumsArray insertObject:allAssetsGroup atIndex:0];
    }
    
    if (completion) {
        completion([tempAlbumsArray copy]);
    }
}


- (PHImageRequestID)requestThumbnailImageWithAlbum:(QQAssetsGroup *)group
                                              size:(CGSize)size
                                        completion:(void (^)(QQAssetsGroup *group, UIImage *result))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    QQAsset *asset = group.assets.lastObject;
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset.phAsset targetSize:CGSizeMake(size.width * [UIScreen mainScreen].scale, size.height * [UIScreen mainScreen].scale) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            group.thumbnailImage = result;
            if (completion) {
                completion(group, result);
            }
        });
    }];
    return requestID;
}

- (PHImageRequestID)requestThumbnailImageWithAsset:(QQAsset *)asset
                                              size:(CGSize)size
                                        completion:(void (^)(QQAsset *asset, UIImage *result))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    PHImageRequestID requestID = [self.cachingImageManager requestImageForAsset:asset.phAsset targetSize:CGSizeMake(size.width * [UIScreen mainScreen].scale, size.height * [UIScreen mainScreen].scale) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                asset.thumbnailImage = result;
            }
            if (completion) {
                completion(asset, result);
            }
        });
    }];
    return requestID;
}

- (PHImageRequestID)requestPreviewImageWithAsset:(QQAsset *)asset
                                     synchronous:(BOOL)synchronous
                                 progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                      completion:(void (^)(QQAsset *asset, UIImage *result))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.synchronous = synchronous;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        asset.downloadProgress = progress;
        if (progressHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressHandler(asset, progress);
            });
        }
    };
    
    PHImageRequestID requestID = [self.cachingImageManager requestImageForAsset:asset.phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            if (downloadSucceed) {
                [asset updateDownloadStatus:YES];
            } else if ([info objectForKey:PHImageErrorKey]) {
                [asset updateDownloadStatus:NO];
            }
            if (completion) {
                completion(asset, result);
            }
        });
    }];
    return requestID;
}

- (PHImageRequestID)requestOriginImageWithAsset:(QQAsset *)asset
                                progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                     completion:(void (^)(QQAsset *asset, UIImage *result))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        asset.downloadProgress = progress;
        if (progressHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressHandler(asset, progress);
            });
        }
    };
    PHImageRequestID requestID = [self.cachingImageManager requestImageDataForAsset:asset.phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL downloadSucceed = (imageData && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            UIImage *result = nil;
            if (downloadSucceed) {
                if (asset.assetMediaType == QQAssetMediaTypeGIF) {
                    result = [UIImage qq_imageWithGIFData:imageData];
                } else {
                    result = [UIImage imageWithData:imageData];
                }
                [asset updateDownloadStatus:YES];
            } else if ([info objectForKey:PHImageErrorKey]) {
                [asset updateDownloadStatus:NO];
            }
            if (completion) {
                completion(asset, result);
            }
        });
    }];
    return requestID;
}

- (PHImageRequestID)requestLivePhotoWithAsset:(QQAsset *)asset
                                     progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                   completion:(void (^)(QQAsset *asset, PHLivePhoto *livePhoto))completion API_AVAILABLE(ios(9.1)) {
    if ([[PHCachingImageManager class] instancesRespondToSelector:@selector(requestLivePhotoForAsset:targetSize:contentMode:options:resultHandler:)]) {
        PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            asset.downloadProgress = progress;
            if (progressHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressHandler(asset, progress);
                });
            }
        };
        PHImageRequestID requestID =  [self.cachingImageManager requestLivePhotoForAsset:asset.phAsset targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale) contentMode:PHImageContentModeDefault options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 这里判断是否下载成功有问题。info里面可能没有下面的key，可能包含PHImageErrorKey等等
                BOOL downloadSucceed = (livePhoto && !info) || (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey] && ![[info objectForKey:PHLivePhotoInfoIsDegradedKey] boolValue] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                PHLivePhoto *result = nil;
                if (downloadSucceed && livePhoto) {
                    result = livePhoto;
                    [asset updateDownloadStatus:YES];
                } else {
                    [asset updateDownloadStatus:NO];
                }
                if (completion) {
                    completion(asset, result);
                }
            });
        }];
        return requestID;
    } else {
        if (completion) {
            completion(nil, nil);
        }
        return 0;
    }
}

- (PHImageRequestID)requestPlayerItemWithAsset:(QQAsset *)asset
                               progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                    completion:(void (^)(QQAsset *asset, AVPlayerItem *playerItem))completion {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        asset.downloadProgress = progress;
        if (progressHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressHandler(asset, progress);
            });
        }
    };
    PHImageRequestID requestID = [self.cachingImageManager requestPlayerItemForVideo:asset.phAsset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        BOOL downloadSucceed = (playerItem != nil);
        CGSize naturalSize = CGSizeZero;
        if (downloadSucceed) {
            // 获取 naturalSize 放在主线程会卡顿，所以放在这里获取
            AVAssetTrack *assetVideoTrack = [playerItem.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            naturalSize = assetVideoTrack.naturalSize;
            NSInteger angle = [self angleFromTransform:assetVideoTrack.preferredTransform];
            if (angle == 90 || angle == 270) {
                naturalSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
            }
        }
        asset.naturalSize = naturalSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayerItem *result = nil;
            if (downloadSucceed) {
                result = playerItem;
                [asset updateDownloadStatus:YES];
            } else {
                [asset updateDownloadStatus:NO];
            }
            if (completion) {
                completion(asset, result);
            }
        });
    }];
    return requestID;
}

- (PHImageRequestID)requestAVAssetWithAsset:(QQAsset *)asset
                            progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                 completion:(void (^)(QQAsset *asset, AVAsset *avAsset))completion {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        asset.downloadProgress = progress;
        if (progressHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressHandler(asset, progress);
            });
        }
    };
    PHImageRequestID requestID = [self.cachingImageManager requestAVAssetForVideo:asset.phAsset options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        // 注意：avAsset不一定是AVURLAsset，也有可能是AVComposition（如：慢视频）
        BOOL downloadSucceed = (avAsset != nil);
        CGSize naturalSize = CGSizeZero;
        if (downloadSucceed) {
            // 获取 naturalSize 放在主线程会卡顿，所以放在这里获取
            AVAssetTrack *assetVideoTrack = [avAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
            naturalSize = assetVideoTrack.naturalSize;
            NSInteger angle = [self angleFromTransform:assetVideoTrack.preferredTransform];
            if (angle == 90 || angle == 270) {
                naturalSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
            }
        }
        asset.naturalSize = naturalSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAsset *result = nil;
            if (downloadSucceed) {
                result = avAsset;
                [asset updateDownloadStatus:YES];
            } else {
                [asset updateDownloadStatus:NO];
            }
            if (completion) {
                completion(asset, result);
            }
        });
    }];
    return requestID;
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
