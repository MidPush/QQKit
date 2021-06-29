//
//  QQUIHelper.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QQUIHelper : NSObject

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

/// 设备宽度，跟横竖屏无关
+ (CGFloat)deviceHeight;

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

@end


