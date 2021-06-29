//
//  QQAssetsPicker.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import "QQAsset.h"
#import "QQAssetsGroup.h"
#import "QQCropViewConstants.h"

typedef NS_ENUM(NSInteger, QQAuthorizationStatus) {
    QQAuthorizationStatusNotDetermined = 0, // 还不确定有没有授权
    QQAuthorizationStatusRestricted,        // 家长控制,不允许访问
    QQAuthorizationStatusDenied,            // 手动禁止了授权
    QQAuthorizationStatusAuthorized,        // 已经授权
    QQAuthorizationStatusLimited API_AVAILABLE(ios(14)), // 有限制访问
};

typedef NS_ENUM(NSInteger, QQPickerFilterType) {
    QQPickerFilterTypeAll,      // 显示所有资源
    QQPickerFilterTypeImage,    // 只显示照片
    QQPickerFilterTypeVideo,    // 只显示视频
    QQPickerFilterTypeAudio     // 只显示音频
};

extern NSNotificationName const QQPickerDidFinishPickingAssetsNotification;
extern NSNotificationName const QQPickerDidCancelPickingAssetsNotification;
extern NSString *const QQPickerSelectedAssetsInfoKey;
extern NSString *const QQPickerUsingOriginalImageKey;

@interface QQPickerConfiguration : NSObject

/// 最多可以选择的图片数，默认为9，0为不限制。
@property (nonatomic, assign) NSInteger selectionLimit;

/// 相册的内容类型，设定了内容类型后，所获取的相册中只包含对应类型的资源，默认显示所有资源
@property (nonatomic, assign) QQPickerFilterType filterType;

/// 是否允许图片多选，默认为 YES。如果为 NO，则不显示 checkbox 和底部工具栏。
@property (nonatomic, assign) BOOL allowsMultipleSelection;

/// 是否允许编辑图片
@property (nonatomic, assign) BOOL allowsImageEditing;

/// 是否允许编辑视频
@property (nonatomic, assign) BOOL allowsVideoEditing;

/**
 是否允许选择LivePhoto，默认为NO。（只有filterType显示照片才有效）
 若为YES，原本是LivePhoto资源的 assetMediaType 为 QQAssetMediaTypeLivePhoto，
 若为NO，原本是LivePhoto资源的  assetMediaType 按 QQAssetMediaTypeStaticImage 处理。
*/
@property (nonatomic, assign) BOOL allowsSelectionLivePhoto;

/**
 是否允许选择GIF，默认为NO。（只有filterType显示照片才有效）
 若为YES，原本是动图资源的 assetMediaType 为 QQAssetMediaTypeGIF，
 若为NO，原本是动图资源的 assetMediaType 按 QQAssetMediaTypeStaticImage 处理。
*/
@property (nonatomic, assign) BOOL allowsSelectionGIF;

/// ============== 裁剪设置 ==============
/**
 裁剪长宽比是否锁定，默认NO
 */
@property (nonatomic, assign) BOOL aspectRatioLockEnabled;

/**
 裁剪类型，默认QQImageCropStyleDefault
 */
@property (nonatomic, assign) QQImageCropStyle croppingStyle;

/**
 最常见宽高比的预设值，默认QQCropViewControllerAspectRatioPresetOriginal
 */
@property (nonatomic, assign) QQCropViewControllerAspectRatioPreset aspectRatioPreset;


/// ============== 增加一些配置 UI 的属性 ==============
@property (nonatomic, strong) UIImage *assetPickerBurstImage;
@property (nonatomic, strong) UIImage *assetPickerCheckMarkNormalImage;
@property (nonatomic, strong) UIImage *assetPickerCheckMarkSelectedImage;
@property (nonatomic, strong) UIImage *assetPickerGIFImage;
@property (nonatomic, strong) UIImage *assetPickerICloudImage;
@property (nonatomic, strong) UIImage *assetPickerNavArrowImage;
@property (nonatomic, strong) UIImage *assetPickerNavBackImage;
@property (nonatomic, strong) UIImage *assetPickerNavCheckImage;
@property (nonatomic, strong) UIImage *assetPickerPlayImage;
@property (nonatomic, strong) UIImage *assetPickerRotateImage;
@property (nonatomic, strong) UIImage *assetPickerVideoImage;

@end

@interface QQAssetsPicker : NSObject

/// 单例
+ (instancetype)sharedPicker;

/// Picker 配置
@property (nonatomic, strong) QQPickerConfiguration *configuration;

/// 获取一个 PHCachingImageManager 的实例
- (PHCachingImageManager *)cachingImageManager;

/// 获取当前应用的“照片”访问授权状态
+ (QQAuthorizationStatus)authorizationStatus;

/**
 *  调起系统询问是否授权访问“照片”的 弹窗
 *  @param handler 授权结束后调用的 block，在主线程上执行
 */
+ (void)requestAuthorization:(void(^)(QQAuthorizationStatus status))handler;

/**
 *  获取所有相册和相册下所有资源
 */
- (void)fetchAssetsGroupsWithCompletion:(void (^)(NSArray<QQAssetsGroup *> *albums))completion;

/**
 * 异步请求相册的缩略图，不会产生网络请求
 */
- (PHImageRequestID)requestThumbnailImageWithAlbum:(QQAssetsGroup *)group
                                              size:(CGSize)size
                                        completion:(void (^)(QQAssetsGroup *group, UIImage *result))completion;

/**
 *  异步请求 Asset 的缩略图，不会产生网络请求
 */
- (PHImageRequestID)requestThumbnailImageWithAsset:(QQAsset *)asset
                                              size:(CGSize)size
                                        completion:(void (^)(QQAsset *asset, UIImage *result))completion;

/**
 *  异步请求 Asset 的预览图，可能会有网络请求
 *  synchronous同步异步
 *  同步执行 block completion 只会执行一次
 *  异步执行 block completion 可能执行多次
 */
- (PHImageRequestID)requestPreviewImageWithAsset:(QQAsset *)asset
                                     synchronous:(BOOL)synchronous
                                 progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                      completion:(void (^)(QQAsset *asset, UIImage *result))completion;

/**
 *  异步请求 Asset 的原图，包含了系统照片“编辑”功能处理后的效果（剪裁，旋转和滤镜等），可能会有网络请求
 */
- (PHImageRequestID)requestOriginImageWithAsset:(QQAsset *)asset
                                progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                     completion:(void (^)(QQAsset *asset, UIImage *result))completion;

/**
 *  异步请求 Live Photo，可能会有网络请求
 */
- (PHImageRequestID)requestLivePhotoWithAsset:(QQAsset *)asset
                              progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                   completion:(void (^)(QQAsset *asset, PHLivePhoto *livePhoto))completion API_AVAILABLE(ios(9.1));

/**
 *  异步请求 AVPlayerItem，可能会有网络请求
 *  该方法请求不会返回进度？有时候也会播放失败，可能是我使用的姿势不对？
 *  后面使用 requestAVAssetForVideo 代替
 */
- (PHImageRequestID)requestPlayerItemWithAsset:(QQAsset *)asset
                               progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                    completion:(void (^)(QQAsset *asset, AVPlayerItem *playerItem))completion;

/**
 *  异步请求 AVAsset，可能会有网络请求
 */
- (PHImageRequestID)requestAVAssetWithAsset:(QQAsset *)asset
                            progressHandler:(void (^)(QQAsset *asset, double downloadProgress))progressHandler
                                 completion:(void (^)(QQAsset *asset, AVAsset *avAsset))completion;
@end

