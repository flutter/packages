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
  return _connection.isVideoMirroringSupported;
}

- (BOOL)isVideoOrientationSupported {
  return _connection.isVideoOrientationSupported;
}

- (void)setVideoMirrored:(BOOL)videoMirrored {
  _connection.videoMirrored = videoMirrored;
}

- (BOOL)isVideoMirrored {
  return _connection.isVideoMirrored;
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation {
  _connection.videoOrientation = videoOrientation;
}

- (AVCaptureVideoOrientation)videoOrientation {
  return _connection.videoOrientation;
}

- (NSArray<AVCaptureInputPort *> *)inputPorts {
  return _connection.inputPorts;
}

@end
