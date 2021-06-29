//
//  QQImageCropViewController.h
//  QQKitDemo
//
//  Created by Mac on 2021/4/9.
//

#import <UIKit/UIKit.h>
#import "QQCropViewConstants.h"
#import "QQCropView.h"
#import "QQCropToolBar.h"
#import "QQCropView.h"
#import "QQAssetPreviewCell.h"

/**
 QQImageCropViewController 是 第三方库 TOCropViewController 的修改版
 源码地址：https://github.com/TimOliver/TOCropViewController
 */
@class QQImageCropViewController;
@protocol QQImageCropViewControllerDelegate <NSObject>

@optional
- (void)cropViewController:(nonnull QQImageCropViewController *)cropViewController
        didCropImageToRect:(CGRect)cropRect
                     angle:(NSInteger)angle;

- (void)cropViewController:(nonnull QQImageCropViewController *)cropViewController
            didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle;

- (void)cropViewController:(nonnull QQImageCropViewController *)cropViewController
    didCropToCircularImage:(nonnull UIImage *)image withRect:(CGRect)cropRect
                     angle:(NSInteger)angle;

- (void)cropViewController:(nonnull QQImageCropViewController *)cropViewController
        didFinishCancelled:(BOOL)cancelled;

- (void)cropViewControllerDidDismiss:(nonnull QQImageCropViewController *)cropViewController;

@end

@interface QQImageCropViewController : UIViewController

/**
 The original, uncropped image that was passed to this controller.
 */
@property (nonnull, nonatomic, readonly) UIImage *image;

/**
 The minimum croping aspect ratio. If set, user is prevented from
 setting cropping rectangle to lower aspect ratio than defined by the parameter.
 */
@property (nonatomic, assign) CGFloat minimumAspectRatio;

/**
 The view controller's delegate that will receive the resulting
 cropped image, as well as crop information.
 */
@property (nullable, nonatomic, weak) id<QQImageCropViewControllerDelegate> delegate;

/**
 The crop view managed by this view controller.
 */
@property (nonnull, nonatomic, strong, readonly) QQCropView *cropView;

/**
 In the coordinate space of the image itself, the region that is currently
 being highlighted by the crop box.
 
 This property can be set before the controller is presented to have
 the image 'restored' to a previous cropping layout.
 */
@property (nonatomic, assign) CGRect imageCropFrame;

/**
 The angle in which the image is rotated in the crop view.
 This can only be in 90 degree increments (eg, 0, 90, 180, 270).
 
 This property can be set before the controller is presented to have
 the image 'restored' to a previous cropping layout.
 */
@property (nonatomic, assign) NSInteger angle;

/**
 The toolbar view managed by this view controller.
 */
@property (nonnull, nonatomic, strong, readonly) QQCropToolBar *toolBar;

/**
 The cropping style of this particular crop view controller
 */
@property (nonatomic, readonly) QQImageCropStyle croppingStyle;

/**
 A choice from one of the pre-defined aspect ratio presets
 */
@property (nonatomic, assign) QQCropViewControllerAspectRatioPreset aspectRatioPreset;

/**
 重置的长宽比
 */
//@property (nonatomic, assign) QQCropViewControllerAspectRatioPreset resetAspectRatioPreset;

/**
 A CGSize value representing a custom aspect ratio, not listed in the presets.
 E.g. A ratio of 4:3 would be represented as (CGSize){4.0f, 3.0f}
 */
@property (nonatomic, assign) CGSize customAspectRatio;

/**
 If this is set alongside `customAspectRatio`, the custom aspect ratio
 will be shown as a selectable choice in the list of aspect ratios. (Default is `nil`)
 */
@property (nullable, nonatomic, copy) NSString *customAspectRatioName;

/**
 Title label which can be used to show instruction on the top of the crop view controller
 */
@property (nullable, nonatomic, readonly) UILabel *titleLabel;

/**
 If true, a custom aspect ratio is set, and the aspectRatioLockEnabled is set to YES, the crop box
 will swap it's dimensions depending on portrait or landscape sized images.
 This value also controls whether the dimensions can swap when the image is rotated.
 
 Default is NO.
 */
@property (nonatomic, assign) BOOL aspectRatioLockDimensionSwapEnabled;

/**
 If true, while it can still be resized, the crop box will be locked to its current aspect ratio.
 
 If this is set to YES, and `resetAspectRatioEnabled` is set to NO, then the aspect ratio
 button will automatically be hidden from the toolbar.
 
 Default is NO.
 */
