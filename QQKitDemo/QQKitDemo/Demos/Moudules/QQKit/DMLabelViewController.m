//
//  DMLabelViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "DMLabelViewController.h"

@interface DMLabelViewController ()

@property (nonatomic, strong) QQLabel *label;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *actions;

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
    
    self.actions = [NSMutableArray array];

    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    
    for (int i = 0; i < 6; i++) {
        QQButton *button = [[QQButton alloc] init];
        [button setTitle:@"按钮" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        button.adjustsButtonWhenDisabled = NO;
        button.adjustsButtonWhenHighlighted = NO;
        button.highlightedBackgroundColor = [UIColor grayColor];
        button.qq_borderColor = [UIColor blackColor];
        button.qq_borderWidth = QQUIHelper.pixelOne;
        [self.scrollView addSubview:button];
        
        [self.actions addObject:button];
        
    
        
    }
    
    
}

- (void)updateLayout {
    CGFloat buttonHeight = 44;
    self.scrollView.frame = CGRectMake((self.view.frame.size.width - 270) / 2, 393, 270, self.actions.count * buttonHeight);
    CGFloat top = 0;
    for (NSInteger i = 0; i < self.actions.count; i++) {
        QQButton *button = self.actions[i];
        if (i == 0) {
            button.qq_borderWidth = 0;
        }
        button.frame = CGRectMake(0, top, self.scrollView.qq_width, buttonHeight);
        button.qq_borderPosition = QQViewBorderPositionTop;
        top = button.qq_bottom;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.label.qq_left = (self.view.qq_width - self.label.qq_width) / 2;
    self.label.qq_top = [QQUIHelper navigationBarMaxY] + 30;
    [self updateLayout];
}

@end
