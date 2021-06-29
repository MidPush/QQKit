//
//  UINavigationBar+QQExtension.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationBar (QQExtension)

/**
 UINavigationBar 的背景 view，可能显示磨砂、背景图，顶部有一部分溢出到 UINavigationBar 外。
 在 iOS 10 及以后是私有的 _UIBarBackground 类。

 在 iOS 9 及以前是私有的 _UINavigationBarBackground 类。
 */
@property (nonatomic, strong, readonly, nullable) UIView *qq_backgroundView;

/**
 qq_backgroundView 内的 subview，用于显示底部分隔线 shadowImage，注意这个 view 是溢出到 qq_backgroundView 外的。若 shadowImage 为 [UIImage new]，则这个 view 的高度为 0。
 */
@property (nonatomic, strong, readonly, nullable) UIImageView *qq_shadowImageView;

@end

NS_ASSUME_NONNULL_END
