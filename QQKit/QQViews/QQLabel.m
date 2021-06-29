//
//  QQLabel.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "QQLabel.h"

@implementation QQLabel

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    _contentEdgeInsets = contentEdgeInsets;
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
    UIEdgeInsets contentEdgeInsets = UIEdgeInsetsZero;
    if (self.text.length > 0 || self.attributedText.length > 0) {
        contentEdgeInsets = self.contentEdgeInsets;
    }
    size = [super sizeThatFits:CGSizeMake(size.width - (contentEdgeInsets.left + contentEdgeInsets.right), size.height - (contentEdgeInsets.top + contentEdgeInsets.bottom))];
    size.width += (contentEdgeInsets.left + contentEdgeInsets.right);
    size.height += (contentEdgeInsets.top + contentEdgeInsets.bottom);
    return size;
}

- (CGSize)intrinsicContentSize {
    CGFloat preferredMaxLayoutWidth = self.preferredMaxLayoutWidth;
    if (preferredMaxLayoutWidth <= 0) {
        preferredMaxLayoutWidth = CGFLOAT_MAX;
    }
    return [self sizeThatFits:CGSizeMake(preferredMaxLayoutWidth, CGFLOAT_MAX)];
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets contentEdgeInsets = UIEdgeInsetsZero;
    if (self.text.length > 0 || self.attributedText.length > 0) {
        contentEdgeInsets = self.contentEdgeInsets;
    }
    rect = UIEdgeInsetsInsetRect(rect, contentEdgeInsets);
    
    // 在某些情况下文字位置错误，因此做了如下保护
    if (self.numberOfLines == 1 && (self.lineBreakMode == NSLineBreakByWordWrapping || self.lineBreakMode == NSLineBreakByCharWrapping)) {
        rect.size.height = CGRectGetHeight(rect) + contentEdgeInsets.top * 2;
    }
    [super drawTextInRect:rect];
}


@end
