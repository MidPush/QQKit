//
//  QQConfirmModalController.m
//  QQKitDemo
//
//  Created by Mac on 2021/7/12.
//

#import "QQConfirmModalController.h"
#import "QQModalView.h"
#import "UIView+QQExtension.h"
#import "CALayer+QQExtension.h"
#import "QQUIHelper.h"

@interface QQConfirmModalController ()<QQModalViewDelegate>

@property (nonatomic, strong) QQModalView *modalView;
@property (nonatomic, strong) UIView *modalContentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) CALayer *titleViewSeparatorLayer;
@property (nonatomic, strong) CALayer *actionsViewSeparatorLayer;
@property (nonatomic, strong) CALayer *buttonSeparatorLayer;

@property (nonatomic, assign) BOOL hasCustomContentView;
@property (nonatomic, assign) BOOL isWillDismissModalView;

@property (nonatomic, copy) void (^dismissCompletion)(void);

@end

@implementation QQConfirmModalController

- (QQModalView *)modalView {
    if (!_modalView) {
        _modalView = [[QQModalView alloc] init];
        _modalView.delegate = self;
    }
    return _modalView;
}

- (UIView *)modalContentView {
    if (!_modalContentView) {
        _modalContentView = [[UIView alloc] init];
        _modalContentView.layer.cornerRadius = 13.0;
        _modalContentView.layer.masksToBounds = YES;
    }
    return _modalContentView;
}

- (QQButton *)createActionsButtonWithText:(NSString *)text {
    UIColor *titleColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1.0];
    UIColor *highlightedColor = [UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1.0];
    QQButton *button = [[QQButton alloc] init];
    button.highlightedBackgroundColor = highlightedColor;
    button.adjustsButtonWhenHighlighted = NO;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    return button;
}

