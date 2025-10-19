// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Dispatch

/// Queue-specific context data to be associated with the capture session queue.
let captureSessionQueueSpecificKey = DispatchSpecificKey<String>()
let captureSessionQueueSpecificValue = "capture_session_queue"
