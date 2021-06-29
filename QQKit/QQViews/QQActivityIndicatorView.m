//
//  QQActivityIndicatorView.m
//  QQKitDemo
//
//  Created by Mac on 2021/5/19.
//

#import "QQActivityIndicatorView.h"

static CGSize QQActivityIndicatorViewStyleSize(QQActivityIndicatorViewStyle style)
{
    if (style == QQActivityIndicatorViewStyleWhiteLarge) {
        return CGSizeMake(37, 37);
    } else {
        return CGSizeMake(20, 20);
    }
}

static UIImage *QQActivityIndicatorViewFrameImage(QQActivityIndicatorViewStyle style, UIColor *toothColor, NSInteger frame, NSInteger numberOfFrames, CGFloat scale)
{
    const CGSize frameSize = QQActivityIndicatorViewStyleSize(style);
    const CGFloat radius = frameSize.width / 2.f;
    const CGFloat TWOPI = M_PI * 2.f;
    const CGFloat numberOfTeeth = 12;
    const CGFloat toothWidth = (style == UIActivityIndicatorViewStyleWhiteLarge) ? 3.5 : 2;

    if (!toothColor) {
        toothColor = (style == QQActivityIndicatorViewStyleGray)? [UIColor grayColor] : [UIColor whiteColor];
    }
    
    UIGraphicsBeginImageContextWithOptions(frameSize, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(context, radius, radius);
    CGContextRotateCTM(context, frame / (CGFloat)numberOfFrames * TWOPI);

    for (NSInteger toothNumber = 0; toothNumber < numberOfTeeth; toothNumber++) {
        const CGFloat alpha = 0.3 + ((toothNumber / numberOfTeeth) * 0.7);
        [[toothColor colorWithAlphaComponent:alpha] setFill];

        CGContextRotateCTM(context, 1 / numberOfTeeth * TWOPI);
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-toothWidth / 2.f, -radius, toothWidth, ceilf(radius * .54f)) cornerRadius:toothWidth / 2.f] fill];
    }
    
    UIImage *frameImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return frameImage;
}

@implementation QQActivityIndicatorView {
    BOOL _animating;
    QQActivityIndicatorViewStyle _activityIndicatorViewStyle;
    BOOL _hidesWhenStopped;
}

- (instancetype)initWithActivityIndicatorStyle:(QQActivityIndicatorViewStyle)style {
    CGRect frame = CGRectZero;
    frame.size = QQActivityIndicatorViewStyleSize(style);
    if (self = [super initWithFrame:frame]) {
        _animating = NO;
        self.activityIndicatorViewStyle = style;
        self.hidesWhenStopped = YES;
        self.opaque = NO;
        self.contentMode = UIViewContentModeCenter;
        self.backgroundColor = [UIColor clearColor];
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [self initWithActivityIndicatorStyle:QQActivityIndicatorViewStyleWhite]) {
        self.frame = frame;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return QQActivityIndicatorViewStyleSize(self.activityIndicatorViewStyle);
}

- (void)setActivityIndicatorViewStyle:(QQActivityIndicatorViewStyle)activityIndicatorViewStyle {
    @synchronized (self) {
        if (_activityIndicatorViewStyle != activityIndicatorViewStyle) {
            _activityIndicatorViewStyle = activityIndicatorViewStyle;
            [self setNeedsDisplay];
            
            if (_animating) {
                [self startAnimating];
            }
        }
    }
}

- (QQActivityIndicatorViewStyle)activityIndicatorViewStyle {
    @synchronized (self) {
        return _activityIndicatorViewStyle;
    }
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    @synchronized (self) {
        _hidesWhenStopped = hidesWhenStopped;
        
        if (_hidesWhenStopped) {
            self.hidden = !_animating;
        } else {
            self.hidden = NO;
        }
    }
}

- (BOOL)hidesWhenStopped {
    @synchronized (self) {
        return _hidesWhenStopped;
    }
}

- (void)setColor:(UIColor *)color {
    @synchronized (self) {
        if (!color) {
            color = (self.activityIndicatorViewStyle == QQActivityIndicatorViewStyleGray)? [UIColor grayColor] : [UIColor whiteColor];
        }
        _color = color;
        self.layer.contents = (id)QQActivityIndicatorViewFrameImage(self.activityIndicatorViewStyle, self.color, 0, 1, [UIScreen mainScreen].scale).CGImage;
    }
}

- (void)_startAnimation {
    @synchronized (self) {
        const NSInteger numberOfFrames = 12;
        const CFTimeInterval animationDuration = 0.8;
        
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:numberOfFrames];
        
        for (NSInteger frameNumber = 0; frameNumber < numberOfFrames; frameNumber++) {
            [images addObject:(__bridge id)QQActivityIndicatorViewFrameImage(self.activityIndicatorViewStyle, self.color, frameNumber, numberOfFrames, [UIScreen mainScreen].scale).CGImage];
        }
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        animation.calculationMode = kCAAnimationDiscrete;
        animation.duration = animationDuration;
        animation.repeatCount = HUGE_VALF;
        animation.values = images;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeBoth;
        
        [self.layer addAnimation:animation forKey:@"contents"];
    }
}

- (void)_stopAnimation {
    @synchronized (self) {
        [self.layer removeAnimationForKey:@"contents"];
        
        self.layer.contents = (id)QQActivityIndicatorViewFrameImage(self.activityIndicatorViewStyle, self.color, 0, 1, [UIScreen mainScreen].scale).CGImage;
        
        if (self.hidesWhenStopped) {
            self.hidden = YES;
        }
    }
}

- (void)startAnimating {
    @synchronized (self) {
        _animating = YES;
        self.hidden = NO;
        [self performSelectorOnMainThread:@selector(_startAnimation) withObject:nil waitUntilDone:NO];
    }
}

- (void)stopAnimating {
    @synchronized (self) {
        _animating = NO;
        [self performSelectorOnMainThread:@selector(_stopAnimation) withObject:nil waitUntilDone:NO];
    }
}

- (BOOL)isAnimating {
    @synchronized (self) {
        return _animating;
    }
}

- (void)didMoveToWindow {
    if (!self.isAnimating) {
        [self _stopAnimation];
    }
}

@end
