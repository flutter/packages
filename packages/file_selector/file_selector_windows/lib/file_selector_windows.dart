// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'src/messages.g.dart';

/// An implementation of [FileSelectorPlatform] for Windows.
base class FileSelectorWindows extends FileSelectorPlatform {
  /// Creates a new plugin implementation instance.
  FileSelectorWindows({@visibleForTesting FileSelectorApi? api})
    : _hostApi = api ?? FileSelectorApi();

  final FileSelectorApi _hostApi;

  /// Registers the Windows implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorWindows();
  }

  @override
  Future<XFile?> openFile([OpenDialogOptions options = const OpenDialogOptions()]) async {
    final FileDialogResult result = await _hostApi.showOpenDialog(
      SelectionOptions(allowedTypes: _typeGroupsFromXTypeGroups(options.acceptedTypeGroups)),
      options.initialDirectory,
      options.confirmButtonText,
    );
    return result.paths.isEmpty ? null : XFile.fileSystem(path: result.paths.first);
  }

  @override
  Future<List<XFile>> openFiles([OpenDialogOptions options = const OpenDialogOptions()]) async {
    final FileDialogResult result = await _hostApi.showOpenDialog(
      SelectionOptions(
        allowMultiple: true,
        allowedTypes: _typeGroupsFromXTypeGroups(options.acceptedTypeGroups),
      ),
      options.initialDirectory,
      options.confirmButtonText,
    );
    return result.paths.map((String path) => XFile.fileSystem(path: path)).toList();
  }

  @override
  Future<FileSaveLocation?> getSaveLocation([
    SaveLocationOptions options = const SaveLocationOptions(),
  ]) async {
    final FileDialogResult result = await _hostApi.showSaveDialog(
      SelectionOptions(allowedTypes: _typeGroupsFromXTypeGroups(options.acceptedTypeGroups)),
      options.initialDirectory,
      options.suggestedName,
      options.confirmButtonText,
    );
    final int? groupIndex = result.typeGroupIndex;
    return result.paths.isEmpty
        ? null
        : FileSaveLocation(
            XFile.fileSystem(path: result.paths.first),
            activeFilter: groupIndex == null ? null : options.acceptedTypeGroups?[groupIndex],
          );
  }

  @override
  Future<XDirectory?> getDirectory([FileDialogOptions options = const FileDialogOptions()]) async {
    final FileDialogResult result = await _hostApi.showOpenDialog(
      SelectionOptions(selectFolders: true, allowedTypes: <TypeGroup>[]),
      options.initialDirectory,
      options.confirmButtonText,
    );
    return result.paths.isEmpty ? null : XDirectory.fileSystem(path: result.paths.first);
  }

  @override
  Future<List<XDirectory>> getDirectories([
    FileDialogOptions options = const FileDialogOptions(),
  ]) async {
    final FileDialogResult result = await _hostApi.showOpenDialog(
      SelectionOptions(allowMultiple: true, selectFolders: true, allowedTypes: <TypeGroup>[]),
      options.initialDirectory,
      options.confirmButtonText,
    );
    return result.paths.map((String path) => XDirectory.fileSystem(path: path)).toList();
  }
}

List<TypeGroup> _typeGroupsFromXTypeGroups(List<XTypeGroup>? xtypes) {
  return (xtypes ?? <XTypeGroup>[]).map((XTypeGroup xtype) {
    if (!xtype.allowsAny && (xtype.extensions?.isEmpty ?? true)) {
      throw ArgumentError(
        'Provided type group $xtype does not allow '
        'all files, but does not set any of the Windows-supported filter '
        'categories. "extensions" must be non-empty for Windows if '
        'anything is non-empty.',
      );
    }
    return TypeGroup(label: xtype.label ?? '', extensions: xtype.extensions ?? <String>[]);
  }).toList();
}
