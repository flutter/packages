// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@interface FLTImageStreamHandler : NSObject <FlutterStreamHandler>

- (instancetype)initWithCaptureSessionQueue:(dispatch_queue_t)captureSessionQueue;

/// The queue on which `eventSink` property should be accessed.
@property(nonatomic, strong) dispatch_queue_t captureSessionQueue;

/// The event sink to stream camera events to Dart.
///
/// The property should only be accessed on `captureSessionQueue`.
/// The block itself should be invoked on the main queue.
@property FlutterEventSink eventSink;

@end
