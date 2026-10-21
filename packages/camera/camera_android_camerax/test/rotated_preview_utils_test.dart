// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.dart';
import 'package:camera_android_camerax/src/rotated_preview_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

TransformationInfo _createTransformationInfo({
  required int rotationDegrees,
  bool hasCameraTransform = false,
  bool isMirroring = false,
}) {
  return TransformationInfo.pigeon_detached(
    rotationDegrees: rotationDegrees,
    hasCameraTransform: hasCameraTransform,
    isMirroring: isMirroring,
  );
}

void main() {
  const surfaceRotations = <int>[
    Surface.rotation0,
    Surface.rotation90,
    Surface.rotation180,
    Surface.rotation270,
  ];

  group('computeUntransformedPreviewRotation', () {
    test('uses the sensor orientation and display rotation when TransformationInfo is null', () {
      // Back cameras: sensor - display.
      expect(
        computeUntransformedPreviewRotation(
          transformationInfo: null,
          cameraIsFrontFacing: false,
          sensorOrientationDegrees: 90,
          displayRotation: Surface.rotation90,
          previewTargetRotation: Surface.rotation0,
        ),
        0,
      );
      expect(
        computeUntransformedPreviewRotation(
          transformationInfo: null,
          cameraIsFrontFacing: false,
          sensorOrientationDegrees: 90,
          displayRotation: Surface.rotation270,
          previewTargetRotation: Surface.rotation0,
        ),
        180,
      );

      // Front cameras: sensor + display.
      expect(
        computeUntransformedPreviewRotation(
          transformationInfo: null,
          cameraIsFrontFacing: true,
          sensorOrientationDegrees: 270,
          displayRotation: Surface.rotation90,
          previewTargetRotation: Surface.rotation0,
        ),
        0,
      );
      expect(
        computeUntransformedPreviewRotation(
          transformationInfo: null,
          cameraIsFrontFacing: true,
          sensorOrientationDegrees: 270,
          displayRotation: Surface.rotation180,
          previewTargetRotation: Surface.rotation0,
        ),
        90,
      );
    });

    test('uses rotationDegrees instead of the sensor orientation when the surface does not have '
        'the camera transform', () {
      // Simulates a buffer that CameraX already rotated (e.g. under stream
      // sharing), so its rotationDegrees no longer matches the sensor orientation.
      expect(
        computeUntransformedPreviewRotation(
          transformationInfo: _createTransformationInfo(rotationDegrees: 0),
          cameraIsFrontFacing: false,
          sensorOrientationDegrees: 90,
          displayRotation: Surface.rotation0,
          previewTargetRotation: Surface.rotation0,
        ),
        0,
      );
    });

    test('uses the sensor orientation when the surface has the camera transform', () {
      for (final cameraIsFrontFacing in <bool>[true, false]) {
        for (final displayRotation in surfaceRotations) {
          final int sensorBasedRotation = computeUntransformedPreviewRotation(
            transformationInfo: null,
            cameraIsFrontFacing: cameraIsFrontFacing,
            sensorOrientationDegrees: 90,
            displayRotation: displayRotation,
            previewTargetRotation: Surface.rotation0,
          );

          // rotationDegrees and isMirroring are deliberately inconsistent with
          // the sensor orientation to show they are ignored.
          for (final isMirroring in <bool>[true, false]) {
            expect(
              computeUntransformedPreviewRotation(
                transformationInfo: _createTransformationInfo(
                  rotationDegrees: 180,
                  hasCameraTransform: true,
                  isMirroring: isMirroring,
                ),
                cameraIsFrontFacing: cameraIsFrontFacing,
                sensorOrientationDegrees: 90,
                displayRotation: displayRotation,
                previewTargetRotation: Surface.rotation0,
              ),
              sensorBasedRotation,
              reason:
                  'front facing: $cameraIsFrontFacing, display rotation: $displayRotation, '
                  'isMirroring: $isMirroring',
            );
          }
        }
      }
    });

    test('shifts rotationDegrees by the change in display rotation since the target rotation', () {
      // Back camera (raw buffer, not mirrored): R - (D - T0) = 0 - (90 - 0) = -90 = 270.
      expect(
        computeUntransformedPreviewRotation(
          transformationInfo: _createTransformationInfo(rotationDegrees: 0),
          cameraIsFrontFacing: false,
          sensorOrientationDegrees: 90,
          displayRotation: Surface.rotation90,
          previewTargetRotation: Surface.rotation0,
        ),
        270,
      );

      // Front camera (raw buffer, mirrored): R + (D - T0) = 0 + (90 - 0) = 90.
      expect(
        computeUntransformedPreviewRotation(
          transformationInfo: _createTransformationInfo(rotationDegrees: 0, isMirroring: true),
          cameraIsFrontFacing: true,
          sensorOrientationDegrees: 270,
          displayRotation: Surface.rotation90,
          previewTargetRotation: Surface.rotation0,
        ),
        90,
      );
    });

    test('shifts rotationDegrees like a back camera for front camera buffers that CameraX '
        'already mirrored', () {
      // Front camera buffer already mirrored by CameraX (isMirroring is false):
      // R - (D - T0) = 90 - (90 - 0) = 0.
      expect(
        computeUntransformedPreviewRotation(
          transformationInfo: _createTransformationInfo(rotationDegrees: 90),
          cameraIsFrontFacing: true,
          sensorOrientationDegrees: 270,
          displayRotation: Surface.rotation90,
          previewTargetRotation: Surface.rotation0,
        ),
        0,
      );
    });

    test(
      'matches the sensor-based rotation when rotationDegrees follows CameraX convention for the target rotation',
      () {
        for (final sensorOrientationDegrees in <int>[0, 90, 180, 270]) {
          for (final cameraIsFrontFacing in <bool>[true, false]) {
            for (final previewTargetRotation in surfaceRotations) {
              // CameraX's rotationDegrees for a buffer in sensor orientation:
              // back `sensor - T0`, front `sensor + T0`. With CameraX's default
              // mirror mode, only front camera buffers are mirrored.
              final int targetRotationDegrees = previewTargetRotation * 90;
              final int cameraXRotationDegrees =
                  (cameraIsFrontFacing
                      ? sensorOrientationDegrees + targetRotationDegrees
                      : sensorOrientationDegrees - targetRotationDegrees) %
                  360;

              for (final displayRotation in surfaceRotations) {
                final int expectedRotation = computeUntransformedPreviewRotation(
                  transformationInfo: null,
                  cameraIsFrontFacing: cameraIsFrontFacing,
                  sensorOrientationDegrees: sensorOrientationDegrees,
                  displayRotation: displayRotation,
                  previewTargetRotation: previewTargetRotation,
                );

                expect(
                  computeUntransformedPreviewRotation(
                    transformationInfo: _createTransformationInfo(
                      rotationDegrees: cameraXRotationDegrees,
                      isMirroring: cameraIsFrontFacing,
                    ),
                    cameraIsFrontFacing: cameraIsFrontFacing,
                    sensorOrientationDegrees: sensorOrientationDegrees,
                    displayRotation: displayRotation,
                    previewTargetRotation: previewTargetRotation,
                  ),
                  expectedRotation,
                  reason:
                      'sensor: $sensorOrientationDegrees, front facing: $cameraIsFrontFacing, '
                      'target rotation: $previewTargetRotation, display rotation: $displayRotation',
                );
              }
            }
          }
        }
      },
    );

    test('rotates front camera buffers that CameraX already mirrored to match the raw buffer '
        'displayed mirrored', () {
      // A raw front camera buffer B is displayed as mirror(rotate(r, B)). If
      // CameraX mirrors the buffer itself (M = mirror(B)), the same image is
      // rotate(-r, M), so CameraX reports rotationDegrees -(sensor + T0) with
      // isMirroring false, and the preview must be rotated by -(sensor + D).
      for (final sensorOrientationDegrees in <int>[0, 90, 180, 270]) {
        for (final previewTargetRotation in surfaceRotations) {
          final int alreadyMirroredRotationDegrees =
              -(sensorOrientationDegrees + previewTargetRotation * 90) % 360;

          for (final displayRotation in surfaceRotations) {
            final int rawBufferRotation = computeUntransformedPreviewRotation(
              transformationInfo: null,
              cameraIsFrontFacing: true,
              sensorOrientationDegrees: sensorOrientationDegrees,
              displayRotation: displayRotation,
              previewTargetRotation: previewTargetRotation,
            );

            expect(
              computeUntransformedPreviewRotation(
                transformationInfo: _createTransformationInfo(
                  rotationDegrees: alreadyMirroredRotationDegrees,
                ),
                cameraIsFrontFacing: true,
                sensorOrientationDegrees: sensorOrientationDegrees,
                displayRotation: displayRotation,
                previewTargetRotation: previewTargetRotation,
              ),
              -rawBufferRotation % 360,
              reason:
                  'sensor: $sensorOrientationDegrees, target rotation: $previewTargetRotation, '
                  'display rotation: $displayRotation',
            );
          }
        }
      }
    });

    test('always returns a rotation in [0, 360)', () {
      for (final rotationDegrees in <int>[0, 90, 180, 270]) {
        for (final cameraIsFrontFacing in <bool>[true, false]) {
          for (final previewTargetRotation in surfaceRotations) {
            for (final displayRotation in surfaceRotations) {
              final int rotation = computeUntransformedPreviewRotation(
                transformationInfo: _createTransformationInfo(rotationDegrees: rotationDegrees),
                cameraIsFrontFacing: cameraIsFrontFacing,
                sensorOrientationDegrees: 90,
                displayRotation: displayRotation,
                previewTargetRotation: previewTargetRotation,
              );
              expect(rotation, inInclusiveRange(0, 270));
              expect(rotation % 90, 0);
            }
          }
        }
      }
    });
  });

  group('buildUntransformedPreview', () {
    const Widget child = Texture(textureId: 3);

    RotatedBox buildPreview({
      TransformationInfo? transformationInfo,
      bool cameraIsFrontFacing = false,
      int sensorOrientationDegrees = 90,
      int displayRotation = Surface.rotation0,
      int previewTargetRotation = Surface.rotation0,
      DeviceOrientation deviceOrientation = DeviceOrientation.portraitUp,
    }) {
      return buildUntransformedPreview(
            child: child,
            transformationInfo: transformationInfo,
            cameraIsFrontFacing: cameraIsFrontFacing,
            sensorOrientationDegrees: sensorOrientationDegrees,
            displayRotation: displayRotation,
            previewTargetRotation: previewTargetRotation,
            deviceOrientation: deviceOrientation,
          )
          as RotatedBox;
    }

    test('rotates the preview by the rotation from TransformationInfo', () {
      final RotatedBox rotatedBox = buildPreview(
        transformationInfo: _createTransformationInfo(rotationDegrees: 180),
      );

      expect(rotatedBox.quarterTurns, 2);
      expect(rotatedBox.child, child);
    });

    test('subtracts the rotation pre-applied by the CameraPreview widget', () {
      // landscapeRight is pre-rotated 90 degrees clockwise by CameraPreview.
      final RotatedBox rotatedBox = buildPreview(
        transformationInfo: _createTransformationInfo(rotationDegrees: 90),
        deviceOrientation: DeviceOrientation.landscapeRight,
      );

      expect(rotatedBox.quarterTurns, 0);
    });

    test('mirrors the preview when TransformationInfo.isMirroring is true', () {
      // The camera being back facing shows that mirroring follows isMirroring.
      final RotatedBox rotatedBox = buildPreview(
        transformationInfo: _createTransformationInfo(rotationDegrees: 90, isMirroring: true),
      );

      final transform = rotatedBox.child! as Transform;
      expect(transform.transform.storage[5], -1);
      expect(transform.child, child);
    });

    test('does not mirror the preview when TransformationInfo.isMirroring is false', () {
      // The camera being front facing shows that mirroring follows isMirroring.
      final RotatedBox rotatedBox = buildPreview(
        transformationInfo: _createTransformationInfo(rotationDegrees: 270),
        cameraIsFrontFacing: true,
      );

      expect(rotatedBox.child, child);
    });

    test('mirrors front camera previews when TransformationInfo is null', () {
      final RotatedBox rotatedBox = buildPreview(cameraIsFrontFacing: true);

      expect(rotatedBox.child, isA<Transform>());
    });

    test('does not mirror back camera previews when TransformationInfo is null', () {
      final RotatedBox rotatedBox = buildPreview();

      expect(rotatedBox.child, child);
    });

    test('mirrors only front camera previews when the surface has the camera transform', () {
      // isMirroring is deliberately inconsistent with the camera facing to show
      // it is ignored.
      expect(
        buildPreview(
          transformationInfo: _createTransformationInfo(
            rotationDegrees: 90,
            hasCameraTransform: true,
          ),
          cameraIsFrontFacing: true,
        ).child,
        isA<Transform>(),
      );
      expect(
        buildPreview(
          transformationInfo: _createTransformationInfo(
            rotationDegrees: 90,
            hasCameraTransform: true,
            isMirroring: true,
          ),
        ).child,
        child,
      );
    });

    test('mirrors across the y-axis in portrait and the x-axis in landscape', () {
      final TransformationInfo mirroredInfo = _createTransformationInfo(
        rotationDegrees: 90,
        isMirroring: true,
      );

      for (final orientation in <DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]) {
        final transform =
            buildPreview(transformationInfo: mirroredInfo, deviceOrientation: orientation).child!
                as Transform;
        expect(transform.transform.storage[0], 1, reason: '$orientation');
        expect(transform.transform.storage[5], -1, reason: '$orientation');
      }

      for (final orientation in <DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]) {
        final transform =
            buildPreview(transformationInfo: mirroredInfo, deviceOrientation: orientation).child!
                as Transform;
        expect(transform.transform.storage[0], -1, reason: '$orientation');
        expect(transform.transform.storage[5], 1, reason: '$orientation');
      }
    });
  });
}
