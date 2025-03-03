// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

/// Mocked implementation of `FlutterBinaryMessenger` protocol that exists to allow constructing
/// a `CameraPlugin` instance for testing. It contains an empty implementation for all protocol
/// methods.
@interface MockFlutterBinaryMessenger : NSObject <FlutterBinaryMessenger>
@end
