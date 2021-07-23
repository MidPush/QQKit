//
//  QQProgressHUD.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/16.
//

#import "QQProgressHUD.h"

@interface QQIndefiniteAnimatedView : UIView

@property (nonatomic, strong) CAShapeLayer *indefiniteAnimatedLayer;
@property (nonatomic, assign) CGFloat strokeThickness;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) UIColor *strokeColor;

@end

@implementation QQIndefiniteAnimatedView

- (void)willMoveToSuperview:(UIView*)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    } else {
        [_indefiniteAnimatedLayer removeFromSuperlayer];
        _indefiniteAnimatedLayer = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutAnimatedLayer];
}

- (void)layoutAnimatedLayer {
    CALayer *layer = self.indefiniteAnimatedLayer;

    if (!layer.superlayer) {
        [self.layer addSublayer:layer];
    }
    
    CGFloat widthDiff = CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds);
    CGFloat heightDiff = CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds);
    layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2 - widthDiff / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2 - heightDiff / 2);
}

- (CAShapeLayer*)indefiniteAnimatedLayer {
    if(!_indefiniteAnimatedLayer) {
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:self.radius startAngle:(CGFloat) (M_PI*3/2) endAngle:(CGFloat) (M_PI/2+M_PI*5) clockwise:YES];
        
        _indefiniteAnimatedLayer = [CAShapeLayer layer];
        _indefiniteAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];
        _indefiniteAnimatedLayer.frame = CGRectMake(0.0f, 0.0f, arcCenter.x*2, arcCenter.y*2);
        _indefiniteAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
        _indefiniteAnimatedLayer.strokeColor = self.strokeColor.CGColor;
        _indefiniteAnimatedLayer.lineWidth = self.strokeThickness;
        _indefiniteAnimatedLayer.lineCap = kCALineCapRound;
        _indefiniteAnimatedLayer.lineJoin = kCALineJoinBevel;
        _indefiniteAnimatedLayer.path = smoothedPath.CGPath;
        
        CALayer *maskLayer = [CALayer layer];
        
        NSBundle *bundle = [NSBundle bundleForClass:[QQProgressHUD class]];
        NSURL *url = [bundle URLForResource:@"QQUIKit" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        
        NSString *path = [imageBundle pathForResource:@"angle-mask" ofType:@"png"];
        
        maskLayer.contents = (__bridge id)[[UIImage imageWithContentsOfFile:path] CGImage];
        maskLayer.frame = _indefiniteAnimatedLayer.bounds;
        _indefiniteAnimatedLayer.mask = maskLayer;
        
        NSTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = (id) 0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_indefiniteAnimatedLayer.mask addAnimation:animation forKey:@"rotate"];
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        [_indefiniteAnimatedLayer addAnimation:animationGroup forKey:@"progress"];
        
    }
    return _indefiniteAnimatedLayer;
}

- (void)setFrame:(CGRect)frame {
    if(!CGRectEqualToRect(frame, super.frame)) {
        [super setFrame:frame];
        
        if(self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (void)setRadius:(CGFloat)radius {
    if(radius != _radius) {
        _radius = radius;
        
        [_indefiniteAnimatedLayer removeFromSuperlayer];
        _indefiniteAnimatedLayer = nil;
        
        if(self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (void)setStrokeColor:(UIColor*)strokeColor {
    _strokeColor = strokeColor;
    _indefiniteAnimatedLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _indefiniteAnimatedLayer.lineWidth = _strokeThickness;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

@end

@interface QQProgressAnimatedView : UIView

@property (nonatomic, strong) CAShapeLayer *ringAnimatedLayer;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat strokeThickness;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat strokeEnd;

@end

@implementation QQProgressAnimatedView

- (void)willMoveToSuperview:(UIView*)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    } else {
        [_ringAnimatedLayer removeFromSuperlayer];
        _ringAnimatedLayer = nil;
    }
}

- (void)layoutAnimatedLayer {
    CALayer *layer = self.ringAnimatedLayer;
    [self.layer addSublayer:layer];
    
    CGFloat widthDiff = CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds);
    CGFloat heightDiff = CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds);
    layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2 - widthDiff / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2 - heightDiff / 2);
}

- (CAShapeLayer*)ringAnimatedLayer {
    if(!_ringAnimatedLayer) {
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:self.radius startAngle:(CGFloat)-M_PI_2 endAngle:(CGFloat) (M_PI + M_PI_2) clockwise:YES];
        
        _ringAnimatedLayer = [CAShapeLayer layer];
        _ringAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];
        _ringAnimatedLayer.frame = CGRectMake(0.0f, 0.0f, arcCenter.x*2, arcCenter.y*2);
        _ringAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
        _ringAnimatedLayer.strokeColor = self.strokeColor.CGColor;
        _ringAnimatedLayer.lineWidth = self.strokeThickness;
        _ringAnimatedLayer.lineCap = kCALineCapRound;
        _ringAnimatedLayer.lineJoin = kCALineJoinBevel;
        _ringAnimatedLayer.path = smoothedPath.CGPath;
    }
    return _ringAnimatedLayer;
}

