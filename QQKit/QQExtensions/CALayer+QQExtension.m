//
//  CALayer+QQExtension.m
//  QQKitDemo
//
//  Created by Mac on 2021/7/6.
//

#import "CALayer+QQExtension.h"
#import "UIView+QQExtension.h"
#import "QQRuntime.h"

@implementation CALayer (QQExtension)

static NSString *kMaskName = @"QQ_CornerRadius_Mask";

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([CALayer class], @selector(layoutSublayers), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject) {
                
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                if (@available(iOS 11.0, *)) {
                } else {
                    if (selfObject.mask && ![selfObject.mask.name isEqualToString:kMaskName]) {
                        return;
                    }
                    if (selfObject.qq_maskedCorners) {
                        if (selfObject.qq_cornerRadius <= 0) {
                            if (selfObject.mask) {
                                selfObject.mask = nil;
                            }
                        } else {
                            CAShapeLayer *cornerMaskLayer = [CAShapeLayer layer];
                            cornerMaskLayer.name = kMaskName;
                            UIRectCorner rectCorner = 0;
                            if ((selfObject.qq_maskedCorners & QQLayerMinXMinYCorner) == QQLayerMinXMinYCorner) {
                                rectCorner |= UIRectCornerTopLeft;
                            }
                            if ((selfObject.qq_maskedCorners & QQLayerMaxXMinYCorner) == QQLayerMaxXMinYCorner) {
                                rectCorner |= UIRectCornerTopRight;
                            }
                            if ((selfObject.qq_maskedCorners & QQLayerMinXMaxYCorner) == QQLayerMinXMaxYCorner) {
                                rectCorner |= UIRectCornerBottomLeft;
                            }
                            if ((selfObject.qq_maskedCorners & QQLayerMaxXMaxYCorner) == QQLayerMaxXMaxYCorner) {
                                rectCorner |= UIRectCornerBottomRight;
                            }
                            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:selfObject.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(selfObject.qq_cornerRadius, selfObject.qq_cornerRadius)];
                            cornerMaskLayer.frame = CGRectMake(0, 0, selfObject.bounds.size.width, selfObject.bounds.size.height);
                            cornerMaskLayer.path = path.CGPath;
                            selfObject.mask = cornerMaskLayer;
                        }
                    }
                }
            };
        });
        
    });
}

static const void * const kQQMaskedCornersKey = &kQQMaskedCornersKey;
- (void)setQq_maskedCorners:(QQCornerMask)qq_maskedCorners {
    BOOL maskedCornersChanged = qq_maskedCorners != self.qq_maskedCorners;
    objc_setAssociatedObject(self, kQQMaskedCornersKey, @(qq_maskedCorners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (@available(iOS 11.0, *)) {
        self.maskedCorners = (CACornerMask)qq_maskedCorners;
    } else {
        if (maskedCornersChanged) {
            // 需要刷新 mask
            if ([NSThread isMainThread]) {
                [self setNeedsLayout];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setNeedsLayout];
                });
            }
        }
    }
    if (maskedCornersChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.qq_borderPosition > 0 && view.qq_borderWidth > 0) {
                [view.qq_borderLayer setNeedsLayout];// 直接调用 layer 的 setNeedsLayout，没有线程限制，如果通过 view 调用则需要在主线程才行
            }
        }
    }
}

- (QQCornerMask)qq_maskedCorners {
    NSUInteger result = [objc_getAssociatedObject(self, kQQMaskedCornersKey) unsignedIntegerValue];
    if (result == 0) {
        result = QQLayerAllCorner;
    }
    return result;
}

static const void * const kQQCornerRadiusKey = &kQQCornerRadiusKey;
- (void)setQq_cornerRadius:(CGFloat)qq_cornerRadius {
    BOOL cornerRadiusChanged = qq_cornerRadius != self.qq_cornerRadius;
    objc_setAssociatedObject(self, kQQCornerRadiusKey, @(qq_cornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (@available(iOS 11.0, *)) {
        self.cornerRadius = qq_cornerRadius;
    } else {
        if (cornerRadiusChanged) {
            // 需要刷新 mask
            if ([NSThread isMainThread]) {
                [self setNeedsLayout];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setNeedsLayout];
                });
            }
        }
    }
    if (cornerRadiusChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.qq_borderPosition > 0 && view.qq_borderWidth > 0) {
                [view.qq_borderLayer setNeedsLayout];// 直接调用 layer 的 setNeedsLayout，没有线程限制，如果通过 view 调用则需要在主线程才行
            }
        }
    }
}

