//
//  QQAssetPreviewScrollView.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/6.
//

#import "QQAssetPreviewScrollView.h"

@interface QQAssetPreviewScrollView ()<UIGestureRecognizerDelegate>

@end

@implementation QQAssetPreviewScrollView

- (BOOL)isOnTop {
    CGPoint translation = [self.panGestureRecognizer translationInView:self];
    if (translation.y > 0 && self.contentOffset.y <= 0) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
            if ([self isOnTop]) {
                return NO;
            }
        }
    }
    return YES;
}

@end
