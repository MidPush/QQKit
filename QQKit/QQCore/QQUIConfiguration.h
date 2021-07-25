//
//  QQUIConfiguration.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QQUIConfigurationTemplateProtocol <NSObject>

@required
+ (void)applyConfigurationTemplate;

@end

@interface QQUIConfiguration : NSObject

#pragma mark - 单例
+ (instancetype)sharedInstance;
- (void)applyTemplate:(Class<QQUIConfigurationTemplateProtocol>)cls;

#pragma mark - 控制器（只作用于QQViewController）
@property (nonatomic, strong, nullable) UIColor *commonViewControllerBackgroundColor;
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;

#pragma mark - 导航栏（UINavigationBar 只作用于QQNavigationController）
@property (nonatomic, assign)           UIBarStyle   navBarStyle;
@property (nonatomic, strong, nullable) UIColor      *navBarTintColor;
@property (nonatomic, strong, nullable) UIColor      *navBarBarTintColor;
@property (nonatomic, strong, nullable) UIImage      *navBarShadowImage;
@property (nonatomic, strong, nullable) UIImage      *navBarBackgroundImage;
@property (nonatomic, strong, nullable) NSDictionary *navBarTitleTextAttributes;

// 导航栏返回按钮 LeftBarButtonItem
@property (nonatomic, strong, nullable) UIImage *navBarBackImage;
@property (nonatomic, strong, nullable) UIColor *navBarBackTitleColor;
@property (nonatomic, strong, nullable) UIFont  *navBarBackTitleFont;
@property (nonatomic, assign)           CGFloat navBarBackImageTitleSpacing;
@property (nonatomic, assign)           CGFloat navBarBackMarginOffset;
@property (nonatomic, assign)           BOOL    needsBackBarButtonItemTitle;

#pragma mark - 输入框（QQTextField & QQTextView 不影响系统输入框）
@property (nonatomic, strong, nullable) UIColor *textFieldTextColor;
@property (nonatomic, strong, nullable) UIColor *textFieldTintColor;
@property (nonatomic, strong, nullable) UIColor *textFieldPlaceholderColor;

#pragma mark - UITabBar
@property (nonatomic, strong, nullable) UIImage *tabBarBackgroundImage;
@property (nonatomic, strong, nullable) UIColor *tabBarBarTintColor;
@property (nonatomic, strong, nullable) UIColor *tabBarShadowImageColor;
@property (nonatomic, assign)           UIBarStyle tabBarStyle;

@property (nonatomic, strong, nullable) UIFont  *tabBarItemTitleFont;
@property (nonatomic, strong, nullable) UIFont  *tabBarItemTitleFontSelected;
@property (nonatomic, strong, nullable) UIColor *tabBarItemTitleColor;
@property (nonatomic, strong, nullable) UIColor *tabBarItemTitleColorSelected;
@property (nonatomic, strong, nullable) UIColor *tabBarItemImageColor;
@property (nonatomic, strong, nullable) UIColor *tabBarItemImageColorSelected;

#pragma mark - QQTableView & QQTableViewCell
@property (nonatomic, strong, nullable) UIColor *tableViewBackgroundColor;
@property (nonatomic, strong, nullable) UIColor *cellSelectedBackgroundColor;

#pragma mark - QQGhostButton & QQFillButton
@property (nonatomic, strong, nullable) UIColor *buttonGhostColor;
@property (nonatomic, strong, nullable) UIColor *buttonFillColor;

#pragma mark - 其他（Others）
@property (nonatomic, assign) BOOL fullScreenPopGestureEnabled;

@end

NS_ASSUME_NONNULL_END
