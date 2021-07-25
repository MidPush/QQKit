//
//  UINavigationBarAppearanceProtocol.h
//  NNKit
//
//  Created by Mac on 2021/3/1.
//

#import <UIKit/UIKit.h>

/**
 设置导航栏的外观
 最好通过此协议方法设置导航栏的外观，否则在某些时机设置外观，可能会出现错误。
 */
@protocol UINavigationBarAppearanceProtocol <NSObject>

@optional

/// 设置导航栏是否隐藏
- (BOOL)prefersNavigationBarHidden;

/// 设置导航栏的 barStyle
- (UIBarStyle)navBarBarStyle;

/// 设置导航栏的背景图
- (UIImage *)navBarBackgroundImage;

/// 设置导航栏底部的分隔线图片，必须在 navigationBar 设置了背景图后才有效（系统限制如此）
- (UIImage *)navBarShadowImage;

/// 设置导航栏的 tintColor
- (UIColor *)navBarTintColor;

/// 设置导航栏的 barTintColor
- (UIColor *)navBarBarTintColor;

/// 设置导航栏的 title
- (NSDictionary<NSAttributedStringKey, id> *)navBarTitleTextAttributes;

@end
