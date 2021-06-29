//
//  UIView+QQExtension.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "UIView+QQExtension.h"

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

@end
