//
//  QQVideoEditViewController.h
//  QQKitDemo
//
//  Created by xuze on 2021/4/9.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QQAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface QQVideoEditViewController : UIViewController

- (instancetype)initWithAsset:(QQAsset *)asset videoAsset:(AVAsset *)videoAsset;

@end

NS_ASSUME_NONNULL_END
