//
//  QQAssetPickerController.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "QQAssetsPicker.h"

/**
 相册选择器
 */
@class QQAssetPickerController;
@protocol QQAssetPickerControllerDelegate <NSObject>

@optional
- (void)picker:(QQAssetPickerController *)picker didFinishPicking:(NSArray<QQAsset *> *)assets usingOriginalImage:(BOOL)usingOriginalImage;
- (void)pickerDidCancel:(QQAssetPickerController *)picker;

@end

@interface QQAssetPickerController : UINavigationController

/**
 初始化方法，如果之前已选择，默认清空已选择的资源
 */
- (instancetype)initWithConfiguration:(QQPickerConfiguration *)configuration;

/**
 初始化方法，如果之前已选择，传入selectedAssets，保留已选择的资源
 */
- (instancetype)initWithConfiguration:(QQPickerConfiguration *)configuration selectedAssets:(NSArray<QQAsset *> *)selectedAssets;

@property (nonatomic, strong, readonly) QQPickerConfiguration *configuration;
@property (nonatomic, weak) id<QQAssetPickerControllerDelegate> pickerDelegate;

@end

