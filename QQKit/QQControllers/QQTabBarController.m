//
//  QQTabBarController.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "QQTabBarController.h"
#import "QQUIConfiguration.h"
#import "UITabBar+QQExtension.h"
#import "UIImage+QQExtension.h"
#import "QQUIHelper.h"

@interface QQTabBarController ()

@end

@implementation QQTabBarController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configurationTabBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

/// 配置 UITabBar
- (void)configurationTabBar {
    QQUIConfiguration *configuration = [QQUIConfiguration sharedInstance];
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithDefaultBackground];
        appearance.backgroundColor = configuration.tabBarBarTintColor;
        
        // barStyle
        appearance.backgroundEffect = [UIBlurEffect effectWithStyle:configuration.tabBarStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemChromeMaterialLight : UIBlurEffectStyleSystemChromeMaterialDark];
        
        // backgroundImage
        appearance.backgroundImage = configuration.tabBarBackgroundImage;
        
        // shadowColor
        appearance.shadowColor = configuration.tabBarShadowImageColor;
        
        // 字体颜色、icon颜色
        [appearance qq_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
            NSMutableDictionary<NSAttributedStringKey, id> *normalAttributes = itemAppearance.normal.titleTextAttributes.mutableCopy;
            normalAttributes[NSFontAttributeName] = configuration.tabBarItemTitleFont;
            normalAttributes[NSForegroundColorAttributeName] = configuration.tabBarItemTitleColor;
            
            NSMutableDictionary<NSAttributedStringKey, id> *selectedAttributes = itemAppearance.selected.titleTextAttributes.mutableCopy;
            selectedAttributes[NSFontAttributeName] = configuration.tabBarItemTitleFontSelected;
            selectedAttributes[NSForegroundColorAttributeName] = configuration.tabBarItemTitleColorSelected;
            
            itemAppearance.normal.titleTextAttributes = normalAttributes.copy;
            itemAppearance.selected.titleTextAttributes = selectedAttributes.copy;
            
            itemAppearance.normal.iconColor = configuration.tabBarItemImageColor;
            itemAppearance.selected.iconColor = configuration.tabBarItemImageColorSelected;
        }];
        
        self.tabBar.standardAppearance = appearance;
    } else {
        // barTintColor
        self.tabBar.barTintColor = configuration.tabBarBarTintColor;
        
        // barStyle
        self.tabBar.barStyle = configuration.tabBarStyle;
        
        // backgroundImage
        self.tabBar.backgroundImage = configuration.tabBarBackgroundImage;
        
        // shadowColor
        self.tabBar.shadowImage = [UIImage qq_imageWithColor:configuration.tabBarShadowImageColor size:CGSizeMake(1, [QQUIHelper pixelOne])];
        
        // 字体颜色、icon颜色
        NSMutableDictionary<NSString *, id> *normalAttributes = [[NSMutableDictionary alloc] initWithDictionary:[self.tabBarItem titleTextAttributesForState:UIControlStateNormal]];
        if (configuration.tabBarItemTitleFont) {
            normalAttributes[NSFontAttributeName] = configuration.tabBarItemTitleFont;
        }
        normalAttributes[NSForegroundColorAttributeName] = configuration.tabBarItemTitleColor;
        
        NSMutableDictionary<NSString *, id> *selectedAttributes = [[NSMutableDictionary alloc] initWithDictionary:[self.tabBarItem titleTextAttributesForState:UIControlStateSelected]];
        if (configuration.tabBarItemTitleFontSelected) {
            selectedAttributes[NSFontAttributeName] = configuration.tabBarItemTitleFontSelected;
        }
        selectedAttributes[NSForegroundColorAttributeName] = configuration.tabBarItemTitleColorSelected;
        
        [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
            [obj setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        }];
    }
    
    if (@available(iOS 10.0, *)) {
        self.tabBar.unselectedItemTintColor = configuration.tabBarItemImageColor;
        self.tabBar.tintColor = configuration.tabBarItemTitleColorSelected;
    } else {
        self.tabBar.tintColor = configuration.tabBarItemTitleColorSelected;
    }
}

#pragma mark - 状态栏
- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.selectedViewController) {
        return self.selectedViewController;
    }
    return [super childViewControllerForStatusBarHidden];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.selectedViewController) {
        return self.selectedViewController;
    }
    return [super childViewControllerForStatusBarStyle];
}

#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate {
    if (self.selectedViewController) {
        return [self.selectedViewController shouldAutorotate];
    }
    return [super shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.selectedViewController) {
        return [self.selectedViewController supportedInterfaceOrientations];
    }
    return [super supportedInterfaceOrientations];
}

#pragma mark - HomeIndicator
- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    if (self.selectedViewController) {
        return self.selectedViewController;
    }
    return [super childViewControllerForHomeIndicatorAutoHidden];
}

@end
