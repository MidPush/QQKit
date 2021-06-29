//
//  QQCircularProgressView.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/16.
//

#import <UIKit/UIKit.h>

/**
 QQCircularProgressView 是 第三方库 DACircularProgressView 的修改版
 源码地址：https://github.com/danielamitay/DACircularProgress
 */
NS_ASSUME_NONNULL_BEGIN

@interface QQCircularProgressView : UIView

@property (nonatomic, strong, nullable) UIColor *trackTintColor;
@property (nonatomic, strong, nullable) UIColor *progressTintColor;
@property (nonatomic, strong, nullable) UIColor *innerTintColor;

@property (nonatomic, assign) BOOL roundedCorners;
@property (nonatomic, assign) BOOL clockwise;

@property (nonatomic, assign) BOOL indeterminate;
@property (nonatomic, assign) NSTimeInterval indeterminateDuration;

@property (nonatomic, assign) CGFloat thicknessRatio;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UILabel *progressLabel;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
