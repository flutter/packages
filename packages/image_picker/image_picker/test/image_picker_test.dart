// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'image_picker_test.mocks.dart' as base_mock;

// Add the mixin to make the platform interface accept the mock.
class _MockImagePickerPlatform extends base_mock.MockImagePickerPlatform
    with MockPlatformInterfaceMixin {}

@GenerateMocks(<Type>[],
    customMocks: <MockSpec<dynamic>>[MockSpec<ImagePickerPlatform>()])
void main() {
  group('ImagePicker', () {
    late _MockImagePickerPlatform mockPlatform;

    setUp(() {
      mockPlatform = _MockImagePickerPlatform();
      ImagePickerPlatform.instance = mockPlatform;
    });

    group('#Single image/video', () {
      group('#pickImage', () {
        setUp(() {
          when(mockPlatform.getImageFromSource(
                  source: anyNamed('source'), options: anyNamed('options')))
              .thenAnswer((Invocation _) async => null);
        });

        test('passes the image source argument correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickImage(source: ImageSource.camera);
          await picker.pickImage(source: ImageSource.gallery);

          verifyInOrder(<Object>[
            mockPlatform.getImageFromSource(
              source: ImageSource.camera,
              options: argThat(
                isInstanceOf<ImagePickerOptions>(),
                named: 'options',
              ),
            ),
            mockPlatform.getImageFromSource(
              source: ImageSource.gallery,
              options: argThat(
                isInstanceOf<ImagePickerOptions>(),
                named: 'options',
              ),
            ),
          ]);
        });

        test('passes the width and height arguments correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickImage(source: ImageSource.camera);
          await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 10.0,
          );
          await picker.pickImage(
            source: ImageSource.camera,
            maxHeight: 10.0,
          );
          await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 10.0,
            maxHeight: 20.0,
          );
          await picker.pickImage(
              source: ImageSource.camera, maxWidth: 10.0, imageQuality: 70);
          await picker.pickImage(
              source: ImageSource.camera, maxHeight: 10.0, imageQuality: 70);
          await picker.pickImage(
              source: ImageSource.camera,
              maxWidth: 10.0,
              maxHeight: 20.0,
              imageQuality: 70);

          verifyInOrder(<Object>[
            mockPlatform.getImageFromSource(
              source: ImageSource.camera,
              options: argThat(
                isInstanceOf<ImagePickerOptions>()
                    .having((ImagePickerOptions options) => options.maxWidth,
                        'maxWidth', isNull)
                    .having((ImagePickerOptions options) => options.maxHeight,
                        'maxHeight', isNull)
                    .having(
                        (ImagePickerOptions options) => options.imageQuality,
                        'imageQuality',
                        isNull),
                named: 'options',
              ),
            ),
            mockPlatform.getImageFromSource(
              source: ImageSource.camera,
              options: argThat(
                isInstanceOf<ImagePickerOptions>()
                    .having((ImagePickerOptions options) => options.maxWidth,
                        'maxWidth', equals(10.0))
                    .having((ImagePickerOptions options) => options.maxHeight,
                        'maxHeight', isNull)
                    .having(
                        (ImagePickerOptions options) => options.imageQuality,
                        'imageQuality',
                        isNull),
                named: 'options',
              ),
            ),
            mockPlatform.getImageFromSource(
              source: ImageSource.camera,
              options: argThat(
                isInstanceOf<ImagePickerOptions>()
                    .having((ImagePickerOptions options) => options.maxWidth,
                        'maxWidth', isNull)
                    .having((ImagePickerOptions options) => options.maxHeight,
                        'maxHeight', equals(10.0))
                    .having(
                        (ImagePickerOptions options) => options.imageQuality,
                        'imageQuality',
                        isNull),
                named: 'options',
              ),
            ),
            mockPlatform.getImageFromSource(
              source: ImageSource.camera,
              options: argThat(
                isInstanceOf<ImagePickerOptions>()
                    .having((ImagePickerOptions options) => options.maxWidth,
                        'maxWidth', equals(10.0))
                    .having((ImagePickerOptions options) => options.maxHeight,
                        'maxHeight', equals(20.0))
                    .having(
                        (ImagePickerOptions options) => options.imageQuality,
                        'imageQuality',
                        isNull),
                named: 'options',
              ),
            ),
            mockPlatform.getImageFromSource(
              source: ImageSource.camera,
              options: argThat(
                isInstanceOf<ImagePickerOptions>()
                    .having((ImagePickerOptions options) => options.maxWidth,
                        'maxWidth', equals(10.0))
                    .having((ImagePickerOptions options) => options.maxHeight,
                        'maxHeight', isNull)
                    .having(
                        (ImagePickerOptions options) => options.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getImageFromSource(
              source: ImageSource.camera,
              options: argThat(
                isInstanceOf<ImagePickerOptions>()
                    .having((ImagePickerOptions options) => options.maxWidth,
                        'maxWidth', isNull)
                    .having((ImagePickerOptions options) => options.maxHeight,
                        'maxHeight', equals(10.0))
                    .having(
                        (ImagePickerOptions options) => options.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getImageFromSource(
              source: ImageSource.camera,
              options: argThat(
                isInstanceOf<ImagePickerOptions>()
                    .having((ImagePickerOptions options) => options.maxWidth,
                        'maxWidth', equals(10.0))
                    .having((ImagePickerOptions options) => options.maxHeight,
                        'maxHeight', equals(20.0))
                    .having(
                        (ImagePickerOptions options) => options.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
          ]);
        });

        test('does not accept a negative width or height argument', () {
          final ImagePicker picker = ImagePicker();
          expect(
            () => picker.pickImage(source: ImageSource.camera, maxWidth: -1.0),
            throwsArgumentError,
          );

          expect(
            () => picker.pickImage(source: ImageSource.camera, maxHeight: -1.0),
            throwsArgumentError,
          );
        });

        test('handles a null image file response gracefully', () async {
          final ImagePicker picker = ImagePicker();

          expect(await picker.pickImage(source: ImageSource.gallery), isNull);
          expect(await picker.pickImage(source: ImageSource.camera), isNull);
        });

        test('camera position defaults to back', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickImage(source: ImageSource.camera);

          verify(mockPlatform.getImageFromSource(
            source: ImageSource.camera,
            options: argThat(
              isInstanceOf<ImagePickerOptions>().having(
                  (ImagePickerOptions options) => options.preferredCameraDevice,
                  'preferredCameraDevice',
                  equals(CameraDevice.rear)),
              named: 'options',
            ),
          ));
        });

        test('camera position can set to front', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickImage(
              source: ImageSource.camera,
              preferredCameraDevice: CameraDevice.front);

          verify(mockPlatform.getImageFromSource(
            source: ImageSource.camera,
            options: argThat(
              isInstanceOf<ImagePickerOptions>().having(
                  (ImagePickerOptions options) => options.preferredCameraDevice,
                  'preferredCameraDevice',
                  equals(CameraDevice.front)),
              named: 'options',
            ),
          ));
        });

        test('full metadata argument defaults to true', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickImage(source: ImageSource.gallery);

          verify(mockPlatform.getImageFromSource(
            source: ImageSource.gallery,
            options: argThat(
              isInstanceOf<ImagePickerOptions>().having(
                  (ImagePickerOptions options) => options.requestFullMetadata,
                  'requestFullMetadata',
                  isTrue),
              named: 'options',
            ),
          ));
        });

        test('passes the full metadata argument correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickImage(
            source: ImageSource.gallery,
            requestFullMetadata: false,
          );

          verify(mockPlatform.getImageFromSource(
            source: ImageSource.gallery,
            options: argThat(
              isInstanceOf<ImagePickerOptions>().having(
                  (ImagePickerOptions options) => options.requestFullMetadata,
                  'requestFullMetadata',
                  isFalse),
              named: 'options',
            ),
          ));
        });
      });

      group('#pickVideo', () {
        setUp(() {
          when(mockPlatform.getVideo(
                  source: anyNamed('source'),
                  preferredCameraDevice: anyNamed('preferredCameraDevice'),
                  maxDuration: anyNamed('maxDuration')))
              .thenAnswer((Invocation _) async => null);
        });

        test('passes the image source argument correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickVideo(source: ImageSource.camera);
          await picker.pickVideo(source: ImageSource.gallery);

          verifyInOrder(<Object>[
            mockPlatform.getVideo(source: ImageSource.camera),
            mockPlatform.getVideo(source: ImageSource.gallery),
          ]);
        });

        test('passes the duration argument correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickVideo(source: ImageSource.camera);
          await picker.pickVideo(
              source: ImageSource.camera,
              maxDuration: const Duration(seconds: 10));

          verifyInOrder(<Object>[
            mockPlatform.getVideo(source: ImageSource.camera),
            mockPlatform.getVideo(
                source: ImageSource.camera,
                maxDuration: const Duration(seconds: 10)),
          ]);
        });

        test('handles a null video file response gracefully', () async {
          final ImagePicker picker = ImagePicker();

          expect(await picker.pickVideo(source: ImageSource.gallery), isNull);
          expect(await picker.pickVideo(source: ImageSource.camera), isNull);
        });

        test('camera position defaults to back', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickVideo(source: ImageSource.camera);

          verify(mockPlatform.getVideo(source: ImageSource.camera));
        });

        test('camera position can set to front', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickVideo(
              source: ImageSource.camera,
              preferredCameraDevice: CameraDevice.front);

          verify(mockPlatform.getVideo(
              source: ImageSource.camera,
              preferredCameraDevice: CameraDevice.front));
        });
      });

      group('#retrieveLostData', () {
        test('retrieveLostData get success response', () async {
          final ImagePicker picker = ImagePicker();
          final XFile lostFile = XFile('/example/path');
          when(mockPlatform.getLostData()).thenAnswer((Invocation _) async =>
              LostDataResponse(
                  file: lostFile,
                  files: <XFile>[lostFile],
                  type: RetrieveType.image));

          final LostDataResponse response = await picker.retrieveLostData();

          expect(response.type, RetrieveType.image);
          expect(response.file!.path, '/example/path');
        });

        test('retrieveLostData should successfully retrieve multiple files',
            () async {
          final ImagePicker picker = ImagePicker();
          final List<XFile> lostFiles = <XFile>[
            XFile('/example/path0'),
            XFile('/example/path1'),
          ];
          when(mockPlatform.getLostData()).thenAnswer((Invocation _) async =>
              LostDataResponse(
                  file: lostFiles.last,
                  files: lostFiles,
                  type: RetrieveType.image));

          final LostDataResponse response = await picker.retrieveLostData();

          expect(response.type, RetrieveType.image);
          expect(response.file, isNotNull);
          expect(response.file!.path, '/example/path1');
          expect(response.files!.first.path, '/example/path0');
          expect(response.files!.length, 2);
        });

        test('retrieveLostData get error response', () async {
          final ImagePicker picker = ImagePicker();
          when(mockPlatform.getLostData()).thenAnswer((Invocation _) async =>
              LostDataResponse(
                  exception: PlatformException(
                      code: 'test_error_code', message: 'test_error_message'),
                  type: RetrieveType.video));

          final LostDataResponse response = await picker.retrieveLostData();

          expect(response.type, RetrieveType.video);
          expect(response.exception!.code, 'test_error_code');
          expect(response.exception!.message, 'test_error_message');
        });
      });
    });

    group('#Multi images', () {
      setUp(() {
        when(
          mockPlatform.getMultiImageWithOptions(
            options: anyNamed('options'),
          ),
        ).thenAnswer((Invocation _) async => <XFile>[]);
      });

      group('#pickMultiImage', () {
        test('passes the width and height arguments correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickMultiImage();
          await picker.pickMultiImage(
            maxWidth: 10.0,
          );
          await picker.pickMultiImage(
            maxHeight: 10.0,
          );
          await picker.pickMultiImage(
            maxWidth: 10.0,
            maxHeight: 20.0,
          );
          await picker.pickMultiImage(
            maxWidth: 10.0,
            imageQuality: 70,
          );
          await picker.pickMultiImage(
            maxHeight: 10.0,
            imageQuality: 70,
          );
          await picker.pickMultiImage(
            maxWidth: 10.0,
            maxHeight: 20.0,
            imageQuality: 70,
          );
          await picker.pickMultiImage(
            maxWidth: 10.0,
            maxHeight: 20.0,
            imageQuality: 70,
            limit: 5,
          );

          verifyInOrder(<Object>[
            mockPlatform.getMultiImageWithOptions(
              options: argThat(
                isInstanceOf<MultiImagePickerOptions>(),
                named: 'options',
              ),
            ),
            mockPlatform.getMultiImageWithOptions(
              options: argThat(
                isInstanceOf<MultiImagePickerOptions>().having(
                    (MultiImagePickerOptions options) =>
                        options.imageOptions.maxWidth,
                    'maxWidth',
                    equals(10.0)),
                named: 'options',
              ),
            ),
            mockPlatform.getMultiImageWithOptions(
              options: argThat(
                isInstanceOf<MultiImagePickerOptions>().having(
                    (MultiImagePickerOptions options) =>
                        options.imageOptions.maxHeight,
                    'maxHeight',
                    equals(10.0)),
                named: 'options',
              ),
            ),
            mockPlatform.getMultiImageWithOptions(
              options: argThat(
                isInstanceOf<MultiImagePickerOptions>()
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.maxHeight,
                        'maxHeight',
                        equals(20.0)),
                named: 'options',
              ),
            ),
            mockPlatform.getMultiImageWithOptions(
              options: argThat(
                isInstanceOf<MultiImagePickerOptions>()
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getMultiImageWithOptions(
              options: argThat(
                isInstanceOf<MultiImagePickerOptions>()
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.maxHeight,
                        'maxHeight',
                        equals(10.0))
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getMultiImageWithOptions(
              options: argThat(
                isInstanceOf<MultiImagePickerOptions>()
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.maxWidth,
                        'maxHeight',
                        equals(10.0))
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getMultiImageWithOptions(
              options: argThat(
                isInstanceOf<MultiImagePickerOptions>()
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.maxWidth,
                        'maxHeight',
                        equals(10.0))
                    .having(
                        (MultiImagePickerOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70))
                    .having((MultiImagePickerOptions options) => options.limit,
                        'limit', equals(5)),
                named: 'options',
              ),
            ),
          ]);
        });

        test('does not accept a negative width or height argument', () {
          final ImagePicker picker = ImagePicker();
          expect(
            () => picker.pickMultiImage(maxWidth: -1.0),
            throwsArgumentError,
          );

          expect(
            () => picker.pickMultiImage(maxHeight: -1.0),
            throwsArgumentError,
          );
        });

        test('does not accept a limit argument lower than 2', () {
          final ImagePicker picker = ImagePicker();
          expect(
            () => picker.pickMultiImage(limit: -1),
            throwsArgumentError,
          );

          expect(
            () => picker.pickMultiImage(limit: 0),
            throwsArgumentError,
          );

          expect(
            () => picker.pickMultiImage(limit: 1),
            throwsArgumentError,
          );
        });

        test('handles an empty image file response gracefully', () async {
          final ImagePicker picker = ImagePicker();

          expect(await picker.pickMultiImage(), isEmpty);
          expect(await picker.pickMultiImage(), isEmpty);
        });

        test('full metadata argument defaults to true', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickMultiImage();

          verify(mockPlatform.getMultiImageWithOptions(
            options: argThat(
              isInstanceOf<MultiImagePickerOptions>().having(
                  (MultiImagePickerOptions options) =>
                      options.imageOptions.requestFullMetadata,
                  'requestFullMetadata',
                  isTrue),
              named: 'options',
            ),
          ));
        });

        test('passes the full metadata argument correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickMultiImage(
            requestFullMetadata: false,
          );

          verify(mockPlatform.getMultiImageWithOptions(
            options: argThat(
              isInstanceOf<MultiImagePickerOptions>().having(
                  (MultiImagePickerOptions options) =>
                      options.imageOptions.requestFullMetadata,
                  'requestFullMetadata',
                  isFalse),
              named: 'options',
            ),
          ));
        });
      });
    });

    group('#Media', () {
      setUp(() {
        when(
          mockPlatform.getMedia(
            options: anyNamed('options'),
          ),
        ).thenAnswer((Invocation _) async => <XFile>[]);
      });

      group('#pickMedia', () {
        test('passes the width and height arguments correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickMedia();
          await picker.pickMedia(
            maxWidth: 10.0,
          );
          await picker.pickMedia(
            maxHeight: 10.0,
          );
          await picker.pickMedia(
            maxWidth: 10.0,
            maxHeight: 20.0,
          );
          await picker.pickMedia(
            maxWidth: 10.0,
            imageQuality: 70,
          );
          await picker.pickMedia(
            maxHeight: 10.0,
            imageQuality: 70,
          );
          await picker.pickMedia(
            maxWidth: 10.0,
            maxHeight: 20.0,
            imageQuality: 70,
          );
          await picker.pickMedia(
            maxWidth: 10.0,
            maxHeight: 20.0,
            imageQuality: 70,
          );

          verifyInOrder(<Object>[
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>(),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>().having(
                    (MediaOptions options) => options.imageOptions.maxWidth,
                    'maxWidth',
                    equals(10.0)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>().having(
                    (MediaOptions options) => options.imageOptions.maxHeight,
                    'maxHeight',
                    equals(10.0)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>()
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.maxHeight,
                        'maxHeight',
                        equals(20.0)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>()
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>()
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.maxHeight,
                        'maxHeight',
                        equals(10.0))
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>()
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxHeight',
                        equals(10.0))
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
          ]);
        });

        test('does not accept a negative width or height argument', () {
          final ImagePicker picker = ImagePicker();
          expect(
            () => picker.pickMedia(maxWidth: -1.0),
            throwsArgumentError,
          );

          expect(
            () => picker.pickMedia(maxHeight: -1.0),
            throwsArgumentError,
          );
        });

        test('handles an empty image file response gracefully', () async {
          final ImagePicker picker = ImagePicker();

          expect(await picker.pickMedia(), isNull);
          expect(await picker.pickMedia(), isNull);
        });

        test('full metadata argument defaults to true', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickMedia();

          verify(mockPlatform.getMedia(
            options: argThat(
              isInstanceOf<MediaOptions>().having(
                  (MediaOptions options) =>
                      options.imageOptions.requestFullMetadata,
                  'requestFullMetadata',
                  isTrue),
              named: 'options',
            ),
          ));
        });

        test('passes the full metadata argument correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickMedia(
            requestFullMetadata: false,
          );

          verify(mockPlatform.getMedia(
            options: argThat(
              isInstanceOf<MediaOptions>().having(
                  (MediaOptions options) =>
                      options.imageOptions.requestFullMetadata,
                  'requestFullMetadata',
                  isFalse),
              named: 'options',
            ),
          ));
        });
      });

      group('#pickMultipleMedia', () {
        test('passes the width and height arguments correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickMultipleMedia();
          await picker.pickMultipleMedia(
            maxWidth: 10.0,
          );
          await picker.pickMultipleMedia(
            maxHeight: 10.0,
          );
          await picker.pickMultipleMedia(
            maxWidth: 10.0,
            maxHeight: 20.0,
          );
          await picker.pickMultipleMedia(
            maxWidth: 10.0,
            imageQuality: 70,
          );
          await picker.pickMultipleMedia(
            maxHeight: 10.0,
            imageQuality: 70,
          );
          await picker.pickMultipleMedia(
            maxWidth: 10.0,
            maxHeight: 20.0,
            imageQuality: 70,
          );
          await picker.pickMultipleMedia(
            maxWidth: 10.0,
            maxHeight: 20.0,
            imageQuality: 70,
            limit: 5,
          );

          verifyInOrder(<Object>[
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>(),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>().having(
                    (MediaOptions options) => options.imageOptions.maxWidth,
                    'maxWidth',
                    equals(10.0)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>().having(
                    (MediaOptions options) => options.imageOptions.maxHeight,
                    'maxHeight',
                    equals(10.0)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>()
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.maxHeight,
                        'maxHeight',
                        equals(20.0)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>()
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>()
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.maxHeight,
                        'maxHeight',
                        equals(10.0))
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>()
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxHeight',
                        equals(10.0))
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70)),
                named: 'options',
              ),
            ),
            mockPlatform.getMedia(
              options: argThat(
                isInstanceOf<MediaOptions>()
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxWidth',
                        equals(10.0))
                    .having(
                        (MediaOptions options) => options.imageOptions.maxWidth,
                        'maxHeight',
                        equals(10.0))
                    .having(
                        (MediaOptions options) =>
                            options.imageOptions.imageQuality,
                        'imageQuality',
                        equals(70))
                    .having((MediaOptions options) => options.limit, 'limit',
                        equals(5)),
                named: 'options',
              ),
            ),
          ]);
        });

        test('does not accept a negative width or height argument', () {
          final ImagePicker picker = ImagePicker();
          expect(
            () => picker.pickMultipleMedia(maxWidth: -1.0),
            throwsArgumentError,
          );

          expect(
            () => picker.pickMultipleMedia(maxHeight: -1.0),
            throwsArgumentError,
          );
        });

        test('does not accept a limit argument lower than 2', () {
          final ImagePicker picker = ImagePicker();
          expect(
            () => picker.pickMultipleMedia(limit: -1),
            throwsArgumentError,
          );

          expect(
            () => picker.pickMultipleMedia(limit: 0),
            throwsArgumentError,
          );

          expect(
            () => picker.pickMultipleMedia(limit: 1),
            throwsArgumentError,
          );
        });

        test('handles an empty image file response gracefully', () async {
          final ImagePicker picker = ImagePicker();

          expect(await picker.pickMultipleMedia(), isEmpty);
          expect(await picker.pickMultipleMedia(), isEmpty);
        });

        test('full metadata argument defaults to true', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickMultipleMedia();

          verify(mockPlatform.getMedia(
            options: argThat(
              isInstanceOf<MediaOptions>().having(
                  (MediaOptions options) =>
                      options.imageOptions.requestFullMetadata,
                  'requestFullMetadata',
                  isTrue),
              named: 'options',
            ),
          ));
        });

        test('passes the full metadata argument correctly', () async {
          final ImagePicker picker = ImagePicker();
          await picker.pickMultipleMedia(
            requestFullMetadata: false,
          );

          verify(mockPlatform.getMedia(
            options: argThat(
              isInstanceOf<MediaOptions>().having(
                  (MediaOptions options) =>
                      options.imageOptions.requestFullMetadata,
                  'requestFullMetadata',
                  isFalse),
              named: 'options',
            ),
          ));
        });
      });
      test('supportsImageSource calls through to platform', () async {
        final ImagePicker picker = ImagePicker();
        when(mockPlatform.supportsImageSource(any)).thenReturn(true);

        final bool supported = picker.supportsImageSource(ImageSource.camera);

        expect(supported, true);
        verify(mockPlatform.supportsImageSource(ImageSource.camera));
      });
    });
  });
}
