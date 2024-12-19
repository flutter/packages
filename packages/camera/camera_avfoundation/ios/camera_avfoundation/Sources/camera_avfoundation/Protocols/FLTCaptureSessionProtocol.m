// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/camera_avfoundation/Protocols/FLTCaptureSessionProtocol.h"
#import "../include/camera_avfoundation/Protocols/FLTCaptureConnection.h"

@interface FLTDefaultCaptureSession ()
@property(nonatomic, strong) AVCaptureSession *captureSession;
@end

@implementation FLTDefaultCaptureSession

- (instancetype)initWithCaptureSession:(AVCaptureSession *)session {
  self = [super init];
  if (self) {
    _captureSession = session;
  }
  return self;
}

- (void)beginConfiguration {
  [_captureSession beginConfiguration];
}

- (void)commitConfiguration {
  [_captureSession commitConfiguration];
}

- (void)startRunning {
  [_captureSession startRunning];
}

- (void)stopRunning {
  [_captureSession stopRunning];
}

- (BOOL)canSetSessionPreset:(AVCaptureSessionPreset)preset {
  return [_captureSession canSetSessionPreset:preset];
}

- (void)addInputWithNoConnections:(id<FLTCaptureInput>)input {
  [_captureSession addInputWithNoConnections:input.input];
}

- (void)addOutputWithNoConnections:(AVCaptureOutput *)output {
  [_captureSession addOutputWithNoConnections:output];
}

- (void)addConnection:(id<FLTCaptureConnection>)connection {
  [_captureSession addConnection:connection.connection];
}

- (void)addOutput:(AVCaptureOutput *)output {
  [_captureSession addOutput:output];
}

- (void)removeInput:(id<FLTCaptureInput>)input {
  [_captureSession removeInput:input.input];
}

- (void)removeOutput:(AVCaptureOutput *)output {
  [_captureSession removeOutput:output];
}

- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset {
  _captureSession.sessionPreset = sessionPreset;
}

- (AVCaptureSessionPreset)sessionPreset {
  return _captureSession.sessionPreset;
}

- (NSArray<AVCaptureInput *> *)inputs {
  return _captureSession.inputs;
}

- (NSArray<AVCaptureOutput *> *)outputs {
  return _captureSession.outputs;
}

- (BOOL)canAddInput:(id<FLTCaptureInput>)input {
  return [_captureSession canAddInput:input.input];
}

- (BOOL)canAddOutput:(AVCaptureOutput *)output {
  return [_captureSession canAddOutput:output];
}

- (BOOL)canAddConnection:(id<FLTCaptureConnection>)connection {
  return [_captureSession canAddConnection:connection.connection];
}

- (void)addInput:(id<FLTCaptureInput>)input {
  [_captureSession addInput:input.input];
}

@end
