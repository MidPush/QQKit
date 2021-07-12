//
//  QQAlertController.m
//  QQKitDemo
//
//  Created by Mac on 2021/7/12.
//

#import "QQAlertController.h"
#import "QQModalView.h"
#import "UIView+QQExtension.h"

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
        
        // 样式
        self.alertContainerBackgroundColor = preferredStyle == QQAlertControllerStyleAlert ? [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0] : [UIColor clearColor];
        self.alertHeaderBackgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        self.alertContentMaximumWidth = preferredStyle == QQAlertControllerStyleAlert ? 270 : [QQUIHelper deviceWidth] - 20;
        self.alertContentCornerRadius = 13.0;
        self.alertHeaderInsets = UIEdgeInsetsMake(20, 16, 20, 16);
        self.alertTitleMessageSpacing = 3.0;
        self.alertTitleAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
        self.alertMessageAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13]};
        self.alertTextFieldHeight = 40;
        self.alertTextFieldFont = [UIFont systemFontOfSize:13];
        self.alertTextFieldTextColor = [UIColor blackColor];
        self.alertButtonHeight = 44.0;
        self.alertButtonBackgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        self.alertButtonHighlightBackgroundColor = [UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1.0];
        self.alertSeparatorColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:219.0/255.0 alpha:1.0];
        self.alertButtonAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1.0],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        self.alertButtonDisabledAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:129.0/255.0 green:129/255.0 blue:129/255.0 alpha:1.0],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        self.alertCancelButtonAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1.0],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        self.alertDestructiveButtonAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:250.0/255.0 green:58.0/255.0 blue:58.0/255.0 alpha:1.0],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        
        //
        self.preferredStyle = preferredStyle;
        
        self.alertActions = [[NSMutableArray alloc] init];
        self.alertTextFields = [[NSMutableArray alloc] init];
        self.destructiveActions = [[NSMutableArray alloc] init];
        
        self.title = title;
        self.message = message;
        
        self.mainVisualEffectView = [[UIView alloc] init];
        self.cancelButtonVisualEffectView = [[UIView alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.modalView];
    
    self.containerView.backgroundColor = self.alertContainerBackgroundColor;
    [self.containerView addSubview:self.scrollWrapView];
    
    self.headerScrollView.backgroundColor = self.alertHeaderBackgroundColor;
    [self.scrollWrapView addSubview:self.headerScrollView];
    
    self.buttonScrollView.backgroundColor = self.alertButtonBackgroundColor;
    [self.scrollWrapView addSubview:self.buttonScrollView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateTitleLabel];
    [self updateMessageLabel];
    [self updateActions];
    [self updateLayout];
    if (!self.modalView.isVisible) {
        [self.modalView showInView:self.view completion:nil];
    }
}

