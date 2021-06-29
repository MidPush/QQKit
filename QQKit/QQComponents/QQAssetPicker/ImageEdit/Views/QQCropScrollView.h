//
//  QQCropScrollView.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQCropScrollView : UIScrollView

@property (nonatomic, copy) void (^touchesBegan)(void);
@property (nonatomic, copy) void (^touchesCancelled)(void);
@property (nonatomic, copy) void (^touchesEnded)(void);

@end

NS_ASSUME_NONNULL_END
