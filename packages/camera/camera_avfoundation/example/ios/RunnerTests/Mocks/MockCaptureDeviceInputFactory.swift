// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

///// A mocked implementation of FLTCaptureDeviceInputFactory which allows injecting a custom
///// implementation.
final class MockCaptureDeviceInputFactory: NSObject, CaptureDeviceInputFactory {
  func deviceInput(with device: CaptureDevice) throws -> CaptureInput {
    return MockCaptureInput()
  }
}
