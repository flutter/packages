// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCam.h"
#import "./include/camera_avfoundation/FLTCam_Test.h"

@import CoreMotion;
@import Flutter;
#import <libkern/OSAtomic.h>

#import "./include/camera_avfoundation/FLTCaptureConnection.h"
#import "./include/camera_avfoundation/FLTCaptureDevice.h"
#import "./include/camera_avfoundation/FLTDeviceOrientationProviding.h"
#import "./include/camera_avfoundation/FLTEventChannel.h"
#import "./include/camera_avfoundation/FLTFormatUtils.h"
#import "./include/camera_avfoundation/FLTImageStreamHandler.h"
#import "./include/camera_avfoundation/FLTSavePhotoDelegate.h"
#import "./include/camera_avfoundation/FLTThreadSafeEventChannel.h"
#import "./include/camera_avfoundation/QueueUtils.h"
#import "./include/camera_avfoundation/messages.g.h"

static FlutterError *FlutterErrorFromNSError(NSError *error) {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                             message:error.localizedDescription
                             details:error.domain];
}

@interface FLTCam () <AVCaptureVideoDataOutputSampleBufferDelegate,
                      AVCaptureAudioDataOutputSampleBufferDelegate>

@property(readonly, nonatomic) int64_t textureId;
@property(readonly, nonatomic) FCPPlatformMediaSettings *mediaSettings;
@property(readonly, nonatomic) FLTCamMediaSettingsAVWrapper *mediaSettingsAVWrapper;
@property(readonly, nonatomic) NSObject<FLTCaptureSession> *videoCaptureSession;
@property(readonly, nonatomic) NSObject<FLTCaptureSession> *audioCaptureSession;

@property(readonly, nonatomic) NSObject<FLTCaptureInput> *captureVideoInput;
@property(readonly, nonatomic) CGSize captureSize;
@property(strong, nonatomic)
    NSObject<FLTAssetWriterInputPixelBufferAdaptor> *assetWriterPixelBufferAdaptor;
@property(strong, nonatomic) AVCaptureVideoDataOutput *videoOutput;
@property(strong, nonatomic) AVCaptureAudioDataOutput *audioOutput;
@property(strong, nonatomic) NSString *videoRecordingPath;
@property(assign, nonatomic) BOOL isAudioSetup;

@property(assign, nonatomic) UIDeviceOrientation lockedCaptureOrientation;
@property(nonatomic) CMMotionManager *motionManager;
/// All FLTCam's state access and capture session related operations should be on run on this queue.
@property(strong, nonatomic) dispatch_queue_t captureSessionQueue;
/// The queue on which captured photos (not videos) are written to disk.
/// Videos are written to disk by `videoAdaptor` on an internal queue managed by AVFoundation.
@property(strong, nonatomic) dispatch_queue_t photoIOQueue;
@property(assign, nonatomic) UIDeviceOrientation deviceOrientation;
/// A wrapper for CMVideoFormatDescriptionGetDimensions.
/// Allows for alternate implementations in tests.
@property(nonatomic, copy) VideoDimensionsForFormat videoDimensionsForFormat;
/// A wrapper for AVCaptureDevice creation to allow for dependency injection in tests.
@property(nonatomic, copy) CaptureDeviceFactory captureDeviceFactory;
@property(nonatomic, copy) AudioCaptureDeviceFactory audioCaptureDeviceFactory;
@property(readonly, nonatomic) NSObject<FLTCaptureDeviceInputFactory> *captureDeviceInputFactory;
@property(assign, nonatomic) FCPPlatformExposureMode exposureMode;
@property(assign, nonatomic) FCPPlatformFocusMode focusMode;
@property(assign, nonatomic) FCPPlatformFlashMode flashMode;
@property(readonly, nonatomic) NSObject<FLTDeviceOrientationProviding> *deviceOrientationProvider;
@property(nonatomic, copy) AssetWriterFactory assetWriterFactory;
@property(nonatomic, copy) InputPixelBufferAdaptorFactory inputPixelBufferAdaptorFactory;
/// Reports the given error message to the Dart side of the plugin.
///
/// Can be called from any thread.
- (void)reportErrorMessage:(NSString *)errorMessage;
@end

@implementation FLTCam

NSString *const errorMethod = @"error";

