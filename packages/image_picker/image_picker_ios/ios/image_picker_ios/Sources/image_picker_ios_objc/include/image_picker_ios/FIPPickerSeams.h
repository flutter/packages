// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A picked item from PHPicker, wrapping the subset of PHPickerResult used by the plugin.
API_AVAILABLE(ios(14))
NS_SWIFT_NAME(PickerItem)
@protocol FIPPickerItem <NSObject>
@property(nonatomic, readonly) NSItemProvider *itemProvider;
@property(nonatomic, readonly, nullable) NSString *assetIdentifier;
@end

#pragma mark -

/// Requests image bytes for a `PHAsset`.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
NS_SWIFT_NAME(ImageDataRequesting)
@protocol FIPImageDataRequesting <NSObject>
- (void)requestImageDataAndOrientationForAsset:(PHAsset *)asset
                                       options:(nullable PHImageRequestOptions *)options
                                 resultHandler:(void (^)(NSData *_Nullable imageData,
                                                         NSString *_Nullable dataUTI,
                                                         CGImagePropertyOrientation orientation,
                                                         NSDictionary *_Nullable info))resultHandler
    NS_SWIFT_NAME(requestImageDataAndOrientation(for:options:resultHandler:));
@end

/// Production implementation that forwards to `PHImageManager`.
NS_SWIFT_NAME(DefaultImageDataRequester)
@interface FIPDefaultImageDataRequester : NSObject <FIPImageDataRequesting>
@end

NS_ASSUME_NONNULL_END
