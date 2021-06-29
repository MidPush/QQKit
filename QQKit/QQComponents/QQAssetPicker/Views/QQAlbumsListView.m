//
//  QQAlbumsListView.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/5.
//

#import "QQAlbumsListView.h"
#import "QQAlbumCell.h"

@interface QQAlbumsListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIControl *backgroundView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation QQAlbumsListView

- (instancetype)initWithFrame:(CGRect)frame albums:(NSArray<QQAssetsGroup *> *)albums {
    if (self = [super initWithFrame:frame]) {
        _albums = albums;
        _backgroundView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [_backgroundView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundView];
        
        CGFloat maxCount = frame.size.width > frame.size.height ? 5 : 8;
        CGFloat contentViewHeight = MIN(albums.count * kQQAlbumCellHeight, maxCount * kQQAlbumCellHeight);
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, -contentViewHeight, self.frame.size.width, contentViewHeight)];
        _contentView.backgroundColor = [UIColor colorWithRed:49 / 255.0 green:49 / 255.0 blue:49 / 255.0 alpha:1.0];
        [self addSubview:_contentView];
        
        _tableView = [[UITableView alloc] initWithFrame:_contentView.bounds];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = kQQAlbumCellHeight;
        [_contentView addSubview:_tableView];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = NO;
        }
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"QQAlbumCell";
    QQAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[QQAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    cell.album = self.albums[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(albumsListView:didSelectAlbum:)]) {
        QQAssetsGroup *album = self.albums[indexPath.row];
        [self.delegate albumsListView:self didSelectAlbum:album];
    }
    [self dismiss];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGSizeEqualToSize(_backgroundView.frame.size, self.frame.size)) {
        _backgroundView.frame = self.bounds;
        NSInteger maxCount = 8;
        if (self.frame.size.width > self.frame.size.height) {
            maxCount = 5;
        }
        CGFloat contentViewHeight = MIN(_albums.count * kQQAlbumCellHeight, maxCount * kQQAlbumCellHeight);
        _contentView.frame = CGRectMake(_contentView.frame.origin.x, _contentView.frame.origin.y, self.frame.size.width, contentViewHeight);
        _tableView.frame = _contentView.bounds;
        [_tableView reloadData];
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    _contentView.layer.mask = maskLayer;
    _contentView.layer.masksToBounds = YES;
}

- (void)showInView:(UIView *)view {
    [view addSubview:self];
    _backgroundView.alpha = 0;
    _show = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 1;
        self.contentView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
    if ([self.delegate respondsToSelector:@selector(albumsListViewDidShow:)]) {
        [self.delegate albumsListViewDidShow:self];
    }
}

- (void)dismiss {
    _show = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0;
        self.contentView.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    if ([self.delegate respondsToSelector:@selector(albumsListViewDidDismiss:)]) {
        [self.delegate albumsListViewDidDismiss:self];
    }
}

@end
