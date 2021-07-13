//
//  DMLabelViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "DMLabelViewController.h"

@interface DMLabelViewController ()

@property (nonatomic, strong) QQLabel *label;

@end

@implementation DMLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initSubviews {
    self.label = [[QQLabel alloc] init];
    self.label.contentEdgeInsets = UIEdgeInsetsMake(20, 40, 20, 40);
    self.label.text = @"可设置 contentEdgeInsets";
    self.label.textColor = UIColor.dm_whiteTextColor;
    self.label.font = [UIFont systemFontOfSize:16];
    self.label.backgroundColor = UIColor.dm_tintColor;
    [self.view addSubview:self.label];
    [self.label sizeToFit];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.label.qq_left = (self.view.qq_width - self.label.qq_width) / 2;
    self.label.qq_top = [QQUIHelper navigationBarMaxY] + 30;
}

@end
