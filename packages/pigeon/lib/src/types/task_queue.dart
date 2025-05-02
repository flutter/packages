// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Type of TaskQueue which determines how handlers are dispatched for
/// HostApi's.
enum TaskQueueType {
  /// Handlers are invoked serially on the default thread. This is the value if
  /// unspecified.
  serial,

  /// Handlers are invoked serially on a background thread.
  serialBackgroundThread,

  // TODO(gaaclarke): Add support for concurrent task queues.
  // /// Handlers are invoked concurrently on a background thread.
  // concurrentBackgroundThread,
}
