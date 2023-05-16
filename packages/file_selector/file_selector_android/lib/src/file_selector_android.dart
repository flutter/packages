// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import 'file_selector_api.g.dart';

/// An implementation of [FileSelectorPlatform] for Android.
class FileSelectorAndroid extends FileSelectorPlatform {
  final FileSelectorApi _api = FileSelectorApi();

  /// Registers this class as the implementation of the file_selector platform interface.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorAndroid();
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final FileResponse? file = await _api.openFile(
      initialDirectory,
      acceptedTypeGroups == null
          ? null
          : _combine<String>(
              acceptedTypeGroups,
              (XTypeGroup group) => group.mimeTypes,
            ),
      acceptedTypeGroups == null
          ? null
          : _combine<String>(
              acceptedTypeGroups,
              (XTypeGroup group) => group.extensions,
            ),
    );
    return file == null ? null : _xFileFromFileResponse(file);
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<FileResponse?> files = await _api.openFiles(
      initialDirectory,
      acceptedTypeGroups == null
          ? null
          : _combine<String>(
              acceptedTypeGroups,
              (XTypeGroup group) => group.mimeTypes,
            ),
      acceptedTypeGroups == null
          ? null
          : _combine<String>(
              acceptedTypeGroups,
              (XTypeGroup group) => group.extensions,
            ),
    );
    return files
        .cast<FileResponse>()
        .map<XFile>(_xFileFromFileResponse)
        .toList();
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return _api.getDirectoryPath(initialDirectory);
  }

  @override
  Future<List<String>> getDirectoryPaths({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> dirs = await _api.getDirectoryPaths(initialDirectory);
    return dirs.cast<String>();
  }

  XFile _xFileFromFileResponse(FileResponse file) {
    return XFile.fromData(
      file.bytes,
      // Note: The name parameter is not used by XFile. The XFile.name returns
      // the extracted file name from XFile.path.
      name: file.name,
      length: file.size,
      mimeType: file.mimeType,
      path: file.path,
    );
  }

  // Combines list values from a list of `XTypeGroup`s. Prevents repeated
  // values.
  List<T> _combine<T>(
    List<XTypeGroup> groups,
    List<T>? Function(XTypeGroup group) onGetList,
  ) {
    return groups.fold<Set<T>>(
      <T>{},
      (Set<T> previousValue, XTypeGroup element) {
        previousValue.addAll(onGetList(element) ?? <T>[]);
        return previousValue;
      },
    ).toList();
  }
}
