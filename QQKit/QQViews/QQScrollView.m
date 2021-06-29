//
//  QQScrollView.m
//  JiXinMei
//
//  Created by Mac on 2021/3/4.
//

#import "QQScrollView.h"

@interface QQScrollView ()<UIGestureRecognizerDelegate>

@end

@implementation QQScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
}

@end