- (void)setFrame:(CGRect)frame {
    if(!CGRectEqualToRect(frame, super.frame)) {
        [super setFrame:frame];
        
        if(self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (void)setRadius:(CGFloat)radius {
    if(radius != _radius) {
        _radius = radius;
        
        [_ringAnimatedLayer removeFromSuperlayer];
        _ringAnimatedLayer = nil;
        
        if(self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (void)setStrokeColor:(UIColor*)strokeColor {
    _strokeColor = strokeColor;
    _ringAnimatedLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _ringAnimatedLayer.lineWidth = _strokeThickness;
}

- (void)setStrokeEnd:(CGFloat)strokeEnd {
    _strokeEnd = strokeEnd;
    _ringAnimatedLayer.strokeEnd = _strokeEnd;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

@end

static const CGFloat QQProgressHUDVerticalSpacing = 12.0f;
static const CGFloat QQProgressHUDHorizontalSpacing = 12.0f;
static const CGFloat QQProgressHUDLabelSpacing = 12.0f;
static const CGFloat QQProgressHUDUndefinedProgress = -1;

@interface QQProgressHUD ()

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UIView *indefiniteAnimatedView;
@property (nonatomic, strong) QQProgressAnimatedView *ringView;
@property (nonatomic, strong) QQProgressAnimatedView *backgroundRingView;

@property (nonatomic, assign) QQProgressHUDMaskType maskType;
@property (nonatomic, assign) QQProgressHUDAnimationType animationType;

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGSize minimumSize;
@property (nonatomic, strong) UIColor *backgroundViewColor;

@property (nonatomic, assign) CGFloat ringRadius;
@property (nonatomic, assign) CGFloat ringThickness;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIImage *infoImage;
@property (nonatomic, strong) UIImage *successImage;
@property (nonatomic, strong) UIImage *errorImage;

@property (nonatomic, weak) NSTimer *hideDelayTimer;
@property (nonatomic, assign) CGFloat progress;
// 淡入显示动画时间
@property (nonatomic, assign) NSTimeInterval fadeInDuration;
// 淡出消失动画时间
@property (nonatomic, assign) NSTimeInterval fadeOutDuration;
    
@end

@implementation QQProgressHUD

+ (QQProgressHUD *)sharedView {
    static QQProgressHUD *sharedView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedView = [[self alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
    });
    return sharedView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.maskView.alpha = 0.0;
        self.backgroundView.alpha = 0.0;
        self.imageView.alpha = 0.0;
        self.statusLabel.alpha = 0.0;
        self.indefiniteAnimatedView.alpha = 0.0;
        self.ringView.alpha = 0.0;
        self.backgroundRingView.alpha = 0.0;
        
        _maskType = QQProgressHUDMaskTypeNone;
        _animationType = QQProgressHUDAnimationTypeFlat;
        
        _contentInsets = UIEdgeInsetsMake(0, 20, 0, 20);
        _cornerRadius = 5.0;
        _minimumSize = CGSizeMake(100, 100);
        _backgroundViewColor = [UIColor blackColor];
    
        _ringRadius = 18.0;
        _ringThickness = 2.0;
        
        _font = [UIFont systemFontOfSize:16];
        _textColor = nil;
        
        _fadeInDuration = 0.15;
        _fadeOutDuration = 0.15;
        
        NSBundle *bundle = [NSBundle bundleForClass:[QQProgressHUD class]];
        NSURL *url = [bundle URLForResource:@"QQUIKit" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        
        _infoImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"info" ofType:@"png"]];
        _successImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"success" ofType:@"png"]];
        _errorImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"error" ofType:@"png"]];
        
    }
    return self;
}

- (void)updateViewHierarchy {
    if (!self.superview) {
        [self.frontWindow addSubview:self];
    } else {
        [self.superview bringSubviewToFront:self];
    }
    if (!self.maskView.superview) {
        [self addSubview:self.maskView];
    }
    if (!self.contentView.superview) {
        [self addSubview:self.contentView];
    }
}

- (void)updateHUDFrame {
    self.maskView.frame = self.bounds;
    CGSize limitSize = CGSizeMake(CGRectGetWidth(self.frame) - (self.contentInsets.left + self.contentInsets.right), CGRectGetHeight(self.frame) - (self.contentInsets.top + self.contentInsets.bottom));
    
    BOOL useImage = (self.imageView.image) && !(self.imageView.hidden) && !(CGSizeEqualToSize(self.imageView.image.size, CGSizeZero));
    BOOL useRing = self.imageView.hidden;
    
    // indefinite
    CGFloat indefiniteWidth = 0;
    CGFloat indefiniteHeight = 0;
    if (useImage) {
        indefiniteWidth = self.imageView.frame.size.width;
        indefiniteHeight = self.imageView.frame.size.height;
    } else if (useRing) {
        indefiniteWidth = CGRectGetWidth(self.indefiniteAnimatedView.frame);
        indefiniteHeight = CGRectGetHeight(self.indefiniteAnimatedView.frame);
        
        if (self.progress != QQProgressHUDUndefinedProgress) {
            indefiniteWidth = CGRectGetWidth(self.backgroundRingView.frame);
            indefiniteHeight = CGRectGetHeight(self.backgroundRingView.frame);
        }
    }
    
    // label
    CGFloat labelWidth = 0;
    CGFloat labelHeight = 0;
    if (self.statusLabel.text.length > 0) {
        CGSize labelSize = [self.statusLabel.text boundingRectWithSize:CGSizeMake(limitSize.width - QQProgressHUDHorizontalSpacing * 2, limitSize.height - indefiniteHeight - QQProgressHUDVerticalSpacing * 2) options:(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: self.statusLabel.font} context:nil].size;
        labelWidth = labelSize.width;
        labelHeight = labelSize.height;
    }
    
    // content
    CGFloat contentWidth = MIN(MAX(indefiniteWidth, labelWidth) + QQProgressHUDHorizontalSpacing * 2, limitSize.width);
    CGFloat contentHeight = MIN(indefiniteHeight + labelHeight + QQProgressHUDVerticalSpacing * 2, limitSize.height);
    if (self.statusLabel.text.length > 0 && (useImage || useRing)) {
        contentHeight += QQProgressHUDLabelSpacing;
    }
    
    contentWidth = MAX(self.minimumSize.width, contentWidth);
    contentHeight = MAX(self.minimumSize.height, contentHeight);
    
    self.contentView.bounds = CGRectMake(0.0f, 0.0f, contentWidth, contentHeight);
    self.backgroundView.frame = self.contentView.bounds;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGFloat labelSpacing = labelHeight > 0 ? QQProgressHUDLabelSpacing : 0;
    CGRect indefiniteFrame = CGRectMake((contentWidth - indefiniteWidth) / 2, (contentHeight - indefiniteHeight - labelSpacing - labelHeight) / 2, indefiniteWidth, indefiniteHeight);
    if (useImage) {
        self.imageView.frame = indefiniteFrame;
    } else if (useRing) {
        self.indefiniteAnimatedView.frame = indefiniteFrame;
    }
    
    if (self.progress != QQProgressHUDUndefinedProgress) {
        self.backgroundRingView.frame = indefiniteFrame;
        self.ringView.frame = indefiniteFrame;
    }
    
    if (useImage || useRing) {
        self.statusLabel.frame = CGRectMake((CGRectGetWidth(self.contentView.bounds) - labelWidth) / 2, CGRectGetMaxY(indefiniteFrame) + QQProgressHUDLabelSpacing, labelWidth, labelHeight);
    } else {
        self.statusLabel.frame = CGRectMake((contentWidth - labelWidth) / 2, (contentHeight - labelHeight) / 2,  labelWidth, labelHeight);
    }
    
    [CATransaction commit];
}

- (void)positionHUD:(NSNotification *)notification {
    CGFloat keyboardHeight = 0.0;
    NSTimeInterval animationDuration = 0.0;
    
    self.frame = self.frontWindow.bounds;
    
    if (notification) {
        NSDictionary *keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if (notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            keyboardHeight = CGRectGetHeight(keyboardFrame);
        }
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = self.bounds;
    CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
    
    // Calculate available height for display
    CGFloat activeHeight = CGRectGetHeight(orientationFrame);
    if (keyboardHeight > 0) {
        activeHeight += CGRectGetHeight(statusBarFrame) * 2;
    }
    activeHeight -= keyboardHeight;
    
    CGFloat posX = CGRectGetMidX(orientationFrame);
    CGFloat posY = floorf(activeHeight*0.45f);

    CGFloat rotateAngle = 0.0;
    CGPoint newCenter = CGPointMake(posX, posY);
    
    if (notification) {
        // Animate update if notification was present
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                             [self.contentView setNeedsDisplay];
                         } completion:nil];
    } else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.transform = CGAffineTransformMakeRotation(angle);
    self.contentView.center = CGPointMake(newCenter.x, newCenter.y);
}

