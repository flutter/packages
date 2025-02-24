// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockAssetWriter.h"

@implementation MockAssetWriter

- (BOOL)startWriting {
  if (self.startWritingStub) {
    self.startWritingStub();
  }
  return YES;
}

- (AVAssetWriterStatus)status {
  if (_statusStub) {
    return _statusStub();
  }
  return AVAssetWriterStatusUnknown;
}

- (void)finishWritingWithCompletionHandler:(void (^)(void))handler {
  if (self.finishWritingStub) {
    self.finishWritingStub(handler);
  }
}

- (void)startSessionAtSourceTime:(CMTime)startTime {
}

- (void)addInput:(AVAssetWriterInput *)input {
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

@implementation MockAssetWriterInputPixelBufferAdaptor

- (BOOL)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer
     withPresentationTime:(CMTime)presentationTime {
  if (self.appendPixelBufferStub) {
    return self.appendPixelBufferStub(pixelBuffer, presentationTime);
  }
  return YES;
}

@end
