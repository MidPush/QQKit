//
//  DMGridViewController.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/14.
//

#import "DMGridViewController.h"

static NSString *kGridCellReuseID = @"DMGridCell";
@interface DMGridCell : QQCollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation DMGridCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor dm_whiteColor];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.numberOfLines = 4;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height);
}

@end

@interface DMGridViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) QQCollectionView *collectionView;

@end

@implementation DMGridViewController

- (instancetype)init {
    if (self = [super init]) {
        [self initDataSource];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)initDataSource {
    
}

- (void)setDataSource:(NSArray<NSDictionary *> *)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
}

- (void)initSubviews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = [QQUIHelper pixelOne];
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[QQCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[DMGridCell class] forCellWithReuseIdentifier:kGridCellReuseID];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    BOOL isSizeChanged = !CGSizeEqualToSize(self.collectionView.bounds.size, CGSizeMake(self.view.frame.size.width, self.view.frame.size.height));
    if (isSizeChanged) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
    _collectionView.frame = self.view.bounds;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DMGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kGridCellReuseID forIndexPath:indexPath];
    cell.titleLabel.text = self.dataSource[indexPath.row].allKeys.firstObject;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.dataSource[indexPath.row].allKeys.firstObject;
    NSString *className = self.dataSource[indexPath.row][key];
    if (className.length > 0) {
        UIViewController *vc = [[NSClassFromString(className) alloc] init];
        vc.title = key;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemCount = 3;
    if (CGRectGetWidth(self.view.frame) > CGRectGetHeight(self.view.frame)) {
        itemCount = 5;
    }
    CGFloat itemWidth = ((CGRectGetWidth(self.view.frame) - (itemCount - 1) * [QQUIHelper pixelOne]) / itemCount);
    return CGSizeMake(itemWidth, itemWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    DMGridCell *cell = (DMGridCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [QQUIConfiguration sharedInstance].cellSelectedBackgroundColor;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    DMGridCell *cell = (DMGridCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

@end
