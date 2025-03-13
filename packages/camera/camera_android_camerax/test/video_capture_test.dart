// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/recorder.dart';
import 'package:camera_android_camerax/src/surface.dart';
import 'package:camera_android_camerax/src/video_capture.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'test_camerax_library.g.dart';
import 'video_capture_test.mocks.dart';

@GenerateMocks(
    <Type>[TestVideoCaptureHostApi, TestInstanceManagerHostApi, Recorder])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  test('withOutput calls the Java side and returns correct video capture',
      () async {
    final MockTestVideoCaptureHostApi mockApi = MockTestVideoCaptureHostApi();
    TestVideoCaptureHostApi.setup(mockApi);

    final InstanceManager instanceManager = InstanceManager(
      onWeakReferenceRemoved: (_) {},
    );

    final Recorder mockRecorder = MockRecorder();
    const int mockRecorderId = 2;
    instanceManager.addHostCreatedInstance(mockRecorder, mockRecorderId,
        onCopy: (_) => MockRecorder());

    final VideoCapture videoCapture =
        VideoCapture.detached(instanceManager: instanceManager);
    const int videoCaptureId = 3;
    instanceManager.addHostCreatedInstance(videoCapture, videoCaptureId,
        onCopy: (_) => VideoCapture.detached(instanceManager: instanceManager));

    when(mockApi.withOutput(mockRecorderId)).thenReturn(videoCaptureId);

    expect(
        await VideoCapture.withOutput(mockRecorder,
            instanceManager: instanceManager),
        videoCapture);
    verify(mockApi.withOutput(mockRecorderId));
  });

  test(
      'setTargetRotation makes call to set target rotation for VideoCapture instance',
      () async {
    final MockTestVideoCaptureHostApi mockApi = MockTestVideoCaptureHostApi();
    TestVideoCaptureHostApi.setup(mockApi);

    final InstanceManager instanceManager = InstanceManager(
      onWeakReferenceRemoved: (_) {},
    );
    const int targetRotation = Surface.rotation180;
    final VideoCapture videoCapture = VideoCapture.detached(
      instanceManager: instanceManager,
    );
    instanceManager.addHostCreatedInstance(
      videoCapture,
      0,
      onCopy: (_) => VideoCapture.detached(instanceManager: instanceManager),
    );

    await videoCapture.setTargetRotation(targetRotation);

    verify(mockApi.setTargetRotation(
        instanceManager.getIdentifier(videoCapture), targetRotation));
  });

  test('getOutput calls the Java side and returns correct Recorder', () async {
    final MockTestVideoCaptureHostApi mockApi = MockTestVideoCaptureHostApi();
    TestVideoCaptureHostApi.setup(mockApi);
    final InstanceManager instanceManager = InstanceManager(
      onWeakReferenceRemoved: (_) {},
    );

    final VideoCapture videoCapture =
        VideoCapture.detached(instanceManager: instanceManager);
    const int videoCaptureId = 2;
    instanceManager.addHostCreatedInstance(videoCapture, videoCaptureId,
        onCopy: (_) => VideoCapture.detached(instanceManager: instanceManager));

    final Recorder mockRecorder = MockRecorder();
    const int mockRecorderId = 3;
    instanceManager.addHostCreatedInstance(mockRecorder, mockRecorderId,
        onCopy: (_) => Recorder.detached(instanceManager: instanceManager));

    when(mockApi.getOutput(videoCaptureId)).thenReturn(mockRecorderId);
    expect(await videoCapture.getOutput(), mockRecorder);
    verify(mockApi.getOutput(videoCaptureId));
  });

  test('flutterApiCreateTest', () async {
    final InstanceManager instanceManager = InstanceManager(
      onWeakReferenceRemoved: (_) {},
    );

    final VideoCaptureFlutterApi flutterApi = VideoCaptureFlutterApiImpl(
      instanceManager: instanceManager,
    );

    flutterApi.create(0);

    expect(
        instanceManager.getInstanceWithWeakReference(0), isA<VideoCapture>());
  });
}
