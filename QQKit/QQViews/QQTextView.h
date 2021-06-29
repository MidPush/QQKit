//
//  QQTextView.h
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import <UIKit/UIKit.h>

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

