//
//  QQAlbumCell.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/5.
//

#import "QQAlbumCell.h"
#import "UIView+QQExtension.h"
#import "QQAssetsPicker.h"

@interface QQAlbumCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIView *line;

@end

@implementation QQAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1.0];
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        
        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.clipsToBounds = YES;
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_thumbnailImageView];
        
        _albumNameLabel = [[UILabel alloc] init];
        _albumNameLabel.textColor = [UIColor whiteColor];
        _albumNameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_albumNameLabel];
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont systemFontOfSize:15];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_countLabel];
        
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithRed:69 / 255.0 green:69 / 255.0 blue:69 / 255.0 alpha:1.0];
        [self.contentView addSubview:_line];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    _thumbnailImageView.frame = CGRectMake(0, (self.qq_height - kQQAlbumCellHeight) / 2, kQQAlbumCellHeight, kQQAlbumCellHeight);
    [_countLabel sizeToFit];
    CGFloat nameMargin = 15;
    CGSize albumNameSize = [_albumNameLabel.text boundingRectWithSize:CGSizeMake(self.qq_width - CGRectGetWidth(_thumbnailImageView.frame) - nameMargin - _countLabel.qq_width - 20, self.qq_height) options:0 attributes:@{NSFontAttributeName:_countLabel.font} context:nil].size;
    _albumNameLabel.frame = CGRectMake(CGRectGetMaxX(_thumbnailImageView.frame) + nameMargin, (self.frame.size.height - albumNameSize.height) / 2, albumNameSize.width, albumNameSize.height);
    _countLabel.frame = CGRectMake(CGRectGetMaxX(_albumNameLabel.frame), (self.qq_height - _countLabel.qq_height) / 2, _countLabel.qq_width, _countLabel.qq_height);
    _line.frame = CGRectMake(0, self.qq_height - 1 / [UIScreen mainScreen].scale, self.qq_width, 1 / [UIScreen mainScreen].scale);
}

- (void)setAlbum:(QQAssetsGroup *)album {
    _album = album;
    _albumNameLabel.text = album.name;
    _countLabel.text = [NSString stringWithFormat:@"（%ld）", (long)album.numberOfAssets];
    [self resizeSubviews];
    if (album.thumbnailImage) {
        _thumbnailImageView.image = album.thumbnailImage;
    } else {
        [[QQAssetsPicker sharedPicker] requestThumbnailImageWithAlbum:album size:CGSizeMake(kQQAlbumCellHeight, kQQAlbumCellHeight) completion:^(QQAssetsGroup *group, UIImage *result) {
            if (self.album == group) {
                self.thumbnailImageView.image = result;
            }
        }];
    }
}

@end
