// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  group('ImagePicker', () {
    late _MockImagePickerPlatform mockPlatform;

    setUp(() {
      CrossFilePlatform.instance = _MockCrossFile();
      mockPlatform = _MockImagePickerPlatform();
      ImagePickerPlatform.instance = mockPlatform;
    });

    group('#Single image/video', () {
      group('#pickImage', () {
        test('passes the image source argument correctly', () async {
          final picker = ImagePicker();

          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(source, ImageSource.camera);
            return null;
          });
          await picker.pickImage(source: ImageSource.camera);

          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(source, ImageSource.gallery);
            return null;
          });
          await picker.pickImage(source: ImageSource.gallery);
        });

        test('passes the width and height arguments correctly', () async {
          final picker = ImagePicker();

          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, isNull);
            return null;
          });
          await picker.pickImage(source: ImageSource.camera);

          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, isNull);
            return null;
          });
          await picker.pickImage(source: ImageSource.camera, maxWidth: 10);

          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, 10);
            expect(options.imageOptions.imageQuality, isNull);
            return null;
          });
          await picker.pickImage(source: ImageSource.camera, maxHeight: 10);

          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, isNull);
            return null;
          });
          await picker.pickImage(source: ImageSource.camera, maxWidth: 10, maxHeight: 20);

          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, 70);
            return null;
          });
          await picker.pickImage(source: ImageSource.camera, maxWidth: 10, imageQuality: 70);

          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, 10);
            expect(options.imageOptions.imageQuality, 70);
            return null;
          });
          await picker.pickImage(source: ImageSource.camera, maxHeight: 10, imageQuality: 70);

          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, 70);
            return null;
          });
          await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 10,
            maxHeight: 20,
            imageQuality: 70,
          );
        });

        test('does not accept a negative width or height argument', () {
          final picker = ImagePicker();
          expect(
            () => picker.pickImage(source: ImageSource.camera, maxWidth: -1),
            throwsArgumentError,
          );

          expect(
            () => picker.pickImage(source: ImageSource.camera, maxHeight: -1),
            throwsArgumentError,
          );
        });

        test('handles a null image file response gracefully', () async {
          final picker = ImagePicker();
          mockPlatform.onPickImage = expectAsync2(
            (ImageSource source, ImagePickerOptions options) async => null,
            count: 2,
          );

          expect(await picker.pickImage(source: ImageSource.gallery), isNull);
          expect(await picker.pickImage(source: ImageSource.camera), isNull);
        });

        test('camera position defaults to back', () async {
          final picker = ImagePicker();
          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.preferredCameraDevice, CameraDevice.rear);
            return null;
          });

          await picker.pickImage(source: ImageSource.camera);
        });

        test('camera position can set to front', () async {
          final picker = ImagePicker();
          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.preferredCameraDevice, CameraDevice.front);
            return null;
          });

          await picker.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.front,
          );
        });

        test('full metadata argument defaults to true', () async {
          final picker = ImagePicker();
          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.imageOptions.requestFullMetadata, isTrue);
            return null;
          });

          await picker.pickImage(source: ImageSource.gallery);
        });

        test('passes the full metadata argument correctly', () async {
          final picker = ImagePicker();
          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(options.imageOptions.requestFullMetadata, isFalse);
            return null;
          });

          await picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false);
        });
      });

      group('#pickVideo', () {
        test('passes the image source argument correctly', () async {
          final picker = ImagePicker();

          mockPlatform.onPickVideo = expectAsync2((
            ImageSource source,
            VideoPickerOptions options,
          ) async {
            expect(source, ImageSource.camera);
            return null;
          });
          await picker.pickVideo(source: ImageSource.camera);

          mockPlatform.onPickVideo = expectAsync2((
            ImageSource source,
            VideoPickerOptions options,
          ) async {
            expect(source, ImageSource.gallery);
            return null;
          });
          await picker.pickVideo(source: ImageSource.gallery);
        });

        test('passes the duration argument correctly', () async {
          final picker = ImagePicker();

          mockPlatform.onPickVideo = expectAsync2((
            ImageSource source,
            VideoPickerOptions options,
          ) async {
            expect(options.videoOptions.maxDuration, isNull);
            return null;
          });
          await picker.pickVideo(source: ImageSource.camera);

          mockPlatform.onPickVideo = expectAsync2((
            ImageSource source,
            VideoPickerOptions options,
          ) async {
            expect(options.videoOptions.maxDuration, const Duration(seconds: 10));
            return null;
          });
          await picker.pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(seconds: 10),
          );
        });

        test('handles a null video file response gracefully', () async {
          final picker = ImagePicker();
          mockPlatform.onPickVideo = expectAsync2(
            (ImageSource source, VideoPickerOptions options) async => null,
            count: 2,
          );

          expect(await picker.pickVideo(source: ImageSource.gallery), isNull);
          expect(await picker.pickVideo(source: ImageSource.camera), isNull);
        });

        test('camera position defaults to back', () async {
          final picker = ImagePicker();
          mockPlatform.onPickVideo = expectAsync2((
            ImageSource source,
            VideoPickerOptions options,
          ) async {
            expect(options.preferredCameraDevice, CameraDevice.rear);
            return null;
          });

          await picker.pickVideo(source: ImageSource.camera);
        });

        test('camera position can set to front', () async {
          final picker = ImagePicker();
          mockPlatform.onPickVideo = expectAsync2((
            ImageSource source,
            VideoPickerOptions options,
          ) async {
            expect(options.preferredCameraDevice, CameraDevice.front);
            return null;
          });

          await picker.pickVideo(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.front,
          );
        });
      });

      group('#retrieveLostData', () {
        test('retrieveLostData get success response', () async {
          final picker = ImagePicker();
          final lostFile = FileSystemXFile('/example/path');
          mockPlatform.onGetLostData = expectAsync0(
            () async => LostDataResponse(
              file: lostFile,
              files: <XFile>[lostFile],
              type: RetrieveType.image,
            ),
          );

          final LostDataResponse response = await picker.retrieveLostData();

          expect(response.type, RetrieveType.image);
          expect((response.file! as FileSystemXFile).path, '/example/path');
        });

        test('retrieveLostData should successfully retrieve multiple files', () async {
          final picker = ImagePicker();
          final lostFiles = <XFile>[
            FileSystemXFile('/example/path0'),
            FileSystemXFile('/example/path1'),
          ];
          mockPlatform.onGetLostData = expectAsync0(
            () async =>
                LostDataResponse(file: lostFiles.last, files: lostFiles, type: RetrieveType.image),
          );

          final LostDataResponse response = await picker.retrieveLostData();

          expect(response.type, RetrieveType.image);
          expect(response.file, isNotNull);
          expect((response.file! as FileSystemXFile).path, '/example/path1');
          expect((response.files!.first as FileSystemXFile).path, '/example/path0');
          expect(response.files!.length, 2);
        });

        test('retrieveLostData get error response', () async {
          final picker = ImagePicker();
          mockPlatform.onGetLostData = expectAsync0(
            () async => LostDataResponse(
              exception: PlatformException(code: 'test_error_code', message: 'test_error_message'),
              type: RetrieveType.video,
            ),
          );

          final LostDataResponse response = await picker.retrieveLostData();

          expect(response.type, RetrieveType.video);
          expect(response.exception!.code, 'test_error_code');
          expect(response.exception!.message, 'test_error_message');
        });
      });

      group('#pickMultiVideo', () {
        test('passes the arguments correctly', () async {
          final picker = ImagePicker();

          mockPlatform.onPickMultiVideo = expectAsync1((MultiVideoPickerOptions options) async {
            expect(options.videoOptions.maxDuration, isNull);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiVideo();

          mockPlatform.onPickMultiVideo = expectAsync1((MultiVideoPickerOptions options) async {
            expect(options.videoOptions.maxDuration, const Duration(seconds: 10));
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiVideo(maxDuration: const Duration(seconds: 10));

          mockPlatform.onPickMultiVideo = expectAsync1((MultiVideoPickerOptions options) async {
            expect(options.videoOptions.maxDuration, isNull);
            expect(options.limit, 5);
            return <XFile>[];
          });
          await picker.pickMultiVideo(limit: 5);
        });
      });
    });

    group('#Multi images', () {
      group('#pickMultiImage', () {
        test('passes the width and height arguments correctly', () async {
          final picker = ImagePicker();

          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, isNull);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiImage();

          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, isNull);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiImage(maxWidth: 10);

          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, 10);
            expect(options.imageOptions.imageQuality, isNull);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiImage(maxHeight: 10);

          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, isNull);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiImage(maxWidth: 10, maxHeight: 20);

          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, 70);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiImage(maxWidth: 10, imageQuality: 70);

          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, 10);
            expect(options.imageOptions.imageQuality, 70);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiImage(maxHeight: 10, imageQuality: 70);

          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, 70);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiImage(maxWidth: 10, maxHeight: 20, imageQuality: 70);

          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, 70);
            expect(options.limit, 5);
            return <XFile>[];
          });
          await picker.pickMultiImage(maxWidth: 10, maxHeight: 20, imageQuality: 70, limit: 5);
        });

        test('does not accept a negative width or height argument', () {
          final picker = ImagePicker();
          expect(() => picker.pickMultiImage(maxWidth: -1), throwsArgumentError);

          expect(() => picker.pickMultiImage(maxHeight: -1), throwsArgumentError);
        });

        test('does not accept a limit argument lower than 1', () {
          final picker = ImagePicker();
          expect(() => picker.pickMultiImage(limit: -1), throwsArgumentError);

          expect(() => picker.pickMultiImage(limit: 0), throwsArgumentError);
        });

        test('delegates to pickImage when limit is 1 and image is picked', () async {
          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(source, ImageSource.gallery);
            return FileSystemXFile('test_path');
          });

          final picker = ImagePicker();
          final List<XFile> result = await picker.pickMultiImage(limit: 1);

          expect(result, hasLength(1));
          expect((result.first as FileSystemXFile).path, 'test_path');
        });

        test('delegates to pickImage when limit is 1 and no image is picked', () async {
          mockPlatform.onPickImage = expectAsync2((
            ImageSource source,
            ImagePickerOptions options,
          ) async {
            expect(source, ImageSource.gallery);
            return null;
          });

          final picker = ImagePicker();
          final List<XFile> result = await picker.pickMultiImage(limit: 1);

          expect(result, isEmpty);
        });

        test('handles an empty image file response gracefully', () async {
          final picker = ImagePicker();
          mockPlatform.onPickMultiImage = expectAsync1(
            (MultiImagePickerOptions options) async => <XFile>[],
            count: 2,
          );

          expect(await picker.pickMultiImage(), isEmpty);
          expect(await picker.pickMultiImage(), isEmpty);
        });

        test('full metadata argument defaults to true', () async {
          final picker = ImagePicker();
          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.requestFullMetadata, isTrue);
            return <XFile>[];
          });

          await picker.pickMultiImage();
        });

        test('passes the full metadata argument correctly', () async {
          final picker = ImagePicker();
          mockPlatform.onPickMultiImage = expectAsync1((MultiImagePickerOptions options) async {
            expect(options.imageOptions.requestFullMetadata, isFalse);
            return <XFile>[];
          });

          await picker.pickMultiImage(requestFullMetadata: false);
        });
      });
    });

    group('#Media', () {
      group('#pickMedia', () {
        test('passes the width and height arguments correctly', () async {
          final picker = ImagePicker();

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isFalse);
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, isNull);
            return <XFile>[];
          });
          await picker.pickMedia();

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isFalse);
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, isNull);
            return <XFile>[];
          });
          await picker.pickMedia(maxWidth: 10);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isFalse);
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, 10);
            expect(options.imageOptions.imageQuality, isNull);
            return <XFile>[];
          });
          await picker.pickMedia(maxHeight: 10);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isFalse);
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, isNull);
            return <XFile>[];
          });
          await picker.pickMedia(maxWidth: 10, maxHeight: 20);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isFalse);
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, 70);
            return <XFile>[];
          });
          await picker.pickMedia(maxWidth: 10, imageQuality: 70);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isFalse);
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, 10);
            expect(options.imageOptions.imageQuality, 70);
            return <XFile>[];
          });
          await picker.pickMedia(maxHeight: 10, imageQuality: 70);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isFalse);
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, 70);
            return <XFile>[];
          });
          await picker.pickMedia(maxWidth: 10, maxHeight: 20, imageQuality: 70);
        });

        test('does not accept a negative width or height argument', () {
          final picker = ImagePicker();
          expect(() => picker.pickMedia(maxWidth: -1), throwsArgumentError);

          expect(() => picker.pickMedia(maxHeight: -1), throwsArgumentError);
        });

        test('handles an empty image file response gracefully', () async {
          final picker = ImagePicker();
          mockPlatform.onPickMedia = expectAsync1(
            (MediaPickerOptions options) async => <XFile>[],
            count: 2,
          );

          expect(await picker.pickMedia(), isNull);
          expect(await picker.pickMedia(), isNull);
        });

        test('full metadata argument defaults to true', () async {
          final picker = ImagePicker();
          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.imageOptions.requestFullMetadata, isTrue);
            return <XFile>[];
          });

          await picker.pickMedia();
        });

        test('passes the full metadata argument correctly', () async {
          final picker = ImagePicker();
          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.imageOptions.requestFullMetadata, isFalse);
            return <XFile>[];
          });

          await picker.pickMedia(requestFullMetadata: false);
        });
      });

      group('#pickMultiMedia', () {
        test('passes the width and height arguments correctly', () async {
          final picker = ImagePicker();

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isTrue);
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, isNull);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiMedia();

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isTrue);
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, isNull);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiMedia(maxWidth: 10);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isTrue);
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, 10);
            expect(options.imageOptions.imageQuality, isNull);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiMedia(maxHeight: 10);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isTrue);
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, isNull);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiMedia(maxWidth: 10, maxHeight: 20);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isTrue);
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, isNull);
            expect(options.imageOptions.imageQuality, 70);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiMedia(maxWidth: 10, imageQuality: 70);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isTrue);
            expect(options.imageOptions.maxWidth, isNull);
            expect(options.imageOptions.maxHeight, 10);
            expect(options.imageOptions.imageQuality, 70);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiMedia(maxHeight: 10, imageQuality: 70);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isTrue);
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, 70);
            expect(options.limit, isNull);
            return <XFile>[];
          });
          await picker.pickMultiMedia(maxWidth: 10, maxHeight: 20, imageQuality: 70);

          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isTrue);
            expect(options.imageOptions.maxWidth, 10);
            expect(options.imageOptions.maxHeight, 20);
            expect(options.imageOptions.imageQuality, 70);
            expect(options.limit, 5);
            return <XFile>[];
          });
          await picker.pickMultiMedia(maxWidth: 10, maxHeight: 20, imageQuality: 70, limit: 5);
        });

        test('does not accept a negative width or height argument', () {
          final picker = ImagePicker();
          expect(() => picker.pickMultiMedia(maxWidth: -1), throwsArgumentError);

          expect(() => picker.pickMultiMedia(maxHeight: -1), throwsArgumentError);
        });

        test('does not accept a limit argument lower than 1', () {
          final picker = ImagePicker();
          expect(() => picker.pickMultiMedia(limit: -1), throwsArgumentError);

          expect(() => picker.pickMultiMedia(limit: 0), throwsArgumentError);
        });

        test('delegates to pickMedia when limit is 1 and media is picked', () async {
          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isFalse);
            return <XFile>[FileSystemXFile('test_path')];
          });

          final picker = ImagePicker();
          final List<XFile> result = await picker.pickMultiMedia(limit: 1);

          expect(result, hasLength(1));
          expect((result.first as FileSystemXFile).path, 'test_path');
        });

        test('delegates to pickMedia when limit is 1 and no media is picked', () async {
          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.allowMultiple, isFalse);
            return <XFile>[];
          });

          final picker = ImagePicker();
          final List<XFile> result = await picker.pickMultiMedia(limit: 1);

          expect(result, isEmpty);
        });

        test('handles an empty image file response gracefully', () async {
          final picker = ImagePicker();
          mockPlatform.onPickMedia = expectAsync1(
            (MediaPickerOptions options) async => <XFile>[],
            count: 2,
          );

          expect(await picker.pickMultiMedia(), isEmpty);
          expect(await picker.pickMultiMedia(), isEmpty);
        });

        test('full metadata argument defaults to true', () async {
          final picker = ImagePicker();
          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.imageOptions.requestFullMetadata, isTrue);
            return <XFile>[];
          });

          await picker.pickMultiMedia();
        });

        test('passes the full metadata argument correctly', () async {
          final picker = ImagePicker();
          mockPlatform.onPickMedia = expectAsync1((MediaPickerOptions options) async {
            expect(options.imageOptions.requestFullMetadata, isFalse);
            return <XFile>[];
          });

          await picker.pickMultiMedia(requestFullMetadata: false);
        });
      });
      test('supportsImageSource calls through to platform', () async {
        final picker = ImagePicker();
        mockPlatform.onSupportsImageSource = expectAsync1((ImageSource source) {
          expect(source, ImageSource.camera);
          return true;
        });

        final bool supported = picker.supportsImageSource(ImageSource.camera);

        expect(supported, true);
      });
    });
  });
}

