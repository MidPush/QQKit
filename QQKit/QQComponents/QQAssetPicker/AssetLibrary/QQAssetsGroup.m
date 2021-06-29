//
//  QQAssetsGroup.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQAssetsGroup.h"
#import "QQAssetsPicker.h"

@interface QQAssetsGroup ()

@end

@implementation QQAssetsGroup

- (instancetype)initWithCollection:(PHAssetCollection *)collection fetchResult:(PHFetchResult *)result {
    if (self = [super init]) {
        _collection = collection;
        _result = result;
        if (result.count > 0) {
            NSMutableArray *assetArray = [NSMutableArray arrayWithCapacity:result.count];
            for (PHAsset *phAsset in result) {
                QQAsset *asset = [[QQAsset alloc] initWithPHAsset:phAsset];
                [assetArray addObject:asset];
            }
            _assets = assetArray;
        }
    }
    return self;
}

- (NSString *)name {
    return self.collection.localizedTitle;
}

- (NSUInteger)numberOfAssets {
    return self.result.count;
}

@end
