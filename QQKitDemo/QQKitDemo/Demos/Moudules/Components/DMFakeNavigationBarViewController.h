//
//  DMFakeNavigationBarViewController.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "DMViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DMNavigationBarStyle) {
    DMNavigationBarStyleOrigin,
    DMNavigationBarStyleRed,
    DMNavigationBarStyleDark,
    DMNavigationBarStyleHideBar,
};

@interface DMFakeNavigationBarViewController : DMViewController

@property(nonatomic, assign) DMNavigationBarStyle barStyle;

@end

NS_ASSUME_NONNULL_END
