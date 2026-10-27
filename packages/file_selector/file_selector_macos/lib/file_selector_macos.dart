// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'src/messages.g.dart';

/// An implementation of [FileSelectorPlatform] for macOS.
base class FileSelectorMacOS extends FileSelectorPlatform {
  /// Creates a new plugin implementation instance.
  FileSelectorMacOS({@visibleForTesting FileSelectorApi? api})
    : _hostApi = api ?? FileSelectorApi();

  final FileSelectorApi _hostApi;

  /// Registers the macOS implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorMacOS();
  }

  @override
  Future<XFile?> openFile({OpenFileDialogOptions options = const OpenFileDialogOptions()}) async {
    final List<String> paths = await _hostApi.displayOpenPanel(
      OpenPanelOptions(
        allowsMultipleSelection: false,
        canChooseDirectories: false,
        canChooseFiles: true,
        baseOptions: SavePanelOptions(
          allowedFileTypes: _allowedTypesFromTypeGroups(options.acceptedTypeGroups),
          directoryPath: options.initialDirectory,
          prompt: options.confirmButtonText,
        ),
      ),
    );
    return paths.isEmpty ? null : _toXFile(paths.single);
  }

  @override
  Future<List<XFile>> openFiles({
    OpenFilesDialogOptions options = const OpenFilesDialogOptions(),
  }) async {
    final List<String> paths = await _hostApi.displayOpenPanel(
      OpenPanelOptions(
        allowsMultipleSelection: true,
        canChooseDirectories: false,
        canChooseFiles: true,
        baseOptions: SavePanelOptions(
          allowedFileTypes: _allowedTypesFromTypeGroups(options.acceptedTypeGroups),
          directoryPath: options.initialDirectory,
          prompt: options.confirmButtonText,
        ),
      ),
    );
    return paths.map((String path) => _toXFile(path)).toList();
  }

  @override
  Future<FileSaveLocation?> getSaveLocation({
    SaveLocationOptions options = const SaveLocationOptions(),
  }) async {
    final String? uri = await _hostApi.displaySavePanel(
      SavePanelOptions(
        allowedFileTypes: _allowedTypesFromTypeGroups(options.acceptedTypeGroups),
        directoryPath: options.initialDirectory,
        nameFieldStringValue: options.suggestedName,
        prompt: options.confirmButtonText,
        canCreateDirectories: options.canCreateDirectories,
      ),
    );
    return uri == null ? null : FileSaveLocation(_toXFile(uri));
  }

  @override
  Future<XDirectory?> getDirectory({
    GetDirectoryDialogOptions options = const GetDirectoryDialogOptions(),
  }) async {
    final List<String> uris = await _hostApi.displayOpenPanel(
      OpenPanelOptions(
        allowsMultipleSelection: false,
        canChooseDirectories: true,
        canChooseFiles: false,
        baseOptions: SavePanelOptions(
          directoryPath: options.initialDirectory,
          prompt: options.confirmButtonText,
          canCreateDirectories: options.canCreateDirectories,
        ),
      ),
    );
    return uris.isEmpty ? null : _toXDirectory(uris.single);
  }

  @override
  Future<List<XDirectory>> getDirectories({
    GetDirectoriesDialogOptions options = const GetDirectoriesDialogOptions(),
  }) async {
    final List<String> uris = await _hostApi.displayOpenPanel(
      OpenPanelOptions(
        allowsMultipleSelection: true,
        canChooseDirectories: true,
        canChooseFiles: false,
        baseOptions: SavePanelOptions(
          directoryPath: options.initialDirectory,
          prompt: options.confirmButtonText,
          canCreateDirectories: options.canCreateDirectories,
        ),
      ),
    );
    return uris.map((String uri) => _toXDirectory(uri)).toList();
  }

  // Converts the type group list into a flat list of all allowed types, since
  // macOS doesn't support filter groups.
  AllowedTypes? _allowedTypesFromTypeGroups(List<XTypeGroup>? typeGroups) {
    if (typeGroups == null || typeGroups.isEmpty) {
      return null;
    }
    final allowedTypes = AllowedTypes(
      extensions: <String>[],
      mimeTypes: <String>[],
      utis: <String>[],
    );
    for (final XTypeGroup typeGroup in typeGroups) {
      // If any group allows everything, no filtering should be done.
      if (typeGroup.allowsAny) {
        return null;
      }
      // Reject a filter that isn't an allow-any, but doesn't set any
      // macOS-supported filter categories.
      if ((typeGroup.extensions?.isEmpty ?? true) &&
          (typeGroup.uniformTypeIdentifiers?.isEmpty ?? true) &&
          (typeGroup.mimeTypes?.isEmpty ?? true)) {
        throw ArgumentError(
          'Provided type group $typeGroup does not allow '
          'all files, but does not set any of the macOS-supported filter '
          'categories. At least one of "extensions", '
          '"uniformTypeIdentifiers", or "mimeTypes" must be non-empty for '
          'macOS if anything is non-empty.',
        );
      }
      allowedTypes.extensions.addAll(typeGroup.extensions ?? <String>[]);
      allowedTypes.mimeTypes.addAll(typeGroup.mimeTypes ?? <String>[]);
      allowedTypes.utis.addAll(typeGroup.uniformTypeIdentifiers ?? <String>[]);
    }

    return allowedTypes;
  }

  XFile _toXFile(String uri) {
    // Uses scoped storage if the app is sandboxed because apps are expected
    // to revoke access to the resource with `dispose`. See
    // https://developer.apple.com/documentation/Security/accessing-files-from-the-macos-app-sandbox#Access-files-with-standard-user-interactions
    if (_isAppSandboxMode()) {
      return XFile.scopedStorage(uri: uri);
    }
    return XFile.fileSystem(path: uri);
  }

  XDirectory _toXDirectory(String uri) {
    // Uses scoped storage if the app is sandboxed because apps are expected
    // to revoke access to the resource with `dispose`. See
    // https://developer.apple.com/documentation/Security/accessing-files-from-the-macos-app-sandbox#Access-files-with-standard-user-interactions
    if (_isAppSandboxMode()) {
      return XDirectory.scopedStorage(uri: uri);
    }
    return XDirectory.fileSystem(path: uri);
  }

  // Checks whether the app is sandboxed by checking for the container id.
  bool _isAppSandboxMode() {
    return Platform.environment.containsKey('APP_SANDBOX_CONTAINER_ID');
  }
}
