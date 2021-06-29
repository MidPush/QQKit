//
//  QQCheckboxButton.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQCheckboxButton.h"
#import "UIColor+QQExtension.h"
#import "QQAssetsPicker.h"

@interface QQCheckboxButton ()


@end

@implementation QQCheckboxButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithImage:[QQAssetsPicker sharedPicker].configuration.assetPickerCheckMarkNormalImage];
        [self addSubview:_imageView];
        
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.hidden = YES;
        _indexLabel.font = [UIFont systemFontOfSize:13];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.layer.masksToBounds = YES;
        _indexLabel.backgroundColor = [UIColor qq_colorWithHexString:@"00CC68"];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_indexLabel];
        
        _actionButton = [[QQButton alloc] init];
        _actionButton.outsideEdgeInsets = [self outsideEdgeInsets];
        [self addSubview:_actionButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    _actionButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGSize imageSize = _imageView.frame.size;
    _imageView.frame = CGRectMake((CGRectGetWidth(self.frame) - imageSize.width) / 2, (CGRectGetHeight(self.frame) - imageSize.height) / 2, imageSize.width, imageSize.height);
    CGSize labeSize = CGSizeMake(imageSize.width + 2, imageSize.height + 2);
    _indexLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - labeSize.width) / 2, (CGRectGetHeight(self.frame) - labeSize.height) / 2, labeSize.width, labeSize.height);
    _indexLabel.layer.cornerRadius = labeSize.height / 2;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
    [self resizeSubviews];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets outsideEdgeInsets = [self outsideEdgeInsets];
    CGRect bounds = CGRectMake(self.bounds.origin.x - outsideEdgeInsets.left, self.bounds.origin.y - outsideEdgeInsets.top, self.bounds.size.width + outsideEdgeInsets.left + outsideEdgeInsets.right, self.bounds.size.height + outsideEdgeInsets.top + outsideEdgeInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}

- (UIEdgeInsets)outsideEdgeInsets {
    return UIEdgeInsetsMake(5, 20, 20, 5);
}

@end
