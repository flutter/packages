// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockCapturePhotoSettings.h"

@implementation MockCapturePhotoSettings
@end

@implementation MockCapturePhotoSettingsFactory

- (id<FLTCapturePhotoSettings>)createPhotoSettings {
  return self.createPhotoSettingsStub ? self.createPhotoSettingsStub()
                                      : [[MockCapturePhotoSettings alloc] init];
}

- (id<FLTCapturePhotoSettings>)createPhotoSettingsWithFormat:
    (NSDictionary<NSString *, id> *)format {
  return self.createPhotoSettingsWithFormatStub ? self.createPhotoSettingsWithFormatStub(format)
                                                : [[MockCapturePhotoSettings alloc] init];
}

@end
