//
//  QQUIHelper.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQUIHelper.h"
#import "UIDevice+QQExtension.h"
#import "NSObject+QQExtension.h"

@interface QQUIHelper ()

@end

@implementation QQUIHelper

+ (instancetype)sharedInstance {
    static QQUIHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QQUIHelper alloc] init];
        instance.beforeChangingOrientation = UIDeviceOrientationUnknown;
    });
    return instance;
}

static CGFloat pixelOne = -1.0f;
+ (CGFloat)pixelOne {
    if (pixelOne < 0) {
        pixelOne = 1 / [[UIScreen mainScreen] scale];
    }
    return pixelOne;
}

+ (BOOL)isLandscape {
    return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
}

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)deviceWidth {
    return MIN([self screenWidth], [self screenHeight]);
}

+ (CGFloat)deviceHeight {
    return MAX([self screenWidth], [self screenHeight]);
}

+ (UIEdgeInsets)deviceSafeAreaInsets {
    return [UIDevice deviceSafeAreaInsets];
}

+ (CGFloat)screenScale {
    return [UIScreen mainScreen].scale;
}

+ (CGFloat)statusBarHeight {
    return (UIApplication.sharedApplication.statusBarHidden ? 0 : UIApplication.sharedApplication.statusBarFrame.size.height);
}

+ (CGFloat)statusBarHeightConstant {
    CGFloat statusBarHeight = 0;
    if (UIApplication.sharedApplication.statusBarHidden) {
        if ([UIDevice isIPad]) {
            if ([UIDevice isNotchedScreen]) {
                statusBarHeight = 24;
            } else {
                statusBarHeight = 20;
            }
        } else {
            if ([self isLandscape]) {
                statusBarHeight = 0;
            } else {
                if ([UIDevice isNotchedScreen]) {
                    if ([[UIDevice deviceModel] isEqualToString:@"iPhone12,1"]) {
                        statusBarHeight = 48;
                    } else if ([UIDevice is61InchScreenAndiPhone12] || [UIDevice is67InchScreen]) {
                        statusBarHeight = 47;
                    } else {
                        statusBarHeight = 44;
                    }
                } else {
                    statusBarHeight = 20;
                }
            }
        }
    } else {
        statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
    }
    return statusBarHeight;
}

+ (CGFloat)navigationBarHeight {
    CGFloat height = 0;
    if ([UIDevice isIPad]) {
        if ([[UIDevice systemVersion] doubleValue] > 12.0) {
            height = 50;
        } else {
            height = 44;
        }
    } else {
        if ([self isLandscape]) {
            if ([UIDevice isNotchedScreen]) {
                // iPhone12、iPhone12Pro 横屏导航栏高度又变回32
                if ([UIDevice is61InchScreenAndiPhone12]) {
                    height = 32;
                } else {
                    height = 44;
                }
            } else {
                height = 32;
            }
        } else {
            height = 44;
        }
    }
    return height;
}

+ (CGFloat)navigationBarMaxY {
    return [self statusBarHeight] + [self navigationBarHeight];
}

+ (CGFloat)tabBarHeight {
    CGFloat height = 0;
    if ([UIDevice isIPad]) {
        if ([UIDevice isNotchedScreen]) {
            height = 65;
        } else {
            if ([[UIDevice systemVersion] doubleValue] >= 12.0) {
                height = 50;
            } else {
                height = 49;
            }
        }
    } else {
        if ([self isLandscape]) {
            if ([UIDevice isRegularScreen]) {
                height = 49;
            } else {
                height = 32;
            }
        } else {
            height = 49;
        }
        
    }
    return height + [UIDevice deviceSafeAreaInsets].bottom;
}

+ (BOOL)isSmallScreen {
    return [self deviceWidth] <= 320.0 + FLT_EPSILON ;
}

+ (BOOL)isMiddleScreen {
    return ([self deviceWidth] > 320.0 + FLT_EPSILON) && ([self deviceWidth] <= 375.0 + FLT_EPSILON);
}

+ (BOOL)isBigScreen {
    return [self deviceWidth] > 375.0 + FLT_EPSILON;
}

#pragma mark - 屏幕旋转

+ (BOOL)rotateDeviceToOrientation:(UIDeviceOrientation)orientation {
    if ([UIDevice currentDevice].orientation == orientation) {
        [UIViewController attemptRotationToDeviceOrientation];
        return NO;
    }
    
    [[UIDevice currentDevice] qq_setValue:@(orientation) forKey:@"orientation"];
    return YES;
}

+ (UIDeviceOrientation)deviceOrientationWithInterfaceOrientationMask:(UIInterfaceOrientationMask)mask {
    if ((mask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
        return [UIDevice currentDevice].orientation;
    }
    if ((mask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
        return [UIDevice currentDevice].orientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        return UIDeviceOrientationPortrait;
    }
    if ((mask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
        return [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationLandscapeRight;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        return UIDeviceOrientationLandscapeRight;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        return UIDeviceOrientationLandscapeLeft;
    }
    if ((mask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIDeviceOrientationPortraitUpsideDown;
    }
    return [UIDevice currentDevice].orientation;
}

+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    if (deviceOrientation == UIDeviceOrientationUnknown) {
        return YES;// YES 表示不用额外处理
    }
    
    if ((mask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
        return YES;
    }
    if ((mask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown != deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        return UIInterfaceOrientationPortrait == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
        return UIInterfaceOrientationLandscapeLeft == deviceOrientation || UIInterfaceOrientationLandscapeRight == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        return UIInterfaceOrientationLandscapeRight == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown == deviceOrientation;
    }
    
    return YES;
}

+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [self interfaceOrientationMask:mask containsDeviceOrientation:(UIDeviceOrientation)interfaceOrientation];
}

#pragma mark - App信息
+ (NSString *)appName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBuildVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

@end