- (CALayer *)createSeparatorLayer {
    CALayer *layer = [CALayer layer];
    [layer qq_removeDefaultAnimations];
    layer.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:224.0/255.0 blue:226.0/255.0 alpha:1.0].CGColor;
    return layer;
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        _titleViewHeight = 48.0;
        _actionsViewHeight = 48.0;
        _alertViewMargins = UIEdgeInsetsMake(20, 20, 20, 20);
        _messageMargins = UIEdgeInsetsMake(20, 20, 20, 20);
        _alertContentMaximumWidth = CGFLOAT_MAX;
        _alertViewCornerRadius = 13.0;
        
        // titleView
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor whiteColor];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleView addSubview:_titleLabel];
        
        _titleViewSeparatorLayer = [self createSeparatorLayer];
        [_titleView.layer addSublayer:_titleViewSeparatorLayer];
        
        // contentView
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:15];
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:_messageLabel];
        
        // actionsView
        _actionsView = [[UIView alloc] init];
        _actionsView.backgroundColor = [UIColor whiteColor];
        
        _cancelButton = [self createActionsButtonWithText:@"取消"];
        [_cancelButton addTarget:self action:@selector(onCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _submitButton = [self createActionsButtonWithText:@"确定"];
        [_submitButton addTarget:self action:@selector(onSubmitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _actionsViewSeparatorLayer = [self createSeparatorLayer];
        _buttonSeparatorLayer = [self createSeparatorLayer];
        
        [_actionsView addSubview:_cancelButton];
        [_actionsView addSubview:_submitButton];
        [_actionsView.layer addSublayer:_actionsViewSeparatorLayer];
        [_actionsView.layer addSublayer:_buttonSeparatorLayer];
            
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.modalContentView addSubview:self.titleView];
    [self.modalContentView addSubview:self.contentView];
    [self.modalContentView addSubview:self.actionsView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateLayout];
    if (!self.modalView.isVisible) {
        [self.modalView showInView:self.view completion:nil];
    }
}

- (void)updateLayout {
    if (_isWillDismissModalView) return;
    BOOL isTitleViewShowing = (self.title.length > 0 || self.attributedTitle.length > 0) && self.titleViewHeight > 0;
    BOOL isActionsViewShowing = (self.cancelButton || self.submitButton) && self.actionsViewHeight > 0;
    
    CGSize containerSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - (self.alertViewMargins.left + self.alertViewMargins.right), CGRectGetHeight(self.view.bounds) - (self.alertViewMargins.top + self.alertViewMargins.bottom + self.titleViewHeight + self.actionsViewHeight));
    containerSize.width = MIN(containerSize.width, self.alertContentMaximumWidth);
    
    if (!self.hasCustomContentView) {
        UIEdgeInsets messageMargins = UIEdgeInsetsMake(20, 20, 20, 20);
        if (self.attributedMessage) {
            _messageLabel.attributedText = self.attributedMessage;
        } else if (self.message) {
            _messageLabel.text = self.message;
        }
        CGSize messageLimitSize = CGSizeMake(containerSize.width - (messageMargins.left + messageMargins.right), containerSize.height - (messageMargins.top + messageMargins.bottom));
        CGSize messageLabeSize = [_messageLabel sizeThatFits:messageLimitSize];
        messageLabeSize.width = fmin(messageLimitSize.width, messageLabeSize.width);
        messageLabeSize.height = fmin(messageLimitSize.height, messageLabeSize.height);
        _messageLabel.frame = CGRectMake(messageMargins.left, messageMargins.top, messageLimitSize.width, messageLabeSize.height);
        
        CGFloat contentViewHeight = _messageLabel.qq_height + messageMargins.top + messageMargins.bottom;
        if (contentViewHeight < 100) {
            contentViewHeight = 100;
            _messageLabel.qq_top = (contentViewHeight - _messageLabel.qq_height) / 2;
        }
        
        self.contentView.frame = CGRectMake(0, 0, containerSize.width, contentViewHeight);
    }
    
    CGSize contentViewSize = [self.contentView sizeThatFits:containerSize];
    contentViewSize.width = fmin(containerSize.width, contentViewSize.width);
    contentViewSize.height = fmin(containerSize.height, contentViewSize.height);
    
    if (isTitleViewShowing) {
        self.titleView.hidden = NO;
        self.titleView.frame = CGRectMake(0, 0, contentViewSize.width, self.titleViewHeight);
        self.titleViewSeparatorLayer.frame = CGRectFlatMake(0, self.titleViewHeight - QQUIHelper.pixelOne, self.titleView.qq_width, QQUIHelper.pixelOne);
        self.titleLabel.frame = CGRectMake(10, 0, self.titleView.qq_width - 20, self.titleView.qq_height);
        if (self.attributedTitle) {
            self.titleLabel.attributedText = self.attributedTitle;
        } else if (self.title) {
            self.titleLabel.text = self.title;
        }
    } else {
        self.titleView.hidden = YES;
        self.titleView.frame = CGRectMake(0, 0, contentViewSize.width, 0);
    }
    
    CGRect contentViewFrame = CGRectMake(0, self.titleView.qq_bottom, contentViewSize.width, contentViewSize.height);
    self.contentView.frame = contentViewFrame;
    
    if (isActionsViewShowing) {
        self.actionsView.hidden = NO;
        self.actionsView.frame = CGRectMake(0, self.contentView.qq_bottom, contentViewSize.width, self.actionsViewHeight);
        self.actionsViewSeparatorLayer.frame = CGRectFlatMake(0, 0, self.actionsView.qq_width, QQUIHelper.pixelOne);

        if (self.cancelButton && self.submitButton) {
            self.cancelButton.frame = CGRectMake(0, 0, self.actionsView.qq_width / 2, self.actionsView.qq_height);
            self.submitButton.frame = CGRectMake(self.cancelButton.qq_right, 0, self.actionsView.qq_width / 2, self.actionsView.qq_height);
            
            
            self.buttonSeparatorLayer.hidden = NO;
            self.buttonSeparatorLayer.frame = CGRectFlatMake((self.actionsView.qq_width - QQUIHelper.pixelOne) / 2, 0, QQUIHelper.pixelOne, self.actionsView.qq_height);
        } else {
            if (self.cancelButton) {
                self.cancelButton.frame = CGRectMake(0, 0, self.actionsView.qq_width, self.actionsView.qq_height);
            } else if (self.submitButton) {
                self.submitButton.frame = CGRectMake(0, 0, self.actionsView.qq_width, self.actionsView.qq_height);
            }
            self.buttonSeparatorLayer.hidden = YES;
        }
    } else {
        self.actionsView.hidden = YES;
        self.actionsView.frame =  CGRectMake(0, self.contentView.qq_bottom, contentViewSize.width, 0);
    }
    
    CGFloat modalContentViewWidth = contentViewSize.width;
    CGFloat modalContentViewHeight = self.titleView.qq_height + self.contentView.qq_height + self.actionsView.qq_height;
    self.modalContentView.frame = CGRectMake((self.view.qq_width - modalContentViewWidth) / 2, (self.view.qq_height - modalContentViewHeight) / 2, modalContentViewWidth, modalContentViewHeight);
    
    self.modalView.contentViewMargins = self.alertViewMargins;
    self.modalView.contentView = self.modalContentView;
    self.modalView.dismissWhenTapDimmingView = NO;
    self.modalView.frame = self.view.bounds;
}

#pragma mark - Showing and Hiding
- (void)show {
    [self showFromController:[UIApplication sharedApplication].delegate.window.rootViewController];
}

- (void)showFromController:(UIViewController *)viewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:self animated:NO completion:nil];
    });
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    self.dismissCompletion = completion;
    [self.modalView dismiss];
}

