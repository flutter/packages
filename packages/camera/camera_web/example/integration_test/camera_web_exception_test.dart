// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: implementation_imports
import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraWebException', () {
    testWidgets('sets all properties', (WidgetTester tester) async {
      const cameraId = 1;
      const CameraErrorCode code = CameraErrorCode.notFound;
      const description = 'The camera is not found.';

      final exception = CameraWebException(cameraId, code, description);

      expect(exception.cameraId, equals(cameraId));
      expect(exception.code, equals(code));
      expect(exception.description, equals(description));
    });

    testWidgets('toString includes all properties', (
      WidgetTester tester,
    ) async {
      const cameraId = 2;
      const CameraErrorCode code = CameraErrorCode.notReadable;
      const description = 'The camera is not readable.';

      final exception = CameraWebException(cameraId, code, description);

      expect(
        exception.toString(),
        equals('CameraWebException($cameraId, $code, $description)'),
      );
    });
  });
}
