//
//  QQUIHelper.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQUIHelper.h"
#import "UIDevice+QQExtension.h"

@implementation QQUIHelper

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
                height = 44;
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
            if ([[UIDevice systemVersion] doubleValue] > 12.0) {
                height = 50;
            } else {
                height = 49;
            }
        }
    } else {
        if ([self isLandscape]) {
            if ([UIDevice isNotchedScreen]) {
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

@end


