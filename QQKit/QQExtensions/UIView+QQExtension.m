//
//  UIView+QQExtension.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "UIView+QQExtension.h"
#import "CALayer+QQExtension.h"
#import "UIImage+QQExtension.h"

@interface QQBorderLayer : CAShapeLayer

@property (nonatomic, weak) UIView *qq_targetBorderView;

@end

@implementation QQBorderLayer

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([QQBorderLayer class], @selector(layoutSublayers), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(QQBorderLayer *selfObject) {
                
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                if (!selfObject.qq_targetBorderView) return;
                
                UIView *view = selfObject.qq_targetBorderView;
                CGFloat borderWidth = selfObject.lineWidth;
                
                UIBezierPath *path = [UIBezierPath bezierPath];;
                
                CGFloat (^adjustsLocation)(CGFloat, CGFloat, CGFloat) = ^CGFloat(CGFloat inside, CGFloat center, CGFloat outside) {
                    return view.qq_borderLocation == QQViewBorderLocationInside ? inside : (view.qq_borderLocation == QQViewBorderLocationCenter ? center : outside);
                };
                
                CGFloat lineOffset = adjustsLocation(borderWidth / 2.0, 0, -borderWidth / 2.0); // 为了像素对齐而做的偏移
                CGFloat lineCapOffset = adjustsLocation(0, borderWidth / 2.0, borderWidth); // 两条相邻的边框连接的位置
                
                BOOL shouldShowTopBorder = (view.qq_borderPosition & QQViewBorderPositionTop) == QQViewBorderPositionTop;
                BOOL shouldShowLeftBorder = (view.qq_borderPosition & QQViewBorderPositionLeft) == QQViewBorderPositionLeft;
                BOOL shouldShowBottomBorder = (view.qq_borderPosition & QQViewBorderPositionBottom) == QQViewBorderPositionBottom;
                BOOL shouldShowRightBorder = (view.qq_borderPosition & QQViewBorderPositionRight) == QQViewBorderPositionRight;
                
                UIBezierPath *topPath = [UIBezierPath bezierPath];
                UIBezierPath *leftPath = [UIBezierPath bezierPath];
                UIBezierPath *bottomPath = [UIBezierPath bezierPath];
                UIBezierPath *rightPath = [UIBezierPath bezierPath];
                
                if (view.layer.qq_cornerRadius > 0) {
                    
                    CGFloat cornerRadius = view.layer.qq_cornerRadius;
                    
                    if (view.layer.qq_maskedCorners) {
                        if ((view.layer.qq_maskedCorners & QQLayerMinXMinYCorner) == QQLayerMinXMinYCorner) {
                            [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                            [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                            [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                            [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                        } else {
                            [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                            [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                            [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                            [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                        }
                        if ((view.layer.qq_maskedCorners & QQLayerMinXMaxYCorner) == QQLayerMinXMaxYCorner) {
                            [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                            [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                            [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                        } else {
                            [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                            CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                            [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                            [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, y)];
                        }
                        if ((view.layer.qq_maskedCorners & QQLayerMaxXMaxYCorner) == QQLayerMaxXMaxYCorner) {
                            [bottomPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                            [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                            [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                        } else {
                            CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                            [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                            CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                            [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                            [rightPath addLineToPoint:CGPointMake(x, cornerRadius)];
                        }
                        if ((view.layer.qq_maskedCorners & QQLayerMaxXMinYCorner) == QQLayerMaxXMinYCorner) {
                            [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                            [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                        } else {
                            CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                            [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
                            [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                        }
                    } else {
                        [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                        
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                        
                        [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                        [bottomPath addArcWithCenter:CGPointMake(CGRectGetHeight(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                        
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                        [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                    }
                    
                } else {
                    [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                    [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                    
                    [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                    [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                    
                    CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                    [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                    [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                    
                    CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                    [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                    [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
                }
                
                if (shouldShowTopBorder && ![topPath isEmpty]) {
                    [path appendPath:topPath];
                }
                if (shouldShowLeftBorder && ![leftPath isEmpty]) {
                    [path appendPath:leftPath];
                }
                if (shouldShowBottomBorder && ![bottomPath isEmpty]) {
                    [path appendPath:bottomPath];
                }
                if (shouldShowRightBorder && ![rightPath isEmpty]) {
                    [path appendPath:rightPath];
                }
                
                selfObject.path = path.CGPath;
                
            };
        });
    });
}

@end

@implementation UIView (QQExtension)

- (void)setQq_top:(CGFloat)qq_top {
    CGRect newFrame = self.frame;
    newFrame.origin.y = qq_top;
    self.frame = newFrame;
}

- (CGFloat)qq_top {
    return CGRectGetMinY(self.frame);
}

- (void)setQq_bottom:(CGFloat)qq_bottom {
    CGRect newFrame = self.frame;
    newFrame.origin.y = qq_bottom - self.frame.size.height;
    self.frame = newFrame;
}

- (CGFloat)qq_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setQq_left:(CGFloat)qq_left {
    CGRect newFrame = self.frame;
    newFrame.origin.x = qq_left;
    self.frame = newFrame;
}

- (CGFloat)qq_left {
    return CGRectGetMinX(self.frame);
}

- (void)setQq_right:(CGFloat)qq_right {
    CGRect newFrame = self.frame;
    newFrame.origin.x = qq_right - newFrame.size.width;
    self.frame = newFrame;
}

- (CGFloat)qq_right {
    return CGRectGetMaxX(self.frame);
}

- (void)setQq_width:(CGFloat)qq_width {
    CGRect newFrame = self.frame;
    newFrame.size.width = qq_width;
    self.frame = newFrame;
}

- (CGFloat)qq_width {
    return CGRectGetWidth(self.frame);
}

- (void)setQq_height:(CGFloat)qq_height {
    CGRect newFrame = self.frame;
    newFrame.size.height = qq_height;
    self.frame = newFrame;
}

- (CGFloat)qq_height {
    return CGRectGetHeight(self.frame);
}

- (void)setQq_centerX:(CGFloat)qq_centerX {
    self.center = CGPointMake(qq_centerX, self.center.y);
}

- (CGFloat)qq_centerX {
    return self.center.x;
}

- (void)setQq_centerY:(CGFloat)qq_centerY {
    self.center = CGPointMake(self.center.x, qq_centerY);
}

- (CGFloat)qq_centerY {
    return self.center.y;
}

- (UIEdgeInsets)qq_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (UIViewController *)qq_viewController {
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = next.nextResponder;
    } while (next != nil);
    return nil;
}

- (void)qq_removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIImage *)qq_snapshotLayerImage {
    return [UIImage qq_imageWithView:self];
}

- (UIImage *)qq_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates {
    return [UIImage qq_imageWithView:self afterScreenUpdates:afterScreenUpdates];
}

- (id)qq_findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView qq_findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}

@end

@implementation UIView (QQBorder)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIView class], @selector(layoutSublayersOfLayer:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CALayer *firstArgv) {

                // call super
                void (*originSelectorIMP)(id, SEL, CALayer *);
                originSelectorIMP = (void (*)(id, SEL, CALayer *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);

                if (selfObject.qq_borderLayer && !selfObject.qq_borderLayer.hidden) {
                    selfObject.qq_borderLayer.frame = selfObject.bounds;
                    [selfObject.layer qq_bringSublayerToFront:selfObject.qq_borderLayer];
                    [selfObject.qq_borderLayer setNeedsLayout];// 把布局刷新逻辑剥离到 layer 内，方便在子线程里直接刷新 layer，如果放在 UIView 内，子线程里就无法主动请求刷新了
                }

                if (selfObject.qq_gradientLayer && !selfObject.qq_gradientLayer.hidden) {
                    selfObject.qq_gradientLayer.frame = selfObject.bounds;
                    [selfObject.layer qq_sendSublayerToBack:selfObject.qq_gradientLayer];
                }
            };
        });
    });
}

static const void * const kQQViewBorderLocationKey = &kQQViewBorderLocationKey;
- (void)setQq_borderLocation:(QQViewBorderLocation)qq_borderLocation {
    BOOL shouldUpdateLayout = self.qq_borderLocation != qq_borderLocation;
    objc_setAssociatedObject(self, kQQViewBorderLocationKey, @(qq_borderLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qq_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (QQViewBorderLocation)qq_borderLocation {
    return [((NSNumber *)objc_getAssociatedObject(self, kQQViewBorderLocationKey)) unsignedIntegerValue];
}

static const void * const kQQViewBorderPositionKey = &kQQViewBorderPositionKey;
- (void)setQq_borderPosition:(QQViewBorderPosition)qq_borderPosition {
    BOOL shouldUpdateLayout = self.qq_borderPosition != qq_borderPosition;
    objc_setAssociatedObject(self, kQQViewBorderPositionKey, @(qq_borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qq_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (QQViewBorderPosition)qq_borderPosition {
    return (QQViewBorderPosition)[objc_getAssociatedObject(self, kQQViewBorderPositionKey) unsignedIntegerValue];
}

static const void * const kQQBorderWidthKey = &kQQBorderWidthKey;
- (void)setQq_borderWidth:(CGFloat)qq_borderWidth {
    BOOL shouldUpdateLayout = self.qq_borderWidth != qq_borderWidth;
    objc_setAssociatedObject(self, kQQBorderWidthKey, @(qq_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qq_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CGFloat)qq_borderWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, kQQBorderWidthKey)) doubleValue];
}

static const void * const kQQBorderColorKey = &kQQBorderColorKey;
- (void)setQq_borderColor:(UIColor *)qq_borderColor {
    objc_setAssociatedObject(self, kQQBorderColorKey, qq_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qq_createBorderLayerIfNeeded];
    [self setNeedsLayout];
}

- (UIColor *)qq_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, kQQBorderColorKey);
}

static const void * const kQQDashPhaseKey = &kQQDashPhaseKey;
- (void)setQq_dashPhase:(CGFloat)qq_dashPhase {
    BOOL shouldUpdateLayout = self.qq_dashPhase != qq_dashPhase;
    objc_setAssociatedObject(self, kQQDashPhaseKey, @(qq_dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qq_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CGFloat)qq_dashPhase {
    return [(NSNumber *)objc_getAssociatedObject(self, kQQDashPhaseKey) floatValue];
}

static const void * const kQQDashPatternKey = &kQQDashPatternKey;
- (void)setQq_dashPattern:(NSArray<NSNumber *> *)qq_dashPattern {
    objc_setAssociatedObject(self, kQQDashPatternKey, qq_dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qq_createBorderLayerIfNeeded];
    [self setNeedsLayout];
}

- (NSArray<NSNumber *> *)qq_dashPattern {
    return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, kQQDashPatternKey);
}

static const void * const kQQBorderLayerKey = &kQQBorderLayerKey;
- (void)setQq_borderLayer:(QQBorderLayer * _Nullable)qq_borderLayer {
    objc_setAssociatedObject(self, kQQBorderLayerKey, qq_borderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (QQBorderLayer *)qq_borderLayer {
    return (QQBorderLayer *)objc_getAssociatedObject(self, kQQBorderLayerKey);
}

- (void)qq_createBorderLayerIfNeeded {
    BOOL shouldShowBorder = self.qq_borderWidth > 0 && self.qq_borderColor && self.qq_borderPosition != QQViewBorderPositionNone;
    if (!shouldShowBorder) {
        self.qq_borderLayer.hidden = YES;
        return;
    }
    
    if (!self.qq_borderLayer) {
        self.qq_borderLayer = [QQBorderLayer layer];
        [(QQBorderLayer *)self.qq_borderLayer setQq_targetBorderView:self];
        self.qq_borderLayer.fillColor = [UIColor clearColor].CGColor;
        [self.qq_borderLayer qq_removeDefaultAnimations];
        [self.layer addSublayer:self.qq_borderLayer];
    }
    self.qq_borderLayer.lineWidth = self.qq_borderWidth;
    self.qq_borderLayer.strokeColor = self.qq_borderColor.CGColor;
    self.qq_borderLayer.lineDashPhase = self.qq_dashPhase;
    self.qq_borderLayer.lineDashPattern = self.qq_dashPattern;
    self.qq_borderLayer.hidden = NO;
}

@end

@implementation UIView (QQGradientColor)

static const void * const kQQGradientDirectionKey = &kQQGradientDirectionKey;
- (void)setQq_gradientDirection:(QQGradientDirection)qq_gradientDirection {
    BOOL shouldUpdateLayout = self.qq_gradientDirection != qq_gradientDirection;
    objc_setAssociatedObject(self, kQQGradientDirectionKey, @(qq_gradientDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qq_createGradientLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (QQGradientDirection)qq_gradientDirection {
    return (QQGradientDirection)[objc_getAssociatedObject(self, kQQGradientDirectionKey) unsignedIntegerValue];
}

static const void * const kQQStartColorKey = &kQQStartColorKey;
- (void)setQq_startColor:(UIColor *)qq_startColor {
    objc_setAssociatedObject(self, kQQStartColorKey, qq_startColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qq_createGradientLayerIfNeeded];
    [self setNeedsLayout];
}

- (UIColor *)qq_startColor {
    return (UIColor *)objc_getAssociatedObject(self, kQQStartColorKey);
}

static const void * const kQQEndColorKey = &kQQEndColorKey;
- (void)setQq_endColor:(UIColor *)qq_endColor {
    objc_setAssociatedObject(self, kQQEndColorKey, qq_endColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qq_createGradientLayerIfNeeded];
    [self setNeedsLayout];
}

- (UIColor *)qq_endColor {
    return (UIColor *)objc_getAssociatedObject(self, kQQEndColorKey);
}

static const void * const kQQGradientLayerKey = &kQQGradientLayerKey;
- (void)setQq_gradientLayer:(CAGradientLayer * _Nullable)qq_gradientLayer {
    objc_setAssociatedObject(self, kQQGradientLayerKey, qq_gradientLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAGradientLayer *)qq_gradientLayer {
    return (CAGradientLayer *)objc_getAssociatedObject(self, kQQGradientLayerKey);
}

- (void)qq_createGradientLayerIfNeeded {
    BOOL shouldShow = self.qq_startColor && self.qq_endColor && (self.qq_gradientDirection == QQGradientDirectionLeftToRight || self.qq_gradientDirection == QQGradientDirectionTopToBottom);
    if (!shouldShow) {
        self.qq_gradientLayer.hidden = YES;
        return;
    }
    
    if (!self.qq_gradientLayer) {
        self.qq_gradientLayer = [CAGradientLayer layer];
        [self.qq_gradientLayer qq_removeDefaultAnimations];
        [self.layer insertSublayer:self.qq_gradientLayer atIndex:0];
    }
    self.qq_gradientLayer.colors = @[(__bridge id)self.qq_startColor.CGColor, (__bridge id)self.qq_endColor.CGColor];
    self.qq_gradientLayer.locations = @[@0, @1];
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    if (self.qq_gradientDirection == QQGradientDirectionTopToBottom) {
        startPoint = CGPointMake(0, 0);
        endPoint = CGPointMake(0, 1);
    } else if (self.qq_gradientDirection == QQGradientDirectionLeftToRight) {
        startPoint = CGPointMake(0, 0.5);
        endPoint = CGPointMake(1, 0.5);
    }
    self.qq_gradientLayer.startPoint = startPoint;
    self.qq_gradientLayer.endPoint = endPoint;
    self.qq_gradientLayer.hidden = NO;
}

@end
