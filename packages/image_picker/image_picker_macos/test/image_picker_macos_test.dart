// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_macos/image_picker_macos.dart';
import 'package:image_picker_macos/src/messages.g.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'image_picker_macos_test.mocks.dart';
import 'test_api.g.dart';

@GenerateMocks(<Type>[FileSelectorPlatform, TestHostImagePickerApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Returns the captured type groups from a mock call result, assuming that
  // exactly one call was made and only the type groups were captured.
  List<XTypeGroup> capturedTypeGroups(VerificationResult result) {
    return result.captured.single as List<XTypeGroup>;
  }

  late ImagePickerMacOS plugin;
  late MockFileSelectorPlatform mockFileSelectorPlatform;
  late MockTestHostImagePickerApi mockImagePickerApi;

  setUp(() {
    plugin = ImagePickerMacOS();
    mockFileSelectorPlatform = MockFileSelectorPlatform();
    mockImagePickerApi = MockTestHostImagePickerApi();

    when(mockFileSelectorPlatform.openFile(
            acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
        .thenAnswer((_) async => null);

    when(mockFileSelectorPlatform.openFiles(
            acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
        .thenAnswer((_) async => List<XFile>.empty());

    when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => false);

    when(mockImagePickerApi.pickImages(any, any)).thenAnswer(
        (_) async => ImagePickerSuccessResult(filePaths: <String>[]));

    when(mockImagePickerApi.pickVideos(any)).thenAnswer(
        (_) async => ImagePickerSuccessResult(filePaths: <String>[]));

    when(mockImagePickerApi.pickMedia(any, any)).thenAnswer(
        (_) async => ImagePickerSuccessResult(filePaths: <String>[]));

    ImagePickerMacOS.fileSelector = mockFileSelectorPlatform;
    TestHostImagePickerApi.setUp(mockImagePickerApi);
  });

  setUpAll(() {
    // Mockito cannot generate a dummy value of type ImagePickerResult
    provideDummy<ImagePickerResult>(
        ImagePickerSuccessResult(filePaths: <String>[]));
  });

  void testWithPHPicker({
    required bool enabled,
    required void Function() body,
  }) {
    plugin.useMacOSPHPicker = enabled;
    when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => enabled);
    body();
  }

  test('registered instance', () {
    ImagePickerMacOS.registerWith();
    expect(ImagePickerPlatform.instance, isA<ImagePickerMacOS>());
  });

  test('defaults to not using macOS PHPicker', () async {
    expect(plugin.useMacOSPHPicker, false);
  });

  test(
    'supportsPHPicker delegate to the supportsPHPicker from the platform API',
    () async {
      when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => false);
      expect(await plugin.supportsPHPicker(), false);

      when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => true);
      expect(await plugin.supportsPHPicker(), true);
    },
  );

  test(
      'shouldUsePHPicker returns true when useMacOSPHPicker and supportsPHPicker are true',
      () async {
    plugin.useMacOSPHPicker = true;
    when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => true);
    expect(await plugin.shouldUsePHPicker(), true);
  });

  test(
      'shouldUsePHPPicker returns false when either useMacOSPHPicker or supportsPHPicker is false',
      () async {
    plugin.useMacOSPHPicker = false;
    when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => true);
    expect(await plugin.shouldUsePHPicker(), false);

    plugin.useMacOSPHPicker = true;
    when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => false);
    expect(await plugin.shouldUsePHPicker(), false);
  });

  test(
      'shouldUsePHPPicker returns false when both useMacOSPHPicker and supportsPHPicker are false',
      () async {
    plugin.useMacOSPHPicker = false;
    when(mockImagePickerApi.supportsPHPicker()).thenAnswer((_) => false);
    expect(await plugin.shouldUsePHPicker(), false);
  });

  group('images', () {
    test('pickImage passes the accepted type groups correctly', () async {
      await plugin.pickImage(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].uniformTypeIdentifiers,
          <String>['public.image']);
    });

    test('getImage passes the accepted type groups correctly', () async {
      await plugin.getImage(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].uniformTypeIdentifiers,
          <String>['public.image']);
    });

    test('getImageFromSource passes the accepted type groups correctly',
        () async {
      await plugin.getImageFromSource(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].uniformTypeIdentifiers,
          <String>['public.image']);
    });

    test('getImageFromSource calls delegate when source is camera', () async {
      Future<void> sharedTest() async {
        const String fakePath = '/tmp/foo';
        plugin.cameraDelegate = FakeCameraDelegate(result: XFile(fakePath));
        expect(
            (await plugin.getImageFromSource(source: ImageSource.camera))!.path,
            fakePath);
      }

      // Camera is unsupported on both PHPicker and file_selector,
      // ensure always to use the camera delegate
      testWithPHPicker(enabled: false, body: sharedTest);
      testWithPHPicker(enabled: true, body: sharedTest);
    });

    test(
        'getImageFromSource throws StateError when source is camera with no delegate',
        () async {
      Future<void> sharedTest() async {
        await expectLater(plugin.getImageFromSource(source: ImageSource.camera),
            throwsStateError);
      }

      // Camera is unsupported on both PHPicker and file_selector,
      // ensure always to throw state error
      testWithPHPicker(enabled: false, body: sharedTest);
      testWithPHPicker(enabled: true, body: sharedTest);
    });

    test(
      'getMultiImage delegate to getMultiImageWithOptions',
      () async {
        // The getMultiImage is soft-deprecated in the platform interface
        // and is only implemented for compatibility. Callers should be using getMultiImageWithOptions.
        await plugin.getMultiImage();
        verify(plugin.getMultiImageWithOptions()).called(1);
      },
    );

    test('getMultiImageWithOptions passes the accepted type groups correctly',
        () async {
      await plugin.getMultiImage();

      final VerificationResult result = verify(
          mockFileSelectorPlatform.openFiles(
              acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].uniformTypeIdentifiers,
          <String>['public.image']);
    });

    test(
      'getMultiImageWithOptions uses PHPicker when it is enabled',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getMultiImageWithOptions();
            verify(plugin.shouldUsePHPicker()).called(1);
            verify(mockImagePickerApi.pickImages(any, any)).called(1);

            verifyNever(mockFileSelectorPlatform.openFiles(
                acceptedTypeGroups: anyNamed('acceptedTypeGroups')));
          },
        );
      },
    );

    test(
      'getMultiImageWithOptions uses file selector when PHPicker is disabled',
      () async {
        testWithPHPicker(
          enabled: false,
          body: () async {
            await plugin.getMultiImageWithOptions();
            verify(plugin.shouldUsePHPicker()).called(1);
            verifyNever(mockImagePickerApi.pickImages(any, any));

            verify(mockFileSelectorPlatform.openFiles(
                    acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
                .called(1);
          },
        );
      },
    );

    test(
      'getMultiImageWithOptions pass 0 as limit to pickImages for PHPicker implementation when unspecified',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getMultiImageWithOptions(
              // ignore: avoid_redundant_argument_values
              options: const MultiImagePickerOptions(limit: null),
            );
            verify(mockImagePickerApi.pickImages(
              any,
              argThat(
                predicate<GeneralOptions>(
                    (GeneralOptions options) => options.limit == 0),
              ),
            ));
          },
        );
      },
    );

    test(
      'getImageFromSource uses PHPicker when it is enabled',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getImageFromSource(source: ImageSource.gallery);
            verify(plugin.shouldUsePHPicker()).called(1);
            verify(mockImagePickerApi.pickImages(any, any)).called(1);

            verifyNever(mockFileSelectorPlatform.openFile(
                acceptedTypeGroups: anyNamed('acceptedTypeGroups')));
          },
        );
      },
    );

    test(
      'getImageFromSource uses file selector when PHPicker is disabled',
      () async {
        testWithPHPicker(
          enabled: false,
          body: () async {
            await plugin.getImageFromSource(source: ImageSource.gallery);
            verify(plugin.shouldUsePHPicker()).called(1);
            verifyNever(mockImagePickerApi.pickImages(any, any));

            verify(mockFileSelectorPlatform.openFile(
                    acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
                .called(1);
          },
        );
      },
    );

    test(
      'getImageFromSource pass 1 as limit to pickImages for PHPicker implementation',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getImageFromSource(source: ImageSource.gallery);

            verify(mockImagePickerApi.pickImages(
              any,
              argThat(
                predicate<GeneralOptions>(
                    (GeneralOptions options) => options.limit == 1),
              ),
            )).called(1);
          },
        );
      },
    );

    test(
      'getImageFromSource uses 100 as image quality if not provided',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getImageFromSource(
              source: ImageSource.gallery,
              // ignore: avoid_redundant_argument_values
              options: const ImagePickerOptions(imageQuality: null),
            );

            verify(mockImagePickerApi.pickImages(
              argThat(
                predicate<ImageSelectionOptions>(
                    (ImageSelectionOptions options) => options.quality == 100),
              ),
              any,
            )).called(1);
          },
        );
      },
    );

    test(
      'getMultiImageWithOptions uses 100 as image quality if not provided',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getMultiImageWithOptions(
              // ignore: avoid_redundant_argument_values
              options: const MultiImagePickerOptions(
                // ignore: avoid_redundant_argument_values
                imageOptions: ImageOptions(imageQuality: null),
              ),
            );

            verify(mockImagePickerApi.pickImages(
              argThat(
                predicate<ImageSelectionOptions>(
                    (ImageSelectionOptions options) => options.quality == 100),
              ),
              any,
            )).called(1);
          },
        );
      },
    );

    test(
      'getImageFromSource return the file from the platform API for PHPicker implementation',
      () {
        testWithPHPicker(
          enabled: true,
          body: () async {
            final List<String> filePaths = <String>['path/to/file'];
            when(mockImagePickerApi.pickImages(
              any,
              any,
            )).thenAnswer((_) async {
              return ImagePickerSuccessResult(filePaths: filePaths);
            });
            expect(
              (await plugin.pickImage(source: ImageSource.gallery))?.path,
              filePaths.first,
            );
          },
        );
      },
    );

    test(
      'getMultiImageWithOptions return the file from the platform API for PHPicker implementation',
      () {
        testWithPHPicker(
          enabled: true,
          body: () async {
            final List<String> filePaths = <String>[
              '/foo/bar/image.png',
              '/dev/flutter/plugins/video.mp4',
              'path/to/file'
            ];
            when(mockImagePickerApi.pickImages(
              any,
              any,
            )).thenAnswer((_) async {
              return ImagePickerSuccessResult(filePaths: filePaths);
            });
            expect(
              (await plugin.getMultiImageWithOptions())
                  .map((XFile file) => file.path),
              filePaths,
            );
          },
        );
      },
    );

    test(
      'getImageFromSource passes the arguments correctly to the platform API for the PHPicker implementation',
      () {
        testWithPHPicker(
          enabled: true,
          body: () async {
            const ImagePickerOptions imageOptions = ImagePickerOptions(
              imageQuality: 50,
              maxHeight: 40,
              maxWidth: 30,
            );
            await plugin.getImageFromSource(
                source: ImageSource.gallery, options: imageOptions);
            verify(mockImagePickerApi.pickImages(
              argThat(predicate<ImageSelectionOptions>(
                (ImageSelectionOptions options) =>
                    options.maxSize?.width == imageOptions.maxWidth &&
                    options.maxSize?.height == imageOptions.maxHeight &&
                    options.quality == imageOptions.imageQuality,
              )),
              argThat(predicate<GeneralOptions>(
                (GeneralOptions options) => options.limit == 1,
              )),
            ));
          },
        );
      },
    );

    test(
      'getMultiImageWithOptions passes the arguments correctly to the platform API for the PHPicker implementation',
      () {
        testWithPHPicker(
          enabled: true,
          body: () async {
            const MultiImagePickerOptions multiImageOptions =
                MultiImagePickerOptions(
              imageOptions:
                  ImageOptions(imageQuality: 50, maxHeight: 40, maxWidth: 30),
              limit: 50,
            );
            await plugin.getMultiImageWithOptions(options: multiImageOptions);

            verify(mockImagePickerApi.pickImages(
              argThat(predicate<ImageSelectionOptions>(
                (ImageSelectionOptions options) =>
                    options.maxSize?.width ==
                        multiImageOptions.imageOptions.maxWidth &&
                    options.maxSize?.height ==
                        multiImageOptions.imageOptions.maxHeight &&
                    options.quality ==
                        multiImageOptions.imageOptions.imageQuality,
              )),
              argThat(predicate<GeneralOptions>(
                (GeneralOptions options) =>
                    options.limit == multiImageOptions.limit,
              )),
            ));
          },
        );
      },
    );

    void testThrowsPlatformExceptionForPHPicker({
      required String methodName,
      required Future<void> Function() underTest,
    }) =>
        test(
          '$methodName throws $PlatformException for PHPicker on platform API error',
          () {
            testWithPHPicker(
                enabled: true,
                body: () async {
                  for (final ImagePickerError error
                      in ImagePickerError.values) {
                    const String platformErrorMessage =
                        'Example Platform Error Message';
                    when(mockImagePickerApi.pickImages(any, any))
                        .thenAnswer((_) async => ImagePickerErrorResult(
                              error: error,
                              platformErrorMessage: platformErrorMessage,
                            ));
                    await expectLater(
                      () => underTest(),
                      throwsA(
                        isA<PlatformException>()
                            .having(
                              (PlatformException e) => e.code,
                              'code',
                              equals(error.name),
                            )
                            .having(
                              (PlatformException e) => e.details,
                              'details',
                              equals(platformErrorMessage),
                            ),
                      ),
                    );
                    verify(mockImagePickerApi.pickImages(any, any)).called(1);
                  }
                });
          },
        );

    testThrowsPlatformExceptionForPHPicker(
      methodName: 'getImageFromSource',
      underTest: () => plugin.getImageFromSource(source: ImageSource.gallery),
    );

    testThrowsPlatformExceptionForPHPicker(
      methodName: 'getMultiImageWithOptions',
      underTest: () => plugin.getMultiImageWithOptions(),
    );
  });

  group('videos', () {
    test('pickVideo delegate to getVideo', () async {
      // The pickVideo is soft-deprecated in the platform interface
      // and is only implemented for compatibility. Callers should be using getVideo.
      await plugin.pickVideo(source: ImageSource.gallery);
      verify(plugin.getVideo(source: ImageSource.gallery)).called(1);
    });

    test('getVideo passes the accepted type groups correctly', () async {
      await plugin.getVideo(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].uniformTypeIdentifiers,
          <String>['public.movie']);
    });

    test('getVideo passes the accepted type groups correctly', () async {
      await plugin.getVideo(source: ImageSource.gallery);

      final VerificationResult result = verify(mockFileSelectorPlatform
          .openFile(acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].uniformTypeIdentifiers,
          <String>['public.movie']);
    });

    test('getVideo calls delegate when source is camera', () async {
      Future<void> sharedTest() async {
        const String fakePath = '/tmp/foo';
        plugin.cameraDelegate = FakeCameraDelegate(result: XFile(fakePath));
        expect((await plugin.getVideo(source: ImageSource.camera))!.path,
            fakePath);
      }

      // Camera is unsupported on both PHPicker and file_selector,
      // ensure always to use the camera delegate
      testWithPHPicker(enabled: false, body: sharedTest);
      testWithPHPicker(enabled: true, body: sharedTest);
    });

    test('getVideo throws StateError when source is camera with no delegate',
        () async {
      Future<void> sharedTest() async {
        await expectLater(
            plugin.getVideo(source: ImageSource.camera), throwsStateError);
      }

      // Camera is unsupported on both PHPicker and file_selector,
      // ensure always to throw state error
      testWithPHPicker(enabled: false, body: sharedTest);
      testWithPHPicker(enabled: true, body: sharedTest);
    });

    test(
      'getVideo uses PHPicker when it is enabled',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getVideo(source: ImageSource.gallery);
            verify(plugin.shouldUsePHPicker()).called(1);
            verify(mockImagePickerApi.pickVideos(any)).called(1);

            verifyNever(mockFileSelectorPlatform.openFile(
                acceptedTypeGroups: anyNamed('acceptedTypeGroups')));
          },
        );
      },
    );

    test(
      'getVideo uses file selector when PHPicker is disabled',
      () async {
        testWithPHPicker(
          enabled: false,
          body: () async {
            await plugin.getVideo(source: ImageSource.gallery);
            verify(plugin.shouldUsePHPicker()).called(1);
            verifyNever(mockImagePickerApi.pickVideos(any));

            verify(mockFileSelectorPlatform.openFile(
                    acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
                .called(1);
          },
        );
      },
    );

    test(
      'getVideo pass 1 as limit to pickVideos for PHPicker implementation',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getVideo(source: ImageSource.gallery);

            verify(mockImagePickerApi.pickVideos(
              argThat(
                predicate<GeneralOptions>(
                    (GeneralOptions options) => options.limit == 1),
              ),
            )).called(1);
          },
        );
      },
    );

    test(
      'getVideo return the file from the platform API for PHPicker implementation',
      () {
        testWithPHPicker(
          enabled: true,
          body: () async {
            final List<String> filePaths = <String>['path/to/file'];
            when(mockImagePickerApi.pickVideos(
              any,
            )).thenAnswer((_) async {
              return ImagePickerSuccessResult(filePaths: filePaths);
            });
            expect(
              (await plugin.getVideo(source: ImageSource.gallery))?.path,
              filePaths.first,
            );
          },
        );
      },
    );

    test(
      'getVideo throws $PlatformException for PHPicker on platform API error',
      () {
        testWithPHPicker(
            enabled: true,
            body: () async {
              for (final ImagePickerError error in ImagePickerError.values) {
                const String platformErrorMessage =
                    'Example Platform Error Message';
                when(mockImagePickerApi.pickVideos(any))
                    .thenAnswer((_) async => ImagePickerErrorResult(
                          error: error,
                          platformErrorMessage: platformErrorMessage,
                        ));
                await expectLater(
                  () => plugin.getVideo(source: ImageSource.gallery),
                  throwsA(
                    isA<PlatformException>()
                        .having(
                          (PlatformException e) => e.code,
                          'code',
                          equals(error.name),
                        )
                        .having(
                          (PlatformException e) => e.details,
                          'details',
                          equals(platformErrorMessage),
                        ),
                  ),
                );
                verify(mockImagePickerApi.pickVideos(any)).called(1);
              }
            });
      },
    );
  });

  group('media', () {
    test('getMedia passes the accepted type groups correctly', () async {
      await plugin.getMedia(options: const MediaOptions(allowMultiple: true));

      final VerificationResult result = verify(
          mockFileSelectorPlatform.openFiles(
              acceptedTypeGroups: captureAnyNamed('acceptedTypeGroups')));
      expect(capturedTypeGroups(result)[0].extensions,
          <String>['public.image', 'public.movie']);
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

    test(
      'getMedia uses file selector when PHPicker is disabled',
      () async {
        testWithPHPicker(
          enabled: false,
          body: () async {
            Future<void> sharedTest({required bool allowMultiple}) async {
              await plugin.getMedia(
                  options: MediaOptions(allowMultiple: allowMultiple));
              verify(plugin.shouldUsePHPicker()).called(1);
              verifyNever(mockImagePickerApi.pickMedia(any, any));

              if (allowMultiple) {
                verify(mockFileSelectorPlatform.openFiles(
                        acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
                    .called(1);
              } else {
                verify(mockFileSelectorPlatform.openFile(
                        acceptedTypeGroups: anyNamed('acceptedTypeGroups')))
                    .called(1);
              }
            }

            await sharedTest(allowMultiple: true);
            await sharedTest(allowMultiple: false);
          },
        );
      },
    );

    test(
      'getMedia uses PHPicker when it is enabled',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getMedia(
              options: const MediaOptions(allowMultiple: false),
            );
            verify(plugin.shouldUsePHPicker()).called(1);
            verify(mockImagePickerApi.pickMedia(any, any)).called(1);

            verifyNever(mockFileSelectorPlatform.openFile(
                acceptedTypeGroups: anyNamed('acceptedTypeGroups')));
          },
        );
      },
    );

    test(
      'getMultiImageWithOptions pass 0 as limit to pickImages when unspecified '
      'and 1 if allowMultiple is false for PHPicker implementation',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getMedia(
              options: const MediaOptions(
                allowMultiple: true,
                // ignore: avoid_redundant_argument_values
                limit: null,
              ),
            );
            verify(mockImagePickerApi.pickMedia(
              any,
              argThat(
                predicate<GeneralOptions>(
                    (GeneralOptions options) => options.limit == 0),
              ),
            ));

            await plugin.getMedia(
              options: const MediaOptions(
                allowMultiple: false,
                // ignore: avoid_redundant_argument_values
                limit: null,
              ),
            );
            verify(mockImagePickerApi.pickMedia(
              any,
              argThat(
                predicate<GeneralOptions>(
                    (GeneralOptions options) => options.limit == 1),
              ),
            ));
          },
        );
      },
    );

    test(
      'getMedia return the files from the platform API for PHPicker implementation',
      () {
        testWithPHPicker(
          enabled: true,
          body: () async {
            final List<String> filePaths = <String>[
              '/foo/bar/image.png',
              '/dev/flutter/plugins/video.mp4',
              'path/to/file'
            ];
            when(mockImagePickerApi.pickMedia(
              any,
              any,
            )).thenAnswer((_) async {
              return ImagePickerSuccessResult(filePaths: filePaths);
            });
            expect(
              (await plugin.getMedia(
                      options: const MediaOptions(allowMultiple: true)))
                  .map((XFile file) => file.path),
              filePaths,
            );
          },
        );
      },
    );

    test(
      'getMedia uses 100 as image quality if not provided',
      () async {
        testWithPHPicker(
          enabled: true,
          body: () async {
            await plugin.getMedia(
              options: const MediaOptions(
                allowMultiple: true,
                // ignore: avoid_redundant_argument_values
                imageOptions: ImageOptions(imageQuality: null),
              ),
            );

            verify(mockImagePickerApi.pickMedia(
              argThat(
                predicate<MediaSelectionOptions>(
                    (MediaSelectionOptions options) =>
                        options.imageSelectionOptions.quality == 100),
              ),
              any,
            )).called(1);
          },
        );
      },
    );

    test(
      'getMedia passes the arguments correctly to the platform API for the PHPicker implementation',
      () {
        testWithPHPicker(
          enabled: true,
          body: () async {
            const MediaOptions mediaOptions = MediaOptions(
              allowMultiple: true,
              imageOptions: ImageOptions(
                maxWidth: 500,
                maxHeight: 300,
                imageQuality: 80,
              ),
              limit: 10,
            );
            await plugin.getMedia(options: mediaOptions);
            verify(mockImagePickerApi.pickMedia(
              argThat(predicate<MediaSelectionOptions>(
                (MediaSelectionOptions options) =>
                    options.imageSelectionOptions.maxSize?.width ==
                        mediaOptions.imageOptions.maxWidth &&
                    options.imageSelectionOptions.maxSize?.height ==
                        mediaOptions.imageOptions.maxHeight &&
                    options.imageSelectionOptions.quality ==
                        mediaOptions.imageOptions.imageQuality,
              )),
              argThat(predicate<GeneralOptions>(
                (GeneralOptions options) => options.limit == mediaOptions.limit,
              )),
            ));
          },
        );
      },
    );

    test(
      'getMedia throws $PlatformException for PHPicker on platform API error',
      () {
        testWithPHPicker(
            enabled: true,
            body: () async {
              for (final ImagePickerError error in ImagePickerError.values) {
                const String platformErrorMessage =
                    'Example Platform Error Message';
                when(mockImagePickerApi.pickMedia(any, any))
                    .thenAnswer((_) async => ImagePickerErrorResult(
                          error: error,
                          platformErrorMessage: platformErrorMessage,
                        ));
                await expectLater(
                  () => plugin.getMedia(
                    options: const MediaOptions(allowMultiple: true),
                  ),
                  throwsA(
                    isA<PlatformException>()
                        .having(
                          (PlatformException e) => e.code,
                          'code',
                          equals(error.name),
                        )
                        .having(
                          (PlatformException e) => e.details,
                          'details',
                          equals(platformErrorMessage),
                        ),
                  ),
                );
                verify(mockImagePickerApi.pickMedia(any, any)).called(1);
              }
            });
      },
    );
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
