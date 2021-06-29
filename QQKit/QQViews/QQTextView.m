//
//  QQTextView.m
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import "QQTextView.h"
#import "NSString+QQExtension.h"
#import "QQUIConfiguration.h"

/// 系统 textView 默认的字号大小，用于 placeholder 默认的文字大小。实测得到，请勿修改。
const CGFloat kSystemTextViewDefaultFontPointSize = 12.0f;

/// 当系统的 textView.textContainerInset 为 UIEdgeInsetsZero 时，文字与 textView 边缘的间距。实测得到，请勿修改（在输入框font大于13时准确，小于等于12时，y有-1px的偏差）。
const UIEdgeInsets kSystemTextViewFixTextInsets = {0, 5, 0, 5};

@interface QQTextView ()

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation QQTextView

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
    
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.hidden = YES;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.font = [UIFont systemFontOfSize:kSystemTextViewDefaultFontPointSize];
    [self addSubview:self.placeholderLabel];
    
    self.textColor = [QQUIConfiguration sharedInstance].textFieldTextColor;
    self.placeholderColor = [QQUIConfiguration sharedInstance].textFieldPlaceholderColor;
    self.tintColor = [QQUIConfiguration sharedInstance].textFieldTintColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters

- (void)setText:(NSString *)text {
    [super setText:text];
    [self handleTextChanged:self];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self handleTextChanged:self];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self updatePlaceholderLabel];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self updatePlaceholderLabel];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    if (@available(iOS 11, *)) {
    } else {
        // iOS 11 以下修改 textContainerInset 的时候无法自动触发 layoutSubview，导致 placeholderLabel 无法更新布局
        [self setNeedsLayout];
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    [self updatePlaceholderLabel];
    [self updatePlaceholderLabelHidden];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
    _attributedPlaceholder = attributedPlaceholder;
    [self updatePlaceholderLabel];
    [self updatePlaceholderLabelHidden];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    _placeholderLabel.textColor = placeholderColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.placeholder.length > 0 || self.attributedPlaceholder.length > 0) {
        UIEdgeInsets labelMargins = UIEdgeInsetsMake(self.textContainerInset.top + kSystemTextViewFixTextInsets.top, self.textContainerInset.left + kSystemTextViewFixTextInsets.left, self.textContainerInset.bottom + kSystemTextViewFixTextInsets.bottom, self.textContainerInset.right + kSystemTextViewFixTextInsets.right);
        CGFloat limitWidth = CGRectGetWidth(self.bounds) - (self.contentInset.left + self.contentInset.right) - (labelMargins.left + labelMargins.right);
        CGFloat limitHeight = CGRectGetHeight(self.bounds) - (self.contentInset.top + self.contentInset.bottom) - (labelMargins.top + labelMargins.bottom);
        CGSize labelSize = [self.placeholderLabel.attributedText boundingRectWithSize:CGSizeMake(limitWidth, limitHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.placeholderLabel.frame = CGRectMake(labelMargins.left, labelMargins.top, limitWidth, labelSize.height);
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self updatePlaceholderLabelHidden];
}

- (void)updatePlaceholderLabel {
    if (_attributedPlaceholder.length > 0) {
        self.placeholderLabel.attributedText = _attributedPlaceholder;
    } else if (_placeholder.length > 0) {
        UIFont *font = self.font ? self.font : [UIFont systemFontOfSize:kSystemTextViewDefaultFontPointSize];
        self.placeholderLabel.attributedText = [[NSAttributedString alloc] initWithString:_placeholder attributes:@{NSFontAttributeName:font}];
    }
    self.placeholderLabel.textAlignment = self.textAlignment;
    [self sendSubviewToBack:self.placeholderLabel];
    [self setNeedsLayout];
}

- (void)updatePlaceholderLabelHidden {
    if (self.placeholder.length == 0 && self.attributedPlaceholder.length == 0) return;
    if (self.text.length == 0 && (self.placeholder.length > 0 || self.attributedPlaceholder.length > 0)) {
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)handleTextChanged:(id)sender {
    [self updatePlaceholderLabelHidden];
    
    QQTextView *textView = nil;
    if ([sender isKindOfClass:[NSNotification class]]) {
        id object = ((NSNotification *)sender).object;
        if (object == self) {
            textView = (QQTextView *)object;
        }
    } else if ([sender isKindOfClass:[QQTextView class]]) {
        textView = (QQTextView *)sender;
    }
    
    if (textView) {
        if (!textView.editable) {
            return;// 不可编辑的 textView 不会显示光标
        }
        if (!textView.markedTextRange) {
            if (textView.text.length > textView.maximumTextLength) {
                textView.text = [textView.text qq_substringAvoidBreakingEmojiWithRange:NSMakeRange(0, textView.maximumTextLength)];
                [self.undoManager removeAllActions]; // 达到最大字符数后清空所有 undoaction, 以免 undo 操作造成crash.
            }
        }
    }
}

@end
