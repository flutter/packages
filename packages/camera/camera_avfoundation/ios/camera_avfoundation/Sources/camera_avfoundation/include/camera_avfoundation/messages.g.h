// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.4.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import <Foundation/Foundation.h>

@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FCPPlatformCameraLensDirection) {
  /// Front facing camera (a user looking at the screen is seen by the camera).
  FCPPlatformCameraLensDirectionFront = 0,
  /// Back facing camera (a user looking at the screen is not seen by the camera).
  FCPPlatformCameraLensDirectionBack = 1,
  /// External camera which may not be mounted to the device.
  FCPPlatformCameraLensDirectionExternal = 2,
};

/// Wrapper for FCPPlatformCameraLensDirection to allow for nullability.
@interface FCPPlatformCameraLensDirectionBox : NSObject
@property(nonatomic, assign) FCPPlatformCameraLensDirection value;
- (instancetype)initWithValue:(FCPPlatformCameraLensDirection)value;
@end

typedef NS_ENUM(NSUInteger, FCPPlatformCameraLensType) {
  /// A built-in wide-angle camera device type.
  FCPPlatformCameraLensTypeWide = 0,
  /// A built-in camera device type with a shorter focal length than a wide-angle camera.
  FCPPlatformCameraLensTypeTelephoto = 1,
  /// A built-in camera device type with a longer focal length than a wide-angle camera.
  FCPPlatformCameraLensTypeUltraWide = 2,
  /// A built-in camera device type that consists of a wide-angle and telephoto camera.
  FCPPlatformCameraLensTypeDual = 3,
  /// A built-in camera device type that consists of two cameras of fixed focal length, one
  /// ultrawide angle and one wide angle.
  FCPPlatformCameraLensTypeDualWide = 4,
  /// A built-in camera device type that consists of three cameras of fixed focal length, one
  /// ultrawide angle, one wide angle, and one telephoto.
  FCPPlatformCameraLensTypeTriple = 5,
  /// A Continuity Camera device type.
  FCPPlatformCameraLensTypeContinuity = 6,
  /// Unknown camera device type.
  FCPPlatformCameraLensTypeUnknown = 7,
};

/// Wrapper for FCPPlatformCameraLensType to allow for nullability.
@interface FCPPlatformCameraLensTypeBox : NSObject
@property(nonatomic, assign) FCPPlatformCameraLensType value;
- (instancetype)initWithValue:(FCPPlatformCameraLensType)value;
@end

typedef NS_ENUM(NSUInteger, FCPPlatformDeviceOrientation) {
  FCPPlatformDeviceOrientationPortraitUp = 0,
  FCPPlatformDeviceOrientationLandscapeLeft = 1,
  FCPPlatformDeviceOrientationPortraitDown = 2,
  FCPPlatformDeviceOrientationLandscapeRight = 3,
};

/// Wrapper for FCPPlatformDeviceOrientation to allow for nullability.
@interface FCPPlatformDeviceOrientationBox : NSObject
@property(nonatomic, assign) FCPPlatformDeviceOrientation value;
- (instancetype)initWithValue:(FCPPlatformDeviceOrientation)value;
@end

typedef NS_ENUM(NSUInteger, FCPPlatformExposureMode) {
  FCPPlatformExposureModeAuto = 0,
  FCPPlatformExposureModeLocked = 1,
};

/// Wrapper for FCPPlatformExposureMode to allow for nullability.
@interface FCPPlatformExposureModeBox : NSObject
@property(nonatomic, assign) FCPPlatformExposureMode value;
- (instancetype)initWithValue:(FCPPlatformExposureMode)value;
@end

typedef NS_ENUM(NSUInteger, FCPPlatformFlashMode) {
  FCPPlatformFlashModeOff = 0,
  FCPPlatformFlashModeAuto = 1,
  FCPPlatformFlashModeAlways = 2,
  FCPPlatformFlashModeTorch = 3,
};

/// Wrapper for FCPPlatformFlashMode to allow for nullability.
@interface FCPPlatformFlashModeBox : NSObject
@property(nonatomic, assign) FCPPlatformFlashMode value;
- (instancetype)initWithValue:(FCPPlatformFlashMode)value;
@end

