// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart'
    show CameraPermissionsErrorData;
import 'package:camera_android_camerax/src/system_services.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'system_services_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestInstanceManagerHostApi, TestSystemServicesHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('SystemServices', () {
    tearDown(() => TestProcessCameraProviderHostApi.setup(null));

    test(
        'requestCameraPermissionsFromInstance completes normally without errors test',
        () async {
      final MockTestSystemServicesHostApi mockApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockApi);

      when(mockApi.requestCameraPermissions(true))
          .thenAnswer((_) async => null);

      await SystemServices.requestCameraPermissions(true);
      verify(mockApi.requestCameraPermissions(true));
    });

    test(
        'requestCameraPermissionsFromInstance throws CameraException if there was a request error',
        () {
      final MockTestSystemServicesHostApi mockApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockApi);
      final CameraPermissionsErrorData error = CameraPermissionsErrorData(
        errorCode: 'Test error code',
        description: 'Test error description',
      );

      when(mockApi.requestCameraPermissions(true))
          .thenAnswer((_) async => error);

      expect(
          () async => SystemServices.requestCameraPermissions(true),
          throwsA(isA<CameraException>()
              .having((CameraException e) => e.code, 'code', 'Test error code')
              .having((CameraException e) => e.description, 'description',
                  'Test error description')));
      verify(mockApi.requestCameraPermissions(true));
    });

    test('onCameraError adds new error to stream', () {
      const String testErrorDescription = 'Test error description!';
      SystemServices.cameraErrorStreamController.stream
          .listen((String errorDescription) {
        expect(errorDescription, equals(testErrorDescription));
      });
      SystemServicesFlutterApiImpl().onCameraError(testErrorDescription);
    });

    test('getTempFilePath completes normally', () async {
      final MockTestSystemServicesHostApi mockApi =
          MockTestSystemServicesHostApi();
      TestSystemServicesHostApi.setup(mockApi);
      const String testPath = '/test/path/';
      const String testPrefix = 'MOV';
      const String testSuffix = '.mp4';

      when(mockApi.getTempFilePath(testPrefix, testSuffix))
          .thenReturn(testPath + testPrefix + testSuffix);
      expect(await SystemServices.getTempFilePath(testPrefix, testSuffix),
          testPath + testPrefix + testSuffix);
      verify(mockApi.getTempFilePath(testPrefix, testSuffix));
    });
  });
}
