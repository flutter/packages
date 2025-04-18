// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Calls `dispatch_queue_set_specific` with a key that is used to identify the queue.
/// This method is needed for comaptibility of Swift tests with Objective-C code.
/// In Swift, the API for settinng key-value pairs on a queue is different, so Swift tests
/// need to call this method to set the key-value pair on the queue in a way that's
/// compatible with the existing Objective-C code.
extern void FLTDispatchQueueSetSpecific(dispatch_queue_t queue, const void *key);

NS_ASSUME_NONNULL_END
