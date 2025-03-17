// Copyright 2013 The Flutter Authors. All rights reserved.
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
- (void)addConnection:(AVCaptureConnection *)connection;
- (void)addOutput:(AVCaptureOutput *)output;
- (void)removeInput:(NSObject<FLTCaptureInput> *)input;
- (void)removeOutput:(AVCaptureOutput *)output;
- (BOOL)canAddInput:(NSObject<FLTCaptureInput> *)input;
- (BOOL)canAddOutput:(AVCaptureOutput *)output;
- (BOOL)canAddConnection:(AVCaptureConnection *)connection;
- (void)addInput:(NSObject<FLTCaptureInput> *)input;

@end

/// A default implementation  of `FLTCaptureSession` which is a direct passthrough
/// to the underlying `AVCaptureSession`.
@interface FLTDefaultCaptureSession : NSObject <FLTCaptureSession>
- (instancetype)initWithCaptureSession:(AVCaptureSession *)session;
@end

NS_ASSUME_NONNULL_END
