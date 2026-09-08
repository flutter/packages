// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

/// Mocked implementation of `FlutterTextureRegistry` protocol that exists to allow constructing
/// a `CameraPlugin` instance for testing. It contains an empty implementation for all protocol
/// methods.
final class MockFlutterTextureRegistry: NSObject, FlutterTextureRegistry {
  func register(_ texture: FlutterTexture) -> Int64 { 0 }

  func textureFrameAvailable(_ textureId: Int64) {}

  func unregisterTexture(_ textureId: Int64) {}
}
