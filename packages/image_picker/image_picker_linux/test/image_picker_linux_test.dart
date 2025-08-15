// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_linux/image_picker_linux.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'image_picker_linux_test.mocks.dart';

@GenerateMocks(<Type>[FileSelectorPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Returns the captured type groups from a mock call result, assuming that
  // exactly one call was made and only the type groups were captured.
  List<XTypeGroup> capturedTypeGroups(VerificationResult result) {
    return result.captured.single as List<XTypeGroup>;
  }

  late ImagePickerLinux plugin;
  late MockFileSelectorPlatform mockFileSelectorPlatform;

  setUp(() {
    plugin = ImagePickerLinux();
    mockFileSelectorPlatform = MockFileSelectorPlatform();

    when(mockFileSelectorPlatform.openFile(
            acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
        .thenAnswer((_) async => null);

    when(mockFileSelectorPlatform.openFiles(
            acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
        .thenAnswer((_) async => List<XFile>.empty());

    ImagePickerLinux.fileSelector = mockFileSelectorPlatform;
  });

  test('registered instance', () {
    ImagePickerLinux.registerWith();
    expect(ImagePickerPlatform.instance, isA<ImagePickerLinux>());
  });

  group('images', () {
    test('pickImage passes the accepted type groups correctly', () async {
      await plugin.pickImage(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].mimeTypes, <String>['image/*']);
    });

    test('getImage passes the accepted type groups correctly', () async {
      await plugin.getImage(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].mimeTypes, <String>['image/*']);
    });

    test('getImageFromSource passes the accepted type groups correctly',
        () async {
      await plugin.getImageFromSource(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].mimeTypes, <String>['image/*']);
    });

    test('getImageFromSource calls delegate when source is camera', () async {
      const String fakePath = '/tmp/foo';
      plugin.cameraDelegate = FakeCameraDelegate(result: XFile(fakePath));
      expect(
          (await plugin.getImageFromSource(source: ImageSource.camera))!.path,
          fakePath);
    });

    test(
        'getImageFromSource throws StateError when source is camera with no delegate',
        () async {
      await expectLater(plugin.getImageFromSource(source: ImageSource.camera),
          throwsStateError);
    });

    test('getMultiImage passes the accepted type groups correctly', () async {
      await plugin.getMultiImage();

      final VerificationResult result = verify(
          mockFileSelectorPlatform.openFiles(
              acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].mimeTypes, <String>['image/*']);
    });
  });

  group('videos', () {
    test('pickVideo passes the accepted type groups correctly', () async {
      await plugin.pickVideo(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].mimeTypes, <String>['video/*']);
    });

    test('getVideo passes the accepted type groups correctly', () async {
      await plugin.getVideo(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].mimeTypes, <String>['video/*']);
    });

    test('getVideo calls delegate when source is camera', () async {
      const String fakePath = '/tmp/foo';
      plugin.cameraDelegate = FakeCameraDelegate(result: XFile(fakePath));
      expect(
          (await plugin.getVideo(source: ImageSource.camera))!.path, fakePath);
    });

    test('getVideo throws StateError when source is camera with no delegate',
        () async {
      await expectLater(
          plugin.getVideo(source: ImageSource.camera), throwsStateError);
    });
  });

  group('media', () {
    test('getMedia passes the accepted type groups correctly', () async {
      await plugin.getMedia(options: const MediaOptions(allowMultiple: true));

      final VerificationResult result = verify(
          mockFileSelectorPlatform.openFiles(
              acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].mimeTypes,
          <String>['image/*', 'video/*']);
    });

    test('multiple media handles an empty path response gracefully', () async {
      expect(
          await plugin.getMedia(
            options: const MediaOptions(
              allowMultiple: true,
            ),
          ),
          <String>[]);
    });

    test('single media handles an empty path response gracefully', () async {
      expect(
          await plugin.getMedia(
            options: const MediaOptions(
              allowMultiple: false,
            ),
          ),
          <String>[]);
    });
  });
}

class FakeCameraDelegate extends ImagePickerCameraDelegate {
  FakeCameraDelegate({this.result});

  XFile? result;

  @override
  Future<XFile?> takePhoto(
      {ImagePickerCameraDelegateOptions options =
          const ImagePickerCameraDelegateOptions()}) async {
    return result;
  }

  @override
  Future<XFile?> takeVideo(
      {ImagePickerCameraDelegateOptions options =
          const ImagePickerCameraDelegateOptions()}) async {
    return result;
  }
}