#pragma mark - Getters

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    if(!_maskView.superview){
        [self insertSubview:_maskView belowSubview:self.contentView];
    }
    return _maskView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.masksToBounds = YES;
    }
    if(!_contentView.superview) {
        [self addSubview:_contentView];
    }
    _contentView.layer.cornerRadius = self.cornerRadius;
    return _contentView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
    }
    if (!_backgroundView.superview) {
        [self.contentView insertSubview:_backgroundView atIndex:0];
    }
    _backgroundView.backgroundColor = self.backgroundViewColor;
    return _backgroundView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    if (!_imageView.superview) {
        [self.contentView addSubview:_imageView];
    }
    [_imageView sizeToFit];
    return _imageView;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.numberOfLines = 0;
    }
    if (!_statusLabel.superview) {
      [self.contentView addSubview:_statusLabel];
    }
    _statusLabel.textColor = self.textColor ? self.textColor : self.tintColor;
    _statusLabel.font = self.font;
    return _statusLabel;
}

- (UIView *)indefiniteAnimatedView {
    if (self.animationType == QQProgressHUDAnimationTypeFlat) {
        if (_indefiniteAnimatedView && ![_indefiniteAnimatedView isKindOfClass:[QQIndefiniteAnimatedView class]]) {
            [_indefiniteAnimatedView removeFromSuperview];
            _indefiniteAnimatedView = nil;
        }
        
        if (!_indefiniteAnimatedView) {
            _indefiniteAnimatedView = [[QQIndefiniteAnimatedView alloc] initWithFrame:CGRectZero];
        }
        
        QQIndefiniteAnimatedView *indefiniteAnimatedView = (QQIndefiniteAnimatedView *)_indefiniteAnimatedView;
        indefiniteAnimatedView.strokeColor = self.tintColor;
        indefiniteAnimatedView.strokeThickness = self.ringThickness;
        indefiniteAnimatedView.radius = self.ringRadius;
    } else {
        if (_indefiniteAnimatedView && ![_indefiniteAnimatedView isKindOfClass:[UIActivityIndicatorView class]]) {
            [_indefiniteAnimatedView removeFromSuperview];
            _indefiniteAnimatedView = nil;
        }
        
        if (!_indefiniteAnimatedView) {
            _indefiniteAnimatedView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        
        // Update styling
        UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)_indefiniteAnimatedView;
        activityIndicatorView.color = self.tintColor;
    }
    [_indefiniteAnimatedView sizeToFit];
    
    return _indefiniteAnimatedView;
}

