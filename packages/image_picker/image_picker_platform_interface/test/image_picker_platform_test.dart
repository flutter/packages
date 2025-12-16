// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  group('ImagePickerPlatform', () {
    test('supportsImageSource defaults to true for original values', () async {
      final ImagePickerPlatform implementation = FakeImagePickerPlatform();

      expect(implementation.supportsImageSource(ImageSource.camera), true);
      expect(implementation.supportsImageSource(ImageSource.gallery), true);
    });
  });

  group('CameraDelegatingImagePickerPlatform', () {
    test(
      'supportsImageSource returns false for camera when there is no delegate',
      () async {
        final implementation = FakeCameraDelegatingImagePickerPlatform();

        expect(implementation.supportsImageSource(ImageSource.camera), false);
      },
    );

    test(
      'supportsImageSource returns true for camera when there is a delegate',
      () async {
        final implementation = FakeCameraDelegatingImagePickerPlatform();
        implementation.cameraDelegate = FakeCameraDelegate();

        expect(implementation.supportsImageSource(ImageSource.camera), true);
      },
    );

    test(
      'getImageFromSource for camera throws if delegate is not set',
      () async {
        final implementation = FakeCameraDelegatingImagePickerPlatform();

        await expectLater(
          implementation.getImageFromSource(source: ImageSource.camera),
          throwsStateError,
        );
      },
    );

    test('getVideo for camera throws if delegate is not set', () async {
      final implementation = FakeCameraDelegatingImagePickerPlatform();

      await expectLater(
        implementation.getVideo(source: ImageSource.camera),
        throwsStateError,
      );
    });

    test('getImageFromSource for camera calls delegate if set', () async {
      const fakePath = '/tmp/foo';
      final implementation = FakeCameraDelegatingImagePickerPlatform();
      implementation.cameraDelegate = FakeCameraDelegate(
        result: XFile(fakePath),
      );

      expect(
        (await implementation.getImageFromSource(
          source: ImageSource.camera,
        ))!.path,
        fakePath,
      );
    });

    test('getVideo for camera calls delegate if set', () async {
      const fakePath = '/tmp/foo';
      final implementation = FakeCameraDelegatingImagePickerPlatform();
      implementation.cameraDelegate = FakeCameraDelegate(
        result: XFile(fakePath),
      );

      expect(
        (await implementation.getVideo(source: ImageSource.camera))!.path,
        fakePath,
      );
    });
  });

  test('Default implementation of getMultiVideoWithOptions should throw '
      'unimplemented error', () {
    final implementation = FakeCameraDelegatingImagePickerPlatform();

    expect(
      () => implementation.getMultiVideoWithOptions(),
      throwsUnimplementedError,
    );
  });
}

class FakeImagePickerPlatform extends ImagePickerPlatform {}

class FakeCameraDelegatingImagePickerPlatform
    extends CameraDelegatingImagePickerPlatform {}

class FakeCameraDelegate extends ImagePickerCameraDelegate {
  FakeCameraDelegate({this.result});

  XFile? result;

  @override
  Future<XFile?> takePhoto({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async {
    return result;
  }

  @override
  Future<XFile?> takeVideo({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async {
    return result;
  }
}
