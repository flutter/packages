// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import AVFoundation;

/// Mock implementation of `FLTAssetWriter` protocol which allows injecting a custom
/// implementation.
@interface MockAssetWriter : NSObject <FLTAssetWriter>

// Properties re-declared as read/write so a mocked value can be set during testing.
@property(nonatomic, strong) NSError *error;

// Stubs that are called when the corresponding public method is called.
@property(nonatomic, copy) AVAssetWriterStatus (^statusStub)(void);
@property(nonatomic, copy) void (^getStatusStub)(void);
@property(nonatomic, copy) void (^startWritingStub)(void);
@property(nonatomic, copy) void (^finishWritingStub)(void (^)(void));

@end

/// Mock implementation of `FLTAssetWriterInput` protocol which allows injecting a custom
/// implementation.
@interface MockAssetWriterInput : NSObject <FLTAssetWriterInput>

// Properties re-declared as read/write so a mocked value can be set during testing.
@property(nonatomic, strong) AVAssetWriterInput *input;
@property(nonatomic, assign) BOOL readyForMoreMediaData;
@property(nonatomic, assign) BOOL expectsMediaDataInRealTime;

// Stub that is called when the `appendSampleBuffer` method is called.
@property(nonatomic, copy) BOOL (^appendSampleBufferStub)(CMSampleBufferRef);

@end

/// Mock implementation of `FLTAssetWriterInput` protocol which allows injecting a custom
/// implementation.
@interface MockAssetWriterInputPixelBufferAdaptor : NSObject <FLTAssetWriterInputPixelBufferAdaptor>

// Stub that is called when the `appendPixelBuffer` method is called.
@property(nonatomic, copy) BOOL (^appendPixelBufferStub)(CVPixelBufferRef, CMTime);

@end
