//
//  QQPermissionPromptView.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "QQButton.h"
#import "QQAssetsPicker.h"

@interface QQPermissionPromptView : UIView

@property (nonatomic, strong) QQButton *closeButton;
@property (nonatomic, strong) QQButton *toSettingButton;
@property (nonatomic, strong) QQButton *limitedButton;
@property (nonatomic, assign) QQAuthorizationStatus authorizationStatus;

@end

