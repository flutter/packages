// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTCam.h"
#import "FLTSavePhotoDelegate.h"

/**
 A block type definition named VideoDimensionsForFormatBlock.

 This block is intended to be used for determining the video dimensions (width and height) for a
 given capture device format. It accepts an AVCaptureDeviceFormat object as its input and returns a
 CMVideoDimensions struct representing the video dimensions associated with that format.

 Parameters:
 - format: An AVCaptureDeviceFormat object representing the format for which the video dimensions
 are being queried.

 Returns:
 A CMVideoDimensions struct containing the width and height (in pixels) of the video associated with
 the provided format.
*/
typedef CMVideoDimensions (^VideoDimensionsForFormatBlock)(AVCaptureDeviceFormat *);

/**
 A block type definition named DeviceWithNoArgumentsBlock.

 This block is intended for use when you need to obtain an instance of AVCaptureDevice without
 requiring any input parameters. It is particularly useful in scenarios where the desired capture
 device is predefined or does not depend on dynamic conditions.

 Returns:
 An AVCaptureDevice instance. The specific instance returned by the block can be predefined within
 the block's implementation, allowing for consistent access to a particular device, such as the
 default camera or microphone, without the need for specifying its unique ID each time.
 */
typedef AVCaptureDevice * (^CaptureDeviceBlock)(void);

@interface FLTImageStreamHandler : NSObject <FlutterStreamHandler>

/// The queue on which `eventSink` property should be accessed.
@property(nonatomic, strong) dispatch_queue_t captureSessionQueue;

/// The event sink to stream camera events to Dart.
///
/// The property should only be accessed on `captureSessionQueue`.
/// The block itself should be invoked on the main queue.
@property FlutterEventSink eventSink;

@end

// APIs exposed for unit testing.
@interface FLTCam ()

/// The output for video capturing.
@property(readonly, nonatomic) AVCaptureVideoDataOutput *captureVideoOutput;

/// The output for photo capturing. Exposed setter for unit tests.
@property(strong, nonatomic) AVCapturePhotoOutput *capturePhotoOutput;

/// True when images from the camera are being streamed.
@property(assign, nonatomic) BOOL isStreamingImages;

/// A dictionary to retain all in-progress FLTSavePhotoDelegates. The key of the dictionary is the
/// AVCapturePhotoSettings's uniqueID for each photo capture operation, and the value is the
/// FLTSavePhotoDelegate that handles the result of each photo capture operation. Note that photo
/// capture operations may overlap, so FLTCam has to keep track of multiple delegates in progress,
/// instead of just a single delegate reference.
@property(readonly, nonatomic)
    NSMutableDictionary<NSNumber *, FLTSavePhotoDelegate *> *inProgressSavePhotoDelegates;

/// Delegate callback when receiving a new video or audio sample.
/// Exposed for unit tests.
- (void)captureOutput:(AVCaptureOutput *)output
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection;

/// Initializes a camera instance.
/// Allows for injecting dependencies that are usually internal.
- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                       enableAudio:(BOOL)enableAudio
                       orientation:(UIDeviceOrientation)orientation
               videoCaptureSession:(AVCaptureSession *)videoCaptureSession
               audioCaptureSession:(AVCaptureSession *)audioCaptureSession
               captureSessionQueue:(dispatch_queue_t)captureSessionQueue
                             error:(NSError **)error;

/**
 Initializes an instance for testing with specified resolution, audio preference, orientation, and
 direct access to capture sessions and blocks.

 This initializer allows the explicit configuration of media capture settings and direct
 manipulation of internal components like capture sessions and device selection blocks, facilitating
 thorough testing scenarios.

 @param resolutionPreset A string defining the resolution preset for video capture.
 @param enableAudio A boolean indicating whether audio capture is enabled.
 @param orientation The device orientation during capture.
 @param videoCaptureSession An AVCaptureSession for video capturing.
 @param audioCaptureSession An AVCaptureSession for audio capturing.
 @param captureSessionQueue The dispatch queue for capture session tasks.
 @param captureDeviceBlock A block returning a specific AVCaptureDevice.
 @param videoDimensionsForFormatBlock A block to determine video dimensions for a given format.
 @param error A pointer to an NSError object to capture any initialization errors.

 @return An instance of the class, configured for testing with provided parameters.
*/
- (instancetype)initWithResolutionPreset:(NSString *)resolutionPreset
                             enableAudio:(BOOL)enableAudio
                             orientation:(UIDeviceOrientation)orientation
                     videoCaptureSession:(AVCaptureSession *)videoCaptureSession
                     audioCaptureSession:(AVCaptureSession *)audioCaptureSession
                     captureSessionQueue:(dispatch_queue_t)captureSessionQueue
                      captureDeviceBlock:(CaptureDeviceBlock)captureDeviceBlock
           videoDimensionsForFormatBlock:
               (VideoDimensionsForFormatBlock)videoDimensionsForFormatBlock
                                   error:(NSError **)error;

/// Start streaming images.
- (void)startImageStreamWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                   imageStreamHandler:(FLTImageStreamHandler *)imageStreamHandler;

@end
