//
//  QQImageCropViewController.m
//  QQKitDemo
//
//  Created by Mac on 2021/4/9.
//

#import "QQImageCropViewController.h"
#import "QQCropToolBar.h"
#import "UIView+QQExtension.h"
#import "UIImage+QQCropRotate.h"
#import "QQAssetsPickerHelper.h"
#import "QQAssetsPicker.h"

static const CGFloat kTOCropViewControllerTitleTopPadding = 14.0f;
static const CGFloat kTOCropViewControllerToolbarHeight = 50.0f;

@interface QQImageCropViewController ()<UIViewControllerTransitioningDelegate, QQCropViewDelegate>

/* The target image */
@property (nonatomic, readwrite) UIImage *image;

/* The cropping style of the crop view */
@property (nonatomic, assign, readwrite) QQImageCropStyle croppingStyle;

//
@property (nonatomic, strong) QQAssetPreviewCell *fromView;;

/* Views */
@property (nonatomic, strong) QQCropToolBar *toolBar;
@property (nonatomic, strong, readwrite) QQCropView *cropView;
@property (nonatomic, strong) UIView *toolbarSnapshotView;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *rotateButton;

/* Transition animation controller */
@property (nonatomic, assign) BOOL isDidAppear;
@property (nonatomic, assign) BOOL isWillDisappear;

/* If pushed from a navigation controller, the visibility of that controller's bars. */
@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) BOOL toolbarHidden;

/* State for whether content is being laid out vertically or horizontally */
@property (nonatomic, readonly) BOOL verticalLayout;

/* Convenience method for managing status bar state */
@property (nonatomic, readonly) BOOL overrideStatusBar; // Whether the view controller needs to touch the status bar
@property (nonatomic, readonly) BOOL statusBarHidden;   // Whether it should be hidden or visible at this point
@property (nonatomic, readonly) CGFloat statusBarHeight; // The height of the status bar when visible

/* Convenience method for getting the vertical inset for both iPhone X and status bar */
@property (nonatomic, readonly) UIEdgeInsets statusBarSafeInsets;

/* Flag to perform initial setup on the first run */
@property (nonatomic, assign) BOOL firstTime;

@end

@implementation QQImageCropViewController

