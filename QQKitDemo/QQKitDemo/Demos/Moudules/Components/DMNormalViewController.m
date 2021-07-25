//
//  DMNormalViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/7/23.
//

#import "DMNormalViewController.h"

@interface DMNormalViewController ()

@end

@implementation DMNormalViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor whiteColor];
//    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    self.navigationItem.title = @"Normal";
    if (self.navigationController) {
        NSLog(@"");
    }
    if (self.type % 2 == 1) {
        self.navigationController.navigationBar.barTintColor = [UIColor cyanColor];
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    }
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:29], NSForegroundColorAttributeName:[UIColor cyanColor]}];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DMNormalViewController *vc = [[DMNormalViewController alloc] init];
    vc.type = self.type+1;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
