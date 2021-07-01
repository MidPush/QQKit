//
//  QQAssetsPickerHelper.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/6.
//

#import "QQAssetsPickerHelper.h"

static NSString *const QQAssetsPickerSpringAnimationKey = @"imagePickerActionSpring";
@implementation QQAssetsPickerHelper

+ (void)springAnimationForView:(UIView *)view {
    if (!view || ![view isKindOfClass:[UIView class]]) return;
    [self removeSpringAnimationForView:view];
    NSTimeInterval duration = 0.6;
    CAKeyframeAnimation *springAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    springAnimation.values = @[@.85, @1.15, @.9, @1.0,];
    springAnimation.keyTimes = @[@(0.0 / duration), @(0.15 / duration) , @(0.3 / duration), @(0.45 / duration),];
    springAnimation.duration = duration;
    [view.layer addAnimation:springAnimation forKey:QQAssetsPickerSpringAnimationKey];
}

+ (void)removeSpringAnimationForView:(UIView *)view {
    if (!view || ![view isKindOfClass:[UIView class]]) return;
    [view.layer removeAnimationForKey:QQAssetsPickerSpringAnimationKey];
}

+ (CGRect)scaleAspectFillImage:(CGSize)imageSize boundsSize:(CGSize)boundsSize {
    if (imageSize.width <= 0 || imageSize.height <= 0) return CGRectZero;
    if (boundsSize.width <= 0 || boundsSize.height <= 0) return CGRectZero;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = 0;
    CGFloat height = 0;
    if (boundsSize.width > boundsSize.height) {
        height = floorf(boundsSize.height);
        width = floorf((height * imageSize.width) / imageSize.height);
    } else {
        width = floorf(boundsSize.width);
        height = floorf((width * imageSize.height) / imageSize.width);
    }
    
    // Horizontally
    if (width < boundsSize.width) {
        x = floorf((boundsSize.width - width) / 2);
    } else {
        x = 0;
    }
    
    // Vertically
    if (height < boundsSize.height) {
        y = floorf((boundsSize.height - height) / 2);
    } else {
        y = 0;
    }
    
    return CGRectMake(x, y, width, height);
}

+ (CGRect)scaleAspectFitImage:(CGSize)imageSize boundsSize:(CGSize)boundsSize {
    if (imageSize.width <= 0 || imageSize.height <= 0) return CGRectZero;
    if (boundsSize.width <= 0 || boundsSize.height <= 0) return CGRectZero;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = 0;
    CGFloat height = 0;
    if (imageSize.width / imageSize.height > boundsSize.width / boundsSize.height) {
        width = boundsSize.width;
        height = imageSize.height * boundsSize.width / imageSize.width;
        x = 0;
        y = (boundsSize.height - height) / 2;
    } else {
        height = boundsSize.height;
        width = imageSize.width * boundsSize.height / imageSize.height;
        x = (boundsSize.width - width) / 2;
        y = 0;
    }
    return CGRectMake(x, y, width, height);
}

+ (NSString *)formatTime:(NSTimeInterval)duration {
    NSInteger minute = (duration / 60);
    NSInteger second = (duration - minute * 60);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minute, (long)second];
}

@end
