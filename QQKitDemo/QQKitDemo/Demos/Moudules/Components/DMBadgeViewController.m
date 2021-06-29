//
//  DMBadgeViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/16.
//

#import "DMBadgeViewController.h"

@interface DMBadgeViewController ()

@property (nonatomic, strong) UIView *demoView;
@property (nonatomic, strong) UILabel *demoLabel;
@property (nonatomic, strong) QQButton *demoButton;

@end

@implementation DMBadgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initSubviews {
    _demoView = [[UIView alloc] init];
    _demoView.backgroundColor = UIColor.qq_randomColor;
    [self.view addSubview:_demoView];
    
    _demoLabel = [[UILabel alloc] init];
    _demoLabel.text = @"我是label";
    _demoLabel.textColor = UIColor.dm_whiteColor;
    _demoLabel.font = [UIFont systemFontOfSize:16];
    _demoLabel.backgroundColor = [UIColor qq_randomColor];
    [self.view addSubview:_demoLabel];
    
    _demoButton = [[QQButton alloc] init];
    _demoButton.imagePosition = QQButtonImagePositionTop;
    _demoButton.spacingBetweenImageAndTitle = 10;
    _demoButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_demoButton setTitleColor:UIColor.dm_tintColor forState:UIControlStateNormal];
    [_demoButton setImage:[[UIImage imageNamed:@"icon_tabbar_uikit_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _demoButton.layer.borderColor = UIColor.dm_separatorColor.CGColor;
    _demoButton.layer.borderWidth = 1;
    [_demoButton setTitle:@"我是Button" forState:UIControlStateNormal];
    [self.view addSubview:_demoButton];
    
    _demoView.qq_badgeString = @"99+";
    _demoLabel.qq_badgeInteger = 10;
    _demoButton.qq_badgeInteger = 3;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _demoView.frame = CGRectMake((self.view.qq_width - 50) / 2, QQUIHelper.navigationBarMaxY + 40, 50, 50);
    [_demoLabel sizeToFit];
    _demoLabel.frame = CGRectMake((self.view.qq_width - _demoLabel.qq_width) / 2, _demoView.qq_bottom + 40, _demoLabel.qq_width, _demoLabel.qq_height);
    _demoButton.frame = CGRectMake((self.view.qq_width - 90) / 2, _demoLabel.qq_bottom + 40, 90, 90);
    
    // 可以自己调整 badge 偏移量
    CGFloat offsetX = (_demoButton.qq_width - _demoButton.imageView.qq_width) / 2;
    CGFloat offsetY = _demoButton.imageView.qq_top;
    _demoButton.qq_badgeOffset = CGPointMake(-offsetX, offsetY);
    
    [_demoView qq_badgeSetNeedsLayout];
    [_demoLabel qq_badgeSetNeedsLayout];
    [_demoButton qq_badgeSetNeedsLayout];
}

@end
