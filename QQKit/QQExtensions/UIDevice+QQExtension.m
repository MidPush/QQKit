//
//  UIDevice+QQExtension.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/7.
//

#import "UIDevice+QQExtension.h"
#import <sys/utsname.h>

@implementation UIDevice (QQExtension)

+ (NSString *)systemVersion {
    static NSString *version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion;
    });
    return version;
}

+ (NSString *)deviceModel {
    if ([self isSimulator]) {
        // 模拟器不返回物理机器信息，但会通过环境变量的方式返回
        return [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
    }
    // See https://www.theiphonewiki.com/wiki/Models for identifiers
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)deviceName {
    static dispatch_once_t onceToken;
    static NSString *name;
    dispatch_once(&onceToken, ^{
        NSString *model = [self deviceModel];
        if (!model) {
            name = @"Unknown Device";
            return;
        }
        
        NSDictionary *dict = @{
            // See https://www.theiphonewiki.com/wiki/Models
            @"iPhone1,1" : @"iPhone 1G",
            @"iPhone1,2" : @"iPhone 3G",
            @"iPhone2,1" : @"iPhone 3GS",
            @"iPhone3,1" : @"iPhone 4 (GSM)",
            @"iPhone3,2" : @"iPhone 4",
            @"iPhone3,3" : @"iPhone 4 (CDMA)",
            @"iPhone4,1" : @"iPhone 4S",
            @"iPhone5,1" : @"iPhone 5",
            @"iPhone5,2" : @"iPhone 5",
            @"iPhone5,3" : @"iPhone 5c",
            @"iPhone5,4" : @"iPhone 5c",
            @"iPhone6,1" : @"iPhone 5s",
            @"iPhone6,2" : @"iPhone 5s",
            @"iPhone7,1" : @"iPhone 6 Plus",
            @"iPhone7,2" : @"iPhone 6",
            @"iPhone8,1" : @"iPhone 6s",
            @"iPhone8,2" : @"iPhone 6s Plus",
            @"iPhone8,4" : @"iPhone SE",
            @"iPhone9,1" : @"iPhone 7",
            @"iPhone9,2" : @"iPhone 7 Plus",
            @"iPhone9,3" : @"iPhone 7",
            @"iPhone9,4" : @"iPhone 7 Plus",
            @"iPhone10,1" : @"iPhone 8",
            @"iPhone10,2" : @"iPhone 8 Plus",
            @"iPhone10,3" : @"iPhone X",
            @"iPhone10,4" : @"iPhone 8",
            @"iPhone10,5" : @"iPhone 8 Plus",
            @"iPhone10,6" : @"iPhone X",
            @"iPhone11,2" : @"iPhone XS",
            @"iPhone11,4" : @"iPhone XS Max",
            @"iPhone11,6" : @"iPhone XS Max CN",
            @"iPhone11,8" : @"iPhone XR",
            @"iPhone12,1" : @"iPhone 11",
            @"iPhone12,3" : @"iPhone 11 Pro",
            @"iPhone12,5" : @"iPhone 11 Pro Max",
            @"iPhone12,8" : @"iPhone SE (2nd generation)",
            @"iPhone13,1" : @"iPhone 12 mini",
            @"iPhone13,2" : @"iPhone 12",
            @"iPhone13,3" : @"iPhone 12 Pro",
            @"iPhone13,4" : @"iPhone 12 Pro Max",
            
            @"iPad1,1" : @"iPad 1",
            @"iPad2,1" : @"iPad 2 (WiFi)",
            @"iPad2,2" : @"iPad 2 (GSM)",
            @"iPad2,3" : @"iPad 2 (CDMA)",
            @"iPad2,4" : @"iPad 2",
            @"iPad2,5" : @"iPad mini 1",
            @"iPad2,6" : @"iPad mini 1",
            @"iPad2,7" : @"iPad mini 1",
            @"iPad3,1" : @"iPad 3 (WiFi)",
            @"iPad3,2" : @"iPad 3 (4G)",
            @"iPad3,3" : @"iPad 3 (4G)",
            @"iPad3,4" : @"iPad 4",
            @"iPad3,5" : @"iPad 4",
            @"iPad3,6" : @"iPad 4",
            @"iPad4,1" : @"iPad Air",
            @"iPad4,2" : @"iPad Air",
            @"iPad4,3" : @"iPad Air",
            @"iPad4,4" : @"iPad mini 2",
            @"iPad4,5" : @"iPad mini 2",
            @"iPad4,6" : @"iPad mini 2",
            @"iPad4,7" : @"iPad mini 3",
            @"iPad4,8" : @"iPad mini 3",
            @"iPad4,9" : @"iPad mini 3",
            @"iPad5,1" : @"iPad mini 4",
            @"iPad5,2" : @"iPad mini 4",
            @"iPad5,3" : @"iPad Air 2",
            @"iPad5,4" : @"iPad Air 2",
            @"iPad6,3" : @"iPad Pro (9.7 inch)",
            @"iPad6,4" : @"iPad Pro (9.7 inch)",
            @"iPad6,7" : @"iPad Pro (12.9 inch)",
            @"iPad6,8" : @"iPad Pro (12.9 inch)",
            @"iPad6,11": @"iPad 5 (WiFi)",
            @"iPad6,12": @"iPad 5 (Cellular)",
            @"iPad7,1" : @"iPad Pro (12.9 inch, 2nd generation)",
            @"iPad7,2" : @"iPad Pro (12.9 inch, 2nd generation)",
            @"iPad7,3" : @"iPad Pro (10.5 inch)",
            @"iPad7,4" : @"iPad Pro (10.5 inch)",
            @"iPad7,5" : @"iPad 6 (WiFi)",
            @"iPad7,6" : @"iPad 6 (Cellular)",
            @"iPad7,11": @"iPad 7 (WiFi)",
            @"iPad7,12": @"iPad 7 (Cellular)",
            @"iPad8,1" : @"iPad Pro (11 inch)",
            @"iPad8,2" : @"iPad Pro (11 inch)",
            @"iPad8,3" : @"iPad Pro (11 inch)",
            @"iPad8,4" : @"iPad Pro (11 inch)",
            @"iPad8,5" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,6" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,7" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,8" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,9" : @"iPad Pro (11 inch, 2nd generation)",
            @"iPad8,10" : @"iPad Pro (11 inch, 2nd generation)",
            @"iPad8,11" : @"iPad Pro (12.9 inch, 4th generation)",
            @"iPad8,12" : @"iPad Pro (12.9 inch, 4th generation)",
            @"iPad11,1" : @"iPad mini (5th generation)",
            @"iPad11,2" : @"iPad mini (5th generation)",
            @"iPad11,3" : @"iPad Air (3rd generation)",
            @"iPad11,4" : @"iPad Air (3rd generation)",
            @"iPad11,6" : @"iPad (WiFi)",
            @"iPad11,7" : @"iPad (Cellular)",
            @"iPad13,1" : @"iPad Air (4th generation)",
            @"iPad13,2" : @"iPad Air (4th generation)",
            
            @"iPod1,1" : @"iPod touch 1",
            @"iPod2,1" : @"iPod touch 2",
            @"iPod3,1" : @"iPod touch 3",
            @"iPod4,1" : @"iPod touch 4",
            @"iPod5,1" : @"iPod touch 5",
            @"iPod7,1" : @"iPod touch 6",
            @"iPod9,1" : @"iPod touch 7",
            
            @"i386" : @"Simulator x86",
            @"x86_64" : @"Simulator x64",
            
            @"Watch1,1" : @"Apple Watch 38mm",
            @"Watch1,2" : @"Apple Watch 42mm",
            @"Watch2,3" : @"Apple Watch Series 2 38mm",
            @"Watch2,4" : @"Apple Watch Series 2 42mm",
            @"Watch2,6" : @"Apple Watch Series 1 38mm",
            @"Watch2,7" : @"Apple Watch Series 1 42mm",
            @"Watch3,1" : @"Apple Watch Series 3 38mm",
            @"Watch3,2" : @"Apple Watch Series 3 42mm",
            @"Watch3,3" : @"Apple Watch Series 3 38mm (LTE)",
            @"Watch3,4" : @"Apple Watch Series 3 42mm (LTE)",
            @"Watch4,1" : @"Apple Watch Series 4 40mm",
            @"Watch4,2" : @"Apple Watch Series 4 44mm",
            @"Watch4,3" : @"Apple Watch Series 4 40mm (LTE)",
            @"Watch4,4" : @"Apple Watch Series 4 44mm (LTE)",
            @"Watch5,1" : @"Apple Watch Series 5 40mm",
            @"Watch5,2" : @"Apple Watch Series 5 44mm",
            @"Watch5,3" : @"Apple Watch Series 5 40mm (LTE)",
            @"Watch5,4" : @"Apple Watch Series 5 44mm (LTE)",
            @"Watch5,9" : @"Apple Watch SE 40mm",
            @"Watch5,10" : @"Apple Watch SE 44mm",
            @"Watch5,11" : @"Apple Watch SE 40mm",
            @"Watch5,12" : @"Apple Watch SE 44mm",
            @"Watch6,1"  : @"Apple Watch Series 6 40mm",
            @"Watch6,2"  : @"Apple Watch Series 6 44mm",
            @"Watch6,3"  : @"Apple Watch Series 6 40mm",
            @"Watch6,4"  : @"Apple Watch Series 6 44mm",
            
            @"AudioAccessory1,1" : @"HomePod",
            @"AudioAccessory1,2" : @"HomePod",
            @"AudioAccessory5,1" : @"HomePod mini",
            
            @"AirPods1,1" : @"AirPods (1st generation)",
            @"AirPods2,1" : @"AirPods (2nd generation)",
            @"iProd8,1"   : @"AirPods Pro",
            
            @"AppleTV2,1" : @"Apple TV 2",
            @"AppleTV3,1" : @"Apple TV 3",
            @"AppleTV3,2" : @"Apple TV 3",
            @"AppleTV5,3" : @"Apple TV 4",
            @"AppleTV6,2" : @"Apple TV 4K",
        };
        name = dict[model];
        if (!name) name = model;
        if ([self isSimulator]) name = [name stringByAppendingString:@" Simulator"];
    });
    return name;
}

static NSInteger isIPad = -1;
+ (BOOL)isIPad {
    if (isIPad < 0) {
        isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : 0;
    }
    return isIPad > 0;
}

static NSInteger isIPod = -1;
+ (BOOL)isIPod {
    if (isIPod < 0) {
        NSString *string = [[UIDevice currentDevice] model];
        isIPod = [string rangeOfString:@"iPod touch"].location != NSNotFound ? 1 : 0;
    }
    return isIPod > 0;
}

static NSInteger isIPhone = -1;
+ (BOOL)isIPhone {
    if (isIPhone < 0) {
        NSString *string = [[UIDevice currentDevice] model];
        isIPhone = [string rangeOfString:@"iPhone"].location != NSNotFound ? 1 : 0;
    }
    return isIPhone > 0;
}

static NSInteger isSimulator = -1;
+ (BOOL)isSimulator {
    if (isSimulator < 0) {
#if TARGET_OS_SIMULATOR
        isSimulator = 1;
#else
        isSimulator = 0;
#endif
    }
    return isSimulator > 0;
}

+ (BOOL)isMac {
#ifdef IOS14_SDK_ALLOWED
    if (@available(iOS 14.0, *)) {
        return [NSProcessInfo processInfo].isiOSAppOnMac || [NSProcessInfo processInfo].isMacCatalystApp;
    }
#endif
    if (@available(iOS 13.0, *)) {
        return [NSProcessInfo processInfo].isMacCatalystApp;
    }
    return NO;
}

static NSInteger isNotchedScreen = -1;
+ (BOOL)isNotchedScreen {
    if (isNotchedScreen < 0) {
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [UIApplication sharedApplication].delegate.window;
            if (!window) {
                window = [UIApplication sharedApplication].windows.firstObject;
            }
            if (window.safeAreaInsets.bottom > 0) {
                isNotchedScreen = 1;
            } else {
                isNotchedScreen = 0;
            }
        }
    }
    return isNotchedScreen > 0;
}

