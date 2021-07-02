//
//  QQKit.h
//  QQKitDemo
//
//  Created by Mac on 2021/6/29.
//

#import <UIKit/UIKit.h>

#ifndef QQKit_h
#define QQKit_h

static NSString * const QQKIT_VERSION = @"1.0.0";

/// Core
#if __has_include("QQRuntime.h")
#import "QQRuntime.h"
#endif

#if __has_include("QQUIConfiguration.h")
#import "QQUIConfiguration.h"
#endif

#if __has_include("QQUIHelper.h")
#import "QQUIHelper.h"
#endif

/// QQExtensions
#if __has_include("NSDate+QQExtension.h")
#import "NSDate+QQExtension.h"
#endif

#if __has_include("NSException+QQExtension.h")
#import "NSException+QQExtension.h"
#endif

#if __has_include("NSObject+QQExtension.h")
#import "NSObject+QQExtension.h"
#endif

#if __has_include("NSString+QQExtension.h")
#import "NSString+QQExtension.h"
#endif

#if __has_include("UIBarButtonItem+QQExtension.h")
#import "UIBarButtonItem+QQExtension.h"
#endif

#if __has_include("UIColor+QQExtension.h")
#import "UIColor+QQExtension.h"
#endif

#if __has_include("UIDevice+QQExtension.h")
#import "UIDevice+QQExtension.h"
#endif

#if __has_include("UIImage+QQExtension.h")
#import "UIImage+QQExtension.h"
#endif

#if __has_include("UINavigationBar+QQExtension.h")
#import "UINavigationBar+QQExtension.h"
#endif

#if __has_include("UIScrollView+QQExtension.h")
#import "UIScrollView+QQExtension.h"
#endif

#if __has_include("UITabBar+QQExtension.h")
#import "UITabBar+QQExtension.h"
#endif

#if __has_include("UITabBarItem+QQExtension.h")
#import "UITabBarItem+QQExtension.h"
#endif

#if __has_include("UIView+QQExtension.h")
#import "UIView+QQExtension.h"
#endif

#if __has_include("UIViewController+QQExtension.h")
#import "UIViewController+QQExtension.h"
#endif

/// QQControllers
#if __has_include("QQViewController.h")
#import "QQViewController.h"
#endif

#if __has_include("QQNavigationController.h")
#import "QQNavigationController.h"
#endif

#if __has_include("QQTabBarController.h")
#import "QQTabBarController.h"
#endif

#if __has_include("QQViewController.h")
#import "QQViewController.h"
#endif

/// Views
#if __has_include("QQButton.h")
#import "QQButton.h"
#endif

#if __has_include("QQFillButton.h")
#import "QQFillButton.h"
#endif

#if __has_include("QQGhostButton.h")
#import "QQGhostButton.h"
#endif

#if __has_include("QQNavigationButton.h")
#import "QQNavigationButton.h"
#endif

#if __has_include("QQCollectionView.h")
#import "QQCollectionView.h"
#endif

#if __has_include("QQCollectionViewCell.h")
#import "QQCollectionViewCell.h"
#endif

#if __has_include("QQLabel.h")
#import "QQLabel.h"
#endif

#if __has_include("QQScrollView.h")
#import "QQScrollView.h"
#endif

#if __has_include("QQSearchBar.h")
#import "QQSearchBar.h"
#endif

#if __has_include("QQTableView.h")
#import "QQTableView.h"
#endif

#if __has_include("QQTableViewCell.h")
#import "QQTableViewCell.h"
#endif

#if __has_include("QQTextField.h")
#import "QQTextField.h"
#endif

#if __has_include("QQTextView.h")
#import "QQTextView.h"
#endif

#if __has_include("QQActivityIndicatorView.h")
#import "QQActivityIndicatorView.h"
#endif

/// QQComponents
#if __has_include("QQAssetPickerController.h")
#import "QQAssetPickerController.h"
#endif

#if __has_include("UIView+QQBadge.h")
#import "UIView+QQBadge.h"
#endif

#if __has_include("QQCircularProgressView.h")
#import "QQCircularProgressView.h"
#endif

#if __has_include("UIViewController+QQFakeNavigationBar.h")
#import "UIViewController+QQFakeNavigationBar.h"
#endif

#if __has_include("QQPageViewController.h")
#import "QQPageViewController.h"
#endif

#if __has_include("QQProgressHUD.h")
#import "QQProgressHUD.h"
#endif

#if __has_include("QQToast.h")
#import "QQToast.h"
#endif

#endif /* QQKit_h */