- (QQProgressAnimatedView *)ringView {
    if (!_ringView) {
        _ringView = [[QQProgressAnimatedView alloc] initWithFrame:CGRectZero];
    }
    _ringView.strokeColor = self.tintColor;
    _ringView.strokeThickness = self.ringThickness;
    _ringView.radius = self.ringRadius;
    [_ringView sizeToFit];
    return _ringView;
}

- (QQProgressAnimatedView *)backgroundRingView {
    if (!_backgroundRingView) {
        _backgroundRingView = [[QQProgressAnimatedView alloc] initWithFrame:CGRectZero];
        _backgroundRingView.strokeEnd = 1.0;
    }
    _backgroundRingView.strokeColor = [self.tintColor colorWithAlphaComponent:0.1];
    _backgroundRingView.strokeThickness = self.ringThickness;
    _backgroundRingView.radius = self.ringRadius;
    [_backgroundRingView sizeToFit];
    return _backgroundRingView;
}

#pragma mark - Setters

+ (void)setDefaultMaskType:(QQProgressHUDMaskType)maskType {
    [self sharedView].maskType = maskType;
}

+ (void)setDefaultAnimationType:(QQProgressHUDAnimationType)animationType {
    [self sharedView].animationType = animationType;
}

+ (void)setContentInsets:(UIEdgeInsets)contentInsets {
    [self sharedView].contentInsets = contentInsets;
}

