//
//  UIImage+QQExtension.h
//  NNKit
//
//  Created by Mac on 2021/3/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QQExtension)

/// 通过 UIColor 创建对应颜色的图片
+ (UIImage *)qq_imageWithColor:(UIColor *)color;
+ (UIImage *)qq_imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)qq_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

/**
 *  在当前图片的基础上叠加一张图片，并指定绘制叠加图片的起始位置
 *
 *  叠加上去的图片将保持原图片的大小不变，不被压缩、拉伸
 *
 *  @param image 要叠加的图片
 *  @param point 所叠加图片的绘制的起始位置
 *
 *  @return 返回一张与原图大小一致的图片，所叠加的图片若超出原图大小，则超出部分被截掉
 */
- (UIImage *)qq_imageWithImageAbove:(UIImage *)image atPoint:(CGPoint)point;

/**
 *  判断一张图是否不存在 alpha 通道，注意 “不存在 alpha 通道” 不等价于 “不透明”。一张不透明的图有可能是存在 alpha 通道但 alpha 值为 1。
 */
- (BOOL)qq_opaque;

/**
 *  获取当前图片的均色，原理是将图片绘制到1px*1px的矩形内，再从当前区域取色，得到图片的均色。
 *  @link http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/ @/link
 *
 *  @return 代表图片平均颜色的UIColor对象
 */
- (nullable UIColor *)qq_averageColor;

/**
 *  保持当前图片的形状不变，使用指定的颜色去重新渲染它，生成一张新图片并返回
 *
 *  @param tintColor 要用于渲染的新颜色
 *
 *  @return 与当前图片形状一致但颜色与参数tintColor相同的新图片
 */
- (nullable UIImage *)qq_imageWithTintColor:(nullable UIColor *)tintColor;


/// GIF动图
+ (nullable UIImage *)qq_imageWithGIFData:(NSData *)data;

/// Resized
- (UIImage *)qq_resizedImageByWidth:(CGFloat)width;
- (UIImage *)qq_resizedImageByHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
