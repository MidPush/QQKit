//
//  UIImage+QQExtension.m
//  NNKit
//
//  Created by Mac on 2021/3/1.
//

#import "UIImage+QQExtension.h"
#import "UIColor+QQExtension.h"

@implementation UIImage (QQExtension)

+ (UIImage *)qq_imageWithColor:(UIColor *)color {
    return [UIImage qq_imageWithColor:color size:CGSizeMake(4, 4) cornerRadius:0];
}

+ (UIImage *)qq_imageWithColor:(UIColor *)color size:(CGSize)size {
    return [UIImage qq_imageWithColor:color size:size cornerRadius:0];
}

+ (UIImage *)qq_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
    color = color ? color : [UIColor clearColor];
    BOOL opaque = (cornerRadius == 0.0 && [color qq_alpha] == 1.0);
    return [UIImage qq_imageWithSize:size opaque:opaque scale:0 actions:^(CGContextRef contextRef) {
        CGContextSetFillColorWithColor(contextRef, color.CGColor);
        if (cornerRadius > 0) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:cornerRadius];
            [path addClip];
            [path fill];
        } else {
            CGContextFillRect(contextRef, CGRectMake(0, 0, size.width, size.height));
        }
    }];
}

- (UIImage *)qq_imageWithImageAbove:(UIImage *)image atPoint:(CGPoint)point {
    return [UIImage qq_imageWithSize:self.size opaque:self.qq_opaque scale:self.scale actions:^(CGContextRef contextRef) {
        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        [image drawAtPoint:point];
    }];
}

+ (UIImage *)qq_imageWithSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale actions:(void (^)(CGContextRef contextRef))actionBlock {
    if (!actionBlock || size.width <= 0 || size.height <= 0) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    actionBlock(context);
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}

+ (UIImage *)qq_imageWithGIFData:(NSData *)data {
    if (!data) return nil;
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!source) return nil;
    
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage;
    
    if (count < 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray <UIImage *> *images = [NSMutableArray array];
        float duration = 0.0;
        for (size_t i = 0; i < count; i++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!imageRef) {
                continue;
            }
            duration += [self qq_frameDurationAtIndex:i source:source];
            UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            [images addObject:image];
            CGImageRelease(imageRef);
        }
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    CFRelease(source);
    return animatedImage;
}

+ (float)qq_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    if (!cfFrameProperties) {
        return frameDuration;
    }
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp != nil) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp != nil) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

- (BOOL)qq_hasAlpha {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    return (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaPremultipliedLast);
}

- (BOOL)qq_opaque {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    BOOL opaque = (alphaInfo == kCGImageAlphaNoneSkipLast
    || alphaInfo == kCGImageAlphaNoneSkipFirst
    || alphaInfo == kCGImageAlphaNone);
    return opaque;
}

- (UIColor *)qq_averageColor {
    unsigned char rgba[4] = {};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (!context) {
        CGColorSpaceRelease(colorSpace);
        return nil;
    }
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    if(rgba[3] > 0) {
        return [UIColor colorWithRed:((CGFloat)rgba[0] / rgba[3])
                               green:((CGFloat)rgba[1] / rgba[3])
                                blue:((CGFloat)rgba[2] / rgba[3])
                               alpha:((CGFloat)rgba[3] / 255.0)];
    } else {
        return [UIColor colorWithRed:((CGFloat)rgba[0]) / 255.0
                               green:((CGFloat)rgba[1]) / 255.0
                                blue:((CGFloat)rgba[2]) / 255.0
                               alpha:((CGFloat)rgba[3]) / 255.0];
    }
}

- (UIImage *)qq_imageWithTintColor:(UIColor *)tintColor {
    BOOL opaque = self.qq_opaque ? tintColor.qq_alpha >= 1.0 : NO;// 如果图片不透明但 tintColor 半透明，则生成的图片也应该是半透明的
    return [UIImage qq_imageWithSize:self.size opaque:opaque scale:self.scale actions:^(CGContextRef contextRef) {
        CGContextTranslateCTM(contextRef, 0, self.size.height);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
        if (!opaque) {
            CGContextSetBlendMode(contextRef, kCGBlendModeNormal);
            CGContextClipToMask(contextRef, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
        }
        CGContextSetFillColorWithColor(contextRef, tintColor.CGColor);
        CGContextFillRect(contextRef, CGRectMake(0, 0, self.size.width, self.size.height));
    }];
}

- (UIImage *)qq_resizedImageByWidth:(CGFloat)width {
    if (self.size.width <= 0 || self.size.height <= 0) return self;
    CGFloat height = width * self.size.height / self.size.width;
    return [self qq_drawImageInBounds:CGRectMake(0, 0, width, height)];
}

- (UIImage *)qq_resizedImageByHeight:(CGFloat)height {
    if (self.size.width <= 0 || self.size.height <= 0) return self;
    CGFloat width = height * self.size.width / self.size.height;
    return [self qq_drawImageInBounds:CGRectMake(0, 0, width, height)];
}

- (UIImage *)qq_drawImageInBounds:(CGRect)bounds {
    UIGraphicsBeginImageContextWithOptions(bounds.size, !self.qq_hasAlpha, self.scale);
    [self drawInRect:bounds];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