- (instancetype)initWithCroppingStyle:(QQImageCropStyle)style image:(UIImage *)image
{
    NSParameterAssert(image);

    if (self = [super init]) {
        // Init parameters
        _image = image;
        _croppingStyle = style;
        
        // Set up base view controller behaviour
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.hidesNavigationBar = true;

        // Default initial behaviour
        _aspectRatioPreset = QQCropViewControllerAspectRatioPresetOriginal;

    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    return [self initWithCroppingStyle:QQImageCropStyleDefault image:image];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set up view controller properties
    self.view.backgroundColor = self.cropView.backgroundColor;
    
    BOOL circularMode = (self.croppingStyle == QQImageCropStyleCircular);

    // Layout the views initially
    self.cropView.frame = [self frameForCropViewWithVerticalLayout:self.verticalLayout];
    self.toolBar.frame = [self frameForToolbarWithVerticalLayout:self.verticalLayout];
    
    if (circularMode) {
        self.rotateButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If this controller is pushed onto a navigation stack, set flags noting the
    // state of the navigation controller bars before we present, and then hide them
    if (self.navigationController) {
        if (self.hidesNavigationBar) {
            self.navigationBarHidden = self.navigationController.navigationBarHidden;
            self.toolbarHidden = self.navigationController.toolbarHidden;
            [self.navigationController setNavigationBarHidden:YES animated:animated];
            [self.navigationController setToolbarHidden:YES animated:animated];
        }

        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    else {
        // Hide the background content when transitioning for performance
        [self.cropView setBackgroundImageViewHidden:YES animated:NO];
        
        // The title label will fade
        self.titleLabel.alpha = animated ? 0.0f : 1.0f;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isDidAppear = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Re-enable translucency now that the animation has completed
    self.cropView.simpleRenderMode = NO;
    
    // Make the grid overlay view fade in
    if (self.cropView.gridOverlayHidden) {
        [self.cropView setGridOverlayHidden:NO animated:animated];
    }
    
    // Fade in the background view content
    if (self.navigationController == nil) {
        [self.cropView setBackgroundImageViewHidden:NO animated:animated];
    }
    
    // If an initial aspect ratio was set before presentation, set it now once the rest of
    // the setup will have been done
    if (self.aspectRatioPreset != QQCropViewControllerAspectRatioPresetOriginal) {
        [self setAspectRatioPreset:self.aspectRatioPreset animated:YES];
        [self onToolBarResetButtonClicked];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isWillDisappear = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Restore the navigation controller to its state before we were presented
    if (self.navigationController && self.hidesNavigationBar) {
        [self.navigationController setNavigationBarHidden:self.navigationBarHidden animated:animated];
        [self.navigationController setToolbarHidden:self.toolbarHidden animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Reset the state once the view has gone offscreen
}

#pragma mark - Status Bar -
- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.navigationController) {
        return UIStatusBarStyleLightContent;
    }

    // Even though we are a dark theme, leave the status bar
    // as black so it's not obvious that it's still visible during the transition
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    if ((_isWillDisappear || !_isDidAppear)) {
        return NO;
    }
    return YES;
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeAll;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (CGRect)frameForToolbarWithVerticalLayout:(BOOL)verticalLayout
{
    UIEdgeInsets insets = self.statusBarSafeInsets;

    CGRect frame = CGRectZero;
    frame.origin.x = 0.0f;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    frame.size.height = kTOCropViewControllerToolbarHeight;
    frame.origin.y = CGRectGetHeight(self.view.bounds) - (frame.size.height + insets.bottom);
    
    return frame;
}

- (CGRect)frameForCropViewWithVerticalLayout:(BOOL)verticalLayout
{
    //On an iPad, if being presented in a modal view controller by a UINavigationController,
    //at the time we need it, the size of our view will be incorrect.
    //If this is the case, derive our view size from our parent view controller instead
    UIView *view = nil;
    if (self.parentViewController == nil) {
        view = self.view;
    }
    else {
        view = self.parentViewController.view;
    }

    UIEdgeInsets insets = self.statusBarSafeInsets;

    CGRect bounds = view.bounds;
    CGRect frame = CGRectZero;

    // Horizontal layout (eg landscape)
    if (!verticalLayout) {
        frame.origin.x = insets.left;
        frame.size.height = CGRectGetHeight(bounds);
        frame.size.width = CGRectGetWidth(bounds) - (insets.left + insets.right);
//        frame.size.height -= (insets.bottom + kTOCropViewControllerToolbarHeight);
    }
    else { // Vertical layout
        frame.size.height = CGRectGetHeight(bounds);
        frame.size.width = CGRectGetWidth(bounds);

        // Set Y and adjust for height
//        frame.size.height -= (insets.bottom + kTOCropViewControllerToolbarHeight);
    }
    
    return frame;
}

- (CGRect)frameForTitleLabelWithSize:(CGSize)size verticalLayout:(BOOL)verticalLayout
{
    CGRect frame = (CGRect){CGPointZero, size};
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat x = 0.0f; // Additional X offset in landscape mode

    // Adjust for landscape layout
    if (!verticalLayout) {
        x = kTOCropViewControllerTitleTopPadding;
        if (@available(iOS 11.0, *)) {
            x += self.view.safeAreaInsets.left;
        }

        viewWidth -= x;
    }

    // Work out horizontal position
    frame.origin.x = ceilf((viewWidth - frame.size.width) * 0.5f);
    if (!verticalLayout) { frame.origin.x += x; }

    // Work out vertical position
    if (@available(iOS 11.0, *)) {
        frame.origin.y = self.view.safeAreaInsets.top + kTOCropViewControllerTitleTopPadding;
    }
    else {
        frame.origin.y = self.statusBarHeight + kTOCropViewControllerTitleTopPadding;
    }

    return frame;
}

- (void)adjustCropViewInsets
{
    UIEdgeInsets insets = self.statusBarSafeInsets;

    // If there is no title text, inset the top of the content as high as possible CGRectGetMinY(self.rotateButton.frame);
    if (!self.titleLabel.text.length) {
        if (self.verticalLayout) {
            self.cropView.cropRegionInsets = UIEdgeInsetsMake(insets.top, 0.0f, CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.rotateButton.frame), 0.0f);
        } else {
            self.cropView.cropRegionInsets = UIEdgeInsetsMake(0.0f, insets.left, CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.rotateButton.frame), insets.right);
        }
        return;
    }

    // Work out the size of the title label based on the crop view size
    CGRect frame = self.titleLabel.frame;
    frame.size = [self.titleLabel sizeThatFits:self.cropView.frame.size];
    self.titleLabel.frame = frame;

    // Set out the appropriate inset for that
    CGFloat verticalInset = self.statusBarHeight;
    verticalInset += kTOCropViewControllerTitleTopPadding;
    verticalInset += self.titleLabel.frame.size.height;
    self.cropView.cropRegionInsets = UIEdgeInsetsMake(verticalInset, 0, insets.bottom, 0);
}

- (void)adjustToolbarInsets
{
    UIEdgeInsets insets = UIEdgeInsetsZero;

    if (@available(iOS 11.0, *)) {
        // Add padding to the left in landscape mode
        if (!self.verticalLayout) {
            insets.left = self.view.safeAreaInsets.left;
            insets.right = self.view.safeAreaInsets.right;
        } else {
            insets.bottom = self.view.safeAreaInsets.bottom;
        }
    }

    // Update the toolbar with these properties
//    self.toolbar.backgroundViewOutsets = insets;
//    self.toolbar.statusBarHeightInset = self.statusBarHeight;
//    [self.toolbar setNeedsLayout];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    [self adjustCropViewInsets];
    [self adjustToolbarInsets];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [UIView performWithoutAnimation:^{
        self.toolBar.frame = [self frameForToolbarWithVerticalLayout:self.verticalLayout];
        [self adjustToolbarInsets];
        [self.toolBar setNeedsLayout];
        self.rotateButton.frame = CGRectMake(10 + self.view.qq_safeAreaInsets.left, CGRectGetMinY(self.toolBar.frame) - 70, 40, 40);
    }];
    
    self.cropView.frame = [self frameForCropViewWithVerticalLayout:self.verticalLayout];
    [self adjustCropViewInsets];
    [self.cropView moveCroppedContentToCenterAnimated:NO];

    if (self.firstTime == NO) {
        [self.cropView performInitialSetup];
        self.firstTime = YES;
        [self performPresentAnimation];
    }
    
    if (self.title.length) {
        self.titleLabel.frame = [self frameForTitleLabelWithSize:self.titleLabel.frame.size verticalLayout:self.verticalLayout];
        [self.cropView moveCroppedContentToCenterAnimated:NO];
    }
    
    [self.view bringSubviewToFront:self.toolBar];
}

#pragma mark - Rotation Handling -

- (void)_willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.toolbarSnapshotView = [self.toolBar snapshotViewAfterScreenUpdates:NO];
    self.toolbarSnapshotView.frame = self.toolBar.frame;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.toolbarSnapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    else {
        self.toolbarSnapshotView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    }
    [self.view addSubview:self.toolbarSnapshotView];

    // Set up the toolbar frame to be just off t
    CGRect frame = [self frameForToolbarWithVerticalLayout:UIInterfaceOrientationIsPortrait(toInterfaceOrientation)];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        frame.origin.x = -frame.size.width;
    }
    else {
        frame.origin.y = self.view.bounds.size.height;
    }
    self.toolBar.frame = frame;

    [self.toolBar layoutIfNeeded];
    self.toolBar.alpha = 0.0f;
    
    [self.cropView prepareforRotation];
    self.cropView.frame = [self frameForCropViewWithVerticalLayout:!UIInterfaceOrientationIsPortrait(toInterfaceOrientation)];
    self.cropView.simpleRenderMode = YES;
    self.cropView.internalLayoutDisabled = YES;
}

- (void)_willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //Remove all animations in the toolbar
    self.toolBar.frame = [self frameForToolbarWithVerticalLayout:!UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    [self.toolBar.layer removeAllAnimations];
    for (CALayer *sublayer in self.toolBar.layer.sublayers) {
        [sublayer removeAllAnimations];
    }

    // On iOS 11, since these layout calls are done multiple times, if we don't aggregate from the
    // current state, the animation breaks.
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:
    ^{
        self.cropView.frame = [self frameForCropViewWithVerticalLayout:!UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
        self.toolBar.frame = [self frameForToolbarWithVerticalLayout:UIInterfaceOrientationIsPortrait(toInterfaceOrientation)];
        [self.cropView performRelayoutForRotation];
    } completion:nil];

    self.toolbarSnapshotView.alpha = 0.0f;
    self.toolBar.alpha = 1.0f;
}

- (void)_didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.toolbarSnapshotView removeFromSuperview];
    self.toolbarSnapshotView = nil;
    
    [self.cropView setSimpleRenderMode:NO animated:YES];
    self.cropView.internalLayoutDisabled = NO;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // If the size doesn't change (e.g, we did a 180 degree device rotation), don't bother doing a relayout
    if (CGSizeEqualToSize(size, self.view.bounds.size)) { return; }
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    CGSize currentSize = self.view.bounds.size;
    if (currentSize.width < size.width) {
        orientation = UIInterfaceOrientationLandscapeLeft;
    }
    
    [self _willRotateToInterfaceOrientation:orientation duration:coordinator.transitionDuration];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self _willAnimateRotationToInterfaceOrientation:orientation duration:coordinator.transitionDuration];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self _didRotateFromInterfaceOrientation:orientation];
    }];
}

