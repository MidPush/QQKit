//
//  QQAssetGridViewController.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQAssetGridViewController : UIViewController

/// 传入之前已选择的资源，再次打开相册会默认选中
@property (nonatomic, strong) NSArray *defaultSelectedAssets;

@end

NS_ASSUME_NONNULL_END
