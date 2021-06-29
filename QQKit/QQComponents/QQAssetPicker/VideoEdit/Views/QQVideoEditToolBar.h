//
//  QQVideoEditToolBar.h
//  QQKitDemo
//
//  Created by Mac on 2021/6/22.
//

#import <UIKit/UIKit.h>
#import "QQButton.h"
#import "QQFillButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface QQVideoEditToolBar : UIView

@property (nonatomic, strong) QQButton *cancelButton;
@property (nonatomic, strong) QQFillButton *doneButton;
@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
