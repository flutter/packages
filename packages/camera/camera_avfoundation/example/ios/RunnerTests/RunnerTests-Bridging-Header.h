// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// FIXME Verify if all these imports are needed + sort imports
#import "camera_avfoundation/CameraPlugin.h"
#import "camera_avfoundation/CameraPlugin_Test.h"
#import "camera_avfoundation/FLTCam.h"
#import "camera_avfoundation/FLTCamConfiguration.h"
#import "camera_avfoundation/FLTCam_Test.h"
#import "camera_avfoundation/FLTSavePhotoDelegate.h"
#import "camera_avfoundation/FLTSavePhotoDelegate_Test.h"
#import "camera_avfoundation/FLTThreadSafeEventChannel.h"

// Mocks, utils, protocols
#import "CameraTestUtils.h"
#import "MockCameraDeviceDiscoverer.h"
#import "MockCaptureDevice.h"
#import "MockCaptureSession.h"
#import "MockDeviceOrientationProvider.h"
#import "MockEventChannel.h"
#import "MockFlutterBinaryMessenger.h"
#import "MockFlutterTextureRegistry.h"
#import "MockGlobalEventApi.h"