#pragma mark - Reset -
- (void)resetCropViewLayout
{
    BOOL animated = (self.cropView.angle == 0);
    
    if (self.resetAspectRatioEnabled) {
        self.aspectRatioLockEnabled = NO;
    }
    
    [self.cropView resetLayoutToDefaultAnimated:animated];
}

- (void)setAspectRatioPreset:(QQCropViewControllerAspectRatioPreset)aspectRatioPreset animated:(BOOL)animated
{
    CGSize aspectRatio = CGSizeZero;
    
    _aspectRatioPreset = aspectRatioPreset;
    
    switch (aspectRatioPreset) {
        case QQCropViewControllerAspectRatioPresetOriginal:
            aspectRatio = CGSizeZero;
            break;
        case QQCropViewControllerAspectRatioPresetSquare:
            aspectRatio = CGSizeMake(1.0f, 1.0f);
            break;
        case QQCropViewControllerAspectRatioPreset3x2:
            aspectRatio = CGSizeMake(3.0f, 2.0f);
            break;
        case QQCropViewControllerAspectRatioPreset5x3:
            aspectRatio = CGSizeMake(5.0f, 3.0f);
            break;
        case QQCropViewControllerAspectRatioPreset4x3:
            aspectRatio = CGSizeMake(4.0f, 3.0f);
            break;
        case QQCropViewControllerAspectRatioPreset5x4:
            aspectRatio = CGSizeMake(5.0f, 4.0f);
            break;
        case QQCropViewControllerAspectRatioPreset7x5:
            aspectRatio = CGSizeMake(7.0f, 5.0f);
            break;
        case QQCropViewControllerAspectRatioPreset16x9:
            aspectRatio = CGSizeMake(16.0f, 9.0f);
            break;
        case QQCropViewControllerAspectRatioPresetCustom:
            aspectRatio = self.customAspectRatio;
            break;
    }
    
    // If the aspect ratio lock is not enabled, allow a swap
    // If the aspect ratio lock is on, allow a aspect ratio swap
    // only if the allowDimensionSwap option is specified.
    BOOL aspectRatioCanSwapDimensions = !self.aspectRatioLockEnabled ||
                                (self.aspectRatioLockEnabled && self.aspectRatioLockDimensionSwapEnabled);
    
    //If the image is a portrait shape, flip the aspect ratio to match
    if (self.cropView.cropBoxAspectRatioIsPortrait &&
        aspectRatioCanSwapDimensions)
    {
        CGFloat width = aspectRatio.width;
        aspectRatio.width = aspectRatio.height;
        aspectRatio.height = width;
    }
    
    [self.cropView setAspectRatio:aspectRatio animated:animated];
}

