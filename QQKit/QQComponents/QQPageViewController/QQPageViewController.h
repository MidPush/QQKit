//
//  QQPageViewController.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/12.
//

#import <UIKit/UIKit.h>
#import "QQPageTopBar.h"

/**
 一个简单的分页控制器，只能满足简单的需求。
 如果需要自定义，可以作为实现思路参考。
 */
NS_ASSUME_NONNULL_BEGIN

@class QQPageViewController;
@protocol QQPageViewControllerDelegate <NSObject>

@optional
- (void)pageViewController:(QQPageViewController *)pageViewController didSelectViewController:(UIViewController *)viewController;

@end

@interface QQPageViewController : UIViewController

@property (nonatomic, strong) QQTopBarAttributes *topBarAttributes;

@property (nullable, nonatomic) NSArray<__kindof UIViewController *> *viewControllers;

@property (nullable, nonatomic, strong, readonly) __kindof UIViewController *selectedViewController;

@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, assign) BOOL scrollAnimated;

@property (nonatomic, assign) BOOL loadAll;

@property (nullable, nonatomic, weak) id<QQPageViewControllerDelegate> delegate;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
