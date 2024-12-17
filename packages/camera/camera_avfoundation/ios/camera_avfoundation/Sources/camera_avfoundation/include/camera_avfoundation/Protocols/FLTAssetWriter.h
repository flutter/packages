// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@protocol FLTAssetWriter <NSObject>
@property(nonatomic, readonly) AVAssetWriterStatus status;
@property (readonly, nullable) NSError *error;
- (BOOL)startWriting;
- (void)finishWritingWithCompletionHandler:(void (^)(void))handler;
- (void)startSessionAtSourceTime:(CMTime)startTime;
- (void)addInput:(AVAssetWriterInput *)input;
@end

@protocol FLTAssetWriterInput <NSObject>
@property(nonatomic, readonly) BOOL expectsMediaDataInRealTime;
@property(nonatomic, readonly) BOOL isReadyForMoreMediaData;
- (BOOL)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

@protocol FLTPixelBufferAdaptor <NSObject>
- (BOOL)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer
    withPresentationTime:(CMTime)presentationTime;
@end

@interface FLTDefaultAssetWriter : NSObject <FLTAssetWriter>
- (instancetype)initWithURL:(NSURL *)url fileType:(AVFileType)fileType error:(NSError **)error;
@end

@interface FLTDefaultAssetWriterInput : NSObject <FLTAssetWriterInput>
- (instancetype)initWithInput:(AVAssetWriterInput *)input;
@end

@interface FLTDefaultPixelBufferAdaptor : NSObject <FLTPixelBufferAdaptor>
- (instancetype)initWithAdaptor:(AVAssetWriterInputPixelBufferAdaptor *)adaptor;
@end

NS_ASSUME_NONNULL_END
