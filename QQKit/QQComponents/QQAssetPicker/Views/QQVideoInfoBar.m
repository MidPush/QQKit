//
//  QQVideoInfoBar.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import "QQVideoInfoBar.h"
#import "UIView+QQExtension.h"
#import "QQAssetsPicker.h"
#import "QQAssetsPickerHelper.h"

@interface QQVideoInfoBar ()

@property (nonatomic, strong) UIImageView *videoIcon;
@property (nonatomic, strong) UILabel *durationLabel;

@end

@implementation QQVideoInfoBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _videoIcon = [[UIImageView alloc] initWithImage:[QQAssetsPicker sharedPicker].configuration.assetPickerVideoImage];
        [self addSubview:_videoIcon];
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:11];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_durationLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    [_videoIcon sizeToFit];
    _videoIcon.frame = CGRectMake(3, (self.qq_height - _videoIcon.qq_height) / 2, _videoIcon.qq_width, _videoIcon.qq_height);
    
    CGFloat durationLabelWidth = self.qq_width - _videoIcon.qq_right - 5;
    CGFloat durationLabelHeight = self.qq_height;
    CGFloat durationLabelX = self.qq_width - durationLabelWidth - 3;
    _durationLabel.frame = CGRectMake(durationLabelX, 0, durationLabelWidth, durationLabelHeight);
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    _durationLabel.text = [QQAssetsPickerHelper formatTime:duration];
    [self resizeSubviews];
}

@end
