// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTImagePickerImageUtil.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface GIFInfo ()

@property(strong, nonatomic, readwrite) NSArray<UIImage *> *images;
@property(assign, nonatomic, readwrite) NSTimeInterval interval;

@end

@implementation GIFInfo

- (instancetype)initWithImages:(NSArray<UIImage *> *)images interval:(NSTimeInterval)interval;
{
  self = [super init];
  if (self) {
    self.images = images;
    self.interval = interval;
  }
  return self;
}

@end

@implementation FLTImagePickerImageUtil : NSObject

static UIImage *FLTImagePickerDrawScaledImage(UIImage *imageToScale, double width, double height) {
  UIGraphicsImageRenderer *imageRenderer =
      [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(width, height)
                                             format:imageToScale.imageRendererFormat];
  return [imageRenderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
    CGContextRef cgContext = rendererContext.CGContext;

    // Flip vertically to translate between UIKit and Quartz.
    CGContextTranslateCTM(cgContext, 0, height);
    CGContextScaleCTM(cgContext, 1, -1);
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height), imageToScale.CGImage);
  }];
}

+ (UIImage *)scaledImage:(UIImage *)image
                maxWidth:(NSNumber *)maxWidth
               maxHeight:(NSNumber *)maxHeight
     isMetadataAvailable:(BOOL)isMetadataAvailable {
  double originalWidth = image.size.width;
  double originalHeight = image.size.height;

  BOOL hasMaxWidth = maxWidth != nil;
  BOOL hasMaxHeight = maxHeight != nil;

  if ((originalWidth == maxWidth.doubleValue && originalHeight == maxHeight.doubleValue) ||
      (!hasMaxWidth && !hasMaxHeight)) {
    // Nothing to scale.
    return image;
  }

  double aspectRatio = originalWidth / originalHeight;

  double width = hasMaxWidth ? MIN(round([maxWidth doubleValue]), originalWidth) : originalWidth;
  double height =
      hasMaxHeight ? MIN(round([maxHeight doubleValue]), originalHeight) : originalHeight;

  bool shouldDownscaleWidth = hasMaxWidth && [maxWidth doubleValue] < originalWidth;
  bool shouldDownscaleHeight = hasMaxHeight && [maxHeight doubleValue] < originalHeight;
  bool shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight;

  if (shouldDownscale) {
    double widthForMaxHeight = height * aspectRatio;
    double heightForMaxWidth = width / aspectRatio;

    if (heightForMaxWidth > height) {
      width = round(widthForMaxHeight);
    } else {
      height = round(heightForMaxWidth);
    }
  }

  if (!isMetadataAvailable) {
    UIImage *imageToScale = [UIImage imageWithCGImage:image.CGImage
                                                scale:1
                                          orientation:image.imageOrientation];
    return FLTImagePickerDrawScaledImage(imageToScale, width, height);
  }

  // Scaling the image always rotate itself based on the current imageOrientation of the original
  // Image. Set to orientationUp for the orignal image before scaling, so the scaled image doesn't
  // mess up with the pixels.
  UIImage *imageToScale = [UIImage imageWithCGImage:image.CGImage
                                              scale:1
                                        orientation:UIImageOrientationUp];

  // The image orientation is manually set to UIImageOrientationUp which swapped the aspect ratio in
  // some scenarios. For example, when the original image has orientation left, the horizontal
  // pixels should be scaled to `width` and the vertical pixels should be scaled to `height`. After
  // setting the orientation to up, we end up scaling the horizontal pixels to `height` and vertical
  // to `width`. Below swap will solve this issue.
  if ([image imageOrientation] == UIImageOrientationLeft ||
      [image imageOrientation] == UIImageOrientationRight ||
      [image imageOrientation] == UIImageOrientationLeftMirrored ||
      [image imageOrientation] == UIImageOrientationRightMirrored) {
    double temp = width;
    width = height;
    height = temp;
  }
  return FLTImagePickerDrawScaledImage(imageToScale, width, height);
}

+ (GIFInfo *)scaledGIFImage:(NSData *)data
                   maxWidth:(NSNumber *)maxWidth
                  maxHeight:(NSNumber *)maxHeight {
  NSMutableDictionary<NSString *, id> *options = [NSMutableDictionary dictionary];
  options[(NSString *)kCGImageSourceShouldCache] = @YES;
  options[(NSString *)kCGImageSourceTypeIdentifierHint] = (NSString *)kUTTypeGIF;

  CGImageSourceRef imageSource =
      CGImageSourceCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef)options);

  size_t numberOfFrames = CGImageSourceGetCount(imageSource);
  NSMutableArray<UIImage *> *images = [NSMutableArray arrayWithCapacity:numberOfFrames];

  NSTimeInterval interval = 0.0;
  for (size_t index = 0; index < numberOfFrames; index++) {
    CGImageRef imageRef =
        CGImageSourceCreateImageAtIndex(imageSource, index, (__bridge CFDictionaryRef)options);

    NSDictionary *properties = (NSDictionary *)CFBridgingRelease(
        CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL));
    NSDictionary *gifProperties = properties[(NSString *)kCGImagePropertyGIFDictionary];

    NSNumber *delay = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delay == nil) {
      delay = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
    }

    if (interval == 0.0) {
      interval = [delay doubleValue];
    }

    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    image = [self scaledImage:image maxWidth:maxWidth maxHeight:maxHeight isMetadataAvailable:YES];

    [images addObject:image];

    CGImageRelease(imageRef);
  }

  CFRelease(imageSource);

  GIFInfo *info = [[GIFInfo alloc] initWithImages:images interval:interval];

  return info;
}

@end
