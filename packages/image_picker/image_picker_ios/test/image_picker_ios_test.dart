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
}

enum _SelectionType { image, multiImage, media, video, multiVideo }

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
    return returnValue.firstOrNull;
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
    return returnValue.firstOrNull;
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
