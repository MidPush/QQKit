//
//  UIScrollView+QQExtension.h
//  QQKitDemo
//
//  Created by xuze on 2021/4/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (QQExtension)

/// UIScrollView 的真正 inset，在 iOS11 以后需要用到 adjustedContentInset 而在 iOS11 以前只需要用 contentInset
@property (nonatomic, assign, readonly) UIEdgeInsets qq_contentInset;

/// 判断当前的scrollView内容是否足够滚动，注意别和 scrollEnabled 混淆
- (BOOL)qq_canScroll;

/// 滚动到最顶部
- (void)qq_scrollToTop;
- (void)qq_scrollToTopAnimated:(BOOL)animated;

/// 滚动到最底部
- (void)qq_scrollToBottom;
- (void)qq_scrollToBottomAnimated:(BOOL)animated;

/// 滚动到最左边
- (void)qq_scrollToLeft;
- (void)qq_scrollToLeftAnimated:(BOOL)animated;

/// 滚动到最右边
- (void)qq_scrollToRight;
- (void)qq_scrollToRightAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
