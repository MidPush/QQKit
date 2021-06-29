//
//  DMOrientationViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "DMOrientationViewController.h"

@interface DMOrientationData : NSObject
@property (nonatomic, assign) UIInterfaceOrientationMask mask;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL selected;
@end

@implementation DMOrientationData
@end

@interface DMOrientationCell : QQTableViewCell
@property (nonatomic, strong) DMOrientationData *orientationData;
@end

@implementation DMOrientationCell
- (void)setOrientationData:(DMOrientationData *)orientationData {
    _orientationData = orientationData;
    self.textLabel.text = orientationData.text;
    self.accessoryType = orientationData.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}
@end

@interface DMOrientationViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) QQTableView *tableView;
@property (nonatomic, strong) NSArray *datas;

@end

@implementation DMOrientationViewController

- (NSArray<NSString *> *)datas {
    if (!_datas) {
        DMOrientationData *data1 = [[DMOrientationData alloc] init];
        data1.text = @"UIInterfaceOrientationMaskPortrait";
        data1.mask = UIInterfaceOrientationMaskPortrait;
        data1.selected = YES;
        
        DMOrientationData *data2 = [[DMOrientationData alloc] init];
        data2.text = @"UIInterfaceOrientationMaskLandscapeLeft";
        data2.mask = UIInterfaceOrientationMaskLandscapeLeft;
        data2.selected = YES;
        
        DMOrientationData *data3 = [[DMOrientationData alloc] init];
        data3.text = @"UIInterfaceOrientationMaskLandscapeRight";
        data3.mask = UIInterfaceOrientationMaskLandscapeRight;
        data3.selected = YES;
        
        DMOrientationData *data4 = [[DMOrientationData alloc] init];
        data4.text = @"UIInterfaceOrientationMaskPortraitUpsideDown";
        data4.mask = UIInterfaceOrientationMaskPortraitUpsideDown;
        data4.selected = YES;
            
        _datas = @[data1, data2, data3, data4];
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)initSubviews {
    _tableView = [[QQTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    
    QQButton *button = [[QQButton alloc] initWithFrame:CGRectMake(0, 0, _tableView.qq_width, 100)];
    button.backgroundColor = UIColor.dm_whiteColor;
    [button setTitle:@"完成方向选择，进入该界面" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.dm_tintColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onTableFooterViewButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _tableView.tableFooterView = button;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DMOrientationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DMOrientationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.tintColor = UIColor.dm_tintColor;
    }
    DMOrientationData *data = self.datas[indexPath.row];
    cell.orientationData = data;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DMOrientationData *data = self.datas[indexPath.row];
    data.selected = !data.selected;
    [self.tableView reloadData];
}

- (void)onTableFooterViewButtonClicked {
    UIInterfaceOrientationMask mask = 0;
    for (DMOrientationData *data in self.datas) {
        if (data.selected) {
            mask |= data.mask;
        }
    }
    DMOrientationViewController *viewController = [[DMOrientationViewController alloc] init];
    viewController.supportedOrientationMask = mask;
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
