//
//  DMTabBarController.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/14.
//

#import "DMTabBarController.h"
#import "DMNavigationController.h"
#import "DMUIKitViewController.h"
#import "DMComponentsViewController.h"
#import "DMOthersViewController.h"
#import "UITabBarItem+QQExtension.h"
#import "QQAssetsPickerHelper.h"

@interface DMTabBarController ()<UITabBarControllerDelegate>

@end

@implementation DMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self initChildViewControllers];
}

- (void)initChildViewControllers {
    
    // QMUIKit
    DMUIKitViewController *uikitViewController = [[DMUIKitViewController alloc] init];
    uikitViewController.hidesBottomBarWhenPushed = NO;
    DMNavigationController *uikitNavController = [[DMNavigationController alloc] initWithRootViewController:uikitViewController];
    [self setupChildViewController:uikitNavController title:@"QQKit" imageName:@"icon_tabbar_uikit" selectedImageName:@"icon_tabbar_uikit_selected"];
    
    // UIComponents
    DMComponentsViewController *componentViewController = [[DMComponentsViewController alloc] init];
    DMNavigationController *componentNavController = [[DMNavigationController alloc] initWithRootViewController:componentViewController];
    [self setupChildViewController:componentNavController title:@"Components" imageName:@"icon_tabbar_component" selectedImageName:@"icon_tabbar_component_selected"];
    
    // Lab
    DMOthersViewController *labViewController = [[DMOthersViewController alloc] init];
    DMNavigationController *labNavController = [[DMNavigationController alloc] initWithRootViewController:labViewController];
    [self setupChildViewController:labNavController title:@"Others" imageName:@"icon_tabbar_lab" selectedImageName:@"icon_tabbar_lab_selected"];
    
    self.viewControllers = @[uikitNavController, componentNavController, labNavController];
}

- (void)setupChildViewController:(UIViewController *)childVC title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image = [UIImage imageNamed:imageName];
    childVC.tabBarItem.selectedImage = [UIImage imageNamed:selectedImageName];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [QQAssetsPickerHelper springAnimationForView:viewController.tabBarItem.qq_imageView];
    return YES;
}

@end
