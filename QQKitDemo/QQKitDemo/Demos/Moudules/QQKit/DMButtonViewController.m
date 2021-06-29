//
//  DMButtonViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "DMButtonViewController.h"

@interface DMButtonViewController ()

@property (nonatomic, strong) QQScrollView *scrollView;

@property (nonatomic, strong) QQButton *normalButton;
@property (nonatomic, strong) QQButton *borderButton;

@property (nonatomic, strong) QQGhostButton *ghostButton;
@property (nonatomic, strong) QQFillButton *fillButton;

@property (nonatomic, strong) NSArray<QQButton *> *imagePositionButtons;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *g;

@end

@implementation DMButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)initSubviews {
    _scrollView = [[QQScrollView alloc] init];
    _scrollView.backgroundColor = UIColor.dm_whiteColor;
    [self.view addSubview:_scrollView];
    
    // normalButton
    _normalButton = [[QQButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _normalButton.adjustsButtonWhenHighlighted = YES;
    _normalButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_normalButton setTitle:@"按钮，支持高亮背景色" forState:UIControlStateNormal];
    [_normalButton setTitleColor:UIColor.dm_whiteColor forState:UIControlStateNormal];
    _normalButton.backgroundColor = UIColor.dm_tintColor;
    _normalButton.layer.cornerRadius = 4;
    _normalButton.highlightedBackgroundColor = [UIColor.dm_tintColor colorWithAlphaComponent:0.5];
    [_scrollView addSubview:_normalButton];
    
    // borderButton
    _borderButton = [[QQButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _borderButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_borderButton setTitle:@"边框支持高亮的按钮" forState:UIControlStateNormal];
    [_borderButton setTitleColor:UIColor.dm_tintColor forState:UIControlStateNormal];
    _borderButton.layer.borderColor = [UIColor.dm_tintColor colorWithAlphaComponent:0.2].CGColor;
    _borderButton.layer.borderWidth = 1;
    _borderButton.layer.cornerRadius = 4;
    _borderButton.highlightedBorderColor = [UIColor.dm_tintColor colorWithAlphaComponent:1.0];
    [_scrollView addSubview:_borderButton];
    
    // ghostButton
    _ghostButton = [[QQGhostButton alloc] initWithGhostColor:UIColor.dm_tintColor frame:CGRectMake(0, 0, 200, 40)];
    _ghostButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_ghostButton setTitle:@"点击修改 GhostColor" forState:UIControlStateNormal];
    [_ghostButton setTitleColor:UIColor.dm_tintColor forState:UIControlStateNormal];
    [_ghostButton addTarget:self action:@selector(onGhostButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_ghostButton];
    
    // fillButton
    _fillButton = [[QQFillButton alloc] initWithFillColor:UIColor.dm_tintColor titleTextColor:UIColor.dm_whiteTextColor frame:CGRectMake(0, 0, 200, 40)];
    _fillButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_fillButton setTitle:@"点击修改 FillColor" forState:UIControlStateNormal];
    [_fillButton addTarget:self action:@selector(onFillButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_fillButton];
    
    
    //
    NSArray *titles = @[@"图片在上面", @"图片在左边", @"图片在下面", @"图片在右边"];
    NSMutableArray *buttons = [NSMutableArray array];
    for (int i = 0; i < titles.count; i++) {
        QQButton *button = [[QQButton alloc] init];
        button.imagePosition = i;
        button.spacingBetweenImageAndTitle = 10;
        button.tintColor = UIColor.dm_tintColor;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:UIColor.dm_tintColor forState:UIControlStateNormal];
        [button setImage:[[UIImage imageNamed:@"icon_tabbar_uikit_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.layer.borderColor = UIColor.dm_separatorColor.CGColor;
        button.layer.borderWidth = 1;
        [_scrollView addSubview:button];
        [buttons addObject:button];
    }
    _imagePositionButtons = [buttons copy];
}

- (void)onGhostButtonClicked {
    self.ghostButton.ghostColor = UIColor.qq_randomColor;
}

- (void)onFillButtonClicked {
    self.fillButton.fillColor = UIColor.qq_randomColor;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _scrollView.frame = self.view.bounds;
    
    _normalButton.qq_left = (self.view.qq_width - _normalButton.qq_width) / 2;
    _normalButton.qq_top = 40;
    
    _borderButton.qq_left = _normalButton.qq_left;
    _borderButton.qq_top = _normalButton.qq_bottom + 30;
    
    _ghostButton.qq_left = _borderButton.qq_left;
    _ghostButton.qq_top = _borderButton.qq_bottom + 30;
    
    _fillButton.qq_left = _ghostButton.qq_left;
    _fillButton.qq_top = _ghostButton.qq_bottom + 30;
    
    CGFloat buttonY = _fillButton.qq_bottom + 30;
    CGFloat buttonW = self.view.qq_width / 2;
    CGFloat buttonH = 80;
    QQButton *lastButton = nil;
    for (int i = 0; i < _imagePositionButtons.count; i++) {
        QQButton *imagePositionButton = _imagePositionButtons[i];
        imagePositionButton.qq_width = buttonW;
        imagePositionButton.qq_height = buttonH;
        if (i == 0 || i == 2) {
            imagePositionButton.qq_left = 0;
        } else {
            imagePositionButton.qq_left = buttonW;
        }
        if (i == 0 || i == 1) {
            imagePositionButton.qq_top = buttonY;
        } else {
            imagePositionButton.qq_top = buttonY + buttonH;
        }
        lastButton = imagePositionButton;
    }
    
    _scrollView.contentSize = CGSizeMake(self.view.qq_width, lastButton.qq_bottom + 20);
}

@end
