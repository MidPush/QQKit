//
//  QQAlertController.m
//  QQKitDemo
//
//  Created by Mac on 2021/7/12.
//

#import "QQAlertController.h"
#import "QQUIHelper.h"
#import "UIView+QQExtension.h"
#import "CALayer+QQExtension.h"
#import "UIColor+QQExtension.h"
#import "UIScrollView+QQExtension.h"
#import "QQModalView.h"

@protocol QQAlertActionDelegate <NSObject>

@optional
- (void)alertActionClicked:(QQAlertAction *)action;

@end

@interface QQAlertAction ()
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, assign, readwrite) QQAlertActionStyle style;
@property (nonatomic, copy) void (^handler)(QQAlertAction *action);
@property (nonatomic, strong) QQButton *button;
@property (nonatomic, weak) id<QQAlertActionDelegate> delegate;
@end

@implementation QQAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(QQAlertActionStyle)style handler:(void (^)(QQAlertAction * _Nonnull))handler {
    QQAlertAction *action = [[QQAlertAction alloc] init];
    action.title = title;
    action.style = style;
    action.handler = handler;
    return action;
}

- (instancetype)init {
    if (self = [super init]) {
        _button = [[QQButton alloc] init];
        _button.adjustsButtonWhenDisabled = NO;
        _button.adjustsButtonWhenHighlighted = NO;
        [_button addTarget:self action:@selector(handleAlertActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    _button.enabled = enabled;
}

- (void)handleAlertActionEvent:(QQButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertActionClicked:)]) {
        [self.delegate alertActionClicked:self];
    }
}

@end

@interface QQAlertController ()<QQModalViewDelegate, QQAlertActionDelegate, UITextFieldDelegate>

// 背景遮罩
@property (nullable, nonatomic, strong) QQModalView *modalView;
@property (nonatomic, assign, readwrite) QQAlertControllerStyle preferredStyle;

// 容器视图
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *scrollWrapView;
@property (nonatomic, strong) UIScrollView *headerScrollView;
@property (nonatomic, strong) UIScrollView *buttonScrollView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) NSMutableArray<QQAlertAction *> *alertActions;
@property (nonatomic, strong) NSMutableArray<QQTextField *> *alertTextFields;
@property (nonatomic, strong) NSMutableArray<QQAlertAction *> *destructiveActions;
@property (nonatomic, strong) QQAlertAction *cancelAction;

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL isWillDismissModalView;
@property (nonatomic, copy) void (^dismissCompletion)(void);

@end