- (void)rotateCropViewClockwise
{
    [self.cropView rotateImageNinetyDegreesAnimated:YES clockwise:YES];
}

- (void)rotateCropViewCounterclockwise
{
    [self.cropView rotateImageNinetyDegreesAnimated:YES clockwise:NO];
}

#pragma mark - Crop View Delegates -
- (void)cropViewDidBecomeResettable:(QQCropView *)cropView {
    self.toolBar.resetButtonEnabled = YES;
}

- (void)cropViewDidBecomeNonResettable:(QQCropView *)cropView {
    self.toolBar.resetButtonEnabled = NO;
}

- (void)cropViewDidStartEditing:(nonnull QQCropView *)cropView {
    [self hideShowRotateButton:YES];
}

- (void)cropViewDidEndEditing:(nonnull QQCropView *)cropView {
    [self hideShowRotateButton:NO];
}

- (void)hideShowRotateButton:(BOOL)startEditing {
    CGFloat alpha = startEditing ? 0.0 : 1.0;
    [UIView animateWithDuration:0.25 animations:^{
        self.rotateButton.alpha = alpha;
    }];
}

#pragma mark - Presentation Handling -
- (void)presentFromViewController:(nonnull UIViewController *)viewController
                         fromView:(nullable QQAssetPreviewCell *)fromView
                            angle:(NSInteger)angle
                     toImageFrame:(CGRect)toFrame
                            setup:(nullable void (^)(void))setup
                       completion:(nullable void (^)(void))completion {
    
    _fromView = fromView;
    
    if (self.angle != 0 || !CGRectIsEmpty(toFrame)) {
        self.angle = angle;
        self.imageCropFrame = toFrame;
    }
    
    CGRect fromFrame = [self.view convertRect:fromView.imageView.frame toView:self.view];
    __weak typeof (self) weakSelf = self;
    [viewController presentViewController:self animated:NO completion:^{
        typeof (self) strongSelf = weakSelf;
        if (completion) {
            completion();
        }
        
        [strongSelf.cropView setCroppingViewsHidden:NO animated:YES];
        if (!CGRectIsEmpty(fromFrame)) {
            [strongSelf.cropView setGridOverlayHidden:NO animated:YES];
        }
    }];
    
}

