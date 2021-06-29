//
//  QQSelectAssetToolBar.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "QQButton.h"

typedef NS_ENUM(NSInteger, ToolBarType) {
    ToolBarTypePreview,
    ToolBarTypeEdit,
};

@interface QQSelectAssetToolBar : UIView

- (instancetype)initWithToolBarType:(ToolBarType)toolBarType;
@property (nonatomic, assign, readonly) ToolBarType toolBarType;

@property (nonatomic, strong) QQButton *leftButton;
@property (nonatomic, strong) QQButton *originImageButton;
@property (nonatomic, strong) QQButton *doneButton;
@property (nonatomic, strong) UILabel *countLabel;



@end

