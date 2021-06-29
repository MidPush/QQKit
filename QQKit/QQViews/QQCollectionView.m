//
//  QQCollectionView.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "QQCollectionView.h"

@implementation QQCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
}

@end
