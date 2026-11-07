// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/dom_helper.dart';
import 'src/utils.dart';

/// The web implementation of [FileSelectorPlatform].
///
/// This class implements the `package:file_selector` functionality for the web.
base class FileSelectorWeb extends FileSelectorPlatform {
  /// Default constructor, initializes _domHelper that we can use
  /// to interact with the DOM.
  /// overrides parameter allows for testing to override functions
  FileSelectorWeb({@visibleForTesting DomHelper? domHelper})
    : _domHelper = domHelper ?? DomHelper();

  final DomHelper _domHelper;

  /// Registers this class as the default instance of [FileSelectorPlatform].
  static void registerWith(Registrar registrar) {
    FileSelectorPlatform.instance = FileSelectorWeb();
  }

  @override
  Future<XFile?> openFile({OpenFileDialogOptions options = const OpenFileDialogOptions()}) async {
    final List<XFile> files = await _openFiles(
      options: OpenFilesDialogOptions(
        initialDirectory: options.initialDirectory,
        confirmButtonText: options.confirmButtonText,
        canCreateDirectories: options.canCreateDirectories,
        acceptedTypeGroups: options.acceptedTypeGroups,
      ),
    );
    return files.isNotEmpty ? files.first : null;
  }

  @override
  Future<List<XFile>> openFiles({
    OpenFilesDialogOptions options = const OpenFilesDialogOptions(),
  }) async {
    return _openFiles(options: options, multiple: true);
  }

  @override
  Future<FileSaveLocation?> getSaveLocation({
    SaveLocationOptions options = const SaveLocationOptions(),
  }) async {
    // This is intended to be passed to XFile, which ignores the path, so
    // provide a non-null dummy value.
    return FileSaveLocation(XFile.scopedStorage(uri: ''));
  }

  @override
  Future<XDirectory?> getDirectory({
    GetDirectoryDialogOptions options = const GetDirectoryDialogOptions(),
  }) async => null;

  Future<List<XFile>> _openFiles({
    OpenFilesDialogOptions options = const OpenFilesDialogOptions(),
    bool multiple = false,
  }) async {
    final String accept = acceptedTypesToString(options.acceptedTypeGroups);
    return _domHelper.getFiles(accept: accept, multiple: multiple);
  }
}