- (instancetype)initWithConfiguration:(nonnull FLTCamConfiguration *)configuration
                                error:(NSError **)error {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _mediaSettings = configuration.mediaSettings;
  _mediaSettingsAVWrapper = configuration.mediaSettingsWrapper;

  _captureSessionQueue = configuration.captureSessionQueue;
  _photoIOQueue = dispatch_queue_create("io.flutter.camera.photoIOQueue", NULL);
  _videoCaptureSession = configuration.videoCaptureSession;
  _audioCaptureSession = configuration.audioCaptureSession;
  _captureDeviceFactory = configuration.captureDeviceFactory;
  _audioCaptureDeviceFactory = configuration.audioCaptureDeviceFactory;
  _captureDevice = _captureDeviceFactory(configuration.initialCameraName);
  _captureDeviceInputFactory = configuration.captureDeviceInputFactory;
  _videoDimensionsForFormat = configuration.videoDimensionsForFormat;
  _flashMode = _captureDevice.hasFlash ? FCPPlatformFlashModeAuto : FCPPlatformFlashModeOff;
  _exposureMode = FCPPlatformExposureModeAuto;
  _focusMode = FCPPlatformFocusModeAuto;
  _lockedCaptureOrientation = UIDeviceOrientationUnknown;
  _deviceOrientation = configuration.orientation;
  _videoFormat = kCVPixelFormatType_32BGRA;
  _inProgressSavePhotoDelegates = [NSMutableDictionary dictionary];
  _fileFormat = FCPPlatformImageFileFormatJpeg;
  _videoCaptureSession.automaticallyConfiguresApplicationAudioSession = NO;
  _audioCaptureSession.automaticallyConfiguresApplicationAudioSession = NO;
  _assetWriterFactory = configuration.assetWriterFactory;
  _inputPixelBufferAdaptorFactory = configuration.inputPixelBufferAdaptorFactory;

  NSError *localError = nil;
  AVCaptureConnection *connection = [self createConnection:&localError];
  if (localError) {
    if (error != nil) {
      *error = localError;
    }
    return nil;
  }

  [_videoCaptureSession addInputWithNoConnections:_captureVideoInput];
  [_videoCaptureSession addOutputWithNoConnections:_captureVideoOutput.avOutput];
  [_videoCaptureSession addConnection:connection];

  _capturePhotoOutput =
      [[FLTDefaultCapturePhotoOutput alloc] initWithPhotoOutput:[AVCapturePhotoOutput new]];
  [_capturePhotoOutput setHighResolutionCaptureEnabled:YES];
  [_videoCaptureSession addOutput:_capturePhotoOutput.avOutput];

  _motionManager = [[CMMotionManager alloc] init];
  [_motionManager startAccelerometerUpdates];

  _deviceOrientationProvider = configuration.deviceOrientationProvider;

  if (_mediaSettings.framesPerSecond) {
    // The frame rate can be changed only on a locked for configuration device.
    if ([_mediaSettingsAVWrapper lockDevice:_captureDevice error:error]) {
      [_mediaSettingsAVWrapper beginConfigurationForSession:_videoCaptureSession];

      // Possible values for presets are hard-coded in FLT interface having
      // corresponding AVCaptureSessionPreset counterparts.
      // If _resolutionPreset is not supported by camera there is
      // fallback to lower resolution presets.
      // If none can be selected there is error condition.
      if (![self setCaptureSessionPreset:_mediaSettings.resolutionPreset withError:error]) {
        [_videoCaptureSession commitConfiguration];
        [_captureDevice unlockForConfiguration];
        return nil;
      }

      FLTSelectBestFormatForRequestedFrameRate(_captureDevice, _mediaSettings,
                                               _videoDimensionsForFormat);

      // Set frame rate with 1/10 precision allowing not integral values.
      int fpsNominator = floor([_mediaSettings.framesPerSecond doubleValue] * 10.0);
      CMTime duration = CMTimeMake(10, fpsNominator);

      [_mediaSettingsAVWrapper setMinFrameDuration:duration onDevice:_captureDevice];
      [_mediaSettingsAVWrapper setMaxFrameDuration:duration onDevice:_captureDevice];

      [_mediaSettingsAVWrapper commitConfigurationForSession:_videoCaptureSession];
      [_mediaSettingsAVWrapper unlockDevice:_captureDevice];
    } else {
      return nil;
    }
  } else {
    // If the frame rate is not important fall to a less restrictive
    // behavior (no configuration locking).
    if (![self setCaptureSessionPreset:_mediaSettings.resolutionPreset withError:error]) {
      return nil;
    }
  }

  [self updateOrientation];

  return self;
}

- (AVCaptureConnection *)createConnection:(NSError **)error {
  // Setup video capture input.
  _captureVideoInput = [_captureDeviceInputFactory deviceInputWithDevice:_captureDevice
                                                                   error:error];

  // Test the return value of the `deviceInputWithDevice` method to see whether an error occurred.
  // Don’t just test to see whether the error pointer was set to point to an error.
  // See:
  // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/ErrorHandling/ErrorHandling.html
  if (!_captureVideoInput) {
    return nil;
  }

  // Setup video capture output.
  _captureVideoOutput = [[FLTDefaultCaptureVideoDataOutput alloc]
      initWithCaptureVideoOutput:[AVCaptureVideoDataOutput new]];
  _captureVideoOutput.videoSettings =
      @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(_videoFormat)};
  [_captureVideoOutput setAlwaysDiscardsLateVideoFrames:YES];
  [_captureVideoOutput setSampleBufferDelegate:self queue:_captureSessionQueue];

  // Setup video capture connection.
  AVCaptureConnection *connection =
      [AVCaptureConnection connectionWithInputPorts:_captureVideoInput.ports
                                             output:_captureVideoOutput.avOutput];
  if ([_captureDevice position] == AVCaptureDevicePositionFront) {
    connection.videoMirrored = YES;
  }

  return connection;
}

- (void)reportInitializationState {
  // Get all the state on the current thread, not the main thread.
  FCPPlatformCameraState *state = [FCPPlatformCameraState
         makeWithPreviewSize:[FCPPlatformSize makeWithWidth:self.previewSize.width
                                                     height:self.previewSize.height]
                exposureMode:self.exposureMode
                   focusMode:self.focusMode
      exposurePointSupported:self.captureDevice.exposurePointOfInterestSupported
         focusPointSupported:self.captureDevice.focusPointOfInterestSupported];

  __weak typeof(self) weakSelf = self;
  FLTEnsureToRunOnMainQueue(^{
    [weakSelf.dartAPI initializedWithState:state
                                completion:^(FlutterError *error){
                                    // Ignore any errors, as this is just an event broadcast.
                                }];
  });
}

- (void)start {
  [_videoCaptureSession startRunning];
  [_audioCaptureSession startRunning];
}

