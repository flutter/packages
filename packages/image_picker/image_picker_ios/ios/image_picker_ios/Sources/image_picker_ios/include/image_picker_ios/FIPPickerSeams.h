// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Camera source and device availability checks.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
NS_SWIFT_NAME(CameraAvailabilityChecking)
@protocol FIPCameraAvailabilityChecking <NSObject>
- (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)sourceType;
- (BOOL)isCameraDeviceAvailable:(UIImagePickerControllerCameraDevice)cameraDevice;
@end

/// Production implementation that forwards to UIImagePickerController.
NS_SWIFT_NAME(DefaultCameraAvailability)
@interface FIPDefaultCameraAvailability : NSObject <FIPCameraAvailabilityChecking>
@end

#pragma mark -

/// Camera authorization status and request-access calls.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
NS_SWIFT_NAME(CameraPermissionChecking)
@protocol FIPCameraPermissionChecking <NSObject>
- (AVAuthorizationStatus)authorizationStatusForMediaType:(AVMediaType)mediaType;
- (void)requestAccessForMediaType:(AVMediaType)mediaType
                completionHandler:(void (^)(BOOL granted))handler;
@end

/// Production implementation that forwards to AVCaptureDevice.
NS_SWIFT_NAME(DefaultCameraPermissionChecker)
@interface FIPDefaultCameraPermissionChecker : NSObject <FIPCameraPermissionChecking>
@end

#pragma mark -

/// Photo library authorization status and request-access calls.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
NS_SWIFT_NAME(PhotoLibraryPermissionChecking)
@protocol FIPPhotoLibraryPermissionChecking <NSObject>
- (PHAuthorizationStatus)authorizationStatus;
- (void)requestAuthorization:(void (^)(PHAuthorizationStatus status))handler;
@end

/// Production implementation that forwards to PHPhotoLibrary.
NS_SWIFT_NAME(DefaultPhotoLibraryPermissionChecker)
@interface FIPDefaultPhotoLibraryPermissionChecker : NSObject <FIPPhotoLibraryPermissionChecking>
@end

#pragma mark -

/// A picked item from PHPicker, wrapping the subset of PHPickerResult used by the plugin.
API_AVAILABLE(ios(14))
NS_SWIFT_NAME(PickerItem)
@protocol FIPPickerItem <NSObject>
@property(nonatomic, readonly) NSItemProvider *itemProvider;
@property(nonatomic, readonly, nullable) NSString *assetIdentifier;
@end

/// Creates PHPickerViewController instances.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
API_AVAILABLE(ios(14))
NS_SWIFT_NAME(PHPickerCreating)
@protocol FIPPHPickerCreating <NSObject>
- (PHPickerViewController *)makePickerWithConfiguration:(PHPickerConfiguration *)configuration
    NS_SWIFT_NAME(makePicker(configuration:));
@end

/// Production implementation that constructs a real PHPickerViewController.
API_AVAILABLE(ios(14))
NS_SWIFT_NAME(DefaultPHPickerCreator)
@interface FIPDefaultPHPickerCreator : NSObject <FIPPHPickerCreating>
@end

NS_ASSUME_NONNULL_END
