//
//  QQCropOverlayView.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQCropOverlayView : UIView

/// 隐藏和显示内部网格线，无动画。
@property (nonatomic, assign) BOOL gridHidden;

/// 隐藏和显示内部网格线，animated是否使用动画。
- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
