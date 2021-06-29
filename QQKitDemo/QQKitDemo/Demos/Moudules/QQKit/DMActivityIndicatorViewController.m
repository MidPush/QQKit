//
//  DMActivityIndicatorViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/5/20.
//

#import "DMActivityIndicatorViewController.h"
#import "QQActivityIndicatorView.h"
#import "QQUIHelper.h"
#import "UIView+QQExtension.h"

@interface DMActivityIndicatorViewController ()

@property (nonatomic, strong) UILabel *titleLabel1;
@property (nonatomic, strong) QQActivityIndicatorView *customLoadingView;
@property (nonatomic, strong) UILabel *titleLabel2;
@property (nonatomic, strong) UIActivityIndicatorView *systemLoadingView;

@end

@implementation DMActivityIndicatorViewController

- (void)loadView {
    UIScrollView *s = [[UIScrollView alloc] init];
    s.contentSize = CGSizeMake(QQUIHelper.deviceWidth, 2 * QQUIHelper.deviceHeight);
    self.view = s;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)initSubviews {
    
    _titleLabel1 = [[UILabel alloc] init];
    _titleLabel1.textColor = UIColor.dm_blackColor;
    _titleLabel1.font = [UIFont systemFontOfSize:12];
    _titleLabel1.text = @"QQActivityIndicatorView，iOS13之前风格";
    [_titleLabel1 sizeToFit];
    [self.view addSubview:_titleLabel1];
    
    _customLoadingView = [[QQActivityIndicatorView alloc] initWithActivityIndicatorStyle:QQActivityIndicatorViewStyleWhite];
    _customLoadingView.hidesWhenStopped = NO;
    _customLoadingView.color = [UIColor dm_tintColor];
    [self.view addSubview:_customLoadingView];
    
    _titleLabel2 = [[UILabel alloc] init];
    _titleLabel2.textColor = UIColor.dm_blackColor;
    _titleLabel2.font = [UIFont systemFontOfSize:12];
    _titleLabel2.text = @"UIActivityIndicatorView，系统风格";
    [_titleLabel2 sizeToFit];
    [self.view addSubview:_titleLabel2];
    
    _systemLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _systemLoadingView.hidesWhenStopped = NO;
    _systemLoadingView.color = [UIColor dm_tintColor];
    [self.view addSubview:_systemLoadingView];
    
    [_customLoadingView startAnimating];
    [_systemLoadingView startAnimating];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _titleLabel1.frame = CGRectMake((self.view.qq_width - _titleLabel1.qq_width) / 2, QQUIHelper.navigationBarMaxY + 50, _titleLabel1.qq_width, _titleLabel1.qq_height);
    
    _customLoadingView.frame = CGRectMake((self.view.qq_width - _customLoadingView.qq_width) / 2, _titleLabel1.qq_bottom + 10, _customLoadingView.qq_width, _customLoadingView.qq_height);
    
    _titleLabel2.frame = CGRectMake((self.view.qq_width - _titleLabel2.qq_width) / 2, _customLoadingView.qq_bottom + 40, _titleLabel2.qq_width, _titleLabel2.qq_height);
    
    _systemLoadingView.frame = CGRectMake((self.view.qq_width - _systemLoadingView.qq_width) / 2, _titleLabel2.qq_bottom + 10, _systemLoadingView.qq_width, _systemLoadingView.qq_height);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_customLoadingView.isAnimating) {
        [_customLoadingView stopAnimating];
    } else {
        [_customLoadingView startAnimating];
    }
    
    if (_systemLoadingView.isAnimating) {
        [_systemLoadingView stopAnimating];
    } else {
        [_systemLoadingView startAnimating];
    }
    
    _customLoadingView.color = UIColor.qq_randomColor;
    _systemLoadingView.color = _customLoadingView.color;
}

@end
