//
//  QQAssetsPickerHelper.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQAssetsPickerHelper : NSObject

+ (void)springAnimationForView:(UIView *)view;
+ (void)removeSpringAnimationForView:(UIView *)view;

// 以AspectFillMode缩放image，算出来frame可能超出bounds
+ (CGRect)scaleAspectFillImage:(CGSize)imageSize boundsSize:(CGSize)boundsSize;

// 以AspectFitMode缩放image，算出来frame不会超出bounds
+ (CGRect)scaleAspectFitImage:(CGSize)imageSize boundsSize:(CGSize)boundsSize;

// 秒转00:00格式
+ (NSString *)formatTime:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
