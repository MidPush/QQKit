//
//  DMPageViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/16.
//

#import "DMPageViewController.h"
#import "QQPageViewController.h"

@interface DMPageChildViewController : UIViewController

@end

@implementation DMPageChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.qq_randomColor;
}

@end

@interface DMPageViewController ()

@property (nonatomic, weak) QQPageViewController *pageViewController;

@end

@implementation DMPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)initSubviews {
    QQTopBarAttributes *attributes = [[QQTopBarAttributes alloc] init];
    attributes.titles = @[@"标题1", @"标题2", @"标题3", @"标题4", @"标题5", @"标题6", @"标题7", @"标题8"];
    attributes.titleColor = UIColor.dm_mainTextColor;
    attributes.selectedTitleColor = UIColor.dm_tintColor;
    attributes.titleFont = [UIFont systemFontOfSize:16];
    attributes.selectedTitleFont = [UIFont systemFontOfSize:16];
    attributes.topBarHeight = 44;
    attributes.itemSpace = 20;
    attributes.contentInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    attributes.indicatorColor = UIColor.dm_tintColor;
    
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSInteger i = 0; i < attributes.titles.count; i++) {
        DMPageChildViewController *vc = [[DMPageChildViewController alloc] init];
        [viewControllers addObject:vc];
    }
    
    QQPageViewController *pageViewController = [[QQPageViewController alloc] init];
    pageViewController.topBarAttributes = attributes;
    pageViewController.viewControllers = viewControllers;
    [self.view addSubview:pageViewController.view];
    [self addChildViewController:pageViewController];
    _pageViewController = pageViewController;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _pageViewController.view.frame = CGRectMake(0, QQUIHelper.navigationBarMaxY, self.view.qq_width, self.view.qq_height - QQUIHelper.navigationBarMaxY);
}

@end
