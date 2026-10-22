// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/image_picker_ios/FIPPickerSeams.h"

@implementation FIPDefaultCameraAvailability
- (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)sourceType {
  return [UIImagePickerController isSourceTypeAvailable:sourceType];
}

- (BOOL)isCameraDeviceAvailable:(UIImagePickerControllerCameraDevice)cameraDevice {
  return [UIImagePickerController isCameraDeviceAvailable:cameraDevice];
}
@end

@implementation FIPDefaultCameraPermissionChecker
- (AVAuthorizationStatus)authorizationStatusForMediaType:(AVMediaType)mediaType {
  return [AVCaptureDevice authorizationStatusForMediaType:mediaType];
}

- (void)requestAccessForMediaType:(AVMediaType)mediaType
                completionHandler:(void (^)(BOOL granted))handler {
  [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:handler];
}
@end

@implementation FIPDefaultPhotoLibraryPermissionChecker
- (PHAuthorizationStatus)authorizationStatus {
  return [PHPhotoLibrary authorizationStatus];
}

- (void)requestAuthorization:(void (^)(PHAuthorizationStatus status))handler {
  [PHPhotoLibrary requestAuthorization:handler];
}

- (PHAuthorizationStatus)authorizationStatusForAccessLevel:(PHAccessLevel)accessLevel {
  return [PHPhotoLibrary authorizationStatusForAccessLevel:accessLevel];
}

- (void)requestAuthorizationForAccessLevel:(PHAccessLevel)accessLevel
                                   handler:(void (^)(PHAuthorizationStatus status))handler {
  [PHPhotoLibrary requestAuthorizationForAccessLevel:accessLevel handler:handler];
}
@end

@implementation FIPDefaultPHPickerCreator
- (PHPickerViewController *)makePickerWithConfiguration:(PHPickerConfiguration *)configuration {
  return [[PHPickerViewController alloc] initWithConfiguration:configuration];
}
@end

@interface PHPickerResult (FIPPickerItem) <FIPPickerItem>
@end

@implementation PHPickerResult (FIPPickerItem)
@end

@implementation FIPDefaultImageDataRequester
- (void)requestImageDataAndOrientationForAsset:(PHAsset *)asset
                                       options:(nullable PHImageRequestOptions *)options
                                 resultHandler:
                                     (void (^)(NSData *_Nullable imageData,
                                               NSString *_Nullable dataUTI,
                                               CGImagePropertyOrientation orientation,
                                               NSDictionary *_Nullable info))resultHandler {
  [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset
                                                                  options:options
                                                            resultHandler:resultHandler];
}
@end

@implementation FIPDefaultRecentAssetsFetcher
- (NSArray<PHAsset *> *)fetchAssetsWithOptions:(PHFetchOptions *)options {
  PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithOptions:options];
  return [result
      objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]];
}
@end

@implementation FIPDefaultThumbnailRequester
- (void)requestImageForAsset:(PHAsset *)asset
                  targetSize:(CGSize)targetSize
                 contentMode:(PHImageContentMode)contentMode
                     options:(nullable PHImageRequestOptions *)options
               resultHandler:(void (^)(UIImage *_Nullable result,
                                       NSDictionary *_Nullable info))resultHandler {
  [[PHImageManager defaultManager] requestImageForAsset:asset
                                             targetSize:targetSize
                                            contentMode:contentMode
                                                options:options
                                          resultHandler:resultHandler];
}
@end
