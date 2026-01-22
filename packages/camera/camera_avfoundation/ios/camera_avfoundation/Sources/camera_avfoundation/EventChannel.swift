// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

/// A protocol which is a direct passthrough to FlutterEventChannel.
/// It exists to allow replacing FlutterEventChannel in tests.
protocol EventChannel {
  func setStreamHandler(_ handler: (any FlutterStreamHandler & NSObjectProtocol)?)
}

extension FlutterEventChannel: EventChannel {}
