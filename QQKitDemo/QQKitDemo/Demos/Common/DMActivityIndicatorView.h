//
//  DMActivityIndicatorView.h
//  QQKitDemo
//
//  Created by Mac on 2021/5/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DMActivityIndicatorViewStyle) {
    DMActivityIndicatorViewStyleWhiteLarge,
    DMActivityIndicatorViewStyleWhite,
    DMActivityIndicatorViewStyleGray
};


static CGSize DMActivityIndicatorViewStyleSize(DMActivityIndicatorViewStyle style) {
    if (style == DMActivityIndicatorViewStyleWhiteLarge) {
        return CGSizeMake(37, 37);
    } else {
        return CGSizeMake(20, 20);
    }
}

static UIImage *DMActivityIndicatorViewFrameImage(DMActivityIndicatorViewStyle style, UIColor *toothColor, NSInteger frame, NSInteger numberOfFrames, CGFloat scale) {
    const CGSize frameSize = DMActivityIndicatorViewStyleSize(style);
    const CGFloat radius = frameSize.width / 2.f;
    const CGFloat TWOPI = M_PI * 2.f;
    const CGFloat numberOfTeeth = 12;
    const CGFloat toothWidth = (style == DMActivityIndicatorViewStyleWhiteLarge) ? 3.5 : 2;
    
    if (!toothColor) {
        toothColor = (style == DMActivityIndicatorViewStyleGray) ? [UIColor grayColor] : [UIColor whiteColor];
    }
    
    UIGraphicsBeginImageContextWithOptions(frameSize, NO, scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(c, radius, radius);
    
    CGContextRotateCTM(c, frame / (CGFloat)numberOfFrames * TWOPI);
    
    for (NSInteger toothNumber = 0; toothNumber < numberOfTeeth; toothNumber++) {
        const CGFloat alpha = 0.3 + ((toothNumber / numberOfTeeth) * 0.7);
        [[toothColor colorWithAlphaComponent:alpha] setFill];
        
        CGContextRotateCTM(c, 1 / numberOfTeeth * TWOPI);
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-toothWidth / 2.f, -radius, toothWidth, ceilf(radius * .54f)) cornerRadius:toothWidth / 2.f] fill];
    }
    
    CGContextSetFillColorWithColor(c, toothColor.CGColor);
    
    UIImage *frameImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return frameImage;
}

@interface DMActivityIndicatorView : UIView

- (instancetype)initWithActivityIndicatorStyle:(DMActivityIndicatorViewStyle)style;
- (instancetype)initWithFrame:(CGRect)frame;
   
@property(nonatomic) DMActivityIndicatorViewStyle activityIndicatorViewStyle;
@property(nonatomic) BOOL                         hidesWhenStopped;

@property (null_resettable, readwrite, nonatomic, strong) UIColor *color;

- (void)startAnimating;
- (void)stopAnimating;
@property(nonatomic, readonly, getter=isAnimating) BOOL animating;

@end

NS_ASSUME_NONNULL_END
