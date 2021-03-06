//
//  QQWebViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/7/8.
//

#import "QQWebViewController.h"
#import "QQUIHelper.h"
#import "UIView+QQExtension.h"
#import "UIColor+QQExtension.h"
#import "CALayer+QQExtension.h"
#import "QQNavigationButton.h"
#import "QQButton.h"
#import "QQAlertController.h"

@interface QQWebProgressView : UIView

@property (nonatomic, strong, nullable) UIColor *trackTintColor;
@property (nonatomic, strong, nullable) UIColor *progressTintColor;
@property (nonatomic, assign) CGFloat progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@property (nonatomic, strong) CALayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation QQWebProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _trackLayer = [[CALayer alloc] init];
        [_trackLayer qq_removeDefaultAnimations];
        [self.layer addSublayer:_trackLayer];
        
        _progressLayer = [[CAShapeLayer alloc] init];
        [_progressLayer qq_removeDefaultAnimations];
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    _trackLayer.frame = self.layer.bounds;
    _progressLayer.frame = CGRectMake(0, 0, self.layer.bounds.size.width * self.progress, self.layer.bounds.size.height);
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    _progressLayer.backgroundColor = progressTintColor.CGColor;
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    _trackLayer.backgroundColor = trackTintColor.CGColor;
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    CGFloat pinnedProgress = MIN(MAX(progress, 0.0), 1.0);
    _progress = progress;
    if (animated) {
        CABasicAnimation *animation = [self.progressLayer animationForKey:@"progress"];
        if (!animation) {
            animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        }
        animation.duration = fabs(self.progress - pinnedProgress);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fillMode = kCAFillModeForwards;
        animation.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 0, self.layer.bounds.size.height)];
        animation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.layer.bounds.size.width * self.progress, self.layer.bounds.size.height)];
        animation.beginTime = CACurrentMediaTime();
        [self.progressLayer addAnimation:animation forKey:@"progress"];
    } else {
        self.progressLayer.frame = CGRectMake(0, 0, self.layer.bounds.size.width * self.progress, self.layer.bounds.size.height);
    }
}

- (void)dealloc {
    [self.progressLayer removeAnimationForKey:@"progress"];
}

@end

@interface QQWebToolBar : UITabBar

@property (nonatomic, assign, getter=isShowing) BOOL showing;
@property (nonatomic, strong) QQButton *backwardButton;
@property (nonatomic, strong) QQButton *forwardButton;

@end

@implementation QQWebToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _backwardButton = [[QQButton alloc] init];
        _backwardButton.enabled = NO;
        [self addSubview:_backwardButton];
        
        _forwardButton = [[QQButton alloc] init];
        _forwardButton.enabled = NO;
        [self addSubview:_forwardButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat buttonHeight = QQUIHelper.tabBarHeight - QQUIHelper.deviceSafeAreaInsets.bottom;
    CGFloat buttonWidth = 44.0;
    CGFloat buttonSpace = 50.0;
    _backwardButton.frame = CGRectMake(self.qq_centerX - buttonWidth - buttonSpace / 2, 0, buttonWidth, buttonHeight);
    _forwardButton.frame = CGRectMake(self.qq_centerX + buttonSpace / 2, 0, buttonWidth, buttonHeight);
}

@end

@interface QQWebViewController ()<WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@property (nonatomic, strong, readwrite) WKWebView *webView;
@property (nonatomic, strong) QQWebProgressView *progressView;
@property (nonatomic, strong) QQWebToolBar *toolBar;
@property (nonatomic, strong) UILabel *hostLabel;

@property (nonatomic, assign) CGPoint beginContentOffset;

@end

@implementation QQWebViewController

- (void)dealloc {
    [self removeObservers];
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = self.configuration;
        if (!configuration) {
            configuration = [[WKWebViewConfiguration alloc] init];
            configuration.allowsInlineMediaPlayback = YES;
            
            WKPreferences *preferences = [[WKPreferences alloc] init];
            preferences.javaScriptCanOpenWindowsAutomatically = YES;
            configuration.preferences = preferences;
        }

        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.scrollView.delegate = self;
    }
    return _webView;
}

- (QQWebProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[QQWebProgressView alloc] init];
        _progressView.trackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        _progressView.progressTintColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1.0];
    }
    return _progressView;
}

