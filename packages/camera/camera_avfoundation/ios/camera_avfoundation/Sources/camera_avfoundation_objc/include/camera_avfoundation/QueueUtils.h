// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Queue-specific context data to be associated with the capture session queue.
extern const char* FLTCaptureSessionQueueSpecific;

/// Ensures the given block to be run on the main queue.
/// If caller site is already on the main queue, the block will be run
/// synchronously. Otherwise, the block will be dispatched asynchronously to the
/// main queue.
/// @param block the block to be run on the main queue.
extern void FLTEnsureToRunOnMainQueue(dispatch_block_t block);

/// Calls `dispatch_queue_set_specific` with a key that is used to identify the
/// queue. This method is needed for compatibility of Swift implementation with
/// Objective-C code. In Swift, the API for setting key-value pairs on a queue
/// is different, so Swift code need to call this method to set the key-value
/// pair on the queue in a way that's compatible with the existing Objective-C
/// code.
extern void FLTDispatchQueueSetSpecific(dispatch_queue_t queue,
                                        const void* key);

NS_ASSUME_NONNULL_END
