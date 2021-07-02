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
        return [tabBarButton qq_valueForKey:@"_imageView"];
    }
    return [tabBarButton qq_valueForKey:@"_info"];
}

@end
