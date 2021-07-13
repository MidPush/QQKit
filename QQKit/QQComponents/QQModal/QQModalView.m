//
//  QQModalView.m
//  QQKitDemo
//
//  Created by xuze on 2021/7/10.
//

#import "QQModalView.h"
#import "UIView+QQExtension.h"

@interface QQModalView ()

@property (nonatomic, assign, readwrite, getter=isVisible) BOOL visible;
@property (nonatomic, assign) BOOL inAnimation;
@property(nonatomic, strong) UITapGestureRecognizer *dimmingViewTapGesture;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation QQModalView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _modalAnimationStyle = QQModalAnimationStyleFade;
        _contentViewMargins = UIEdgeInsetsMake(20, 20, 20, 20);
        _dismissWhenTapDimmingView = YES;
        _removeWhenDismiss = YES;
        [self initDefaultDimmingView];
        [self addKeyboardNotification];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dimmingView.frame = self.bounds;
}

#pragma mark - Keyboard
- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    UIResponder *firstResponder = [self firstResponderInWindows];
    if (!firstResponder || !([firstResponder isKindOfClass:[UIView class]] && [(UIView *)firstResponder isDescendantOfView:self])) {
        return;
    }
    CGRect endFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = endFrame.size.height;
    if (self.keyboardHeight != keyboardHeight) {
        self.keyboardHeight = keyboardHeight;
        [self updateLayout];
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    CGFloat keyboardHeight = 0;
    if (self.keyboardHeight != keyboardHeight) {
        self.keyboardHeight = keyboardHeight;
        [self updateLayout];
    }
}

- (UIResponder *)firstResponderInWindows {
    UIResponder *responder = [UIApplication.sharedApplication.keyWindow qq_findFirstResponder];
    if (!responder) {
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            if (window != UIApplication.sharedApplication.keyWindow) {
                responder = [window qq_findFirstResponder];
                if (responder) {
                    return responder;
                }
            }
        }
    }
    return responder;
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
        self.dimmingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
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
        [self endEditing:YES];
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
    
    void (^didShowCompletion)(BOOL finished) = ^(BOOL finished) {
        self.inAnimation = NO;
        if (completion) {
            completion(finished);
        }
    };
    
    self.inAnimation = YES;
    
    CGRect contentViewFrame = [self contentViewDefaultFrame];
    if (self.showingAnimation) {
        //使用自定义动画
        if (self.layoutBlock) {
            self.layoutBlock(self.bounds, self.keyboardHeight, contentViewFrame);
        }
        self.showingAnimation(self.dimmingView, self.bounds, self.keyboardHeight, contentViewFrame, didShowCompletion);
    } else {
        self.contentView.frame = contentViewFrame;
        [self.contentView setNeedsLayout];
        [self.contentView layoutIfNeeded];
        
        if (self.modalAnimationStyle == QQModalAnimationStyleFade) {
            self.dimmingView.alpha = 0.0;
            self.contentView.alpha = 0.0;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.dimmingView.alpha = 1.0;
                self.contentView.alpha = 1.0;
            } completion:^(BOOL finished) {
                didShowCompletion(finished);
            }];
        } else if (self.modalAnimationStyle == QQModalAnimationStylePopup) {
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeScale(0, 0);
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.dimmingView.alpha = 1.0;
                self.contentView.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                self.contentView.transform = CGAffineTransformIdentity;
                didShowCompletion(finished);
            }];
        } else if (self.modalAnimationStyle == QQModalAnimationStyleSheet) {
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.bounds) - CGRectGetMinY(self.contentView.frame));
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.dimmingView.alpha = 1.0;
                self.contentView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                didShowCompletion(finished);
            }];
        } else {
            didShowCompletion(YES);
        }
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
    
    void (^didDismissCompletion)(BOOL finished) = ^(BOOL finished) {
        if (self.removeWhenDismiss) {
            [self removeFromSuperview];
        } else {
            self.hidden = YES;
        }
        self.inAnimation = NO;
        self.visible = NO;

        if ([self.delegate respondsToSelector:@selector(didDismissModalView:)]) {
            [self.delegate didDismissModalView:self];
        }

        if (completion) {
            completion(finished);
        }
    };
    
    self.inAnimation = YES;
    
    if (self.hidingAnimation) {
        self.hidingAnimation(self.dimmingView, self.bounds, self.keyboardHeight, didDismissCompletion);
    } else {
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
}

- (CGRect)contentViewDefaultFrame {
    CGSize containerSize = CGSizeMake(CGRectGetWidth(self.bounds) - (self.contentViewMargins.left + self.contentViewMargins.right), CGRectGetHeight(self.bounds) - (self.contentViewMargins.top + self.contentViewMargins.bottom + self.keyboardHeight));
    CGSize contentViewSize = [self.contentView sizeThatFits:containerSize];
    contentViewSize.width = fmin(containerSize.width, contentViewSize.width);
    contentViewSize.height = fmin(containerSize.height, contentViewSize.height);
    CGRect contentViewFrame = CGRectMake((containerSize.width - contentViewSize.width) / 2 + self.contentViewMargins.left, (containerSize.height - contentViewSize.height) / 2 + self.contentViewMargins.top, contentViewSize.width, contentViewSize.height);
    return contentViewFrame;
}

- (void)updateLayout {
    if (CGRectEqualToRect(CGRectZero, self.frame)) return;
    self.dimmingView.frame = self.bounds;
    CGRect contentViewFrame = [self contentViewDefaultFrame];
    if (self.layoutBlock) {
        self.layoutBlock(self.bounds, self.keyboardHeight, contentViewFrame);
    } else {
        self.contentView.frame = contentViewFrame;
    }
}

- (void)dealloc {
    [self removeKeyboardNotification];
}

@end
