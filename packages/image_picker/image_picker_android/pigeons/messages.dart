// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  javaOut: 'android/src/main/java/io/flutter/plugins/imagepicker/Messages.java',
  javaOptions: JavaOptions(
    package: 'io.flutter.plugins.imagepicker',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
class GeneralOptions {
  GeneralOptions(this.allowMultiple, this.usePhotoPicker, this.limit);
  bool allowMultiple;
  bool usePhotoPicker;
  int? limit;
}

/// Options for image selection and output.
class ImageSelectionOptions {
  ImageSelectionOptions({this.maxWidth, this.maxHeight, required this.quality});

  /// If set, the max width that the image should be resized to fit in.
  double? maxWidth;

  /// If set, the max height that the image should be resized to fit in.
  double? maxHeight;

  /// The quality of the output image, from 0-100.
  ///
  /// 100 indicates original quality.
  int quality;
}

class MediaSelectionOptions {
  MediaSelectionOptions({
    required this.imageSelectionOptions,
  });

  ImageSelectionOptions imageSelectionOptions;
}

/// Options for image selection and output.
class VideoSelectionOptions {
  VideoSelectionOptions({this.maxDurationSeconds});

  /// The maximum desired length for the video, in seconds.
  int? maxDurationSeconds;
}

// Corresponds to `CameraDevice` from the platform interface package.
enum SourceCamera { rear, front }

// Corresponds to `ImageSource` from the platform interface package.
enum SourceType { camera, gallery }

/// Specification for the source of an image or video selection.
class SourceSpecification {
  SourceSpecification(this.type, this.camera);
  SourceType type;
  SourceCamera? camera;
}

/// An error that occurred during lost result retrieval.
///
/// The data here maps to the `PlatformException` that will be created from it.
class CacheRetrievalError {
  CacheRetrievalError({required this.code, this.message});
  final String code;
  final String? message;
}

// Corresponds to `RetrieveType` from the platform interface package.
enum CacheRetrievalType { image, video }

/// The result of retrieving cached results from a previous run.
class CacheRetrievalResult {
  CacheRetrievalResult(
      {required this.type, this.error, this.paths = const <String>[]});

  /// The type of the retrieved data.
  final CacheRetrievalType type;

  /// The error from the last selection, if any.
  final CacheRetrievalError? error;

  /// The results from the last selection, if any.
  ///
  /// Elements must not be null, by convention. See
  /// https://github.com/flutter/flutter/issues/97848
  final List<String?> paths;
}

@HostApi(dartHostTestHandler: 'TestHostImagePickerApi')
abstract class ImagePickerApi {
  /// Selects images and returns their paths.
  ///
  /// Elements must not be null, by convention. See
  /// https://github.com/flutter/flutter/issues/97848
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  @async
  List<String?> pickImages(
    SourceSpecification source,
    ImageSelectionOptions options,
    GeneralOptions generalOptions,
  );

  /// Selects video and returns their paths.
  ///
  /// Elements must not be null, by convention. See
  /// https://github.com/flutter/flutter/issues/97848
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  @async
  List<String?> pickVideos(
    SourceSpecification source,
    VideoSelectionOptions options,
    GeneralOptions generalOptions,
  );

  /// Selects images and videos and returns their paths.
  ///
  /// Elements must not be null, by convention. See
  /// https://github.com/flutter/flutter/issues/97848
  @async
  List<String?> pickMedia(
    MediaSelectionOptions mediaSelectionOptions,
    GeneralOptions generalOptions,
  );

  /// Returns results from a previous app session, if any.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  CacheRetrievalResult? retrieveLostResults();
}
