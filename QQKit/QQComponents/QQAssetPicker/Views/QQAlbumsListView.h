//
//  QQAlbumsListView.h
//  QQKitDemo
//
//  Created by xuze on 2021/4/5.
//

#import <UIKit/UIKit.h>
#import "QQAssetsPicker.h"

@class QQAlbumsListView;
@protocol QQAlbumsListViewDelegate <NSObject>

@optional
- (void)albumsListView:(QQAlbumsListView *)albumsListView didSelectAlbum:(QQAssetsGroup *)album;
- (void)albumsListViewDidShow:(QQAlbumsListView *)albumsListView;
- (void)albumsListViewDidDismiss:(QQAlbumsListView *)albumsListView;

@end

@interface QQAlbumsListView : UIView

- (instancetype)initWithFrame:(CGRect)frame albums:(NSArray<QQAssetsGroup *> *)albums;
@property (nonatomic, weak) id<QQAlbumsListViewDelegate> delegate;
@property (nonatomic, strong) NSArray<QQAssetsGroup *> *albums;
@property (nonatomic, assign, getter=isShow) BOOL show;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@end