- (void)stop {
  [_videoCaptureSession stopRunning];
  [_audioCaptureSession stopRunning];
}

- (void)setVideoFormat:(OSType)videoFormat {
  _videoFormat = videoFormat;
  _captureVideoOutput.videoSettings =
      @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(videoFormat)};
}

- (void)setImageFileFormat:(FCPPlatformImageFileFormat)fileFormat {
  _fileFormat = fileFormat;
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
  if (_deviceOrientation == orientation) {
    return;
  }

  _deviceOrientation = orientation;
  [self updateOrientation];
}

- (void)updateOrientation {
  if (_isRecording) {
    return;
  }

  UIDeviceOrientation orientation = (_lockedCaptureOrientation != UIDeviceOrientationUnknown)
                                        ? _lockedCaptureOrientation
                                        : _deviceOrientation;

  [self updateOrientation:orientation forCaptureOutput:_capturePhotoOutput];
  [self updateOrientation:orientation forCaptureOutput:_captureVideoOutput];
}

- (void)updateOrientation:(UIDeviceOrientation)orientation
         forCaptureOutput:(NSObject<FLTCaptureOutput> *)captureOutput {
  if (!captureOutput) {
    return;
  }

  NSObject<FLTCaptureConnection> *connection =
      [captureOutput connectionWithMediaType:AVMediaTypeVideo];
  if (connection && connection.isVideoOrientationSupported) {
    connection.videoOrientation = [self getVideoOrientationForDeviceOrientation:orientation];
  }
}

- (void)captureToFileWithCompletion:(void (^)(NSString *_Nullable,
                                              FlutterError *_Nullable))completion {
  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];

  if (self.mediaSettings.resolutionPreset == FCPPlatformResolutionPresetMax) {
    [settings setHighResolutionPhotoEnabled:YES];
  }

  NSString *extension;

  BOOL isHEVCCodecAvailable =
      [self.capturePhotoOutput.availablePhotoCodecTypes containsObject:AVVideoCodecTypeHEVC];

  if (_fileFormat == FCPPlatformImageFileFormatHeif && isHEVCCodecAvailable) {
    settings =
        [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey : AVVideoCodecTypeHEVC}];
    extension = @"heif";
  } else {
    extension = @"jpg";
  }

  // If the flash is in torch mode, no capture-level flash setting is needed.
  if (self.flashMode != FCPPlatformFlashModeTorch) {
    [settings setFlashMode:FCPGetAVCaptureFlashModeForPigeonFlashMode(self.flashMode)];
  }
  NSError *error;
  NSString *path = [self getTemporaryFilePathWithExtension:extension
                                                 subfolder:@"pictures"
                                                    prefix:@"CAP_"
                                                     error:&error];
  if (error) {
    completion(nil, FlutterErrorFromNSError(error));
    return;
  }

  __weak typeof(self) weakSelf = self;
  FLTSavePhotoDelegate *savePhotoDelegate = [[FLTSavePhotoDelegate alloc]
           initWithPath:path
                ioQueue:self.photoIOQueue
      completionHandler:^(NSString *_Nullable path, NSError *_Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        dispatch_async(strongSelf.captureSessionQueue, ^{
          // cannot use the outter `strongSelf`
          typeof(self) strongSelf = weakSelf;
          if (!strongSelf) return;
          [strongSelf.inProgressSavePhotoDelegates removeObjectForKey:@(settings.uniqueID)];
        });

        if (error) {
          completion(nil, FlutterErrorFromNSError(error));
        } else {
          NSAssert(path, @"Path must not be nil if no error.");
          completion(path, nil);
        }
      }];

  NSAssert(dispatch_get_specific(FLTCaptureSessionQueueSpecific),
           @"save photo delegate references must be updated on the capture session queue");
  self.inProgressSavePhotoDelegates[@(settings.uniqueID)] = savePhotoDelegate;
  [self.capturePhotoOutput capturePhotoWithSettings:settings delegate:savePhotoDelegate];
}

- (AVCaptureVideoOrientation)getVideoOrientationForDeviceOrientation:
    (UIDeviceOrientation)deviceOrientation {
  if (deviceOrientation == UIDeviceOrientationPortrait) {
    return AVCaptureVideoOrientationPortrait;
  } else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
    // Note: device orientation is flipped compared to video orientation. When UIDeviceOrientation
    // is landscape left the video orientation should be landscape right.
    return AVCaptureVideoOrientationLandscapeRight;
  } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
    // Note: device orientation is flipped compared to video orientation. When UIDeviceOrientation
    // is landscape right the video orientation should be landscape left.
    return AVCaptureVideoOrientationLandscapeLeft;
  } else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
    return AVCaptureVideoOrientationPortraitUpsideDown;
  } else {
    return AVCaptureVideoOrientationPortrait;
  }
}

- (NSString *)getTemporaryFilePathWithExtension:(NSString *)extension
                                      subfolder:(NSString *)subfolder
                                         prefix:(NSString *)prefix
                                          error:(NSError **)error {
  NSString *docDir =
      NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
  NSString *fileDir =
      [[docDir stringByAppendingPathComponent:@"camera"] stringByAppendingPathComponent:subfolder];
  NSString *fileName = [prefix stringByAppendingString:[[NSUUID UUID] UUIDString]];
  NSString *file =
      [[fileDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:extension];

  NSFileManager *fm = [NSFileManager defaultManager];
  if (![fm fileExistsAtPath:fileDir]) {
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:fileDir
                                             withIntermediateDirectories:true
                                                              attributes:nil
                                                                   error:error];
    if (!success) {
      return nil;
    }
  }

  return file;
}

