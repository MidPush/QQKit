//
//  QQAssetPreviewViewController.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/2.
//

#import <UIKit/UIKit.h>
#import "QQAsset.h"

@protocol QQAssetPreviewViewControllerDelegate <NSObject>

@optional
- (void)selectedAssetsDidChange:(NSMutableArray *)selectedAssets;
- (void)needsUpdateSourceViewHideOrShow;
- (void)onPreviewToolBarOriginImageButtonClicked:(BOOL)selectedOriginImage;

@end

@interface QQAssetPreviewViewController : UIViewController

/**
 *  更新数据并刷新 UI，手动调用
 */
- (void)updateAssets:(NSMutableArray<QQAsset *> *)assets selectedAssets:(NSMutableArray<QQAsset *> *)selectedAssets currentPage:(NSInteger)currentPage;

@property (nonatomic, weak) id<QQAssetPreviewViewControllerDelegate> delegate;

/// 通过block获取 sourceView，从而进行 zoom 动画的位置计算，如果sourceView为nil，会使用fade动画
@property (nonatomic, copy) UIView *(^sourceView)(QQAsset *asset);

/// 是否选择原图
@property (nonatomic, assign) BOOL selectedOriginImage;

@end

