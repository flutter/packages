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

  group('computePreviewTargetRotation', () {
    test('returns rotation0 if the surface handles crop and rotation', () {
      for (final cameraIsFrontFacing in <bool>[true, false]) {
        for (final sensorOrientationDegrees in <int>[0, 90, 180, 270]) {
          expect(
            computePreviewTargetRotation(
              handlesCropAndRotation: true,
              cameraIsFrontFacing: cameraIsFrontFacing,
              sensorOrientationDegrees: sensorOrientationDegrees,
            ),
            Surface.rotation0,
            reason: 'front: $cameraIsFrontFacing, sensor: $sensorOrientationDegrees',
          );
        }
      }
    });

    test('returns the sensor orientation for back cameras if the surface does not handle crop '
        'and rotation', () {
      const expected = <int, int>{
        0: Surface.rotation0,
        90: Surface.rotation90,
        180: Surface.rotation180,
        270: Surface.rotation270,
      };
      expected.forEach((int sensorOrientationDegrees, int targetRotation) {
        expect(
          computePreviewTargetRotation(
            handlesCropAndRotation: false,
            cameraIsFrontFacing: false,
            sensorOrientationDegrees: sensorOrientationDegrees,
          ),
          targetRotation,
          reason: 'sensor: $sensorOrientationDegrees',
        );
      });
    });

    test('returns the inverse of the sensor orientation for front cameras if the surface does '
        'not handle crop and rotation', () {
      const expected = <int, int>{
        0: Surface.rotation0,
        90: Surface.rotation270,
        180: Surface.rotation180,
        270: Surface.rotation90,
      };
      expected.forEach((int sensorOrientationDegrees, int targetRotation) {
        expect(
          computePreviewTargetRotation(
            handlesCropAndRotation: false,
            cameraIsFrontFacing: true,
            sensorOrientationDegrees: sensorOrientationDegrees,
          ),
          targetRotation,
          reason: 'sensor: $sensorOrientationDegrees',
        );
      });
    });

    test('makes a buffer copied by CameraX look like a buffer from the camera directly', () {
      // CameraX reports the rotation of a copied buffer relative to the target
      // rotation (sensor - target for back cameras, sensor + target for front
      // cameras). Without the camera transform, a direct buffer is in sensor
      // orientation, so the copied buffer matches it if that rotation is 0.
      //
      // This checks the pin against how CameraX is understood to compute that
      // rotation, not against CameraX itself, so it must be updated if CameraX
      // changes how it does.
      for (final cameraIsFrontFacing in <bool>[true, false]) {
        for (final sensorOrientationDegrees in <int>[0, 90, 180, 270]) {
          final int targetRotationDegrees =
              computePreviewTargetRotation(
                handlesCropAndRotation: false,
                cameraIsFrontFacing: cameraIsFrontFacing,
                sensorOrientationDegrees: sensorOrientationDegrees,
              ) *
              90;
          final int relativeRotationDegrees = cameraIsFrontFacing
              ? (sensorOrientationDegrees + targetRotationDegrees) % 360
              : (sensorOrientationDegrees - targetRotationDegrees) % 360;
          expect(
            relativeRotationDegrees,
            0,
            reason: 'front: $cameraIsFrontFacing, sensor: $sensorOrientationDegrees',
          );
        }
      }
    });

    test('throws for a sensor orientation that is not a multiple of 90', () {
      expect(
        () => computePreviewTargetRotation(
          handlesCropAndRotation: false,
          cameraIsFrontFacing: false,
          sensorOrientationDegrees: 45,
        ),
        throwsArgumentError,
      );
    });
  });

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
          bufferNeedsMirroring: false,
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
          bufferNeedsMirroring: false,
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
          bufferNeedsMirroring: true,
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
          bufferNeedsMirroring: true,
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
          bufferNeedsMirroring: false,
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
            bufferNeedsMirroring: cameraIsFrontFacing,
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
                bufferNeedsMirroring: cameraIsFrontFacing,
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
          bufferNeedsMirroring: false,
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
          bufferNeedsMirroring: true,
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
          bufferNeedsMirroring: false,
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
                  bufferNeedsMirroring: cameraIsFrontFacing,
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
                    bufferNeedsMirroring: cameraIsFrontFacing,
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
      // When CameraX mirrors a front camera buffer itself while copying it,
      // the copy is the mirror image of the raw buffer. Rotating a mirror
      // image clockwise looks like rotating the original counterclockwise, so
      // the copy must be rotated by the opposite of the raw buffer's rotation
      // to end up looking the same as the raw buffer once the plugin rotates
      // and mirrors it. CameraX reports this by giving the copy the opposite
      // of the rotation it reports for the raw buffer.
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
              bufferNeedsMirroring: true,
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
                bufferNeedsMirroring: false,
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
                bufferNeedsMirroring: false,
              );
              expect(rotation, inInclusiveRange(0, 270));
              expect(rotation % 90, 0);
            }
          }
        }
      }
    });
  });

  group('untransformedBufferNeedsMirroring', () {
    test('returns whether the camera is front facing for buffers from the camera directly', () {
      for (final cameraIsFrontFacing in <bool>[true, false]) {
        for (final previewMirroringDisabled in <bool>[true, false]) {
          for (final transformationInfo in <TransformationInfo?>[
            null,
            _createTransformationInfo(rotationDegrees: 0, hasCameraTransform: true),
            _createTransformationInfo(
              rotationDegrees: 0,
              hasCameraTransform: true,
              isMirroring: true,
            ),
          ]) {
            expect(
              untransformedBufferNeedsMirroring(
                transformationInfo: transformationInfo,
                cameraIsFrontFacing: cameraIsFrontFacing,
                previewMirroringDisabled: previewMirroringDisabled,
              ),
              cameraIsFrontFacing,
              reason:
                  'front: $cameraIsFrontFacing, mirroring disabled: $previewMirroringDisabled, '
                  'info: ${transformationInfo?.isMirroring}',
            );
          }
        }
      }
    });

    test('follows TransformationInfo.isMirroring for copied buffers by default', () {
      for (final cameraIsFrontFacing in <bool>[true, false]) {
        for (final isMirroring in <bool>[true, false]) {
          expect(
            untransformedBufferNeedsMirroring(
              transformationInfo: _createTransformationInfo(
                rotationDegrees: 0,
                isMirroring: isMirroring,
              ),
              cameraIsFrontFacing: cameraIsFrontFacing,
              previewMirroringDisabled: false,
            ),
            isMirroring,
            reason: 'front: $cameraIsFrontFacing',
          );
        }
      }
    });

    test('returns whether the camera is front facing for copied buffers if CameraX mirroring is '
        'disabled', () {
      for (final cameraIsFrontFacing in <bool>[true, false]) {
        for (final isMirroring in <bool>[true, false]) {
          expect(
            untransformedBufferNeedsMirroring(
              transformationInfo: _createTransformationInfo(
                rotationDegrees: 0,
                isMirroring: isMirroring,
              ),
              cameraIsFrontFacing: cameraIsFrontFacing,
              previewMirroringDisabled: true,
            ),
            cameraIsFrontFacing,
            reason: 'isMirroring: $isMirroring',
          );
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
      bool previewMirroringDisabled = false,
      DeviceOrientation deviceOrientation = DeviceOrientation.portraitUp,
    }) {
      return buildUntransformedPreview(
            child: child,
            transformationInfo: transformationInfo,
            cameraIsFrontFacing: cameraIsFrontFacing,
            sensorOrientationDegrees: sensorOrientationDegrees,
            displayRotation: displayRotation,
            previewTargetRotation: previewTargetRotation,
            previewMirroringDisabled: previewMirroringDisabled,
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
      // storage holds the matrix in column-major order, so storage[0] is the x
      // scale and storage[5] is the y scale. The buffer is rotated a quarter
      // turn, so it is flipped vertically (y scale -1) to end up mirrored
      // horizontally.
      expect(transform.transform.storage[0], 1);
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

      // The buffer is rotated a quarter turn (sensor 90 + display 0 degrees),
      // so it is flipped vertically (storage[5] is the y scale) to end up
      // mirrored horizontally.
      final transform = rotatedBox.child! as Transform;
      expect(transform.transform.storage[0], 1);
      expect(transform.transform.storage[5], -1);
      expect(transform.child, child);
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

    test('mirrors across the x-axis when the preview is rotated a quarter or three quarter turn '
        'in total and across the y-axis otherwise', () {
      for (final rotationDegrees in <int>[0, 90, 180, 270]) {
        for (final DeviceOrientation orientation in DeviceOrientation.values) {
          final transform =
              buildPreview(
                    transformationInfo: _createTransformationInfo(
                      rotationDegrees: rotationDegrees,
                      isMirroring: true,
                    ),
                    deviceOrientation: orientation,
                  ).child!
                  as Transform;
          final rotatedQuarterTurn = rotationDegrees % 180 == 90;
          final reason = 'rotationDegrees: $rotationDegrees, $orientation';
          // storage[0] is the x scale and storage[5] is the y scale, so -1 in
          // one of them flips the buffer horizontally or vertically.
          expect(transform.transform.storage[0], rotatedQuarterTurn ? 1 : -1, reason: reason);
          expect(transform.transform.storage[5], rotatedQuarterTurn ? -1 : 1, reason: reason);
        }
      }
    });

    test('mirrors raw front camera buffers across the x-axis in portrait and the y-axis in '
        'landscape', () {
      const displayRotationToOrientation = <int, DeviceOrientation>{
        Surface.rotation0: DeviceOrientation.portraitUp,
        Surface.rotation90: DeviceOrientation.landscapeLeft,
        Surface.rotation180: DeviceOrientation.portraitDown,
        Surface.rotation270: DeviceOrientation.landscapeRight,
      };
      displayRotationToOrientation.forEach((int displayRotation, DeviceOrientation orientation) {
        final transform =
            buildPreview(
                  cameraIsFrontFacing: true,
                  sensorOrientationDegrees: 270,
                  displayRotation: displayRotation,
                  deviceOrientation: orientation,
                ).child!
                as Transform;
        final bool portrait =
            orientation == DeviceOrientation.portraitUp ||
            orientation == DeviceOrientation.portraitDown;
        // A 270 degree sensor needs a quarter or three quarter turn in portrait,
        // so the buffer is flipped vertically (y scale, storage[5], is -1), and
        // a half or no turn in landscape, so it is flipped horizontally (x
        // scale, storage[0], is -1).
        expect(transform.transform.storage[0], portrait ? 1 : -1, reason: '$orientation');
        expect(transform.transform.storage[5], portrait ? -1 : 1, reason: '$orientation');
      });
    });

    test('draws buffers copied by CameraX exactly like buffers from the camera directly for '
        'ImageReader backed previews with the pinned target rotation', () {
      // With the target rotation pinned by computePreviewTargetRotation and
      // CameraX mirroring disabled, CameraX copies buffers without rotating or
      // mirroring them, so it reports a rotation of 0 degrees that does not
      // need mirroring. They must be drawn exactly like buffers from the camera
      // directly so that switching between them is not visible.
      const displayRotationToOrientation = <int, DeviceOrientation>{
        Surface.rotation0: DeviceOrientation.portraitUp,
        Surface.rotation90: DeviceOrientation.landscapeLeft,
        Surface.rotation180: DeviceOrientation.portraitDown,
        Surface.rotation270: DeviceOrientation.landscapeRight,
      };
      for (final cameraIsFrontFacing in <bool>[true, false]) {
        for (final sensorOrientationDegrees in <int>[0, 90, 180, 270]) {
          final int previewTargetRotation = computePreviewTargetRotation(
            handlesCropAndRotation: false,
            cameraIsFrontFacing: cameraIsFrontFacing,
            sensorOrientationDegrees: sensorOrientationDegrees,
          );
          displayRotationToOrientation.forEach((
            int displayRotation,
            DeviceOrientation orientation,
          ) {
            RotatedBox build(TransformationInfo transformationInfo) => buildPreview(
              transformationInfo: transformationInfo,
              cameraIsFrontFacing: cameraIsFrontFacing,
              sensorOrientationDegrees: sensorOrientationDegrees,
              displayRotation: displayRotation,
              previewTargetRotation: previewTargetRotation,
              previewMirroringDisabled: true,
              deviceOrientation: orientation,
            );
            final RotatedBox direct = build(
              _createTransformationInfo(rotationDegrees: 0, hasCameraTransform: true),
            );
            final RotatedBox copied = build(_createTransformationInfo(rotationDegrees: 0));
            final reason =
                'front: $cameraIsFrontFacing, sensor: $sensorOrientationDegrees, '
                'orientation: $orientation';

            expect(copied.quarterTurns % 4, direct.quarterTurns % 4, reason: reason);
            if (cameraIsFrontFacing) {
              expect(copied.child, isA<Transform>(), reason: reason);
              expect(
                (copied.child! as Transform).transform,
                (direct.child! as Transform).transform,
                reason: reason,
              );
            } else {
              expect(copied.child, child, reason: reason);
              expect(direct.child, child, reason: reason);
            }
          });
        }
      }
    });
  });
}
