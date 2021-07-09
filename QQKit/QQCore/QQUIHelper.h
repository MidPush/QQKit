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

/// 导航栏的静态高度
+ (CGFloat)navigationBarHeight;

/// 导航栏 MaxY
+ (CGFloat)navigationBarMaxY;

/// tabBar的静态高度，如果是 NotchedScreen 设备会加上设备的 safeAreaInsets.bottom 值
+ (CGFloat)tabBarHeight;


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

@end


