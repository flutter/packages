// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_ios/image_picker_ios.dart';
import 'package:image_picker_ios/src/messages.g.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ImagePickerIOS picker;
  late _FakeImagePickerApi api;

  setUp(() {
    api = _FakeImagePickerApi();
    picker = ImagePickerIOS(api: api);
  });

  test('can be instantiated', () {
    expect(ImagePickerIOS(), isNotNull);
  });

  test('registration', () async {
    ImagePickerIOS.registerWith();
    expect(ImagePickerPlatform.instance, isA<ImagePickerIOS>());
  });

  group('#pickImage', () {
    test('calls the method correctly with default arguments', () async {
      api.returnValue = <String>['/foo.png'];
      final PickedFile? result = await picker.pickImage(
        source: ImageSource.camera,
      );
      expect(result?.path, '/foo.png');
      expect(api.passedSelectionType, _SelectionType.image);
      expect(api.passedMaxSize?.width, null);
      expect(api.passedMaxSize?.height, null);
      expect(api.passedImageQuality, null);
      expect(api.passedSource?.camera, SourceCamera.rear);
      expect(api.passedRequestFullMetadata, true);
    });

    test('passes camera source argument correctly', () async {
      await picker.pickImage(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes gallery source argument correctly', () async {
      await picker.pickImage(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes width and height arguments correctly', () async {
      await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 10.0,
        maxHeight: 20.0,
      );

      expect(api.passedMaxSize?.width, 10);
      expect(api.passedMaxSize?.height, 20);
    });

    test('passes image quality correctly', () async {
      await picker.pickImage(source: ImageSource.camera, imageQuality: 70);

      expect(api.passedImageQuality, 70);
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
      api.returnValue = <String>[];

      expect(await picker.pickImage(source: ImageSource.gallery), isNull);
    });

    test('camera position can set to front', () async {
      await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      expect(api.passedSource?.camera, SourceCamera.front);
    });
  });

  group('#pickMultiImage', () {
    test('calls the method correctly with default arguments', () async {
      api.returnValue = <String>['/foo.png', '/bar.png'];
      final List<PickedFile>? result = await picker.pickMultiImage();

      expect(result?.length, 2);
      expect(result?[0].path, '/foo.png');
      expect(result?[1].path, '/bar.png');
      expect(api.passedSelectionType, _SelectionType.multiImage);
      expect(api.passedRequestFullMetadata, true);
      expect(api.passedMaxSize?.width, null);
      expect(api.passedMaxSize?.height, null);
      expect(api.passedImageQuality, null);
      expect(api.passedLimit, null);
    });

    test('passes the width and height arguments correctly', () async {
      await picker.pickMultiImage(maxWidth: 10.0, maxHeight: 20.0);

      expect(api.passedMaxSize?.width, 10);
      expect(api.passedMaxSize?.height, 20);
    });

    test('does not accept a negative width or height argument', () {
      expect(() => picker.pickMultiImage(maxWidth: -1.0), throwsArgumentError);

      expect(() => picker.pickMultiImage(maxHeight: -1.0), throwsArgumentError);
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

    test('returns null for an empty list', () async {
      api.returnValue = <String>[];

      expect(await picker.pickMultiImage(), isNull);
    });
  });

  group('#pickVideo', () {
    test('calls the method correctly with default arguments', () async {
      api.returnValue = <String>['/foo.mp4'];
      final PickedFile? result = await picker.pickVideo(
        source: ImageSource.camera,
      );

      expect(result?.path, '/foo.mp4');
      expect(api.passedSelectionType, _SelectionType.video);
      expect(api.passedMaxDurationSeconds, null);
    });

    test('passes the camera source argument correctly', () async {
      await picker.pickVideo(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes the gallery source argument correctly', () async {
      await picker.pickVideo(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes the duration argument correctly', () async {
      await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 1),
      );

      expect(api.passedMaxDurationSeconds, 60);
    });

    test('handles a null video path response gracefully', () async {
      api.returnValue = <String>[];

      expect(await picker.pickVideo(source: ImageSource.gallery), isNull);
      expect(await picker.pickVideo(source: ImageSource.camera), isNull);
    });

    test('camera position can set to front', () async {
      await picker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      expect(api.passedSource?.camera, SourceCamera.front);
    });
  });

  group('#getImage', () {
    test('calls the method correctly with default arguments', () async {
      api.returnValue = <String>['/foo.png'];
      final XFile? result = await picker.getImage(source: ImageSource.camera);

      expect(result?.path, '/foo.png');
      expect(api.passedSelectionType, _SelectionType.image);
      expect(api.passedRequestFullMetadata, true);
      expect(api.passedMaxSize?.width, null);
      expect(api.passedMaxSize?.height, null);
      expect(api.passedImageQuality, null);
    });

    test('passes the camera image source argument correctly', () async {
      await picker.getImage(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes the gallery image source argument correctly', () async {
      await picker.getImage(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes the width and height arguments correctly', () async {
      await picker.getImage(
        source: ImageSource.camera,
        maxWidth: 10.0,
        maxHeight: 20.0,
      );

      expect(api.passedMaxSize?.width, 10);
      expect(api.passedMaxSize?.height, 20);
    });

    test('passes image quality argument correctly', () async {
      await picker.getImage(source: ImageSource.camera, imageQuality: 70);

      expect(api.passedImageQuality, 70);
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
      api.returnValue = <String>[];

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
        preferredCameraDevice: CameraDevice.front,
      );

      expect(api.passedSource?.camera, SourceCamera.front);
    });
  });

  group('#getMultiImage', () {
    test('calls the method correctly with default arguments', () async {
      api.returnValue = <String>['/foo.png', '/bar.png'];
      final List<XFile>? result = await picker.getMultiImage();

      expect(result?.length, 2);
      expect(result?[0].path, '/foo.png');
      expect(result?[1].path, '/bar.png');
      expect(api.passedSelectionType, _SelectionType.multiImage);
      expect(api.passedRequestFullMetadata, true);
      expect(api.passedMaxSize?.width, null);
      expect(api.passedMaxSize?.height, null);
      expect(api.passedImageQuality, null);
      expect(api.passedLimit, null);
    });

    test('passes the width and height arguments correctly', () async {
      await picker.getMultiImage(maxWidth: 10.0, maxHeight: 20.0);

      expect(api.passedMaxSize?.width, 10);
      expect(api.passedMaxSize?.height, 20);
    });

    test('passes the image quality argument correctly', () async {
      await picker.getMultiImage(imageQuality: 70);

      expect(api.passedImageQuality, 70);
    });

    test('does not accept a negative width or height argument', () {
      expect(() => picker.getMultiImage(maxWidth: -1.0), throwsArgumentError);

      expect(() => picker.getMultiImage(maxHeight: -1.0), throwsArgumentError);
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(() => picker.getMultiImage(imageQuality: -1), throwsArgumentError);

      expect(
        () => picker.getMultiImage(imageQuality: 101),
        throwsArgumentError,
      );
    });

    test('returns null for an empty list', () async {
      api.returnValue = <String>[];

      expect(await picker.getMultiImage(), isNull);
    });
  });

  group('#getMedia', () {
    test('calls the method correctly with default arguments', () async {
      api.returnValue = <String>['/foo.png', '/bar.mp4'];
      final List<XFile> result = await picker.getMedia(
        options: const MediaOptions(allowMultiple: true),
      );

      expect(result.length, 2);
      expect(result[0].path, '/foo.png');
      expect(result[1].path, '/bar.mp4');
      expect(api.passedSelectionType, _SelectionType.media);
      expect(api.passedMediaSelectionOptions?.allowMultiple, true);
      expect(api.passedMediaSelectionOptions?.requestFullMetadata, true);
      expect(api.passedMediaSelectionOptions?.maxSize.width, null);
      expect(api.passedMediaSelectionOptions?.maxSize.height, null);
      expect(api.passedMediaSelectionOptions?.imageQuality, null);
      expect(api.passedMediaSelectionOptions?.limit, null);
    });

    test('passes the width and height arguments correctly', () async {
      await picker.getMedia(
        options: MediaOptions(
          allowMultiple: true,
          imageOptions: ImageOptions.createAndValidate(
            maxWidth: 10.0,
            maxHeight: 20.0,
          ),
        ),
      );

      expect(api.passedMediaSelectionOptions?.maxSize.width, 10);
      expect(api.passedMediaSelectionOptions?.maxSize.height, 20);
    });

    test('passes the image quality argument correctly', () async {
      await picker.getMedia(
        options: MediaOptions(
          allowMultiple: true,
          imageOptions: ImageOptions.createAndValidate(imageQuality: 70),
        ),
      );

      expect(api.passedMediaSelectionOptions?.imageQuality, 70);
    });

    test('passes request metadata argument correctly', () async {
      await picker.getMedia(
        options: const MediaOptions(
          allowMultiple: true,
          imageOptions: ImageOptions(requestFullMetadata: false),
        ),
      );

      expect(api.passedMediaSelectionOptions?.requestFullMetadata, false);
    });

    test('passes allowMultiple argument correctly', () async {
      await picker.getMedia(options: const MediaOptions(allowMultiple: false));

      expect(api.passedMediaSelectionOptions?.allowMultiple, false);
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.getMedia(
          options: MediaOptions(
            allowMultiple: true,
            imageOptions: ImageOptions.createAndValidate(maxWidth: -1.0),
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getMedia(
          options: MediaOptions(
            allowMultiple: true,
            imageOptions: ImageOptions.createAndValidate(maxHeight: -1.0),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.getMedia(
          options: MediaOptions(
            allowMultiple: true,
            imageOptions: ImageOptions.createAndValidate(imageQuality: -1),
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getMedia(
          options: MediaOptions(
            allowMultiple: true,
            imageOptions: ImageOptions.createAndValidate(imageQuality: 101),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid limit argument', () {
      final Matcher throwsLimitArgumentError = throwsA(
        isA<ArgumentError>()
            .having((ArgumentError error) => error.name, 'name', 'limit')
            .having(
              (ArgumentError error) => error.message,
              'message',
              'cannot be lower than 2',
            ),
      );

      expect(
        () => picker.getMedia(
          options: const MediaOptions(allowMultiple: true, limit: -1),
        ),
        throwsLimitArgumentError,
      );

      expect(
        () => picker.getMedia(
          options: const MediaOptions(allowMultiple: true, limit: 0),
        ),
        throwsLimitArgumentError,
      );

      expect(
        () => picker.getMedia(
          options: const MediaOptions(allowMultiple: true, limit: 1),
        ),
        throwsLimitArgumentError,
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

    test('validates maxWidth and maxHeight', () {
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

    test('validates imageQuality', () {
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

    test('handles a empty path response gracefully', () async {
      api.returnValue = <String>[];

      expect(
        await picker.getMedia(options: const MediaOptions(allowMultiple: true)),
        <String>[],
      );
    });
  });

  group('#getVideo', () {
    test('calls the method correctly with default arguments', () async {
      api.returnValue = <String>['/foo.mp4'];
      final XFile? result = await picker.getVideo(source: ImageSource.gallery);

      expect(result?.path, '/foo.mp4');
      expect(api.passedSelectionType, _SelectionType.video);
      expect(api.passedMaxDurationSeconds, null);
    });

    test('passes the camera image source argument correctly', () async {
      await picker.getVideo(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes the gallery image source argument correctly', () async {
      await picker.getVideo(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes the duration argument correctly', () async {
      await picker.getVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 1),
      );

      expect(api.passedMaxDurationSeconds, 60);
    });

    test('handles a null video path response gracefully', () async {
      api.returnValue = <String>[];

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
  });

  group('#getMultiVideoWithOptions', () {
    test('calls the method correctly', () async {
      api.returnValue = <String>['/foo.mp4', 'bar.mp4'];
      final List<XFile> result = await picker.getMultiVideoWithOptions();

      expect(result.length, 2);
      expect(result[0].path, '/foo.mp4');
      expect(result[1].path, 'bar.mp4');
      expect(api.passedSelectionType, _SelectionType.multiVideo);
      expect(api.passedMaxDurationSeconds, null);
      expect(api.passedLimit, null);
    });

    test('passes the arguments correctly', () async {
      api.returnValue = <String>[];
      await picker.getMultiVideoWithOptions(
        options: const MultiVideoPickerOptions(
          maxDuration: Duration(seconds: 10),
          limit: 5,
        ),
      );

      expect(api.passedMaxDurationSeconds, 10);
      expect(api.passedLimit, 5);
    });
  });

  group('#getImageFromSource', () {
    test('calls the method correctly with default arguments', () async {
      api.returnValue = <String>['/foo.png'];
      final XFile? result = await picker.getImageFromSource(
        source: ImageSource.camera,
      );

      expect(result?.path, '/foo.png');
      expect(api.passedSelectionType, _SelectionType.image);
      expect(api.passedRequestFullMetadata, true);
      expect(api.passedMaxSize?.width, null);
      expect(api.passedMaxSize?.height, null);
      expect(api.passedImageQuality, null);
    });

    test('passes the camera image source argument correctly', () async {
      await picker.getImageFromSource(source: ImageSource.camera);

      expect(api.passedSource?.type, SourceType.camera);
    });

    test('passes the gallery image source argument correctly', () async {
      await picker.getImageFromSource(source: ImageSource.gallery);

      expect(api.passedSource?.type, SourceType.gallery);
    });

    test('passes the width and height arguments correctly', () async {
      await picker.getImageFromSource(
        source: ImageSource.camera,
        options: const ImagePickerOptions(maxWidth: 10.0, maxHeight: 20.0),
      );

      expect(api.passedMaxSize?.width, 10);
      expect(api.passedMaxSize?.height, 20);
    });

    test('passes the image quality argument correctly', () async {
      await picker.getImageFromSource(
        source: ImageSource.camera,
        options: const ImagePickerOptions(imageQuality: 70),
      );

      expect(api.passedImageQuality, 70);
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
      api.returnValue = <String>[];

      expect(
        await picker.getImageFromSource(source: ImageSource.gallery),
        isNull,
      );
      expect(
        await picker.getImageFromSource(source: ImageSource.camera),
        isNull,
      );
    });

    test('camera position defaults to back', () async {
      await picker.getImageFromSource(source: ImageSource.camera);

      expect(api.passedSource?.camera, SourceCamera.rear);
    });

    test('camera position can set to front', () async {
      await picker.getImageFromSource(
        source: ImageSource.camera,
        options: const ImagePickerOptions(
          preferredCameraDevice: CameraDevice.front,
        ),
      );

      expect(api.passedSource?.camera, SourceCamera.front);
    });

    test('passes the request full metadata argument correctly', () async {
      await picker.getImageFromSource(
        source: ImageSource.gallery,
        options: const ImagePickerOptions(requestFullMetadata: false),
      );

      expect(api.passedRequestFullMetadata, false);
    });
  });

  group('#getMultiImageWithOptions', () {
    test('calls the method correctly with default arguments', () async {
      api.returnValue = <String>['/foo.png', '/bar.png'];
      final List<XFile> result = await picker.getMultiImageWithOptions();

      expect(result.length, 2);
      expect(result[0].path, '/foo.png');
      expect(result[1].path, '/bar.png');
      expect(api.passedSelectionType, _SelectionType.multiImage);
      expect(api.passedRequestFullMetadata, true);
      expect(api.passedMaxSize?.width, null);
      expect(api.passedMaxSize?.height, null);
      expect(api.passedImageQuality, null);
      expect(api.passedLimit, null);
    });

    test('passes the width and height arguments correctly', () async {
      await picker.getMultiImageWithOptions(
        options: const MultiImagePickerOptions(
          imageOptions: ImageOptions(maxWidth: 10.0, maxHeight: 20.0),
        ),
      );

      expect(api.passedMaxSize?.width, 10);
      expect(api.passedMaxSize?.height, 20);
    });

    test('passes the image quality argument correctly', () async {
      await picker.getMultiImageWithOptions(
        options: const MultiImagePickerOptions(
          imageOptions: ImageOptions(imageQuality: 70),
        ),
      );

      expect(api.passedImageQuality, 70);
    });

    test('passes the limit argument correctly', () async {
      await picker.getMultiImageWithOptions(
        options: const MultiImagePickerOptions(limit: 5),
      );

      expect(api.passedLimit, 5);
    });

    test('does not accept a negative width or height argument', () {
      expect(
        () => picker.getMultiImageWithOptions(
          options: const MultiImagePickerOptions(
            imageOptions: ImageOptions(maxWidth: -1.0),
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getMultiImageWithOptions(
          options: const MultiImagePickerOptions(
            imageOptions: ImageOptions(maxHeight: -1.0),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('does not accept an invalid imageQuality argument', () {
      expect(
        () => picker.getMultiImageWithOptions(
          options: const MultiImagePickerOptions(
            imageOptions: ImageOptions(imageQuality: -1),
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => picker.getMultiImageWithOptions(
          options: const MultiImagePickerOptions(
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
            .having(
              (ArgumentError error) => error.message,
              'message',
              'cannot be lower than 2',
            ),
      );

      expect(
        () => picker.getMultiImageWithOptions(
          options: const MultiImagePickerOptions(limit: -1),
        ),
        throwsLimitArgumentError,
      );

      expect(
        () => picker.getMultiImageWithOptions(
          options: const MultiImagePickerOptions(limit: 0),
        ),
        throwsLimitArgumentError,
      );

      expect(
        () => picker.getMultiImageWithOptions(
          options: const MultiImagePickerOptions(limit: 1),
        ),
        throwsLimitArgumentError,
      );
    });

    test('handles an empty response', () async {
      api.returnValue = <String>[];

      expect(await picker.getMultiImageWithOptions(), isEmpty);
    });

    test('Passes the request full metadata argument correctly', () async {
      await picker.getMultiImageWithOptions(
        options: const MultiImagePickerOptions(
          imageOptions: ImageOptions(requestFullMetadata: false),
        ),
      );

      expect(api.passedRequestFullMetadata, false);
    });
  });

  group('#getMultiVideoWithOptions', () {
    test('calls the method correctly', () async {
      api.returnValue = <String>['/foo.mp4', 'bar.mp4'];
      final List<XFile> result = await picker.getMultiVideoWithOptions();

      expect(result.length, 2);
      expect(result[0].path, '/foo.mp4');
      expect(result[1].path, 'bar.mp4');
      expect(api.passedSelectionType, _SelectionType.multiVideo);
      expect(api.passedMaxDurationSeconds, null);
      expect(api.passedLimit, null);
    });

    test('handles an empty response', () async {
      api.returnValue = <String>[];
      final List<XFile> result = await picker.getMultiVideoWithOptions();
      expect(result, isEmpty);
    });

    test('passes the arguments correctly', () async {
      api.returnValue = <String>[];
      await picker.getMultiVideoWithOptions(
        options: const MultiVideoPickerOptions(
          maxDuration: Duration(seconds: 10),
          limit: 5,
        ),
      );

      expect(api.passedMaxDurationSeconds, 10);
      expect(api.passedLimit, 5);
    });
  });

  test('converts SourceType correctly', () async {
    // This is implicitly tested in other tests, but let's be explicit
    await picker.pickImage(source: ImageSource.camera);
    expect(api.passedSource?.type, SourceType.camera);

    await picker.pickImage(source: ImageSource.gallery);
    expect(api.passedSource?.type, SourceType.gallery);
  });

  test('converts SourceCamera correctly', () async {
    await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    expect(api.passedSource?.camera, SourceCamera.front);

    await picker.pickImage(source: ImageSource.camera);
    expect(api.passedSource?.camera, SourceCamera.rear);
  });

  group('Pigeon models', () {
    test('MaxSize equality and hashCode', () {
      final MaxSize a = MaxSize(width: 10, height: 20);
      final MaxSize b = MaxSize(width: 10, height: 20);
      final MaxSize c = MaxSize(width: 11, height: 20);
      final MaxSize nanSize = MaxSize(width: double.nan, height: 20);
      final MaxSize nanSize2 = MaxSize(width: double.nan, height: 20);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(nanSize));
      expect(nanSize, nanSize2);
      expect(nanSize.hashCode, nanSize2.hashCode);
    });

    test('MaxSize encode and decode', () {
      final MaxSize a = MaxSize(width: 10, height: 20);
      final Object encoded = a.encode();
      final MaxSize decoded = MaxSize.decode(encoded);

      expect(a, decoded);
    });

    test('MaxSize identity', () {
      final MaxSize a = MaxSize(width: 10, height: 20);
      expect(a, a);
    });

    test('MaxSize inequality with other types', () {
      final MaxSize a = MaxSize(width: 10, height: 20);
      // ignore: ComparisonWithNonFunctionalType
      expect(a == 'not a MaxSize', isFalse);
    });

    test('MaxSize hashCode normalizes zero', () {
      final MaxSize posZero = MaxSize(width: 0.0, height: 0.0);
      final MaxSize negZero = MaxSize(width: -0.0, height: -0.0);
      expect(posZero.hashCode, negZero.hashCode);
    });

    test('MediaSelectionOptions equality and hashCode', () {
      final MaxSize size1 = MaxSize(width: 10, height: 20);
      final MaxSize size2 = MaxSize(width: 10, height: 20);
      final MediaSelectionOptions a = MediaSelectionOptions(
        maxSize: size1,
        imageQuality: 70,
        requestFullMetadata: true,
        allowMultiple: true,
        limit: 5,
      );
      final MediaSelectionOptions b = MediaSelectionOptions(
        maxSize: size2,
        imageQuality: 70,
        requestFullMetadata: true,
        allowMultiple: true,
        limit: 5,
      );
      final MediaSelectionOptions c = MediaSelectionOptions(
        maxSize: size1,
        imageQuality: 71,
        requestFullMetadata: true,
        allowMultiple: true,
        limit: 5,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('MediaSelectionOptions encode and decode', () {
      final MediaSelectionOptions a = MediaSelectionOptions(
        maxSize: MaxSize(width: 10, height: 20),
        imageQuality: 70,
        requestFullMetadata: true,
        allowMultiple: true,
        limit: 5,
      );
      final Object encoded = a.encode();
      final MediaSelectionOptions decoded = MediaSelectionOptions.decode(encoded);

      expect(a, decoded);
    });

    test('SourceSpecification equality and hashCode', () {
      final SourceSpecification a = SourceSpecification(
        type: SourceType.camera,
        camera: SourceCamera.front,
      );
      final SourceSpecification b = SourceSpecification(
        type: SourceType.camera,
        camera: SourceCamera.front,
      );
      final SourceSpecification c = SourceSpecification(
        type: SourceType.gallery,
        camera: SourceCamera.front,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('SourceSpecification encode and decode', () {
      final SourceSpecification a = SourceSpecification(
        type: SourceType.camera,
        camera: SourceCamera.front,
      );
      final Object encoded = a.encode();
      final SourceSpecification decoded = SourceSpecification.decode(encoded);

      expect(a, decoded);
    });

    test('SourceType and SourceCamera cover all values', () {
      // This helps hit the coverage for enum values
      expect(SourceType.values.length, 2);
      expect(SourceType.camera.index, 0);
      expect(SourceType.gallery.index, 1);

      expect(SourceCamera.values.length, 2);
      expect(SourceCamera.rear.index, 0);
      expect(SourceCamera.front.index, 1);
    });
  });

  group('Pigeon utility functions', () {
    test('ImagePickerApi handles reply list length > 1 (Platform Error)', () async {
      final ImagePickerApi api = ImagePickerApi();
      const String channelName = 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickImage';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(channelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>['error_code', 'error_message', 'error_details'],
      );
      expect(
        () => api.pickImage(
          SourceSpecification(type: SourceType.camera, camera: SourceCamera.rear),
          MaxSize(width: 10, height: 10),
          70,
          true,
        ),
        throwsA(isA<PlatformException>()
            .having((PlatformException e) => e.code, 'code', 'error_code')
            .having((PlatformException e) => e.message, 'message', 'error_message')),
      );
    });

    test('ImagePickerApi handles reply list [null] when isNullValid is false', () async {
      final ImagePickerApi api = ImagePickerApi();
      const String multiChannelName = 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickMultiImage';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(multiChannelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>[null],
      );
      expect(
        () => api.pickMultiImage(MaxSize(width: 10, height: 10), 70, true, null),
        throwsA(isA<PlatformException>().having((PlatformException e) => e.code, 'code', 'null-error')),
      );
    });

    test('_deepEquals covers various cases', () {
      final ImagePickerIOS picker = ImagePickerIOS();
      // We can't access _deepEquals directly as it is private in messages.g.dart.
      // But we can test it via MaxSize.operator == which uses it.

      final MaxSize size1 = MaxSize(width: 100, height: 200);
      // ignore: ComparisonWithNonFunctionalType
      expect(size1 == 'not a size', isFalse);

      final MaxSize size2 = MaxSize(width: 100, height: 200);
      expect(size1 == size2, isTrue);

      final MaxSize size3 = MaxSize(width: 100.1, height: 200);
      final MaxSize size4 = MaxSize(width: 100.1, height: 200);
      expect(size3 == size4, isTrue);
    });
  });

  group('ImagePickerApi messages', () {
    late ImagePickerApi api;
    const String channelName = 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickImage';

    setUp(() {
      api = ImagePickerApi();
    });

    test('pickImage handles success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(channelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>['/foo.png'],
      );
      final String? path = await api.pickImage(
        SourceSpecification(type: SourceType.camera, camera: SourceCamera.rear),
        MaxSize(width: 10, height: 10),
        70,
        true,
      );
      expect(path, '/foo.png');
    });

    test('pickImage handles null response', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(channelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>[null],
      );
      final String? path = await api.pickImage(
        SourceSpecification(type: SourceType.camera, camera: SourceCamera.rear),
        MaxSize(width: 10, height: 10),
        70,
        true,
      );
      expect(path, isNull);
    });

    test('pickImage handles channel error (null reply)', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(channelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => null,
      );
      expect(
        () => api.pickImage(
          SourceSpecification(type: SourceType.camera, camera: SourceCamera.rear),
          MaxSize(width: 10, height: 10),
          70,
          true,
        ),
        throwsA(isA<PlatformException>().having((PlatformException e) => e.code, 'code', 'channel-error')),
      );
    });

    test('pickImage handles platform error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(channelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>['error_code', 'error_message', 'error_details'],
      );
      expect(
        () => api.pickImage(
          SourceSpecification(type: SourceType.camera, camera: SourceCamera.rear),
          MaxSize(width: 10, height: 10),
          70,
          true,
        ),
        throwsA(isA<PlatformException>()
            .having((PlatformException e) => e.code, 'code', 'error_code')
            .having((PlatformException e) => e.message, 'message', 'error_message')
            .having((PlatformException e) => e.details, 'details', 'error_details')),
      );
    });

    test('pickMultiImage handles null return error', () async {
      const String multiChannelName = 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickMultiImage';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(multiChannelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>[null],
      );
      expect(
        () => api.pickMultiImage(MaxSize(width: 10, height: 10), 70, true, null),
        throwsA(isA<PlatformException>().having((PlatformException e) => e.code, 'code', 'null-error')),
      );
    });

    test('ImagePickerApi handles reply list too long', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(channelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>['error', 'message', 'details', 'extra'],
      );
      expect(
        () => api.pickImage(
          SourceSpecification(type: SourceType.camera, camera: SourceCamera.rear),
          MaxSize(width: 10, height: 10),
          70,
          true,
        ),
        throwsA(isA<PlatformException>()),
      );
    });

    test('ImagePickerApi with suffix', () async {
      final ImagePickerApi apiWithSuffix = ImagePickerApi(messageChannelSuffix: 'suffix');
      const String channelNameWithSuffix = 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickImage.suffix';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(channelNameWithSuffix, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>['/foo.png'],
      );

      final String? path = await apiWithSuffix.pickImage(
        SourceSpecification(type: SourceType.camera, camera: SourceCamera.rear),
        MaxSize(width: 10, height: 10),
        70,
        true,
      );
      expect(path, '/foo.png');
    });

    test('pickMultiImage success', () async {
      const String multiChannelName = 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickMultiImage';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(multiChannelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>[<String>['/foo.png', '/bar.png']],
      );
      final List<String> paths = await api.pickMultiImage(MaxSize(width: 10, height: 10), 70, true, null);
      expect(paths, <String>['/foo.png', '/bar.png']);
    });

    test('pickVideo success', () async {
      const String videoChannelName = 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickVideo';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(videoChannelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>['/foo.mp4'],
      );
      final String? path = await api.pickVideo(
        SourceSpecification(type: SourceType.camera, camera: SourceCamera.rear),
        60,
      );
      expect(path, '/foo.mp4');
    });

    test('pickMultiVideo success', () async {
      const String multiVideoChannelName = 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickMultiVideo';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(multiVideoChannelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>[<String>['/foo.mp4', '/bar.mp4']],
      );
      final List<String> paths = await api.pickMultiVideo(60, null);
      expect(paths, <String>['/foo.mp4', '/bar.mp4']);
    });

    test('pickMedia success', () async {
      const String mediaChannelName = 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickMedia';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
        BasicMessageChannel<Object?>(mediaChannelName, ImagePickerApi.pigeonChannelCodec),
        (Object? message) async => <Object?>[<String>['/foo.png', '/bar.mp4']],
      );
      final List<String> paths = await api.pickMedia(
        MediaSelectionOptions(
          maxSize: MaxSize(width: 10, height: 10),
          imageQuality: 70,
          requestFullMetadata: true,
          allowMultiple: true,
        ),
      );
      expect(paths, <String>['/foo.png', '/bar.mp4']);
    });

    test('ImagePickerApi with custom binary messenger', () async {
      final _FakeBinaryMessenger messenger = _FakeBinaryMessenger();
      final ImagePickerApi apiWithMessenger = ImagePickerApi(binaryMessenger: messenger);

      await apiWithMessenger.pickImage(
        SourceSpecification(type: SourceType.camera, camera: SourceCamera.rear),
        MaxSize(width: 10, height: 10),
        70,
        true,
      );

      expect(messenger.lastChannel, 'dev.flutter.pigeon.image_picker_ios.ImagePickerApi.pickImage');
    });
  });

  group('Pigeon Codec', () {
    test('codec can handle all types', () {
      const MessageCodec<Object?> codec = ImagePickerApi.pigeonChannelCodec;

      final ByteData? encodedInt = codec.encodeMessage(123);
      expect(codec.decodeMessage(encodedInt), 123);

      final ByteData? encodedCamera = codec.encodeMessage(SourceCamera.front);
      expect(codec.decodeMessage(encodedCamera), SourceCamera.front);

      final ByteData? encodedType = codec.encodeMessage(SourceType.gallery);
      expect(codec.decodeMessage(encodedType), SourceType.gallery);

      final MaxSize size = MaxSize(width: 1.1, height: 2.2);
      final ByteData? encodedSize = codec.encodeMessage(size);
      expect(codec.decodeMessage(encodedSize), size);

      final MediaSelectionOptions options = MediaSelectionOptions(
        maxSize: size,
        imageQuality: 70,
        requestFullMetadata: true,
        allowMultiple: true,
        limit: 5,
      );
      final ByteData? encodedOptions = codec.encodeMessage(options);
      expect(codec.decodeMessage(encodedOptions), options);

      final SourceSpecification source = SourceSpecification(
        type: SourceType.camera,
        camera: SourceCamera.rear,
      );
      final ByteData? encodedSource = codec.encodeMessage(source);
      expect(codec.decodeMessage(encodedSource), source);
    });
  });
}

enum _SelectionType { image, multiImage, media, video, multiVideo }

class _FakeBinaryMessenger extends BinaryMessenger {
  String? lastChannel;
  @override
  Future<ByteData?> send(String channel, ByteData? message) async {
    lastChannel = channel;
    return ImagePickerApi.pigeonChannelCodec.encodeMessage(<Object?>['/foo.png']);
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {}

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) async {}
}

class _FakeImagePickerApi implements ImagePickerApi {
  // The value to return from calls.
  List<String> returnValue = <String>[];

  _SelectionType? passedSelectionType;

  // Passed arguments.
  SourceSpecification? passedSource;
  MaxSize? passedMaxSize;
  int? passedImageQuality;
  bool? passedRequestFullMetadata;
  int? passedLimit;
  MediaSelectionOptions? passedMediaSelectionOptions;
  int? passedMaxDurationSeconds;

  @override
  Future<String?> pickImage(
    SourceSpecification source,
    MaxSize maxSize,
    int? imageQuality,
    bool requestFullMetadata,
  ) async {
    passedSelectionType = _SelectionType.image;
    passedSource = source;
    passedMaxSize = maxSize;
    passedImageQuality = imageQuality;
    passedRequestFullMetadata = requestFullMetadata;
    return returnValue.isEmpty ? null : returnValue.first;
  }

  @override
  Future<List<String>> pickMultiImage(
    MaxSize maxSize,
    int? imageQuality,
    bool requestFullMetadata,
    int? limit,
  ) async {
    passedSelectionType = _SelectionType.multiImage;
    passedMaxSize = maxSize;
    passedImageQuality = imageQuality;
    passedRequestFullMetadata = requestFullMetadata;
    passedLimit = limit;
    return returnValue;
  }

  @override
  Future<List<String>> pickMedia(
    MediaSelectionOptions mediaSelectionOptions,
  ) async {
    passedSelectionType = _SelectionType.media;
    passedMediaSelectionOptions = mediaSelectionOptions;
    return returnValue;
  }

  @override
  Future<String?> pickVideo(
    SourceSpecification source,
    int? maxDurationSeconds,
  ) async {
    passedSelectionType = _SelectionType.video;
    passedSource = source;
    passedMaxDurationSeconds = maxDurationSeconds;
    return returnValue.isEmpty ? null : returnValue.first;
  }

  @override
  Future<List<String>> pickMultiVideo(
    int? maxDurationSeconds,
    int? limit,
  ) async {
    passedSelectionType = _SelectionType.multiVideo;
    passedMaxDurationSeconds = maxDurationSeconds;
    passedLimit = limit;
    return returnValue;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
