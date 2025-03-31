// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// A protocol that is a direct passthrough to `AVAssetWriter`. It is used to allow for mocking
/// `AVAssetWriter` in tests.
@protocol FLTAssetWriter <NSObject>

@property(nonatomic, readonly) AVAssetWriterStatus status;
@property(readonly, nullable) NSError *error;

- (BOOL)startWriting;
- (void)finishWritingWithCompletionHandler:(void (^)(void))handler;
- (void)startSessionAtSourceTime:(CMTime)startTime;
- (void)addInput:(AVAssetWriterInput *)input;

@end

/// A protocol that is a direct passthrough to `AVAssetWriterInput`. It is used to allow for mocking
/// `AVAssetWriterInput` in tests.
@protocol FLTAssetWriterInput <NSObject>

/// The underlying `AVAssetWriterInput` instance. All method and property calls will be forwarded
/// to this instance.
@property(nonatomic, readonly) AVAssetWriterInput *input;

@property(nonatomic, assign) BOOL expectsMediaDataInRealTime;
@property(nonatomic, readonly) BOOL readyForMoreMediaData;

- (BOOL)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

/// A protocol that is a direct passthrough to `AVAssetWriterInputPixelBufferAdaptor`. It is used to
/// allow for mocking `AVAssetWriterInputPixelBufferAdaptor` in tests.
@protocol FLTAssetWriterInputPixelBufferAdaptor <NSObject>
- (BOOL)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer
     withPresentationTime:(CMTime)presentationTime;
@end

/// A default implementation of `FLTAssetWriter` which creates an `AVAssetWriter` instance and
/// forwards calls to it.
@interface FLTDefaultAssetWriter : NSObject <FLTAssetWriter>

/// Creates an `AVAssetWriter` instance with the given URL and file type. It takes the same params
/// as the `AVAssetWriter`'s initializer.
- (instancetype)initWithURL:(NSURL *)url fileType:(AVFileType)fileType error:(NSError **)error;

@end

/// A default implementation of `FLTAssetWriterInput` which forwards calls to the
/// underlying `AVAssetWriterInput`.
@interface FLTDefaultAssetWriterInput : NSObject <FLTAssetWriterInput>

/// Creates a wrapper around the `input` which will forward calls to it.
- (instancetype)initWithInput:(AVAssetWriterInput *)input;

@end

/// A default implementation of `FLTAssetWriterInputPixelBufferAdaptor` which forwards calls to the
/// underlying `AVAssetWriterInputPixelBufferAdaptor`.
@interface FLTDefaultAssetWriterInputPixelBufferAdaptor
    : NSObject <FLTAssetWriterInputPixelBufferAdaptor>

/// Creates a wrapper around the `adaptor` which will forward calls to it.
- (instancetype)initWithAdaptor:(AVAssetWriterInputPixelBufferAdaptor *)adaptor;

@end

NS_ASSUME_NONNULL_END
