// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: implementation_imports
import 'dart:js_interop';

import 'package:camera_web/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart';

import 'helpers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CameraErrorCode', () {
    group('toString returns a correct type for', () {
      testWidgets('notSupported', (WidgetTester tester) async {
        expect(
          CameraErrorCode.notSupported.toString(),
          equals('cameraNotSupported'),
        );
      });

      testWidgets('notFound', (WidgetTester tester) async {
        expect(
          CameraErrorCode.notFound.toString(),
          equals('cameraNotFound'),
        );
      });

      testWidgets('notReadable', (WidgetTester tester) async {
        expect(
          CameraErrorCode.notReadable.toString(),
          equals('cameraNotReadable'),
        );
      });

      testWidgets('overconstrained', (WidgetTester tester) async {
        expect(
          CameraErrorCode.overconstrained.toString(),
          equals('cameraOverconstrained'),
        );
      });

      testWidgets('permissionDenied', (WidgetTester tester) async {
        expect(
          CameraErrorCode.permissionDenied.toString(),
          equals('CameraAccessDenied'),
        );
      });

      testWidgets('type', (WidgetTester tester) async {
        expect(
          CameraErrorCode.type.toString(),
          equals('cameraType'),
        );
      });

      testWidgets('abort', (WidgetTester tester) async {
        expect(
          CameraErrorCode.abort.toString(),
          equals('cameraAbort'),
        );
      });

      testWidgets('security', (WidgetTester tester) async {
        expect(
          CameraErrorCode.security.toString(),
          equals('cameraSecurity'),
        );
      });

      testWidgets('missingMetadata', (WidgetTester tester) async {
        expect(
          CameraErrorCode.missingMetadata.toString(),
          equals('cameraMissingMetadata'),
        );
      });

      testWidgets('orientationNotSupported', (WidgetTester tester) async {
        expect(
          CameraErrorCode.orientationNotSupported.toString(),
          equals('orientationNotSupported'),
        );
      });

      testWidgets('torchModeNotSupported', (WidgetTester tester) async {
        expect(
          CameraErrorCode.torchModeNotSupported.toString(),
          equals('torchModeNotSupported'),
        );
      });

      testWidgets('zoomLevelNotSupported', (WidgetTester tester) async {
        expect(
          CameraErrorCode.zoomLevelNotSupported.toString(),
          equals('zoomLevelNotSupported'),
        );
      });

      testWidgets('zoomLevelInvalid', (WidgetTester tester) async {
        expect(
          CameraErrorCode.zoomLevelInvalid.toString(),
          equals('zoomLevelInvalid'),
        );
      });

      testWidgets('notStarted', (WidgetTester tester) async {
        expect(
          CameraErrorCode.notStarted.toString(),
          equals('cameraNotStarted'),
        );
      });

      testWidgets('videoRecordingNotStarted', (WidgetTester tester) async {
        expect(
          CameraErrorCode.videoRecordingNotStarted.toString(),
          equals('videoRecordingNotStarted'),
        );
      });

      testWidgets('unknown', (WidgetTester tester) async {
        expect(
          CameraErrorCode.unknown.toString(),
          equals('cameraUnknown'),
        );
      });

      group('fromMediaError', () {
        testWidgets('with aborted error code', (WidgetTester tester) async {
          expect(
            CameraErrorCode.fromMediaError(
              createJSInteropWrapper(
                  FakeMediaError(MediaError.MEDIA_ERR_ABORTED)) as MediaError,
            ).toString(),
            equals('mediaErrorAborted'),
          );
        });

        testWidgets('with network error code', (WidgetTester tester) async {
          expect(
            CameraErrorCode.fromMediaError(
              createJSInteropWrapper(
                  FakeMediaError(MediaError.MEDIA_ERR_NETWORK)) as MediaError,
            ).toString(),
            equals('mediaErrorNetwork'),
          );
        });

        testWidgets('with decode error code', (WidgetTester tester) async {
          expect(
            CameraErrorCode.fromMediaError(
              createJSInteropWrapper(
                  FakeMediaError(MediaError.MEDIA_ERR_DECODE)) as MediaError,
            ).toString(),
            equals('mediaErrorDecode'),
          );
        });

        testWidgets('with source not supported error code',
            (WidgetTester tester) async {
          expect(
            CameraErrorCode.fromMediaError(
              createJSInteropWrapper(
                      FakeMediaError(MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED))
                  as MediaError,
            ).toString(),
            equals('mediaErrorSourceNotSupported'),
          );
        });

        testWidgets('with unknown error code', (WidgetTester tester) async {
          expect(
            CameraErrorCode.fromMediaError(
              createJSInteropWrapper(FakeMediaError(5)) as MediaError,
            ).toString(),
            equals('mediaErrorUnknown'),
          );
        });
      });
    });
  });
}
