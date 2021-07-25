//
//  DMTextViewViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "DMTextViewViewController.h"

@interface DMTextViewViewController ()

@property (nonatomic, strong) QQTextView *textView;
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation DMTextViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.dm_whiteColor;
}

- (void)initSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    _textView = [[QQTextView alloc] init];
    _textView.placeholder = @"可设置placeholder、限制文本输入长度";
    _textView.placeholderColor = UIColor.dm_placeholderColor;
    _textView.maximumTextLength = 20;
    _textView.tintColor = UIColor.dm_tintColor;
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.layer.borderWidth = QQUIHelper.pixelOne;
    _textView.layer.borderColor = UIColor.dm_separatorColor.CGColor;
    _textView.layer.cornerRadius = 4;
    [self.view addSubview:_textView];
    
    _tipsLabel = [[UILabel alloc] init];
//    _tipsLabel.text = [NSString stringWithFormat:@"最长不超过 %@ 个文字，可尝试输入 emoji、粘贴一大段文字。", @(self.textView.maximumTextLength)];
    _tipsLabel.textColor = UIColor.dm_lightGrayColor;
    _tipsLabel.font = [UIFont systemFontOfSize:12];
    _tipsLabel.numberOfLines = 0;
    [self.view addSubview:_tipsLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _textView.frame = CGRectMake(15, QQUIHelper.navigationBarMaxY + 30, self.view.qq_width - 30, 80);
    
    CGFloat tipsLabelHeight = [self.tipsLabel sizeThatFits:CGSizeMake(_textView.qq_width, CGFLOAT_MAX)].height;
    _tipsLabel.frame = CGRectMake(_textView.qq_left, _textView.qq_bottom + 10, _textView.qq_width, tipsLabelHeight);
}

@end
