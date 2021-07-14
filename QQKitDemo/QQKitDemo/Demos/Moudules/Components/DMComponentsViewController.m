//
//  DMComponentsViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/14.
//

#import "DMComponentsViewController.h"

@interface DMComponentsViewController ()

@end

@implementation DMComponentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupNavigationBar {
    self.navigationItem.title = @"QQComponents";
}

- (void)initDataSource {
    self.dataSource = @[
        @{@"QQFakeNavigationBar" : @"DMFakeNavigationBarViewController"},
        @{@"QQPageViewController" : @"DMPageViewController"},
        @{@"QQAssetPicker" : @"DMAssetPickerViewController"},
        @{@"QQBadge" : @"DMBadgeViewController"},
        @{@"QQToast" : @"DMToastViewController"},
        @{@"QQCircularProgress" : @"DMCircularProgressViewController"},
        @{@"QQModalViewController" : @"DMModalViewController"},
        @{@"QQWebViewController" : @"DMWebViewController"},
    ];
}


@end