#pragma mark - QQModalViewDelegate
- (void)willDismissModalView:(QQModalView *)modalView {
    _isWillDismissModalView = YES;
}

- (void)didDismissModalView:(QQModalView *)modalView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:^{
            if (self.dismissCompletion) {
                self.dismissCompletion();
                self.dismissCompletion = nil;
            }
        }];
    });
}

#pragma mark - Button Actions
- (void)onCancelButtonClicked {
    if (self.actionsHandler) {
        self.actionsHandler(self, NO);
    } else {
        [self.modalView dismiss];
    }
}

- (void)onSubmitButtonClicked {
    if (self.actionsHandler) {
        self.actionsHandler(self, YES);
    } else {
        [self.modalView dismiss];
    }
}

- (void)removeCancelButton {
    [_cancelButton removeFromSuperview];
    _cancelButton = nil;
    [self updateLayout];
}

- (void)removeSubmitButton {
    [_submitButton removeFromSuperview];
    _submitButton = nil;
    [self updateLayout];
}

#pragma mark - Setters
- (void)setAlertViewCornerRadius:(CGFloat)alertViewCornerRadius {
    _alertViewCornerRadius = alertViewCornerRadius;
    self.modalContentView.layer.cornerRadius = alertViewCornerRadius;
}

- (void)setTitleViewHeight:(CGFloat)titleViewHeight {
    if (_titleViewHeight != titleViewHeight) {
        _titleViewHeight = titleViewHeight;
        if ([self isViewLoaded]) {
            [self updateLayout];
        }
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    if (![self.titleLabel.text isEqualToString:title]) {
        self.titleLabel.text = title;
        if ([self isViewLoaded]) {
            [self updateLayout];
        }
    }
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    _attributedTitle = attributedTitle;
    self.titleLabel.attributedText = attributedTitle;
    if ([self isViewLoaded]) {
        [self updateLayout];
    }
}

- (void)setTitleViewSeparatorColor:(UIColor *)titleViewSeparatorColor {
    _titleViewSeparatorColor = titleViewSeparatorColor;
    _titleViewSeparatorLayer.backgroundColor = titleViewSeparatorColor.CGColor;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView != contentView) {
        [_contentView removeFromSuperview];
        _contentView = contentView;
        if ([self isViewLoaded]) {
            [self.modalContentView insertSubview:_contentView atIndex:0];
            [self updateLayout];
        }
        self.hasCustomContentView = YES;
    } else {
        self.hasCustomContentView = YES;
    }
}

- (void)setMessage:(NSString *)message {
    if (![_message isEqualToString:message]) {
        _message = [message copy];
        self.messageLabel.text = message;
        if ([self isViewLoaded]) {
            [self updateLayout];
        }
    }
}

- (void)setAttributedMessage:(NSAttributedString *)attributedMessage {
    _attributedMessage = attributedMessage;
    self.messageLabel.attributedText = attributedMessage;
    if ([self isViewLoaded]) {
        [self updateLayout];
    }
}

- (void)setAlertViewMargins:(UIEdgeInsets)alertViewMargins {
    if (!UIEdgeInsetsEqualToEdgeInsets(_alertViewMargins, alertViewMargins)) {
        _alertViewMargins = alertViewMargins;
        if ([self isViewLoaded]) {
            [self updateLayout];
        }
    }
}

- (void)setActionsViewHeight:(CGFloat)actionsViewHeight {
    if (_actionsViewHeight != actionsViewHeight) {
        _actionsViewHeight = actionsViewHeight;
        if ([self isViewLoaded]) {
            [self updateLayout];
        }
    }
}

- (void)setActionsViewSeparatorColor:(UIColor *)actionsViewSeparatorColor {
    _actionsViewSeparatorColor = actionsViewSeparatorColor;
    _actionsViewSeparatorLayer.backgroundColor = actionsViewSeparatorColor.CGColor;
    _buttonSeparatorLayer.backgroundColor = actionsViewSeparatorColor.CGColor;
}

@end
