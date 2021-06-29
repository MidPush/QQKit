//
//  UIColor+QQKitDemo.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (QQKitDemo)

/// App里面常用的颜色
@property (class, nonatomic, strong, readonly) UIColor *dm_whiteColor;
@property (class, nonatomic, strong, readonly) UIColor *dm_blackColor;

@property (class, nonatomic, strong, readonly) UIColor *dm_backgroundColor;
@property (class, nonatomic, strong, readonly) UIColor *dm_tintColor;
@property (class, nonatomic, strong, readonly) UIColor *dm_mainTextColor;
@property (class, nonatomic, strong, readonly) UIColor *dm_whiteTextColor;
@property (class, nonatomic, strong, readonly) UIColor *dm_mainGrayColor;
@property (class, nonatomic, strong, readonly) UIColor *dm_lightGrayColor;
@property (class, nonatomic, strong, readonly) UIColor *dm_separatorColor;
@property (class, nonatomic, strong, readonly) UIColor *dm_placeholderColor;

@property (class, nonatomic, strong, readonly) UIColor *dm_highlightedColor;
@property (class, nonatomic, strong, readonly) UIColor *dm_disabledColor;

@end

NS_ASSUME_NONNULL_END