- (QQWebToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[QQWebToolBar alloc] init];
        [_toolBar.backwardButton addTarget:self action:@selector(onToolBarBackwardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.forwardButton addTarget:self action:@selector(onToolBarForwardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self updateToolBarItems];
    }
    return _toolBar;
}

- (UILabel *)hostLabel {
    if (!_hostLabel) {
        _hostLabel = [[UILabel alloc] init];
        _hostLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        _hostLabel.font = [UIFont systemFontOfSize:13];
        _hostLabel.textAlignment = NSTextAlignmentCenter;
        _hostLabel.alpha = 0.0;
    }
    return _hostLabel;
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL configuration:nil];
}

- (instancetype)initWithURL:(NSURL *)URL configuration:(WKWebViewConfiguration *)configuration {
    if (self = [super init]) {
        _URL = URL;
        _configuration = configuration;
        _showsToolbar = YES;
        _hidesToolbarOnSwipe = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        UIPanGestureRecognizer *panGesture = [self getFullScreenPopGesture];
        if (panGesture) {
            panGesture.enabled = YES;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ????????????????????? contentInset???????????????????????????????????????BUG?????????????????????????????????????????????
    if (@available(iOS 11.0, *)) {
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.hostLabel];
    
    [self addObservers];
    [self showToolBarsIfNeeded:NO];
    [self updateNavigationBarItems];
    [self updateToolBarItems];
    
    [self loadRequest];
}

- (void)loadRequest {
    if (!_URL) return;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_URL];
    [self.webView loadRequest:request];
}

- (CGFloat)getWebViewMinY {
    CGFloat webViewMinY = 0;
    if (self.navigationController.navigationBar && self.navigationController.navigationBar.translucent && !self.navigationController.navigationBarHidden && !self.navigationController.navigationBar.hidden) {
        webViewMinY = self.navigationController.navigationBar.qq_bottom;
    }
    return webViewMinY;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!CGSizeEqualToSize(self.webView.bounds.size, CGSizeMake(self.view.qq_width, self.toolBar.qq_top - self.webView.qq_top))) {
        CGFloat webViewY = [self getWebViewMinY];
        CGFloat toolbarTop = self.view.qq_height;
        if (self.showsToolbar) {
            if (self.toolBar.isShowing) {
                toolbarTop = self.view.qq_height - QQUIHelper.tabBarHeight;
            }
            self.toolBar.frame = CGRectMake(0, toolbarTop, self.view.qq_width, QQUIHelper.tabBarHeight);
        }
        self.webView.frame = CGRectMake(0, webViewY, self.view.qq_width, toolbarTop - webViewY);
        self.progressView.frame = CGRectMake(0, webViewY, self.view.qq_width, 2.0);
        if (webViewY == 0) {
            self.hostLabel.frame = CGRectMake(10, self.view.qq_safeAreaInsets.top + 10, self.view.qq_width - 20, self.hostLabel.qq_height);
        } else {
            self.hostLabel.frame = CGRectMake(10, self.webView.qq_top + 10, self.view.qq_width - 20, self.hostLabel.qq_height);
        }
    }
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self updateWebViewContentInset];
}

- (void)showToolBarsIfNeeded:(BOOL)animated {
    if (self.showsToolbar && self.isViewLoaded && (self.webView.canGoBack || self.webView.canGoForward)) {
        if (self.toolBar.showing) return;
        self.toolBar.showing = YES;
        [self.view addSubview:self.toolBar];
        [UIView animateWithDuration:animated? 0.25 : 0 animations:^{
            self.toolBar.qq_top = self.view.qq_height - self.toolBar.qq_height;
            self.webView.qq_height = self.toolBar.qq_top - self.webView.qq_top;
        } completion:^(BOOL finished) {
            [self updateWebViewContentInset];
        }];
    }
}

- (void)hideToolBarsIfNeeded:(BOOL)animated {
    if (self.showsToolbar && self.isViewLoaded) {
        if (!self.toolBar.showing) return;
        self.toolBar.showing = NO;
        [UIView animateWithDuration:animated? 0.25 : 0 animations:^{
            self.toolBar.qq_top = self.view.qq_height;
            self.webView.qq_height = self.toolBar.qq_top - self.webView.qq_top;
        } completion:^(BOOL finished) {
            [self updateWebViewContentInset];
        }];
    }
}

