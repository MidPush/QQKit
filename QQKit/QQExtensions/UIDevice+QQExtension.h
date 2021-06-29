//
//  UIDevice+QQExtension.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (QQExtension)

/// 设备系统版本
@property (class, nonatomic, readonly) NSString *systemVersion;

/// 如 iPhone12,5、iPad6,8
@property (class, nonatomic, readonly) NSString *deviceModel;

/// 如 iPhone 11 Pro Max、iPad Pro (12.9 inch)，如果是模拟器，会在后面带上“ Simulator”字样。
@property (class, nonatomic, readonly) NSString *deviceName;

@property (class, nonatomic, assign, readonly) BOOL isIPad;
@property (class, nonatomic, assign, readonly) BOOL isIPod;
@property (class, nonatomic, assign, readonly) BOOL isIPhone;
@property (class, nonatomic, assign, readonly) BOOL isSimulator;
@property (class, nonatomic, assign, readonly) BOOL isMac;

/// 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备
@property (class, nonatomic, readonly) BOOL isNotchedScreen;

/// iPhone 12 / 12 Pro
@property (class, nonatomic, readonly) BOOL is61InchScreenAndiPhone12;

/// iPhone 12 Pro Max
@property (class, nonatomic, readonly) BOOL is67InchScreen;

/// 用于获取 isNotchedScreen 设备的 insets，注意对于 iPad Pro 11-inch 这种无刘海凹槽但却有使用 Home Indicator 的设备，它的 top 返回0，bottom 返回 safeAreaInsets.bottom 的值
@property (class, nonatomic, readonly) UIEdgeInsets deviceSafeAreaInsets;

/// 系统设置里是否开启了“放大显示-试图-放大”，支持放大模式的 iPhone 设备可在官方文档中查询 https://support.apple.com/zh-cn/guide/iphone/iphd6804774e/ios
@property (class, nonatomic, readonly) BOOL isZoomedMode;

@end

NS_ASSUME_NONNULL_END
