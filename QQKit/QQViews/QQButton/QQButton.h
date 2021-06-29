//
//  QQButton.h
//  NNKit
//
//  Created by xuze on 2021/2/27.
//

#import <UIKit/UIKit.h>

/// 控制图片在UIButton里的位置，默认为QQButtonImagePositionLeft
typedef NS_ENUM(NSUInteger, QQButtonImagePosition) {
    QQButtonImagePositionTop,             // imageView在titleLabel上面
    QQButtonImagePositionLeft,            // imageView在titleLabel左边
    QQButtonImagePositionBottom,          // imageView在titleLabel下面
    QQButtonImagePositionRight,           // imageView在titleLabel右边
};

/**
 *  计算imageView、titleLabel的frame和系统的计算方式不同：
 *  系统UIButton默认计算方式：当按钮的 bounds 比较小时，系统会尽量展示图片的完整性。
 *  QQButton计算方式：当按钮的 bounds 比较小时，QQButton会尽量展示图片和文字整体的完整性。
 *  所以设置同样的contentEdgeInsets、 imageEdgeInsets、titleEdgeInsets值，当按钮的 bounds 比较小时，展示的效果可能不同。
 *  先这样吧，以后有时间再研究系统默认的计算方式（^_^）
 */
@interface QQButton : UIButton

/**
 * 设置按钮里图标和文字的相对位置，默认为QQButtonImagePositionLeft<br/>
 * 可配合imageEdgeInsets、titleEdgeInsets、contentHorizontalAlignment、contentVerticalAlignment使用
 */
@property (nonatomic, assign) QQButtonImagePosition imagePosition;

/**
 * 设置按钮里图标和文字之间的间隔，会自动响应 imagePosition 的变化而变化，默认为0。
 * @warning 会与 imageEdgeInsets、 titleEdgeInsets、 contentEdgeInsets 共同作用。
 */
@property (nonatomic, assign) IBInspectable CGFloat spacingBetweenImageAndTitle;

/**
 * 是否自动调整highlighted时的按钮样式，默认为YES。<br/>
 * 当值为YES时，按钮highlighted时会改变自身的alpha属性为<b>ButtonHighlightedAlpha</b>
 */
@property (nonatomic, assign) IBInspectable BOOL adjustsButtonWhenHighlighted;

/**
 * 是否自动调整disabled时的按钮样式，默认为YES。<br/>
 * 当值为YES时，按钮disabled时会改变自身的alpha属性为<b>ButtonDisabledAlpha</b>
 */
@property (nonatomic, assign) IBInspectable BOOL adjustsButtonWhenDisabled;

/**
 * 设置按钮点击时的背景色，默认为nil。
 * @warning 不支持带透明度的背景颜色。当设置highlightedBackgroundColor时，会强制把adjustsButtonWhenHighlighted设为NO，避免两者效果冲突。
 * @see adjustsButtonWhenHighlighted
 */
@property (nonatomic, strong, nullable) IBInspectable UIColor *highlightedBackgroundColor;

/**
 * 设置按钮点击时的边框颜色，默认为nil。
 * @warning 当设置highlightedBorderColor时，会强制把adjustsButtonWhenHighlighted设为NO，避免两者效果冲突。
 * @see adjustsButtonWhenHighlighted
 */
@property(nonatomic, strong, nullable) IBInspectable UIColor *highlightedBorderColor;

/**
 * 增大按钮响应区域
 */
@property (nonatomic, assign) UIEdgeInsets outsideEdgeInsets;

@end

