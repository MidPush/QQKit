//
//  UIView+QQExtension.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (QQExtension)

// Layout
@property (nonatomic, assign) CGFloat qq_top;
@property (nonatomic, assign) CGFloat qq_bottom;

@property (nonatomic, assign) CGFloat qq_left;
@property (nonatomic, assign) CGFloat qq_right;

@property (nonatomic, assign) CGFloat qq_width;
@property (nonatomic, assign) CGFloat qq_height;

@property (nonatomic, assign) CGFloat qq_centerX;
@property (nonatomic, assign) CGFloat qq_centerY;

/**
 在 iOS 11 及之后的版本，此属性将返回系统已有的 self.safeAreaInsets。在之前的版本此属性返回 UIEdgeInsetsZero
 */
@property(nonatomic, assign, readonly) UIEdgeInsets qq_safeAreaInsets;

/**
 获取当前 UIView 所在的控制器，可能为空
 最好不要经常用，会使代码逻辑很乱。
 */
- (nullable UIViewController *)qq_viewController;

@end

NS_ASSUME_NONNULL_END
