//
//  QQTextField.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "QQTextField.h"
#import "NSString+QQExtension.h"
#import "QQUIConfiguration.h"

@implementation QQTextField

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
    self.maximumTextLength = NSUIntegerMax;
    self.textInsets = UIEdgeInsetsZero;
    [self addTarget:self action:@selector(handleTextChangeEvent:) forControlEvents:UIControlEventEditingChanged];
    
    self.textColor = [QQUIConfiguration sharedInstance].textFieldTextColor;
    self.placeholderColor = [QQUIConfiguration sharedInstance].textFieldPlaceholderColor;
    self.tintColor = [QQUIConfiguration sharedInstance].textFieldTintColor;
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    [self updateAttributedPlaceholderIfNeeded];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    // 当通过`setText:`方式修改文字时，handleTextChangeEvent不会触发，需手动调用
    [self handleTextChangeEvent:self];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    // 当通过`setAttributedText:`方式修改文字时，handleTextChangeEvent不会触发，需手动调用
    [self handleTextChangeEvent:self];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [self updateAttributedPlaceholderIfNeeded];
}

- (void)updateAttributedPlaceholderIfNeeded {
    if (!self.placeholderColor) return;
    NSString *placeholder = self.placeholder;
    if (placeholder.length == 0) {
        placeholder = @" ";
    }
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:self.placeholderColor}];
}

- (void)handleTextChangeEvent:(QQTextField *)textField {
    if (!textField.markedTextRange) {
        if (textField.text.length > textField.maximumTextLength) {
            textField.text = [textField.text qq_substringAvoidBreakingEmojiWithRange:NSMakeRange(0, textField.maximumTextLength)];
            [self.undoManager removeAllActions]; // 达到最大字符数后清空所有 undoaction, 以免 undo 操作造成crash.
        }
    }
}

#pragma mark - Overrides

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.textInsets);
    return [super textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.textInsets);
    return [super editingRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.placeholderInsets);
    return [super placeholderRectForBounds:bounds];
}

@end
