// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/CameraPlugin.h"
#import "./include/camera_avfoundation/CameraPlugin_Test.h"

@import AVFoundation;
@import Flutter;

#import "./include/camera_avfoundation/CameraProperties.h"
#import "./include/camera_avfoundation/FLTCam.h"
#import "./include/camera_avfoundation/FLTCameraPermissionManager.h"
#import "./include/camera_avfoundation/FLTThreadSafeEventChannel.h"
#import "./include/camera_avfoundation/QueueUtils.h"
#import "./include/camera_avfoundation/messages.g.h"

static FlutterError *FlutterErrorFromNSError(NSError *error) {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                             message:error.localizedDescription
                             details:error.domain];
}

@interface CameraPlugin ()
@property(readonly, nonatomic) id<FlutterTextureRegistry> registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(nonatomic) FCPCameraGlobalEventApi *globalEventAPI;
@property(readonly, nonatomic) FLTCameraPermissionManager *permissionManager;
@end

@implementation CameraPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  CameraPlugin *instance = [[CameraPlugin alloc] initWithRegistry:[registrar textures]
                                                        messenger:[registrar messenger]];
  SetUpFCPCameraApi([registrar messenger], instance);
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  return
      [self initWithRegistry:registry
                   messenger:messenger
                   globalAPI:[[FCPCameraGlobalEventApi alloc] initWithBinaryMessenger:messenger]];
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger
                       globalAPI:(FCPCameraGlobalEventApi *)globalAPI {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registry = registry;
  _messenger = messenger;
  _globalEventAPI = globalAPI;
  _captureSessionQueue = dispatch_queue_create("io.flutter.camera.captureSessionQueue", NULL);

  id<FLTPermissionServicing> permissionService = [[FLTDefaultPermissionService alloc] init];
  _permissionManager =
      [[FLTCameraPermissionManager alloc] initWithPermissionService:permissionService];

  dispatch_queue_set_specific(_captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);

  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(orientationChanged:)
                                               name:UIDeviceOrientationDidChangeNotification
                                             object:[UIDevice currentDevice]];
  return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [UIDevice.currentDevice endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)note {
  UIDevice *device = note.object;
  UIDeviceOrientation orientation = device.orientation;

  if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown) {
    // Do not change when oriented flat.
    return;
  }

  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    // `FLTCam::setDeviceOrientation` must be called on capture session queue.
    [weakSelf.camera setDeviceOrientation:orientation];
    // `CameraPlugin::sendDeviceOrientation` can be called on any queue.
    [weakSelf sendDeviceOrientation:orientation];
  });
}

- (void)sendDeviceOrientation:(UIDeviceOrientation)orientation {
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [weakSelf.globalEventAPI
        deviceOrientationChangedOrientation:FCPGetPigeonDeviceOrientationForOrientation(orientation)
                                 completion:^(FlutterError *error){
                                     // Ignore errors; this is essentially a broadcast stream, and
                                     // it's fine if the other end
                                     // doesn't receive the message (e.g., if it doesn't currently
                                     // have a listener set up).
                                 }];
  });
}

#pragma mark FCPCameraApi Implementation

- (void)availableCamerasWithCompletion:
    (nonnull void (^)(NSArray<FCPPlatformCameraDescription *> *_Nullable,
                      FlutterError *_Nullable))completion {
  dispatch_async(self.captureSessionQueue, ^{
    NSMutableArray *discoveryDevices =
        [@[ AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera ]
            mutableCopy];
    if (@available(iOS 13.0, *)) {
      [discoveryDevices addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
    }
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
        discoverySessionWithDeviceTypes:discoveryDevices
                              mediaType:AVMediaTypeVideo
                               position:AVCaptureDevicePositionUnspecified];
    NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
    NSMutableArray<FCPPlatformCameraDescription *> *reply =
        [[NSMutableArray alloc] initWithCapacity:devices.count];
    for (AVCaptureDevice *device in devices) {
      FCPPlatformCameraLensDirection lensFacing;
      switch (device.position) {
        case AVCaptureDevicePositionBack:
          lensFacing = FCPPlatformCameraLensDirectionBack;
          break;
        case AVCaptureDevicePositionFront:
          lensFacing = FCPPlatformCameraLensDirectionFront;
          break;
        case AVCaptureDevicePositionUnspecified:
          lensFacing = FCPPlatformCameraLensDirectionExternal;
          break;
      }
      [reply addObject:[FCPPlatformCameraDescription makeWithName:device.uniqueID
                                                    lensDirection:lensFacing]];
    }
    completion(reply, nil);
  });
}

