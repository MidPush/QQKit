//
//  QQTextView.h
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import <UIKit/UIKit.h>

/**
 如果 TextView 是第一个添加到控制器的 view 上，iOS11之前需要设置控制器的 automaticallyAdjustsScrollViewInsets 为 NO，
 否则会自动偏移导航栏高度的距离，因为 UITextView 是继承自 UIScrollView
 */
@interface QQTextView : UITextView

/// placeholder
@property (nonatomic, copy) NSString *placeholder;
 
/// attributedPlaceholder
@property (nonatomic, copy) NSAttributedString *attributedPlaceholder;

/// placeholder 颜色
@property (nonatomic, strong) UIColor *placeholderColor;

/// 允许输入最大文字长度，默认为 NSUIntegerMax
@property (nonatomic, assign) IBInspectable NSUInteger maximumTextLength;

@end

