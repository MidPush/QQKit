//
//  QQVideoImageFrameCell.m
//  QQKitDemo
//
//  Created by Mac on 2021/6/22.
//

#import "QQVideoImageFrameCell.h"

@implementation QQVideoImageFrameModel

@end

@interface QQVideoImageFrameCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation QQVideoImageFrameCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    _imageView = [[UIImageView alloc] init];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = CGRectMake(0, 0, self.frame.size.width - 1, self.frame.size.height);
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
}

- (void)setImageFrameModel:(QQVideoImageFrameModel *)imageFrameModel {
    _imageFrameModel = imageFrameModel;
    _imageView.image = imageFrameModel.image;
}

@end