- (BOOL)setCaptureSessionPreset:(FCPPlatformResolutionPreset)resolutionPreset
                      withError:(NSError **)error {
  switch (resolutionPreset) {
    case FCPPlatformResolutionPresetMax: {
      NSObject<FLTCaptureDeviceFormat> *bestFormat =
          [self highestResolutionFormatForCaptureDevice:_captureDevice];
      if (bestFormat) {
        _videoCaptureSession.sessionPreset = AVCaptureSessionPresetInputPriority;
        if ([_captureDevice lockForConfiguration:NULL]) {
          // Set the best device format found and finish the device configuration.
          _captureDevice.activeFormat = bestFormat;
          [_captureDevice unlockForConfiguration];
          break;
        }
      }
    }
    case FCPPlatformResolutionPresetUltraHigh:
      if ([_videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
        _videoCaptureSession.sessionPreset = AVCaptureSessionPreset3840x2160;
        break;
      }
      if ([_videoCaptureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        _videoCaptureSession.sessionPreset = AVCaptureSessionPresetHigh;
        break;
      }
    case FCPPlatformResolutionPresetVeryHigh:
      if ([_videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        _videoCaptureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        break;
      }
    case FCPPlatformResolutionPresetHigh:
      if ([_videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        _videoCaptureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        break;
      }
    case FCPPlatformResolutionPresetMedium:
      if ([_videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        _videoCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
        break;
      }
    case FCPPlatformResolutionPresetLow:
      if ([_videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
        _videoCaptureSession.sessionPreset = AVCaptureSessionPreset352x288;
        break;
      }
    default:
      if ([_videoCaptureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
        _videoCaptureSession.sessionPreset = AVCaptureSessionPresetLow;
      } else {
        if (error != nil) {
          *error =
              [NSError errorWithDomain:NSCocoaErrorDomain
                                  code:NSURLErrorUnknown
                              userInfo:@{
                                NSLocalizedDescriptionKey :
                                    @"No capture session available for current capture session."
                              }];
        }
        return NO;
      }
  }
  CMVideoDimensions size = self.videoDimensionsForFormat(_captureDevice.activeFormat);
  _previewSize = CGSizeMake(size.width, size.height);
  _audioCaptureSession.sessionPreset = _videoCaptureSession.sessionPreset;
  return YES;
}

/// Finds the highest available resolution in terms of pixel count for the given device.
/// Preferred are formats with the same subtype as current activeFormat.
- (NSObject<FLTCaptureDeviceFormat> *)highestResolutionFormatForCaptureDevice:
    (NSObject<FLTCaptureDevice> *)captureDevice {
  FourCharCode preferredSubType =
      CMFormatDescriptionGetMediaSubType(_captureDevice.activeFormat.formatDescription);
  NSObject<FLTCaptureDeviceFormat> *bestFormat = nil;
  NSUInteger maxPixelCount = 0;
  BOOL isBestSubTypePreferred = NO;
  for (NSObject<FLTCaptureDeviceFormat> *format in _captureDevice.formats) {
    CMVideoDimensions res = self.videoDimensionsForFormat(format);
    NSUInteger height = res.height;
    NSUInteger width = res.width;
    NSUInteger pixelCount = height * width;
    FourCharCode subType = CMFormatDescriptionGetMediaSubType(format.formatDescription);
    BOOL isSubTypePreferred = subType == preferredSubType;
    if (pixelCount > maxPixelCount ||
        (pixelCount == maxPixelCount && isSubTypePreferred && !isBestSubTypePreferred)) {
      bestFormat = format;
      maxPixelCount = pixelCount;
      isBestSubTypePreferred = isSubTypePreferred;
    }
  }
  return bestFormat;
}

- (void)close {
  [self stop];
  for (AVCaptureInput *input in [_videoCaptureSession inputs]) {
    [_videoCaptureSession removeInput:[[FLTDefaultCaptureInput alloc] initWithInput:input]];
  }
  for (AVCaptureOutput *output in [_videoCaptureSession outputs]) {
    [_videoCaptureSession removeOutput:output];
  }
  for (AVCaptureInput *input in [_audioCaptureSession inputs]) {
    [_audioCaptureSession removeInput:[[FLTDefaultCaptureInput alloc] initWithInput:input]];
  }
  for (AVCaptureOutput *output in [_audioCaptureSession outputs]) {
    [_audioCaptureSession removeOutput:output];
  }
}

- (void)dealloc {
  [_motionManager stopAccelerometerUpdates];
}

/// Main logic to setup the video recording.
- (void)setUpVideoRecordingWithCompletion:(void (^)(FlutterError *_Nullable))completion {
  NSError *error;
  _videoRecordingPath = [self getTemporaryFilePathWithExtension:@"mp4"
                                                      subfolder:@"videos"
                                                         prefix:@"REC_"
                                                          error:&error];
  if (error) {
    completion(FlutterErrorFromNSError(error));
    return;
  }
  if (![self setupWriterForPath:_videoRecordingPath]) {
    completion([FlutterError errorWithCode:@"IOError" message:@"Setup Writer Failed" details:nil]);
    return;
  }
  // startWriting should not be called in didOutputSampleBuffer where it can cause state
  // in which _isRecording is YES but _videoWriter.status is AVAssetWriterStatusUnknown
  // in stopVideoRecording if it is called after startVideoRecording but before
  // didOutputSampleBuffer had chance to call startWriting and lag at start of video
  // https://github.com/flutter/flutter/issues/132016
  // https://github.com/flutter/flutter/issues/151319
  [_videoWriter startWriting];
  _isFirstVideoSample = YES;
  _isRecording = YES;
  _isRecordingPaused = NO;
  _videoTimeOffset = CMTimeMake(0, 1);
  _audioTimeOffset = CMTimeMake(0, 1);
  _videoIsDisconnected = NO;
  _audioIsDisconnected = NO;
  completion(nil);
}

- (void)startVideoRecordingWithCompletion:(void (^)(FlutterError *_Nullable))completion
                    messengerForStreaming:(nullable NSObject<FlutterBinaryMessenger> *)messenger {
  if (!_isRecording) {
    if (messenger != nil) {
      [self startImageStreamWithMessenger:messenger
                               completion:^(FlutterError *_Nullable error) {
                                 [self setUpVideoRecordingWithCompletion:completion];
                               }];
      return;
    }

    [self setUpVideoRecordingWithCompletion:completion];
  } else {
    completion([FlutterError errorWithCode:@"Error"
                                   message:@"Video is already recording"
                                   details:nil]);
  }
}

- (void)stopVideoRecordingWithCompletion:(void (^)(NSString *_Nullable,
                                                   FlutterError *_Nullable))completion {
  if (_isRecording) {
    _isRecording = NO;

    // when _isRecording is YES startWriting was already called so _videoWriter.status
    // is always either AVAssetWriterStatusWriting or AVAssetWriterStatusFailed and
    // finishWritingWithCompletionHandler does not throw exception so there is no need
    // to check _videoWriter.status
    [_videoWriter finishWritingWithCompletionHandler:^{
      if (self->_videoWriter.status == AVAssetWriterStatusCompleted) {
        [self updateOrientation];
        completion(self->_videoRecordingPath, nil);
        self->_videoRecordingPath = nil;
      } else {
        completion(nil, [FlutterError errorWithCode:@"IOError"
                                            message:@"AVAssetWriter could not finish writing!"
                                            details:nil]);
      }
    }];
  } else {
    NSError *error =
        [NSError errorWithDomain:NSCocoaErrorDomain
                            code:NSURLErrorResourceUnavailable
                        userInfo:@{NSLocalizedDescriptionKey : @"Video is not recording!"}];
    completion(nil, FlutterErrorFromNSError(error));
  }
}

- (void)pauseVideoRecording {
  _isRecordingPaused = YES;
  _videoIsDisconnected = YES;
  _audioIsDisconnected = YES;
}

- (void)resumeVideoRecording {
  _isRecordingPaused = NO;
}

- (void)lockCaptureOrientation:(FCPPlatformDeviceOrientation)pigeonOrientation {
  UIDeviceOrientation orientation =
      FCPGetUIDeviceOrientationForPigeonDeviceOrientation(pigeonOrientation);
  if (_lockedCaptureOrientation != orientation) {
    _lockedCaptureOrientation = orientation;
    [self updateOrientation];
  }
}

- (void)unlockCaptureOrientation {
  _lockedCaptureOrientation = UIDeviceOrientationUnknown;
  [self updateOrientation];
}

- (void)setFlashMode:(FCPPlatformFlashMode)mode
      withCompletion:(void (^)(FlutterError *_Nullable))completion {
  if (mode == FCPPlatformFlashModeTorch) {
    if (!_captureDevice.hasTorch) {
      completion([FlutterError errorWithCode:@"setFlashModeFailed"
                                     message:@"Device does not support torch mode"
                                     details:nil]);
      return;
    }
    if (!_captureDevice.isTorchAvailable) {
      completion([FlutterError errorWithCode:@"setFlashModeFailed"
                                     message:@"Torch mode is currently not available"
                                     details:nil]);
      return;
    }
    if (_captureDevice.torchMode != AVCaptureTorchModeOn) {
      [_captureDevice lockForConfiguration:nil];
      [_captureDevice setTorchMode:AVCaptureTorchModeOn];
      [_captureDevice unlockForConfiguration];
    }
  } else {
    if (!_captureDevice.hasFlash) {
      completion([FlutterError errorWithCode:@"setFlashModeFailed"
                                     message:@"Device does not have flash capabilities"
                                     details:nil]);
      return;
    }
    AVCaptureFlashMode avFlashMode = FCPGetAVCaptureFlashModeForPigeonFlashMode(mode);
    if (![_capturePhotoOutput.supportedFlashModes
            containsObject:[NSNumber numberWithInt:((int)avFlashMode)]]) {
      completion([FlutterError errorWithCode:@"setFlashModeFailed"
                                     message:@"Device does not support this specific flash mode"
                                     details:nil]);
      return;
    }
    if (_captureDevice.torchMode != AVCaptureTorchModeOff) {
      [_captureDevice lockForConfiguration:nil];
      [_captureDevice setTorchMode:AVCaptureTorchModeOff];
      [_captureDevice unlockForConfiguration];
    }
  }
  _flashMode = mode;
  completion(nil);
}

- (void)setExposureMode:(FCPPlatformExposureMode)mode {
  _exposureMode = mode;
  [self applyExposureMode];
}

- (void)applyExposureMode {
  [_captureDevice lockForConfiguration:nil];
  switch (self.exposureMode) {
    case FCPPlatformExposureModeLocked:
      // AVCaptureExposureModeAutoExpose automatically adjusts the exposure one time, and then
      // locks exposure for the device
      [_captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
      break;
    case FCPPlatformExposureModeAuto:
      if ([_captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [_captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
      } else {
        [_captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
      }
      break;
  }
  [_captureDevice unlockForConfiguration];
}

- (void)setFocusMode:(FCPPlatformFocusMode)mode {
  _focusMode = mode;
  [self applyFocusMode];
}

- (void)applyFocusMode {
  [self applyFocusMode:_focusMode onDevice:_captureDevice];
}

- (void)applyFocusMode:(FCPPlatformFocusMode)focusMode
              onDevice:(NSObject<FLTCaptureDevice> *)captureDevice {
  [captureDevice lockForConfiguration:nil];
  switch (focusMode) {
    case FCPPlatformFocusModeLocked:
      // AVCaptureFocusModeAutoFocus automatically adjusts the focus one time, and then locks focus
      if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
      }
      break;
    case FCPPlatformFocusModeAuto:
      if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
      } else if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
      }
      break;
  }
  [captureDevice unlockForConfiguration];
}

- (void)pausePreview {
  _isPreviewPaused = true;
}

- (void)resumePreview {
  _isPreviewPaused = false;
}

- (void)setDescriptionWhileRecording:(NSString *)cameraName
                      withCompletion:(void (^)(FlutterError *_Nullable))completion {
  if (!_isRecording) {
    completion([FlutterError errorWithCode:@"setDescriptionWhileRecordingFailed"
                                   message:@"Device was not recording"
                                   details:nil]);
    return;
  }

  _captureDevice = self.captureDeviceFactory(cameraName);

  NSObject<FLTCaptureConnection> *oldConnection =
      [_captureVideoOutput connectionWithMediaType:AVMediaTypeVideo];

  // Stop video capture from the old output.
  [_captureVideoOutput setSampleBufferDelegate:nil queue:nil];

  // Remove the old video capture connections.
  [_videoCaptureSession beginConfiguration];
  [_videoCaptureSession removeInput:_captureVideoInput];
  [_videoCaptureSession removeOutput:_captureVideoOutput.avOutput];

  NSError *error = nil;
  AVCaptureConnection *newConnection = [self createConnection:&error];
  if (error) {
    completion(FlutterErrorFromNSError(error));
    return;
  }

  // Keep the same orientation the old connections had.
  if (oldConnection && newConnection.isVideoOrientationSupported) {
    newConnection.videoOrientation = oldConnection.videoOrientation;
  }

  // Add the new connections to the session.
  if (![_videoCaptureSession canAddInput:_captureVideoInput])
    completion([FlutterError errorWithCode:@"VideoError"
                                   message:@"Unable switch video input"
                                   details:nil]);
  [_videoCaptureSession addInputWithNoConnections:_captureVideoInput];
  if (![_videoCaptureSession canAddOutput:_captureVideoOutput.avOutput])
    completion([FlutterError errorWithCode:@"VideoError"
                                   message:@"Unable switch video output"
                                   details:nil]);
  [_videoCaptureSession addOutputWithNoConnections:_captureVideoOutput.avOutput];
  if (![_videoCaptureSession canAddConnection:newConnection])
    completion([FlutterError errorWithCode:@"VideoError"
                                   message:@"Unable switch video connection"
                                   details:nil]);
  [_videoCaptureSession addConnection:newConnection];
  [_videoCaptureSession commitConfiguration];

  completion(nil);
}

- (CGPoint)CGPointForPoint:(nonnull FCPPlatformPoint *)point
           withOrientation:(UIDeviceOrientation)orientation {
  double x = point.x;
  double y = point.y;
  switch (orientation) {
    case UIDeviceOrientationPortrait:  // 90 ccw
      y = 1 - point.x;
      x = point.y;
      break;
    case UIDeviceOrientationPortraitUpsideDown:  // 90 cw
      x = 1 - point.y;
      y = point.x;
      break;
    case UIDeviceOrientationLandscapeRight:  // 180
      x = 1 - point.x;
      y = 1 - point.y;
      break;
    case UIDeviceOrientationLandscapeLeft:
    default:
      // No rotation required
      break;
  }
  return CGPointMake(x, y);
}

- (void)setExposurePoint:(FCPPlatformPoint *)point
          withCompletion:(void (^)(FlutterError *_Nullable))completion {
  if (!_captureDevice.exposurePointOfInterestSupported) {
    completion([FlutterError errorWithCode:@"setExposurePointFailed"
                                   message:@"Device does not have exposure point capabilities"
                                   details:nil]);
    return;
  }
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  [_captureDevice lockForConfiguration:nil];
  // A nil point resets to the center.
  [_captureDevice
      setExposurePointOfInterest:[self CGPointForPoint:(point
                                                            ?: [FCPPlatformPoint makeWithX:0.5
                                                                                         y:0.5])
                                       withOrientation:orientation]];
  [_captureDevice unlockForConfiguration];
  // Retrigger auto exposure
  [self applyExposureMode];
  completion(nil);
}

- (void)setFocusPoint:(FCPPlatformPoint *)point
       withCompletion:(void (^)(FlutterError *_Nullable))completion {
  if (!_captureDevice.focusPointOfInterestSupported) {
    completion([FlutterError errorWithCode:@"setFocusPointFailed"
                                   message:@"Device does not have focus point capabilities"
                                   details:nil]);
    return;
  }
  UIDeviceOrientation orientation = [_deviceOrientationProvider orientation];
  [_captureDevice lockForConfiguration:nil];
  // A nil point resets to the center.
  [_captureDevice
      setFocusPointOfInterest:[self
                                  CGPointForPoint:(point ?: [FCPPlatformPoint makeWithX:0.5 y:0.5])
                                  withOrientation:orientation]];
  [_captureDevice unlockForConfiguration];
  // Retrigger auto focus
  [self applyFocusMode];
  completion(nil);
}

- (void)setExposureOffset:(double)offset {
  [_captureDevice lockForConfiguration:nil];
  [_captureDevice setExposureTargetBias:offset completionHandler:nil];
  [_captureDevice unlockForConfiguration];
}

- (void)startImageStreamWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                           completion:(void (^)(FlutterError *))completion {
  [self startImageStreamWithMessenger:messenger
                   imageStreamHandler:[[FLTImageStreamHandler alloc]
                                          initWithCaptureSessionQueue:_captureSessionQueue]
                           completion:completion];
}

- (void)startImageStreamWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                   imageStreamHandler:(FLTImageStreamHandler *)imageStreamHandler
                           completion:(void (^)(FlutterError *))completion {
  if (!_isStreamingImages) {
    id<FLTEventChannel> eventChannel = [FlutterEventChannel
        eventChannelWithName:@"plugins.flutter.io/camera_avfoundation/imageStream"
             binaryMessenger:messenger];
    FLTThreadSafeEventChannel *threadSafeEventChannel =
        [[FLTThreadSafeEventChannel alloc] initWithEventChannel:eventChannel];

    _imageStreamHandler = imageStreamHandler;
    __weak typeof(self) weakSelf = self;
    [threadSafeEventChannel setStreamHandler:_imageStreamHandler
                                  completion:^{
                                    typeof(self) strongSelf = weakSelf;
                                    if (!strongSelf) {
                                      completion(nil);
                                      return;
                                    }

                                    dispatch_async(strongSelf.captureSessionQueue, ^{
                                      // cannot use the outter strongSelf
                                      typeof(self) strongSelf = weakSelf;
                                      if (!strongSelf) {
                                        completion(nil);
                                        return;
                                      }

                                      strongSelf.isStreamingImages = YES;
                                      strongSelf.streamingPendingFramesCount = 0;
                                      completion(nil);
                                    });
                                  }];
  } else {
    [self reportErrorMessage:@"Images from camera are already streaming!"];
    completion(nil);
  }
}

- (void)stopImageStream {
  if (_isStreamingImages) {
    _isStreamingImages = NO;
    _imageStreamHandler = nil;
  } else {
    [self reportErrorMessage:@"Images from camera are not streaming!"];
  }
}

- (void)receivedImageStreamData {
  self.streamingPendingFramesCount--;
}

- (void)setZoomLevel:(CGFloat)zoom withCompletion:(void (^)(FlutterError *_Nullable))completion {
  if (_captureDevice.maxAvailableVideoZoomFactor < zoom ||
      _captureDevice.minAvailableVideoZoomFactor > zoom) {
    NSString *errorMessage = [NSString
        stringWithFormat:@"Zoom level out of bounds (zoom level should be between %f and %f).",
                         _captureDevice.minAvailableVideoZoomFactor,
                         _captureDevice.maxAvailableVideoZoomFactor];

    completion([FlutterError errorWithCode:@"ZOOM_ERROR" message:errorMessage details:nil]);
    return;
  }

  NSError *error = nil;
  if (![_captureDevice lockForConfiguration:&error]) {
    completion(FlutterErrorFromNSError(error));
    return;
  }
  _captureDevice.videoZoomFactor = zoom;
  [_captureDevice unlockForConfiguration];

  completion(nil);
}

- (CGFloat)minimumAvailableZoomFactor {
  return _captureDevice.minAvailableVideoZoomFactor;
}

- (CGFloat)maximumAvailableZoomFactor {
  return _captureDevice.maxAvailableVideoZoomFactor;
}

- (CGFloat)minimumExposureOffset {
  return _captureDevice.minExposureTargetBias;
}

- (CGFloat)maximumExposureOffset {
  return _captureDevice.maxExposureTargetBias;
}

- (BOOL)setupWriterForPath:(NSString *)path {
  NSError *error = nil;
  NSURL *outputURL;
  if (path != nil) {
    outputURL = [NSURL fileURLWithPath:path];
  } else {
    return NO;
  }

  [self setUpCaptureSessionForAudioIfNeeded];

  _videoWriter = _assetWriterFactory(outputURL, AVFileTypeMPEG4, &error);

  NSParameterAssert(_videoWriter);
  if (error) {
    [self reportErrorMessage:error.description];
    return NO;
  }

  NSMutableDictionary<NSString *, id> *videoSettings = [[_mediaSettingsAVWrapper
      recommendedVideoSettingsForAssetWriterWithFileType:AVFileTypeMPEG4
                                               forOutput:_captureVideoOutput] mutableCopy];

  if (_mediaSettings.videoBitrate || _mediaSettings.framesPerSecond) {
    NSMutableDictionary *compressionProperties = [[NSMutableDictionary alloc] init];

    if (_mediaSettings.videoBitrate) {
      compressionProperties[AVVideoAverageBitRateKey] = _mediaSettings.videoBitrate;
    }

    if (_mediaSettings.framesPerSecond) {
      compressionProperties[AVVideoExpectedSourceFrameRateKey] = _mediaSettings.framesPerSecond;
    }

    videoSettings[AVVideoCompressionPropertiesKey] = compressionProperties;
  }

  _videoWriterInput =
      [_mediaSettingsAVWrapper assetWriterVideoInputWithOutputSettings:videoSettings];

  _videoAdaptor = _inputPixelBufferAdaptorFactory(
      _videoWriterInput, @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(_videoFormat)});

  NSParameterAssert(_videoWriterInput);

  _videoWriterInput.expectsMediaDataInRealTime = YES;

  // Add the audio input
  if (_mediaSettings.enableAudio) {
    AudioChannelLayout acl;
    bzero(&acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSMutableDictionary *audioOutputSettings = [@{
      AVFormatIDKey : [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
      AVSampleRateKey : [NSNumber numberWithFloat:44100.0],
      AVNumberOfChannelsKey : [NSNumber numberWithInt:1],
      AVChannelLayoutKey : [NSData dataWithBytes:&acl length:sizeof(acl)],
    } mutableCopy];

    if (_mediaSettings.audioBitrate) {
      audioOutputSettings[AVEncoderBitRateKey] = _mediaSettings.audioBitrate;
    }

    _audioWriterInput =
        [_mediaSettingsAVWrapper assetWriterAudioInputWithOutputSettings:audioOutputSettings];

    _audioWriterInput.expectsMediaDataInRealTime = YES;

    [_mediaSettingsAVWrapper addInput:_audioWriterInput toAssetWriter:_videoWriter];
    [_audioOutput setSampleBufferDelegate:self queue:_captureSessionQueue];
  }

  if (self.flashMode == FCPPlatformFlashModeTorch) {
    [self.captureDevice lockForConfiguration:nil];
    [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
    [self.captureDevice unlockForConfiguration];
  }

  [_mediaSettingsAVWrapper addInput:_videoWriterInput toAssetWriter:_videoWriter];

  [_captureVideoOutput setSampleBufferDelegate:self queue:_captureSessionQueue];

  return YES;
}

// This function, although slightly modified, is also in video_player_avfoundation.
// Both need to do the same thing and run on the same thread (for example main thread).
// Configure application wide audio session manually to prevent overwriting flag
// MixWithOthers by capture session.
// Only change category if it is considered an upgrade which means it can only enable
// ability to play in silent mode or ability to record audio but never disables it,
// that could affect other plugins which depend on this global state. Only change
// category or options if there is change to prevent unnecessary lags and silence.
static void upgradeAudioSessionCategory(AVAudioSessionCategory requestedCategory,
                                        AVAudioSessionCategoryOptions options) {
  NSSet *playCategories = [NSSet
      setWithObjects:AVAudioSessionCategoryPlayback, AVAudioSessionCategoryPlayAndRecord, nil];
  NSSet *recordCategories =
      [NSSet setWithObjects:AVAudioSessionCategoryRecord, AVAudioSessionCategoryPlayAndRecord, nil];
  NSSet *requiredCategories =
      [NSSet setWithObjects:requestedCategory, AVAudioSession.sharedInstance.category, nil];
  BOOL requiresPlay = [requiredCategories intersectsSet:playCategories];
  BOOL requiresRecord = [requiredCategories intersectsSet:recordCategories];
  if (requiresPlay && requiresRecord) {
    requestedCategory = AVAudioSessionCategoryPlayAndRecord;
  } else if (requiresPlay) {
    requestedCategory = AVAudioSessionCategoryPlayback;
  } else if (requiresRecord) {
    requestedCategory = AVAudioSessionCategoryRecord;
  }
  options = AVAudioSession.sharedInstance.categoryOptions | options;
  if ([requestedCategory isEqualToString:AVAudioSession.sharedInstance.category] &&
      options == AVAudioSession.sharedInstance.categoryOptions) {
    return;
  }
  [AVAudioSession.sharedInstance setCategory:requestedCategory withOptions:options error:nil];
}

- (void)setUpCaptureSessionForAudioIfNeeded {
  // Don't setup audio twice or we will lose the audio.
  if (!_mediaSettings.enableAudio || _isAudioSetup) {
    return;
  }

  NSError *error = nil;
  // Create a device input with the device and add it to the session.
  // Setup the audio input.
  NSObject<FLTCaptureDevice> *audioDevice = self.audioCaptureDeviceFactory();
  NSObject<FLTCaptureInput> *audioInput =
      [_captureDeviceInputFactory deviceInputWithDevice:audioDevice error:&error];
  if (error) {
    [self reportErrorMessage:error.description];
  }
  // Setup the audio output.
  _audioOutput = [[AVCaptureAudioDataOutput alloc] init];

  dispatch_block_t block = ^{
    // Set up options implicit to AVAudioSessionCategoryPlayback to avoid conflicts with other
    // plugins like video_player.
    upgradeAudioSessionCategory(AVAudioSessionCategoryPlayAndRecord,
                                AVAudioSessionCategoryOptionDefaultToSpeaker |
                                    AVAudioSessionCategoryOptionAllowBluetoothA2DP |
                                    AVAudioSessionCategoryOptionAllowAirPlay);
  };
  if (!NSThread.isMainThread) {
    dispatch_sync(dispatch_get_main_queue(), block);
  } else {
    block();
  }

  if ([_audioCaptureSession canAddInput:audioInput]) {
    [_audioCaptureSession addInput:audioInput];

    if ([_audioCaptureSession canAddOutput:_audioOutput]) {
      [_audioCaptureSession addOutput:_audioOutput];
      _isAudioSetup = YES;
    } else {
      [self reportErrorMessage:@"Unable to add Audio input/output to session capture"];
      _isAudioSetup = NO;
    }
  }
}

- (void)reportErrorMessage:(NSString *)errorMessage {
  __weak typeof(self) weakSelf = self;
  FLTEnsureToRunOnMainQueue(^{
    [weakSelf.dartAPI reportError:errorMessage
                       completion:^(FlutterError *error){
                           // Ignore any errors, as this is just an event broadcast.
                       }];
  });
}

@end
