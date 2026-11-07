// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/src/services/binary_messenger.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_android/src/messages.g.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  late ImagePickerAndroid picker;
  late _FakeImagePickerApi api;

  setUp(() {
    CrossFilePlatform.instance = CrossFileTest();

    api = _FakeImagePickerApi();
    picker = ImagePickerAndroid(api: api);
  });

  test('registers instance', () async {
    ImagePickerAndroid.registerWith();
    expect(ImagePickerPlatform.instance, isA<ImagePickerAndroid>());
  });

  group('#pickImage', () {
    test('calls the method correctly', () async {
      const fakePath = '/foo.jpg';
      api.returnValue = <String>[fakePath];
      final XFile? result = await picker.pickImage(source: ImageSource.camera);

      expect((result as FileSystemXFile?)?.path, fakePath);
      expect(api.lastCall, _LastPickType.image);
      expect(api.passedAllowMultiple, false);
    });

    test('passes the gallery image source argument correctly', () async {
      await picker.pickImage(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes the camera image source argument correctly', () async {
      await picker.pickImage(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes default image options', () async {
      await picker.pickImage(source: ImageSource.gallery);

      expect(api.passedImageOptions?.maxWidth, null);
      expect(api.passedImageOptions?.maxHeight, null);
      expect(api.passedImageOptions?.quality, 100);
    });

    test('passes image option arguments correctly', () async {
      await picker.pickImage(
        source: ImageSource.camera,
        options: const ImagePickerOptions(
          imageOptions: ImageOptions(maxWidth: 10, maxHeight: 20, imageQuality: 70),
        ),
      );

      expect(api.passedImageOptions?.maxWidth, 10.0);
      expect(api.passedImageOptions?.maxHeight, 20.0);
      expect(api.passedImageOptions?.quality, 70);
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.pickImage(
          source: ImageSource.gallery,
          options: const ImagePickerOptions(imageOptions: ImageOptions(imageQuality: -1)),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.pickImage(
          source: ImageSource.gallery,
          options: const ImagePickerOptions(imageOptions: ImageOptions(imageQuality: 101)),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.pickImage(
          source: ImageSource.camera,
          options: const ImagePickerOptions(imageOptions: ImageOptions(imageQuality: -1)),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.pickImage(
          source: ImageSource.camera,
          options: const ImagePickerOptions(imageOptions: ImageOptions(imageQuality: 101)),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.pickImage(
          source: ImageSource.camera,
          options: const ImagePickerOptions(imageOptions: ImageOptions(maxWidth: -1)),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.pickImage(
          source: ImageSource.camera,
          options: const ImagePickerOptions(imageOptions: ImageOptions(maxHeight: -1)),
        ),
        throwsArgumentError,
      );
    });

    test('handles a null image path response gracefully', () async {
      api.returnValue = null;

      expect(await picker.pickImage(source: ImageSource.gallery), isNull);
      expect(await picker.pickImage(source: ImageSource.camera), isNull);
    });

    test('camera position defaults to back', () async {
      await picker.pickImage(source: ImageSource.camera);

      expect(api.passedSource?.camera, SourceCamera.rear);
    });

    test('camera position can be set to front', () async {
      await picker.pickImage(
        source: ImageSource.camera,
        options: const ImagePickerOptions(preferredCameraDevice: CameraDevice.front),
      );

      expect(api.passedSource?.camera, SourceCamera.front);
    });

    test('defaults to not using Android Photo Picker', () async {
      await picker.pickImage(source: ImageSource.gallery);

      expect(api.passedPhotoPickerFlag, false);
    });

    test('allows using Android Photo Picker', () async {
      picker.useAndroidPhotoPicker = true;
      await picker.pickImage(source: ImageSource.gallery);

      expect(api.passedPhotoPickerFlag, true);
    });
  });

  group('#pickMultiImage', () {
    test('calls the method correctly', () async {
      const fakePaths = <String>['/foo.jgp', 'bar.jpg'];
      api.returnValue = fakePaths;

      final List<XFile> files = await picker.pickMultiImage();

      expect(api.lastCall, _LastPickType.image);
      expect(api.passedAllowMultiple, true);
      expect(files.length, 2);
      expect((files[0] as FileSystemXFile).path, fakePaths[0]);
      expect((files[1] as FileSystemXFile).path, fakePaths[1]);
    });

    test('passes default image options', () async {
      await picker.pickMultiImage();

      expect(api.passedImageOptions?.maxWidth, null);
      expect(api.passedImageOptions?.maxHeight, null);
      expect(api.passedImageOptions?.quality, 100);
      expect(api.limit, null);
    });

    test('passes image option arguments correctly', () async {
      await picker.pickMultiImage(
        options: const MultiImagePickerOptions(
          imageOptions: ImageOptions(maxWidth: 10, maxHeight: 20, imageQuality: 70),
        ),
      );

      expect(api.passedImageOptions?.maxWidth, 10.0);
      expect(api.passedImageOptions?.maxHeight, 20.0);
      expect(api.passedImageOptions?.quality, 70);
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.pickMultiImage(
          options: const MultiImagePickerOptions(imageOptions: ImageOptions(maxWidth: -1)),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.pickMultiImage(
          options: const MultiImagePickerOptions(imageOptions: ImageOptions(maxHeight: -1)),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.pickMultiImage(
          options: const MultiImagePickerOptions(imageOptions: ImageOptions(imageQuality: -1)),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.pickMultiImage(
          options: const MultiImagePickerOptions(imageOptions: ImageOptions(imageQuality: 101)),
        ),
        throwsArgumentError,
      );
    });

    test('handles an empty path response gracefully', () async {
      api.returnValue = <String>[];

      expect(await picker.pickMultiImage(), <XFile>[]);
    });

    test('defaults to not using Android Photo Picker', () async {
      await picker.pickMultiImage();

      expect(api.passedPhotoPickerFlag, false);
    });

    test('allows using Android Photo Picker', () async {
      picker.useAndroidPhotoPicker = true;
      await picker.pickMultiImage();

      expect(api.passedPhotoPickerFlag, true);
    });
  });

  group('#pickVideo', () {
    test('calls the method correctly', () async {
      const fakePath = '/foo.jpg';
      api.returnValue = <String>[fakePath];
      final XFile? result = await picker.pickVideo(source: ImageSource.camera);

      expect((result as FileSystemXFile?)?.path, fakePath);
      expect(api.lastCall, _LastPickType.video);
      expect(api.passedAllowMultiple, false);
    });

    test('passes the gallery image source argument correctly', () async {
      await picker.pickVideo(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes the camera image source argument correctly', () async {
      await picker.pickVideo(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes null as the default duration', () async {
      await picker.pickVideo(source: ImageSource.gallery);

      expect(api.passedVideoOptions, isNotNull);
      expect(api.passedVideoOptions?.maxDurationSeconds, null);
    });

    test('passes the duration argument correctly', () async {
      await picker.pickVideo(
        source: ImageSource.camera,
        options: const VideoPickerOptions(
          videoOptions: VideoOptions(maxDuration: Duration(minutes: 1)),
        ),
      );

      expect(api.passedVideoOptions?.maxDurationSeconds, 60);
    });

    test('handles a null video path response gracefully', () async {
      api.returnValue = null;

      expect(await picker.pickVideo(source: ImageSource.gallery), isNull);
      expect(await picker.pickVideo(source: ImageSource.camera), isNull);
    });

    test('camera position defaults to back', () async {
      await picker.pickVideo(source: ImageSource.camera);

      expect(api.passedSource?.camera, SourceCamera.rear);
    });

    test('camera position can set to front', () async {
      await picker.pickVideo(
        source: ImageSource.camera,
        options: const VideoPickerOptions(preferredCameraDevice: CameraDevice.front),
      );

      expect(api.passedSource?.camera, SourceCamera.front);
    });

    test('defaults to not using Android Photo Picker', () async {
      await picker.pickVideo(source: ImageSource.gallery);

      expect(api.passedPhotoPickerFlag, false);
    });

    test('allows using Android Photo Picker', () async {
      picker.useAndroidPhotoPicker = true;
      await picker.pickVideo(source: ImageSource.gallery);

      expect(api.passedPhotoPickerFlag, true);
    });
  });

  group('#pickMultiVideo', () {
    test('calls the method correctly', () async {
      const fakePaths = <String>['/foo.mp4', 'bar.mp4'];
      api.returnValue = fakePaths;
      final List<XFile> result = await picker.pickMultiVideo();

      expect(result.length, 2);
      expect((result[0] as FileSystemXFile).path, fakePaths[0]);
      expect(api.lastCall, _LastPickType.video);
      expect(api.passedAllowMultiple, true);
    });

    test('passes the arguments correctly', () async {
      api.returnValue = <String>[];
      await picker.pickMultiVideo(
        options: const MultiVideoPickerOptions(
          videoOptions: VideoOptions(maxDuration: Duration(seconds: 10)),
          limit: 5,
        ),
      );

      expect(api.passedSource?.type, SourceType.gallery);
      expect(api.passedVideoOptions?.maxDurationSeconds, 10);
      expect(api.limit, 5);
    });
  });

  group('#getLostData', () {
    test('getLostData get success response', () async {
      api.returnValue = CacheRetrievalResult(
        type: CacheRetrievalType.image,
        paths: <String>['/example/path'],
      );

      final LostDataResponse response = await picker.getLostData();
      expect(response.type, RetrieveType.image);
      expect(response.file, isNotNull);
      expect((response.file! as FileSystemXFile).path, '/example/path');
    });

    test('getLostData should successfully retrieve multiple files', () async {
      api.returnValue = CacheRetrievalResult(
        type: CacheRetrievalType.image,
        paths: <String>['/example/path0', '/example/path1'],
      );

      final LostDataResponse response = await picker.getLostData();
      expect(response.type, RetrieveType.image);
      expect(response.file, isNotNull);
      expect((response.file! as FileSystemXFile).path, '/example/path1');
      expect((response.files!.first as FileSystemXFile).path, '/example/path0');
      expect(response.files!.length, 2);
    });

    test('getLostData get error response', () async {
      api.returnValue = CacheRetrievalResult(
        type: CacheRetrievalType.video,
        paths: <String>[],
        error: CacheRetrievalError(code: 'test_error_code', message: 'test_error_message'),
      );

      final LostDataResponse response = await picker.getLostData();
      expect(response.type, RetrieveType.video);
      expect(response.exception, isNotNull);
      expect(response.exception!.code, 'test_error_code');
      expect(response.exception!.message, 'test_error_message');
    });

    test('getLostData get null response', () async {
      api.returnValue = null;

      expect((await picker.getLostData()).isEmpty, true);
    });

    test('getLostData get both path and error should throw', () async {
      api.returnValue = CacheRetrievalResult(
        type: CacheRetrievalType.video,
        paths: <String>['/example/path'],
        error: CacheRetrievalError(code: 'test_error_code', message: 'test_error_message'),
      );

      expect(picker.getLostData(), throwsAssertionError);
    });
  });

  group('#pickMedia', () {
    test('calls the method correctly', () async {
      const fakePaths = <String>['/foo.jgp', 'bar.jpg'];
      api.returnValue = fakePaths;

      final List<XFile> files = await picker.pickMedia(
        options: const MediaPickerOptions(allowMultiple: true),
      );

      expect(api.lastCall, _LastPickType.image);
      expect(files.length, 2);
      expect((files[0] as FileSystemXFile).path, fakePaths[0]);
      expect((files[1] as FileSystemXFile).path, fakePaths[1]);
    });

    test('passes default image options', () async {
      await picker.pickMedia(options: const MediaPickerOptions(allowMultiple: true));

      expect(api.passedImageOptions?.maxWidth, null);
      expect(api.passedImageOptions?.maxHeight, null);
      expect(api.passedImageOptions?.quality, 100);
      expect(api.limit, null);
    });

    test('passes image option arguments correctly', () async {
      await picker.pickMedia(
        options: const MediaPickerOptions(
          allowMultiple: true,
          imageOptions: ImageOptions(maxWidth: 10, maxHeight: 20, imageQuality: 70),
          limit: 5,
        ),
      );

      expect(api.passedImageOptions?.maxWidth, 10.0);
      expect(api.passedImageOptions?.maxHeight, 20.0);
      expect(api.passedImageOptions?.quality, 70);
      expect(api.limit, 5);
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.pickMedia(
          options: const MediaPickerOptions(
            allowMultiple: true,
            imageOptions: ImageOptions(maxWidth: -1),
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.pickMedia(
          options: const MediaPickerOptions(
            allowMultiple: true,
            imageOptions: ImageOptions(maxHeight: -1),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.pickMedia(
          options: const MediaPickerOptions(
            allowMultiple: true,
            imageOptions: ImageOptions(imageQuality: -1),
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.pickMedia(
          options: const MediaPickerOptions(
            allowMultiple: true,
            imageOptions: ImageOptions(imageQuality: 101),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid limit argument', () {
      final Matcher throwsLimitArgumentError = throwsA(
        isA<ArgumentError>()
            .having((ArgumentError error) => error.name, 'name', 'limit')
            .having((ArgumentError error) => error.message, 'message', 'cannot be lower than 2'),
      );

      expect(
        () => picker.pickMedia(options: const MediaPickerOptions(allowMultiple: true, limit: -1)),
        throwsLimitArgumentError,
      );

      expect(
        () => picker.pickMedia(options: const MediaPickerOptions(allowMultiple: true, limit: 0)),
        throwsLimitArgumentError,
      );

      expect(
        () => picker.pickMedia(options: const MediaPickerOptions(allowMultiple: true, limit: 1)),
        throwsLimitArgumentError,
      );
    });

    test('does not accept a not null limit when allowMultiple is false', () {
      expect(
        () => picker.pickMedia(options: const MediaPickerOptions(allowMultiple: false, limit: 5)),
        throwsArgumentError,
      );
    });

    test('handles an empty path response gracefully', () async {
      api.returnValue = <String>[];

      expect(
        await picker.pickMedia(options: const MediaPickerOptions(allowMultiple: true)),
        <XFile>[],
      );
    });

    test('defaults to not using Android Photo Picker', () async {
      await picker.pickMedia(options: const MediaPickerOptions(allowMultiple: true));

      expect(api.passedPhotoPickerFlag, false);
    });

    test('allows using Android Photo Picker', () async {
      picker.useAndroidPhotoPicker = true;
      await picker.pickMedia(options: const MediaPickerOptions(allowMultiple: true));

      expect(api.passedPhotoPickerFlag, true);
    });
  });
}

enum _LastPickType { image, video }

class _FakeImagePickerApi implements ImagePickerApi {
  // The value to return.
  Object? returnValue;

  // Passed arguments.
  SourceSpecification? passedSource;
  ImageSelectionOptions? passedImageOptions;
  VideoSelectionOptions? passedVideoOptions;
  bool? passedAllowMultiple;
  bool? passedPhotoPickerFlag;
  int? limit;
  _LastPickType? lastCall;

  @override
  Future<List<String>> pickImages(
    SourceSpecification source,
    ImageSelectionOptions options,
    GeneralOptions generalOptions,
  ) async {
    lastCall = _LastPickType.image;
    passedSource = source;
    passedImageOptions = options;
    passedAllowMultiple = generalOptions.allowMultiple;
    passedPhotoPickerFlag = generalOptions.usePhotoPicker;
    limit = generalOptions.limit;
    return returnValue as List<String>? ?? <String>[];
  }

  @override
  Future<List<String>> pickMedia(
    MediaSelectionOptions options,
    GeneralOptions generalOptions,
  ) async {
    lastCall = _LastPickType.image;
    passedImageOptions = options.imageSelectionOptions;
    passedPhotoPickerFlag = generalOptions.usePhotoPicker;
    passedAllowMultiple = generalOptions.allowMultiple;
    limit = generalOptions.limit;
    return returnValue as List<String>? ?? <String>[];
  }

  @override
  Future<List<String>> pickVideos(
    SourceSpecification source,
    VideoSelectionOptions options,
    GeneralOptions generalOptions,
  ) async {
    lastCall = _LastPickType.video;
    passedSource = source;
    passedVideoOptions = options;
    passedAllowMultiple = generalOptions.allowMultiple;
    passedPhotoPickerFlag = generalOptions.usePhotoPicker;
    limit = generalOptions.limit;
    return returnValue as List<String>? ?? <String>[];
  }

  @override
  Future<CacheRetrievalResult?> retrieveLostResults() async {
    return returnValue as CacheRetrievalResult?;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}

final class CrossFileTest extends CrossFilePlatform {}
