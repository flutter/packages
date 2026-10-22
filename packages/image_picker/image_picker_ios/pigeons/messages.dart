// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    objcHeaderOut:
        'ios/image_picker_ios/Sources/image_picker_ios/include/image_picker_ios/messages.g.h',
    objcSourceOut: 'ios/image_picker_ios/Sources/image_picker_ios/messages.g.m',
    objcOptions: ObjcOptions(
      prefix: 'FLT',
      headerIncludePath: './include/image_picker_ios/messages.g.h',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
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

/// Options for retrieving recent media.
class RecentMediaRequest {
  RecentMediaRequest({
    required this.limit,
    required this.includeImages,
    required this.includeVideos,
    required this.width,
    required this.height,
  });

  /// The maximum number of items to return.
  int limit;

  /// Whether to include images.
  bool includeImages;

  /// Whether to include videos.
  bool includeVideos;

  /// The target width of each thumbnail, in pixels.
  int width;

  /// The target height of each thumbnail, in pixels.
  int height;
}

// Corresponds to `MediaSelectionType` from the platform interface package.
enum RecentMediaKind { image, video }

/// A thumbnail of a recent item from the photo library.
class RecentMediaItem {
  RecentMediaItem({required this.path, required this.kind});

  /// The path to the JPEG thumbnail.
  String path;

  /// The type of the original item.
  RecentMediaKind kind;
}

@HostApi()
abstract class ImagePickerApi {
  @async
  @ObjCSelector('pickImageWithSource:maxSize:quality:fullMetadata:')
  String? pickImage(
    SourceSpecification source,
    MaxSize maxSize,
    int? imageQuality,
    bool requestFullMetadata,
  );
  @async
  @ObjCSelector('pickMultiImageWithMaxSize:quality:fullMetadata:limit:')
  List<String> pickMultiImage(
    MaxSize maxSize,
    int? imageQuality,
    bool requestFullMetadata,
    int? limit,
  );
  @async
  @ObjCSelector('pickVideoWithSource:maxDuration:')
  String? pickVideo(SourceSpecification source, int? maxDurationSeconds);
  @async
  @ObjCSelector('pickMultiVideoWithMaxDuration:limit:')
  List<String> pickMultiVideo(int? maxDurationSeconds, int? limit);

  /// Selects images and videos and returns their paths.
  @async
  @ObjCSelector('pickMediaWithMediaSelectionOptions:')
  List<String> pickMedia(MediaSelectionOptions mediaSelectionOptions);

  /// Returns thumbnails of the most recent items in the photo library.
  @async
  @ObjCSelector('getRecentMediaWithRequest:')
  List<RecentMediaItem> getRecentMedia(RecentMediaRequest request);
}
