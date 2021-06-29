//
//  QQAssetGridCell.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "QQAsset.h"

@protocol QQAssetGridCellDelegate <NSObject>

@optional
- (void)onCheckboxButtonClicked:(QQAsset *)asset;
@end

@interface QQAssetGridCell : UICollectionViewCell

// 缩略图
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, assign) id<QQAssetGridCellDelegate> delegate;
@property (nonatomic, strong) QQAsset *asset;
- (void)renderWithAsset:(QQAsset *)asset referenceSize:(CGSize)referenceSize isMaxLimit:(BOOL)isMaxLimit;
- (void)startSpringAnimation;
- (void)removeSpringAnimation;

@end

