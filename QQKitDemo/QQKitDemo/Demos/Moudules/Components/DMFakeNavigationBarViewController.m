//
//  DMFakeNavigationBarViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "DMFakeNavigationBarViewController.h"
#import "QQNavigationButton.h"

@interface DMNavBarStyleData : NSObject
@property (nonatomic, assign) UIBarStyle barStyle;
@property (nonatomic, copy) NSString *text;
@end

@implementation DMNavBarStyleData
@end

@interface DMNavBarStyleCell : QQTableViewCell
@property (nonatomic, strong) DMNavBarStyleData *navBarStyleData;
@end

@implementation DMNavBarStyleCell
- (void)setNavBarStyleData:(DMNavBarStyleData *)navBarStyleData {
    _navBarStyleData = navBarStyleData;
    self.textLabel.text = navBarStyleData.text;
}
@end

@interface DMFakeNavigationBarViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) QQTableView *tableView;

@property (nonatomic, strong) NSArray *datas;

@end

@implementation DMFakeNavigationBarViewController

- (NSArray<NSString *> *)datas {
    if (!_datas) {
        _datas = @[
            @"默认 navBar 样式",
            @"黑色 navBar 样式",
            @"红色 navBar 样式",
            @"隐藏 navBar 样式",
        ];
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)setupNavigationBar {
    if (self.barStyle == DMNavigationBarStyleOrigin) {
        self.navigationItem.title = @"默认 navBar 样式";
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem qq_rightItemWithTitle:@"确定" titleColor:UIColor.dm_blackColor font:[UIFont systemFontOfSize:16] target:nil action:nil];
    } else if (self.barStyle == DMNavigationBarStyleDark) {
        self.navigationItem.title = @"黑色 navBar 样式";
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem qq_leftItemWithImage:[UIImage imageNamed:@"nav_back_white"] title:@"返回" titleColor:[UIColor dm_whiteTextColor] target:self action:@selector(onBackBarButtonItemClicked)];
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem qq_rightItemWithTitle:@"确定" titleColor:UIColor.dm_whiteTextColor font:[UIFont systemFontOfSize:16] target:nil action:nil];
    } else if (self.barStyle == DMNavigationBarStyleRed) {
        self.navigationItem.title = @"红色 navBar 样式";
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem qq_leftItemWithImage:[UIImage imageNamed:@"nav_back_white"] title:@"绿色" titleColor:[UIColor greenColor] target:self action:@selector(onBackBarButtonItemClicked)];
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem qq_rightItemWithTitle:@"确定" titleColor:UIColor.greenColor font:[UIFont systemFontOfSize:16] target:nil action:nil];
    } else if (self.barStyle == DMNavigationBarStyleHideBar) {
        
    }
}

- (void)initSubviews {
    _tableView = [[QQTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[QQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.tintColor = UIColor.dm_tintColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DMNavigationBarStyle barStyle = 0;
    if (indexPath.row == 0) {
        barStyle = DMNavigationBarStyleOrigin;
    } else if (indexPath.row == 1) {
        barStyle = DMNavigationBarStyleDark;
    } else if (indexPath.row == 2) {
        barStyle = DMNavigationBarStyleRed;
    } else if (indexPath.row == 3) {
        barStyle = DMNavigationBarStyleHideBar;
    }
    DMFakeNavigationBarViewController *vc = [[DMFakeNavigationBarViewController alloc] init];
    vc.barStyle = barStyle;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.barStyle == DMNavigationBarStyleDark || self.barStyle == DMNavigationBarStyleRed) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

#pragma mark - UINavigationBarAppearanceProtocol
/// 设置导航栏是否隐藏
- (BOOL)prefersNavigationBarHidden {
    if (self.barStyle == DMNavigationBarStyleHideBar) {
        return YES;
    }
    return NO;
}

/// 设置导航栏的背景图
- (UIImage *)navBarBackgroundImage {
    return nil;
}

/// 设置导航栏底部的分隔线图片，必须在 navigationBar 设置了背景图后才有效（系统限制如此）
- (UIImage *)navBarShadowImage {
    if (self.barStyle == DMNavigationBarStyleOrigin) {
        return [QQUIConfiguration sharedInstance].navBarShadowImage;
    } else if (self.barStyle == DMNavigationBarStyleDark) {
        return [UIImage qq_imageWithColor:[UIColor qq_colorWithHexString:@"636363"] size:CGSizeMake(10, [QQUIHelper pixelOne])];
    } else if (self.barStyle == DMNavigationBarStyleRed) {
        return [UIImage new];
    }
    return [QQUIConfiguration sharedInstance].navBarShadowImage;
}

/// 设置当前导航栏的 tintColor
- (UIColor *)navBarTintColor {
    if (self.barStyle == DMNavigationBarStyleOrigin) {
        return [QQUIConfiguration sharedInstance].navBarTintColor;
    } else if (self.barStyle == DMNavigationBarStyleDark) {
        return UIColor.dm_whiteColor;
    } else if (self.barStyle == DMNavigationBarStyleRed) {
        return UIColor.greenColor;
    }
    return [QQUIConfiguration sharedInstance].navBarTintColor;
}

/// 设置导航栏的 barTintColor
- (UIColor *)navBarBarTintColor {
    if (self.barStyle == DMNavigationBarStyleOrigin) {
        return [QQUIConfiguration sharedInstance].navBarBarTintColor;
    } else if (self.barStyle == DMNavigationBarStyleDark) {
        return [UIColor qq_colorWithHexString:@"424242"];
    } else if (self.barStyle == DMNavigationBarStyleRed) {
        return UIColor.redColor;
    }
    return [QQUIConfiguration sharedInstance].navBarBarTintColor;
}

/// 设置导航栏的 title
- (NSDictionary<NSAttributedStringKey, id> *)navBarTitleTextAttributes {
    if (self.barStyle == DMNavigationBarStyleOrigin) {
        return [QQUIConfiguration sharedInstance].navBarTitleTextAttributes;
    } else if (self.barStyle == DMNavigationBarStyleDark) {
        return @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:UIColor.dm_whiteTextColor};
    } else if (self.barStyle == DMNavigationBarStyleRed) {
        return @{NSFontAttributeName:[UIFont systemFontOfSize:20], NSForegroundColorAttributeName:UIColor.dm_whiteTextColor};
    }
    return [QQUIConfiguration sharedInstance].navBarTitleTextAttributes;
}


@end
