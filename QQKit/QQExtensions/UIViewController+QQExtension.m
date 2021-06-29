//
//  UIViewController+QQExtension.m
//  PinHuoHuo
//
//  Created by Mac on 2021/6/10.
//

#import "UIViewController+QQExtension.h"

@implementation UIViewController (QQExtension)

- (UIViewController *)qq_visibleViewController {
    if (self.presentedViewController) {
        return [self.presentedViewController qq_visibleViewController];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).visibleViewController qq_visibleViewController];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController qq_visibleViewController];
    }
    
    if (self.isViewLoaded) {
        return self;
    }
    
    return nil;
}

@end
