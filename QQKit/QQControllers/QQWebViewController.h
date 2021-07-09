//
//  QQWebViewController.h
//  QQKitDemo
//
//  Created by Mac on 2021/7/8.
//

#import "QQViewController.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface QQWebViewController : QQViewController

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL configuration:(nullable WKWebViewConfiguration *)configuration;

@property (nonatomic, strong, readonly) WKWebView *webView;

#pragma mark - QQWebProgressView
@property (nonatomic, strong, nullable) UIColor *trackTintColor;
@property (nonatomic, strong, nullable) UIColor *progressTintColor;

#pragma mark - NavgionBar
@property (nonatomic, strong) UIImage *closeImage;

#pragma mark - QQWebToolBar
/// 是否显示 toolbar，默认为YES
@property (nonatomic, assign) BOOL showsToolbar;

/// 当滑动时隐藏 toolbar，默认为YES
@property (nonatomic, assign) BOOL hidesToolbarOnSwipe;

/// 后退图标
@property (nonatomic, strong) UIImage *backwardImage;

/// 前进图标
@property (nonatomic, strong) UIImage *forwardImage;

@end

NS_ASSUME_NONNULL_END
