//
//  DMModalViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/7/10.
//

#import "DMModalViewController.h"
#import "QQModalView.h"
#import "QQModalViewController.h"
#import "QQConfirmModalController.h"
#import "QQAlertController.h"
#import "CALayer+QQExtension.h"

@interface DMModalViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) QQTableView *tableView;

@property (nonatomic, strong) NSArray *datas;

@end

@implementation DMModalViewController

- (NSArray<NSString *> *)datas {
    if (!_datas) {
        _datas = @[
            @[
                @"Modal 动画，默认提供3种动画",
                @"自定义背景遮罩",
                @"layoutBlock，自定义布局"
            ],
            @[
                @"Modal 动画，默认提供3种动画",
                @"自定义背景遮罩",
                @"layoutBlock，自定义布局"
            ],
            @[
                @"弹出 QQConfirmModalController",
            ],
            @[
                @"弹出 QQAlertController",
                @"弹出系统 UIAlertController"
            ],
            
        ];
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.datas[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[QQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.tintColor = UIColor.dm_tintColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.datas[indexPath.section][indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"以QQModalView方式显示";
    } else if (section == 1) {
        return @"以QQModalViewController方式显示";
    } else if (section == 2) {
        return @"QQConfirmModalController";
    } else if (section == 3) {
        return @"QQAlertController";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 1) {
        BOOL isVC = (indexPath.section == 1);
        if (indexPath.row == 0) {
            [self showModalView:NO isVC:isVC];
        } else if (indexPath.row == 1) {
            [self showModalView:YES isVC:isVC];
        } else if (indexPath.row == 2) {
            [self showLayoutBlock:isVC];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            QQConfirmModalController *confirmViewController = [[QQConfirmModalController alloc] init];
            confirmViewController.title = @"标题";
            confirmViewController.message = @"modalView提供的显示/隐藏动画总共有3种，可通过animationStyle属性来设置，默认为QQModalAnimationStyleFade。\n\n多次打开此浮层会在这3种动画之间互相切换。";
            [confirmViewController.submitButton setTitle:@"点击改变样式" forState:UIControlStateNormal];
            [confirmViewController showFromController:self];
            
            confirmViewController.actionsHandler = ^(QQConfirmModalController * _Nonnull controller, BOOL isSubmit) {
                if (!isSubmit) {
                    [controller dismiss];
                    return;
                }
                NSArray *changeTitles = @[@"", @"标题", @"标题标题"];
                NSArray *changeMessages = @[@"消息消息消息消息", @"modalView提供的显示/隐藏动画总共有3种，可通过animationStyle属性来设置，默认为QQModalAnimationStyleFade。\n\n多次打开此浮层会在这3种动画之间互相切换。"];
                controller.titleViewHeight = arc4random() % 13 + 48;
                controller.title = changeTitles[arc4random() % 3];
                controller.titleView.backgroundColor = UIColor.qq_randomColor;
                controller.titleViewSeparatorColor = UIColor.qq_randomColor;
                
                controller.contentView.backgroundColor = UIColor.qq_randomColor;
                controller.message = changeMessages[arc4random() % 2];
                
                controller.actionsViewHeight = arc4random() % 13 + 48;
                [controller.cancelButton setTitleColor:UIColor.qq_randomColor forState:UIControlStateNormal];
                [controller.submitButton setTitleColor:UIColor.qq_randomColor forState:UIControlStateNormal];
                controller.actionsViewSeparatorColor = UIColor.qq_randomColor;
            };
            
        }
    } else if (indexPath.section == 3) {
        NSString *title = @"ceil用 法： double ceil(double x);功 能： 返回大于或者等于指定表达式的最小整数头文件：math.h返回数据类型：double";
        NSString *message = @"ceil用 法： double ceil(double x);功 能：";
        
        NSInteger addCount = 0;
//        title = nil;
//        message = nil;
        NSInteger preferredStyle = QQAlertControllerStyleAlert;
        if (indexPath.row == 0) {
            QQAlertController *alert = [QQAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
            
            QQAlertAction *action2 = [QQAlertAction actionWithTitle:@"取消" style:QQAlertActionStyleCancel handler:^(QQAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action2];
            
            QQAlertAction *action3 = [QQAlertAction actionWithTitle:@"确认" style:QQAlertActionStyleDestructive handler:^(QQAlertAction * _Nonnull action) {
                
            }] ;
            [alert addAction:action3];
            
            for (NSInteger i = 0; i < addCount; i++) {
                QQAlertAction *action4 = [QQAlertAction actionWithTitle:@"确认" style:QQAlertActionStyleDestructive handler:^(QQAlertAction * _Nonnull action) {

                }] ;
                [alert addAction:action4];
            }

//            for (NSInteger i = 0; i < 2; i++) {
//                [alert addTextFieldWithConfigurationHandler:nil];
//            }
            
            
            UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            visualEffectView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            
            UIVisualEffectView *visualEffectView2 = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            visualEffectView2.backgroundColor = [UIColor whiteColor];
            
            alert.mainVisualEffectView = visualEffectView;
            alert.cancelButtonVisualEffectView = visualEffectView2;
            alert.alertContainerBackgroundColor = nil;
            alert.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
            alert.alertButtonBackgroundColor = nil;
            [alert showFromController:self];
        } else if (indexPath.row == 1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
            
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action2];
            
            UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
            }] ;
            [alert addAction:action3];
            
            for (NSInteger i = 0; i < addCount; i++) {
                UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

                }] ;
                [alert addAction:action4];
            }
            
//            for (NSInteger i = 0; i < 2; i++) {
//                [alert addTextFieldWithConfigurationHandler:nil];
//            }
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}


- (void)showModalView:(BOOL)customDimmingView isVC:(BOOL)isVC {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    contentView.backgroundColor = UIColor.dm_whiteColor;
    contentView.layer.cornerRadius = 6;
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"modalView提供的显示/隐藏动画总共有3种，可通过animationStyle属性来设置，默认为QQModalAnimationStyleFade。\n\n多次打开此浮层会在这3种动画之间互相切换。" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName: UIColor.dm_mainTextColor}];
    label.attributedText = attributedString;
    
    UIEdgeInsets contentViewPadding = UIEdgeInsetsMake(20, 20, 20, 20);
    CGSize labelSize = [label sizeThatFits:CGSizeMake(contentView.qq_width - contentViewPadding.left - contentViewPadding.right, contentView.qq_height - contentViewPadding.top - contentViewPadding.bottom)];
    
    label.frame = CGRectMake(contentViewPadding.left, contentViewPadding.top, labelSize.width, labelSize.height);
    [contentView addSubview:label];
    
    UIView *dimmingView = nil;
    if (customDimmingView) {
        dimmingView = [[UIView alloc] init];
        dimmingView.backgroundColor = [UIColor.dm_tintColor colorWithAlphaComponent:.35];
    }
    
    static QQModalAnimationStyle style = QQModalAnimationStyleFade;
    
    if (isVC) {
        QQModalViewController *modalVC = [[QQModalViewController alloc] init];
        modalVC.modalAnimationStyle = style % 3;
        modalVC.contentView = contentView;
        if (dimmingView) {
            modalVC.dimmingView = dimmingView;
        }
        [modalVC show];
    } else {
        QQModalView *modalView = [[QQModalView alloc] initWithFrame:CGRectZero];
        modalView.modalAnimationStyle = style % 3;
        modalView.contentView = contentView;
        if (dimmingView) {
            modalView.dimmingView = dimmingView;
        }
        [modalView show];
    }
    style++;
}

