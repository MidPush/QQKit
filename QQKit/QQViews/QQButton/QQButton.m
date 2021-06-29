//
//  QQButton.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "QQButton.h"

@interface QQButton ()

@property (nonatomic, strong) CALayer *highlightedBackgroundLayer;
@property (nonatomic, strong) UIColor *originBorderColor;

@end

@implementation QQButton

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
    // 去掉系统默认的表现
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    self.adjustsButtonWhenHighlighted = YES;
    self.adjustsButtonWhenDisabled = YES;
    
    // 图片默认在按钮左边
    self.imagePosition = QQButtonImagePositionLeft;
}

// 系统访问 self.imageView 会触发 layout
- (UIImageView *)_qq_imageView {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString(@"_imageView");
    if ([self respondsToSelector:sel]) {
        return [self performSelector:sel];
    }
#pragma clang diagnostic pop
    return nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    /** 计算imageView、titleLabel的frame，计算方式和系统的UIButton不同：
     *系统默认计算方式：当按钮的 bounds 比较小时，系统会尽量展示图片的完整性。
     *下面计算方式：当按钮的 bounds 比较小时，QQButton会尽量展示图片和文字整体的完整性。
     *所以设置同样的contentEdgeInsets、 imageEdgeInsets、titleEdgeInsets值，当按钮的 bounds 比较小时，展示的效果可能不同。
     *先这样吧，以后有时间再研究系统默认的计算方式（^_^）
     */
    
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    BOOL isImageViewShowing = self.currentImage;
    BOOL isTitleLabelShowing = self.currentTitle || self.currentAttributedTitle;
    CGFloat spacingBetweenImageAndTitle = (isImageViewShowing && isTitleLabelShowing) ? self.spacingBetweenImageAndTitle : 0;
    
    CGSize contentSize = self.bounds.size;
    CGSize imageSize = CGSizeZero;
    CGSize titleSize = CGSizeZero;
    CGFloat imageViewX = 0;
    CGFloat imageViewY = 0;
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = 0;
    
    if (isImageViewShowing) {
        imageSize = self.currentImage.size;
        imageSize.width = MIN(contentSize.width, imageSize.width);
        imageSize.height = MIN(contentSize.height, imageSize.height);
    }
    
    if (self.imagePosition == QQButtonImagePositionTop) {
        if (isTitleLabelShowing) {
            CGSize titleLimitSize = CGSizeMake(contentSize.width, contentSize.height - imageSize.height - spacingBetweenImageAndTitle);
            titleSize = [self titleSizeWithLimitSize:titleLimitSize];
        }
        if (isImageViewShowing) {
            titleLabelY = (imageSize.height + spacingBetweenImageAndTitle);
        }
    } else if (self.imagePosition == QQButtonImagePositionLeft) {
        if (isTitleLabelShowing) {
            CGSize titleLimitSize = CGSizeMake(contentSize.width - imageSize.width - spacingBetweenImageAndTitle, contentSize.height);
            titleSize = [self titleSizeWithLimitSize:titleLimitSize];
        }
        if (isImageViewShowing) {
            titleLabelX = (imageSize.width + spacingBetweenImageAndTitle);
        }
    } else if (self.imagePosition == QQButtonImagePositionBottom) {
        if (isTitleLabelShowing) {
            CGSize titleLimitSize = CGSizeMake(contentSize.width, contentSize.height - imageSize.height - spacingBetweenImageAndTitle);
            titleSize = [self titleSizeWithLimitSize:titleLimitSize];
        }
        if (isImageViewShowing) {
            imageViewY = (titleSize.height + spacingBetweenImageAndTitle);
        }
    } else if (self.imagePosition == QQButtonImagePositionRight) {
        if (isTitleLabelShowing) {
            CGSize titleLimitSize = CGSizeMake(contentSize.width - imageSize.width - spacingBetweenImageAndTitle, contentSize.height);
            titleSize = [self titleSizeWithLimitSize:titleLimitSize];
        }
        if (isImageViewShowing) {
            imageViewX = (titleSize.width + spacingBetweenImageAndTitle);
        }
    }
    
    CGPoint imageOffset = CGPointZero;
    CGPoint titleOffset = CGPointZero;
    CGPoint contentOffset = CGPointMake((self.contentEdgeInsets.left - self.contentEdgeInsets.right) / 2, (self.contentEdgeInsets.top - self.contentEdgeInsets.bottom) / 2);
    
    switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentLeft: {
            imageOffset.x = 0;
            titleOffset.x = 0;
        } break;
        case UIControlContentHorizontalAlignmentCenter: {
            if (self.imagePosition == QQButtonImagePositionTop || self.imagePosition == QQButtonImagePositionBottom) {
                imageOffset.x = (CGRectGetWidth(self.bounds) - imageSize.width) / 2;
                titleOffset.x = (CGRectGetWidth(self.bounds) - titleSize.width) / 2;
            } else if (self.imagePosition == QQButtonImagePositionLeft || self.imagePosition == QQButtonImagePositionRight) {
                imageOffset.x = (CGRectGetWidth(self.bounds) - imageSize.width - titleSize.width - spacingBetweenImageAndTitle) / 2;
                titleOffset.x = imageOffset.x;
            }
        } break;
        case UIControlContentHorizontalAlignmentRight: {
            if (self.imagePosition == QQButtonImagePositionTop || self.imagePosition == QQButtonImagePositionBottom) {
                imageOffset.x = CGRectGetWidth(self.bounds) - imageSize.width;
                titleOffset.x = CGRectGetWidth(self.bounds) - titleSize.width;
            } else if (self.imagePosition == QQButtonImagePositionLeft || self.imagePosition == QQButtonImagePositionRight) {
                imageOffset.x = CGRectGetWidth(self.bounds) - imageSize.width - titleSize.width - spacingBetweenImageAndTitle;
                titleOffset.x = imageOffset.x;
            }
        } break;
        case UIControlContentHorizontalAlignmentFill: {
            if (self.imagePosition == QQButtonImagePositionTop || self.imagePosition == QQButtonImagePositionBottom) {
                if (isImageViewShowing) {
                    imageSize.width = CGRectGetWidth(self.bounds);
                    imageViewX = 0;
                }
                if (isTitleLabelShowing) {
                    titleSize.width = CGRectGetWidth(self.bounds);
                    titleLabelX = 0;
                }
            } else if (self.imagePosition == QQButtonImagePositionLeft || self.imagePosition == QQButtonImagePositionRight) {
                CGFloat increase = CGRectGetWidth(self.bounds) - imageSize.width - titleSize.width - spacingBetweenImageAndTitle;
                if (isImageViewShowing && isTitleLabelShowing) {
                    increase = increase / 2;
                }
                if (isImageViewShowing) {
                    imageSize.width += increase;
                }
                if (isTitleLabelShowing) {
                    titleSize.width += increase;
                }
                if (self.imagePosition == QQButtonImagePositionLeft) {
                    titleLabelX = imageSize.width + spacingBetweenImageAndTitle;
                } else if (self.imagePosition == QQButtonImagePositionRight) {
                    imageViewX = titleSize.width + spacingBetweenImageAndTitle;
                }
            }
        } break;
        default:
            break;
    }
    
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop: {
            imageOffset.y = 0;
            titleOffset.y = 0;
        } break;
        case UIControlContentVerticalAlignmentCenter: {
            if (self.imagePosition == QQButtonImagePositionTop || self.imagePosition == QQButtonImagePositionBottom) {
                imageOffset.y = (CGRectGetHeight(self.bounds) - imageSize.height - titleSize.height - spacingBetweenImageAndTitle) / 2;
                titleOffset.y = imageOffset.y;
            } else if (self.imagePosition == QQButtonImagePositionLeft || self.imagePosition == QQButtonImagePositionRight) {
                imageOffset.y = (CGRectGetHeight(self.bounds) - imageSize.height) / 2;
                titleOffset.y = (CGRectGetHeight(self.bounds) - titleSize.height) / 2;
            }
        } break;
        case UIControlContentVerticalAlignmentBottom: {
            if (self.imagePosition == QQButtonImagePositionTop || self.imagePosition == QQButtonImagePositionBottom) {
                imageOffset.y = CGRectGetHeight(self.bounds) - imageSize.height - titleSize.height - spacingBetweenImageAndTitle;
                titleOffset.y = imageOffset.y;
            } else if (self.imagePosition == QQButtonImagePositionLeft || self.imagePosition == QQButtonImagePositionRight) {
                imageOffset.y = CGRectGetHeight(self.bounds) - imageSize.height;
                titleOffset.y = CGRectGetHeight(self.bounds) - titleSize.height;
            }
        } break;
        case UIControlContentVerticalAlignmentFill: {
            if (self.imagePosition == QQButtonImagePositionTop || self.imagePosition == QQButtonImagePositionBottom) {
                CGFloat increase = CGRectGetHeight(self.bounds) - imageSize.height - titleSize.height - spacingBetweenImageAndTitle;
                if (isImageViewShowing && isTitleLabelShowing) {
                    increase = increase / 2;
                }
                if (isImageViewShowing) {
                    imageSize.height += increase;
                }
                if (isTitleLabelShowing) {
                    titleSize.height += increase;
                }
                if (self.imagePosition == QQButtonImagePositionTop) {
                    titleLabelY = imageSize.height + spacingBetweenImageAndTitle;
                } else if (self.imagePosition == QQButtonImagePositionBottom) {
                    imageViewY = titleSize.height + spacingBetweenImageAndTitle;
                }
            } else if (self.imagePosition == QQButtonImagePositionLeft || self.imagePosition == QQButtonImagePositionRight) {
                if (isImageViewShowing) {
                    imageSize.height = CGRectGetHeight(self.bounds);
                    imageViewY = 0;
                }
                if (isTitleLabelShowing) {
                    titleSize.height = CGRectGetHeight(self.bounds);
                    titleLabelY = 0;
                }
            }
        } break;
        default:
            break;
    }
    
    imageViewX += (self.imageEdgeInsets.left - self.imageEdgeInsets.right) / 2 + contentOffset.x + imageOffset.x;
    imageViewY += (self.imageEdgeInsets.top - self.imageEdgeInsets.bottom) / 2 + contentOffset.y + imageOffset.y;
    titleLabelX += (self.titleEdgeInsets.left - self.titleEdgeInsets.right) / 2 + contentOffset.x + titleOffset.x;
    titleLabelY += (self.titleEdgeInsets.top - self.titleEdgeInsets.bottom) / 2 + contentOffset.y + titleOffset.y;
    
    self._qq_imageView.frame = CGRectMake(imageViewX, imageViewY, imageSize.width, imageSize.height);
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleSize.width, titleSize.height);
    
    
    if (self.imagePosition == QQButtonImagePositionTop || self.imagePosition == QQButtonImagePositionBottom) {
        
    } else if (self.imagePosition == QQButtonImagePositionLeft|| self.imagePosition == QQButtonImagePositionRight) {
        
    }
    
}

