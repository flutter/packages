// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

/// A mock implementation of `FLTWritableData` that allows injecting a custom implementation
/// for writing to a file.
@interface MockWritableData : NSObject <FLTWritableData>

/// A stub that replaces the default implementation of `writeToFile:options:error:`.
@property(nonatomic, copy) BOOL (^writeToFileStub)
    (NSString *path, NSDataWritingOptions options, NSError **error);

@end
