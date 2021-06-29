//
//  UITabBarItem+QQExtension.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBarItem (QQExtension)

/// 获取一个UITabBarItem内显示图标的UIImageView，如果找不到则返回nil
- (nullable UIImageView *)qq_imageView;

/// 获取一个UITabBarItem内显示图标的UIImageView，如果找不到则返回nil
+ (nullable UIImageView *)qq_imageViewInTabBarButton:(UIView *)tabBarButton;

@end

NS_ASSUME_NONNULL_END
