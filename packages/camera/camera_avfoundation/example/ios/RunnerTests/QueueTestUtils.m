// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "QueueTestUtils.h"

@import camera_avfoundation;

void FLTDispatchQueueSetSpecific(dispatch_queue_t queue, const void *key) {
  dispatch_queue_set_specific(queue, key, (void *)key, NULL);
}
