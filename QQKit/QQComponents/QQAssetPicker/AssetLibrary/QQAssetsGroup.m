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
    }
    return self;
}

- (NSString *)name {
    return self.collection.localizedTitle;
}

- (NSUInteger)numberOfAssets {
    return self.result.count;
}

- (void)enumerateAssetsUsingBlock:(void (^)(NSArray<QQAsset *> *assets))enumerationBlock {
    NSInteger resultCount = self.result.count;
    NSMutableArray *assetArray = [NSMutableArray arrayWithCapacity:resultCount];
    for (NSInteger i = 0; i < resultCount; i++) {
        PHAsset *pHAsset = self.result[i];
        QQAsset *asset = [[QQAsset alloc] initWithPHAsset:pHAsset];
        [assetArray addObject:asset];
    }
    if (enumerationBlock) {
        enumerationBlock([assetArray copy]);
    }
}

@end
