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
  Future<XFile?> openFile([OpenDialogOptions options = const OpenDialogOptions()]) async {
    final List<XFile> files = await _openFiles(options: options);
    return files.isNotEmpty ? files.first : null;
  }

  @override
  Future<List<XFile>> openFiles([OpenDialogOptions options = const OpenDialogOptions()]) async {
    return _openFiles(options: options, multiple: true);
  }

  @override
  Future<XDirectory?> getDirectoryPath([
    FileDialogOptions options = const FileDialogOptions(),
  ]) async => null;

  Future<List<XFile>> _openFiles({
    OpenDialogOptions options = const OpenDialogOptions(),
    bool multiple = false,
  }) async {
    final String accept = acceptedTypesToString(options.acceptedTypeGroups);
    return _domHelper.getFiles(accept: accept, multiple: multiple);
  }
}