@implementation QQAlertController {
    NSString *_title;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(QQAlertControllerStyle)preferredStyle {
    return [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(QQAlertControllerStyle)preferredStyle {
    if (self = [super init]) {
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        BOOL alertStyle = (preferredStyle == QQAlertControllerStyleAlert);
        
        // 样式
        _alertContainerBackgroundColor = alertStyle ? [UIColor qq_colorWithRGB:@[@247, @247, @247]] : [UIColor clearColor];
        _alertHeaderBackgroundColor = [UIColor qq_colorWithRGB:@[@247, @247, @247]];
        _alertContentMaximumWidth = alertStyle ? 270 : [QQUIHelper deviceWidth] - 20;
        _alertContentCornerRadius = 13.0;
        _alertHeaderInsets = UIEdgeInsetsMake(20, 16, 20, 16);
        _alertSeparatorColor = [UIColor qq_colorWithRGB:@[@80, @80, @80]];
        
        _alertTitleMessageSpacing = 3.0;
        _alertTextFieldMessageSpacing = 10;
        _alertTitleAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
        _alertMessageAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13]};
        
        _alertTextFieldHeight = 43;
        _alertTextFieldsSpecing = 2.0;
        _alertTextFieldFont = [UIFont systemFontOfSize:13];
        _alertTextFieldTextColor = [UIColor blackColor];
        _alertTextFieldBackgroundColor = [UIColor whiteColor];
        
        _alertButtonHeight = alertStyle ? 44.0 : 57.0;
        _alertButtonBackgroundColor = [UIColor qq_colorWithRGB:@[@247, @247, @247]];
        _alertButtonHighlightBackgroundColor = [UIColor qq_colorWithRGB:@[@232, @232, @232]];
        _alertButtonAttributes = @{NSForegroundColorAttributeName:[UIColor qq_colorWithRGB:@[@0, @122, @255]],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        _alertButtonDisabledAttributes = @{NSForegroundColorAttributeName:[UIColor qq_colorWithRGB:@[@129, @129, @129]],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        _alertCancelButtonAttributes = @{NSForegroundColorAttributeName:[UIColor qq_colorWithRGB:@[@0, @122, @255]],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
        _alertDestructiveButtonAttributes = @{NSForegroundColorAttributeName:[UIColor qq_colorWithRGB:@[@250, @58, @58]],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        
        self.preferredStyle = preferredStyle;
        
        self.alertActions = [[NSMutableArray alloc] init];
        self.alertTextFields = [[NSMutableArray alloc] init];
        self.destructiveActions = [[NSMutableArray alloc] init];
        
        self.title = title;
        self.message = message;
        
        self.mainVisualEffectView = [[UIView alloc] init];
        self.cancelButtonVisualEffectView = [[UIView alloc] init];
        self.containerView.backgroundColor = alertStyle ? self.alertContainerBackgroundColor : [UIColor clearColor];
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    QQTextField *firstTextField = self.alertTextFields.firstObject;
    [firstTextField becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.modalView];
    
    [self.containerView addSubview:self.scrollWrapView];
    
    self.headerScrollView.qq_borderColor = self.alertSeparatorColor;
    self.headerScrollView.qq_borderPosition = QQViewBorderPositionBottom;
    self.headerScrollView.qq_borderWidth = QQUIHelper.pixelOne;
    self.headerScrollView.backgroundColor = self.alertHeaderBackgroundColor;
    [self.scrollWrapView addSubview:self.headerScrollView];
    
    self.buttonScrollView.backgroundColor = self.alertButtonBackgroundColor;
    [self.scrollWrapView addSubview:self.buttonScrollView];
    
    __weak __typeof(self)weakSelf = self;
    self.modalView.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
        weakSelf.keyboardHeight = keyboardHeight;
        [weakSelf updateLayout];
    };
    
    self.modalView.showingAnimation = ^(UIView * _Nonnull dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void (^ _Nonnull completion)(BOOL)) {
        if (weakSelf.preferredStyle == QQAlertControllerStyleAlert) {
            dimmingView.alpha = 0;
            weakSelf.containerView.alpha = 0;
            weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
            [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                dimmingView.alpha = 1;
                weakSelf.containerView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (weakSelf.preferredStyle == QQAlertControllerStyleActionSheet) {
            dimmingView.alpha = 0;
            weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
            [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                dimmingView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
    
    self.modalView.hidingAnimation = ^(UIView * _Nullable dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void (^ _Nonnull completion)(BOOL)) {
        if (weakSelf.preferredStyle == QQAlertControllerStyleAlert) {
            [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                dimmingView.alpha = 0;
                weakSelf.containerView.alpha = 0;
            } completion:^(BOOL finished) {
                weakSelf.containerView.alpha = 1;
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (weakSelf.preferredStyle == QQAlertControllerStyleActionSheet) {
            [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                dimmingView.alpha = 0;
                weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!CGRectEqualToRect(self.modalView.frame, self.view.frame)) {
        [self updateTitleLabel];
        [self updateMessageLabel];
        [self updateTextFields];
        [self updateActions];
        [self updateLayout];
        if (!self.modalView.isVisible) {
            [self.modalView showInView:self.view completion:nil];
        }
    }
}

- (void)updateLayout {
    
    if (_isWillDismissModalView || !self.isViewLoaded) return;
    
    /// 这布局算的好恶心🤢
    BOOL hasTitle = (self.titleLabel.text.length > 0 && !self.titleLabel.hidden);
    BOOL hasMessage = (self.messageLabel.text.length > 0 && !self.messageLabel.hidden);
    BOOL hasTextField = self.alertTextFields.count > 0;
    
    CGFloat containerMaximumHeight = self.view.qq_height - (self.view.qq_safeAreaInsets.top + self.view.qq_safeAreaInsets.bottom);
    if (self.keyboardHeight > 0) {
        containerMaximumHeight -= (self.keyboardHeight + 20);
    }
    
    CGRect containerViewFrame = CGRectZero;
    CGFloat lastTop = 0;
    if (self.preferredStyle == QQAlertControllerStyleAlert) {
        CGSize containerSize = CGSizeMake(self.alertContentMaximumWidth, containerMaximumHeight);
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField) ? self.alertHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField) ? self.alertHeaderInsets.bottom : 0;
        
        CGSize headerLimitSize = CGSizeMake(containerSize.width - (contentPaddingLeft + contentPaddingRight), CGFLOAT_MAX);
        
        // 标题
        lastTop = contentPaddingTop;
        if (hasTitle) {
            CGSize titleLabeSize = [self.titleLabel sizeThatFits:headerLimitSize];
            titleLabeSize.width = fmin(headerLimitSize.width, titleLabeSize.width);
            titleLabeSize.height = fmin(headerLimitSize.height, titleLabeSize.height);
            
            self.titleLabel.frame = CGRectMake(contentPaddingLeft, lastTop, headerLimitSize.width, titleLabeSize.height);
            
            lastTop = self.titleLabel.qq_bottom + (hasMessage ? self.alertTitleMessageSpacing : contentPaddingBottom);
        }
        
        // 信息
        if (hasMessage) {
            CGSize messageLabeSize = [self.messageLabel sizeThatFits:headerLimitSize];
            messageLabeSize.width = fmin(headerLimitSize.width, messageLabeSize.width);
            messageLabeSize.height = fmin(headerLimitSize.height, messageLabeSize.height);
            
            self.messageLabel.frame = CGRectMake(contentPaddingLeft, lastTop, headerLimitSize.width, messageLabeSize.height);
            
            lastTop = self.messageLabel.qq_bottom + (hasTextField ? self.alertTextFieldMessageSpacing : contentPaddingBottom);
        }
        
        // 输入框
        if (hasTextField) {
            for (int i = 0; i < self.alertTextFields.count; i++) {
                QQTextField *textField = self.alertTextFields[i];
                CGRect textFieldFrame = CGRectMake(contentPaddingLeft, lastTop, headerLimitSize.width, self.alertTextFieldHeight);
                textField.frame = textFieldFrame;
                lastTop = textField.qq_bottom + self.alertTextFieldsSpecing;
            }
            lastTop += contentPaddingBottom;
        }
        
        // headerScrollView、buttonScrollView
        NSArray *orderedAlertActions = [self orderedAlertActions:self.alertActions];
        
        CGFloat headerScrollViewHeight = lastTop;
        CGFloat buttonScrollViewHeight = 0;
        BOOL buttonVerticalLayout = (orderedAlertActions.count != 2);
        if (buttonVerticalLayout) {
            buttonScrollViewHeight = orderedAlertActions.count * self.alertButtonHeight;
        } else {
            buttonScrollViewHeight = self.alertButtonHeight;
        }
        
        if (headerScrollViewHeight > containerMaximumHeight / 2 && buttonScrollViewHeight > containerMaximumHeight / 2) {
            headerScrollViewHeight = containerMaximumHeight / 2;
            buttonScrollViewHeight = containerMaximumHeight / 2;
        } else {
            CGFloat buttonScrollViewMinHeight = fmin(3 * self.alertButtonHeight, orderedAlertActions.count * self.alertButtonHeight);
            if (!buttonVerticalLayout) {
                buttonScrollViewMinHeight = self.alertButtonHeight;
            }
            
            if (headerScrollViewHeight + buttonScrollViewMinHeight > containerSize.height) {
                headerScrollViewHeight = (containerSize.height - buttonScrollViewMinHeight);
                buttonScrollViewHeight =  buttonScrollViewMinHeight;
            } else {
                buttonScrollViewHeight = fmin(orderedAlertActions.count * self.alertButtonHeight, containerSize.height - headerScrollViewHeight);
                if (!buttonVerticalLayout) {
                    buttonScrollViewHeight = self.alertButtonHeight;
                }
            }
            
        }
        
        if (buttonVerticalLayout) {
            CGFloat buttonTop = 0;
            for (int i = 0; i < orderedAlertActions.count; i++) {
                QQAlertAction *action = orderedAlertActions[i];
                action.button.frame = CGRectMake(0, buttonTop, CGRectGetWidth(self.buttonScrollView.bounds), self.alertButtonHeight);
                action.button.qq_borderPosition = QQViewBorderPositionTop;
                buttonTop = CGRectGetMaxY(action.button.frame);
            }
            
            self.buttonScrollView.contentSize = CGSizeMake(self.buttonScrollView.qq_width, buttonTop);
        } else {
            // 对齐系统，先 add 的在右边，后 add 的在左边
            QQAlertAction *leftAction = orderedAlertActions[1];
            leftAction.button.frame = CGRectMake(0, 0, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
            leftAction.button.qq_borderPosition = QQViewBorderPositionTop|QQViewBorderPositionRight;
            
            QQAlertAction *rightAction = orderedAlertActions[0];
            rightAction.button.frame = CGRectMake(CGRectGetMaxX(leftAction.button.frame), 0, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
            rightAction.button.qq_borderPosition = QQViewBorderPositionTop;
            self.buttonScrollView.contentSize = CGSizeMake(self.buttonScrollView.qq_width, rightAction.button.qq_height);
        }
        
        self.headerScrollView.frame = CGRectMake(0, 0, containerSize.width, headerScrollViewHeight);
        self.headerScrollView.contentSize = CGSizeMake(containerSize.width, lastTop);
        
        self.buttonScrollView.frame = CGRectMake(0, ceil(self.headerScrollView.qq_bottom), containerSize.width, buttonScrollViewHeight);
        
        self.scrollWrapView.frame = CGRectMake(0, 0, containerSize.width, self.buttonScrollView.qq_bottom);
        
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
        
        // 容器
        containerViewFrame = CGRectMake((self.view.qq_width - containerSize.width) / 2, (self.view.qq_height - self.scrollWrapView.qq_bottom - self.keyboardHeight) / 2, containerSize.width, self.scrollWrapView.qq_bottom);
    
        [self.buttonScrollView qq_scrollToBottom];
        
    } else if (self.preferredStyle == QQAlertControllerStyleActionSheet) {
        
        CGSize containerSize = CGSizeMake(self.alertContentMaximumWidth, containerMaximumHeight - 20);
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        CGFloat contentPaddingTop = (hasTitle || hasMessage) ? self.alertHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage) ? self.alertHeaderInsets.bottom : 0;
        
        CGSize headerLimitSize = CGSizeMake(containerSize.width - (contentPaddingLeft + contentPaddingRight), CGFLOAT_MAX);
        
        // 标题
        lastTop = contentPaddingTop;
        if (hasTitle) {
            CGSize titleLabeSize = [self.titleLabel sizeThatFits:headerLimitSize];
            titleLabeSize.width = fmin(headerLimitSize.width, titleLabeSize.width);
            titleLabeSize.height = fmin(headerLimitSize.height, titleLabeSize.height);
            
            self.titleLabel.frame = CGRectMake(contentPaddingLeft, lastTop, headerLimitSize.width, titleLabeSize.height);
            
            lastTop = self.titleLabel.qq_bottom + (hasMessage ? self.alertTitleMessageSpacing : contentPaddingBottom);
        }
        
        // 信息
        if (hasMessage) {
            CGSize messageLabeSize = [self.messageLabel sizeThatFits:headerLimitSize];
            messageLabeSize.width = fmin(headerLimitSize.width, messageLabeSize.width);
            messageLabeSize.height = fmin(headerLimitSize.height, messageLabeSize.height);
            
            self.messageLabel.frame = CGRectMake(contentPaddingLeft, lastTop, headerLimitSize.width, messageLabeSize.height);
            
            lastTop = self.messageLabel.qq_bottom + contentPaddingBottom;
        }
        
        
        NSMutableArray<QQAlertAction *> *newOrderActions = [[self orderedAlertActions:self.alertActions] mutableCopy];
        
        // headerScrollView、buttonScrollView
        BOOL hasCancelButton = (self.cancelAction != nil);
        if (hasCancelButton) {
            containerSize.height -= (self.alertButtonHeight + 20);
        }
        CGFloat actionButtonMinHeight = 0;
        CGFloat buttonScrollViewMinHeight = 0;
        if (hasCancelButton) {
            actionButtonMinHeight += self.alertButtonHeight;
            [newOrderActions removeObject:self.cancelAction];
        }
        if (newOrderActions.count == 1) {
            buttonScrollViewMinHeight = self.alertButtonHeight;
            actionButtonMinHeight += buttonScrollViewMinHeight;
        } else if (newOrderActions.count > 1) {
            buttonScrollViewMinHeight = (self.alertButtonHeight * 2);
            actionButtonMinHeight += buttonScrollViewMinHeight;
        }
        
        // 限制 headerScrollView、buttonScrollView 高度
        CGFloat headerScrollViewHeight = lastTop;
        CGFloat buttonScrollViewHeight = 0;
        if (headerScrollViewHeight + actionButtonMinHeight > containerSize.height) {
            headerScrollViewHeight = (containerSize.height - buttonScrollViewMinHeight);
            buttonScrollViewHeight =  buttonScrollViewMinHeight;
        } else {
            buttonScrollViewHeight = fmin(self.alertButtonHeight * newOrderActions.count, containerSize.height - headerScrollViewHeight);
        }
        
        // 布局按钮
        CGFloat buttonTop = 0;
        for (int i = 0; i < newOrderActions.count; i++) {
            QQAlertAction *action = newOrderActions[i];
            action.button.frame = CGRectMake(0, buttonTop, containerSize.width, self.alertButtonHeight);
            action.button.qq_borderPosition = QQViewBorderPositionTop;
            buttonTop = CGRectGetMaxY(action.button.frame);
        }

        self.headerScrollView.frame = CGRectMake(0, 0, containerSize.width, headerScrollViewHeight);
        self.headerScrollView.contentSize = CGSizeMake(containerSize.width, lastTop);
        
        self.buttonScrollView.frame = CGRectMake(0, self.headerScrollView.qq_bottom, containerSize.width, buttonScrollViewHeight);
        self.buttonScrollView.contentSize = CGSizeMake(containerSize.width, buttonTop);
        
        // 取消按钮
        if (hasCancelButton) {
            self.cancelButtonVisualEffectView.frame = CGRectMake(0, self.buttonScrollView.qq_bottom + 10, containerSize.width, self.alertButtonHeight);
            self.cancelButtonVisualEffectView.layer.cornerRadius = self.alertContentCornerRadius;
            
            self.cancelAction.button.frame = self.cancelButtonVisualEffectView.bounds;
        }
        
        self.scrollWrapView.frame = CGRectMake(0, 0, containerSize.width, self.buttonScrollView.qq_bottom);
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
    
        // 容器
        CGFloat containerViewHeight = hasCancelButton ? self.cancelButtonVisualEffectView.qq_bottom : self.scrollWrapView.qq_bottom;
        containerViewFrame = CGRectMake((self.view.qq_width - containerSize.width) / 2, (self.view.qq_height - containerViewHeight - 10 - self.view.qq_safeAreaInsets.bottom), containerSize.width, containerViewHeight);
    }
    
    if (self.buttonScrollView.qq_canScroll) {
        self.headerScrollView.qq_borderPosition = QQViewBorderPositionBottom;
    } else {
        self.headerScrollView.qq_borderPosition = QQViewBorderPositionNone;
    }
    
    self.containerView.frame = containerViewFrame;
    if (self.preferredStyle == QQAlertControllerStyleAlert) {
        self.modalView.modalAnimationStyle = QQModalAnimationStyleFade;
        self.modalView.dismissWhenTapDimmingView = NO;
    } else if (self.preferredStyle == QQAlertControllerStyleActionSheet) {
        self.modalView.modalAnimationStyle = QQModalAnimationStyleSheet;
        self.modalView.dismissWhenTapDimmingView = YES;
    }
    self.modalView.contentView = self.containerView;
    self.modalView.contentViewMargins = UIEdgeInsetsZero;
    self.modalView.frame = self.view.bounds;
}

- (NSArray<QQAlertAction *> *)orderedAlertActions:(NSArray<QQAlertAction *> *)actions {
    NSMutableArray<QQAlertAction *> *newActions = [[NSMutableArray alloc] init];
    for (QQAlertAction *action in self.alertActions) {
        if (action.style != QQAlertActionStyleCancel && action.style != QQAlertActionStyleDestructive) {
            [newActions addObject:action];
        }
    }
    for (QQAlertAction *action in self.destructiveActions) {
        [newActions addObject:action];
    }
    if (self.cancelAction) {
        [newActions addObject:self.cancelAction];
    }
    return newActions;
}

- (void)addAction:(QQAlertAction *)action {
    if (action.style == QQAlertActionStyleCancel && self.cancelAction) {
        // 同一个alertController不可以同时添加两个cancel按钮
        return;
    }
    if (action.style == QQAlertActionStyleCancel) {
        self.cancelAction = action;
    }
    if (action.style == QQAlertActionStyleDestructive) {
        [self.destructiveActions addObject:action];
    }
    
    // 只有ActionSheet的取消按钮不参与滚动
    if (self.preferredStyle == QQAlertControllerStyleActionSheet && action.style == QQAlertActionStyleCancel) {
        if (!self.cancelButtonVisualEffectView.superview) {
            [self.containerView addSubview:self.cancelButtonVisualEffectView];
        }
        if ([self.cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)self.cancelButtonVisualEffectView).contentView addSubview:action.button];
        } else {
            [self.cancelButtonVisualEffectView addSubview:action.button];
        }
    } else {
        [self.buttonScrollView addSubview:action.button];
    }
    action.delegate = self;
    [self.alertActions addObject:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(QQTextField * _Nonnull))configurationHandler {
    if (self.preferredStyle == QQAlertControllerStyleActionSheet) {
        // Sheet类型不允许添加UITextField
        return;
    }
    
    QQTextField *textField = [[QQTextField alloc] init];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = self.alertTextFieldBackgroundColor;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = self.alertTextFieldFont;
    textField.textColor = self.alertTextFieldTextColor;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.textInsets = UIEdgeInsetsMake(4, 7, 4, 7);
    [self.headerScrollView addSubview:textField];
    [self.alertTextFields addObject:textField];
    if (configurationHandler) {
        configurationHandler(textField);
    }
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

#pragma mark - QQAlertActionDelegate
- (void)alertActionClicked:(QQAlertAction *)action {
    [self.modalView dismiss];
}

#pragma mark - Getters & Setters
- (QQModalView *)modalView {
    if (!_modalView) {
        _modalView = [[QQModalView alloc] init];
        _modalView.delegate = self;
    }
    return _modalView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (UIView *)scrollWrapView {
    if (!_scrollWrapView) {
        _scrollWrapView = [[UIView alloc] init];
    }
    return _scrollWrapView;
}

- (UIScrollView *)headerScrollView {
    if (!_headerScrollView) {
        _headerScrollView = [[UIScrollView alloc] init];
        _headerScrollView.scrollsToTop = NO;
        if (@available(iOS 11, *)) {
            _headerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _headerScrollView;
}

- (UIScrollView *)buttonScrollView {
    if (!_buttonScrollView) {
        _buttonScrollView = [[UIScrollView alloc] init];
        _buttonScrollView.scrollsToTop = NO;
        if (@available(iOS 11, *)) {
            _buttonScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _buttonScrollView;
}

- (void)setMainVisualEffectView:(UIView *)mainVisualEffectView {
    if (!mainVisualEffectView) {
        // 不允许为空
        mainVisualEffectView = [[UIView alloc] init];
    }
    BOOL isValueChanged = _mainVisualEffectView != mainVisualEffectView;
    if (isValueChanged) {
        if ([_mainVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)_mainVisualEffectView).contentView qq_removeAllSubviews];
        } else {
            [_mainVisualEffectView qq_removeAllSubviews];
        }
        [_mainVisualEffectView removeFromSuperview];
        _mainVisualEffectView = nil;
    }
    _mainVisualEffectView = mainVisualEffectView;
    if (isValueChanged) {
        [self.scrollWrapView insertSubview:_mainVisualEffectView atIndex:0];
        [self updateCornerRadius];
    }
}

- (void)setCancelButtonVisualEffectView:(UIView *)cancelButtonVisualEffectView {
    if (!cancelButtonVisualEffectView) {
        // 不允许为空
        cancelButtonVisualEffectView = [[UIView alloc] init];
    }
    BOOL isValueChanged = _cancelButtonVisualEffectView != cancelButtonVisualEffectView;
    if (isValueChanged) {
        if ([_cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)_cancelButtonVisualEffectView).contentView qq_removeAllSubviews];
        } else {
            [_cancelButtonVisualEffectView qq_removeAllSubviews];
        }
        [_cancelButtonVisualEffectView removeFromSuperview];
        _cancelButtonVisualEffectView = nil;
    }
    _cancelButtonVisualEffectView = cancelButtonVisualEffectView;
    if (isValueChanged) {
        [self.containerView addSubview:_cancelButtonVisualEffectView];
        if (self.preferredStyle == QQAlertControllerStyleActionSheet && self.cancelAction && !self.cancelAction.button.superview) {
            if ([_cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
                UIVisualEffectView *effectView = (UIVisualEffectView *)_cancelButtonVisualEffectView;
                [effectView.contentView addSubview:self.cancelAction.button];
            } else {
                [_cancelButtonVisualEffectView addSubview:self.cancelAction.button];
            }
        }
        
        [self updateCornerRadius];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.headerScrollView addSubview:_titleLabel];
    }
    if (!_title || _title.length == 0) {
        _titleLabel.hidden = YES;
    } else {
        _titleLabel.hidden = NO;
    }
}

- (NSString *)title {
    return _title;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.headerScrollView addSubview:_messageLabel];
    }
    if (!_message || _message.length == 0) {
        self.messageLabel.hidden = YES;
    } else {
        self.messageLabel.hidden = NO;
        [self updateMessageLabel];
    }
}

- (NSArray<QQAlertAction *> *)actions {
    return [self.alertActions copy];
}

#pragma mark - 设置 alertContent 样式

- (void)setAlertContainerBackgroundColor:(UIColor *)alertContainerBackgroundColor {
    _alertContainerBackgroundColor = alertContainerBackgroundColor;
    self.containerView.backgroundColor = alertContainerBackgroundColor;
}

- (void)setAlertHeaderBackgroundColor:(UIColor *)alertHeaderBackgroundColor {
    _alertHeaderBackgroundColor = alertHeaderBackgroundColor;
    self.headerScrollView.backgroundColor = alertHeaderBackgroundColor;
}

- (void)setAlertContentMaximumWidth:(CGFloat)alertContentMaximumWidth {
    if (_alertContentMaximumWidth != alertContentMaximumWidth) {
        _alertContentMaximumWidth = alertContentMaximumWidth;
        [self updateLayout];
    }
}

- (void)setAlertContentCornerRadius:(CGFloat)alertContentCornerRadius {
    if (_alertContentCornerRadius != alertContentCornerRadius) {
        _alertContentCornerRadius = alertContentCornerRadius;
        [self updateCornerRadius];
    }
}

- (void)setAlertHeaderInsets:(UIEdgeInsets)alertHeaderInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_alertHeaderInsets, alertHeaderInsets)) {
        _alertHeaderInsets = alertHeaderInsets;
        [self updateLayout];
    }
}

- (void)setAlertTitleMessageSpacing:(CGFloat)alertTitleMessageSpacing {
    if (_alertTitleMessageSpacing != alertTitleMessageSpacing) {
        _alertTitleMessageSpacing = alertTitleMessageSpacing;
        [self updateLayout];
    }
}

- (void)setAlertTextFieldMessageSpacing:(CGFloat)alertTextFieldMessageSpacing {
    if (_alertTextFieldMessageSpacing != alertTextFieldMessageSpacing) {
        _alertTextFieldMessageSpacing = alertTextFieldMessageSpacing;
        [self updateLayout];
    }
}

- (void)setAlertTitleAttributes:(NSDictionary<NSAttributedStringKey,id> *)alertTitleAttributes {
    _alertTitleAttributes = alertTitleAttributes;
    [self updateTitleLabel];
}

- (void)setAlertMessageAttributes:(NSDictionary<NSAttributedStringKey,id> *)alertMessageAttributes {
    _alertMessageAttributes = alertMessageAttributes;
    [self updateMessageLabel];
}

#pragma mark - 设置TextField样式
- (void)setAlertTextFieldHeight:(CGFloat)alertTextFieldHeight {
    if (_alertTextFieldHeight != alertTextFieldHeight) {
        _alertTextFieldHeight = alertTextFieldHeight;
        [self updateLayout];
    }
}

- (void)setAlertTextFieldsSpecing:(CGFloat)alertTextFieldsSpecing {
    if (_alertTextFieldsSpecing != alertTextFieldsSpecing) {
        _alertTextFieldsSpecing = alertTextFieldsSpecing;
        [self updateLayout];
    }
}

- (void)setAlertTextFieldFont:(UIFont *)alertTextFieldFont {
    if (_alertTextFieldFont != alertTextFieldFont) {
        _alertTextFieldFont = alertTextFieldFont;
        [self updateTextFields];
    }
}

- (void)setAlertTextFieldTextColor:(UIColor *)alertTextFieldTextColor {
    if (_alertTextFieldTextColor != alertTextFieldTextColor) {
        _alertTextFieldTextColor = alertTextFieldTextColor;
        [self updateTextFields];
    }
}

- (void)setAlertTextFieldBackgroundColor:(UIColor *)alertTextFieldBackgroundColor {
    if (_alertTextFieldBackgroundColor != alertTextFieldBackgroundColor) {
        _alertTextFieldBackgroundColor = alertTextFieldBackgroundColor;
        [self updateTextFields];
    }
}

#pragma mark - 设置按钮样式
- (void)setAlertButtonHeight:(CGFloat)alertButtonHeight {
    if (_alertButtonHeight != alertButtonHeight) {
        _alertButtonHeight = alertButtonHeight;
        [self updateLayout];
    }
}

- (void)setAlertButtonBackgroundColor:(UIColor *)alertButtonBackgroundColor {
    if (_alertButtonBackgroundColor != alertButtonBackgroundColor) {
        _alertButtonBackgroundColor = alertButtonBackgroundColor;
        [self updateActions];
    }
}

- (void)setAlertButtonHighlightBackgroundColor:(UIColor *)alertButtonHighlightBackgroundColor {
    if (_alertButtonHighlightBackgroundColor != alertButtonHighlightBackgroundColor) {
        _alertButtonHighlightBackgroundColor = alertButtonHighlightBackgroundColor;
        [self updateActions];
    }
}

- (void)setAlertSeparatorColor:(UIColor *)alertSeparatorColor {
    if (_alertSeparatorColor != alertSeparatorColor) {
        _alertSeparatorColor = alertSeparatorColor;
        self.headerScrollView.qq_borderColor = self.alertSeparatorColor;
        [self updateActions];
    }
}

- (void)setAlertButtonAttributes:(NSDictionary<NSAttributedStringKey,id> *)alertButtonAttributes {
    _alertButtonAttributes = alertButtonAttributes;
    [self updateActions];
}

- (void)setAlertButtonDisabledAttributes:(NSDictionary<NSAttributedStringKey,id> *)alertButtonDisabledAttributes {
    _alertButtonDisabledAttributes = alertButtonDisabledAttributes;
    [self updateActions];
}

- (void)setAlertCancelButtonAttributes:(NSDictionary<NSAttributedStringKey,id> *)alertCancelButtonAttributes {
    _alertCancelButtonAttributes = alertCancelButtonAttributes;
    [self updateActions];
}

- (void)setAlertDestructiveButtonAttributes:(NSDictionary<NSAttributedStringKey,id> *)alertDestructiveButtonAttributes {
    _alertDestructiveButtonAttributes = alertDestructiveButtonAttributes;
    [self updateActions];
}

- (void)updateTitleLabel {
    if (self.titleLabel && !self.titleLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.title attributes:self.alertTitleAttributes];
        self.titleLabel.attributedText = attributeString;
    }
}

- (void)updateMessageLabel {
    if (self.messageLabel && !self.messageLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.message attributes:self.alertMessageAttributes];
        self.messageLabel.attributedText = attributeString;
    }
}

- (void)updateTextFields {
    for (QQTextField *textField in self.textFields) {
        textField.backgroundColor = self.alertTextFieldBackgroundColor;
        textField.font = self.alertTextFieldFont;
        textField.textColor = self.alertTextFieldTextColor;
    }
}

- (void)updateActions {
    for (QQAlertAction *alertAction in self.alertActions) {
        
        UIColor *backgroundColor = self.alertButtonBackgroundColor;
        UIColor *highlightBackgroundColor = self.alertButtonHighlightBackgroundColor ;
        UIColor *borderColor = self.alertSeparatorColor;
        
        alertAction.button.backgroundColor = backgroundColor;
        alertAction.button.highlightedBackgroundColor = highlightBackgroundColor;
        alertAction.button.qq_borderColor = borderColor;
        alertAction.button.qq_borderWidth = QQUIHelper.pixelOne;
        
        NSAttributedString *attributeString = nil;
        if (alertAction.style == QQAlertActionStyleCancel) {
        
            NSDictionary *attributes = self.alertCancelButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else if (alertAction.style == QQAlertActionStyleDestructive) {
            
            NSDictionary *attributes = self.alertDestructiveButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else {
            
            NSDictionary *attributes = self.alertButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        }
        
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateNormal];
        
        NSDictionary *attributes = self.alertButtonDisabledAttributes;
        if (alertAction.buttonDisabledAttributes) {
            attributes = alertAction.buttonDisabledAttributes;
        }
        
        attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateDisabled];
        
        if ([alertAction.button imageForState:UIControlStateNormal]) {
            NSRange range = NSMakeRange(0, attributeString.length);
            UIColor *disabledColor = [attributeString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
            [alertAction.button setImage:[[alertAction.button imageForState:UIControlStateNormal] qq_imageWithTintColor:disabledColor] forState:UIControlStateDisabled];
        }
    }
}

- (void)updateCornerRadius {
    if (self.preferredStyle == QQAlertControllerStyleAlert) {
        if (self.containerView) { self.containerView.layer.cornerRadius = self.alertContentCornerRadius; self.containerView.clipsToBounds = YES; }
        if (self.cancelButtonVisualEffectView) { self.cancelButtonVisualEffectView.layer.cornerRadius = self.alertContentCornerRadius; self.cancelButtonVisualEffectView.clipsToBounds = NO;}
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = 0; self.scrollWrapView.clipsToBounds = NO; }
    } else if (self.preferredStyle == QQAlertControllerStyleActionSheet) {
        if (self.containerView) { self.containerView.layer.cornerRadius = 0; self.containerView.clipsToBounds = NO; }
        if (self.cancelButtonVisualEffectView) { self.cancelButtonVisualEffectView.layer.cornerRadius = self.alertContentCornerRadius; self.cancelButtonVisualEffectView.clipsToBounds = YES; }
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = self.alertContentCornerRadius; self.scrollWrapView.clipsToBounds = YES; }
    }
}

@end
