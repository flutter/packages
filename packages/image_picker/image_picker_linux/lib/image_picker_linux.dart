// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_linux/file_selector_linux.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// The Linux implementation of [ImagePickerPlatform].
///
/// This class implements the `package:image_picker` functionality for
/// Linux.
class ImagePickerLinux extends CameraDelegatingImagePickerPlatform {
  /// Constructs a platform implementation.
  ImagePickerLinux();

  /// The file selector used to prompt the user to select images or videos.
  @visibleForTesting
  static FileSelectorPlatform fileSelector = FileSelectorLinux();

  /// Registers this class as the default instance of [ImagePickerPlatform].
  static void registerWith() {
    ImagePickerPlatform.instance = ImagePickerLinux();
  }

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final XFile? file = await getImageFromSource(
        source: source,
        options: ImagePickerOptions(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: imageQuality,
            preferredCameraDevice: preferredCameraDevice));
    if (file != null) {
      return PickedFile(file.path);
    }
    return null;
  }

  @override
  Future<PickedFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final XFile? file = await getVideo(
        source: source,
        preferredCameraDevice: preferredCameraDevice,
        maxDuration: maxDuration);
    if (file != null) {
      return PickedFile(file.path);
    }
    return null;
  }

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    return getImageFromSource(
        source: source,
        options: ImagePickerOptions(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: imageQuality,
            preferredCameraDevice: preferredCameraDevice));
  }

  // [ImagePickerOptions] options are not currently supported on Linux. If any
  // of its fields are set, they will be silently ignored.
  //
  // If source is `ImageSource.camera`, an `StateError` will be thrown
  // unless a [cameraDelegate] is set.
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    switch (source) {
      case ImageSource.camera:
        return super.getImageFromSource(source: source);
      case ImageSource.gallery:
        const XTypeGroup typeGroup =
            XTypeGroup(label: 'Images', mimeTypes: <String>['image/*']);
        final XFile? file = await fileSelector
            .openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
        return file;
    }
    // Ensure that there's a fallback in case a new source is added.
    // ignore: dead_code
    throw UnimplementedError('Unknown ImageSource: $source');
  }

  // `preferredCameraDevice` and `maxDuration` arguments are not currently
  // supported on Linux. If any of these arguments is supplied, they will be
  // silently ignored.
  //
  // If source is `ImageSource.camera`, an `StateError` will be thrown
  // unless a [cameraDelegate] is set.
  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    switch (source) {
      case ImageSource.camera:
        return super.getVideo(
            source: source,
            preferredCameraDevice: preferredCameraDevice,
            maxDuration: maxDuration);
      case ImageSource.gallery:
        const XTypeGroup typeGroup =
            XTypeGroup(label: 'Videos', mimeTypes: <String>['video/*']);
        final XFile? file = await fileSelector
            .openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
        return file;
    }
    // Ensure that there's a fallback in case a new source is added.
    // ignore: dead_code
    throw UnimplementedError('Unknown ImageSource: $source');
  }

  // `maxWidth`, `maxHeight`, and `imageQuality` arguments are not currently
  // supported on Linux. If any of these arguments is supplied, they will be
  // silently ignored.
  @override
  Future<List<XFile>> getMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    const XTypeGroup typeGroup =
        XTypeGroup(label: 'Images', mimeTypes: <String>['image/*']);
    final List<XFile> files = await fileSelector
        .openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    return files;
  }
}
