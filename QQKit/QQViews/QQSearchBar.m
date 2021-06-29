//
//  QQSearchBar.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/15.
//

#import "QQSearchBar.h"
#import "QQButton.h"
#import "UIView+QQExtension.h"

const CGFloat kSpacingBetweenSearchIconAndField = 6;
const CGFloat kQQSearchBarMargin = 8;
@interface QQSearchBar ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *searchContainerView;
@property (nonatomic, strong) UIView *searchFieldBackgroundView;
@property (nonatomic, strong) UIImageView *searchIcon;
@property (nonatomic, strong) UIButton *searchBarButton;

@end

@implementation QQSearchBar

- (UIButton *)searchBarButton {
    if (!_searchBarButton) {
        _searchBarButton = [[UIButton alloc] init];
        _searchBarButton.backgroundColor = [UIColor clearColor];
    }
    return _searchBarButton;;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    _textFieldMargins = UIEdgeInsetsZero;
    _placeholderAlignment = QQPlaceholderAlignmentLeft;
    _textFieldRadius = -1;
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    _searchContainerView = [[UIView alloc] init];
    [self addSubview:_searchContainerView];
    
    _searchFieldBackgroundView = [[UIView alloc] init];
    _searchFieldBackgroundView.layer.masksToBounds = YES;
    _searchFieldBackgroundView.backgroundColor = [UIColor colorWithRed:238/255.0 green:237/255.0 blue:239/255.0 alpha:1.0];
    [_searchContainerView addSubview:_searchFieldBackgroundView];
    
    NSBundle *bundle = [NSBundle bundleForClass:[QQSearchBar class]];
    NSURL *url = [bundle URLForResource:@"QQUIKit" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    UIImage *searchImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"SearchIcon" ofType:@"png"]];

    _searchIcon = [[UIImageView alloc] initWithImage:searchImage];
    [_searchFieldBackgroundView addSubview:_searchIcon];
    
    _searchTextField = [[QQTextField alloc] init];
    _searchTextField.delegate = self;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.enablesReturnKeyAutomatically = YES;
    _searchTextField.textAlignment = NSTextAlignmentLeft;
    [_searchTextField addTarget:self action:@selector(searchTextFieldChange:) forControlEvents:UIControlEventEditingChanged];
    [_searchFieldBackgroundView addSubview:_searchTextField];
    
    _cancelButton = [QQButton buttonWithType:UIButtonTypeSystem];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(onCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_searchContainerView addSubview:_cancelButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeSubviews];
    [self updateTextFieldRadius];
    [self updatePlaceholderAlignment];
}

- (void)updateTextFieldRadius {
    if (_textFieldRadius < 0) {
        _searchFieldBackgroundView.layer.cornerRadius = _searchFieldBackgroundView.qq_height / 2;
    } else {
        _searchFieldBackgroundView.layer.cornerRadius = _textFieldRadius;
    }
}

- (void)updatePlaceholderAlignment {
    // 这里没有去计算 NSTextAlignmentRight 的情况，一般也用不到
    CGSize searchIconSize = self.searchIcon.frame.size;
    
    if (_placeholderAlignment == QQPlaceholderAlignmentLeft || self.searchTextField.isEditing || self.searchTextField.hasText) {
        _searchIcon.frame =  CGRectMake(kQQSearchBarMargin, (_searchFieldBackgroundView.qq_height - searchIconSize.height) / 2, searchIconSize.width, searchIconSize.height);
        self.searchTextField.placeholderInsets = UIEdgeInsetsZero;
    } else if (_placeholderAlignment == QQPlaceholderAlignmentCenter) {
        CGSize placeholderSize = [self.placeholder boundingRectWithSize:self.searchTextField.frame.size options:0 attributes:@{NSFontAttributeName:self.searchTextField.font} context:nil].size;
        CGFloat totalWidth = searchIconSize.width + placeholderSize.width + kSpacingBetweenSearchIconAndField;
        CGFloat searchIconX = (self.searchFieldBackgroundView.qq_width - totalWidth) / 2;
        CGFloat placeholderOffset = searchIconX - kQQSearchBarMargin;
        _searchIcon.frame = CGRectMake(searchIconX, (_searchFieldBackgroundView.qq_height - searchIconSize.height) / 2, searchIconSize.width, searchIconSize.height);
        self.searchTextField.placeholderInsets = UIEdgeInsetsMake(0, placeholderOffset, 0, 0);
    }
    [self.searchTextField setNeedsLayout];
}