- (void)performPresentAnimation {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        return;
    }
    
    _fromView.hidden = YES;
    self.cropView.hidden = YES;
    CGRect fromFrame = [self.view convertRect:_fromView.imageView.frame toView:self.view];
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithImage:_fromView.imageView.image];
    animatedImageView.clipsToBounds = YES;
    animatedImageView.contentMode = _fromView.imageView.contentMode;
    animatedImageView.frame = fromFrame;
    [self.view insertSubview:animatedImageView atIndex:0];
    
    CGRect toFrame = [self.cropView convertRect:self.cropView.imageViewFrame toView:self.view];
    [UIView animateWithDuration:0.25 animations:^{
        animatedImageView.frame = toFrame;
        animatedImageView.layer.cornerRadius = 0.0;
    } completion:^(BOOL finished) {
        [animatedImageView removeFromSuperview];
        self.cropView.hidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}
    
- (void)performDismissAnimation:(BOOL)cancel {
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (cancel) {
        [self resetCropViewLayout];
    }
    
    self.cropView.hidden = YES;
    self.hidesNavigationBar = YES;
    self.toolBar.hidden = YES;
    self.rotateButton.hidden = YES;
    
    CGRect cropFrame = self.cropView.imageCropFrame;
    NSInteger angle = self.cropView.angle;
    UIImage *animatedImage = self.image;
    BOOL isCircularImageDelegateAvailable = [self.delegate respondsToSelector:@selector(cropViewController:didCropToCircularImage:withRect:angle:)];
    BOOL isCircularImageCallbackAvailable = self.onDidCropToCircleImage != nil;

    // Check if non-circular was implemented
    BOOL isDidCropToImageDelegateAvailable = [self.delegate respondsToSelector:@selector(cropViewController:didCropToImage:withRect:angle:)];
    BOOL isDidCropToImageCallbackAvailable = self.onDidCropToRect != nil;

    if (self.croppingStyle == QQImageCropStyleCircular && (isCircularImageDelegateAvailable || isCircularImageCallbackAvailable)) {
        animatedImage = [self.image croppedImageWithFrame:cropFrame angle:angle circularClip:YES];
    } else if (isDidCropToImageDelegateAvailable || isDidCropToImageCallbackAvailable) {
        if (angle == 0 && CGRectEqualToRect(cropFrame, (CGRect){CGPointZero, self.image.size})) {
            animatedImage = self.image;
        } else {
            animatedImage = [self.image croppedImageWithFrame:cropFrame angle:angle circularClip:NO];
        }
    }
    
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self callDelegate:cancel animatedView:nil];
        [self.navigationController popViewControllerAnimated:cancel];
        return;
    }
    
    UIImageView *animatedView = [[UIImageView alloc] initWithImage:animatedImage];
    animatedView.frame = [self.cropView convertRect:self.cropView.cropBoxFrame toView:self.view];
    animatedView.clipsToBounds = YES;
    animatedView.layer.masksToBounds = YES;
    [self.view addSubview:animatedView];
    
    CGRect toFrame = [QQAssetsPickerHelper scaleAspectFillImage:animatedImage.size boundsSize:self.view.frame.size];
    
    [UIView animateWithDuration:0.25 animations:^{
        animatedView.frame = toFrame;
    } completion:^(BOOL finished) {
        self.fromView.hidden = NO;
        [self callDelegate:cancel animatedView:animatedView];
    }];
}

