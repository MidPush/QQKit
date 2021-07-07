//
//  DMViewBorderViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/7/5.
//

#import "DMViewBorderViewController.h"
#import "CALayer+QQExtension.h"

@interface DMViewBorderViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *locationTitleLabel;
@property (nonatomic, strong) UISegmentedControl *locationSegmentedControl;

@property (nonatomic, strong) UILabel *positionTitleLabel;
@property (nonatomic, strong) QQButton *positionTopButton;
@property (nonatomic, strong) QQButton *positionLeftButton;
@property (nonatomic, strong) QQButton *positionBottomButton;
@property (nonatomic, strong) QQButton *positionRightButton;

@property (nonatomic, strong) UILabel *borderWidthTitleLabel;
@property (nonatomic, strong) QQTextField *borderWidthTextField;

@property (nonatomic, strong) UILabel *borderColorTitleLabel;
@property (nonatomic, strong) QQButton *randomColorButton;

@property (nonatomic, strong) UILabel *radiusTitleLabel;
@property (nonatomic, strong) QQTextField *radiusTextField;

@property (nonatomic, strong) UILabel *maskedCornersTitleLabel;
@property (nonatomic, strong) QQButton *leftTopButton;
@property (nonatomic, strong) QQButton *rightTopButton;
@property (nonatomic, strong) QQButton *leftBottomButton;
@property (nonatomic, strong) QQButton *rightBottomButton;

@property (nonatomic, strong) UIColor *borderColor;

@end

@implementation DMViewBorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateTargetView];
}

- (void)updateTargetView {
    
    // BorderPosition
    QQViewBorderPosition position = QQViewBorderPositionNone;
    if (self.positionTopButton.selected) {
        position |= QQViewBorderPositionTop;
    }
    if (self.positionLeftButton.selected) {
        position |= QQViewBorderPositionLeft;
    }
    if (self.positionBottomButton.selected) {
        position |= QQViewBorderPositionBottom;
    }
    if (self.positionRightButton.selected) {
        position |= QQViewBorderPositionRight;
    }
    self.targetView.qq_borderPosition = position;
    self.targetView.qq_borderColor = self.borderColor;
    self.targetView.qq_borderWidth = [self.borderWidthTextField.text floatValue];
    self.targetView.qq_borderLocation = self.locationSegmentedControl.selectedSegmentIndex;

//    // MaskedCorners
    QQCornerMask cornerMask = 0;
    if (self.leftTopButton.isSelected) {
        cornerMask |= QQLayerMinXMinYCorner;
    }
    if (self.rightTopButton.isSelected) {
        cornerMask |= QQLayerMaxXMinYCorner;
    }
    if (self.leftBottomButton.isSelected) {
        cornerMask |= QQLayerMinXMaxYCorner;
    }
    if (self.rightBottomButton.isSelected) {
        cornerMask |= QQLayerMaxXMaxYCorner;
    }
    if (cornerMask == 0) {
        // 默认值
        cornerMask = QQLayerAllCorner;
    }
    self.targetView.layer.qq_maskedCorners = cornerMask;
}

