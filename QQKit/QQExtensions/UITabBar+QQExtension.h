//
//  UITabBar+QQExtension.h
//  QQKitDemo
//
//  Created by xuze on 2021/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (QQExtension)

/**
 UITabBar 的背景 view，可能显示磨砂、背景图，顶部有一部分溢出到 UITabBar 外。
 在 iOS 10 及以后是私有的 _UIBarBackground 类。
 在 iOS 9 及以前是私有的 _UITabBarBackgroundView 类。
 */
@property (nonatomic, strong, readonly, nullable) UIView *qq_backgroundView;

/**
 UITabBar 顶部分隔线 shadowImage
 */
@property (nonatomic, strong, readonly, nullable) UIImageView *qq_shadowImageView;

@end

@interface UITabBarAppearance (QQExtension)

/**
 同时设置 stackedLayoutAppearance、inlineLayoutAppearance、compactInlineLayoutAppearance 三个状态下的 itemAppearance
 */
- (void)qq_applyItemAppearanceWithBlock:(void (^)(UITabBarItemAppearance *itemAppearance))block;

@end

NS_ASSUME_NONNULL_END