final class _MockCrossFile extends CrossFilePlatform {}

final class _MockImagePickerPlatform extends ImagePickerPlatform {
  _MockImagePickerPlatform();

  late Future<XFile?> Function(ImageSource source, ImagePickerOptions options) onPickImage;

  late Future<List<XFile>> Function(MultiImagePickerOptions options) onPickMultiImage;

  late Future<List<XFile>> Function(MediaPickerOptions options) onPickMedia;

  late Future<XFile?> Function(ImageSource source, VideoPickerOptions options) onPickVideo;

  late Future<List<XFile>> Function(MultiVideoPickerOptions options) onPickMultiVideo;

  late Future<LostDataResponse> Function() onGetLostData;

  late bool Function(ImageSource source) onSupportsImageSource;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) => onPickImage(source, options);

  @override
  Future<List<XFile>> pickMultiImage({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) => onPickMultiImage(options);

  @override
  Future<List<XFile>> pickMedia({required MediaPickerOptions options}) => onPickMedia(options);

  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    VideoPickerOptions options = const VideoPickerOptions(),
  }) => onPickVideo(source, options);

  @override
  Future<List<XFile>> pickMultiVideo({
    MultiVideoPickerOptions options = const MultiVideoPickerOptions(),
  }) => onPickMultiVideo(options);

  @override
  Future<LostDataResponse> getLostData() => onGetLostData();

  @override
  bool supportsImageSource(ImageSource source) => onSupportsImageSource(source);
}
