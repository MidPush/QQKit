//
//  DMActivityIndicatorView.m
//  QQKitDemo
//
//  Created by Mac on 2021/5/19.
//

#import "DMActivityIndicatorView.h"


@implementation DMActivityIndicatorView {
    BOOL _animating;
    DMActivityIndicatorViewStyle _activityIndicatorViewStyle;
    BOOL _hidesWhenStopped;
}

- (instancetype)initWithActivityIndicatorStyle:(DMActivityIndicatorViewStyle)style {
    CGRect frame = CGRectZero;
    frame.size = DMActivityIndicatorViewStyleSize(style);
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
    if (self = [self initWithActivityIndicatorStyle:DMActivityIndicatorViewStyleWhite]) {
        self.frame = frame;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return DMActivityIndicatorViewStyleSize(self.activityIndicatorViewStyle);
}

- (void)setActivityIndicatorViewStyle:(DMActivityIndicatorViewStyle)activityIndicatorViewStyle {
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

- (DMActivityIndicatorViewStyle)activityIndicatorViewStyle {
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

- (void)_startAnimation {
    @synchronized (self) {
        const NSInteger numberOfFrames = 12;
        const CFTimeInterval animationDuration = 0.8;
        
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:numberOfFrames];
        
        for (NSInteger frameNumber = 0; frameNumber < numberOfFrames; frameNumber++) {
            [images addObject:(__bridge id)DMActivityIndicatorViewFrameImage(self.activityIndicatorViewStyle, self.color, frameNumber, numberOfFrames, [UIScreen mainScreen].scale).CGImage];
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
        
        self.layer.contents = (id)DMActivityIndicatorViewFrameImage(self.activityIndicatorViewStyle, self.color, 0, 1, [UIScreen mainScreen].scale).CGImage;
        
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
