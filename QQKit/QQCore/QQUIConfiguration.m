//
//  QQUIConfiguration.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/13.
//

#import "QQUIConfiguration.h"

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
    self.commonViewContorllerBackgroundColor = [UIColor whiteColor];
    self.supportedOrientationMask = UIInterfaceOrientationMaskAll;
    
#pragma mark - 导航栏（UINavigationBar）
    self.navBarStyle = UIBarStyleDefault;
    self.navBarTintColor = nil;
    self.navBarBarTintColor = nil;
    self.navBarBackgroundImage = nil;
    self.navBarShadowImage = nil;
    self.navBarTitleTextAttributes = nil;
    
    self.navBarBackImage = nil;
    self.navBarBackTitleColor = nil;
    self.navBarBackTitleFont = [UIFont systemFontOfSize:15];
    self.navBarBackImageTitleSpacing = 5.0;
    self.navBarBackMarginOffset = 12;
    self.needsBackBarButtonItemTitle = NO;
    
#pragma mark - 输入框（QQTextField & QQTextView 不影响系统输入框）
    self.textFieldTextColor = nil;
    self.textFieldTintColor = nil;
    self.textFieldPlaceholderColor = nil;
    
#pragma mark - UITabBar
    self.tabBarBackgroundImage = nil;
    self.tabBarBarTintColor = nil;
    self.tabBarShadowImageColor = nil;
    self.tabBarStyle = UIBarStyleDefault;
    
    self.tabBarItemTitleFont = [UIFont systemFontOfSize:10];
    self.tabBarItemTitleFontSelected = [UIFont systemFontOfSize:10];
    self.tabBarItemTitleColor = nil;
    self.tabBarItemTitleColorSelected = nil;
    self.tabBarItemImageColor = nil;
    self.tabBarItemImageColorSelected = nil;
    
#pragma mark - TableView & TableViewCell
    self.tableViewBackgroundColor = nil;
    self.cellSelectedBackgroundColor = nil;
    
#pragma mark - QQButton & QQGhostButton & QQFillButton
    self.buttonGhostColor = nil;
    self.buttonFillColor = nil;
    
#pragma mark - 其他（Others）
    self.fullScreenPopGestureEnabled = YES;
    
}

@end
