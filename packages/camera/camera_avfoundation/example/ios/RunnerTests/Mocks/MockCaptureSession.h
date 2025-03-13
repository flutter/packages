// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// Mock implementation of `FLTCaptureSession` protocol which allows injecting a custom
/// implementation.
@interface MockCaptureSession : NSObject <FLTCaptureSession>

// Stubs that are called when the corresponding public method is called.
@property(nonatomic, copy) void (^beginConfigurationStub)(void);
@property(nonatomic, copy) void (^commitConfigurationStub)(void);
@property(nonatomic, copy) void (^startRunningStub)(void);
@property(nonatomic, copy) void (^stopRunningStub)(void);
@property(nonatomic, copy) void (^setSessionPresetStub)(AVCaptureSessionPreset preset);

// Properties re-declared as read/write so a mocked value can be set during testing.
@property(nonatomic, strong) NSMutableArray<AVCaptureInput *> *inputs;
@property(nonatomic, strong) NSMutableArray<AVCaptureOutput *> *outputs;
@property(nonatomic, assign) BOOL canSetSessionPreset;
@property(nonatomic, copy) AVCaptureSessionPreset sessionPreset;
@property(nonatomic, assign) BOOL automaticallyConfiguresApplicationAudioSession;

@end

NS_ASSUME_NONNULL_END