+ (CGFloat)deviceWidth {
    return MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
}

+ (CGFloat)deviceHeight {
    return MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
}

+ (CGSize)screenSizeFor61InchAndiPhone12 {
    return CGSizeMake(390, 844);
}

+ (CGSize)screenSizeFor67Inch {
    return CGSizeMake(428, 926);
}

static NSInteger is61InchScreenAndiPhone12 = -1;
+ (BOOL)is61InchScreenAndiPhone12 {
    if (is61InchScreenAndiPhone12 < 0) {
        is61InchScreenAndiPhone12 = (self.deviceWidth == self.screenSizeFor61InchAndiPhone12.width && self.deviceHeight == self.screenSizeFor61InchAndiPhone12.height && ([[self deviceModel] isEqualToString:@"iPhone13,2"] || [[self deviceModel] isEqualToString:@"iPhone13,3"])) ? 1 : 0;
    }
    return is61InchScreenAndiPhone12 > 0;
}

static NSInteger is67InchScreen = -1;
+ (BOOL)is67InchScreen {
    if (is67InchScreen < 0) {
        is67InchScreen = (self.deviceWidth == self.screenSizeFor67Inch.width && self.deviceHeight == self.screenSizeFor67Inch.height) ? 1 : 0;
    }
    return is67InchScreen > 0;
}

