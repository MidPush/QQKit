//
//  QQVideoEditor.h
//  QQKitDemo
//
//  Created by Mac on 2021/6/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 主要功能：视频旋转、裁剪视频、添加水印、合并视频
 注意：对视频编辑方面不是太了解，QQVideoEditor在对视频操作上可能会有问题
 以后有空好好研究一下视频方面吧（^_^）！
 */
NS_ASSUME_NONNULL_BEGIN

@interface QQVideoEditor : NSObject

/// 初始化方法
- (instancetype)initWithURL:(NSURL *)url presetName:(NSString *)presetName;
- (instancetype)initWithAsset:(AVAsset *)asset presetName:(NSString *)presetName;

/// 视频输出资源
@property (nonatomic, strong, readonly, nullable) AVAsset *outputAsset;

/// 视频输出URL
@property (nonatomic, copy, nullable) NSURL *outputURL;

/// 视频输出类型，默认 AVFileTypeMPEG4
@property (nonatomic, copy, nullable) AVFileType outputFileType;

/// 添加旋转视频任务
- (void)addRotateTask:(CGFloat)rotateAngle;

/// 添加裁剪范围视频任务
- (void)addCropRectTask:(CGRect)cropRect;

/// 添加裁剪时间视频任务
- (void)addCropTimeTask:(CMTimeRange)timeRange;

/// 添加水印任务
- (void)addWatermarkTask:(UIImage *)image;

/// 添加视频合并任务
- (void)addMixTask:(AVAsset *)asset;

/// 开始任务
- (void)startTaskWithProgress:(void (^)(double progress))progress completion:(void (^)(NSError *error))completion;

/// 取消任务
- (void)cancelTask;

@end

NS_ASSUME_NONNULL_END
