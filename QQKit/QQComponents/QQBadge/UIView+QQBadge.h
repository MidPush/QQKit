//
//  UIView+QQBadge.h
//  JiXinMei
//
//  Created by Mac on 2021/3/3.
//

#import <UIKit/UIKit.h>

@interface UIView (QQBadge)

/// 用数字设置badge，0表示不显示badge
@property (nonatomic, assign) NSUInteger qq_badgeInteger;

/// 用字符串设置badge，nil 表示不显示badge
@property (nonatomic, copy, nullable) NSString *qq_badgeString;

/// 默认 badge 的布局处于 view 右上角（x = view.width, y = -badge height），通过这个属性可以调整 badge 相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
@property (nonatomic, assign) CGPoint qq_badgeOffset;

/// badgeLabel
@property (nonatomic, strong, readonly, nullable) UILabel *qq_badgeLabel;

/// 强制需要更新 badge frame
- (void)qq_badgeSetNeedsLayout;

@end