+ (void)setCornerRadius:(CGFloat)cornerRadius {
    [self sharedView].cornerRadius = cornerRadius;
}

+ (void)setMinimumSize:(CGSize)minimumSize {
    [self sharedView].minimumSize = minimumSize;
}

+ (void)setBackgroundColor:(UIColor *)color {
    [self sharedView].backgroundViewColor = color;
}

+ (void)setRingRadius:(CGFloat)ringRadius {
    [self sharedView].ringRadius = ringRadius;
}

+ (void)setRingThickness:(CGFloat)ringThickness {
    [self sharedView].ringThickness = ringThickness;
}

+ (void)setTintColor:(UIColor *)tintColor {
    [self sharedView].tintColor = tintColor;
}

+ (void)setFont:(UIFont *)font {
    [self sharedView].font = font;
}

+ (void)setTextColor:(UIColor *)textColor {
    [self sharedView].textColor = textColor;
}

+ (void)setInfoImage:(UIImage *)image {
    [self sharedView].infoImage = image;
}

+ (void)setSuccessImage:(UIImage *)image {
    [self sharedView].successImage = image;
}

+ (void)setErrorImage:(UIImage *)image {
    [self sharedView].errorImage = image;
}

#pragma mark - Show Methods

+ (void)show {
    [self showWithStatus:nil];
}

+ (void)showWithStatus:(NSString *)status {
    [self showProgress:QQProgressHUDUndefinedProgress status:status];
}

+ (void)showProgress:(CGFloat)progress {
    [self showProgress:progress status:nil];
}

+ (void)showProgress:(CGFloat)progress status:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedView] showProgress:progress status:status];
    });
}

+ (void)showInfoWithStatus:(NSString *)status {
    [self showImage:[self sharedView].infoImage status:status];
}

+ (void)showSuccessWithStatus:(NSString *)status {
    [self showImage:[self sharedView].successImage status:status];
}

+ (void)showErrorWithStatus:(NSString *)status {
    [self showImage:[self sharedView].errorImage status:status];
}

+ (void)showImage:(UIImage *)image status:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedView] showImage:image status:status];
    });
}

#pragma mark - Dismiss Methods

+ (void)dismiss {
    [self dismissWithDelay:0];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedView] dismissWithDelay:delay];
    });
}

#pragma mark - Master show/dismiss methods

