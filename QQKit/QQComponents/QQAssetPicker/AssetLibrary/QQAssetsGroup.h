//
//  QQAssetsGroup.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import "QQAsset.h"

NS_ASSUME_NONNULL_BEGIN

/**
 代表一个相册
 */
@interface QQAssetsGroup : NSObject

- (instancetype)initWithCollection:(PHAssetCollection *)collection fetchResult:(PHFetchResult *)result;
@property (nonatomic, strong, readonly) PHAssetCollection *collection;
@property (nonatomic, strong, readonly) PHFetchResult *result;

/// 相册名称
@property (nonatomic, copy) NSString *name;

/// 相册内的资源数量
@property (nonatomic, assign, readonly) NSUInteger numberOfAssets;

/// 相册内所有的资源
@property (nonatomic, strong) NSMutableArray<QQAsset *> *assets;

/// 相册的缩略图
@property (nonatomic, strong) UIImage *thumbnailImage;

@end

NS_ASSUME_NONNULL_END
