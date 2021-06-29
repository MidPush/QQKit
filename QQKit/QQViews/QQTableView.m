//
//  QQTableView.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "QQTableView.h"

@interface QQTableView ()<UIGestureRecognizerDelegate>

@end

@implementation QQTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

@end
