// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockAssetWriter.h"

@implementation MockAssetWriter
- (BOOL)startWriting {
  if (self.startWritingStub) {
    self.startWritingStub();
  }
  self.status = AVAssetWriterStatusWriting;
  return YES;
}

- (void)finishWritingWithCompletionHandler:(void (^)(void))handler {
  if (self.finishWritingStub) {
    self.finishWritingStub(handler);
  } else if (handler) {
    handler();
  }
}

- (void)startSessionAtSourceTime:(CMTime)startTime {
}

- (void)addInput:(nonnull AVAssetWriterInput *)input {
}

@end

@implementation MockAssetWriterInput
- (BOOL)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer {
  if (self.appendSampleBufferStub) {
    return self.appendSampleBufferStub(sampleBuffer);
  }
  return YES;
}
@end

@implementation MockPixelBufferAdaptor
- (BOOL)appendPixelBuffer:(nonnull CVPixelBufferRef)pixelBuffer
     withPresentationTime:(CMTime)presentationTime {
  if (self.appendPixelBufferStub) {
    return self.appendPixelBufferStub(pixelBuffer, presentationTime);
  }
  return YES;
}
@end
