//
//  QQActivityIndicatorView.h
//  QQKitDemo
//
//  Created by Mac on 2021/5/19.
//

#import <UIKit/UIKit.h>

/**
 自己实现系统的 UIActivityIndicatorView（iOS 13 之前的风格）
 iOS 13 后 UIActivityIndicatorView 风格改变
 如果希望使用以前的风格，可以使用 QQActivityIndicatorView
 */
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QQActivityIndicatorViewStyle) {
    QQActivityIndicatorViewStyleWhiteLarge = 0,
    QQActivityIndicatorViewStyleWhite = 1,
    QQActivityIndicatorViewStyleGray = 2,
};

@interface QQActivityIndicatorView : UIView

- (instancetype)initWithActivityIndicatorStyle:(QQActivityIndicatorViewStyle)style;
   
@property (nonatomic, assign) QQActivityIndicatorViewStyle activityIndicatorViewStyle;
@property (nonatomic, assign) BOOL                         hidesWhenStopped;

@property (null_resettable, readwrite, nonatomic, strong) UIColor *color;

- (void)startAnimating;
- (void)stopAnimating;
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

@end

NS_ASSUME_NONNULL_END
