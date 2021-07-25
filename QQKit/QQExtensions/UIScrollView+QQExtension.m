//
//  UIScrollView+QQExtension.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/5.
//

#import "UIScrollView+QQExtension.h"

@implementation UIScrollView (QQExtension)

- (UIEdgeInsets)qq_contentInset {
    if (@available(iOS 11.0, *)) {
        return self.adjustedContentInset;
    } else {
        return self.contentInset;
    }
}

- (BOOL)qq_canScroll {
    if (self.bounds.size.width <= 0 || self.bounds.size.height <= 0) {
        return NO;
    }
    BOOL canVerticalScroll = self.contentSize.height + self.qq_contentInset.top + self.qq_contentInset.bottom > CGRectGetHeight(self.bounds);
    BOOL canHorizontalScoll = self.contentSize.width + self.qq_contentInset.left + self.qq_contentInset.right > CGRectGetWidth(self.bounds);
    return canVerticalScroll || canHorizontalScoll;
}

- (void)qq_scrollToTop {
    [self qq_scrollToTopAnimated:NO];
}

- (void)qq_scrollToTopAnimated:(BOOL)animated {
    if ([self qq_canScroll]) {
        CGPoint offset = self.contentOffset;
        offset.y = -self.qq_contentInset.top;
        [self setContentOffset:offset animated:animated];
    }
}

- (void)qq_scrollToBottom {
    [self qq_scrollToBottomAnimated:NO];
}

- (void)qq_scrollToBottomAnimated:(BOOL)animated {
    if ([self qq_canScroll]) {
        CGPoint offset = self.contentOffset;
        offset.y = self.contentSize.height + self.qq_contentInset.bottom - self.bounds.size.height;
        [self setContentOffset:offset animated:animated];
    }
}

- (void)qq_scrollToLeft {
    [self qq_scrollToLeftAnimated:NO];
}

- (void)qq_scrollToLeftAnimated:(BOOL)animated {
    if ([self qq_canScroll]) {
        CGPoint offset = self.contentOffset;
        offset.x = -self.qq_contentInset.left;
        [self setContentOffset:offset animated:animated];
    }
}

- (void)qq_scrollToRight {
    [self qq_scrollToRightAnimated:NO];
}

- (void)qq_scrollToRightAnimated:(BOOL)animated {
    if ([self qq_canScroll]) {
        CGPoint offset = self.contentOffset;
        offset.x = self.contentSize.width + self.qq_contentInset.right - self.bounds.size.width;
        [self setContentOffset:offset animated:animated];
    }
}

@end