- (void)resizeSubviews {
    
    _searchContainerView.frame = self.bounds;
    CGSize boundsSize = self.frame.size;
    [_cancelButton sizeToFit];
    
    CGFloat searchFieldBackgroundViewX = self.textFieldMargins.left + self.qq_safeAreaInsets.left;
    CGFloat searchFieldBackgroundViewY = self.textFieldMargins.top;
    CGFloat searchFieldBackgroundViewWidth = boundsSize.width - (self.textFieldMargins.left + self.textFieldMargins.right + self.qq_safeAreaInsets.left + self.qq_safeAreaInsets.right);
    CGFloat searchFieldBackgroundViewHeight = boundsSize.height - (self.textFieldMargins.top + self.textFieldMargins.bottom);
    
    if (_showsLeftAccessoryView && _leftAccessoryView) {
        searchFieldBackgroundViewX += (self.leftAccessoryView.qq_width + kQQSearchBarMargin);
        searchFieldBackgroundViewWidth -= (self.leftAccessoryView.qq_width + kQQSearchBarMargin);
        
        _leftAccessoryView.frame = CGRectMake(self.textFieldMargins.left + self.qq_safeAreaInsets.left, (boundsSize.height - self.leftAccessoryView.qq_height) / 2, self.leftAccessoryView.qq_width, self.leftAccessoryView.qq_height);
    } else {
        _leftAccessoryView.frame = CGRectMake(-self.leftAccessoryView.qq_width, (boundsSize.height - self.leftAccessoryView.qq_height) / 2, self.leftAccessoryView.qq_width, self.leftAccessoryView.qq_height);
    }
    
    if (_showsCancelButton) {
        searchFieldBackgroundViewWidth -= (self.cancelButton.qq_width + kQQSearchBarMargin);
        _cancelButton.frame = CGRectMake(boundsSize.width - _cancelButton.qq_width - self.qq_safeAreaInsets.right, 0, _cancelButton.qq_width, boundsSize.height);
    } else {
        _cancelButton.frame = CGRectMake(boundsSize.width, 0, _cancelButton.qq_width, boundsSize.height);
    }
    
    if (_showsRightAccessoryView && _rightAccessoryView) {
        searchFieldBackgroundViewWidth -= (self.rightAccessoryView.qq_width + kQQSearchBarMargin);
        _rightAccessoryView.frame = CGRectMake(searchFieldBackgroundViewX + searchFieldBackgroundViewWidth + kQQSearchBarMargin, (boundsSize.height - self.rightAccessoryView.qq_height) / 2, self.rightAccessoryView.qq_width, self.rightAccessoryView.qq_height);
    } else {
        self.rightAccessoryView.frame = CGRectMake(boundsSize.width, (boundsSize.height - self.rightAccessoryView.qq_height) / 2, self.rightAccessoryView.qq_width, self.rightAccessoryView.qq_height);
    }
    
    _searchFieldBackgroundView.frame = CGRectMake(searchFieldBackgroundViewX, searchFieldBackgroundViewY, searchFieldBackgroundViewWidth, searchFieldBackgroundViewHeight);
    
    CGSize searchIconSize = self.searchIcon.frame.size;
    _searchIcon.frame = CGRectMake(kQQSearchBarMargin, (_searchFieldBackgroundView.qq_height - searchIconSize.height) / 2, searchIconSize.width, searchIconSize.height);
    
    CGFloat textFieldX = self.searchIcon.qq_right + kSpacingBetweenSearchIconAndField;
    CGFloat textFieldY = 0;
    CGFloat textFieldW = _searchFieldBackgroundView.qq_width - textFieldX - kSpacingBetweenSearchIconAndField;
    CGFloat textFieldH = _searchFieldBackgroundView.qq_height;
    self.searchTextField.frame = CGRectMake(textFieldX, textFieldY, textFieldW, textFieldH);
    
    if (_searchBarButton) {
        _searchBarButton.frame = _searchFieldBackgroundView.bounds;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
    [self updatePlaceholderAlignment];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        return [self.delegate searchBarShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [self.delegate searchBarTextDidEndEditing:self];
    }
    [self updatePlaceholderAlignment];
}

- (void)searchTextFieldChange:(UITextField *)textField {
    _text = textField.text;
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [self.delegate searchBarSearchButtonClicked:self];
    }
    return YES;
}