- (void)showLayoutBlock:(BOOL)isVC {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    contentView.backgroundColor = UIColor.dm_whiteColor;
    contentView.layer.cornerRadius = 10;
    contentView.layer.qq_maskedCorners = QQLayerMinXMinYCorner|QQLayerMaxXMinYCorner;
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"利用layoutBlock可以自定义浮层的布局，注意此时contentViewMargins属性无效，如果需要实现外间距，请自行计算" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName: UIColor.dm_mainTextColor}];
    label.attributedText = attributedString;
    
    UIEdgeInsets contentViewPadding = UIEdgeInsetsMake(20, 20, 20, 20);
    CGSize labelSize = [label sizeThatFits:CGSizeMake(contentView.qq_width - contentViewPadding.left - contentViewPadding.right, contentView.qq_height - contentViewPadding.top - contentViewPadding.bottom)];
    
    label.frame = CGRectMake(contentViewPadding.left, contentViewPadding.top, labelSize.width, labelSize.height);
    [contentView addSubview:label];
    
    if (isVC) {
        QQModalViewController *modalVC = [[QQModalViewController alloc] init];
        modalVC.modalAnimationStyle = QQModalAnimationStyleSheet;
        modalVC.contentView = contentView;
        modalVC.layoutBlock = ^(CGRect containerBounds,  CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
            contentView.frame = CGRectMake((self.view.qq_width - contentView.qq_width) / 2, containerBounds.size.height - contentView.qq_height, contentView.qq_width, contentView.qq_height);
        };
        [modalVC show];
    } else {
        QQModalView *modalView = [[QQModalView alloc] initWithFrame:CGRectZero];
        modalView.modalAnimationStyle = QQModalAnimationStyleSheet;
        modalView.contentView = contentView;
        modalView.layoutBlock = ^(CGRect containerBounds,  CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
            contentView.frame = CGRectMake((self.view.qq_width - contentView.qq_width) / 2, containerBounds.size.height - contentView.qq_height, contentView.qq_width, contentView.qq_height);
        };
        [modalView show];
    }

}

@end
