#import "GoogleMapMarkerIconCache.h"

@interface GoogleMapMarkerIconCache  ()

@property(weak, nonatomic) NSObject<FlutterPluginRegistrar>* registrar;
@property(assign, nonatomic) CGFloat screenScale;
@property(strong, nonatomic) NSMutableDictionary* images;

@end

@implementation GoogleMapMarkerIconCache
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                      screenScale:(CGFloat)screenScale {
  self = [super init];
  if (self) {
    NSAssert(screenScale > 0, @"Screen scale must be greater than 0");
    _registrar = registrar;
    _screenScale = screenScale;
    _images = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (UIImage*)getImage:(NSArray *)iconData {
  if ([self.images objectForKey:iconData]) {
    //return self.images[iconData];
  }
  
  UIImage* image = [self extractIconFromData:iconData];
  self.images[iconData] = image;
  
  return image;
}


- (UIImage *)extractIconFromData:(NSArray *)iconData {
  UIImage *image;
  if ([iconData.firstObject isEqualToString:@"defaultMarker"]) {
    CGFloat hue = (iconData.count == 1) ? 0.0f : [iconData[1] doubleValue];
    image = [GMSMarker markerImageWithColor:[UIColor colorWithHue:hue / 360.0
                                                       saturation:1.0
                                                       brightness:0.7
                                                            alpha:1.0]];
  } else if ([iconData.firstObject isEqualToString:@"fromAsset"]) {
    // Deprecated: This message handling for 'fromAsset' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if (iconData.count == 2) {
      image = [UIImage imageNamed:[self.registrar lookupKeyForAsset:iconData[1]]];
    } else {
      image = [UIImage imageNamed:[self.registrar lookupKeyForAsset:iconData[1]
                                                   fromPackage:iconData[2]]];
    }
  } else if ([iconData.firstObject isEqualToString:@"fromAssetImage"]) {
    // Deprecated: This message handling for 'fromAssetImage' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if (iconData.count == 3) {
      image = [UIImage imageNamed:[self.registrar lookupKeyForAsset:iconData[1]]];
      id scaleParam = iconData[2];
      image = [self scaleImage:image by:scaleParam];
    } else {
      NSString *error =
          [NSString stringWithFormat:@"'fromAssetImage' should have exactly 3 arguments. Got: %lu",
                                     (unsigned long)iconData.count];
      NSException *exception = [NSException exceptionWithName:@"InvalidBitmapDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  } else if ([iconData[0] isEqualToString:@"fromBytes"]) {
    // Deprecated: This message handling for 'fromBytes' has been replaced by 'bytes'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if (iconData.count == 2) {
      @try {
        FlutterStandardTypedData *byteData = iconData[1];
        CGFloat mainScreenScale = [[UIScreen mainScreen] scale];
        image = [UIImage imageWithData:[byteData data] scale:mainScreenScale];
      } @catch (NSException *exception) {
        @throw [NSException exceptionWithName:@"InvalidByteDescriptor"
                                       reason:@"Unable to interpret bytes as a valid image."
                                     userInfo:nil];
      }
    } else {
      NSString *error = [NSString
          stringWithFormat:@"fromBytes should have exactly one argument, the bytes. Got: %lu",
                           (unsigned long)iconData.count];
      NSException *exception = [NSException exceptionWithName:@"InvalidByteDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  } else if ([iconData.firstObject isEqualToString:@"asset"]) {
    NSDictionary *assetData = iconData[1];
    if (![assetData isKindOfClass:[NSDictionary class]]) {
      NSException *exception =
          [NSException exceptionWithName:@"InvalidByteDescriptor"
                                  reason:@"Unable to interpret asset, expected a dictionary as the "
                                         @"second parameter."
                                userInfo:nil];
      @throw exception;
    }

    NSString *assetName = assetData[@"assetName"];
    NSString *scalingMode = assetData[@"bitmapScaling"];

    image = [UIImage imageNamed:[self.registrar lookupKeyForAsset:assetName]];

    if ([scalingMode isEqualToString:@"auto"]) {
      NSNumber *width = assetData[@"width"];
      NSNumber *height = assetData[@"height"];
      CGFloat imagePixelRatio = [assetData[@"imagePixelRatio"] doubleValue];

      if (width || height) {
        image = [GoogleMapMarkerIconCache scaledImage:image withScale:self.screenScale];
        image = [GoogleMapMarkerIconCache scaledImage:image
                                                withWidth:width
                                                   height:height
                                              screenScale:self.screenScale];
      } else {
        image = [GoogleMapMarkerIconCache scaledImage:image withScale:imagePixelRatio];
      }
    }
  } else if ([iconData[0] isEqualToString:@"bytes"]) {
    NSDictionary *byteData = iconData[1];
    if (![byteData isKindOfClass:[NSDictionary class]]) {
      NSException *exception =
          [NSException exceptionWithName:@"InvalidByteDescriptor"
                                  reason:@"Unable to interpret bytes, expected a dictionary as the "
                                         @"second parameter."
                                userInfo:nil];
      @throw exception;
    }

    FlutterStandardTypedData *bytes = byteData[@"byteData"];
    NSString *scalingMode = byteData[@"bitmapScaling"];

    @try {
      image = [UIImage imageWithData:[bytes data] scale:self.screenScale];
      if ([scalingMode isEqualToString:@"auto"]) {
        NSNumber *width = byteData[@"width"];
        NSNumber *height = byteData[@"height"];
        CGFloat imagePixelRatio = [byteData[@"imagePixelRatio"] doubleValue];

        if (width || height) {
          // Before scaling the image, image must be in screenScale
          image = [GoogleMapMarkerIconCache scaledImage:image withScale:self.screenScale];
          image = [GoogleMapMarkerIconCache scaledImage:image
                                                  withWidth:width
                                                     height:height
                                                screenScale:self.screenScale];
        } else {
          image = [GoogleMapMarkerIconCache scaledImage:image withScale:imagePixelRatio];
        }
      } else {
        // No scaling, load image from bytes without scale parameter.
        image = [UIImage imageWithData:[bytes data]];
      }
    } @catch (NSException *exception) {
      @throw [NSException exceptionWithName:@"InvalidByteDescriptor"
                                     reason:@"Unable to interpret bytes as a valid image."
                                   userInfo:nil];
    }
  }

  return image;
}

/// This method is deprecated within the context of `BitmapDescriptor.fromBytes` handling in the
/// flutter google_maps_flutter_platform_interface package which has been replaced by 'bytes'
/// message handling. It will be removed when the deprecated image bitmap description type
/// 'fromBytes' is removed from the platform interface.
- (UIImage *)scaleImage:(UIImage *)image by:(id)scaleParam {
  double scale = 1.0;
  if ([scaleParam isKindOfClass:[NSNumber class]]) {
    scale = [scaleParam doubleValue];
  }
  if (fabs(scale - 1) > 1e-3) {
    return [UIImage imageWithCGImage:[image CGImage]
                               scale:(image.scale * scale)
                         orientation:(image.imageOrientation)];
  }
  return image;
}

/// Creates a scaled version of the provided UIImage based on a specified scale factor. If the
/// scale factor differs from the image's current scale by more than a small epsilon-delta (to
/// account for minor floating-point inaccuracies), a new UIImage object is created with the
/// specified scale. Otherwise, the original image is returned.
///
/// @param image The UIImage to scale.
/// @param scale The factor by which to scale the image.
/// @return UIImage Returns the scaled UIImage.
+ (UIImage *)scaledImage:(UIImage *)image withScale:(CGFloat)scale {
  if (fabs(scale - image.scale) > DBL_EPSILON) {
    return [UIImage imageWithCGImage:[image CGImage]
                               scale:scale
                         orientation:(image.imageOrientation)];
  }
  return image;
}

/// Scales an input UIImage to a specified size. If the aspect ratio of the input image
/// closely matches the target size, indicated by a small epsilon-delta, the image's scale
/// property is updated instead of resizing the image. If the aspect ratios differ beyond this
/// threshold, the method redraws the image at the target size.
///
/// @param image The UIImage to scale.
/// @param size The target CGSize to scale the image to.
/// @return UIImage Returns the scaled UIImage.
+ (UIImage *)scaledImage:(UIImage *)image withSize:(CGSize)size {
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
  if ([GoogleMapMarkerIconCache isScalableWithScaleFactorFromSize:originalPixelSize
                                                               toSize:size]) {
    // Scaled image has close to same aspect ratio,
    // updating image scale instead of resizing image.
    CGFloat factor = originalPixelWidth / size.width;
    return [GoogleMapMarkerIconCache scaledImage:image withScale:(image.scale * factor)];
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
    return [GoogleMapMarkerIconCache scaledImage:newImage withScale:image.scale];
  }
}

/// Scales an input UIImage to a specified width and height preserving aspect ratio if both
/// widht and height are not given..
///
/// @param image The UIImage to scale.
/// @param width The target width to scale the image to.
/// @param height The target height to scale the image to.
/// @param screenScale The current screen scale.
/// @return UIImage Returns the scaled UIImage.
+ (UIImage *)scaledImage:(UIImage *)image
               withWidth:(NSNumber *)width
                  height:(NSNumber *)height
             screenScale:(CGFloat)screenScale {
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
  return [GoogleMapMarkerIconCache scaledImage:image withSize:targetSize];
}

+ (BOOL)isScalableWithScaleFactorFromSize:(CGSize)originalSize toSize:(CGSize)targetSize {
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

@end


@interface IconData ()

@property(assign, nonatomic) NSArray* iconData;

@end

@implementation IconData

- (instancetype)init:(NSArray *)iconData {
  self = [super init];
  if (self) {
    _iconData = iconData;
  }
  return self;
}

- (BOOL)isEqual:(nullable id)object {
    if (object == nil) {
        return NO;
    }

    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[IconData class]]) {
        return NO;
    }

  return YES; //[self isEqualToIconData:(IconData *)object];
}

//- (BOOL)isEqualToIconData:(IconData *)iconData {
//  
//    return [self.red isEqualToNumber:color.red] &&
//        [self.green isEqualToNumber:color.green] &&
//        [self.blue isEqualToNumber:color.blue];
//}
//
//- (NSUInteger)hash {
//    return [self.red hash] ^ [self.green hash] ^ [self.blue hash];
//}
@end
