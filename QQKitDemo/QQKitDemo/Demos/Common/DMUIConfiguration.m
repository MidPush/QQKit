//
//  DMUIConfiguration.m
//  QQKitDemo
//
//  Created by xuze on 2021/7/1.
//

#import "DMUIConfiguration.h"

@implementation DMUIConfiguration

// QQUIConfigurationTemplateProtocol

+ (void)applyConfigurationTemplate {
    
    QQUIConfiguration *configuration = [QQUIConfiguration sharedInstance];
    
#pragma mark - 控制器
    configuration.commonViewControllerBackgroundColor = [UIColor qq_colorWithHexString:@"ededed"];
    configuration.supportedOrientationMask = UIInterfaceOrientationMaskAll;
    
#pragma mark - 导航栏（UINavigationBar）
    configuration.navBarStyle = UIBarStyleDefault;
    configuration.navBarTintColor = [UIColor qq_colorWithHexString:@"000000"];
    configuration.navBarBarTintColor = [UIColor qq_colorWithHexString:@"ededed"];
    configuration.navBarBackgroundImage = nil;
    configuration.navBarShadowImage = [UIImage qq_imageWithColor:[UIColor qq_colorWithHexString:@"e9e9e9"] size:CGSizeMake(4, [QQUIHelper pixelOne])];
    configuration.navBarTitleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor qq_colorWithHexString:@"222222"]};
    
    configuration.navBarBackImage = [UIImage imageNamed:@"nav_back_black"];
    configuration.navBarBackTitleColor = [UIColor qq_colorWithHexString:@"222222"];
    configuration.navBarBackTitleFont = [UIFont systemFontOfSize:15];
    configuration.navBarBackImageTitleSpacing = 5.0;
    configuration.navBarBackMarginOffset = 12;
    configuration.needsBackBarButtonItemTitle = NO;
    
#pragma mark - 输入框（QQTextField & QQTextView 不影响系统输入框）
    configuration.textFieldTextColor = [UIColor qq_colorWithHexString:@"222222"];
    configuration.textFieldTintColor = nil;
    configuration.textFieldPlaceholderColor = [UIColor qq_colorWithHexString:@"999999"];
    
#pragma mark - UITabBar
    configuration.tabBarBackgroundImage = nil;
    configuration.tabBarBarTintColor = [UIColor qq_colorWithHexString:@"f5f5f5"];
    configuration.tabBarShadowImageColor = [UIColor qq_colorWithHexString:@"eeeeee"];
    configuration.tabBarStyle = UIBarStyleDefault;
    
    configuration.tabBarItemTitleFont = [UIFont systemFontOfSize:10];
    configuration.tabBarItemTitleFontSelected = [UIFont systemFontOfSize:10];
    configuration.tabBarItemTitleColor = [UIColor qq_colorWithHexString:@"222222"];
    configuration.tabBarItemTitleColorSelected = [UIColor qq_colorWithHexString:@"00CC68"];
    configuration.tabBarItemImageColor = [UIColor qq_colorWithHexString:@"222222"];
    configuration.tabBarItemImageColorSelected = [UIColor qq_colorWithHexString:@"00CC68"];
    
#pragma mark - TableView & TableViewCell
    configuration.tableViewBackgroundColor = nil;
    configuration.cellSelectedBackgroundColor = [UIColor qq_colorWithHexString:@"eeeff1"];
    
#pragma mark - QQButton & QQGhostButton & QQFillButton
    configuration.buttonGhostColor = nil;
    configuration.buttonFillColor = nil;
    
#pragma mark - 其他（Others）
    configuration.fullScreenPopGestureEnabled = YES;
    
}

@end
