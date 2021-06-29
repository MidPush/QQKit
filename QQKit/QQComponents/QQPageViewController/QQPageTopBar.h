//
//  QQPageTopBar.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/12.
//

#import <UIKit/UIKit.h>

/// 如果不满足需要，自己添加属性
@interface QQTopBarAttributes : NSObject

// title
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *selectedTitleFont;

// indicator
@property (nonatomic, strong) UIColor * indicatorColor;
@property (nonatomic, assign) CGFloat   indicatorWidth;
@property (nonatomic, assign) CGFloat   indicatorHeight;
@property (nonatomic, assign) CGFloat   indicatorCornerRadius;
@property (nonatomic, assign) CGFloat   indicatorOffsetY;

// content
@property (nonatomic, assign) CGFloat topBarHeight;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) BOOL fixedItemWidth;
@property (nonatomic, assign) CGFloat itemSpace;

@end

@class QQPageTopBar;
@protocol QQPageTopBarDelegate <NSObject>

@optional
- (void)topBar:(QQPageTopBar *)topBar didSelectItemAtIndex:(NSUInteger)index;

@end

/**
 一个简单的PageTopBar
 */
@interface QQPageTopBar : UIView

@property (nonatomic, strong) QQTopBarAttributes *attributes;
@property (nonatomic, weak) id<QQPageTopBarDelegate> delegate;

@property (nonatomic, assign) NSInteger selectedIndex;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

@end