- (void)updateWebViewContentInset {
    if (!self.showsToolbar) {
        UIEdgeInsets safeAreaInsets = self.view.qq_safeAreaInsets;
        safeAreaInsets.top = 0;
        self.webView.scrollView.contentInset = safeAreaInsets;
    }
}

- (void)updateNavigationBarItems {
    if (!self.navigationController.navigationBar) return;
    UIImage *image = self.closeImage;
    if (!image) {
        image = [UIImage imageWithContentsOfFile:[[self imageBundle] pathForResource:@"WebNavbarClose" ofType:@"png"]];
    }
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem qq_leftItemWithImage:image target:self action:@selector(onBackBarButtonItemClicked)];
}

- (void)updateToolBarItems {
    if (!_toolBar) return;
    UIImage *backwardImage = self.backwardImage;
    if (!backwardImage) {
        backwardImage = [UIImage imageWithContentsOfFile:[[self imageBundle] pathForResource:@"WebToolbarBackward" ofType:@"png"]];
    }
    [self.toolBar.backwardButton setImage:backwardImage forState:UIControlStateNormal];
    
    UIImage *forwardImage = self.forwardImage;
    if (!forwardImage) {
        forwardImage = [UIImage imageWithContentsOfFile:[[self imageBundle] pathForResource:@"WebToolbarForward" ofType:@"png"]];
    }
    [self.toolBar.forwardButton setImage:forwardImage forState:UIControlStateNormal];
}

- (void)onBackBarButtonItemClicked {
    BOOL isPush = NO;
    if (self.navigationController.viewControllers.count > 1) {
        if (self.navigationController.viewControllers[self.navigationController.viewControllers.count - 1] == self) {
            isPush = YES;
        }
    }
    if (isPush) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onToolBarBackwardButtonClicked {
    [self.webView goBack];
}

- (void)onToolBarForwardButtonClicked {
    [self.webView goForward];
}

- (NSBundle *)imageBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[QQWebViewController class]];
    NSURL *url = [bundle URLForResource:@"QQUIKit" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    return imageBundle;
}

#pragma mark - Setters

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    self.progressView.trackTintColor = trackTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    self.progressView.progressTintColor = progressTintColor;
}


- (void)setCloseImage:(UIImage *)closeImage {
    _closeImage = closeImage;
    [self updateNavigationBarItems];
}

- (void)setShowsToolbar:(BOOL)showsToolbar {
    _showsToolbar = showsToolbar;
    if (showsToolbar) {
        [self showToolBarsIfNeeded:NO];
    } else {
        [self hideToolBarsIfNeeded:NO];
    }
}

- (void)setHidesToolbarOnSwipe:(BOOL)hidesToolbarOnSwipe {
    _hidesToolbarOnSwipe = hidesToolbarOnSwipe;
    if (!hidesToolbarOnSwipe) {
        [self showToolBarsIfNeeded:NO];
    }
}

- (void)setBackwardImage:(UIImage *)backwardImage {
    _backwardImage = backwardImage;
    [self updateToolBarItems];
}

- (void)setForwardImage:(UIImage *)forwardImage {
    _forwardImage = forwardImage;
    [self updateToolBarItems];
}

#pragma mark - Observers

