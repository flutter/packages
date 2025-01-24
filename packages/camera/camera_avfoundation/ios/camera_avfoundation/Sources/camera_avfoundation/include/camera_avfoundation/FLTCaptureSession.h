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
- (void)addInputWithNoConnections:(AVCaptureInput *)input;
- (void)addOutputWithNoConnections:(AVCaptureOutput *)output;
- (void)addConnection:(AVCaptureConnection *)connection;
- (void)addOutput:(AVCaptureOutput *)output;
- (void)removeInput:(AVCaptureInput *)input;
- (void)removeOutput:(AVCaptureOutput *)output;
- (BOOL)canAddInput:(AVCaptureInput *)input;
- (BOOL)canAddOutput:(AVCaptureOutput *)output;
- (BOOL)canAddConnection:(AVCaptureConnection *)connection;
- (void)addInput:(AVCaptureInput *)input;

@end

@interface AVCaptureSession (FLTCaptureSession) <FLTCaptureSession>
@end

NS_ASSUME_NONNULL_END
