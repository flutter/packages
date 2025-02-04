// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMImageUtils.h"
#import "Foundation/Foundation.h"

/// This method is deprecated within the context of `BitmapDescriptor.fromBytes` handling in the
/// flutter google_maps_flutter_platform_interface package which has been replaced by 'bytes'
/// message handling. It will be removed when the deprecated image bitmap description type
/// 'fromBytes' is removed from the platform interface.
static UIImage *scaledImage(UIImage *image, double scale);

/// Creates a scaled version of the provided UIImage based on a specified scale factor. If the
/// scale factor differs from the image's current scale by more than a small epsilon-delta (to
/// account for minor floating-point inaccuracies), a new UIImage object is created with the
/// specified scale. Otherwise, the original image is returned.
///
/// @param image The UIImage to scale.
/// @param scale The factor by which to scale the image.
/// @return UIImage Returns the scaled UIImage.
static UIImage *scaledImageWithScale(UIImage *image, CGFloat scale);

/// Scales an input UIImage to a specified size. If the aspect ratio of the input image
/// closely matches the target size, indicated by a small epsilon-delta, the image's scale
/// property is updated instead of resizing the image. If the aspect ratios differ beyond this
/// threshold, the method redraws the image at the target size.
///
/// @param image The UIImage to scale.
/// @param size The target CGSize to scale the image to.
/// @return UIImage Returns the scaled UIImage.
static UIImage *scaledImageWithSize(UIImage *image, CGSize size);

/// Scales an input UIImage to a specified width and height preserving aspect ratio if both
/// widht and height are not given..
///
/// @param image The UIImage to scale.
/// @param width The target width to scale the image to.
/// @param height The target height to scale the image to.
/// @param screenScale The current screen scale.
/// @return UIImage Returns the scaled UIImage.
static UIImage *scaledImageWithWidthHeight(UIImage *image, NSNumber *width, NSNumber *height,
                                           CGFloat screenScale);

UIImage *FGMIconFromBitmap(FGMPlatformBitmap *platformBitmap,
                           NSObject<FlutterPluginRegistrar> *registrar, CGFloat screenScale) {
  assert(screenScale > 0 && "Screen scale must be greater than 0");
  // See comment in messages.dart for why this is so loosely typed. See also
  // https://github.com/flutter/flutter/issues/117819.
  id bitmap = platformBitmap.bitmap;
  UIImage *image;
  if ([bitmap isKindOfClass:[FGMPlatformBitmapDefaultMarker class]]) {
    FGMPlatformBitmapDefaultMarker *bitmapDefaultMarker = bitmap;
    CGFloat hue = bitmapDefaultMarker.hue.doubleValue;
    image = [GMSMarker markerImageWithColor:[UIColor colorWithHue:hue / 360.0
                                                       saturation:1.0
                                                       brightness:0.7
                                                            alpha:1.0]];
  } else if ([bitmap isKindOfClass:[FGMPlatformBitmapAsset class]]) {
    // Deprecated: This message handling for 'fromAsset' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    FGMPlatformBitmapAsset *bitmapAsset = bitmap;
    if (bitmapAsset.pkg) {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapAsset.name
                                                   fromPackage:bitmapAsset.pkg]];
    } else {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapAsset.name]];
    }
  } else if ([bitmap isKindOfClass:[FGMPlatformBitmapAssetImage class]]) {
    // Deprecated: This message handling for 'fromAssetImage' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    FGMPlatformBitmapAssetImage *bitmapAssetImage = bitmap;
    image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapAssetImage.name]];
    image = scaledImage(image, bitmapAssetImage.scale);
  } else if ([bitmap isKindOfClass:[FGMPlatformBitmapBytes class]]) {
    // Deprecated: This message handling for 'fromBytes' has been replaced by 'bytes'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    FGMPlatformBitmapBytes *bitmapBytes = bitmap;
    @try {
      CGFloat mainScreenScale = [[UIScreen mainScreen] scale];
      image = [UIImage imageWithData:bitmapBytes.byteData.data scale:mainScreenScale];
    } @catch (NSException *exception) {
      @throw [NSException exceptionWithName:@"InvalidByteDescriptor"
                                     reason:@"Unable to interpret bytes as a valid image."
                                   userInfo:nil];
    }
  } else if ([bitmap isKindOfClass:[FGMPlatformBitmapAssetMap class]]) {
    FGMPlatformBitmapAssetMap *bitmapAssetMap = bitmap;

    image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapAssetMap.assetName]];

    if (bitmapAssetMap.bitmapScaling == FGMPlatformMapBitmapScalingAuto) {
      NSNumber *width = bitmapAssetMap.width;
      NSNumber *height = bitmapAssetMap.height;
      if (width || height) {
        image = scaledImageWithScale(image, screenScale);
        image = scaledImageWithWidthHeight(image, width, height, screenScale);
      } else {
        image = scaledImageWithScale(image, bitmapAssetMap.imagePixelRatio);
      }
    }
  } else if ([bitmap isKindOfClass:[FGMPlatformBitmapBytesMap class]]) {
    FGMPlatformBitmapBytesMap *bitmapBytesMap = bitmap;
    FlutterStandardTypedData *bytes = bitmapBytesMap.byteData;

    @try {
      image = [UIImage imageWithData:bytes.data scale:screenScale];
      if (bitmapBytesMap.bitmapScaling == FGMPlatformMapBitmapScalingAuto) {
        NSNumber *width = bitmapBytesMap.width;
        NSNumber *height = bitmapBytesMap.height;

        if (width || height) {
          // Before scaling the image, image must be in screenScale.
          image = scaledImageWithScale(image, screenScale);
          image = scaledImageWithWidthHeight(image, width, height, screenScale);
        } else {
          image = scaledImageWithScale(image, bitmapBytesMap.imagePixelRatio);
        }
      } else {
        // No scaling, load image from bytes without scale parameter.
        image = [UIImage imageWithData:bytes.data];
      }
    } @catch (NSException *exception) {
      @throw [NSException exceptionWithName:@"InvalidByteDescriptor"
                                     reason:@"Unable to interpret bytes as a valid image."
                                   userInfo:nil];
    }
  }

  return image;
}

