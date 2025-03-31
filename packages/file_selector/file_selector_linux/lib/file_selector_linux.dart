// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'src/messages.g.dart';

/// An implementation of [FileSelectorPlatform] for Linux.
class FileSelectorLinux extends FileSelectorPlatform {
  /// Creates a new plugin implementation instance.
  FileSelectorLinux({
    @visibleForTesting FileSelectorApi? api,
  }) : _hostApi = api ?? FileSelectorApi();

  final FileSelectorApi _hostApi;

  /// Registers the Linux implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorLinux();
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String> paths = await _hostApi.showFileChooser(
        PlatformFileChooserActionType.open,
        PlatformFileChooserOptions(
          allowedFileTypes:
              _platformTypeGroupsFromXTypeGroups(acceptedTypeGroups),
          currentFolderPath: initialDirectory,
          acceptButtonLabel: confirmButtonText,
          selectMultiple: false,
        ));
    return paths.isEmpty ? null : XFile(paths.first);
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String> paths = await _hostApi.showFileChooser(
        PlatformFileChooserActionType.open,
        PlatformFileChooserOptions(
          allowedFileTypes:
              _platformTypeGroupsFromXTypeGroups(acceptedTypeGroups),
          currentFolderPath: initialDirectory,
          acceptButtonLabel: confirmButtonText,
          selectMultiple: true,
        ));
    return paths.map((String path) => XFile(path)).toList();
  }

  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
    final FileSaveLocation? location = await getSaveLocation(
        acceptedTypeGroups: acceptedTypeGroups,
        options: SaveDialogOptions(
          initialDirectory: initialDirectory,
          suggestedName: suggestedName,
          confirmButtonText: confirmButtonText,
        ));
    return location?.path;
  }

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async {
    // TODO(stuartmorgan): Add the selected type group here and return it. See
    // https://github.com/flutter/flutter/issues/107093
    final List<String> paths = await _hostApi.showFileChooser(
        PlatformFileChooserActionType.save,
        PlatformFileChooserOptions(
          allowedFileTypes:
              _platformTypeGroupsFromXTypeGroups(acceptedTypeGroups),
          currentFolderPath: options.initialDirectory,
          currentName: options.suggestedName,
          acceptButtonLabel: options.confirmButtonText,
        ));
    return paths.isEmpty ? null : FileSaveLocation(paths.first);
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String> paths = await _hostApi.showFileChooser(
        PlatformFileChooserActionType.chooseDirectory,
        PlatformFileChooserOptions(
          currentFolderPath: initialDirectory,
          acceptButtonLabel: confirmButtonText,
          selectMultiple: false,
        ));
    return paths.isEmpty ? null : paths.first;
  }

  @override
  Future<List<String>> getDirectoryPaths({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return _hostApi.showFileChooser(
        PlatformFileChooserActionType.chooseDirectory,
        PlatformFileChooserOptions(
          currentFolderPath: initialDirectory,
          acceptButtonLabel: confirmButtonText,
          selectMultiple: true,
        ));
  }
}

List<PlatformTypeGroup>? _platformTypeGroupsFromXTypeGroups(
    List<XTypeGroup>? groups) {
  return groups?.map(_platformTypeGroupFromXTypeGroup).toList();
}

PlatformTypeGroup _platformTypeGroupFromXTypeGroup(XTypeGroup group) {
  final String label = group.label ?? '';
  if (group.allowsAny) {
    return PlatformTypeGroup(
      label: label,
      extensions: <String>['*'],
    );
  }
  if ((group.extensions?.isEmpty ?? true) &&
      (group.mimeTypes?.isEmpty ?? true)) {
    throw ArgumentError('Provided type group $group does not allow '
        'all files, but does not set any of the Linux-supported filter '
        'categories. "extensions" or "mimeTypes" must be non-empty for Linux '
        'if anything is non-empty.');
  }
  return PlatformTypeGroup(
      label: label,
      // Covert to GtkFileFilter's *.<extension> format.
      extensions: group.extensions
              ?.map((String extension) => '*.$extension')
              .toList() ??
          <String>[],
      mimeTypes: group.mimeTypes ?? <String>[]);
}
