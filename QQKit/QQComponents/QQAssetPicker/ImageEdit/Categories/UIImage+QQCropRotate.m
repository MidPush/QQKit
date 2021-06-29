//
//  UIImage+QQCropRotate.m
//  QQKitDemo
//
//  Created by xuze on 2021/4/10.
//

#import "UIImage+QQCropRotate.h"

@implementation UIImage (QQCropRotate)

- (BOOL)hasAlpha {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    return (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaPremultipliedLast);
}

- (UIImage *)croppedImageWithFrame:(CGRect)frame angle:(NSInteger)angle circularClip:(BOOL)circular {
    UIImage *croppedImage = nil;
    UIGraphicsBeginImageContextWithOptions(frame.size, !self.hasAlpha && !circular, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();

        // If we're capturing a circular image, set the clip mask first
        if (circular) {
            CGContextAddEllipseInRect(context, (CGRect){CGPointZero, frame.size});
            CGContextClip(context);
        }

        // Offset the origin (Which is the top left corner) to start where our cropping origin is
        CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);

        // If an angle was supplied, rotate the entire canvas + coordinate space to match
        if (angle != 0) {
            // Rotation in radians
            CGFloat rotation = angle * (M_PI/180.0f);

            // Work out the new bounding size of the canvas after rotation
            CGRect imageBounds = (CGRect){CGPointZero, self.size};
            CGRect rotatedBounds = CGRectApplyAffineTransform(imageBounds,
                                                              CGAffineTransformMakeRotation(rotation));
            // As we're rotating from the top left corner, and not the center of the canvas, the frame
            // will have rotated out of our visible canvas. Compensate for this.
            CGContextTranslateCTM(context, -rotatedBounds.origin.x, -rotatedBounds.origin.y);

            // Perform the rotation transformation
            CGContextRotateCTM(context, rotation);
        }

        // Draw the image with all of the transformation parameters applied.
        // We do not need to worry about specifying the size here since we're already
        // constrained by the context image size
        [self drawAtPoint:CGPointZero];
        
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();

    // Re-apply the retina scale we originally had
    return [UIImage imageWithCGImage:croppedImage.CGImage scale:self.scale orientation:UIImageOrientationUp];
}

@end