- (void)initSubviews {
    
    self.view.qq_startColor = [UIColor qq_colorWithHexString:@"#FF753D"];
    self.view.qq_endColor = [UIColor qq_colorWithHexString:@"#FF1414"];
    
    _targetView = [[UIView alloc] initWithFrame:CGRectMake((self.view.qq_width - 100) / 2, QQUIHelper.navigationBarMaxY + 30, 100, 100)];
    _targetView.backgroundColor = [UIColor dm_blackColor];
    [self.view addSubview:_targetView];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.qq_borderPosition = QQViewBorderPositionTop;
    _scrollView.qq_borderColor = UIColor.dm_separatorColor;
    _scrollView.qq_borderWidth = QQUIHelper.pixelOne;
    [self.view addSubview:_scrollView];
    
    _locationTitleLabel = [self createTitleLabel:@"qq_borderLocation"];
    _locationSegmentedControl = [self createSegmentedControl:@[@"Inside", @"Center", @"Outside"]];
    
    _positionTitleLabel = [self createTitleLabel:@"qq_borderPosition"];
    _positionTopButton = [self createSelectButton:@"Top"];
    _positionLeftButton = [self createSelectButton:@"Left"];
    _positionBottomButton = [self createSelectButton:@"Bottom"];
    _positionRightButton = [self createSelectButton:@"Right"];
    
    _borderWidthTitleLabel = [self createTitleLabel:@"qq_borderWidth"];
    _borderWidthTextField = [self createTextField];
    
    _borderColorTitleLabel = [self createTitleLabel:@"qq_borderColor"];
    _randomColorButton = [[QQFillButton alloc] initWithFillColor:UIColor.dm_tintColor titleTextColor:UIColor.dm_whiteTextColor];
    _randomColorButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_randomColorButton setTitle:@"随机色" forState:UIControlStateNormal];
    [_randomColorButton addTarget:self action:@selector(onRandomColorButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_randomColorButton];
    
    _radiusTitleLabel = [self createTitleLabel:@"qq_cornerRadius"];
    _radiusTextField = [self createTextField];
    
    _maskedCornersTitleLabel = [self createTitleLabel:@"qq_maskedCorners"];
    _leftTopButton = [self createSelectButton:@"MinXMinY"];
    _rightTopButton = [self createSelectButton:@"MaxXMinY"];
    _leftBottomButton = [self createSelectButton:@"MinXMaxY"];
    _rightBottomButton = [self createSelectButton:@"MaxXMaxY"];
    
    _locationSegmentedControl.selectedSegmentIndex = 0;
    _positionTopButton.selected = YES;
    _borderWidthTextField.text = [NSString stringWithFormat:@"%.1f", 2.0];
    _radiusTextField.text = @"0";
    _borderColor = UIColor.qq_randomColor;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _targetView.frame = CGRectMake((self.view.qq_width - 100) / 2, QQUIHelper.navigationBarMaxY + 30, 100, 100);
    
    _scrollView.frame = CGRectMake(0, _targetView.qq_bottom + 30, self.view.qq_width, self.view.qq_height - (_targetView.qq_bottom + 30));
    
    CGFloat marginLeft = 16;
    CGFloat lineHeight = 44;
    
    _locationTitleLabel.frame = CGRectMake(marginLeft, 0, _locationTitleLabel.qq_width, lineHeight);
    _locationSegmentedControl.frame = CGRectMake(self.view.qq_width - 180 - marginLeft, (lineHeight - 30) / 2, 180, 30);
    
    _positionTitleLabel.frame = CGRectMake(marginLeft, lineHeight, _positionTitleLabel.qq_width, lineHeight);
    _positionTopButton.frame = CGRectMake(0, _positionTitleLabel.qq_bottom, self.view.qq_width, lineHeight);
    _positionLeftButton.frame = CGRectMake(0, _positionTopButton.qq_bottom, self.view.qq_width, lineHeight);
    _positionBottomButton.frame = CGRectMake(0, _positionLeftButton.qq_bottom, self.view.qq_width, lineHeight);
    _positionRightButton.frame = CGRectMake(0, _positionBottomButton.qq_bottom, self.view.qq_width, lineHeight);
    
    _borderWidthTitleLabel.frame = CGRectMake(marginLeft, _positionRightButton.qq_bottom, _borderWidthTitleLabel.qq_width, lineHeight);
    _borderWidthTextField.frame = CGRectMake(self.view.qq_width - 60 - marginLeft, _borderWidthTitleLabel.qq_top + (lineHeight - 30) / 2, 60, 30);
    
    _borderColorTitleLabel.frame = CGRectMake(marginLeft, _borderWidthTitleLabel.qq_bottom, _borderColorTitleLabel.qq_width, lineHeight);
    _randomColorButton.frame = CGRectMake(self.view.qq_width - 60 - marginLeft, _borderColorTitleLabel.qq_top + (lineHeight - 30) / 2, 60, 30);
    
    _radiusTitleLabel.frame = CGRectMake(marginLeft, _borderColorTitleLabel.qq_bottom, _radiusTitleLabel.qq_width, lineHeight);
    _radiusTextField.frame = CGRectMake(self.view.qq_width - 60 - marginLeft, _radiusTitleLabel.qq_top + (lineHeight - 30) / 2, 60, 30);
    
    _maskedCornersTitleLabel.frame = CGRectMake(marginLeft, _radiusTitleLabel.qq_bottom, _maskedCornersTitleLabel.qq_width, lineHeight);
    _leftTopButton.frame = CGRectMake(0, _maskedCornersTitleLabel.qq_bottom, self.view.qq_width, lineHeight);
    _rightTopButton.frame = CGRectMake(0, _leftTopButton.qq_bottom, self.view.qq_width, lineHeight);
    _leftBottomButton.frame = CGRectMake(0, _rightTopButton.qq_bottom, self.view.qq_width, lineHeight);
    _rightBottomButton.frame = CGRectMake(0, _leftBottomButton.qq_bottom, self.view.qq_width, lineHeight);
    
    _scrollView.contentSize = CGSizeMake(self.view.qq_width, _rightBottomButton.qq_bottom + 30);
}

