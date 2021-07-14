//
//  DMWebViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/7/11.
//

#import "DMWebViewController.h"
#import "QQWebViewController.h"
#import <SafariServices/SafariServices.h>

@interface DMWebViewController ()

@property (nonatomic, strong) QQTextField *textField;
@property (nonatomic, strong) QQFillButton *openButton;
@property (nonatomic, strong) QQFillButton *safariButton;

@end

@implementation DMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.dm_whiteColor;
}

- (void)initSubviews {
    _textField = [[QQTextField alloc] init];
    _textField.placeholder = @"请输入网址";
    _textField.text = @"https://www.baidu.com";
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.placeholderColor = UIColor.dm_placeholderColor;
    _textField.textInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    _textField.tintColor = UIColor.dm_tintColor;
    _textField.font = [UIFont systemFontOfSize:13];
    _textField.layer.borderWidth = QQUIHelper.pixelOne;
    _textField.layer.borderColor = UIColor.dm_separatorColor.CGColor;
    _textField.layer.cornerRadius = 4;
    [self.view addSubview:_textField];
    
    _openButton = [[QQFillButton alloc] initWithFillColor:UIColor.dm_tintColor titleTextColor:UIColor.dm_whiteTextColor];
    _openButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_openButton setTitle:@"QQWeb打开" forState:UIControlStateNormal];
    [_openButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_openButton];

    _safariButton = [[QQFillButton alloc] initWithFillColor:UIColor.dm_tintColor titleTextColor:UIColor.dm_whiteTextColor];
    _safariButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_safariButton setTitle:@"Safari打开" forState:UIControlStateNormal];
    [_safariButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_safariButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _textField.frame = CGRectMake(15, QQUIHelper.navigationBarMaxY + 30, self.view.qq_width - 30, 44);
    _openButton.frame = CGRectMake((self.view.qq_width - 200) / 2, _textField.qq_bottom + 30, 200, 44);
    _safariButton.frame = CGRectMake((self.view.qq_width - 200) / 2, _openButton.qq_bottom + 30, 200, 44);
}

- (void)onButtonClicked:(UIButton *)button {
    if (self.textField.text.length == 0) {
        [QQToast showInfo:@"请输入网址"];
        return;
    }
    NSURL *url = [NSURL URLWithString:self.textField.text];
    if (button == _openButton) {
        QQWebViewController *vc = [[QQWebViewController alloc] initWithURL:url];
        vc.showsToolbar = YES;
        vc.hidesToolbarOnSwipe = YES;
        vc.progressTintColor = UIColor.dm_tintColor;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if (@available(iOS 11.0, *)) {
            SFSafariViewController *v = [[SFSafariViewController alloc] initWithURL:url];
            v.preferredControlTintColor = UIColor.dm_tintColor;
            v.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleClose;
            [self presentViewController:v animated:YES completion:nil];
        } else {
            [QQToast showInfo:@"SafariViewController只支持 iOS 11.0 之后"];
        }
    }
}

@end