- (void)createCameraWithName:(nonnull NSString *)cameraName
                    settings:(nonnull FCPPlatformMediaSettings *)settings
                  completion:
                      (nonnull void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  // Create FLTCam only if granted camera access (and audio access if audio is enabled)
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [self->_permissionManager requestCameraPermissionWithCompletionHandler:^(FlutterError *error) {
      typeof(self) strongSelf = weakSelf;
      if (!strongSelf) return;

      if (error) {
        completion(nil, error);
      } else {
        // Request audio permission on `create` call with `enableAudio` argument instead of the
        // `prepareForVideoRecording` call. This is because `prepareForVideoRecording` call is
        // optional, and used as a workaround to fix a missing frame issue on iOS.
        if (settings.enableAudio) {
          // Setup audio capture session only if granted audio access.
          [self->_permissionManager
              requestAudioPermissionWithCompletionHandler:^(FlutterError *error) {
                // cannot use the outter `strongSelf`
                typeof(self) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (error) {
                  completion(nil, error);
                } else {
                  [strongSelf createCameraOnSessionQueueWithName:cameraName
                                                        settings:settings
                                                      completion:completion];
                }
              }];
        } else {
          [strongSelf createCameraOnSessionQueueWithName:cameraName
                                                settings:settings
                                              completion:completion];
        }
      }
    }];
  });
}

- (void)initializeCamera:(NSInteger)cameraId
         withImageFormat:(FCPPlatformImageFormatGroup)imageFormat
              completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf sessionQueueInitializeCamera:cameraId
                           withImageFormat:imageFormat
                                completion:completion];
  });
}

- (void)startImageStreamWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera startImageStreamWithMessenger:weakSelf.messenger];
    completion(nil);
  });
}

- (void)stopImageStreamWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera stopImageStream];
    completion(nil);
  });
}

- (void)receivedImageStreamDataWithCompletion:
    (nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera receivedImageStreamData];
    completion(nil);
  });
}

- (void)takePictureWithCompletion:(nonnull void (^)(NSString *_Nullable,
                                                    FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera captureToFileWithCompletion:completion];
  });
}

- (void)prepareForVideoRecordingWithCompletion:
    (nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setUpCaptureSessionForAudio];
    completion(nil);
  });
}

- (void)startVideoRecordingWithStreaming:(BOOL)enableStream
                              completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;
    [strongSelf.camera
        startVideoRecordingWithCompletion:completion
                    messengerForStreaming:(enableStream ? strongSelf.messenger : nil)];
  });
}

- (void)stopVideoRecordingWithCompletion:(nonnull void (^)(NSString *_Nullable,
                                                           FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera stopVideoRecordingWithCompletion:completion];
  });
}

- (void)pauseVideoRecordingWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera pauseVideoRecording];
    completion(nil);
  });
}

- (void)resumeVideoRecordingWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera resumeVideoRecording];
    completion(nil);
  });
}

- (void)getMinimumZoomLevel:(nonnull void (^)(NSNumber *_Nullable,
                                              FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    completion(@(weakSelf.camera.minimumAvailableZoomFactor), nil);
  });
}

- (void)getMaximumZoomLevel:(nonnull void (^)(NSNumber *_Nullable,
                                              FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    completion(@(weakSelf.camera.maximumAvailableZoomFactor), nil);
  });
}

- (void)setZoomLevel:(double)zoom completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setZoomLevel:zoom withCompletion:completion];
  });
}

- (void)setFlashMode:(FCPPlatformFlashMode)mode
          completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setFlashMode:mode withCompletion:completion];
  });
}

- (void)setExposureMode:(FCPPlatformExposureMode)mode
             completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setExposureMode:mode];
    completion(nil);
  });
}

- (void)setExposurePoint:(nullable FCPPlatformPoint *)point
              completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setExposurePoint:point withCompletion:completion];
  });
}

- (void)getMinimumExposureOffset:(nonnull void (^)(NSNumber *_Nullable,
                                                   FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    completion(@(weakSelf.camera.captureDevice.minExposureTargetBias), nil);
  });
}