- (void)callDelegate:(BOOL)cancel animatedView:(UIView *)animatedView {
    CGRect cropFrame = self.cropView.imageCropFrame;
    NSInteger angle = self.cropView.angle;
    if (cancel) {
        if ([self.delegate respondsToSelector:@selector(cropViewController:didFinishCancelled:)]) {
            [self.delegate cropViewController:self didFinishCancelled:YES];
        }

        if (self.onDidFinishCancelled != nil) {
            self.onDidFinishCancelled(YES);
        }
        
        [self dismissAndRemovewAnimatedView:animatedView];
    } else {
        if ([self.delegate respondsToSelector:@selector(cropViewController:didCropImageToRect:angle:)]) {
            [self.delegate cropViewController:self didCropImageToRect:cropFrame angle:angle];
        }

        if (self.onDidCropImageToRect != nil) {
            self.onDidCropImageToRect(cropFrame, angle);
        }
        
        // Check if the circular APIs were implemented
        BOOL isCircularImageDelegateAvailable = [self.delegate respondsToSelector:@selector(cropViewController:didCropToCircularImage:withRect:angle:)];
        BOOL isCircularImageCallbackAvailable = self.onDidCropToCircleImage != nil;

        // Check if non-circular was implemented
        BOOL isDidCropToImageDelegateAvailable = [self.delegate respondsToSelector:@selector(cropViewController:didCropToImage:withRect:angle:)];
        BOOL isDidCropToImageCallbackAvailable = self.onDidCropToRect != nil;

        //If cropping circular and the circular generation delegate/block is implemented, call it
        if (self.croppingStyle == QQImageCropStyleCircular && (isCircularImageDelegateAvailable || isCircularImageCallbackAvailable)) {
            UIImage *image = [self.image croppedImageWithFrame:cropFrame angle:angle circularClip:YES];
            //Dispatch on the next run-loop so the animation isn't interuppted by the crop operation
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (isCircularImageDelegateAvailable) {
                    [self.delegate cropViewController:self didCropToCircularImage:image withRect:cropFrame angle:angle];
                }
                if (isCircularImageCallbackAvailable) {
                    self.onDidCropToCircleImage(image, cropFrame, angle);
                }
                
                [self dismissAndRemovewAnimatedView:animatedView];
            });
    
        }
        //If the delegate/block that requires the specific cropped image is provided, call it
        else if (isDidCropToImageDelegateAvailable || isDidCropToImageCallbackAvailable) {
            UIImage *image = nil;
            if (angle == 0 && CGRectEqualToRect(cropFrame, (CGRect){CGPointZero, self.image.size})) {
                image = self.image;
            }
            else {
                image = [self.image croppedImageWithFrame:cropFrame angle:angle circularClip:NO];
            }
            //Dispatch on the next run-loop so the animation isn't interuppted by the crop operation
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (isDidCropToImageDelegateAvailable) {
                    [self.delegate cropViewController:self didCropToImage:image withRect:cropFrame angle:angle];
                }

                if (isDidCropToImageCallbackAvailable) {
                    self.onDidCropToRect(image, cropFrame, angle);
                }
                
                [self dismissAndRemovewAnimatedView:animatedView];
            });
        
        }
    }
}

