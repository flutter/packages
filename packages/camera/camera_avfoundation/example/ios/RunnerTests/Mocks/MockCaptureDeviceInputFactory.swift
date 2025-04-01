// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

///// A mocked implementation of FLTCaptureDeviceInputFactory which allows injecting a custom
///// implementation.
final class MockCaptureDeviceInputFactory: NSObject, FLTCaptureDeviceInputFactory {
  func deviceInput(with device: FLTCaptureDevice) throws -> FLTCaptureInput {
    return MockCaptureInput()
  }
}