/**
 * iOS7以后的button，系统sizeToFit后默认会自带一个上下的contentInsets，此方法计算则是 按钮大小即为内容大小。
 */
- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize resultSize = CGSizeZero;
    
    BOOL isImageViewShowing = self.currentImage;
    BOOL isTitleLabelShowing = self.currentTitle || self.currentAttributedTitle;
    CGFloat spacingBetweenImageAndTitle = (isImageViewShowing && isTitleLabelShowing) ? self.spacingBetweenImageAndTitle : 0;
    
    CGSize imageSize = CGSizeZero;
    CGSize titleSize = CGSizeZero;
    if (isImageViewShowing) {
        imageSize = self.currentImage.size;
    }
    if (isTitleLabelShowing) {
        titleSize = [self titleSizeWithLimitSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    }
    if (self.imagePosition == QQButtonImagePositionTop || self.imagePosition == QQButtonImagePositionBottom) {
        resultSize.width = MAX(imageSize.width, titleSize.width);
        resultSize.height = imageSize.height + titleSize.height + spacingBetweenImageAndTitle;
    } else if (self.imagePosition == QQButtonImagePositionLeft || self.imagePosition == QQButtonImagePositionRight) {
        resultSize.width = imageSize.width + titleSize.width + spacingBetweenImageAndTitle;
        resultSize.height = MAX(imageSize.height, titleSize.height);
    }
    resultSize.width += (self.contentEdgeInsets.left + self.contentEdgeInsets.right);
    resultSize.height += (self.contentEdgeInsets.top + self.contentEdgeInsets.bottom);
    
    return resultSize;
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted && !self.originBorderColor) {
        // 手指按在按钮上会不断触发setHighlighted:，所以这里做了保护，设置过一次就不用再设置了
        self.originBorderColor = [UIColor colorWithCGColor:self.layer.borderColor];
    }
    
    // 渲染背景色
    if (self.highlightedBackgroundColor || self.highlightedBorderColor) {
        if (self.highlightedBackgroundColor) {
            if (!self.highlightedBackgroundLayer) {
                self.highlightedBackgroundLayer = [CALayer layer];
                [self.layer insertSublayer:self.highlightedBackgroundLayer atIndex:0];
            }
            self.highlightedBackgroundLayer.frame = self.bounds;
            self.highlightedBackgroundLayer.cornerRadius = self.layer.cornerRadius;
            self.highlightedBackgroundLayer.backgroundColor = self.highlighted ? self.highlightedBackgroundColor.CGColor : [UIColor clearColor].CGColor;
        }
        
        if (self.highlightedBorderColor) {
            self.layer.borderColor = self.highlighted ? self.highlightedBorderColor.CGColor : self.originBorderColor.CGColor;
        }
    }
    
    // 如果此时是disabled，则disabled的样式优先
    if (!self.enabled) {
        return;
    }
    
    // 自定义highlighted样式
    if (self.adjustsButtonWhenHighlighted) {
        if (highlighted) {
            self.alpha = 0.5;
        } else {
            self.alpha = 1;
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (!enabled && self.adjustsButtonWhenDisabled) {
        self.alpha = 0.5;
    } else {
        self.alpha = 1;
    }
}

- (void)setSpacingBetweenImageAndTitle:(CGFloat)spacingBetweenImageAndTitle {
    _spacingBetweenImageAndTitle = spacingBetweenImageAndTitle;
    [self setNeedsLayout];
}

- (void)setImagePosition:(QQButtonImagePosition)imagePosition {
    _imagePosition = imagePosition;
    [self setNeedsLayout];
}

- (CGSize)titleSizeWithLimitSize:(CGSize)limitSize {
    return [self.titleLabel sizeThatFits:limitSize];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    CGRect bounds = CGRectMake(self.bounds.origin.x - _outsideEdgeInsets.left, self.bounds.origin.y - _outsideEdgeInsets.top, self.bounds.size.width + _outsideEdgeInsets.left + _outsideEdgeInsets.right, self.bounds.size.height + _outsideEdgeInsets.top + _outsideEdgeInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}

@end
