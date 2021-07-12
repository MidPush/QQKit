//
//  QQModalViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/7/10.
//

#import "QQModalViewController.h"
#import "QQModalView.h"

@interface QQModalViewController ()<QQModalViewDelegate>

@property (nonatomic, strong) QQModalView *modalView;
@property (nonatomic, assign) BOOL isWillDismissModalView;

@end

@implementation QQModalViewController

- (QQModalView *)modalView {
    if (!_modalView) {
        _modalView = [[QQModalView alloc] init];
        _modalView.delegate = self;
    }
    return _modalView;
}

- (instancetype)init {
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCustom;
        _hidesWhenTapDimmingView = YES;
        _modalAnimationStyle = QQModalAnimationStyleFade;
    }
    return self;
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
    self.modalView.frame = self.view.bounds;
    [self.modalView updateLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.modalView.contentView = self.contentView;
    self.modalView.dismissWhenTapDimmingView = self.hidesWhenTapDimmingView;
    self.modalView.modalAnimationStyle = self.modalAnimationStyle;
    self.modalView.dimmingView = self.dimmingView;
    self.modalView.layoutBlock = self.layoutBlock;
}

- (void)setContentView:(UIView *)contentView {
    _contentView = contentView;
    self.modalView.contentView = contentView;
    [self.modalView updateLayout];
}

- (void)setDimmingView:(UIView *)dimmingView {
    self.modalView.dimmingView = dimmingView;
    [self.modalView updateLayout];
}

- (UIView *)dimmingView {
    return _modalView.dimmingView;
}

- (void)setHidesWhenTapDimmingView:(BOOL)hidesWhenTapDimmingView {
    _hidesWhenTapDimmingView = hidesWhenTapDimmingView;
    self.modalView.dismissWhenTapDimmingView = hidesWhenTapDimmingView;
}

- (void)setModalAnimationStyle:(QQModalAnimationStyle)modalAnimationStyle {
    _modalAnimationStyle = modalAnimationStyle;
    self.modalView.modalAnimationStyle = modalAnimationStyle;
}

- (void)setLayoutBlock:(void (^)(CGRect, CGFloat, CGRect))layoutBlock {
    _layoutBlock = layoutBlock;
    self.modalView.layoutBlock = layoutBlock;
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
    [self.modalView dismiss];
}

#pragma mark - QQModalViewDelegate
- (void)willDismissModalView:(QQModalView *)modalView {
    _isWillDismissModalView = YES;
}

- (void)didDismissModalView:(QQModalView *)modalView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}

@end
