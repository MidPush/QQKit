//
//  UIViewController+QQExtension.h
//  PinHuoHuo
//
//  Created by Mac on 2021/6/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (QQExtension)

/**
 *  获取当前controller里的最高层可见viewController
 */
- (nullable UIViewController *)qq_visibleViewController;

@end

NS_ASSUME_NONNULL_END
