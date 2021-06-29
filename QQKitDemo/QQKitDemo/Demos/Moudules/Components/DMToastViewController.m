//
//  DMToastViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/16.
//

#import "DMToastViewController.h"
#import "QQToast.h"

@interface DMToastViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) QQTextField *textField;
@property (nonatomic, strong) QQTableView *tableView;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSArray<NSString *> *datas;

@end

@implementation DMToastViewController

- (NSArray<NSString *> *)datas {
    if (!_datas) {
        _datas = @[
            @"Loading With Native",
            @"Loading With Flat",
            @"Progress",
            @"Success",
            @"Error",
            @"Info",
            @"TintColor",
            @"只显示文字",
        ];
    }
    return _datas;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initSubviews {
    
    self.view.backgroundColor = UIColor.dm_whiteColor;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor dm_mainTextColor];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.text = @"TextFiled：";
    [self.view addSubview:_titleLabel];
    
    _textField = [[QQTextField alloc] init];
    _textField.textInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    _textField.placeholder = @"测试弹出键盘时，Toast显示是否正确";
    _textField.font = [UIFont systemFontOfSize:14];
    _textField.layer.borderWidth = QQUIHelper.pixelOne;
    _textField.layer.borderColor = UIColor.dm_separatorColor.CGColor;
    _textField.layer.cornerRadius = 4;
    [self.view addSubview:_textField];
    
    _tableView = [[QQTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(15, QQUIHelper.navigationBarMaxY + 10, _titleLabel.qq_width, 44);
    _textField.frame = CGRectMake(_titleLabel.qq_right + 10, QQUIHelper.navigationBarMaxY + 10, self.view.qq_width - (_titleLabel.qq_right + 20), 44);
    self.tableView.frame = CGRectMake(0, _textField.qq_bottom + 10, self.view.qq_width, self.view.qq_height - _textField.qq_height - 10);
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
    if (indexPath.row == 0) {
        [QQToast showLoading:@"加载中..." time:5 animationType:QQProgressHUDAnimationTypeNative];
    } else if (indexPath.row == 1) {
        [QQToast showLoading:@"加载中..." time:5];
    } else if (indexPath.row == 2) {
        [self startTimer];
    } else if (indexPath.row == 3) {
        [QQToast showSuccess:@"加载成功"];
    } else if (indexPath.row == 4) {
        [QQToast showError:@"加载失败"];
    } else if (indexPath.row == 5) {
        [QQToast showInfo:@"缓存已清除"];
    } else if (indexPath.row == 6) {
        [QQToast showInfo:@"改变主题颜色"];
        [QQToast setTintColor:UIColor.qq_randomColor];
    } else if (indexPath.row == 7) {
        [QQToast showWithText:@"只显示文字"];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)progressChange {
    static CGFloat progress = 0.0;
    progress += 0.01;
    [QQToast showProgress:progress text:@"下载中..."];
    if (progress >= 1.0) {
        [self stopTimer];
        [QQToast showSuccess:@"下载成功"];
        progress = 0;
    }
}

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                  target:self
                                                selector:@selector(progressChange)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

@end
