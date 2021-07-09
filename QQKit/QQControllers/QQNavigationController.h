//
//  QQNavigationController.h
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import <UIKit/UIKit.h>

/** 全屏返回手势作用区域 */
typedef NS_ENUM(NSInteger, QQPopRectEdge) {
    QQPopRectEdgeAll,     //全屏
    QQPopRectEdgeLeft,    //边缘
    QQPopRectEdgeNone,    //禁用
};

@interface QQNavigationController : UINavigationController

/// 设置全屏返回手势作用区域
@property (nonatomic, assign) QQPopRectEdge popRectEdge;

@property (nonatomic, copy) QQPopRectEdge (^shouldCanPopGesture)(void);

@end

