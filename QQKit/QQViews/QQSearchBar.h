//
//  QQSearchBar.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import <UIKit/UIKit.h>
#import "QQTextField.h"

/**
 系统 UISearchBar 暴露的接口太少，很难灵活的修改样式。
 直到 iOS 13，才开放 searchTextField，之前都是通过 KVC 拿到 searchTextField。
 QQSearchBar 属性和方法大部分和 UISearchBar 相同。
 */
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QQPlaceholderAlignment) {
    QQPlaceholderAlignmentLeft,
    QQPlaceholderAlignmentCenter
};

@class QQSearchBar;
@protocol QQSearchBarDelegate <NSObject>

@optional
- (BOOL)searchBarShouldBeginEditing:(QQSearchBar *)searchBar;

- (void)searchBarTextDidBeginEditing:(QQSearchBar *)searchBar;

- (BOOL)searchBarShouldEndEditing:(QQSearchBar *)searchBar;

- (void)searchBarTextDidEndEditing:(QQSearchBar *)searchBar;

- (void)searchBar:(QQSearchBar *)searchBar textDidChange:(NSString *)searchText;

- (BOOL)searchBar:(QQSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)searchBarSearchButtonClicked:(QQSearchBar *)searchBar;

- (void)searchBarCancelButtonClicked:(QQSearchBar *)searchBar;

@end

@interface QQSearchBar : UIView

/// 代理
@property (nonatomic, weak, nullable) id<QQSearchBarDelegate> delegate;

/// 设置默认文字
@property (nonatomic, copy, nullable) NSString *text;

/// 设置 placeholder，默认为nil
@property (nonatomic, copy, nullable) NSString *placeholder;

/// 设置 placeholder 居中居左
@property (nonatomic, assign) QQPlaceholderAlignment placeholderAlignment;

/// 设置 searchTextField 背景颜色
@property (nonatomic, strong, nullable) UIColor *textFieldBackgroundColor;

/// 设置搜索图标
@property (nonatomic, strong, nullable) UIImage *searchImage;

/// 设置圆角，默认为高度的一半，设置小于0，则为高度的一半
@property (nonatomic, assign) CGFloat textFieldRadius;

/// searchTextField 距离 SearchBar 边距，默认 {2, 0, 2, 0}
@property (nonatomic, assign) UIEdgeInsets textFieldMargins;

/// 搜索 TextField
@property (nonatomic, strong, readonly) QQTextField *searchTextField;

/// 取消按钮，QQSearchBar初始化就创建了
@property (nonatomic, strong) UIButton *cancelButton;

/// 左边 AccessoryView，默认为 nil
@property (nonatomic, strong, nullable) UIView *leftAccessoryView;

/// 右边 AccessoryView，默认为 nil
@property (nonatomic, strong, nullable) UIView *rightAccessoryView;

/// 显示或隐藏取消按钮，默认不显示 NO
@property (nonatomic, assign) BOOL showsCancelButton;

/// 显示或隐藏 LeftAccessoryView，默认不显示 NO
@property (nonatomic, assign) BOOL showsLeftAccessoryView;

/// 显示或隐藏 RightAccessoryView，默认不显示 NO
@property (nonatomic, assign) BOOL showsRightAccessoryView;

/// 以动画形式显示或隐藏取消按钮
- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated;

/// 以动画形式显示或隐藏 LeftAccessoryView
- (void)setShowsLeftAccessoryView:(BOOL)showsLeftAccessoryView animated:(BOOL)animated;

/// 以动画形式显示或隐藏 RightAccessoryView
- (void)setShowsRightAccessoryView:(BOOL)showsRightAccessoryView animated:(BOOL)animated;

/// 把 QQSearchBar 当作按钮展示，内部会创建一个 UIButton 响应事件
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/// 把 QQSearchBar 还原成正常搜索功能使用 ，移除UIButton 响应事件
- (void)removeTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