typedef NS_ENUM(NSUInteger, FCPPlatformFocusMode) {
  FCPPlatformFocusModeAuto = 0,
  FCPPlatformFocusModeLocked = 1,
};

/// Wrapper for FCPPlatformFocusMode to allow for nullability.
@interface FCPPlatformFocusModeBox : NSObject
@property(nonatomic, assign) FCPPlatformFocusMode value;
- (instancetype)initWithValue:(FCPPlatformFocusMode)value;
@end

/// Pigeon version of ImageFileFormat.
typedef NS_ENUM(NSUInteger, FCPPlatformImageFileFormat) {
  FCPPlatformImageFileFormatJpeg = 0,
  FCPPlatformImageFileFormatHeif = 1,
};

/// Wrapper for FCPPlatformImageFileFormat to allow for nullability.
@interface FCPPlatformImageFileFormatBox : NSObject
@property(nonatomic, assign) FCPPlatformImageFileFormat value;
- (instancetype)initWithValue:(FCPPlatformImageFileFormat)value;
@end

typedef NS_ENUM(NSUInteger, FCPPlatformImageFormatGroup) {
  FCPPlatformImageFormatGroupBgra8888 = 0,
  FCPPlatformImageFormatGroupYuv420 = 1,
};

/// Wrapper for FCPPlatformImageFormatGroup to allow for nullability.
@interface FCPPlatformImageFormatGroupBox : NSObject
@property(nonatomic, assign) FCPPlatformImageFormatGroup value;
- (instancetype)initWithValue:(FCPPlatformImageFormatGroup)value;
@end

typedef NS_ENUM(NSUInteger, FCPPlatformResolutionPreset) {
  FCPPlatformResolutionPresetLow = 0,
  FCPPlatformResolutionPresetMedium = 1,
  FCPPlatformResolutionPresetHigh = 2,
  FCPPlatformResolutionPresetVeryHigh = 3,
  FCPPlatformResolutionPresetUltraHigh = 4,
  FCPPlatformResolutionPresetMax = 5,
};

/// Wrapper for FCPPlatformResolutionPreset to allow for nullability.
@interface FCPPlatformResolutionPresetBox : NSObject
@property(nonatomic, assign) FCPPlatformResolutionPreset value;
- (instancetype)initWithValue:(FCPPlatformResolutionPreset)value;
@end

@class FCPPlatformCameraDescription;
@class FCPPlatformCameraState;
@class FCPPlatformMediaSettings;
@class FCPPlatformPoint;
@class FCPPlatformSize;

@interface FCPPlatformCameraDescription : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithName:(NSString *)name
               lensDirection:(FCPPlatformCameraLensDirection)lensDirection
                    lensType:(FCPPlatformCameraLensType)lensType;
/// The name of the camera device.
@property(nonatomic, copy) NSString *name;
/// The direction the camera is facing.
@property(nonatomic, assign) FCPPlatformCameraLensDirection lensDirection;
/// The type of the camera lens.
@property(nonatomic, assign) FCPPlatformCameraLensType lensType;
@end

@interface FCPPlatformCameraState : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithPreviewSize:(FCPPlatformSize *)previewSize
                       exposureMode:(FCPPlatformExposureMode)exposureMode
                          focusMode:(FCPPlatformFocusMode)focusMode
             exposurePointSupported:(BOOL)exposurePointSupported
                focusPointSupported:(BOOL)focusPointSupported;
/// The size of the preview, in pixels.
@property(nonatomic, strong) FCPPlatformSize *previewSize;
/// The default exposure mode
@property(nonatomic, assign) FCPPlatformExposureMode exposureMode;
/// The default focus mode
@property(nonatomic, assign) FCPPlatformFocusMode focusMode;
/// Whether setting exposure points is supported.
@property(nonatomic, assign) BOOL exposurePointSupported;
/// Whether setting focus points is supported.
@property(nonatomic, assign) BOOL focusPointSupported;
@end

