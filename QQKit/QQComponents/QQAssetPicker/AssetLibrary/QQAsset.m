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
        NSArray *resourceArray = [PHAssetResource assetResourcesForAsset:phAsset];
        if (resourceArray.count > 0) {
            _iCloud = [[resourceArray.firstObject qq_valueForKey:@"locallyAvailable"] boolValue];
        }
        _fileName = ((PHAssetResource *)resourceArray.firstObject).originalFilename;
        if (!_fileName) {
            _fileName = [self randomString:8];
        }
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

- (NSString *)randomString:(NSUInteger)length {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex: arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}

@end
