// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/QueueUtils.h"

void FLTEnsureToRunOnMainQueue(dispatch_block_t block) {
  if (!NSThread.isMainThread) {
    dispatch_async(dispatch_get_main_queue(), block);
  } else {
    block();
  }
}
