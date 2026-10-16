// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'src/messages.g.dart';

/// An implementation of [FileSelectorPlatform] for Linux.
base class FileSelectorLinux extends FileSelectorPlatform {
  /// Creates a new plugin implementation instance.
  FileSelectorLinux({@visibleForTesting FileSelectorApi? api})
    : _hostApi = api ?? FileSelectorApi();

  final FileSelectorApi _hostApi;

  /// Registers the Linux implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorLinux();
  }

  @override
  Future<XFile?> openFile([OpenDialogOptions options = const OpenDialogOptions()]) async {
    final List<String> paths = await _hostApi.showFileChooser(
      PlatformFileChooserActionType.open,
      PlatformFileChooserOptions(
        allowedFileTypes: _platformTypeGroupsFromXTypeGroups(options.acceptedTypeGroups),
        currentFolderPath: options.initialDirectory,
        acceptButtonLabel: options.confirmButtonText,
        selectMultiple: false,
      ),
    );
    return paths.isEmpty ? null : XFile.fileSystem(path: paths.first);
  }

  @override
  Future<List<XFile>> openFiles([OpenDialogOptions options = const OpenDialogOptions()]) async {
    final List<String> paths = await _hostApi.showFileChooser(
      PlatformFileChooserActionType.open,
      PlatformFileChooserOptions(
        allowedFileTypes: _platformTypeGroupsFromXTypeGroups(options.acceptedTypeGroups),
        currentFolderPath: options.initialDirectory,
        acceptButtonLabel: options.confirmButtonText,
        selectMultiple: true,
      ),
    );
    return paths.map((String path) => XFile.fileSystem(path: path)).toList();
  }

  @override
  Future<FileSaveLocation?> getSaveLocation([
    SaveLocationOptions options = const SaveLocationOptions(),
  ]) async {
    // TODO(stuartmorgan): Add the selected type group here and return it. See
    // https://github.com/flutter/flutter/issues/107093
    final List<String> paths = await _hostApi.showFileChooser(
      PlatformFileChooserActionType.save,
      PlatformFileChooserOptions(
        allowedFileTypes: _platformTypeGroupsFromXTypeGroups(options.acceptedTypeGroups),
        currentFolderPath: options.initialDirectory,
        currentName: options.suggestedName,
        acceptButtonLabel: options.confirmButtonText,
        createFolders: options.canCreateDirectories,
      ),
    );
    return paths.isEmpty ? null : FileSaveLocation(XFile.fileSystem(path: paths.first));
  }

  @override
  Future<XDirectory?> getDirectory([FileDialogOptions options = const FileDialogOptions()]) async {
    final List<String> paths = await _hostApi.showFileChooser(
      PlatformFileChooserActionType.chooseDirectory,
      PlatformFileChooserOptions(
        currentFolderPath: options.initialDirectory,
        acceptButtonLabel: options.confirmButtonText,
        createFolders: options.canCreateDirectories,
        selectMultiple: false,
      ),
    );
    return paths.isEmpty ? null : XDirectory.fileSystem(path: paths.first);
  }

  @override
  Future<List<XDirectory>> getDirectories([
    FileDialogOptions options = const FileDialogOptions(),
  ]) async {
    final List<String> paths = await _hostApi.showFileChooser(
      PlatformFileChooserActionType.chooseDirectory,
      PlatformFileChooserOptions(
        currentFolderPath: options.initialDirectory,
        acceptButtonLabel: options.confirmButtonText,
        createFolders: options.canCreateDirectories,
        selectMultiple: true,
      ),
    );
    return paths.map((String path) => XDirectory.fileSystem(path: path)).toList();
  }
}

List<PlatformTypeGroup>? _platformTypeGroupsFromXTypeGroups(List<XTypeGroup>? groups) {
  return groups?.map(_platformTypeGroupFromXTypeGroup).toList();
}

PlatformTypeGroup _platformTypeGroupFromXTypeGroup(XTypeGroup group) {
  final String label = group.label ?? '';
  if (group.allowsAny) {
    return PlatformTypeGroup(label: label, extensions: <String>['*']);
  }
  if ((group.extensions?.isEmpty ?? true) && (group.mimeTypes?.isEmpty ?? true)) {
    throw ArgumentError(
      'Provided type group $group does not allow '
      'all files, but does not set any of the Linux-supported filter '
      'categories. "extensions" or "mimeTypes" must be non-empty for Linux '
      'if anything is non-empty.',
    );
  }
  return PlatformTypeGroup(
    label: label,
    // Covert to GtkFileFilter's *.<extension> format.
    extensions: group.extensions?.map((String extension) => '*.$extension').toList() ?? <String>[],
    mimeTypes: group.mimeTypes ?? <String>[],
  );
}
