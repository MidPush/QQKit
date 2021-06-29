//
//  UIImage+QQCropRotate.h
//  QQKitDemo
//
//  Created by xuze on 2021/4/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QQCropRotate)

- (nonnull UIImage *)croppedImageWithFrame:(CGRect)frame
                                     angle:(NSInteger)angle
                              circularClip:(BOOL)circular;

@end

NS_ASSUME_NONNULL_END
