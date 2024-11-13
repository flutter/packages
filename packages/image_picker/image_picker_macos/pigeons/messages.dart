// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  swiftOut:
      'macos/image_picker_macos/Sources/image_picker_macos/messages.g.swift',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// The common options between [ImageSelectionOptions], [VideoSelectionOptions]
/// and [MediaSelectionOptions].
class GeneralOptions {
  GeneralOptions({required this.limit});

  /// The value `0` means no limit.
  int limit;
}

/// Represents the maximum size with [width] and [height] dimensions.
class MaxSize {
  MaxSize(this.width, this.height);
  double? width;
  double? height;
}

/// Options for image selection and output.
class ImageSelectionOptions {
  ImageSelectionOptions({this.maxSize, required this.quality});

  /// If set, the max size that the image should be resized to fit in.
  MaxSize? maxSize;

  /// The quality of the output image, from 0-100.
  ///
  /// 100 indicates original quality.
  int quality;
}

// TODO(EchoEllet): Confirm if it's not possible to support maxDurationSeconds with macOS PHPicker
// /// Options for video selection and output.
// class VideoSelectionOptions {
//   VideoSelectionOptions();

// }

class MediaSelectionOptions {
  MediaSelectionOptions({
    required this.imageSelectionOptions,
  });

  ImageSelectionOptions imageSelectionOptions;
}

@HostApi(dartHostTestHandler: 'TestHostImagePickerApi')
abstract class ImagePickerApi {
  bool supportsPHPicker();

  // TODO(EchoEllet): Should ImagePickerApi be more similar to image_picker_ios or image_picker_android messages.dart?
  //  `pickImage()` and `pickMultiImage()` vs `pickImages()` with `limit` and `allowMultiple`.
  //  Currently it's closer to the image_picker_android messages.dart but without allowMultiple

  // Return file paths

  @async
  List<String> pickImages(
    ImageSelectionOptions options,
    GeneralOptions generalOptions,
  );

  /// Currently, multi-video selection is unimplemented.
  @async
  List<String> pickVideos(
    GeneralOptions generalOptions,
  );
  @async
  List<String> pickMedia(
    MediaSelectionOptions options,
    GeneralOptions generalOptions,
  );
}
