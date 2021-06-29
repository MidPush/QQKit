//
//  DMSearchBarViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "DMSearchBarViewController.h"
#import "QQSearchBar.h"

@interface DMSearchBarViewController ()<UITableViewDelegate, UITableViewDataSource, QQSearchBarDelegate>

@property (nonatomic, strong) QQTableView *tableView;

@property (nonatomic, strong) NSArray<NSString *> *datas;

@property (nonatomic, strong) UISearchBar *uiSearchBar;
@property (nonatomic, strong) QQSearchBar *qqSearchBar;

@end

@implementation DMSearchBarViewController

- (NSArray<NSString *> *)datas {
    if (!_datas) {
        _datas = @[
            @"placeholder 居中",
            @"更换 placeholder 文字",
            @"调整输入框布局",
            @"显示隐藏 cancelButton",
            @"显示隐藏 leftAccessoryView",
            @"显示隐藏 rightAccessoryView",
            @"使用半圆角风格",
        ];
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initSubviews {
    
    _uiSearchBar = [[UISearchBar alloc] init];
    _uiSearchBar.placeholder = @"系统 UISearchBar";
    if (@available(iOS 13.0, *)) {
        _uiSearchBar.searchTextField.font = [UIFont systemFontOfSize:14];
    }
    [self.view addSubview:_uiSearchBar];
    
    _qqSearchBar = [[QQSearchBar alloc] init];
    _qqSearchBar.placeholder = @"自定义 QQSearchBar";
    _qqSearchBar.searchTextField.font = [UIFont systemFontOfSize:14];
    _qqSearchBar.delegate = self;
    [self.view addSubview:_qqSearchBar];
    
    _tableView = [[QQTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _uiSearchBar.frame = CGRectMake(10, QQUIHelper.navigationBarMaxY + 30, self.view.frame.size.width - 20, 44);
    _qqSearchBar.frame = CGRectMake(_uiSearchBar.qq_left, _uiSearchBar.qq_bottom + 10, _uiSearchBar.qq_width, _uiSearchBar.qq_height);
    
    self.tableView.frame = CGRectMake(0, _qqSearchBar.qq_bottom + 10, self.view.qq_width, self.view.qq_height - (_qqSearchBar.qq_bottom + 10));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[QQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.datas[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    if (indexPath.row == 0) {
        QQPlaceholderAlignment placeholderAlignment = self.qqSearchBar.placeholderAlignment;
        if (placeholderAlignment == QQPlaceholderAlignmentLeft) {
            placeholderAlignment = QQPlaceholderAlignmentCenter;
        } else {
            placeholderAlignment = QQPlaceholderAlignmentLeft;
        }
        self.qqSearchBar.placeholderAlignment = placeholderAlignment;
    } else if (indexPath.row == 1) {
        NSString *placeholder = self.qqSearchBar.placeholder;
        if ([placeholder isEqualToString:@"自定义 QQSearchBar"]) {
            placeholder = @"更换后 placeholder 更换后 placeholder 更换后 placeholder";
        } else {
            placeholder = @"自定义 QQSearchBar";
        }
        self.qqSearchBar.placeholder = placeholder;
    } else if (indexPath.row == 2) {
        if (self.qqSearchBar.textFieldMargins.left == 0) {
            self.qqSearchBar.textFieldMargins = UIEdgeInsetsMake(2, 50, 2, 50);
        } else {
            self.qqSearchBar.textFieldMargins = UIEdgeInsetsMake(2, 0, 2, 0);
        }
    } else if (indexPath.row == 3) {
        BOOL show = self.qqSearchBar.showsCancelButton;
        [self.qqSearchBar setShowsCancelButton:!show animated:YES];
        [self.uiSearchBar setShowsCancelButton:!show animated:YES];
    } else if (indexPath.row == 4) {
        if (!self.qqSearchBar.leftAccessoryView) {
            self.qqSearchBar.leftAccessoryView = [self createAccessoryView];
        }
        BOOL show = self.qqSearchBar.showsLeftAccessoryView;
        [self.qqSearchBar setShowsLeftAccessoryView:!show animated:YES];
    } else if (indexPath.row == 5) {
        if (!self.qqSearchBar.rightAccessoryView) {
            self.qqSearchBar.rightAccessoryView = [self createAccessoryView];
        }
        BOOL show = self.qqSearchBar.showsRightAccessoryView;
        [self.qqSearchBar setShowsRightAccessoryView:!show animated:YES];
    } else if (indexPath.row == 6) {
        if (self.qqSearchBar.textFieldRadius > 0) {
            self.qqSearchBar.textFieldRadius = -1;
        } else {
            self.qqSearchBar.textFieldRadius = 10;
        }
    }
}

- (UIView *)createAccessoryView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    view.backgroundColor = UIColor.qq_randomColor;
    return view;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - QQSearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(QQSearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(QQSearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

@end
