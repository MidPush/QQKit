//
//  QQViewController.h
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import <UIKit/UIKit.h>
#import "QQNavigationController.h"
#import "UINavigationBarAppearanceProtocol.h"

@interface QQViewController : UIViewController<UINavigationBarAppearanceProtocol>

/// 当前控制器支持旋转方向
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;

/**
 设置全屏返回手势作用区域。
 注意：修改 popRectEdge 是修改 QQNavigationController 返回手势作用区域，
 所以在 viewWillAppear 修改后，在 viewWillDisappear 中修改回来。
 例如：
 - (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.popRectEdge = PopRectEdgeNone;
 }
 - (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.popRectEdge = PopRectEdgeAll;
 }
 */
@property (nonatomic, assign) QQPopRectEdge popRectEdge;

/**
 * 设置导航栏，子类重写
 * 这里不加 NS_REQUIRES_SUPER 标志，要不要调用 [super setupNavigationBar] 由自己决定。加了标志后每次都要调用 super 很麻烦
 * 因为有时候一级继承并不需要调用 super。- (void) initSubviews、- (void)onBackBarButtonItemClicked  同理
 */
- (void)setupNavigationBar;

/// 初始化子视图，子类重写
- (void)initSubviews;

/**
 * 点击了返回按钮 backBarButtonItem，调用 [self.navigationController popViewControllerAnimated:YES] 方法返回上一个控制器
 * 如果需要拦截返回按钮点击事件，子类重写
 */
- (void)onBackBarButtonItemClicked;

@end