+ (UIEdgeInsets)deviceSafeAreaInsets {
    if (![self isNotchedScreen]) {
        return UIEdgeInsetsZero;
    }
    
    if ([self isIPad]) {
        return UIEdgeInsetsMake(0, 0, 20, 0);
    }
    
    static NSDictionary<NSString *, NSDictionary<NSNumber *, NSValue *> *> *dict;
    if (!dict) {
        dict = @{
            // iPhone 12 mini
            @"iPhone13,1": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(50, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 50, 21, 50)],
            },
            @"iPhone13,1-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(43, 0, 29, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 43, 21, 43)],
            },
            // iPhone 12
            @"iPhone13,2": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone13,2-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(39, 0, 28, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 39, 21, 39)],
            },
            // iPhone 12 Pro
            @"iPhone13,3": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone13,3-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(39, 0, 28, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 39, 21, 39)],
            },
            // iPhone 12 Pro Max
            @"iPhone13,4": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone13,4-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(41, 0, 29 + 2.0 / 3.0, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 41, 21, 41)],
            },
            // iPhone 11
            @"iPhone12,1": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(48, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 48, 21, 48)],
            },
            @"iPhone12,1-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(44, 0, 31, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 44, 21, 44)],
            },
            // iPhone 11 Pro Max
            @"iPhone12,5": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(44, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 44, 21, 44)],
            },
            @"iPhone12,5-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(40, 0, 30 + 2.0 / 3.0, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 40, 21, 40)],
            },
        };
    }
    
    NSString *deviceKey = [self deviceModel];
    if (!dict[deviceKey]) {
        deviceKey = @"iPhone12,5";// 默认按 iPhone 11 Pro Max
    }
    if ([self isZoomedMode]) {
        deviceKey = [NSString stringWithFormat:@"%@-Zoom", deviceKey];
    }
    
    NSNumber *orientationKey = nil;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            orientationKey = @(UIInterfaceOrientationLandscapeLeft);
            break;
        default:
            orientationKey = @(UIInterfaceOrientationPortrait);
            break;
    }
    
    UIEdgeInsets insets = dict[deviceKey][orientationKey].UIEdgeInsetsValue;
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        insets = UIEdgeInsetsMake(insets.bottom, insets.left, insets.top, insets.right);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        insets = UIEdgeInsetsMake(insets.top, insets.right, insets.bottom, insets.left);
    }
    return insets;
}

+ (BOOL)isZoomedMode {
    if (![self isIPhone]) {
        return NO;
    }
    
    CGFloat nativeScale = UIScreen.mainScreen.nativeScale;
    CGFloat scale = UIScreen.mainScreen.scale;
    
    // 对于所有的 Plus 系列 iPhone，屏幕物理像素低于软件层面的渲染像素，不管标准模式还是放大模式，nativeScale 均小于 scale，所以需要特殊处理才能准确区分放大模式
    // https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
    BOOL shouldBeDownsampledDevice = CGSizeEqualToSize(UIScreen.mainScreen.nativeBounds.size, CGSizeMake(1080, 1920));
    if (shouldBeDownsampledDevice) {
        scale /= 1.15;
    }
    
    return nativeScale > scale;
}

@end