@interface FCPPlatformMediaSettings : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithResolutionPreset:(FCPPlatformResolutionPreset)resolutionPreset
                         framesPerSecond:(nullable NSNumber *)framesPerSecond
                            videoBitrate:(nullable NSNumber *)videoBitrate
                            audioBitrate:(nullable NSNumber *)audioBitrate
                             enableAudio:(BOOL)enableAudio;
@property(nonatomic, assign) FCPPlatformResolutionPreset resolutionPreset;
@property(nonatomic, strong, nullable) NSNumber *framesPerSecond;
@property(nonatomic, strong, nullable) NSNumber *videoBitrate;
@property(nonatomic, strong, nullable) NSNumber *audioBitrate;
@property(nonatomic, assign) BOOL enableAudio;
@end

@interface FCPPlatformPoint : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithX:(double)x y:(double)y;
@property(nonatomic, assign) double x;
@property(nonatomic, assign) double y;
@end

@interface FCPPlatformSize : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithWidth:(double)width height:(double)height;
@property(nonatomic, assign) double width;
@property(nonatomic, assign) double height;
@end

/// The codec used by all APIs.
NSObject<FlutterMessageCodec> *FCPGetMessagesCodec(void);

@protocol FCPCameraApi
/// Returns the list of available cameras.
- (void)availableCamerasWithCompletion:(void (^)(NSArray<FCPPlatformCameraDescription *> *_Nullable,
                                                 FlutterError *_Nullable))completion;
/// Create a new camera with the given settings, and returns its ID.
- (void)createCameraWithName:(NSString *)cameraName
                    settings:(FCPPlatformMediaSettings *)settings
                  completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
/// Initializes the camera with the given ID.
- (void)initializeCamera:(NSInteger)cameraId
         withImageFormat:(FCPPlatformImageFormatGroup)imageFormat
              completion:(void (^)(FlutterError *_Nullable))completion;
/// Begins streaming frames from the camera.
- (void)startImageStreamWithCompletion:(void (^)(FlutterError *_Nullable))completion;
/// Stops streaming frames from the camera.
- (void)stopImageStreamWithCompletion:(void (^)(FlutterError *_Nullable))completion;
/// Called by the Dart side of the plugin when it has received the last image
/// frame sent.
///
/// This is used to throttle sending frames across the channel.
- (void)receivedImageStreamDataWithCompletion:(void (^)(FlutterError *_Nullable))completion;
/// Indicates that the given camera is no longer being used on the Dart side,
/// and any associated resources can be cleaned up.
- (void)disposeCamera:(NSInteger)cameraId completion:(void (^)(FlutterError *_Nullable))completion;
/// Locks the camera capture to the current device orientation.
- (void)lockCaptureOrientation:(FCPPlatformDeviceOrientation)orientation
                    completion:(void (^)(FlutterError *_Nullable))completion;
/// Unlocks camera capture orientation, allowing it to automatically adapt to
/// device orientation.
- (void)unlockCaptureOrientationWithCompletion:(void (^)(FlutterError *_Nullable))completion;
/// Takes a picture with the current settings, and returns the path to the
/// resulting file.
- (void)takePictureWithCompletion:(void (^)(NSString *_Nullable,
                                            FlutterError *_Nullable))completion;
/// Does any preprocessing necessary before beginning to record video.
- (void)prepareForVideoRecordingWithCompletion:(void (^)(FlutterError *_Nullable))completion;
/// Begins recording video, optionally enabling streaming to Dart at the same
/// time.
- (void)startVideoRecordingWithStreaming:(BOOL)enableStream
                              completion:(void (^)(FlutterError *_Nullable))completion;
/// Stops recording video, and results the path to the resulting file.
- (void)stopVideoRecordingWithCompletion:(void (^)(NSString *_Nullable,
                                                   FlutterError *_Nullable))completion;
