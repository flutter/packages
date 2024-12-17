// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

@interface MockAssetWriter : NSObject <FLTAssetWriter>
@property(nonatomic, assign) AVAssetWriterStatus status;
@property(nonatomic, copy) void (^getStatusStub)(void);
@property(nonatomic, copy) void (^startWritingStub)(void);
@property(nonatomic, copy) void (^finishWritingStub)(void (^)(void));
@property(nonatomic, strong) NSError *error;
@end

@interface MockAssetWriterInput : NSObject <FLTAssetWriterInput>
@property(nonatomic, assign) BOOL isReadyForMoreMediaData;
@property(nonatomic, assign) BOOL expectsMediaDataInRealTime;
@property(nonatomic, copy) BOOL (^appendSampleBufferStub)(CMSampleBufferRef);
@end

@interface MockPixelBufferAdaptor : NSObject <FLTPixelBufferAdaptor>
@property(nonatomic, copy) BOOL (^appendPixelBufferStub)(CVPixelBufferRef, CMTime);
@end