@property (nonatomic, assign) BOOL aspectRatioLockEnabled;

/**
 If true, tapping the reset button will also reset the aspect ratio back to the image
 default ratio. Otherwise, the reset will just zoom out to the current aspect ratio.
 
 If this is set to NO, and `aspectRatioLockEnabled` is set to YES, then the aspect ratio
 button will automatically be hidden from the toolbar.
 
 Default is YES
 */
@property (nonatomic, assign) BOOL resetAspectRatioEnabled;

/**
 When disabled, an additional rotation button that rotates the canvas in
 90-degree segments in a clockwise direction is shown in the toolbar.
 
 Default is NO.
 */
@property (nonatomic, assign) BOOL rotateButtonHidden;

/*
 If this controller is embedded in UINavigationController its navigation bar
 is hidden by default. Set this property to false to show the navigation bar.
 This must be set before this controller is presented.
 */
@property (nonatomic, assign) BOOL hidesNavigationBar;

/**
 An array of `TOCropViewControllerAspectRatioPreset` enum values denoting which
 aspect ratios the crop view controller may display (Default is nil. All are shown)
 */
@property (nullable, nonatomic, strong) NSArray<NSNumber *> *allowedAspectRatios;

/**
 When the user hits cancel, or completes a
 UIActivityViewController operation, this block will be called,
 giving you a chance to manually dismiss the view controller
 */
@property (nullable, nonatomic, strong) void (^onDidFinishCancelled)(BOOL isFinished);

/**
 Called when the user has committed the crop action, and provides
 just the cropping rectangle.
 
 @param cropRect A rectangle indicating the crop region of the image the user chose
                    (In the original image's local co-ordinate space)
 @param angle The angle of the image when it was cropped
 */
@property (nullable, nonatomic, strong) void (^onDidCropImageToRect)(CGRect cropRect, NSInteger angle);

/**
 Called when the user has committed the crop action, and provides
 both the cropped image with crop co-ordinates.
 
 @param image The newly cropped image.
 @param cropRect A rectangle indicating the crop region of the image the user chose
                    (In the original image's local co-ordinate space)
 @param angle The angle of the image when it was cropped
 */
@property (nullable, nonatomic, strong) void (^onDidCropToRect)(UIImage* _Nonnull image, CGRect cropRect, NSInteger angle);

/**
 If the cropping style is set to circular, this block will return a circle-cropped version of the selected
 image, as well as it's cropping co-ordinates
 
 @param image The newly cropped image, clipped to a circle shape
 @param cropRect A rectangle indicating the crop region of the image the user chose
                    (In the original image's local co-ordinate space)
 @param angle The angle of the image when it was cropped
 */
@property (nullable, nonatomic, strong) void (^onDidCropToCircleImage)(UIImage* _Nonnull image, CGRect cropRect, NSInteger angle);


///------------------------------------------------
/// @name Object Creation
///------------------------------------------------

/**
 Creates a new instance of a crop view controller with the supplied image
 
 @param image The image that will be used to crop.
 */
- (nonnull instancetype)initWithImage:(nonnull UIImage *)image NS_SWIFT_NAME(init(image:));

/**
 Creates a new instance of a crop view controller with the supplied image and cropping style
 
 @param style The cropping style that will be used with this view controller (eg, rectangular, or circular)
 @param image The image that will be cropped
 */
- (nonnull instancetype)initWithCroppingStyle:(QQImageCropStyle)style image:(nonnull UIImage *)image;

/**
 Commits the crop action as if user pressed done button in the bottom bar themself
 */
- (void)commitCurrentCrop;

/**
 Resets object of TOCropViewController class as if user pressed reset button in the bottom bar themself
 */
- (void)resetCropViewLayout;

/**
 Set the aspect ratio to be one of the available preset options. These presets have specific behaviour
 such as swapping their dimensions depending on portrait or landscape sized images.
 
 @param aspectRatioPreset The aspect ratio preset
 @param animated Whether the transition to the aspect ratio is animated
 */
- (void)setAspectRatioPreset:(QQCropViewControllerAspectRatioPreset)aspectRatioPreset animated:(BOOL)animated NS_SWIFT_NAME(setAspectRatioPresent(_:animated:));


- (void)presentFromViewController:(nonnull UIViewController *)viewController
                         fromView:(nullable QQAssetPreviewCell *)fromView
                            angle:(NSInteger)angle
                     toImageFrame:(CGRect)toFrame
                            setup:(nullable void (^)(void))setup
                       completion:(nullable void (^)(void))completion;

@end