- (void)getMaximumExposureOffset:(nonnull void (^)(NSNumber *_Nullable,
                                                   FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    completion(@(weakSelf.camera.captureDevice.maxExposureTargetBias), nil);
  });
}

- (void)setExposureOffset:(double)offset
               completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setExposureOffset:offset];
    completion(nil);
  });
}

- (void)setFocusMode:(FCPPlatformFocusMode)mode
          completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setFocusMode:mode];
    completion(nil);
  });
}

- (void)setFocusPoint:(nullable FCPPlatformPoint *)point
           completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setFocusPoint:point withCompletion:completion];
  });
}

- (void)lockCaptureOrientation:(FCPPlatformDeviceOrientation)orientation
                    completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera lockCaptureOrientation:orientation];
    completion(nil);
  });
}

- (void)unlockCaptureOrientationWithCompletion:
    (nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera unlockCaptureOrientation];
    completion(nil);
  });
}

- (void)pausePreviewWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera pausePreview];
    completion(nil);
  });
}

- (void)resumePreviewWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera resumePreview];
    completion(nil);
  });
}

- (void)setImageFileFormat:(FCPPlatformImageFileFormat)format
                completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setImageFileFormat:format];
    completion(nil);
  });
}

- (void)updateDescriptionWhileRecordingCameraName:(nonnull NSString *)cameraName
                                       completion:
                                           (nonnull void (^)(FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera setDescriptionWhileRecording:cameraName withCompletion:completion];
  });
}

- (void)disposeCamera:(NSInteger)cameraId
           completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  [_registry unregisterTexture:cameraId];
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf.camera close];
    weakSelf.camera = nil;
    completion(nil);
  });
}

#pragma mark Private

// This must be called on captureSessionQueue. It is extracted from
// initializeCamera:withImageFormat:completion: to make it easier to reason about strong/weak
// self pointers.
- (void)sessionQueueInitializeCamera:(NSInteger)cameraId
                     withImageFormat:(FCPPlatformImageFormatGroup)imageFormat
                          completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  [_camera setVideoFormat:FCPGetPixelFormatForPigeonFormat(imageFormat)];

  __weak CameraPlugin *weakSelf = self;
  _camera.onFrameAvailable = ^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;
    if (![strongSelf.camera isPreviewPaused]) {
      FLTEnsureToRunOnMainQueue(^{
        [weakSelf.registry textureFrameAvailable:cameraId];
      });
    }
  };
  _camera.dartAPI = [[FCPCameraEventApi alloc]
      initWithBinaryMessenger:_messenger
         messageChannelSuffix:[NSString stringWithFormat:@"%ld", cameraId]];
  [_camera reportInitializationState];
  [self sendDeviceOrientation:[UIDevice currentDevice].orientation];
  [_camera start];
  completion(nil);
}

- (void)createCameraOnSessionQueueWithName:(NSString *)name
                                  settings:(FCPPlatformMediaSettings *)settings
                                completion:(nonnull void (^)(NSNumber *_Nullable,
                                                             FlutterError *_Nullable))completion {
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.captureSessionQueue, ^{
    [weakSelf sessionQueueCreateCameraWithName:name settings:settings completion:completion];
  });
}

// This must be called on captureSessionQueue. It is extracted from
// initializeCamera:withImageFormat:completion: to make it easier to reason about strong/weak
// self pointers.
- (void)sessionQueueCreateCameraWithName:(NSString *)name
                                settings:(FCPPlatformMediaSettings *)settings
                              completion:(nonnull void (^)(NSNumber *_Nullable,
                                                           FlutterError *_Nullable))completion {
  FLTCamMediaSettingsAVWrapper *mediaSettingsAVWrapper =
      [[FLTCamMediaSettingsAVWrapper alloc] init];

  NSError *error;
  FLTCam *cam = [[FLTCam alloc] initWithCameraName:name
                                     mediaSettings:settings
                            mediaSettingsAVWrapper:mediaSettingsAVWrapper
                                       orientation:[[UIDevice currentDevice] orientation]
                               captureSessionQueue:self.captureSessionQueue
                                             error:&error];

  if (error) {
    completion(nil, FlutterErrorFromNSError(error));
  } else {
    [_camera close];
    _camera = cam;
    __weak typeof(self) weakSelf = self;
    FLTEnsureToRunOnMainQueue(^{
      completion(@([weakSelf.registry registerTexture:cam]), nil);
    });
  }
}

@end
