// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;

#import "FLTCaptureDevice.h"

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to AVCaptureSession.
/// It exists to allow replacing AVCaptureSession in tests.
@protocol FLTCaptureSession <NSObject>

@property(nonatomic, copy) AVCaptureSessionPreset sessionPreset;
@property(nonatomic, readonly) NSArray<AVCaptureInput *> *inputs;
@property(nonatomic, readonly) NSArray<AVCaptureOutput *> *outputs;
@property(nonatomic, assign) BOOL automaticallyConfiguresApplicationAudioSession;

- (void)beginConfiguration;
- (void)commitConfiguration;
- (void)startRunning;
- (void)stopRunning;
- (BOOL)canSetSessionPreset:(AVCaptureSessionPreset)preset;
- (void)addInputWithNoConnections:(NSObject<FLTCaptureInput> *)input;
- (void)addOutputWithNoConnections:(AVCaptureOutput *)output;
// Methods renamed in Swift for consistency with AVCaptureSession Swift interface.
- (void)addConnection:(AVCaptureConnection *)connection NS_SWIFT_NAME(addConnection(_:));
- (void)addInput:(NSObject<FLTCaptureInput> *)input NS_SWIFT_NAME(addInput(_:));
- (void)addOutput:(AVCaptureOutput *)output NS_SWIFT_NAME(addOutput(_:));
- (void)removeInput:(NSObject<FLTCaptureInput> *)input NS_SWIFT_NAME(removeInput(_:));
- (void)removeOutput:(AVCaptureOutput *)output NS_SWIFT_NAME(removeOutput(_:));
- (BOOL)canAddInput:(NSObject<FLTCaptureInput> *)input NS_SWIFT_NAME(canAddInput(_:));
- (BOOL)canAddOutput:(AVCaptureOutput *)output NS_SWIFT_NAME(canAddOutput(_:));
- (BOOL)canAddConnection:(AVCaptureConnection *)connection NS_SWIFT_NAME(canAddConnection(_:));

@end

/// A default implementation  of `FLTCaptureSession` which is a direct passthrough
/// to the underlying `AVCaptureSession`.
@interface FLTDefaultCaptureSession : NSObject <FLTCaptureSession>
- (instancetype)initWithCaptureSession:(AVCaptureSession *)session;
@end

NS_ASSUME_NONNULL_END
