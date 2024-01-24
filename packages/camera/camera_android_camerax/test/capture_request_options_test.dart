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

@GenerateMocks(<Type>[
  CaptureRequestOption,
  TestCaptureRequestOptionsHostApi,
  TestInstanceManagerHostApi
])
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

      final List<(CaptureRequestKeySupportedType, dynamic)> options =
          <(CaptureRequestKeySupportedType, dynamic)>[
        (CaptureRequestKeySupportedType.controlAeLock, true),
      ];

      CaptureRequestOptions.detached(
        requestedOptions: options,
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(
        argThat(isA<int>()),
        argThat(isA<List<CaptureRequestOption>>()),
      ));
    });

    test(
        'create makes call on the Java side as expected for suppported capture request options',
        () {
      final MockTestCaptureRequestOptionsHostApi mockApi =
          MockTestCaptureRequestOptionsHostApi();
      TestCaptureRequestOptionsHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final List<(CaptureRequestKeySupportedType key, dynamic value)>
          supportedOptionsForTesting =
          <(CaptureRequestKeySupportedType key, dynamic value)>[
        (CaptureRequestKeySupportedType.controlAeLock, null),
        (CaptureRequestKeySupportedType.controlAeLock, false)
      ];

      final CaptureRequestOptions instance = CaptureRequestOptions(
        requestedOptions: supportedOptionsForTesting,
        instanceManager: instanceManager,
      );

      final VerificationResult verificationResult = verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        captureAny,
      ));
      final List<CaptureRequestOption?> captureRequestOptions =
          verificationResult.captured.single as List<CaptureRequestOption?>;

      expect(captureRequestOptions.length,
          equals(supportedOptionsForTesting.length));
      for (int i = 0; i < supportedOptionsForTesting.length; i++) {
        final (CaptureRequestKeySupportedType key, dynamic value) option =
            supportedOptionsForTesting[i];
        final CaptureRequestOption expectedCaptureRequestOption =
            captureRequestOptions[i]!;
        final CaptureRequestKeySupportedType optionKey = option.$1;
        final dynamic optionValue = option.$2;

        if (optionValue == null) {
          expect(expectedCaptureRequestOption.value, '');
          continue;
        }

        switch (optionKey) {
          case CaptureRequestKeySupportedType.controlAeLock:
            expect(expectedCaptureRequestOption.value,
                equals(optionValue == true ? 'true' : 'false'));
          // This ignore statement is safe beause this will test when
          // a new CaptureRequestKeySupportedType is being added, but the logic in
          // in the CaptureRequestOptions class has not yet been updated.
          // ignore: no_default_cases
          default:
            fail(
                'Option $option contains unrecognized CaptureRequestKeySupportedType key ${option.$1}');
        }
      }
    });
  });
}