UIImage *scaledImage(UIImage *image, double scale) {
  if (fabs(scale - 1) > 1e-3) {
    return [UIImage imageWithCGImage:[image CGImage]
                               scale:(image.scale * scale)
                         orientation:(image.imageOrientation)];
  }
  return image;
}

UIImage *scaledImageWithScale(UIImage *image, CGFloat scale) {
  if (fabs(scale - image.scale) > DBL_EPSILON) {
    return [UIImage imageWithCGImage:[image CGImage]
                               scale:scale
                         orientation:(image.imageOrientation)];
  }
  return image;
}

UIImage *scaledImageWithSize(UIImage *image, CGSize size) {
  CGFloat originalPixelWidth = image.size.width * image.scale;
  CGFloat originalPixelHeight = image.size.height * image.scale;

  // Return original image if either original image size or target size is so small that
  // image cannot be resized or displayed.
  if (originalPixelWidth <= 0 || originalPixelHeight <= 0 || size.width <= 0 || size.height <= 0) {
    return image;
  }

  // Check if the image's size, accounting for scale, matches the target size.
  if (fabs(originalPixelWidth - size.width) <= DBL_EPSILON &&
      fabs(originalPixelHeight - size.height) <= DBL_EPSILON) {
    // No need for resizing, return the original image
    return image;
  }

  // Check if the aspect ratios are approximately equal.
  CGSize originalPixelSize = CGSizeMake(originalPixelWidth, originalPixelHeight);
  if (FGMIsScalableWithScaleFactorFromSize(originalPixelSize, size)) {
    // Scaled image has close to same aspect ratio,
    // updating image scale instead of resizing image.
    CGFloat factor = originalPixelWidth / size.width;
    return scaledImageWithScale(image, image.scale * factor);
  } else {
    // Aspect ratios differ significantly, resize the image.
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = 1.0;
    format.opaque = NO;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size
                                                                               format:format];
    UIImage *newImage =
        [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull context) {
          [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        }];

    // Return image with proper scaling.
    return scaledImageWithScale(newImage, image.scale);
  }
}

UIImage *scaledImageWithWidthHeight(UIImage *image, NSNumber *width, NSNumber *height,
                                    CGFloat screenScale) {
  if (!width && !height) {
    return image;
  }

  CGFloat targetWidth = width ? width.doubleValue : image.size.width;
  CGFloat targetHeight = height ? height.doubleValue : image.size.height;

  if (width && !height) {
    // Calculate height based on aspect ratio if only width is provided.
    double aspectRatio = image.size.height / image.size.width;
    targetHeight = round(targetWidth * aspectRatio);
  } else if (!width && height) {
    // Calculate width based on aspect ratio if only height is provided.
    double aspectRatio = image.size.width / image.size.height;
    targetWidth = round(targetHeight * aspectRatio);
  }

  CGSize targetSize =
      CGSizeMake(round(targetWidth * screenScale), round(targetHeight * screenScale));
  return scaledImageWithSize(image, targetSize);
}

BOOL FGMIsScalableWithScaleFactorFromSize(CGSize originalSize, CGSize targetSize) {
  // Select the scaling factor based on the longer side to have good precision.
  CGFloat scaleFactor = (originalSize.width > originalSize.height)
                            ? (targetSize.width / originalSize.width)
                            : (targetSize.height / originalSize.height);

  // Calculate the scaled dimensions.
  CGFloat scaledWidth = originalSize.width * scaleFactor;
  CGFloat scaledHeight = originalSize.height * scaleFactor;

  // Check if the scaled dimensions are within a one-pixel
  // threshold of the target dimensions.
  BOOL widthWithinThreshold = fabs(scaledWidth - targetSize.width) <= 1.0;
  BOOL heightWithinThreshold = fabs(scaledHeight - targetSize.height) <= 1.0;

  // The image is considered scalable with scale factor
  // if both dimensions are within the threshold.
  return widthWithinThreshold && heightWithinThreshold;
}
