//
//  QQCircularProgressView.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/16.
//

#import "QQCircularProgressView.h"

@interface QQCircularProgressLayer : CALayer

@property (nonatomic, strong) UIColor *trackTintColor;
@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *innerTintColor;

@property (nonatomic, assign) BOOL roundedCorners;
@property (nonatomic, assign) BOOL clockwise;

@property (nonatomic, assign) CGFloat thicknessRatio;
@property (nonatomic, assign) CGFloat progress;

@end

@implementation QQCircularProgressLayer

// 加dynamic才能让自定义的属性支持动画
@dynamic trackTintColor;
@dynamic progressTintColor;
@dynamic innerTintColor;
@dynamic roundedCorners;
@dynamic thicknessRatio;
@dynamic progress;
@dynamic clockwise;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

- (void)drawInContext:(CGContextRef)context {
    CGRect rect = self.bounds;
    CGPoint centerPoint = CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0);
    CGFloat radius = MIN(rect.size.height, rect.size.width) / 2.0;
    
    BOOL clockwise = self.clockwise;
    
    CGFloat progress = MIN(self.progress, 1.0 - FLT_EPSILON);
    CGFloat radians = 0;
    if (clockwise) {
        radians = (float)((progress * 2.0 * M_PI) - M_PI_2);
    } else {
        radians = (float)(3 * M_PI_2 - (progress * 2.0 * M_PI));
    }
     
    // 绘制 track
    CGContextSetFillColorWithColor(context, self.trackTintColor.CGColor);
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathMoveToPoint(trackPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, (float)(2.0 * M_PI), 0.0, true);
    CGPathCloseSubpath(trackPath);
    CGContextAddPath(context, trackPath);
    CGContextFillPath(context);
    CGPathRelease(trackPath);

    // 绘制 progress
    if (progress > 0.0) {
        CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
        CGMutablePathRef progressPath = CGPathCreateMutable();
        CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
        CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, (float)(3.0 * M_PI_2), radians, !clockwise);
        CGPathCloseSubpath(progressPath);
        CGContextAddPath(context, progressPath);
        CGContextFillPath(context);
        CGPathRelease(progressPath);
    }
    
    // 绘制圆角
    if (progress > 0.0 && self.roundedCorners) {
        CGFloat pathWidth = radius * self.thicknessRatio;
        CGFloat xOffset = radius * (1.0 + ((1.0 - (self.thicknessRatio / 2.0)) * cosf(radians)));
        CGFloat yOffset = radius * (1.0 + ((1.0 - (self.thicknessRatio / 2.0)) * sinf(radians)));
        CGPoint endPoint = CGPointMake(xOffset, yOffset);
        
        CGRect startEllipseRect = CGRectMake(centerPoint.x - pathWidth / 2.0, 0, pathWidth, pathWidth);
        CGContextAddEllipseInRect(context, startEllipseRect);
        CGContextFillPath(context);
        
        CGRect endEllipseRect = CGRectMake(endPoint.x - pathWidth / 2.0, endPoint.y - pathWidth / 2.0, pathWidth, pathWidth);
        CGContextAddEllipseInRect(context, endEllipseRect);
        CGContextFillPath(context);
    }
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGFloat innerRadius = radius * (1 - self.thicknessRatio);
    CGRect clearRect = CGRectMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius, innerRadius * 2.0, innerRadius * 2.0);
    CGContextAddEllipseInRect(context, clearRect);
    CGContextFillPath(context);
    
    if (self.innerTintColor) {
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextSetFillColorWithColor(context, self.innerTintColor.CGColor);
        CGContextAddEllipseInRect(context, clearRect);
        CGContextFillPath(context);
    }
}

@end

@interface QQCircularProgressView ()<CAAnimationDelegate>

@end

@implementation QQCircularProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.backgroundColor = [UIColor clearColor];
    self.trackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    self.progressTintColor = [UIColor whiteColor];
    self.innerTintColor = nil;
    self.thicknessRatio = 0.3;
    self.roundedCorners = NO;
    self.clockwise = YES;
    self.indeterminate = NO;
    self.indeterminateDuration = 2.0;
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.backgroundColor = [UIColor clearColor];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.progressLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.progressLabel.frame = self.bounds;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    self.circularProgressLayer.contentsScale = self.window.screen.scale;
    [self.circularProgressLayer setNeedsDisplay];
}

+ (Class)layerClass {
    return [QQCircularProgressLayer class];
}

- (QQCircularProgressLayer *)circularProgressLayer {
    return (QQCircularProgressLayer *)self.layer;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSNumber *pinnedProgressNumber = [anim valueForKey:@"toValue"];
    self.circularProgressLayer.progress = [pinnedProgressNumber floatValue];
}

#pragma mark - Propertys

- (CGFloat)progress {
    return self.circularProgressLayer.progress;
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    if (!_indeterminate) {
        [self.layer removeAnimationForKey:@"indeterminateAnimation"];
    }
    [self.circularProgressLayer removeAnimationForKey:@"progress"];
    
    CGFloat pinnedProgress = MIN(MAX(progress, 0.0), 1.0);
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
        animation.duration = fabs(self.progress - pinnedProgress);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fillMode = kCAFillModeForwards;
        animation.fromValue = [NSNumber numberWithFloat:self.progress];
        animation.toValue = [NSNumber numberWithFloat:pinnedProgress];
        animation.beginTime = CACurrentMediaTime();
        animation.delegate = self;
        [self.circularProgressLayer addAnimation:animation forKey:@"progress"];
    } else {
        [self.circularProgressLayer setNeedsDisplay];
        self.circularProgressLayer.progress = pinnedProgress;
    }
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    self.circularProgressLayer.trackTintColor = trackTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    self.circularProgressLayer.progressTintColor = progressTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (void)setInnerTintColor:(UIColor *)innerTintColor {
    _innerTintColor = innerTintColor;
    self.circularProgressLayer.innerTintColor = innerTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (void)setRoundedCorners:(BOOL)roundedCorners {
    _roundedCorners = roundedCorners;
    self.circularProgressLayer.roundedCorners = roundedCorners;
    [self.circularProgressLayer setNeedsDisplay];
}

- (void)setThicknessRatio:(CGFloat)thicknessRatio {
    _thicknessRatio = thicknessRatio;
    self.circularProgressLayer.thicknessRatio = MIN(MAX(thicknessRatio, 0.0), 1.0);
    [self.circularProgressLayer setNeedsDisplay];
}

- (void)setIndeterminate:(BOOL)indeterminate {
    _indeterminate = indeterminate;
    if (indeterminate) {
        CAAnimation *spinAnimation = [self.layer animationForKey:@"indeterminateAnimation"];
        if (!spinAnimation) {
            CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            spinAnimation.byValue = [NSNumber numberWithDouble:indeterminate ? 2.0 * M_PI : -2.0 * M_PI];
            spinAnimation.duration = self.indeterminateDuration;
            spinAnimation.repeatCount = HUGE_VALF;
            spinAnimation.removedOnCompletion = NO;
            [self.layer addAnimation:spinAnimation forKey:@"indeterminateAnimation"];
        }
    } else {
        [self.layer removeAnimationForKey:@"indeterminateAnimation"];
    }
}

- (void)setClockwise:(BOOL)clockwise {
    _clockwise = clockwise;
    self.circularProgressLayer.clockwise = clockwise;
    [self.circularProgressLayer setNeedsDisplay];
}

- (void)dealloc {
    [self.layer removeAnimationForKey:@"indeterminateAnimation"];
    [self.circularProgressLayer removeAnimationForKey:@"progress"];
}

@end
