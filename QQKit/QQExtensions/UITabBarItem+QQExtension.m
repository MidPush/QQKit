//
//  UITabBarItem+QQExtension.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/20.
//

#import "UITabBarItem+QQExtension.h"
#import "NSObject+QQExtension.h"

@implementation UITabBarItem (QQExtension)

- (UIImageView *)qq_imageView {
    if ([self respondsToSelector:@selector(view)]) {
        UIView *tabBarButton = [self qq_valueForKey:@"view"];
        return [self.class qq_imageViewInTabBarButton:tabBarButton];
    }
    return nil;
}

+ (UIImageView *)qq_imageViewInTabBarButton:(UIView *)tabBarButton {
    if (!tabBarButton) {
        return nil;
    }
    
    if (@available(iOS 13.0, *)) {
        if ([tabBarButton.subviews.firstObject isKindOfClass:[UIVisualEffectView class]] && ((UIVisualEffectView *)tabBarButton.subviews.firstObject).contentView.subviews.count) {
            // iOS 13 下如果 tabBar 是磨砂的，则每个 button 内部都会有一个磨砂，而磨砂再包裹了 imageView、label 等 subview，但某些时机后系统又会把 imageView、label 挪出来放到 button 上，所以这里做个保护
            
            UIView *contentView = ((UIVisualEffectView *)tabBarButton.subviews.firstObject).contentView;
            // iOS 13 beta5 布局发生了变化，即使有磨砂 view，内部也不一定包裹着 imageView
            for (UIView *subview in contentView.subviews) {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITabBarSwappableImageView"]) {
                    return (UIImageView *)subview;
                }
            }
        }
    }
    
    for (UIView *subview in tabBarButton.subviews) {
        // iOS10及以后，imageView都是用UITabBarSwappableImageView实现的，所以遇到这个class就直接拿
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITabBarSwappableImageView"]) {
            return (UIImageView *)subview;
        }
    }
    
    // 如果用户设置系统开启按钮形状功能，会多一个 UIImageView 指示器，所以先完全遍历，没有 UITabBarSwappableImageView 才来到此遍历
    for (UIView *subview in tabBarButton.subviews) {
        // iOS10以前，选中的item的高亮是用UITabBarSelectionIndicatorView实现的，所以要屏蔽掉
        if ([subview isKindOfClass:[UIImageView class]] && ![NSStringFromClass([subview class]) isEqualToString:@"UITabBarSelectionIndicatorView"]) {
            return (UIImageView *)subview;
        }
    }
    
    return nil;
}

@end
