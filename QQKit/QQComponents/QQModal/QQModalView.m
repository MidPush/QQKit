//
//  QQModalView.m
//  QQKitDemo
//
//  Created by xuze on 2021/7/10.
//

#import "QQModalView.h"

@interface QQModalView ()

@property (nonatomic, assign, readwrite, getter=isVisible) BOOL visible;
@property (nonatomic, assign) BOOL inAnimation;
@property(nonatomic, strong) UITapGestureRecognizer *dimmingViewTapGesture;

@end

@implementation QQModalView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _modalAnimationStyle = QQModalAnimationStyleFade;
        _contentViewMargins = UIEdgeInsetsMake(20, 20, 20, 20);
        _dismissWhenTapDimmingView = YES;
        _removeWhenDismiss = YES;
        [self initDefaultDimmingView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dimmingView.frame = self.bounds;
}

#pragma mark - Dimming View

- (void)setDimmingView:(UIView *)dimmingView {
    if (_dimmingView != dimmingView) {
        [self insertSubview:dimmingView belowSubview:_dimmingView];
        [_dimmingView removeFromSuperview];
        _dimmingView = dimmingView;
    }
    [self setNeedsLayout];
    [self dimmingViewAddTapGestureIfNeeded];
}

- (void)initDefaultDimmingView {
    if (!self.dimmingView) {
        _dimmingView = [[UIView alloc] init];
        self.dimmingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        [self dimmingViewAddTapGestureIfNeeded];
        [self addSubview:self.dimmingView];
    }
}

- (void)dimmingViewAddTapGestureIfNeeded {
    if (!self.dimmingView) {
        return;
    }
    
    if (self.dimmingViewTapGesture.view == self.dimmingView) {
        return;
    }
    
    if (!self.dimmingViewTapGesture) {
        self.dimmingViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapGestureHandler:)];
    }
    [self.dimmingView addGestureRecognizer:self.dimmingViewTapGesture];
    self.dimmingView.userInteractionEnabled = YES;//
}

- (void)dimmingViewTapGestureHandler:(UITapGestureRecognizer *)tapGesture {
    if (!self.dismissWhenTapDimmingView) {
        return;
    }
    [self dismiss];
}

#pragma mark - show & dismiss
- (void)show {
    [self showInView:[UIApplication sharedApplication].delegate.window completion:nil];
}

- (void)showInView:(UIView *)view completion:(void (^)(BOOL))completion {
    if (!view || self.isVisible || self.inAnimation) return;
    self.visible = YES;
    
    self.hidden = NO;
    [view addSubview:self];
    
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame) > 0 ? CGRectGetWidth(self.frame) : CGRectGetWidth(view.bounds), CGRectGetHeight(self.frame) > 0 ? CGRectGetHeight(self.frame) : CGRectGetHeight(view.bounds));
    
    if (!self.contentView) {
        [self layoutIfNeeded];
        return;
    }
    [self addSubview:self.contentView];
    [self layoutIfNeeded];
    
    [self updateLayout];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    self.inAnimation = YES;
    if (self.modalAnimationStyle == QQModalAnimationStyleFade) {
        self.dimmingView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
            self.inAnimation = NO;
        }];
    } else if (self.modalAnimationStyle == QQModalAnimationStylePopup) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            self.contentView.transform = CGAffineTransformIdentity;
            if (completion) {
                completion(finished);
            }
            self.inAnimation = NO;
        }];
    } else if (self.modalAnimationStyle == QQModalAnimationStyleSheet) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.bounds) - CGRectGetMinY(self.contentView.frame));
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
            self.inAnimation = NO;
        }];
    }
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(BOOL))completion {
    if (!self.isVisible || self.inAnimation) return;
    
    if ([self.delegate respondsToSelector:@selector(willDismissModalView:)]) {
        [self.delegate willDismissModalView:self];
    }
    
    self.visible = NO;
    self.inAnimation = YES;
    
    void (^didDismissCompletion)(BOOL finished) = ^(BOOL finished) {
        if (self.removeWhenDismiss) {
            [self removeFromSuperview];
        } else {
            self.hidden = YES;
        }
        self.inAnimation = NO;

        if ([self.delegate respondsToSelector:@selector(didDismissModalView:)]) {
            [self.delegate didDismissModalView:self];
        }

        if (completion) {
            completion(YES);
        }
    };
    
    if (self.modalAnimationStyle == QQModalAnimationStyleFade) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.dimmingView.alpha = 1.0;
            self.contentView.alpha = 1.0;
            didDismissCompletion(finished);
            
        }];
    } else if (self.modalAnimationStyle == QQModalAnimationStylePopup) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL finished) {
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformIdentity;
            didDismissCompletion(finished);
        }];
    } else if (self.modalAnimationStyle == QQModalAnimationStyleSheet) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.bounds) - CGRectGetMinY(self.contentView.frame));
        } completion:^(BOOL finished) {
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformIdentity;
            didDismissCompletion(finished);
        }];
    } else {
        self.dimmingView.alpha = 1.0;
        self.contentView.alpha = 1.0;
        self.contentView.transform = CGAffineTransformIdentity;
        didDismissCompletion(YES);
    }
}

- (CGRect)contentViewDefaultFrame {
    CGSize containerSize = CGSizeMake(CGRectGetWidth(self.bounds) - (self.contentViewMargins.left + self.contentViewMargins.right), CGRectGetHeight(self.bounds) - (self.contentViewMargins.top + self.contentViewMargins.bottom));
    CGSize contentViewSize = [self.contentView sizeThatFits:containerSize];
    contentViewSize.width = fmin(containerSize.width, contentViewSize.width);
    contentViewSize.height = fmin(containerSize.height, contentViewSize.height);
    CGRect contentViewFrame = CGRectMake((containerSize.width - contentViewSize.width) / 2 + self.contentViewMargins.left, (containerSize.height - contentViewSize.height) / 2 + self.contentViewMargins.top, contentViewSize.width, contentViewSize.height);
    return contentViewFrame;
}

- (void)updateLayout {
    if (CGRectEqualToRect(CGRectZero, self.frame)) {
        return;
    }
    self.dimmingView.frame = self.bounds;
    CGRect contentViewFrame = [self contentViewDefaultFrame];
    if (self.layoutBlock) {
        self.layoutBlock(self.bounds, contentViewFrame);
    } else {
        self.contentView.frame = contentViewFrame;
    }
}

@end