- (void)addObservers {
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers {
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    [self.webView removeObserver:self forKeyPath:@"URL"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object != self.webView) return;
    id value = change[NSKeyValueChangeNewKey];
    if ([keyPath isEqualToString:@"title"]) {
        self.navigationItem.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.webView.estimatedProgress >= 1.0f ) {
            [UIView animateWithDuration:0.3 animations:^{
                self.progressView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.progressView.progress = 0.0f;
            }];
        } else {
            self.progressView.alpha = 1.0f;
        }
    } else if ([keyPath isEqualToString:@"canGoBack"]) {
        BOOL canGoBack = [value boolValue];
        self.toolBar.backwardButton.enabled = canGoBack;
        [self checkPopRectEdge];
        [self showToolBarsIfNeeded:NO];
    } else if ([keyPath isEqualToString:@"canGoForward"]) {
        BOOL canGoForward = [value boolValue];
        self.toolBar.forwardButton.enabled = canGoForward;
        [self checkPopRectEdge];
        [self showToolBarsIfNeeded:NO];
    } else if ([keyPath isEqualToString:@"URL"]) {
        if (self.webView.URL.host.length > 0) {
            self.hostLabel.text = [NSString stringWithFormat:@"????????????%@??????", self.webView.URL.host];
        } else {
            self.hostLabel.text = nil;
        }
        [self.hostLabel sizeToFit];
        self.hostLabel.frame = CGRectMake(10, self.hostLabel.qq_top, self.view.qq_width - 20, self.hostLabel.qq_height);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        if (-scrollView.contentOffset.y > self.hostLabel.qq_bottom - self.webView.qq_top) {
            self.hostLabel.alpha = (-scrollView.contentOffset.y - (self.hostLabel.qq_bottom - self.webView.qq_top)) / 80;
        } else {
            self.hostLabel.alpha = 0;
        }
    } else {
        self.hostLabel.alpha = 0;
    }
    if (!scrollView.isDragging) return;
    if ([self needsUpdateToolbar]) {
        if (self.webView.scrollView.contentOffset.y > (self.webView.scrollView.contentSize.height - self.webView.qq_height - self.toolBar.qq_height)) {
            // ?????????????????????????????????
            self.toolBar.qq_top = self.view.qq_height;
            self.webView.qq_height = self.toolBar.qq_top - self.webView.qq_top;
        } else {
            CGPoint currentContentOffset = scrollView.contentOffset;
            CGFloat offsetY = currentContentOffset.y - self.beginContentOffset.y;
            CGFloat toolbarMinY = self.view.qq_height - self.toolBar.qq_height;
            CGFloat toolbarMaxY = self.view.qq_height;
            CGFloat toolbarTop = 0;
            if (self.toolBar.isShowing) {
                toolbarTop = toolbarMinY + offsetY;
            } else {
                toolbarTop = toolbarMaxY + offsetY;
            }
            toolbarTop = MIN(MAX(toolbarTop, toolbarMinY), toolbarMaxY);
            self.toolBar.qq_top = toolbarTop;
            self.webView.qq_height = toolbarTop - self.webView.qq_top;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self needsUpdateToolbar]) {
        self.beginContentOffset = scrollView.contentOffset;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self needsUpdateToolbar]) {
        CGFloat offsetY = scrollView.contentOffset.y - self.beginContentOffset.y;
        if (offsetY > 0) {
            [self hideToolBarsIfNeeded:YES];
        } else if (offsetY < 0) {
            [self showToolBarsIfNeeded:YES];
        }
    }
}

- (BOOL)needsUpdateToolbar {
    return self.showsToolbar && self.hidesToolbarOnSwipe && (_webView.canGoBack || _webView.canGoForward) && self.webView.scrollView.contentSize.height > (self.webView.qq_height + self.toolBar.qq_height);
}

#pragma mark - WKNavigationDelegate

// ????????????????????????????????????
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"URL:%@", navigationAction.request.URL.absoluteString);
    
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = URL.scheme;
    
    if ([self canJump:URL.absoluteString]) {
        // app??????
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            NSString *tips = [NSString stringWithFormat:@"????????????%@????????????????????????", QQUIHelper.appName.length > 0 ? QQUIHelper.appName : @"App"];
            
            QQAlertController *alert = [self createWebAlertWithTitle:nil message:tips];
            QQAlertAction *cancelAction = [QQAlertAction actionWithTitle:@"??????" style:QQAlertActionStyleCancel handler:^(QQAlertAction * _Nonnull action) {
                
            }];
            QQAlertAction *continueAction = [QQAlertAction actionWithTitle:@"??????" style:QQAlertActionStyleDefault handler:^(QQAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:URL];
            }];
            [alert addAction:cancelAction];
            [alert addAction:continueAction];
            [alert showFromController:self];
            
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    } else {
        // ????????????????????????
        if ([scheme isEqualToString:@"tel"] || [scheme isEqualToString:@"sms"] || [scheme isEqualToString:@"mailto"]) {
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
                
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

// ????????????????????????????????????
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler API_AVAILABLE(macos(10.15), ios(13.0)) {
//
//    decisionHandler(WKNavigationActionPolicyAllow, preferences);
//}

// ??????????????????????????????????????????????????????
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%s", __func__);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// ???????????????????????????
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self showToolBarsIfNeeded:YES];
}

// ?????????????????????????????????????????????
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

// ???????????????????????????
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

// ??????????????????????????????
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
}