- (void)showProgress:(CGFloat)progress status:(NSString *)status {
    [self stopDelayTimer];
    
    [self updateViewHierarchy];
    
    self.imageView.hidden = YES;
    self.imageView.image = nil;
    
    self.statusLabel.text = status;
    self.progress = progress;
    
    if (progress >= 0) {
        [self removeIndefiniteAnimatedView];
        
        if (!self.ringView.superview) {
            [self.contentView addSubview:self.ringView];
        }
        if (!self.backgroundRingView.superview) {
            [self.contentView addSubview:self.backgroundRingView];
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.ringView.strokeEnd = progress;
        [CATransaction commit];
    } else {
        [self removeProgressAnimatedView];
        
        [self.contentView addSubview:self.indefiniteAnimatedView];
        if ([self.indefiniteAnimatedView isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView *)self.indefiniteAnimatedView startAnimating];
        }
    }
    [self fadeIn];
}

- (void)showImage:(UIImage *)image status:(NSString *)status {
    [self stopDelayTimer];
    
    [self updateViewHierarchy];
    
    self.imageView.hidden = NO;
    [self removeIndefiniteAnimatedView];
    [self removeProgressAnimatedView];
    
    if (image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
        self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    self.imageView.tintColor = self.tintColor;
    self.statusLabel.text = status;
    
    [self fadeIn];
}

- (void)dismiss {
    [self dismissWithDelay:0];
}

- (void)dismissWithDelay:(NSTimeInterval)delay {
    if (delay > 0) {
        [self stopDelayTimer];
        NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.hideDelayTimer = timer;
    } else {
        [self fadeOut];
    }
}

- (void)fadeIn {
    [self updateHUDFrame];
    [self positionHUD:nil];
    
    self.userInteractionEnabled = (self.maskType != QQProgressHUDMaskTypeNone);
    
    if (self.maskView.alpha != 1.0) {
        
        void (^animationsBlock)(void) = ^{
            [self fadeInEffects];
        };
        
        void (^completionBlock)(void) = ^{
            if (self.maskView.alpha == 1.0) {
                [self registerNotifications];
            }
        };
        
        if (self.fadeInDuration > 0) {
            // Animate appearance
            [UIView animateWithDuration:self.fadeInDuration
                                  delay:0
                                options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                             animations:^{
                                 animationsBlock();
                             } completion:^(BOOL finished) {
                                 completionBlock();
                             }];
        } else {
            animationsBlock();
            completionBlock();
        }
        
        [self setNeedsDisplay];
    } else {
        BOOL useRing = self.imageView.hidden;
        if (useRing) {
            [self stopDelayTimer];
        } else {
            NSTimeInterval delay = [QQProgressHUD displayDurationForString:self.statusLabel.text];
            [self dismissWithDelay:delay];
        }
    }
}

- (void)fadeOut {
    void (^animationsBlock)(void) = ^{
        [self fadeOutEffects];
    };
    
    void (^completionBlock)(void) = ^{
        if (self.backgroundView.alpha == 0.0) {
            
            [self removeNotifications];
            
            [self removeIndefiniteAnimatedView];
            [self removeProgressAnimatedView];
            [self.contentView removeFromSuperview];
            [self removeFromSuperview];
            self.progress = QQProgressHUDUndefinedProgress;
            [self stopDelayTimer];
            
        }
    };
    
    if (self.fadeOutDuration > 0) {
        UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:self.fadeOutDuration delay:0 options:options animations:^{
            animationsBlock();
        } completion:^(BOOL finished) {
            completionBlock();
        }];
    } else {
        animationsBlock();
        completionBlock();
    }
}

- (void)fadeInEffects {
    self.backgroundView.backgroundColor = self.backgroundViewColor;
    self.maskView.alpha = 1.0;
    self.contentView.alpha = 1.0;
    self.backgroundView.alpha = 1.0;
    self.imageView.alpha = 1.0;
    self.statusLabel.alpha = 1.0;
    _indefiniteAnimatedView.alpha = 1.0;
    _ringView.alpha = 1.0;
    _backgroundRingView.alpha = 1.0;
}