- (void)dismissAndRemovewAnimatedView:(UIView *)animatedView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [animatedView removeFromSuperview];
        [self dismissViewControllerAnimated:NO completion:^{
            if ([self.delegate respondsToSelector:@selector(cropViewControllerDidDismiss:)]) {
                [self.delegate cropViewControllerDidDismiss:self];
            }
        }];
    });
}
#pragma mark - Button Feedback -

- (void)onRotateButtonClicked {
    [self.cropView rotateImageNinetyDegreesAnimated:YES clockwise:NO];
}

- (void)onToolBarCancelButtonClicked
{
    [self performDismissAnimation:YES];
}

- (void)onToolBarResetButtonClicked {
    [self resetCropViewLayout];
}

- (void)onToolBarDoneButtonClicked
{
    [self performDismissAnimation:NO];
}

- (void)commitCurrentCrop
{
    [self onToolBarDoneButtonClicked];
}

#pragma mark - Property Methods -

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];

    if (self.title.length == 0) {
        [_titleLabel removeFromSuperview];
        _cropView.cropRegionInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _titleLabel = nil;
        return;
    }

    self.titleLabel.text = self.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = [self frameForTitleLabelWithSize:self.titleLabel.frame.size verticalLayout:self.verticalLayout];
}

- (QQCropView *)cropView
{
    // Lazily create the crop view in case we try and access it before presentation, but
    // don't add it until our parent view controller view has loaded at the right time
    if (!_cropView) {
        _cropView = [[QQCropView alloc] initWithCroppingStyle:self.croppingStyle image:self.image];
        _cropView.delegate = self;
        _cropView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_cropView];
    }
    return _cropView;
}

