// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  setUp(() {
    CrossFilePlatform.instance = CrossFileTest();
  });

  group('ImagePickerPlatform', () {
    test('supportsImageSource defaults to true for original values', () async {
      final ImagePickerPlatform implementation = FakeImagePickerPlatform();

      expect(implementation.supportsImageSource(ImageSource.camera), true);
      expect(implementation.supportsImageSource(ImageSource.gallery), true);
    });
  });

  group('CameraDelegatingImagePickerPlatform', () {
    test('supportsImageSource returns false for camera when there is no delegate', () async {
      final implementation = FakeCameraDelegatingImagePickerPlatform();

      expect(implementation.supportsImageSource(ImageSource.camera), false);
    });

    test('supportsImageSource returns true for camera when there is a delegate', () async {
      final implementation = FakeCameraDelegatingImagePickerPlatform();
      implementation.cameraDelegate = FakeCameraDelegate();

      expect(implementation.supportsImageSource(ImageSource.camera), true);
    });

    test('pickImage for camera throws if delegate is not set', () async {
      final implementation = FakeCameraDelegatingImagePickerPlatform();

      await expectLater(implementation.pickImage(source: ImageSource.camera), throwsStateError);
    });

    test('pickVideo for camera throws if delegate is not set', () async {
      final implementation = FakeCameraDelegatingImagePickerPlatform();

      await expectLater(implementation.pickVideo(source: ImageSource.camera), throwsStateError);
    });

    test('pickImage for camera calls delegate if set', () async {
      const fakePath = '/tmp/foo';
      final implementation = FakeCameraDelegatingImagePickerPlatform();
      implementation.cameraDelegate = FakeCameraDelegate(
        result: XFile.scopedStorage(uri: fakePath),
      );

      expect((await implementation.pickImage(source: ImageSource.camera))!.uri, fakePath);
    });

    test('pickVideo for camera calls delegate if set', () async {
      const fakePath = '/tmp/foo';
      final implementation = FakeCameraDelegatingImagePickerPlatform();
      implementation.cameraDelegate = FakeCameraDelegate(
        // Use scoped storage because it doesn't parse the path to a URI.
        result: XFile.scopedStorage(uri: fakePath),
      );

      expect((await implementation.pickVideo(source: ImageSource.camera))!.uri, fakePath);
    });
  });

  test('Default implementation of pickMedia should throw '
      'unimplemented error', () {
    final implementation = FakeCameraDelegatingImagePickerPlatform();

    expect(
      () => implementation.pickMedia(options: const MediaPickerOptions(allowMultiple: false)),
      throwsUnimplementedError,
    );
  });

  test('Default implementation of pickImage should throw '
      'unimplemented error', () {
    final implementation = FakeCameraDelegatingImagePickerPlatform();

    expect(() => implementation.pickImage(source: ImageSource.gallery), throwsUnimplementedError);
  });

  test('Default implementation of pickMultiImage should throw '
      'unimplemented error', () {
    final implementation = FakeCameraDelegatingImagePickerPlatform();

    expect(() => implementation.pickMultiImage(), throwsUnimplementedError);
  });

  test('Default implementation of pickVideo should throw '
      'unimplemented error', () {
    final implementation = FakeCameraDelegatingImagePickerPlatform();

    expect(() => implementation.pickVideo(source: ImageSource.gallery), throwsUnimplementedError);
  });

  test('Default implementation of pickMultiVideo should throw '
      'unimplemented error', () {
    final implementation = FakeCameraDelegatingImagePickerPlatform();

    expect(() => implementation.pickMultiVideo(), throwsUnimplementedError);
  });

  test('Default implementation of getLostData should throw '
      'unimplemented error', () {
    final implementation = FakeCameraDelegatingImagePickerPlatform();

    expect(() => implementation.getLostData(), throwsUnimplementedError);
  });
}

final class FakeImagePickerPlatform extends ImagePickerPlatform {}

final class FakeCameraDelegatingImagePickerPlatform extends CameraDelegatingImagePickerPlatform {}

final class FakeCameraDelegate extends ImagePickerCameraDelegate {
  FakeCameraDelegate({this.result});

  XFile? result;

  @override
  Future<XFile?> takePhoto({ImagePickerOptions options = const ImagePickerOptions()}) async {
    return result;
  }

  @override
  Future<XFile?> takeVideo({VideoPickerOptions options = const VideoPickerOptions()}) async {
    return result;
  }
}

final class CrossFileTest extends CrossFilePlatform {}
