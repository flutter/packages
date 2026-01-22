// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Dispatch
import Foundation

/// Queue-specific context data to be associated with the capture session queue.
let captureSessionQueueSpecificKey = DispatchSpecificKey<String>()
let captureSessionQueueSpecificValue = "capture_session_queue"

/// Ensures the given block to be run on the main queue.
/// If caller site is already on the main queue, the block will be run
/// synchronously. Otherwise, the block will be dispatched asynchronously to the
/// main queue.
/// block - the block to be run on the main queue.
func ensureToRunOnMainQueue(_ block: @escaping () -> Void) {
  if Thread.isMainThread {
    block()
  } else {
    DispatchQueue.main.async {
      block()
    }
  }
}
