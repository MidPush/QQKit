//
//  DMUITabBarItemViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/20.
//

#import "DMUITabBarItemViewController.h"
#import "UITabBarItem+QQExtension.h"

@interface DMUITabBarItemViewController ()

@property (nonatomic, strong) QQFillButton *button;
@property (nonatomic, strong) UITabBar *tabBar;

@end

@implementation DMUITabBarItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initSubviews {
    
    self.button = [[QQFillButton alloc] initWithFillColor:UIColor.dm_tintColor titleTextColor:UIColor.dm_whiteColor];
    self.button.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.button setTitle:@"获取 UITabBarItem 上的 imageView" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(onButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    self.tabBar = [[UITabBar alloc] init];
    
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"QQKit" image:[UIImage imageNamed:@"icon_tabbar_uikit"] selectedImage:[UIImage imageNamed:@"icon_tabbar_uikit_selected"]];
    
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"Components" image:[UIImage imageNamed:@"icon_tabbar_component"] selectedImage:[UIImage imageNamed:@"icon_tabbar_component_selected"]];
    
    UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"Others" image:[UIImage imageNamed:@"icon_tabbar_lab"] selectedImage:[UIImage imageNamed:@"icon_tabbar_lab_selected"]];
    
    self.tabBar.items = @[item1, item2, item3];
    self.tabBar.selectedItem = item1;
    [self.view addSubview:self.tabBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.button.frame = CGRectMake((self.view.qq_width - 300) / 2, QQUIHelper.navigationBarMaxY + 60, 300, 40);
    
    CGFloat tabBarHeight = QQUIHelper.tabBarHeight;
    self.tabBar.frame = CGRectMake(0, self.view.qq_height - tabBarHeight, self.view.qq_width, tabBarHeight);
}

- (void)onButtonClicked {
    UIImageView *imageView = self.tabBar.selectedItem.qq_imageView;
    if (imageView) {
        [UIView animateWithDuration:.25 delay:0 usingSpringWithDamping:.1 initialSpringVelocity:5 options:0 animations:^{
            imageView.transform = CGAffineTransformMakeScale(1.4, 1.4);
        } completion:^(BOOL finished) {
            imageView.transform = CGAffineTransformIdentity;
        }];
    }
}

@end
