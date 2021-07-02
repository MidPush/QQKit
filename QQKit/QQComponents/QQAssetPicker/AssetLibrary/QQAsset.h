//
//  QQAsset.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QQAssetMediaType) {
    QQAssetMediaTypeUnknow,
    
    // image
    QQAssetMediaTypeStaticImage,
    QQAssetMediaTypeLivePhoto NS_ENUM_AVAILABLE_IOS(9_1),
    QQAssetMediaTypeGIF,
    QQAssetMediaTypeBurst,
    
    // video
    QQAssetMediaTypeVideo,
    
    // audio
    QQAssetMediaTypeAudio
};

typedef NS_ENUM(NSUInteger, QQAssetDownloadStatus) {
    QQAssetDownloadStatusSucceed = 1,
    QQAssetDownloadStatusDownloading,
    QQAssetDownloadStatusCanceled,
    QQAssetDownloadStatusFailed
};

@interface QQAsset : NSObject

- (instancetype)initWithPHAsset:(PHAsset *)phAsset;
- (void)updateDownloadStatus:(BOOL)result;

/// 资源类型
@property (nonatomic, assign, readonly) QQAssetMediaType assetMediaType;

/// 从 iCloud 下载资源大图的状态
@property (nonatomic, assign, readonly) QQAssetDownloadStatus downloadStatus;

/// PHAsset
@property (nonatomic, strong, readonly) PHAsset *phAsset;

/// 资源标识符
@property (nonatomic, copy, readonly) NSString *identifier;

/// 文件名
@property (nonatomic, copy, readonly) NSString *fileName;

/// 资源是否是 iCloud
@property (nonatomic, assign, readonly) BOOL iCloud;

/// 编辑后的图
@property (nonatomic, strong) UIImage *editImage;

/// 编辑后的视频URL
@property (nonatomic, strong) NSURL *editVideoURL;

/// 缩略图
@property (nonatomic, strong) UIImage *thumbnailImage;

/// 视频时长
@property (nonatomic, assign, readonly) NSTimeInterval duration;

/// 视频 naturalSize
@property (nonatomic, assign) CGSize naturalSize;

/// 从 iCloud 下载资源进度
@property (nonatomic, assign) double downloadProgress;

/// 是否被选择
@property (nonatomic, assign) BOOL selected;

/// 被选择的 index
@property (nonatomic, assign) NSInteger selectedIndex;

/// 当预览时是否隐藏
@property (nonatomic, assign) BOOL isHidden;

/// 点击完成按钮时才会对以下属性赋值
// 未选择原图有值
@property (nonatomic, strong, nullable) UIImage *previewImage;

// 选择了原图有值
@property (nonatomic, strong, nullable) UIImage *originalImage;

// 资源是GIF有值
@property (nonatomic, strong, nullable) UIImage *GIFImage;

// 资源是PHLivePhoto有值
@property (nonatomic, strong, nullable) PHLivePhoto *livePhoto API_AVAILABLE(ios(9.1));

//资源是视频有值
@property (nonatomic, strong, nullable) AVAsset *avAsset;

@end

NS_ASSUME_NONNULL_END
