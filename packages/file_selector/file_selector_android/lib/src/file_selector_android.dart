// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/cupertino.dart';

import 'file_selector_api.g.dart';

/// An implementation of [FileSelectorPlatform] for Android.
base class FileSelectorAndroid extends FileSelectorPlatform {
  FileSelectorAndroid({@visibleForTesting FileSelectorApi? api}) : _api = api ?? FileSelectorApi();

  final FileSelectorApi _api;

  /// Registers this class as the implementation of the file_selector platform interface.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorAndroid();
  }

  @override
  Future<XFile?> openFile([OpenDialogOptions options = const OpenDialogOptions()]) async {
    final String? uri = await _api.openFile(
      options.initialDirectory,
      _fileTypesFromTypeGroups(options.acceptedTypeGroups),
    );
    return uri == null ? null : XFile.scopedStorage(uri: uri);
  }

  @override
  Future<List<XFile>> openFiles([OpenDialogOptions options = const OpenDialogOptions()]) async {
    final List<String> files = await _api.openFiles(
      options.initialDirectory,
      _fileTypesFromTypeGroups(options.acceptedTypeGroups),
    );
    return files.map<XFile>((String uri) => XFile.scopedStorage(uri: uri)).toList();
  }

  @override
  Future<XDirectory?> getDirectory([FileDialogOptions options = const FileDialogOptions()]) async {
    final String? uri = await _api.getDirectoryPath(options.initialDirectory);
    return uri == null ? null : XDirectory.scopedStorage(uri: uri);
  }

  FileTypes _fileTypesFromTypeGroups(List<XTypeGroup>? typeGroups) {
    if (typeGroups == null) {
      return FileTypes(extensions: <String>[], mimeTypes: <String>[]);
    }

    final mimeTypes = <String>{};
    final extensions = <String>{};

    for (final XTypeGroup group in typeGroups) {
      if (!group.allowsAny && group.mimeTypes == null && group.extensions == null) {
        throw ArgumentError(
          'Provided type group $group does not allow all files, but does not '
          'set any of the Android supported filter categories. At least one of '
          '"extensions" or "mimeTypes" must be non-empty for Android.',
        );
      }

      mimeTypes.addAll(group.mimeTypes ?? <String>{});
      extensions.addAll(group.extensions ?? <String>{});
    }

    return FileTypes(mimeTypes: mimeTypes.toList(), extensions: extensions.toList());
  }
}