// ??????????????????????????????
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    
}

// ???????????????????????????
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s", __func__);
}

// ???web??????????????????????????????????????????
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
//
//}

// ???web?????????web??????????????????????????????
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"%s", __func__);
}

// ???web????????????TLS?????????????????????????????????????????????
//- (void)webView:(WKWebView *)webView authenticationChallenge:(NSURLAuthenticationChallenge *)challenge shouldAllowDeprecatedTLS:(void (^)(BOOL))decisionHandler API_AVAILABLE(macos(11.0), ios(14.0)) {
//
//}
//
//// ?????????WKNavigationActionPolicyDownload????????????
//- (void)webView:(WKWebView *)webView navigationAction:(WKNavigationAction *)navigationAction didBecomeDownload:(WKDownload *)download API_AVAILABLE(macos(11.3), ios(14.5)) {
//
//}
//
//// ?????????WKNavigationResponsePolicyDownload???????????????
//- (void)webView:(WKWebView *)webView navigationResponse:(WKNavigationResponse *)navigationResponse didBecomeDownload:(WKDownload *)download API_AVAILABLE(macos(11.3), ios(14.5)) {
//
//}

#pragma mark - WKUIDelegate
// ??????????????????webview???
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"%s", __func__);
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// ??????????????????DOM???????????????close()?????????????????????
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"%s", __func__);
}

// ????????????JavaScript???????????????
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    QQAlertController *alert = [self createWebAlertWithTitle:self.URL.host message:message];
    QQAlertAction *confirmAction = [QQAlertAction actionWithTitle:@"??????" style:QQAlertActionStyleDefault handler:^(QQAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alert addAction:confirmAction];
    [alert showFromController:self];
    
    NSLog(@"%s", __func__);
}

