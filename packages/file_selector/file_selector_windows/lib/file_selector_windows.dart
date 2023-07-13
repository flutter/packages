// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import 'src/messages.g.dart';

/// An implementation of [FileSelectorPlatform] for Windows.
class FileSelectorWindows extends FileSelectorPlatform {
  final FileSelectorApi _hostApi = FileSelectorApi();

  /// Registers the Windows implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorWindows();
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final FileDialogResult result = await _hostApi.showOpenDialog(
        SelectionOptions(
          allowMultiple: false,
          selectFolders: false,
          allowedTypes: _typeGroupsFromXTypeGroups(acceptedTypeGroups),
        ),
        initialDirectory,
        confirmButtonText);
    return result.paths.isEmpty ? null : XFile(result.paths.first!);
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final FileDialogResult result = await _hostApi.showOpenDialog(
        SelectionOptions(
          allowMultiple: true,
          selectFolders: false,
          allowedTypes: _typeGroupsFromXTypeGroups(acceptedTypeGroups),
        ),
        initialDirectory,
        confirmButtonText);
    return result.paths.map((String? path) => XFile(path!)).toList();
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
    final FileDialogResult result = await _hostApi.showSaveDialog(
        SelectionOptions(
          allowMultiple: false,
          selectFolders: false,
          allowedTypes: _typeGroupsFromXTypeGroups(acceptedTypeGroups),
        ),
        options.initialDirectory,
        options.suggestedName,
        options.confirmButtonText);
    final int? groupIndex = result.typeGroupIndex;
    return result.paths.isEmpty
        ? null
        : FileSaveLocation(result.paths.first!,
            activeFilter:
                groupIndex == null ? null : acceptedTypeGroups?[groupIndex]);
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final FileDialogResult result = await _hostApi.showOpenDialog(
        SelectionOptions(
          allowMultiple: false,
          selectFolders: true,
          allowedTypes: <TypeGroup>[],
        ),
        initialDirectory,
        confirmButtonText);
    return result.paths.isEmpty ? null : result.paths.first!;
  }

  @override
  Future<List<String>> getDirectoryPaths({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final FileDialogResult result = await _hostApi.showOpenDialog(
        SelectionOptions(
          allowMultiple: true,
          selectFolders: true,
          allowedTypes: <TypeGroup>[],
        ),
        initialDirectory,
        confirmButtonText);
    return result.paths.isEmpty ? <String>[] : List<String>.from(result.paths);
  }
}

List<TypeGroup> _typeGroupsFromXTypeGroups(List<XTypeGroup>? xtypes) {
  return (xtypes ?? <XTypeGroup>[]).map((XTypeGroup xtype) {
    if (!xtype.allowsAny && (xtype.extensions?.isEmpty ?? true)) {
      throw ArgumentError('Provided type group $xtype does not allow '
          'all files, but does not set any of the Windows-supported filter '
          'categories. "extensions" must be non-empty for Windows if '
          'anything is non-empty.');
    }
    return TypeGroup(
        label: xtype.label ?? '', extensions: xtype.extensions ?? <String>[]);
  }).toList();
}