- (CGFloat)qq_cornerRadius {
    return [((NSNumber *)objc_getAssociatedObject(self, kQQCornerRadiusKey)) floatValue];
}

- (void)qq_sendSublayerToBack:(CALayer *)sublayer {
    [self insertSublayer:sublayer atIndex:0];
}

- (void)qq_bringSublayerToFront:(CALayer *)sublayer {
    [self insertSublayer:sublayer atIndex:(unsigned)self.sublayers.count];
}

- (void)qq_removeDefaultAnimations {
    NSMutableDictionary<NSString *, id<CAAction>> *actions = @{NSStringFromSelector(@selector(bounds)): [NSNull null],
                                                               NSStringFromSelector(@selector(position)): [NSNull null],
                                                               NSStringFromSelector(@selector(zPosition)): [NSNull null],
                                                               NSStringFromSelector(@selector(anchorPoint)): [NSNull null],
                                                               NSStringFromSelector(@selector(anchorPointZ)): [NSNull null],
                                                               NSStringFromSelector(@selector(transform)): [NSNull null],
                                                                #pragma clang diagnostic push
                                                                #pragma clang diagnostic ignored "-Wundeclared-selector"
                                                               NSStringFromSelector(@selector(hidden)): [NSNull null],
                                                               NSStringFromSelector(@selector(doubleSided)): [NSNull null],
                                                                #pragma clang diagnostic pop
                                                               NSStringFromSelector(@selector(sublayerTransform)): [NSNull null],
                                                               NSStringFromSelector(@selector(masksToBounds)): [NSNull null],
                                                               NSStringFromSelector(@selector(contents)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsRect)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsScale)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsCenter)): [NSNull null],
                                                               NSStringFromSelector(@selector(minificationFilterBias)): [NSNull null],
                                                               NSStringFromSelector(@selector(backgroundColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(cornerRadius)): [NSNull null],
                                                               NSStringFromSelector(@selector(borderWidth)): [NSNull null],
                                                               NSStringFromSelector(@selector(borderColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(opacity)): [NSNull null],
                                                               NSStringFromSelector(@selector(compositingFilter)): [NSNull null],
                                                               NSStringFromSelector(@selector(filters)): [NSNull null],
                                                               NSStringFromSelector(@selector(backgroundFilters)): [NSNull null],
                                                               NSStringFromSelector(@selector(shouldRasterize)): [NSNull null],
                                                               NSStringFromSelector(@selector(rasterizationScale)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowOpacity)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowOffset)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowRadius)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowPath)): [NSNull null]}.mutableCopy;
    
    if (@available(iOS 11.0, *)) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(maskedCorners)): [NSNull null]}];
    }
    
    if ([self isKindOfClass:[CAShapeLayer class]]) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(path)): [NSNull null],
                                            NSStringFromSelector(@selector(fillColor)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeColor)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeStart)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeEnd)): [NSNull null],
                                            NSStringFromSelector(@selector(lineWidth)): [NSNull null],
                                            NSStringFromSelector(@selector(miterLimit)): [NSNull null],
                                            NSStringFromSelector(@selector(lineDashPhase)): [NSNull null]}];
    }
    
    if ([self isKindOfClass:[CAGradientLayer class]]) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(colors)): [NSNull null],
                                            NSStringFromSelector(@selector(locations)): [NSNull null],
                                            NSStringFromSelector(@selector(startPoint)): [NSNull null],
                                            NSStringFromSelector(@selector(endPoint)): [NSNull null]}];
    }
    
    self.actions = actions;
}

- (BOOL)hasFourCornerRadius {
    return (self.qq_maskedCorners & QQLayerMinXMinYCorner) == QQLayerMinXMinYCorner &&
           (self.qq_maskedCorners & QQLayerMaxXMinYCorner) == QQLayerMaxXMinYCorner &&
           (self.qq_maskedCorners & QQLayerMinXMaxYCorner) == QQLayerMinXMaxYCorner &&
           (self.qq_maskedCorners & QQLayerMaxXMaxYCorner) == QQLayerMaxXMaxYCorner;
}

@end
