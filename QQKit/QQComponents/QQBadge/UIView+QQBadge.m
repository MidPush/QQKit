//
//  UIView+QQBadge.m
//  JiXinMei
//
//  Created by Mac on 2021/3/3.
//

#import "UIView+QQBadge.h"
#import "UIColor+QQExtension.h"
#import <objc/runtime.h>

static const void * const kBadgeIntegerKey = &kBadgeIntegerKey;
static const void * const kBadgeStringKey = &kBadgeStringKey;
static const void * const kBadgeOffsetKey = &kBadgeOffsetKey;
static const void * const kBadgeLabelKey = &kBadgeLabelKey;

@implementation UIView (QQBadge)

- (void)setQq_badgeInteger:(NSUInteger)badge {
    objc_setAssociatedObject(self, kBadgeIntegerKey, @(badge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qq_badgeString = badge > 0 ? [NSString stringWithFormat:@"%@", @(badge)] : nil;
}

- (NSUInteger)qq_badgeInteger {
    return [((NSNumber *)objc_getAssociatedObject(self, kBadgeIntegerKey)) unsignedIntegerValue];
}

- (void)setQq_badgeString:(NSString *)badgeString {
    objc_setAssociatedObject(self, kBadgeStringKey, badgeString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (badgeString.length > 0) {
        if (!self.qq_badgeLabel) {
            self.qq_badgeLabel = [[UILabel alloc] init];
            self.qq_badgeLabel.clipsToBounds = YES;
            self.qq_badgeLabel.textAlignment = NSTextAlignmentCenter;
            self.qq_badgeLabel.backgroundColor = [UIColor qq_colorWithHexString:@"fb0000"];
            self.qq_badgeLabel.textColor = [UIColor qq_colorWithHexString:@"ffffff"];
            self.qq_badgeLabel.font = [UIFont systemFontOfSize:8];
            [self addSubview:self.qq_badgeLabel];
        }
        self.qq_badgeLabel.text = self.qq_badgeString;
        self.qq_badgeLabel.hidden = [self.qq_badgeString isEqualToString:@"0"];
        self.clipsToBounds = NO;
        
        [self layoutBadgeLabel];
    } else {
        self.qq_badgeLabel.hidden = YES;
    }
}

- (NSString *)qq_badgeString {
    return objc_getAssociatedObject(self, kBadgeStringKey);
}

- (void)setQq_badgeOffset:(CGPoint)badgeOffset {
    objc_setAssociatedObject(self, kBadgeOffsetKey, @(badgeOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self layoutBadgeLabel];
}

- (CGPoint)qq_badgeOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, kBadgeOffsetKey)) CGPointValue];
}

- (void)setQq_badgeLabel:(UILabel *)badgeLabel {
    objc_setAssociatedObject(self, kBadgeLabelKey, badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)qq_badgeLabel {
    return objc_getAssociatedObject(self, kBadgeLabelKey);
}

- (void)layoutBadgeLabel {
    if (!self.qq_badgeLabel) return;
    CGSize textSize = [self.qq_badgeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];CGSize badgeLabelSize = CGSizeMake(textSize.width + 10, textSize.height + 2);
    if (self.qq_badgeLabel.text.length == 1) {
        // 当只有一位数字时，会取宽/高中最大的值作为最终的宽高，以保证整个 badge 是正圆。
        CGFloat size = MAX(textSize.width + 2, textSize.height + 2);
        badgeLabelSize = CGSizeMake(size, size);
    }
    self.qq_badgeLabel.frame = CGRectMake(CGRectGetWidth(self.frame) + self.qq_badgeOffset.x, -badgeLabelSize.height + self.qq_badgeOffset.y, badgeLabelSize.width , badgeLabelSize.height);
    self.qq_badgeLabel.layer.cornerRadius = MIN(badgeLabelSize.width / 2, badgeLabelSize.height / 2);
    [self bringSubviewToFront:self.qq_badgeLabel];
}

- (void)qq_badgeSetNeedsLayout {
    [self layoutBadgeLabel];
}

@end
