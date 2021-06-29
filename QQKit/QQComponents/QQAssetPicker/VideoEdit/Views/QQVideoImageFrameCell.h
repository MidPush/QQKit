//
//  QQVideoImageFrameCell.h
//  QQKitDemo
//
//  Created by Mac on 2021/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQVideoImageFrameModel : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL finish;

@end

@interface QQVideoImageFrameCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) QQVideoImageFrameModel *imageFrameModel;

@end

NS_ASSUME_NONNULL_END
