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
    // TODO: Should support passing extensions also.
    final FileResponse? file = await _api.openFile(
      initialDirectory,
      acceptedTypeGroups == null ? null : _combineMimeTypes(acceptedTypeGroups),
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
      null,
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
    return XFile(
      file.path,
      name: file.name,
      mimeType: file.mimeType,
      bytes: file.bytes,
    );
  }

  List<String> _combineMimeTypes(List<XTypeGroup> groups) {
    return groups.fold<Set<String>>(
      <String>{},
      (Set<String> previousValue, XTypeGroup element) {
        previousValue.addAll(element.mimeTypes ?? <String>[]);
        return previousValue;
      },
    ).toList();
  }
}
