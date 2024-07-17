// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_android/src/messages.g.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  late ImagePickerAndroid picker;
  late _FakeImagePickerApi api;

  setUp(() {
    api = _FakeImagePickerApi();
    picker = ImagePickerAndroid(api: api);
  });

  test('registers instance', () async {
    ImagePickerAndroid.registerWith();
    expect(ImagePickerPlatform.instance, isA<ImagePickerAndroid>());
  });

  group('#pickImage', () {
    test('calls the method correctly', () async {
      const String fakePath = '/foo.jpg';
      api.returnValue = <String>[fakePath];
      final PickedFile? result =
          await picker.pickImage(source: ImageSource.camera);

      expect(result?.path, fakePath);
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
        maxWidth: 10.0,
        maxHeight: 20.0,
        imageQuality: 70,
      );

      expect(api.passedImageOptions?.maxWidth, 10.0);
      expect(api.passedImageOptions?.maxHeight, 20.0);
      expect(api.passedImageOptions?.quality, 70);
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.pickImage(imageQuality: -1, source: ImageSource.gallery),
        throwsArgumentError,
      );

      expect(
        () => picker.pickImage(imageQuality: 101, source: ImageSource.gallery),
        throwsArgumentError,
      );

      expect(
        () => picker.pickImage(imageQuality: -1, source: ImageSource.camera),
        throwsArgumentError,
      );

      expect(
        () => picker.pickImage(imageQuality: 101, source: ImageSource.camera),
        throwsArgumentError,
      );
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.pickImage(source: ImageSource.camera, maxWidth: -1.0),
        throwsArgumentError,
      );

      expect(
        () => picker.pickImage(source: ImageSource.camera, maxHeight: -1.0),
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
          preferredCameraDevice: CameraDevice.front);

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
      const List<String> fakePaths = <String>['/foo.jgp', 'bar.jpg'];
      api.returnValue = fakePaths;

      final List<PickedFile>? files = await picker.pickMultiImage();

      expect(api.lastCall, _LastPickType.image);
      expect(api.passedAllowMultiple, true);
      expect(files?.length, 2);
      expect(files?[0].path, fakePaths[0]);
      expect(files?[1].path, fakePaths[1]);
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
        maxWidth: 10.0,
        maxHeight: 20.0,
        imageQuality: 70,
      );

      expect(api.passedImageOptions?.maxWidth, 10.0);
      expect(api.passedImageOptions?.maxHeight, 20.0);
      expect(api.passedImageOptions?.quality, 70);
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.pickMultiImage(maxWidth: -1.0),
        throwsArgumentError,
      );

      expect(
        () => picker.pickMultiImage(maxHeight: -1.0),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.pickMultiImage(imageQuality: -1),
        throwsArgumentError,
      );

      expect(
        () => picker.pickMultiImage(imageQuality: 101),
        throwsArgumentError,
      );
    });

    test('handles an empty path response gracefully', () async {
      api.returnValue = <String>[];

      expect(await picker.pickMultiImage(), isNull);
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
      const String fakePath = '/foo.jpg';
      api.returnValue = <String>[fakePath];
      final PickedFile? result =
          await picker.pickVideo(source: ImageSource.camera);

      expect(result?.path, fakePath);
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
        maxDuration: const Duration(minutes: 1),
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
        preferredCameraDevice: CameraDevice.front,
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

  group('#retrieveLostData', () {
    test('retrieveLostData get success response', () async {
      api.returnValue = CacheRetrievalResult(
          type: CacheRetrievalType.image, paths: <String>['/example/path']);

      final LostData response = await picker.retrieveLostData();
      expect(response.type, RetrieveType.image);
      expect(response.file, isNotNull);
      expect(response.file!.path, '/example/path');
    });

    test('retrieveLostData get error response', () async {
      api.returnValue = CacheRetrievalResult(
          type: CacheRetrievalType.video,
          paths: <String>[],
          error: CacheRetrievalError(
              code: 'test_error_code', message: 'test_error_message'));

      final LostData response = await picker.retrieveLostData();
      expect(response.type, RetrieveType.video);
      expect(response.exception, isNotNull);
      expect(response.exception!.code, 'test_error_code');
      expect(response.exception!.message, 'test_error_message');
    });

    test('retrieveLostData get null response', () async {
      api.returnValue = null;

      expect((await picker.retrieveLostData()).isEmpty, true);
    });

    test('retrieveLostData get both path and error should throw', () async {
      api.returnValue = CacheRetrievalResult(
          type: CacheRetrievalType.video,
          paths: <String>['/example/path'],
          error: CacheRetrievalError(
              code: 'test_error_code', message: 'test_error_message'));

      expect(picker.retrieveLostData(), throwsAssertionError);
    });
  });

  group('#getImage', () {
    test('calls the method correctly', () async {
      const String fakePath = '/foo.jpg';
      api.returnValue = <String>[fakePath];
      final XFile? result = await picker.getImage(source: ImageSource.camera);

      expect(result?.path, fakePath);
      expect(api.lastCall, _LastPickType.image);
      expect(api.passedAllowMultiple, false);
    });

    test('passes the gallery image source argument correctly', () async {
      await picker.getImage(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes the camera image source argument correctly', () async {
      await picker.getImage(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes default image options', () async {
      await picker.getImage(source: ImageSource.gallery);

      expect(api.passedImageOptions?.maxWidth, null);
      expect(api.passedImageOptions?.maxHeight, null);
      expect(api.passedImageOptions?.quality, 100);
    });

    test('passes image option arguments correctly', () async {
      await picker.getImage(
        source: ImageSource.camera,
        maxWidth: 10.0,
        maxHeight: 20.0,
        imageQuality: 70,
      );

      expect(api.passedImageOptions?.maxWidth, 10.0);
      expect(api.passedImageOptions?.maxHeight, 20.0);
      expect(api.passedImageOptions?.quality, 70);
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.getImage(imageQuality: -1, source: ImageSource.gallery),
        throwsArgumentError,
      );

      expect(
        () => picker.getImage(imageQuality: 101, source: ImageSource.gallery),
        throwsArgumentError,
      );

      expect(
        () => picker.getImage(imageQuality: -1, source: ImageSource.camera),
        throwsArgumentError,
      );

      expect(
        () => picker.getImage(imageQuality: 101, source: ImageSource.camera),
        throwsArgumentError,
      );
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.getImage(source: ImageSource.camera, maxWidth: -1.0),
        throwsArgumentError,
      );

      expect(
        () => picker.getImage(source: ImageSource.camera, maxHeight: -1.0),
        throwsArgumentError,
      );
    });

    test('handles a null image path response gracefully', () async {
      api.returnValue = null;

      expect(await picker.getImage(source: ImageSource.gallery), isNull);
      expect(await picker.getImage(source: ImageSource.camera), isNull);
    });

    test('camera position defaults to back', () async {
      await picker.getImage(source: ImageSource.camera);

      expect(api.passedSource?.camera, SourceCamera.rear);
    });

    test('camera position can set to front', () async {
      await picker.getImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);

      expect(api.passedSource?.camera, SourceCamera.front);
    });

    test('defaults to not using Android Photo Picker', () async {
      await picker.getImage(source: ImageSource.gallery);

      expect(api.passedPhotoPickerFlag, false);
    });

    test('allows using Android Photo Picker', () async {
      picker.useAndroidPhotoPicker = true;
      await picker.getImage(source: ImageSource.gallery);

      expect(api.passedPhotoPickerFlag, true);
    });
  });

  group('#getMultiImage', () {
    test('calls the method correctly', () async {
      const List<String> fakePaths = <String>['/foo.jgp', 'bar.jpg'];
      api.returnValue = fakePaths;

      final List<XFile>? files = await picker.getMultiImage();

      expect(api.lastCall, _LastPickType.image);
      expect(api.passedAllowMultiple, true);
      expect(files?.length, 2);
      expect(files?[0].path, fakePaths[0]);
      expect(files?[1].path, fakePaths[1]);
    });

    test('passes default image options', () async {
      await picker.getMultiImage();

      expect(api.passedImageOptions?.maxWidth, null);
      expect(api.passedImageOptions?.maxHeight, null);
      expect(api.passedImageOptions?.quality, 100);
      expect(api.limit, null);
    });

    test('passes image option arguments correctly', () async {
      await picker.getMultiImage(
        maxWidth: 10.0,
        maxHeight: 20.0,
        imageQuality: 70,
      );

      expect(api.passedImageOptions?.maxWidth, 10.0);
      expect(api.passedImageOptions?.maxHeight, 20.0);
      expect(api.passedImageOptions?.quality, 70);
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.getMultiImage(maxWidth: -1.0),
        throwsArgumentError,
      );

      expect(
        () => picker.getMultiImage(maxHeight: -1.0),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.getMultiImage(imageQuality: -1),
        throwsArgumentError,
      );

      expect(
        () => picker.getMultiImage(imageQuality: 101),
        throwsArgumentError,
      );
    });

    test('handles an empty image path response gracefully', () async {
      api.returnValue = <String>[];

      expect(await picker.getMultiImage(), isNull);
      expect(await picker.getMultiImage(), isNull);
    });

    test('defaults to not using Android Photo Picker', () async {
      await picker.getMultiImage();

      expect(api.passedPhotoPickerFlag, false);
    });

    test('allows using Android Photo Picker', () async {
      picker.useAndroidPhotoPicker = true;
      await picker.getMultiImage();

      expect(api.passedPhotoPickerFlag, true);
    });
  });

  group('#getVideo', () {
    test('calls the method correctly', () async {
      const String fakePath = '/foo.jpg';
      api.returnValue = <String>[fakePath];
      final XFile? result = await picker.getVideo(source: ImageSource.camera);

      expect(result?.path, fakePath);
      expect(api.lastCall, _LastPickType.video);
      expect(api.passedAllowMultiple, false);
    });

    test('passes the gallery image source argument correctly', () async {
      await picker.getVideo(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes the camera image source argument correctly', () async {
      await picker.getVideo(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes null as the default duration', () async {
      await picker.getVideo(source: ImageSource.gallery);

      expect(api.passedVideoOptions, isNotNull);
      expect(api.passedVideoOptions?.maxDurationSeconds, null);
    });

    test('passes the duration argument correctly', () async {
      await picker.getVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 1),
      );

      expect(api.passedVideoOptions?.maxDurationSeconds, 60);
    });

    test('handles a null video path response gracefully', () async {
      api.returnValue = null;

      expect(await picker.getVideo(source: ImageSource.gallery), isNull);
      expect(await picker.getVideo(source: ImageSource.camera), isNull);
    });

    test('camera position defaults to back', () async {
      await picker.getVideo(source: ImageSource.camera);

      expect(api.passedSource?.camera, SourceCamera.rear);
    });

    test('camera position can set to front', () async {
      await picker.getVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      expect(api.passedSource?.camera, SourceCamera.front);
    });

    test('defaults to not using Android Photo Picker', () async {
      await picker.getVideo(source: ImageSource.gallery);

      expect(api.passedPhotoPickerFlag, false);
    });

    test('allows using Android Photo Picker', () async {
      picker.useAndroidPhotoPicker = true;
      await picker.getVideo(source: ImageSource.gallery);

      expect(api.passedPhotoPickerFlag, true);
    });
  });

  group('#getLostData', () {
    test('getLostData get success response', () async {
      api.returnValue = CacheRetrievalResult(
          type: CacheRetrievalType.image, paths: <String>['/example/path']);

      final LostDataResponse response = await picker.getLostData();
      expect(response.type, RetrieveType.image);
      expect(response.file, isNotNull);
      expect(response.file!.path, '/example/path');
    });

    test('getLostData should successfully retrieve multiple files', () async {
      api.returnValue = CacheRetrievalResult(
          type: CacheRetrievalType.image,
          paths: <String>['/example/path0', '/example/path1']);

      final LostDataResponse response = await picker.getLostData();
      expect(response.type, RetrieveType.image);
      expect(response.file, isNotNull);
      expect(response.file!.path, '/example/path1');
      expect(response.files!.first.path, '/example/path0');
      expect(response.files!.length, 2);
    });

    test('getLostData get error response', () async {
      api.returnValue = CacheRetrievalResult(
          type: CacheRetrievalType.video,
          paths: <String>[],
          error: CacheRetrievalError(
              code: 'test_error_code', message: 'test_error_message'));

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
          error: CacheRetrievalError(
              code: 'test_error_code', message: 'test_error_message'));

      expect(picker.getLostData(), throwsAssertionError);
    });
  });

  group('#getMedia', () {
    test('calls the method correctly', () async {
      const List<String> fakePaths = <String>['/foo.jgp', 'bar.jpg'];
      api.returnValue = fakePaths;

      final List<XFile> files = await picker.getMedia(
        options: const MediaOptions(
          allowMultiple: true,
        ),
      );

      expect(api.lastCall, _LastPickType.image);
      expect(files.length, 2);
      expect(files[0].path, fakePaths[0]);
      expect(files[1].path, fakePaths[1]);
    });

    test('passes default image options', () async {
      await picker.getMedia(
        options: const MediaOptions(
          allowMultiple: true,
        ),
      );

      expect(api.passedImageOptions?.maxWidth, null);
      expect(api.passedImageOptions?.maxHeight, null);
      expect(api.passedImageOptions?.quality, 100);
      expect(api.limit, null);
    });

    test('passes image option arguments correctly', () async {
      await picker.getMedia(
          options: const MediaOptions(
        allowMultiple: true,
        imageOptions: ImageOptions(
          maxWidth: 10.0,
          maxHeight: 20.0,
          imageQuality: 70,
        ),
        limit: 5,
      ));

      expect(api.passedImageOptions?.maxWidth, 10.0);
      expect(api.passedImageOptions?.maxHeight, 20.0);
      expect(api.passedImageOptions?.quality, 70);
      expect(api.limit, 5);
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.getMedia(
          options: const MediaOptions(
            allowMultiple: true,
            imageOptions: ImageOptions(maxWidth: -1.0),
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getMedia(
          options: const MediaOptions(
            allowMultiple: true,
            imageOptions: ImageOptions(maxHeight: -1.0),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.getMedia(
          options: const MediaOptions(
            allowMultiple: true,
            imageOptions: ImageOptions(imageQuality: -1),
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getMedia(
          options: const MediaOptions(
            allowMultiple: true,
            imageOptions: ImageOptions(imageQuality: 101),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid limit argument', () {
      expect(
        () => picker.getMedia(
          options: const MediaOptions(
            allowMultiple: true,
            limit: -1,
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getMedia(
          options: const MediaOptions(
            allowMultiple: true,
            limit: 0,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept a not null limit when allowMultiple is false', () {
      expect(
        () => picker.getMedia(
          options: const MediaOptions(allowMultiple: false, limit: 5),
        ),
        throwsArgumentError,
      );
    });

    test('handles an empty path response gracefully', () async {
      api.returnValue = <String>[];

      expect(
          await picker.getMedia(
            options: const MediaOptions(
              allowMultiple: true,
            ),
          ),
          <String>[]);
    });

    test('defaults to not using Android Photo Picker', () async {
      await picker.getMedia(
        options: const MediaOptions(
          allowMultiple: true,
        ),
      );

      expect(api.passedPhotoPickerFlag, false);
    });

    test('allows using Android Photo Picker', () async {
      picker.useAndroidPhotoPicker = true;
      await picker.getMedia(
        options: const MediaOptions(
          allowMultiple: true,
        ),
      );

      expect(api.passedPhotoPickerFlag, true);
    });
  });

  group('#getImageFromSource', () {
    test('calls the method correctly', () async {
      const String fakePath = '/foo.jpg';
      api.returnValue = <String>[fakePath];
      final XFile? result = await picker.getImage(source: ImageSource.camera);

      expect(result?.path, fakePath);
      expect(api.lastCall, _LastPickType.image);
      expect(api.passedAllowMultiple, false);
    });

    test('passes the gallery image source argument correctly', () async {
      await picker.getImageFromSource(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes the camera image source argument correctly', () async {
      await picker.getImageFromSource(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes default image options', () async {
      await picker.getImageFromSource(source: ImageSource.gallery);

      expect(api.passedImageOptions?.maxWidth, null);
      expect(api.passedImageOptions?.maxHeight, null);
      expect(api.passedImageOptions?.quality, 100);
    });

    test('passes image option arguments correctly', () async {
      await picker.getImageFromSource(
        source: ImageSource.camera,
        options: const ImagePickerOptions(
          maxWidth: 10.0,
          maxHeight: 20.0,
          imageQuality: 70,
        ),
      );

      expect(api.passedImageOptions?.maxWidth, 10.0);
      expect(api.passedImageOptions?.maxHeight, 20.0);
      expect(api.passedImageOptions?.quality, 70);
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.getImageFromSource(
          source: ImageSource.gallery,
          options: const ImagePickerOptions(imageQuality: -1),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getImageFromSource(
          source: ImageSource.gallery,
          options: const ImagePickerOptions(imageQuality: 101),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getImageFromSource(
          source: ImageSource.camera,
          options: const ImagePickerOptions(imageQuality: -1),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getImageFromSource(
          source: ImageSource.camera,
          options: const ImagePickerOptions(imageQuality: 101),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.getImageFromSource(
          source: ImageSource.camera,
          options: const ImagePickerOptions(maxWidth: -1.0),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getImageFromSource(
          source: ImageSource.camera,
          options: const ImagePickerOptions(maxHeight: -1.0),
        ),
        throwsArgumentError,
      );
    });

    test('handles a null image path response gracefully', () async {
      api.returnValue = null;

      expect(
          await picker.getImageFromSource(source: ImageSource.gallery), isNull);
      expect(
          await picker.getImageFromSource(source: ImageSource.camera), isNull);
    });

    test('camera position defaults to back', () async {
      await picker.getImageFromSource(source: ImageSource.camera);

      expect(api.passedSource?.camera, SourceCamera.rear);
    });

    test('camera position can be set to front', () async {
      await picker.getImageFromSource(
          source: ImageSource.camera,
          options: const ImagePickerOptions(
              preferredCameraDevice: CameraDevice.front));

      expect(api.passedSource?.camera, SourceCamera.front);
    });

    test('defaults to not using Android Photo Picker', () async {
      await picker.getImageFromSource(source: ImageSource.gallery);

      expect(api.passedPhotoPickerFlag, false);
    });

    test('allows using Android Photo Picker', () async {
      picker.useAndroidPhotoPicker = true;
      await picker.getImageFromSource(source: ImageSource.gallery);

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
  Future<List<String?>> pickImages(
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
    return returnValue as List<String?>? ?? <String>[];
  }

  @override
  Future<List<String?>> pickMedia(
    MediaSelectionOptions options,
    GeneralOptions generalOptions,
  ) async {
    lastCall = _LastPickType.image;
    passedImageOptions = options.imageSelectionOptions;
    passedPhotoPickerFlag = generalOptions.usePhotoPicker;
    passedAllowMultiple = generalOptions.allowMultiple;
    limit = generalOptions.limit;
    return returnValue as List<String?>? ?? <String>[];
  }

  @override
  Future<List<String?>> pickVideos(
    SourceSpecification source,
    VideoSelectionOptions options,
    GeneralOptions generalOptions,
  ) async {
    lastCall = _LastPickType.video;
    passedSource = source;
    passedVideoOptions = options;
    passedAllowMultiple = generalOptions.allowMultiple;
    passedPhotoPickerFlag = generalOptions.usePhotoPicker;
    return returnValue as List<String?>? ?? <String>[];
  }

  @override
  Future<CacheRetrievalResult?> retrieveLostResults() async {
    return returnValue as CacheRetrievalResult?;
  }
}
