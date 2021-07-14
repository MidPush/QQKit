//
//  DMUIKitViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/14.
//

#import "DMUIKitViewController.h"

@interface DMUIKitViewController ()

@end

@implementation DMUIKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupNavigationBar {
    self.navigationItem.title = @"QQKit";
}

- (void)initDataSource {
    self.dataSource = @[
        @{@"QQButton" : @"DMButtonViewController"},
        @{@"QQLabel" : @"DMLabelViewController"},
        @{@"QQTextView" : @"DMTextViewViewController"},
        @{@"QQTextField" : @"DMTextFieldViewController"},
        @{@"QQSearchBar" : @"DMSearchBarViewController"},
        @{@"QQActivityIndicatorView" : @"DMActivityIndicatorViewController"},
        @{@"ViewController Orientation" : @"DMOrientationViewController"},
        @{@"UITabBarItem+QQExtension" : @"DMUITabBarItemViewController"},
        @{@"UIView+QQExtension" : @"DMViewBorderViewController"},
    ];
}


@end
