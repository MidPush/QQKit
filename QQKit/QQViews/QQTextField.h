//
//  QQTextField.h
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import <UIKit/UIKit.h>

@interface QQTextField : UITextField

/// placeholder 颜色
@property (nonatomic, strong) UIColor *placeholderColor;

/// 允许输入最大文字长度，默认为 NSUIntegerMax
@property (nonatomic, assign) IBInspectable NSUInteger maximumTextLength;

/// 文字在输入框内的 padding
@property (nonatomic, assign) UIEdgeInsets textInsets;

/// placeholder在输入框内的 padding
@property (nonatomic, assign) UIEdgeInsets placeholderInsets;

@end

