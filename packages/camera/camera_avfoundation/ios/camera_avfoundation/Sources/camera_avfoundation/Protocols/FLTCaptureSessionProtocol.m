// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/camera_avfoundation/Protocols/FLTCaptureSessionProtocol.h"

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

- (void)addInputWithNoConnections:(AVCaptureInput *)input {
    [_captureSession addInputWithNoConnections:input];
}

- (void)addOutputWithNoConnections:(AVCaptureOutput *)output {
    [_captureSession addOutputWithNoConnections:output];
}

- (void)addConnection:(AVCaptureConnection *)connection {
    [_captureSession addConnection:connection];
}

- (void)addOutput:(AVCaptureOutput *)output {
    [_captureSession addOutput:output];
}

- (void)removeInput:(AVCaptureInput *)input {
    [_captureSession removeInput:input];
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

- (BOOL)canAddInput:(AVCaptureInput *)input {
    return [_captureSession canAddInput:input];
}

- (BOOL)canAddOutput:(AVCaptureOutput *)output {
    return [_captureSession canAddOutput:output];
}

- (BOOL)canAddConnection:(AVCaptureConnection *)connection {
    return [_captureSession canAddConnection:connection];
}

- (void)addInput:(AVCaptureInput *)input {
    [_captureSession addInput:input];
}

@end
