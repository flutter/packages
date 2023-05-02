// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v9.2.5), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

enum SourceCamera {
  rear,
  front,
}

enum SourceType {
  camera,
  gallery,
}

enum CacheRetrievalType {
  image,
  video,
}

/// Options for image selection and output.
class ImageSelectionOptions {
  ImageSelectionOptions({
    this.maxWidth,
    this.maxHeight,
    required this.quality,
  });

  /// If set, the max width that the image should be resized to fit in.
  double? maxWidth;

  /// If set, the max height that the image should be resized to fit in.
  double? maxHeight;

  /// The quality of the output image, from 0-100.
  ///
  /// 100 indicates original quality.
  int quality;

  Object encode() {
    return <Object?>[
      maxWidth,
      maxHeight,
      quality,
    ];
  }

  static ImageSelectionOptions decode(Object result) {
    result as List<Object?>;
    return ImageSelectionOptions(
      maxWidth: result[0] as double?,
      maxHeight: result[1] as double?,
      quality: result[2]! as int,
    );
  }
}

/// Options for image selection and output.
class VideoSelectionOptions {
  VideoSelectionOptions({
    this.maxDurationSeconds,
  });

  /// The maximum desired length for the video, in seconds.
  int? maxDurationSeconds;

  Object encode() {
    return <Object?>[
      maxDurationSeconds,
    ];
  }

  static VideoSelectionOptions decode(Object result) {
    result as List<Object?>;
    return VideoSelectionOptions(
      maxDurationSeconds: result[0] as int?,
    );
  }
}

/// Specification for the source of an image or video selection.
class SourceSpecification {
  SourceSpecification({
    required this.type,
    this.camera,
  });

  SourceType type;

  SourceCamera? camera;

  Object encode() {
    return <Object?>[
      type.index,
      camera?.index,
    ];
  }

  static SourceSpecification decode(Object result) {
    result as List<Object?>;
    return SourceSpecification(
      type: SourceType.values[result[0]! as int],
      camera: result[1] != null ? SourceCamera.values[result[1]! as int] : null,
    );
  }
}

/// An error that occurred during lost result retrieval.
///
/// The data here maps to the `PlatformException` that will be created from it.
class CacheRetrievalError {
  CacheRetrievalError({
    required this.code,
    this.message,
  });

  String code;

  String? message;

  Object encode() {
    return <Object?>[
      code,
      message,
    ];
  }

  static CacheRetrievalError decode(Object result) {
    result as List<Object?>;
    return CacheRetrievalError(
      code: result[0]! as String,
      message: result[1] as String?,
    );
  }
}

/// The result of retrieving cached results from a previous run.
class CacheRetrievalResult {
  CacheRetrievalResult({
    required this.type,
    this.error,
    required this.paths,
  });

  /// The type of the retrieved data.
  CacheRetrievalType type;

  /// The error from the last selection, if any.
  CacheRetrievalError? error;

  /// The results from the last selection, if any.
  ///
  /// Elements must not be null, by convention. See
  /// https://github.com/flutter/flutter/issues/97848
  List<String?> paths;

  Object encode() {
    return <Object?>[
      type.index,
      error?.encode(),
      paths,
    ];
  }

  static CacheRetrievalResult decode(Object result) {
    result as List<Object?>;
    return CacheRetrievalResult(
      type: CacheRetrievalType.values[result[0]! as int],
      error: result[1] != null
          ? CacheRetrievalError.decode(result[1]! as List<Object?>)
          : null,
      paths: (result[2] as List<Object?>?)!.cast<String?>(),
    );
  }
}

class _ImagePickerApiCodec extends StandardMessageCodec {
  const _ImagePickerApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is CacheRetrievalError) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is CacheRetrievalResult) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else if (value is ImageSelectionOptions) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else if (value is SourceSpecification) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    } else if (value is VideoSelectionOptions) {
      buffer.putUint8(132);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return CacheRetrievalError.decode(readValue(buffer)!);
      case 129:
        return CacheRetrievalResult.decode(readValue(buffer)!);
      case 130:
        return ImageSelectionOptions.decode(readValue(buffer)!);
      case 131:
        return SourceSpecification.decode(readValue(buffer)!);
      case 132:
        return VideoSelectionOptions.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class ImagePickerApi {
  /// Constructor for [ImagePickerApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  ImagePickerApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;
  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _ImagePickerApiCodec();

  /// Selects images and returns their paths.
  ///
  /// Elements must not be null, by convention. See
  /// https://github.com/flutter/flutter/issues/97848
  Future<List<String?>> pickImages(
      SourceSpecification arg_source,
      ImageSelectionOptions arg_options,
      bool arg_allowMultiple,
      bool arg_usePhotoPicker) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ImagePickerApi.pickImages', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(<Object?>[
      arg_source,
      arg_options,
      arg_allowMultiple,
      arg_usePhotoPicker
    ]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as List<Object?>?)!.cast<String?>();
    }
  }

  /// Selects video and returns their paths.
  ///
  /// Elements must not be null, by convention. See
  /// https://github.com/flutter/flutter/issues/97848
  Future<List<String?>> pickVideos(
      SourceSpecification arg_source,
      VideoSelectionOptions arg_options,
      bool arg_allowMultiple,
      bool arg_usePhotoPicker) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ImagePickerApi.pickVideos', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(<Object?>[
      arg_source,
      arg_options,
      arg_allowMultiple,
      arg_usePhotoPicker
    ]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as List<Object?>?)!.cast<String?>();
    }
  }

  /// Returns results from a previous app session, if any.
  Future<CacheRetrievalResult?> retrieveLostResults() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ImagePickerApi.retrieveLostResults', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as CacheRetrievalResult?);
    }
  }
}