- (void)updateLayout {
    
    if (_isWillDismissModalView) return;
    
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
        
        CGFloat buttonScrollViewHeight = 0;
        BOOL buttonVerticalLayout = (self.alertActions.count != 2);
        if (self.alertActions.count > 0 && self.alertActions.count <= 2) {
            buttonScrollViewHeight = self.alertButtonHeight;
        } else if (self.alertActions.count > 2) {
            buttonScrollViewHeight = self.alertButtonHeight * 3;
        }
        if (buttonScrollViewHeight == 0) {
            self.buttonScrollView.hidden = YES;
            self.buttonScrollView.frame = CGRectZero;
        } else {
            self.buttonScrollView.hidden = NO;
            self.buttonScrollView.frame = CGRectMake(0, 0, containerSize.width, buttonScrollViewHeight);
            
            if (buttonVerticalLayout) {
                CGFloat buttonTop = 0;
                for (int i = 0; i < self.alertActions.count; i++) {
                    QQAlertAction *action = self.alertActions[i];
                    action.button.frame = CGRectMake(0, buttonTop, CGRectGetWidth(self.buttonScrollView.bounds), self.alertButtonHeight);
                    action.button.qq_borderPosition = QQViewBorderPositionTop;
                    buttonTop = CGRectGetMaxY(action.button.frame);
                }
                
                self.buttonScrollView.contentSize = CGSizeMake(self.buttonScrollView.qq_width, buttonTop);
            } else {
                // 对齐系统，先 add 的在右边，后 add 的在左边
                QQAlertAction *leftAction = self.alertActions[1];
                leftAction.button.frame = CGRectMake(0, 0, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
                leftAction.button.qq_borderPosition = QQViewBorderPositionTop|QQViewBorderPositionRight;
                
                QQAlertAction *rightAction = self.alertActions[0];
                rightAction.button.frame = CGRectMake(CGRectGetMaxX(leftAction.button.frame), 0, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
                rightAction.button.qq_borderPosition = QQViewBorderPositionTop;
                
                self.buttonScrollView.contentSize = CGSizeMake(self.buttonScrollView.qq_width, rightAction.button.qq_height);
            }
        }
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField) ? self.alertHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField) ? self.alertHeaderInsets.bottom : 0;
        
        CGSize headerLimitSize = CGSizeMake(containerSize.width - (contentPaddingLeft + contentPaddingRight), CGFLOAT_MAX);
        
        lastTop = contentPaddingTop;
        if (hasTitle) {
            CGSize titleLabeSize = [self.titleLabel sizeThatFits:headerLimitSize];
            titleLabeSize.width = fmin(headerLimitSize.width, titleLabeSize.width);
            titleLabeSize.height = fmin(headerLimitSize.height, titleLabeSize.height);
            
            self.titleLabel.frame = CGRectMake(contentPaddingLeft, lastTop, headerLimitSize.width, titleLabeSize.height);
            
            lastTop = self.titleLabel.qq_bottom + (hasMessage ? self.alertTitleMessageSpacing : contentPaddingBottom);
        }
        
        if (hasMessage) {
            CGSize messageLabeSize = [self.messageLabel sizeThatFits:headerLimitSize];
            messageLabeSize.width = fmin(headerLimitSize.width, messageLabeSize.width);
            messageLabeSize.height = fmin(headerLimitSize.height, messageLabeSize.height);
            
            self.messageLabel.frame = CGRectMake(contentPaddingLeft, lastTop, headerLimitSize.width, messageLabeSize.height);
            
            lastTop = self.titleLabel.qq_bottom + contentPaddingBottom;
        }
        
        if (hasTextField) {
            for (int i = 0; i < self.alertTextFields.count; i++) {
                QQTextField *textField = self.alertTextFields[i];
                CGRect textFieldFrame = CGRectMake(contentPaddingLeft, lastTop, headerLimitSize.width, self.alertTextFieldHeight);
                textField.frame = textFieldFrame;
                lastTop = textField.qq_bottom;
            }
        }
        
        CGFloat headerScrollViewHeight = lastTop + contentPaddingBottom;
        headerScrollViewHeight = fmin(headerScrollViewHeight, containerSize.height - buttonScrollViewHeight);
        
        
        self.headerScrollView.frame = CGRectMake(0, 0, containerSize.width, headerScrollViewHeight);
        
        self.buttonScrollView.frame = CGRectMake(0, self.headerScrollView.qq_bottom, containerSize.width, buttonScrollViewHeight);
        
        self.scrollWrapView.frame = CGRectMake(0, 0, containerSize.width, self.buttonScrollView.qq_bottom);
        
        containerViewFrame = CGRectMake(0, 0, containerSize.width, self.scrollWrapView.qq_bottom);
    }
    
    self.containerView.frame = containerViewFrame;
    self.modalView.contentView = self.containerView;
    self.modalView.dismissWhenTapDimmingView = NO;
    self.modalView.frame = self.view.bounds;
    [self.modalView updateLayout];
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
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor whiteColor];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:13];
    textField.textColor = [UIColor blackColor];
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

- (void)updateTitleLabel {
    if (self.titleLabel && !self.titleLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.title attributes:self.alertTitleAttributes];
        self.titleLabel.attributedText = attributeString;
    }
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

- (void)updateMessageLabel {
    if (self.messageLabel && !self.messageLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.message attributes:self.alertMessageAttributes];
        self.messageLabel.attributedText = attributeString;
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
