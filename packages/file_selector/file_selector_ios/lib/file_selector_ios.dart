// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'src/messages.g.dart';

/// An implementation of [FileSelectorPlatform] for iOS.
base class FileSelectorIOS extends FileSelectorPlatform {
  /// Creates a new plugin implementation instance.
  FileSelectorIOS({@visibleForTesting FileSelectorApi? api}) : _hostApi = api ?? FileSelectorApi();

  final FileSelectorApi _hostApi;

  /// Registers the iOS implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorIOS();
  }

  // TODO(bparrishMines): Add an iOS `OpenDialogOptions` implementation option
  // to configure the flag passed to the native
  // UIDocumentPickerViewController:(documenttypes:in:). The plugin currently
  // passes `UIDocumentPickerMode.import` which "essentially` creates a copy of
  // the file. So this returns a `FileSystemXFile` instead of a
  // `ScopedStorageXFile`. See https://github.com/flutter/flutter/issues/193925
  @override
  Future<XFile?> openFile([OpenDialogOptions options = const OpenDialogOptions()]) async {
    final List<String> path = await _hostApi.openFile(
      FileSelectorConfig(utis: _allowedUtiListFromTypeGroups(options.acceptedTypeGroups)),
    );
    return path.isEmpty ? null : XFile.fileSystem(path: path.first);
  }

  // TODO(bparrishMines): Add an iOS `OpenDialogOptions` implementation option
  // to configure the flag passed to the native
  // UIDocumentPickerViewController:(documenttypes:in:). The plugin currently
  // passes `UIDocumentPickerMode.import` which "essentially` creates a copy of
  // the file. So this returns a `FileSystemXFile` instead of a
  // `ScopedStorageXFile`. See https://github.com/flutter/flutter/issues/193925
  @override
  Future<List<XFile>> openFiles([OpenDialogOptions options = const OpenDialogOptions()]) async {
    final List<String> pathList = await _hostApi.openFile(
      FileSelectorConfig(
        utis: _allowedUtiListFromTypeGroups(options.acceptedTypeGroups),
        allowMultiSelection: true,
      ),
    );
    return pathList.map((String path) => XFile.fileSystem(path: path)).toList();
  }

  // Converts the type group list into a list of all allowed UTIs, since
  // iOS doesn't support filter groups.
  List<String> _allowedUtiListFromTypeGroups(List<XTypeGroup>? typeGroups) {
    // iOS requires a list of allowed types, so allowing all is expressed via
    // a root type rather than an empty list.
    const allowAny = <String>['public.data'];

    if (typeGroups == null || typeGroups.isEmpty) {
      return allowAny;
    }
    final allowedUTIs = <String>[];
    for (final XTypeGroup typeGroup in typeGroups) {
      // If any group allows everything, no filtering should be done.
      if (typeGroup.allowsAny) {
        return allowAny;
      }
      if (typeGroup.uniformTypeIdentifiers?.isEmpty ?? true) {
        throw ArgumentError(
          'The provided type group $typeGroup should either '
          'allow all files, or have a non-empty "uniformTypeIdentifiers"',
        );
      }
      allowedUTIs.addAll(typeGroup.uniformTypeIdentifiers!);
    }
    return allowedUTIs;
  }
}
