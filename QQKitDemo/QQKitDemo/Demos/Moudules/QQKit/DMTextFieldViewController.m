//
//  DMTextFieldViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "DMTextFieldViewController.h"

@interface DMTextFieldViewController ()

@property (nonatomic, strong) QQTextField *textField;
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation DMTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.dm_whiteColor;
}

- (void)initSubviews {
    _textField = [[QQTextField alloc] init];
    _textField.placeholder = @"请输入文字";
    _textField.placeholderColor = UIColor.dm_placeholderColor;
    _textField.maximumTextLength = 20;
    _textField.textInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    _textField.tintColor = UIColor.dm_tintColor;
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.layer.borderWidth = QQUIHelper.pixelOne;
    _textField.layer.borderColor = UIColor.dm_separatorColor.CGColor;
    _textField.layer.cornerRadius = 4;
    [self.view addSubview:_textField];
    
    _tipsLabel = [[UILabel alloc] init];
    _tipsLabel.text = @"支持：\n1. 自定义 placeholder 颜色；\n2.调整输入框与文字之间的间距；\n3. 限制可输入的最大文字长度（可试试输入 emoji、从中文输入法候选词输入等）。";
    _tipsLabel.textColor = UIColor.dm_lightGrayColor;
    _tipsLabel.font = [UIFont systemFontOfSize:12];
    _tipsLabel.numberOfLines = 0;
    [self.view addSubview:_tipsLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _textField.frame = CGRectMake(15, QQUIHelper.navigationBarMaxY + 30, self.view.qq_width - 30, 44);
    
    CGFloat tipsLabelHeight = [self.tipsLabel sizeThatFits:CGSizeMake(_textField.qq_width, CGFLOAT_MAX)].height;
    _tipsLabel.frame = CGRectMake(_textField.qq_left, _textField.qq_bottom + 10, _textField.qq_width, tipsLabelHeight);
}

@end
