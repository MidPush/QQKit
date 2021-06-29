//
//  AppDelegate.m
//  QQKitDemo
//
//  Created by Mac on 2021/6/29.
//

#import "AppDelegate.h"
#import "DMTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DMTabBarController *mainVC = [[DMTabBarController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
