// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>
#import "CameraTestUtils.h"

/// Includes test cases related to resolution presets setting  operations for FLTCam class.
@interface FLTCamSessionPresetsTest : XCTestCase
@end

/// swizzles AVCaptureDevice constructor to return mocked object
@implementation AVCaptureDevice (UniqueIDSwizzling)

+ (void)swizzleDeviceWithUniqueIDMethod {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class class = object_getClass((id)self);

    SEL originalSelector = @selector(deviceWithUniqueID:);
    SEL swizzledSelector = @selector(test_deviceWithUniqueID:);

    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

    method_exchangeImplementations(originalMethod, swizzledMethod);
  });
}

+ (AVCaptureDevice *)test_deviceWithUniqueID:(NSString *)deviceUniqueID {
  id mockDevice = OCMClassMock([AVCaptureDevice class]);

  // always allow locking for configuration to be able to set value for activeFormat
  OCMStub([mockDevice lockForConfiguration:NULL]).andReturn(YES);
  return mockDevice;
}

@end

/// swizzles getHighestResolutionFormatForCaptureDevice private method to always return a value
@implementation FLTCam (TestSwizzling)

+ (void)swizzleGetHighestResolutionMethod {
  Class class = [self class];

  SEL originalSelector = @selector(getHighestResolutionFormatForCaptureDevice:);
  SEL swizzledSelector = @selector(test_getHighestResolutionFormatForCaptureDevice:);

  Method originalMethod = class_getInstanceMethod(class, originalSelector);
  Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

  BOOL didAddMethod =
      class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod),
                      method_getTypeEncoding(swizzledMethod));

  if (didAddMethod) {
    class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod),
                        method_getTypeEncoding(originalMethod));
  } else {
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
}

- (AVCaptureDeviceFormat *)test_getHighestResolutionFormatForCaptureDevice:
    (AVCaptureDevice *)device {
  id mockDeviceFormat = OCMClassMock([AVCaptureDeviceFormat class]);

  return mockDeviceFormat;
}

@end

@implementation FLTCamSessionPresetsTest

- (void)testResolutionPresetWithBestFormat_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPresetInputPriority;

  // make sure initializing AVCaptureDevice always succeeds
  [AVCaptureDevice swizzleDeviceWithUniqueIDMethod];
  // make sure getHighestResolutionFormatForCaptureDevice returns a value
  [FLTCam swizzleGetHighestResolutionMethod];

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);

  OCMExpect([videoSessionMock setSessionPreset:expectedPreset]);

  FLTCreateCamWithVideoCaptureSession(videoSessionMock, @"max");

  OCMVerifyAll(videoSessionMock);

  // cleanup
  [AVCaptureDevice swizzleDeviceWithUniqueIDMethod];
  [FLTCam swizzleGetHighestResolutionMethod];
}

- (void)testResolutionPresetWithCanSetSessionPresetMax_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPreset3840x2160;

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);

  // make sure that setting resolution preset for session always succeeds
  OCMStub([videoSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  OCMExpect([videoSessionMock setSessionPreset:expectedPreset]);

  FLTCreateCamWithVideoCaptureSession(videoSessionMock, @"max");

  OCMVerifyAll(videoSessionMock);
}

- (void)testResolutionPresetWithCanSetSessionPresetUltraHigh_mustUpdateCaptureSessionPreset {
  NSString *expectedPreset = AVCaptureSessionPreset3840x2160;

  id videoSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([videoSessionMock addInputWithNoConnections:[OCMArg any]]);  // no-op

  // make sure that setting resolution preset for session always succeeds
  OCMStub([videoSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  // expect that setting "ultraHigh" resolutionPreset correctly updates videoCaptureSession
  OCMExpect([videoSessionMock setSessionPreset:expectedPreset]);

  FLTCreateCamWithVideoCaptureSession(videoSessionMock, @"ultraHigh");

  OCMVerifyAll(videoSessionMock);
}

@end
