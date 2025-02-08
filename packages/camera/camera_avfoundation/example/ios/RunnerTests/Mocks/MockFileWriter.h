// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

@interface MockFileWriter : NSObject <FLTFileWriting>
@property(nonatomic, copy) BOOL (^writeToFileStub)
    (NSString *path, NSDataWritingOptions options, NSError **error);
@end
