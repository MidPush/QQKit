//
//  QQNavigationBarAlbumTitleView.h
//  QQKitDemo
//
//  Created by xuze on 2021/4/5.
//

#import <UIKit/UIKit.h>
#import "QQFillButton.h"

@interface QQNavigationBarAlbumTitleView : UIView

@property (nonatomic, strong) UIButton *actionButton;
- (void)updateAlbumName:(NSString *)albumName animated:(BOOL)animated;
- (void)rotateArrowIcon;

@end

