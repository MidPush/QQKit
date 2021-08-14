//
//  QQAsset.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQAsset.h"
#import "QQAssetsPicker.h"
#import "NSObject+QQExtension.h"

@implementation QQAsset

- (instancetype)initWithPHAsset:(PHAsset *)phAsset {
    if (self = [super init]) {
        _phAsset = phAsset;
        _identifier = phAsset.localIdentifier;
        QQPickerConfiguration *configuration = [QQAssetsPicker sharedPicker].configuration;
        if (phAsset.mediaType == PHAssetMediaTypeImage) {
            if ([[[phAsset qq_valueForKey:@"filename"] lowercaseString] hasSuffix:@"gif"] && configuration.allowsSelectionGIF) {
                _assetMediaType = QQAssetMediaTypeGIF;
            } else if (phAsset.representsBurst) {
                _assetMediaType = QQAssetMediaTypeBurst;
            } else {
                if (@available(iOS 9.1, *)) {
                    if ((phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) && configuration.allowsSelectionLivePhoto) {
                        _assetMediaType = QQAssetMediaTypeLivePhoto;
                    } else {
                        _assetMediaType = QQAssetMediaTypeStaticImage;
                    }
                } else {
                    _assetMediaType = QQAssetMediaTypeStaticImage;
                }
            }
        } else if (phAsset.mediaType == PHAssetMediaTypeVideo) {
            _assetMediaType = QQAssetMediaTypeVideo;
            _duration = round(phAsset.duration);
        } else if (phAsset.mediaType == PHAssetMediaTypeAudio) {
            _assetMediaType = QQAssetMediaTypeAudio;
        } else {
            _assetMediaType = QQAssetMediaTypeUnknow;
        }
    }
    return self;
}

- (void)updateDownloadStatus:(BOOL)result {
    _downloadStatus = result ? QQAssetDownloadStatusSucceed : QQAssetDownloadStatusFailed;
}

- (void)setDownloadProgress:(double)downloadProgress {
    _downloadProgress = downloadProgress;
    _downloadStatus = QQAssetDownloadStatusDownloading;
}

- (NSString *)fileName {
    NSArray *resourceArray = [PHAssetResource assetResourcesForAsset:_phAsset];
    NSString *fileName = nil;
    if (resourceArray.count > 0) {
        fileName = ((PHAssetResource *)resourceArray.firstObject).originalFilename;
    }
    if (!fileName) {
        fileName = [self randomString:8];
    }
    return fileName;
}

- (BOOL)iCloud {
    NSArray *resourceArray = [PHAssetResource assetResourcesForAsset:_phAsset];
    if (resourceArray.count > 0) {
        BOOL iCloud = [[resourceArray.firstObject qq_valueForKey:@"locallyAvailable"] boolValue];
        return iCloud;
    }
    return NO;
}

- (NSString *)randomString:(NSUInteger)length {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex: arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    return [self.identifier isEqualToString:((QQAsset *)object).identifier];
}

@end
