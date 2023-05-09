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
    final String? filePath = await _api.openFile(initialDirectory, null);
    return filePath != null ? XFile(filePath) : null;
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String?> filePaths =
        await _api.openFiles(initialDirectory, null);
    return filePaths
        .map<XFile>((String? filePath) => XFile(filePath!))
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
}
