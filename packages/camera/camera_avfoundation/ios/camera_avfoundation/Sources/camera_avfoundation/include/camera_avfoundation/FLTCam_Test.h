// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTCam.h"
#import "FLTCaptureConnection.h"
#import "FLTCaptureDevice.h"
#import "FLTCapturePhotoOutput.h"
#import "FLTDeviceOrientationProviding.h"
#import "FLTSavePhotoDelegate.h"

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
@property(strong, nonatomic) NSObject<FLTCapturePhotoOutput> *capturePhotoOutput;

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
           fromConnection:(NSObject<FLTCaptureConnection> *)connection;

/// Start streaming images.
- (void)startImageStreamWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                   imageStreamHandler:(FLTImageStreamHandler *)imageStreamHandler;

@end
