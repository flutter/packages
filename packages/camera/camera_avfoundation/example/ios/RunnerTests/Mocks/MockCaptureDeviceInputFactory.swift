// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

@testable import camera_avfoundation

///// A mocked implementation of CaptureDeviceInputFactory which allows injecting a custom
///// implementation.
final class MockCaptureDeviceInputFactory: NSObject, CaptureDeviceInputFactory {
  func deviceInput(with device: CaptureDevice) throws -> CaptureInput {
    return MockCaptureInput()
  }
}
