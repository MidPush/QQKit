//
//  QQCropViewConstants.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/9.
//

#import <Foundation/Foundation.h>

/**
 裁剪类型
 */
typedef NS_ENUM(NSInteger, QQImageCropStyle) {
    QQImageCropStyleDefault,    // 矩形的裁切框
    QQImageCropStyleCircular,   // 圆形的裁切框
};

/**
 最常见宽高比的预设值
 */
typedef NS_ENUM(NSInteger, QQCropViewControllerAspectRatioPreset) {
    QQCropViewControllerAspectRatioPresetOriginal,
    QQCropViewControllerAspectRatioPresetSquare,
    QQCropViewControllerAspectRatioPreset3x2,
    QQCropViewControllerAspectRatioPreset5x3,
    QQCropViewControllerAspectRatioPreset4x3,
    QQCropViewControllerAspectRatioPreset5x4,
    QQCropViewControllerAspectRatioPreset7x5,
    QQCropViewControllerAspectRatioPreset16x9,
    QQCropViewControllerAspectRatioPresetCustom
};