- (UILabel *)createTitleLabel:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = UIColor.dm_mainTextColor;
    titleLabel.text = title;
    [titleLabel sizeToFit];
    [self.scrollView addSubview:titleLabel];
    return titleLabel;
}

- (UISegmentedControl *)createSegmentedControl:(NSArray *)items {
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:items];
    control.tintColor = UIColor.dm_mainTextColor;
    control.frame = CGRectMake(0, 0, 240, 0);
    [control addTarget:self action:@selector(onSegmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:control];
    return control;
}

- (QQTextField *)createTextField {
    QQTextField *textField = [[QQTextField alloc] init];
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    textField.font = [UIFont systemFontOfSize:12];
    textField.textColor = UIColor.dm_tintColor;
    textField.layer.borderColor = UIColor.dm_blackColor.CGColor;
    textField.layer.borderWidth = 1.0;
    textField.textAlignment = NSTextAlignmentCenter;
    [textField addTarget:self action:@selector(handleTextFieldChangedEvent:) forControlEvents:UIControlEventEditingChanged];
    [self.scrollView addSubview:textField];
    return textField;
}

- (QQButton *)createSelectButton:(NSString *)title {
    QQButton *button = [[QQButton alloc] init];
    button.imagePosition = QQButtonImagePositionRight;
    button.spacingBetweenImageAndTitle = 10;
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.dm_mainGrayColor forState:UIControlStateNormal];
    UIImage *selectedImage = [UIImage imageNamed:@"check"];
    [button setImage:selectedImage forState:UIControlStateSelected];
    [button setImage:selectedImage forState:UIControlStateHighlighted | UIControlStateSelected];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.highlightedBackgroundColor = UIColor.dm_backgroundColor;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 40, 0, -40);
    [button addTarget:self action:@selector(onSelectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button];
    return button;
}

- (void)onSegmentedControlClicked:(UISegmentedControl *)control {
    [self updateTargetView];
}

- (void)onSelectButtonClicked:(QQButton *)button {
    button.selected = !button.selected;
    [self updateTargetView];
}

- (void)onRandomColorButtonClicked {
    self.targetView.qq_borderColor = UIColor.qq_randomColor;
}

- (void)handleTextFieldChangedEvent:(QQTextField *)textField {
    if (textField == self.radiusTextField) {
        self.targetView.layer.qq_cornerRadius = [textField.text floatValue];
    } else if (textField == self.borderWidthTextField) {
        self.targetView.qq_borderWidth = [textField.text floatValue];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
