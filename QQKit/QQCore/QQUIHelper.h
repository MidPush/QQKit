//
//  QQUIHelper.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QQUIHelper : NSObject

/// 单例
+ (instancetype)sharedInstance;

#pragma mark - UI相关

/// 获取一个像素
+ (CGFloat)pixelOne;

/// 是否横竖屏，用户界面横屏了才会返回YES
+ (BOOL)isLandscape;

/// 屏幕宽度，会根据横竖屏的变化而变化
+ (CGFloat)screenWidth;

/// 屏幕高度，会根据横竖屏的变化而变化
+ (CGFloat)screenHeight;

/// 设备宽度，跟横竖屏无关
+ (CGFloat)deviceWidth;

/// 设备高度，跟横竖屏无关
+ (CGFloat)deviceHeight;

/// 设备 safeAreaInsets
+ (UIEdgeInsets)deviceSafeAreaInsets;

/// 屏幕scale
+ (CGFloat)screenScale;

/// 状态栏高度(来电等情况下，状态栏高度会发生变化，所以应该实时计算，iOS 13 起，来电等情况下状态栏高度不会改变)
+ (CGFloat)statusBarHeight;

/// 状态栏高度(如果状态栏不可见，也会返回一个普通状态下可见的高度)
+ (CGFloat)statusBarHeightConstant;

/// 导航栏的静态高度，有新设备时可能需要更新
+ (CGFloat)navigationBarHeight;

/// 导航栏 MaxY，有新设备时可能需要更新
+ (CGFloat)navigationBarMaxY;

/// tabBar的静态高度，如果是 NotchedScreen 设备会加上设备的 safeAreaInsets.bottom 值，有新设备时可能需要更新
+ (CGFloat)tabBarHeight;

/// 是否是小屏幕，屏幕宽 <= 320
+ (BOOL)isSmallScreen;

/// 是否是中屏幕，屏幕宽 > 320 && <=375
+ (BOOL)isMiddleScreen;

/// 是否是大屏幕，屏幕宽 > 375
+ (BOOL)isBigScreen;

#pragma mark - 屏幕旋转

/// 记录手动旋转方向前的设备方向，当值不为 UIDeviceOrientationUnknown 时表示设备方向有经过了手动调整。默认值为 UIDeviceOrientationUnknown。
@property (nonatomic, assign) UIDeviceOrientation beforeChangingOrientation;

/// 旋转当前设备的方向到指定方向
+ (BOOL)rotateDeviceToOrientation:(UIDeviceOrientation)orientation;

/// 将一个 UIInterfaceOrientationMask 转换成对应的 UIDeviceOrientation
+ (UIDeviceOrientation)deviceOrientationWithInterfaceOrientationMask:(UIInterfaceOrientationMask)mask;

/// 判断一个 UIInterfaceOrientationMask 是否包含某个给定的 UIDeviceOrientation 方向
+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

/// 判断一个 UIInterfaceOrientationMask 是否包含某个给定的 UIInterfaceOrientation 方向
+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

#pragma mark - App信息
/// 应用名称
+ (NSString *)appName;

/// 版本号（eg：1.0.0）
+ (NSString *)appVersion;

/// build版本（eg：101）
+ (NSString *)appBuildVersion;

@end

#pragma mark - 一些自定义函数

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
CG_INLINE CGFloat flatSpecificScale(CGFloat floatValue, CGFloat scale) {
    floatValue = (floatValue == CGFLOAT_MIN ? 0 : floatValue);
    scale = scale ?: [UIScreen mainScreen].scale;
    CGFloat flattedValue = ceil(floatValue * scale) / scale;
    return flattedValue;
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
CG_INLINE CGFloat flat(CGFloat floatValue) {
    return flatSpecificScale(floatValue, 0);
}

/// 创建一个像素对齐的CGRect
CG_INLINE CGRect CGRectFlatMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    return CGRectMake(flat(x), flat(y), flat(width), flat(height));
}
