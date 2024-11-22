// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  objcHeaderOut:
      'ios/image_picker_ios/Sources/image_picker_ios/include/image_picker_ios/messages.g.h',
  objcSourceOut: 'ios/image_picker_ios/Sources/image_picker_ios/messages.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FLT',
    headerIncludePath: './include/image_picker_ios/messages.g.h',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
class MaxSize {
  MaxSize(this.width, this.height);
  double? width;
  double? height;
}

class MediaSelectionOptions {
  MediaSelectionOptions({
    required this.maxSize,
    this.imageQuality,
    required this.requestFullMetadata,
    required this.allowMultiple,
    this.limit,
  });

  MaxSize maxSize;
  int? imageQuality;
  bool requestFullMetadata;
  bool allowMultiple;
  int? limit;
}

// Corresponds to `CameraDevice` from the platform interface package.
enum SourceCamera { rear, front }

// Corresponds to `ImageSource` from the platform interface package.
enum SourceType { camera, gallery }

class SourceSpecification {
  SourceSpecification(this.type, this.camera);
  SourceType type;
  SourceCamera camera;
}

@HostApi(dartHostTestHandler: 'TestHostImagePickerApi')
abstract class ImagePickerApi {
  @async
  @ObjCSelector('pickImageWithSource:maxSize:quality:fullMetadata:')
  String? pickImage(SourceSpecification source, MaxSize maxSize,
      int? imageQuality, bool requestFullMetadata);
  @async
  @ObjCSelector('pickMultiImageWithMaxSize:quality:fullMetadata:limit:')
  List<String> pickMultiImage(
      MaxSize maxSize, int? imageQuality, bool requestFullMetadata, int? limit);
  @async
  @ObjCSelector('pickVideoWithSource:maxDuration:')
  String? pickVideo(SourceSpecification source, int? maxDurationSeconds);

  /// Selects images and videos and returns their paths.
  @async
  @ObjCSelector('pickMediaWithMediaSelectionOptions:')
  List<String> pickMedia(MediaSelectionOptions mediaSelectionOptions);
}
