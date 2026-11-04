// Copyright 2013 The Flutter Authors
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
base class ImagePickerLinux extends CameraDelegatingImagePickerPlatform {
  /// The file selector used to prompt the user to select images or videos.
  @visibleForTesting
  static FileSelectorPlatform fileSelector = FileSelectorLinux();

  /// Registers this class as the default instance of [ImagePickerPlatform].
  static void registerWith() {
    ImagePickerPlatform.instance = ImagePickerLinux();
  }

  // [ImagePickerOptions] options are not currently supported. If any
  // of its fields are set, they will be silently ignored.
  //
  // If source is `ImageSource.camera`, a `StateError` will be thrown
  // unless a [cameraDelegate] is set.
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    switch (source) {
      case ImageSource.camera:
        return super.pickImage(source: source, options: options);
      case ImageSource.gallery:
        const typeGroup = XTypeGroup(label: 'Images', mimeTypes: <String>['image/*']);
        final XFile? file = await fileSelector.openFile(
          options: const OpenFileDialogOptions(acceptedTypeGroups: <XTypeGroup>[typeGroup]),
        );
        return file;
    }
    // Ensure that there's a fallback in case a new source is added.
    // ignore: dead_code
    throw UnimplementedError('Unknown ImageSource: $source');
  }

  // `preferredCameraDevice` and `maxDuration` arguments are not currently
  // supported. If either of these arguments are supplied, they will be silently
  // ignored.
  //
  // If source is `ImageSource.camera`, a `StateError` will be thrown
  // unless a [cameraDelegate] is set.
  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    VideoPickerOptions options = const VideoPickerOptions(),
  }) async {
    switch (source) {
      case ImageSource.camera:
        return super.pickVideo(source: source, options: options);
      case ImageSource.gallery:
        const typeGroup = XTypeGroup(label: 'Videos', mimeTypes: <String>['video/*']);
        final XFile? file = await fileSelector.openFile(
          options: const OpenFileDialogOptions(acceptedTypeGroups: <XTypeGroup>[typeGroup]),
        );
        return file;
    }
    // Ensure that there's a fallback in case a new source is added.
    // ignore: dead_code
    throw UnimplementedError('Unknown ImageSource: $source');
  }

  // `maxWidth`, `maxHeight`, and `imageQuality` arguments are not currently
  // supported. If any of these arguments are supplied, they will be silently
  // ignored.
  @override
  Future<List<XFile>> pickMultiImage({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    const typeGroup = XTypeGroup(label: 'Images', mimeTypes: <String>['image/*']);
    final List<XFile> files = await fileSelector.openFiles(
      options: const OpenFilesDialogOptions(acceptedTypeGroups: <XTypeGroup>[typeGroup]),
    );
    return files;
  }

  @override
  Future<List<XFile>> pickMultiVideo({
    MultiVideoPickerOptions options = const MultiVideoPickerOptions(),
  }) async {
    const typeGroup = XTypeGroup(label: 'Videos', mimeTypes: <String>['video/*']);
    final List<XFile> files = await fileSelector.openFiles(
      options: const OpenFilesDialogOptions(acceptedTypeGroups: <XTypeGroup>[typeGroup]),
    );
    return files;
  }

  // `maxWidth`, `maxHeight`, and `imageQuality` arguments are not currently
  // supported. If any of these arguments are supplied, they will be silently
  // ignored.
  @override
  Future<List<XFile>> pickMedia({required MediaPickerOptions options}) async {
    const typeGroup = XTypeGroup(
      label: 'Images and videos',
      mimeTypes: <String>['image/*', 'video/*'],
    );

    List<XFile> files;

    if (options.allowMultiple) {
      files = await fileSelector.openFiles(
        options: const OpenFilesDialogOptions(acceptedTypeGroups: <XTypeGroup>[typeGroup]),
      );
    } else {
      final XFile? file = await fileSelector.openFile(
        options: const OpenFileDialogOptions(acceptedTypeGroups: <XTypeGroup>[typeGroup]),
      );
      files = <XFile>[if (file != null) file];
    }
    return files;
  }
}
