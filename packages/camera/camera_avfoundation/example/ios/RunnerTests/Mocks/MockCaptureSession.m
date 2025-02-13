// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockCaptureSession.h"

@implementation MockCaptureSession

- (instancetype)init {
  self = [super init];
  if (self) {
    _inputs = [NSMutableArray array];
    _outputs = [NSMutableArray array];
  }
  return self;
}

- (void)beginConfiguration {
  if (self.beginConfigurationStub) {
    self.beginConfigurationStub();
  }
}

- (void)commitConfiguration {
  if (self.commitConfigurationStub) {
    self.commitConfigurationStub();
  }
}

- (void)startRunning {
  if (self.startRunningStub) {
    self.startRunningStub();
  }
}

- (void)stopRunning {
  if (self.stopRunningStub) {
    self.stopRunningStub();
  }
}

- (BOOL)canSetSessionPreset:(AVCaptureSessionPreset)preset {
  return self.canSetSessionPreset;
}

- (void)addConnection:(nonnull AVCaptureConnection *)connection {
}

- (void)addInput:(nonnull NSObject<FLTCaptureInput> *)input {
}

- (void)addInputWithNoConnections:(nonnull NSObject<FLTCaptureInput> *)input {
}

- (void)addOutput:(nonnull AVCaptureOutput *)output {
}

- (void)addOutputWithNoConnections:(nonnull AVCaptureOutput *)output {
}

- (BOOL)canAddConnection:(nonnull AVCaptureConnection *)connection {
  return YES;
}

- (BOOL)canAddInput:(nonnull NSObject<FLTCaptureInput> *)input {
  return YES;
}

- (BOOL)canAddOutput:(nonnull AVCaptureOutput *)output {
  return YES;
}

- (void)removeInput:(nonnull NSObject<FLTCaptureInput> *)input {
}

- (void)removeOutput:(nonnull AVCaptureOutput *)output {
}

- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset {
  if (self.setSessionPresetStub) {
    self.setSessionPresetStub(sessionPreset);
  }
}

@end