/// Pauses video recording.
- (void)pauseVideoRecordingWithCompletion:(void (^)(FlutterError *_Nullable))completion;
/// Resumes a previously paused video recording.
- (void)resumeVideoRecordingWithCompletion:(void (^)(FlutterError *_Nullable))completion;
/// Switches the camera to the given flash mode.
- (void)setFlashMode:(FCPPlatformFlashMode)mode
          completion:(void (^)(FlutterError *_Nullable))completion;
/// Switches the camera to the given exposure mode.
- (void)setExposureMode:(FCPPlatformExposureMode)mode
             completion:(void (^)(FlutterError *_Nullable))completion;
/// Anchors auto-exposure to the given point in (0,1) coordinate space.
///
/// A null value resets to the default exposure point.
- (void)setExposurePoint:(nullable FCPPlatformPoint *)point
              completion:(void (^)(FlutterError *_Nullable))completion;
/// Returns the minimum exposure offset supported by the camera.
- (void)getMinimumExposureOffset:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
/// Returns the maximum exposure offset supported by the camera.
- (void)getMaximumExposureOffset:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
/// Sets the exposure offset manually to the given value.
- (void)setExposureOffset:(double)offset completion:(void (^)(FlutterError *_Nullable))completion;
/// Switches the camera to the given focus mode.
- (void)setFocusMode:(FCPPlatformFocusMode)mode
          completion:(void (^)(FlutterError *_Nullable))completion;
/// Anchors auto-focus to the given point in (0,1) coordinate space.
///
/// A null value resets to the default focus point.
- (void)setFocusPoint:(nullable FCPPlatformPoint *)point
           completion:(void (^)(FlutterError *_Nullable))completion;
/// Returns the minimum zoom level supported by the camera.
- (void)getMinimumZoomLevel:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
/// Returns the maximum zoom level supported by the camera.
- (void)getMaximumZoomLevel:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
/// Sets the zoom factor.
- (void)setZoomLevel:(double)zoom completion:(void (^)(FlutterError *_Nullable))completion;
/// Pauses streaming of preview frames.
- (void)pausePreviewWithCompletion:(void (^)(FlutterError *_Nullable))completion;
/// Resumes a previously paused preview stream.
- (void)resumePreviewWithCompletion:(void (^)(FlutterError *_Nullable))completion;
/// Changes the camera used while recording video.
///
/// This should only be called while video recording is active.
- (void)updateDescriptionWhileRecordingCameraName:(NSString *)cameraName
                                       completion:(void (^)(FlutterError *_Nullable))completion;
/// Sets the file format used for taking pictures.
- (void)setImageFileFormat:(FCPPlatformImageFileFormat)format
                completion:(void (^)(FlutterError *_Nullable))completion;
@end

extern void SetUpFCPCameraApi(id<FlutterBinaryMessenger> binaryMessenger,
                              NSObject<FCPCameraApi> *_Nullable api);

extern void SetUpFCPCameraApiWithSuffix(id<FlutterBinaryMessenger> binaryMessenger,
                                        NSObject<FCPCameraApi> *_Nullable api,
                                        NSString *messageChannelSuffix);

/// Handler for native callbacks that are not tied to a specific camera ID.
@interface FCPCameraGlobalEventApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                   messageChannelSuffix:(nullable NSString *)messageChannelSuffix;
/// Called when the device's physical orientation changes.
- (void)deviceOrientationChangedOrientation:(FCPPlatformDeviceOrientation)orientation
                                 completion:(void (^)(FlutterError *_Nullable))completion;
@end

/// Handler for native callbacks that are tied to a specific camera ID.
///
/// This is intended to be initialized with the camera ID as a suffix.
@interface FCPCameraEventApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                   messageChannelSuffix:(nullable NSString *)messageChannelSuffix;
/// Called when the camera is inialitized for use.
- (void)initializedWithState:(FCPPlatformCameraState *)initialState
                  completion:(void (^)(FlutterError *_Nullable))completion;
/// Called when an error occurs in the camera.
///
/// This should be used for errors that occur outside of the context of
/// handling a specific HostApi call, such as during streaming.
- (void)reportError:(NSString *)message completion:(void (^)(FlutterError *_Nullable))completion;
@end

NS_ASSUME_NONNULL_END
