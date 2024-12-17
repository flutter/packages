// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/camera_avfoundation/Protocols/FLTAssetWriter.h"

@interface FLTDefaultAssetWriter ()
@property(nonatomic, strong) AVAssetWriter *writer;
@end

@implementation FLTDefaultAssetWriter

- (instancetype)initWithURL:(NSURL *)url fileType:(AVFileType)fileType error:(NSError **)error {
  self = [super init];
  if (self) {
    _writer = [[AVAssetWriter alloc] initWithURL:url fileType:fileType error:error];
  }
  return self;
}

- (BOOL)startWriting {
  return [self.writer startWriting];
}

- (void)finishWritingWithCompletionHandler:(void (^)(void))handler {
  [self.writer finishWritingWithCompletionHandler:handler];
}

- (AVAssetWriterStatus)status {
  return _writer.status;
}

- (NSError *)error {
  return _writer.error;
}

- (void)startSessionAtSourceTime:(CMTime)startTime {
  return [_writer startSessionAtSourceTime:startTime];
}

- (void)addInput:(AVAssetWriterInput *)input {
  return [_writer addInput:input];
}

@end

@interface FLTDefaultAssetWriterInput ()
@property(nonatomic, strong) AVAssetWriterInput *input;
@end

@implementation FLTDefaultAssetWriterInput

- (instancetype)initWithInput:(AVAssetWriterInput *)input {
  self = [super init];
  if (self) {
    _input = input;
  }
  return self;
}

- (BOOL)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer {
  return [self.input appendSampleBuffer:sampleBuffer];
}

- (BOOL)expectsMediaDataInRealTime {
  return [self.input expectsMediaDataInRealTime];
}

- (BOOL)isReadyForMoreMediaData {
  return [self.input isReadyForMoreMediaData];
}

@end

@interface FLTDefaultPixelBufferAdaptor ()
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;
@end

@implementation FLTDefaultPixelBufferAdaptor

- (nonnull instancetype)initWithAdaptor:(nonnull AVAssetWriterInputPixelBufferAdaptor *)adaptor {
  self = [super init];
  if (self) {
    _adaptor = adaptor;
  }
  return self;
}

- (BOOL)appendPixelBuffer:(nonnull CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime { 
  return [_adaptor appendPixelBuffer:pixelBuffer withPresentationTime:presentationTime];
}

@end
