// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'src/messages.g.dart';

/// An Android implementation of [ImagePickerPlatform].
base class ImagePickerAndroid extends ImagePickerPlatform {
  /// Creates a new plugin implementation instance.
  ImagePickerAndroid({@visibleForTesting ImagePickerApi? api}) : _hostApi = api ?? ImagePickerApi();

  final ImagePickerApi _hostApi;

  /// Whether to use the Android Photo Picker on Android versions less than 16.
  ///
  /// On Android 16+ the Photo Picker is always used regardless of this setting.
  ///
  /// On earlier Android versions, setting this to false uses the legacy
  /// `ACTION_GET_CONTENT` picker instead of the Photo Picker.
  ///
  /// Defaults to false.
  bool useAndroidPhotoPicker = false;

  /// Registers this class as the default platform implementation.
  static void registerWith() {
    ImagePickerPlatform.instance = ImagePickerAndroid();
  }

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    final ImageOptions imageOptions = options.imageOptions;
    _verifyImageOptions(imageOptions);

    final List<String> paths = await _hostApi.pickImages(
      _buildSourceSpec(source, options.preferredCameraDevice),
      ImageSelectionOptions(
        maxWidth: imageOptions.maxWidth?.toDouble(),
        maxHeight: imageOptions.maxHeight?.toDouble(),
        quality: imageOptions.imageQuality ?? 100,
      ),
      GeneralOptions(allowMultiple: false, usePhotoPicker: useAndroidPhotoPicker),
    );
    return paths.isEmpty ? null : XFile.fileSystem(path: paths.first);
  }

  @override
  Future<List<XFile>> pickMultiImage({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    final ImageOptions imageOptions = options.imageOptions;
    _verifyImageOptions(imageOptions);

    final int? limit = options.limit;
    if (limit != null && limit < 2) {
      throw RangeError.range(limit, 2, null, 'limit');
    }

    final List<String> paths = await _hostApi.pickImages(
      SourceSpecification(type: SourceType.gallery),
      ImageSelectionOptions(
        maxWidth: imageOptions.maxWidth?.toDouble(),
        maxHeight: imageOptions.maxHeight?.toDouble(),
        quality: imageOptions.imageQuality ?? 100,
      ),
      GeneralOptions(allowMultiple: true, usePhotoPicker: useAndroidPhotoPicker, limit: limit),
    );
    if (paths.isEmpty) {
      return <XFile>[];
    }

    return paths.map((String path) => XFile.fileSystem(path: path)).toList();
  }

  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    VideoPickerOptions options = const VideoPickerOptions(),
  }) async {
    final Duration? maxDuration = options.videoOptions.maxDuration;
    if (maxDuration != null && (maxDuration.isNegative || maxDuration == Duration.zero)) {
      throw ArgumentError.value(maxDuration, 'maxDuration', 'must be greater than zero.');
    }

    final List<String> paths = await _hostApi.pickVideos(
      _buildSourceSpec(source, options.preferredCameraDevice),
      VideoSelectionOptions(maxDurationSeconds: maxDuration?.inSeconds),
      GeneralOptions(allowMultiple: false, usePhotoPicker: useAndroidPhotoPicker),
    );
    return paths.isEmpty ? null : XFile.fileSystem(path: paths.first);
  }

  @override
  Future<List<XFile>> pickMultiVideo({
    MultiVideoPickerOptions options = const MultiVideoPickerOptions(),
  }) async {
    final Duration? maxDuration = options.videoOptions.maxDuration;
    if (maxDuration != null && (maxDuration.isNegative || maxDuration == Duration.zero)) {
      throw ArgumentError.value(maxDuration, 'maxDuration', 'must be greater than zero.');
    }

    final int? limit = options.limit;
    if (limit != null && limit < 2) {
      throw RangeError.range(limit, 2, null, 'limit');
    }

    final List<String> paths = await _hostApi.pickVideos(
      SourceSpecification(type: SourceType.gallery),
      VideoSelectionOptions(maxDurationSeconds: options.videoOptions.maxDuration?.inSeconds),
      GeneralOptions(allowMultiple: true, usePhotoPicker: useAndroidPhotoPicker, limit: limit),
    );

    if (paths.isEmpty) {
      return <XFile>[];
    }

    return paths.map((String path) => XFile.fileSystem(path: path)).toList();
  }

  @override
  Future<List<XFile>> pickMedia({required MediaPickerOptions options}) async {
    return (await _hostApi.pickMedia(
      _mediaOptionsToMediaSelectionOptions(options),
      _mediaOptionsToGeneralOptions(options),
    )).map((String? path) => XFile.fileSystem(path: path!)).toList();
  }

  MediaSelectionOptions _mediaOptionsToMediaSelectionOptions(MediaPickerOptions mediaOptions) {
    final ImageSelectionOptions imageSelectionOptions =
        _imageOptionsToImageSelectionOptionsWithValidator(mediaOptions.imageOptions);

    return MediaSelectionOptions(imageSelectionOptions: imageSelectionOptions);
  }

  ImageSelectionOptions _imageOptionsToImageSelectionOptionsWithValidator(
    ImageOptions imageOptions,
  ) {
    _verifyImageOptions(imageOptions);
    return ImageSelectionOptions(
      quality: imageOptions.imageQuality ?? 100,
      maxHeight: imageOptions.maxHeight?.toDouble(),
      maxWidth: imageOptions.maxWidth?.toDouble(),
    );
  }

  GeneralOptions _mediaOptionsToGeneralOptions(MediaPickerOptions options) {
    final bool allowMultiple = options.allowMultiple;
    final int? limit = options.limit;

    if (!allowMultiple && limit != null) {
      throw ArgumentError.value(
        allowMultiple,
        'allowMultiple',
        'cannot be false, when limit is not null',
      );
    }

    if (limit != null && limit < 2) {
      throw ArgumentError.value(limit, 'limit', 'cannot be lower than 2');
    }

    return GeneralOptions(
      allowMultiple: allowMultiple,
      usePhotoPicker: useAndroidPhotoPicker,
      limit: limit,
    );
  }

  @override
  Future<LostDataResponse> getLostData() async {
    final CacheRetrievalResult? result = await _hostApi.retrieveLostResults();

    if (result == null) {
      return LostDataResponse.empty();
    }

    // There must either be data or an error if the response wasn't null.
    assert(result.paths.isEmpty != (result.error == null));

    final CacheRetrievalError? error = result.error;
    final PlatformException? exception = error == null
        ? null
        : PlatformException(code: error.code, message: error.message);

    // Entries are guaranteed not to be null, even though that's not currently
    // expressible in Pigeon.
    final List<XFile> pickedFileList = result.paths
        .map((String? path) => XFile.fileSystem(path: path!))
        .toList();

    return LostDataResponse(
      file: pickedFileList.isEmpty ? null : pickedFileList.last,
      exception: exception,
      type: _retrieveTypeForCacheType(result.type),
      files: pickedFileList,
    );
  }

  SourceSpecification _buildSourceSpec(ImageSource source, CameraDevice device) {
    return SourceSpecification(
      type: _sourceSpecTypeForSource(source),
      camera: _sourceSpecCameraForDevice(device),
    );
  }

  SourceType _sourceSpecTypeForSource(ImageSource source) {
    switch (source) {
      case ImageSource.camera:
        return SourceType.camera;
      case ImageSource.gallery:
        return SourceType.gallery;
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return SourceType.gallery;
  }

  SourceCamera _sourceSpecCameraForDevice(CameraDevice device) {
    switch (device) {
      case CameraDevice.front:
        return SourceCamera.front;
      case CameraDevice.rear:
        return SourceCamera.rear;
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return SourceCamera.rear;
  }

  RetrieveType _retrieveTypeForCacheType(CacheRetrievalType type) {
    switch (type) {
      case CacheRetrievalType.image:
        return RetrieveType.image;
      case CacheRetrievalType.video:
        return RetrieveType.video;
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return RetrieveType.image;
  }

  void _verifyImageOptions(ImageOptions options) {
    if (options.imageQuality case final int imageQuality) {
      RangeError.checkValueInInterval(imageQuality, 0, 100, 'imageQuality');
    }
    if (options.maxWidth case final int maxWidth) {
      RangeError.checkNotNegative(maxWidth, 'maxWidth');
    }
    if (options.maxHeight case final int maxHeight) {
      RangeError.checkNotNegative(maxHeight, 'maxHeight');
    }
  }
}
