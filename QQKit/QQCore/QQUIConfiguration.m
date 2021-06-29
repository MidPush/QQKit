//
//  QQUIConfiguration.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/13.
//

#import "QQUIConfiguration.h"
#import "UIColor+QQExtension.h"
#import "UIImage+QQExtension.h"
#import "QQUIHelper.h"

@implementation QQUIConfiguration

+ (void)load {
    [self sharedInstance];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static QQUIConfiguration *sharedInstance;
    dispatch_once(&pred, ^{
        sharedInstance = [[QQUIConfiguration alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initDefaultConfiguration];
    }
    return self;
}

- (void)applyTemplate:(Class<QQUIConfigurationTemplateProtocol>)cls {
    if ([cls respondsToSelector:@selector(applyConfigurationTemplate)]) {
        [cls applyConfigurationTemplate];
    }
}

- (void)initDefaultConfiguration {
    
#pragma mark - 控制器
    self.commonViewContorllerBackgroundColor = [UIColor qq_colorWithHexString:@"ededed"];
    self.supportedOrientationMask = UIInterfaceOrientationMaskAll;
    
#pragma mark - 导航栏（UINavigationBar）
    self.navBarStyle = UIBarStyleDefault;
    self.navBarTintColor = [UIColor qq_colorWithHexString:@"000000"];
    self.navBarBarTintColor = [UIColor qq_colorWithHexString:@"ededed"];
    self.navBarBackgroundImage = nil;
    self.navBarShadowImage = [UIImage qq_imageWithColor:[UIColor qq_colorWithHexString:@"e9e9e9"] size:CGSizeMake(4, [QQUIHelper pixelOne])];
    self.navBarTitleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor qq_colorWithHexString:@"222222"]};
    
    self.navBarBackImage = [UIImage imageNamed:@"nav_back_black"];
    self.navBarBackTitleColor = [UIColor qq_colorWithHexString:@"222222"];
    self.navBarBackTitleFont = [UIFont systemFontOfSize:15];
    self.navBarBackImageTitleSpacing = 5.0;
    self.navBarBackMarginOffset = 12;
    self.needsBackBarButtonItemTitle = NO;
    
#pragma mark - 输入框（QQTextField & QQTextView 不影响系统输入框）
    self.textFieldTextColor = [UIColor qq_colorWithHexString:@"222222"];
    self.textFieldTintColor = nil;
    self.textFieldPlaceholderColor = [UIColor qq_colorWithHexString:@"999999"];
    
#pragma mark - UITabBar
    self.tabBarBackgroundImage = nil;
    self.tabBarBarTintColor = [UIColor qq_colorWithHexString:@"f5f5f5"];
    self.tabBarShadowImageColor = [UIColor qq_colorWithHexString:@"eeeeee"];
    self.tabBarStyle = UIBarStyleDefault;
    
    self.tabBarItemTitleFont = [UIFont systemFontOfSize:10];
    self.tabBarItemTitleFontSelected = [UIFont systemFontOfSize:10];
    self.tabBarItemTitleColor = [UIColor qq_colorWithHexString:@"222222"];
    self.tabBarItemTitleColorSelected = [UIColor qq_colorWithHexString:@"00CC68"];
    self.tabBarItemImageColor = [UIColor qq_colorWithHexString:@"222222"];
    self.tabBarItemImageColorSelected = [UIColor qq_colorWithHexString:@"00CC68"];
    
#pragma mark - TableView & TableViewCell
    self.tableViewBackgroundColor = nil;
    self.cellSelectedBackgroundColor = [UIColor qq_colorWithHexString:@"eeeff1"];
    
#pragma mark - QQButton & QQGhostButton & QQFillButton
    self.buttonGhostColor = nil;
    self.buttonFillColor = nil;
    
#pragma mark - 其他（Others）
    self.fullScreenPopGestureEnabled = YES;
    
}

@end
