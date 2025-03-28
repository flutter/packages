// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockCapturePhotoOutput.h"

@implementation MockCapturePhotoOutput
- (void)capturePhotoWithSettings:(AVCapturePhotoSettings *)settings
                        delegate:(id<AVCapturePhotoCaptureDelegate>)delegate {
  if (self.capturePhotoWithSettingsStub) {
    self.capturePhotoWithSettingsStub(settings, delegate);
  }
}

- (nullable NSObject<FLTCaptureConnection> *)connectionWithMediaType:
    (nonnull AVMediaType)mediaType {
  if (self.connectionWithMediaTypeStub) {
    return self.connectionWithMediaTypeStub(mediaType);
  } else {
    return NULL;
  }
}

@end
