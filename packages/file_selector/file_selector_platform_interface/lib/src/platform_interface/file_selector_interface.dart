// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types/types.dart';

/// The interface that implementations of file_selector must implement.
base class FileSelectorPlatform {
  /// The default instance of [FileSelectorPlatform] to use.
  static FileSelectorPlatform? instance;

  /// Opens a file dialog for loading files and returns a file path.
  ///
  /// Returns `null` if the user cancels the operation.
  Future<XFile?> openFile([OpenDialogOptions options = const OpenDialogOptions()]) {
    throw UnimplementedError('openFile() has not been implemented.');
  }

  /// Opens a file dialog for loading files and returns a list of file paths.
  ///
  /// Returns an empty list if the user cancels the operation.
  Future<List<XFile>> openFiles([OpenDialogOptions options = const OpenDialogOptions()]) {
    throw UnimplementedError('openFiles() has not been implemented.');
  }

  /// Opens a file dialog for saving files and returns a file location at which
  /// to save.
  ///
  /// Returns `null` if the user cancels the operation.
  Future<FileSaveLocation?> getSaveLocation([
    SaveLocationOptions options = const SaveLocationOptions(),
  ]) async {
    throw UnimplementedError('getSaveLocation() has not been implemented.');
  }

  /// Opens a file dialog for loading directories and returns a directory path.
  ///
  /// The `options` argument controls additional settings that can be passed to
  /// file dialog. See [FileDialogOptions] for more details.
  ///
  /// Returns `null` if the user cancels the operation.
  Future<XDirectory?> getDirectory([FileDialogOptions options = const FileDialogOptions()]) {
    throw UnimplementedError('getDirectoryPath() has not been implemented.');
  }

  /// Opens a file dialog for loading directories and returns multiple directory
  /// paths.
  ///
  /// The `options` argument controls additional settings that can be passed to
  /// the file dialog. See [FileDialogOptions] for more details.
  ///
  /// Returns an empty list if the user cancels the operation.
  Future<List<XDirectory>> getDirectories([FileDialogOptions options = const FileDialogOptions()]) {
    throw UnimplementedError('getDirectoryPaths() has not been implemented.');
  }
}
