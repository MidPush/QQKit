//
//  QQTableViewCell.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "QQTableViewCell.h"
#import "QQUIConfiguration.h"

@implementation QQTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([QQUIConfiguration sharedInstance].cellSelectedBackgroundColor) {
        self.selectedBackgroundColor = [QQUIConfiguration sharedInstance].cellSelectedBackgroundColor;
    }
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    _selectedBackgroundColor = selectedBackgroundColor;
    // 系统默认的 selectedBackgroundView 是 UITableViewCellSelectedBackground，无法修改自定义背景色，所以改为用普通的 UIView
    if ([NSStringFromClass(self.selectedBackgroundView.class) hasPrefix:@"UITableViewCell"]) {
        self.selectedBackgroundView = [[UIView alloc] init];
    }
    self.selectedBackgroundView.backgroundColor = selectedBackgroundColor;
}

@end
