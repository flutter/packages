// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTAssetWriter.h"

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
  return [_writer startWriting];
}

- (void)finishWritingWithCompletionHandler:(void (^)(void))handler {
  [_writer finishWritingWithCompletionHandler:handler];
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
  return [_input appendSampleBuffer:sampleBuffer];
}

- (BOOL)expectsMediaDataInRealTime {
  return [_input expectsMediaDataInRealTime];
}

- (void)setExpectsMediaDataInRealTime:(BOOL)expectsMediaDataInRealTime {
  _input.expectsMediaDataInRealTime = expectsMediaDataInRealTime;
}

- (BOOL)readyForMoreMediaData {
  return _input.readyForMoreMediaData;
}

@end

@interface FLTDefaultAssetWriterInputPixelBufferAdaptor ()
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;
@end

@implementation FLTDefaultAssetWriterInputPixelBufferAdaptor

- (instancetype)initWithAdaptor:(AVAssetWriterInputPixelBufferAdaptor *)adaptor {
  self = [super init];
  if (self) {
    _adaptor = adaptor;
  }
  return self;
}

- (BOOL)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer
     withPresentationTime:(CMTime)presentationTime {
  return [_adaptor appendPixelBuffer:pixelBuffer withPresentationTime:presentationTime];
}

@end
