// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCaptureConnection.h"

@interface FLTDefaultCaptureConnection ()
@property(nonatomic, strong) AVCaptureConnection *connection;
@end

@implementation FLTDefaultCaptureConnection

- (instancetype)initWithConnection:(AVCaptureConnection *)connection {
  self = [super init];
  if (self) {
    _connection = connection;
  }
  return self;
}

- (BOOL)isVideoMirroringSupported {
  return self.connection.isVideoMirroringSupported;
}

- (BOOL)isVideoOrientationSupported {
  return self.connection.isVideoOrientationSupported;
}

- (void)setVideoMirrored:(BOOL)videoMirrored {
  self.connection.videoMirrored = videoMirrored;
}

- (BOOL)isVideoMirrored {
  return self.connection.isVideoMirrored;
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation {
  self.connection.videoOrientation = videoOrientation;
}

- (AVCaptureVideoOrientation)videoOrientation {
  return self.connection.videoOrientation;
}

- (NSArray<AVCaptureInputPort *> *)inputPorts {
  return self.connection.inputPorts;
}

@end