- (void)onCancelButtonClicked {
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

- (void)setText:(NSString *)text {
    _text = text;
    _searchTextField.text = text;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _searchTextField.placeholder = placeholder;
    [self updatePlaceholderAlignment];
}

- (void)setPlaceholderAlignment:(QQPlaceholderAlignment)placeholderAlignment {
    _placeholderAlignment = placeholderAlignment;
    [self updatePlaceholderAlignment];
}

- (void)setTextFieldBackgroundColor:(UIColor *)textFieldBackgroundColor {
    _textFieldBackgroundColor = textFieldBackgroundColor;
    _searchFieldBackgroundView.backgroundColor = textFieldBackgroundColor;
}

- (void)setSearchImage:(UIImage *)searchImage {
    _searchImage = searchImage;
    self.searchIcon.image = searchImage;
    [self resizeSubviews];
    [self updatePlaceholderAlignment];
}

- (void)setTextFieldRadius:(CGFloat)textFieldRadius {
    _textFieldRadius = textFieldRadius;
    [self updateTextFieldRadius];
}

- (void)setTextFieldMargins:(UIEdgeInsets)textFieldMargins {
    _textFieldMargins = textFieldMargins;
    [self resizeSubviews];
    [self updatePlaceholderAlignment];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated {
    if (_showsCancelButton == showsCancelButton) return;
    [self resizeSubviews];
    _showsCancelButton = showsCancelButton;
    if (showsCancelButton) {
        if (animated) {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self resizeSubviews];
            } completion:^(BOOL finished) {
                
            }];
        } else {
            [self resizeSubviews];
        }
    } else {
        if (animated) {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self resizeSubviews];
            } completion:^(BOOL finished) {
                
            }];
        } else {
            [self resizeSubviews];
        }
    }
    [self updatePlaceholderAlignment];
}

- (void)setShowsLeftAccessoryView:(BOOL)showsLeftAccessoryView animated:(BOOL)animated {
    if (_showsLeftAccessoryView == showsLeftAccessoryView || !_leftAccessoryView) return;
    [self.searchContainerView insertSubview:_leftAccessoryView atIndex:0];
    [self resizeSubviews];
    _showsLeftAccessoryView = showsLeftAccessoryView;
    if (showsLeftAccessoryView) {
        if (animated) {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self resizeSubviews];
            } completion:^(BOOL finished) {
                
            }];
        } else {
            [self resizeSubviews];
        }
    } else {
        if (animated) {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self resizeSubviews];
            } completion:^(BOOL finished) {
                
            }];
        } else {
            [self resizeSubviews];
        }
    }
    [self updatePlaceholderAlignment];
}
- (void)setShowsRightAccessoryView:(BOOL)showsRightAccessoryView animated:(BOOL)animated {
    if (_showsRightAccessoryView == showsRightAccessoryView || !_rightAccessoryView) return;
    [self.searchContainerView insertSubview:_rightAccessoryView atIndex:0];
    [self resizeSubviews];
    _showsRightAccessoryView = showsRightAccessoryView;
    if (showsRightAccessoryView) {
        if (animated) {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self resizeSubviews];
            } completion:^(BOOL finished) {
                
            }];
        } else {
            [self resizeSubviews];
        }
    } else {
        if (animated) {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self resizeSubviews];
            } completion:^(BOOL finished) {
                
            }];
        } else {
            [self resizeSubviews];
        }
    }
    [self updatePlaceholderAlignment];
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    self.searchBarButton.frame = self.searchFieldBackgroundView.bounds;
    if (!self.searchBarButton.superview) {
        [self.searchFieldBackgroundView addSubview:self.searchBarButton];
    }
    [self.searchBarButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (_searchBarButton) {
        [_searchBarButton removeTarget:target action:action forControlEvents:controlEvents];
        [_searchBarButton removeFromSuperview];
        _searchBarButton = nil;
    }
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    return [self.searchTextField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    return [self.searchTextField resignFirstResponder];
}


@end
