// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/recording.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'recording_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestRecordingHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('Recording', () {
    tearDown(() => TestRecorderHostApi.setup(null));

    test('close calls close on Java side', () async {
      final MockTestRecordingHostApi mockApi = MockTestRecordingHostApi();
      TestRecordingHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final Recording recording =
          Recording.detached(instanceManager: instanceManager);
      const int recordingId = 0;
      when(mockApi.close(recordingId)).thenAnswer((_) {});
      instanceManager.addHostCreatedInstance(recording, recordingId,
          onCopy: (_) => Recording.detached(instanceManager: instanceManager));

      recording.close();

      verify(mockApi.close(recordingId));
    });

    test('pause calls pause on Java side', () async {
      final MockTestRecordingHostApi mockApi = MockTestRecordingHostApi();
      TestRecordingHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final Recording recording =
          Recording.detached(instanceManager: instanceManager);
      const int recordingId = 0;
      when(mockApi.pause(recordingId)).thenAnswer((_) {});
      instanceManager.addHostCreatedInstance(recording, recordingId,
          onCopy: (_) => Recording.detached(instanceManager: instanceManager));

      recording.pause();

      verify(mockApi.pause(recordingId));
    });

    test('resume calls resume on Java side', () async {
      final MockTestRecordingHostApi mockApi = MockTestRecordingHostApi();
      TestRecordingHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final Recording recording =
          Recording.detached(instanceManager: instanceManager);
      const int recordingId = 0;
      when(mockApi.resume(recordingId)).thenAnswer((_) {});
      instanceManager.addHostCreatedInstance(recording, recordingId,
          onCopy: (_) => Recording.detached(instanceManager: instanceManager));

      recording.resume();

      verify(mockApi.resume(recordingId));
    });

    test('stop calls stop on Java side', () async {
      final MockTestRecordingHostApi mockApi = MockTestRecordingHostApi();
      TestRecordingHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final Recording recording =
          Recording.detached(instanceManager: instanceManager);
      const int recordingId = 0;
      when(mockApi.stop(recordingId)).thenAnswer((_) {});
      instanceManager.addHostCreatedInstance(recording, recordingId,
          onCopy: (_) => Recording.detached(instanceManager: instanceManager));

      recording.stop();

      verify(mockApi.stop(recordingId));
    });

    test('flutterApiCreateTest', () async {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final RecordingFlutterApi flutterApi = RecordingFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0);

      expect(instanceManager.getInstanceWithWeakReference(0), isA<Recording>());
    });
  });
}