- (void)fadeOutEffects {
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.maskView.alpha = 0.0;
    self.contentView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    self.imageView.alpha = 0.0;
    self.statusLabel.alpha = 0.0;
    _indefiniteAnimatedView.alpha = 0.0;
    _ringView.alpha = 0.0;
    _backgroundRingView.alpha = 0.0;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.statusLabel.textColor = self.textColor ? self.textColor : self.tintColor;
    self.imageView.tintColor = self.tintColor;
    if ([self.indefiniteAnimatedView isKindOfClass:[UIActivityIndicatorView class]]) {
        UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)_indefiniteAnimatedView;
        activityIndicatorView.color = self.tintColor;
    } else if ([self.indefiniteAnimatedView isKindOfClass:[QQIndefiniteAnimatedView class]]) {
        QQIndefiniteAnimatedView *indefiniteAnimatedView = (QQIndefiniteAnimatedView *)_indefiniteAnimatedView;
        indefiniteAnimatedView.strokeColor = self.tintColor;
    }
}

#pragma mark - Notifications

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Helps

- (UIWindow *)frontWindow {
    return [UIApplication sharedApplication].delegate.window;
}

- (void)removeIndefiniteAnimatedView {
    if (_indefiniteAnimatedView) {
        if ([_indefiniteAnimatedView isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView *)self.indefiniteAnimatedView stopAnimating];
        }
        [_indefiniteAnimatedView removeFromSuperview];
    }
    [self.contentView.layer removeAllAnimations];
}

- (void)removeProgressAnimatedView {
    if (_ringView) {
        [_ringView removeFromSuperview];
    }
    if (_backgroundRingView) {
        [_backgroundRingView removeFromSuperview];
    }
    [self.contentView.layer removeAllAnimations];
}

- (void)stopDelayTimer {
    if (_hideDelayTimer) {
        [_hideDelayTimer invalidate];
        _hideDelayTimer = nil;
    }
}

- (UIView *)keyboardView {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        UIView *view = [self getKeyboardViewFromWindow:window];
        if (view) {
            return view;
        }
    }
    return nil;
}

- (UIView *)getKeyboardViewFromWindow:(UIWindow *)window {
    
    if (!window) return nil;
    
    NSString *windowName = NSStringFromClass(window.class);
    if (![windowName isEqualToString:[NSString stringWithFormat:@"UI%@", @"RemoteKeyboardWindow"]]) {
        return nil;
    }
    
    for (UIView *view in window.subviews) {
        NSString *viewName = NSStringFromClass(view.class);
        if (![viewName isEqualToString:[NSString stringWithFormat:@"UI%@", @"InputSetContainerView"]]) {
            continue;
        }
        for (UIView *subView in view.subviews) {
            NSString *subViewName = NSStringFromClass(subView.class);
            if (![subViewName isEqualToString:[NSString stringWithFormat:@"UI%@", @"InputSetHostView"]]) {
                continue;
            }
            return subView;
        }
    }
    
    return nil;
}

- (CGFloat)visibleKeyboardHeight {
    UIView *keyboardView = [self keyboardView];
    UIWindow *keyboardWindow = keyboardView.window;
    if (!keyboardView || !keyboardWindow) {
        return 0;
    } else {
        // 开启了系统的“设置→辅助功能→动态效果→减弱动态效果→首选交叉淡出过渡效果”后，键盘动画不再是 slide，而是 fade，此时应该用 alpha 来判断
        if (keyboardView.alpha <= 0) {
            return 0;
        }
        
        CGRect visibleRect = CGRectIntersection(keyboardWindow.bounds, keyboardView.frame);
        if (!CGRectIsNull(visibleRect) && !CGRectIsInfinite(visibleRect)) {
            return CGRectGetHeight(visibleRect);
        }
        return 0;
    }
}

+ (NSTimeInterval)displayDurationForString:(NSString *)string {
    CGFloat duration = MAX((CGFloat)string.length * 0.06 + 0.5, 2.0);
    return duration;
}

+ (void)bringHUDToFront {
    QQProgressHUD *hud = [self sharedView];
    if (hud.superview) {
        [hud.superview bringSubviewToFront:hud];
    }
}

@end
