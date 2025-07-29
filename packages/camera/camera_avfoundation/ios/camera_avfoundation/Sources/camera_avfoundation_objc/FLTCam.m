// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCam.h"
#import "./include/camera_avfoundation/FLTCam_Test.h"

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

@interface FLTCam () <AVCaptureVideoDataOutputSampleBufferDelegate,
                      AVCaptureAudioDataOutputSampleBufferDelegate>

@property(readonly, nonatomic) int64_t textureId;

@property(readonly, nonatomic) CGSize captureSize;
@property(strong, nonatomic)
    NSObject<FLTAssetWriterInputPixelBufferAdaptor> *assetWriterPixelBufferAdaptor;
@property(strong, nonatomic) AVCaptureVideoDataOutput *videoOutput;
@property(assign, nonatomic) BOOL isAudioSetup;

/// A wrapper for CMVideoFormatDescriptionGetDimensions.
/// Allows for alternate implementations in tests.
@property(nonatomic, copy) VideoDimensionsForFormat videoDimensionsForFormat;
/// A wrapper for AVCaptureDevice creation to allow for dependency injection in tests.
@property(nonatomic, copy) AudioCaptureDeviceFactory audioCaptureDeviceFactory;
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
  _videoCaptureSession = configuration.videoCaptureSession;
  _audioCaptureSession = configuration.audioCaptureSession;
  _captureDeviceFactory = configuration.captureDeviceFactory;
  _audioCaptureDeviceFactory = configuration.audioCaptureDeviceFactory;
  _captureDevice = _captureDeviceFactory(configuration.initialCameraName);
  _captureDeviceInputFactory = configuration.captureDeviceInputFactory;
  _videoDimensionsForFormat = configuration.videoDimensionsForFormat;
  _flashMode = _captureDevice.hasFlash ? FCPPlatformFlashModeAuto : FCPPlatformFlashModeOff;
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