- (QQCropToolBar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[QQCropToolBar alloc] initWithFrame:CGRectZero];
        [_toolBar.cancelButton addTarget:self action:@selector(onToolBarCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.resetButton addTarget:self action:@selector(onToolBarResetButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.doneButton addTarget:self action:@selector(onToolBarDoneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_toolBar];
    }
    return _toolBar;
}

- (UIButton *)rotateButton {
    if (!_rotateButton) {
        _rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rotateButton setImage:[QQAssetsPicker sharedPicker].configuration.assetPickerRotateImage forState:UIControlStateNormal];
        [_rotateButton addTarget:self action:@selector(onRotateButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_rotateButton];
    }
    return _rotateButton;
}

- (UILabel *)titleLabel
{
    if (!self.title.length) { return nil; }
    if (_titleLabel) { return _titleLabel; }

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 1;
    _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    _titleLabel.clipsToBounds = YES;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = self.title;

    [self.view insertSubview:self.titleLabel aboveSubview:self.cropView];

    return _titleLabel;
}

- (void)setAspectRatioLockEnabled:(BOOL)aspectRatioLockEnabled
{
    self.cropView.aspectRatioLockEnabled = aspectRatioLockEnabled;
}

- (void)setAspectRatioLockDimensionSwapEnabled:(BOOL)aspectRatioLockDimensionSwapEnabled
{
    self.cropView.aspectRatioLockDimensionSwapEnabled = aspectRatioLockDimensionSwapEnabled;
}

- (BOOL)aspectRatioLockEnabled
{
    return self.cropView.aspectRatioLockEnabled;
}

- (void)setResetAspectRatioEnabled:(BOOL)resetAspectRatioEnabled
{
    self.cropView.resetAspectRatioEnabled = resetAspectRatioEnabled;
}

- (void)setCustomAspectRatio:(CGSize)customAspectRatio
{
    _customAspectRatio = customAspectRatio;
    [self setAspectRatioPreset:QQCropViewControllerAspectRatioPresetCustom animated:NO];
}

- (BOOL)resetAspectRatioEnabled
{
    return self.cropView.resetAspectRatioEnabled;
}

- (void)setRotateButtonHidden:(BOOL)rotateButtonHidden {
    _rotateButtonHidden = rotateButtonHidden;
    self.rotateButton.hidden = rotateButtonHidden;
}

- (void)setAngle:(NSInteger)angle
{
    self.cropView.angle = angle;
}

- (NSInteger)angle
{
    return self.cropView.angle;
}

- (void)setImageCropFrame:(CGRect)imageCropFrame
{
    self.cropView.imageCropFrame = imageCropFrame;
}

- (CGRect)imageCropFrame
{
    return self.cropView.imageCropFrame;
}

- (BOOL)verticalLayout
{
#if TARGET_OS_MACCATALYST
    return YES;
#endif

    return CGRectGetWidth(self.view.bounds) < CGRectGetHeight(self.view.bounds);
}

- (BOOL)overrideStatusBar
{
    // If we're pushed from a navigation controller, we'll defer
    // to its handling of the status bar
    if (self.navigationController) {
        return NO;
    }
    
    // If the view controller presenting us already hid it, we don't need to
    // do anything ourselves
    if (self.presentingViewController.prefersStatusBarHidden) {
        return NO;
    }
    
    // We'll handle the status bar
    return YES;
}

- (BOOL)statusBarHidden
{
    // Defer behaviour to the hosting navigation controller
//    if (self.navigationController) {
//        return self.navigationController.prefersStatusBarHidden;
//    }
//    
//    //If our presenting controller has already hidden the status bar,
//    //hide the status bar by default
//    if (self.presentingViewController.prefersStatusBarHidden) {
//        return YES;
//    }
    
    // Our default behaviour is to always hide the status bar
    return YES;
}

- (CGFloat)statusBarHeight
{
    CGFloat statusBarHeight = 0.0f;
    if (@available(iOS 11.0, *)) {
        statusBarHeight = self.view.safeAreaInsets.top;

        // We do need to include the status bar height on devices
        // that have a physical hardware inset, like an iPhone X notch
        BOOL hardwareRelatedInset = self.view.safeAreaInsets.bottom > FLT_EPSILON
                                    && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;

        // Always have insetting on Mac Catalyst
        #if TARGET_OS_MACCATALYST
        hardwareRelatedInset = YES;
        #endif

        // Unless the status bar is visible, or we need to account
        // for a hardware notch, always treat the status bar height as zero
        if (self.statusBarHidden && !hardwareRelatedInset) {
            statusBarHeight = 0.0f;
        }
    }
    else {
        if (self.statusBarHidden) {
            statusBarHeight = 0.0f;
        }
        else {
            statusBarHeight = self.topLayoutGuide.length;
        }
    }
    
    return statusBarHeight;
}

- (UIEdgeInsets)statusBarSafeInsets
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        insets = self.view.safeAreaInsets;
        insets.top = self.statusBarHeight;
    }
    else {
        insets.top = self.statusBarHeight;
    }

    return insets;
}

- (void)setMinimumAspectRatio:(CGFloat)minimumAspectRatio
{
    self.cropView.minimumAspectRatio = minimumAspectRatio;
}

- (CGFloat)minimumAspectRatio
{
    return self.cropView.minimumAspectRatio;
}

@end
