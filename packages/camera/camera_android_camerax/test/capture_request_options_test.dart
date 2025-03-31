// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/capture_request_options.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'capture_request_options_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(
    <Type>[TestCaptureRequestOptionsHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('CaptureRequestOptions', () {
    tearDown(() {
      TestCaptureRequestOptionsHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('detached create does not make call on the Java side', () {
      final MockTestCaptureRequestOptionsHostApi mockApi =
          MockTestCaptureRequestOptionsHostApi();
      TestCaptureRequestOptionsHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final List<(CaptureRequestKeySupportedType, Object?)> options =
          <(CaptureRequestKeySupportedType, Object?)>[
        (CaptureRequestKeySupportedType.controlAeLock, true),
      ];

      CaptureRequestOptions.detached(
        requestedOptions: options,
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(
        argThat(isA<int>()),
        argThat(isA<Map<int, Object?>>()),
      ));
    }, skip: 'Flaky test: https://github.com/flutter/flutter/issues/164132');

    test(
        'create makes call on the Java side as expected for suppported null capture request options',
        () {
      final MockTestCaptureRequestOptionsHostApi mockApi =
          MockTestCaptureRequestOptionsHostApi();
      TestCaptureRequestOptionsHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final List<(CaptureRequestKeySupportedType key, Object? value)>
          supportedOptionsForTesting = <(
        CaptureRequestKeySupportedType key,
        Object? value
      )>[(CaptureRequestKeySupportedType.controlAeLock, null)];

      final CaptureRequestOptions instance = CaptureRequestOptions(
        requestedOptions: supportedOptionsForTesting,
        instanceManager: instanceManager,
      );

      final VerificationResult verificationResult = verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        captureAny,
      ));
      final Map<int?, Object?> captureRequestOptions =
          verificationResult.captured.single as Map<int?, Object?>;

      expect(captureRequestOptions.length,
          equals(supportedOptionsForTesting.length));
      for (final (CaptureRequestKeySupportedType key, Object? value) option
          in supportedOptionsForTesting) {
        final CaptureRequestKeySupportedType optionKey = option.$1;
        expect(captureRequestOptions[optionKey.index], isNull);
      }
    });

    test(
        'create makes call on the Java side as expected for suppported non-null capture request options',
        () {
      final MockTestCaptureRequestOptionsHostApi mockApi =
          MockTestCaptureRequestOptionsHostApi();
      TestCaptureRequestOptionsHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final List<(CaptureRequestKeySupportedType key, Object? value)>
          supportedOptionsForTesting = <(
        CaptureRequestKeySupportedType key,
        Object? value
      )>[(CaptureRequestKeySupportedType.controlAeLock, false)];

      final CaptureRequestOptions instance = CaptureRequestOptions(
        requestedOptions: supportedOptionsForTesting,
        instanceManager: instanceManager,
      );

      final VerificationResult verificationResult = verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        captureAny,
      ));
      final Map<int?, Object?>? captureRequestOptions =
          verificationResult.captured.single as Map<int?, Object?>?;

      expect(captureRequestOptions!.length,
          equals(supportedOptionsForTesting.length));
      for (final (CaptureRequestKeySupportedType key, Object? value) option
          in supportedOptionsForTesting) {
        final CaptureRequestKeySupportedType optionKey = option.$1;
        final Object? optionValue = option.$2;

        switch (optionKey) {
          case CaptureRequestKeySupportedType.controlAeLock:
            expect(captureRequestOptions[optionKey.index],
                equals(optionValue! as bool));
          // This ignore statement is safe beause this will test when
          // a new CaptureRequestKeySupportedType is being added, but the logic in
          // in the CaptureRequestOptions class has not yet been updated.
          // ignore: no_default_cases, unreachable_switch_default
          default:
            fail(
                'Option $option contains unrecognized CaptureRequestKeySupportedType key ${option.$1}');
        }
      }
    });
  });
}
