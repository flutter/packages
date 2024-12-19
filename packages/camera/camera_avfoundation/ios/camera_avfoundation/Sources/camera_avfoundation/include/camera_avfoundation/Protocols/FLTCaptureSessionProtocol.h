// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;

#import "FLTCaptureDeviceControlling.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FLTCaptureSessionProtocol <NSObject>

- (void)beginConfiguration;
- (void)commitConfiguration;
- (void)startRunning;
- (void)stopRunning;
- (BOOL)canSetSessionPreset:(AVCaptureSessionPreset)preset;
- (void)addInputWithNoConnections:(AVCaptureInput *)input;
- (void)addOutputWithNoConnections:(AVCaptureOutput *)output;
- (void)addConnection:(AVCaptureConnection *)connection;
- (void)addOutput:(AVCaptureOutput *)output;
- (void)removeInput:(id<FLTCaptureInput>)input;
- (void)removeOutput:(AVCaptureOutput *)output;
- (BOOL)canAddInput:(id<FLTCaptureInput>)input;
- (BOOL)canAddOutput:(AVCaptureOutput *)output;
- (BOOL)canAddConnection:(AVCaptureConnection *)connection;
- (void)addInput:(id<FLTCaptureInput>)input;
@property(nonatomic, copy) AVCaptureSessionPreset sessionPreset;
@property(nonatomic, readonly) NSArray<AVCaptureInput *> *inputs;
@property(nonatomic, readonly) NSArray<AVCaptureOutput *> *outputs;

@end

@interface FLTDefaultCaptureSession : NSObject <FLTCaptureSessionProtocol>
- (instancetype)initWithCaptureSession:(AVCaptureSession *)session;
@end

NS_ASSUME_NONNULL_END
