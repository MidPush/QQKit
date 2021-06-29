//
//  QQCropToolBar.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQCropToolBar : UIView

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, assign) BOOL resetButtonEnabled;

@end

NS_ASSUME_NONNULL_END
