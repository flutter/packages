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