// ????????????JavaScript???????????????
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    QQAlertController *alert = [self createWebAlertWithTitle:self.URL.host message:message];
    QQAlertAction *cancelAction = [QQAlertAction actionWithTitle:@"??????" style:QQAlertActionStyleCancel handler:^(QQAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    QQAlertAction *confirmAction = [QQAlertAction actionWithTitle:@"??????" style:QQAlertActionStyleDefault handler:^(QQAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [alert showFromController:self];
    
    NSLog(@"%s", __func__);
}

// ????????????JavaScript?????????????????????
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    
    QQAlertController *alert = [self createWebAlertWithTitle:self.URL.host message:prompt];
    QQAlertAction *cancelAction = [QQAlertAction actionWithTitle:@"??????" style:QQAlertActionStyleCancel handler:^(QQAlertAction * _Nonnull action) {
        completionHandler(nil);
    }];
    QQAlertAction *confirmAction = [QQAlertAction actionWithTitle:@"??????" style:QQAlertActionStyleDefault handler:^(QQAlertAction * _Nonnull action) {
        QQTextField *textFiled = alert.textFields.firstObject;
        completionHandler(textFiled.text);
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(QQTextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    [alert showFromController:self];
    
    NSLog(@"%s", __func__);
}

// ??????????????????????????????????????????????????????????????????????????????
//- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuConfigurationForElement:completionHandler:", ios(10.0, 13.0)) {
//    return YES;
//}
//
//// ????????????????????????????????????????????????????????????????????????????????????
//- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuConfigurationForElement:completionHandler:", ios(10.0, 13.0)) {
//    return nil;
//}
//
//// ?????????????????????????????????????????????????????????
//- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuForElement:willCommitWithAnimator:", ios(10.0, 13.0)) {
//
//}
//
//// ????????????????????????????????????
//- (void)webView:(WKWebView *)webView contextMenuConfigurationForElement:(WKContextMenuElementInfo *)elementInfo completionHandler:(void (^)(UIContextMenuConfiguration * _Nullable configuration))completionHandler API_AVAILABLE(ios(13.0)) {
//
//}
//
//// ????????????????????????????????????
//- (void)webView:(WKWebView *)webView contextMenuWillPresentForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
//
//}
//
//// ????????????????????????UIContextMenuContentPreviewProvider??????????????????????????????
//- (void)webView:(WKWebView *)webView contextMenuForElement:(WKContextMenuElementInfo *)elementInfo willCommitWithAnimator:(id <UIContextMenuInteractionCommitAnimating>)animator API_AVAILABLE(ios(13.0)) {
//
//}
//
//// ??????????????????????????????????????????????????????????????????????????????
//- (void)webView:(WKWebView *)webView contextMenuDidEndForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
//
//}

#pragma mark - More

- (QQAlertController *)createWebAlertWithTitle:(NSString *)title message:(NSString *)message {
    QQAlertController *alert = [QQAlertController alertControllerWithTitle:title message:message preferredStyle:QQAlertControllerStyleAlert];
    alert.alertContentMaximumWidth = QQUIHelper.deviceWidth - 60;
    alert.alertContentCornerRadius = 10;
    if (title.length > 0) {
        alert.alertTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor qq_colorWithHexString:@"222222"]};
        alert.alertMessageAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor qq_colorWithHexString:@"999999"]};
    } else {
        alert.alertTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor qq_colorWithHexString:@"222222"]};
        alert.alertMessageAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor qq_colorWithHexString:@"222222"]};
    }
    alert.alertHeaderMinimumHeight = 100;
    alert.alertHeaderInsets = UIEdgeInsetsMake(30, 25, 30, 25);
    alert.alertTitleMessageSpacing = 20;
    alert.alertTextFieldMessageSpacing = 15;
    alert.alertButtonHeight = 55;
    alert.alertButtonAttributes = @{NSForegroundColorAttributeName:[UIColor qq_colorWithHexString:@"5c6e82"],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    alert.alertCancelButtonAttributes = @{NSForegroundColorAttributeName:[UIColor qq_colorWithHexString:@"222222"],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    alert.alertTextFieldFont = [UIFont systemFontOfSize:15];
    alert.alertTextFieldHeight = 40;
    alert.alertTextFieldTextColor = [UIColor qq_colorWithHexString:@"222222"];
    alert.alertSeparatorColor = [UIColor qq_colorWithHexString:@"e6e6e6"];
    alert.alertTextFieldPlacehodlerColor = [UIColor qq_colorWithHexString:@"999999"];
    alert.alertTextFieldBackgroundColor = [UIColor qq_colorWithHexString:@"eeeff1"];
    
    return alert;
}

- (BOOL)canJump:(NSString *)urlString {
    BOOL canJump = NO;
    for (NSString *scheme in [self someURLSchemes]) {
        if ([urlString rangeOfString:scheme options:NSCaseInsensitiveSearch].location != NSNotFound) {
            canJump = YES;
        }
    }
    if (([urlString hasPrefix:@"https://itunes.apple.com/"] || [urlString hasPrefix:@"https://apps.apple.com/"]) && [urlString containsString:@"/id"]) {
        canJump = YES;
    }
    return canJump;
}

- (NSArray *)someURLSchemes {
    // ?????? info.plist ????????????????????? LSApplicationQueriesSchemes
    return @[
        @"message://", //??????
        @"maps://", //??????
        @"itms-apps://", //AppStore
        @"itms-appss://", //AppStore
        @"sinaweibo://", //??????
        @"bdmap://", //????????????
        @"openapp.jdmobile://", //??????
        @"imeituan://", //??????
        @"taobao://", //??????
        @"pinduoduo://", //?????????
        @"alipay://", //?????????
        @"alipays://", //?????????
        @"mqq://", //QQ
    ];
}

- (void)checkPopRectEdge {
    UIPanGestureRecognizer *panGesture = [self getFullScreenPopGesture];
    if (panGesture) {
        if (_webView.canGoBack && _webView.allowsBackForwardNavigationGestures) {
            panGesture.enabled = NO;
        } else {
            panGesture.enabled = YES;
        }
    }
}

- (UIPanGestureRecognizer *)getFullScreenPopGesture {
    if ([self.navigationController isKindOfClass:NSClassFromString(@"QQNavigationController")]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self.navigationController respondsToSelector:@selector(fullScreenPopGesture)]) {
            UIPanGestureRecognizer *panGesture = [self.navigationController performSelector:@selector(fullScreenPopGesture)];
            if ([panGesture isKindOfClass:[UIPanGestureRecognizer class]]) {
                return panGesture;
            }
        }
        #pragma clang diagnostic pop
    }
    return nil;
}

@end
