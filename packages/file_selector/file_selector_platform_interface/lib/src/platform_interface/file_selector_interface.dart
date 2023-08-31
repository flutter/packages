// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../file_selector_platform_interface.dart';
import '../method_channel/method_channel_file_selector.dart';

/// The interface that implementations of file_selector must implement.
///
/// Platform implementations should extend this class rather than implement it as `file_selector`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [FileSelectorPlatform] methods.
abstract class FileSelectorPlatform extends PlatformInterface {
  /// Constructs a FileSelectorPlatform.
  FileSelectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FileSelectorPlatform _instance = MethodChannelFileSelector();

  /// The default instance of [FileSelectorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFileSelector].
  static FileSelectorPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FileSelectorPlatform] when they register themselves.
  static set instance(FileSelectorPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Opens a file dialog for loading files and returns a file path.
  ///
  /// Returns `null` if the user cancels the operation.
  // TODO(stuartmorgan): Switch to FileDialogOptions if we ever need to
  // duplicate this to add a parameter.
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) {
    throw UnimplementedError('openFile() has not been implemented.');
  }

  /// Opens a file dialog for loading files and returns a list of file paths.
  ///
  /// Returns an empty list if the user cancels the operation.
  // TODO(stuartmorgan): Switch to FileDialogOptions if we ever need to
  // duplicate this to add a parameter.
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) {
    throw UnimplementedError('openFiles() has not been implemented.');
  }

  /// Opens a file dialog for saving files and returns a file path at which to
  /// save.
  ///
  /// Returns `null` if the user cancels the operation.
  // TODO(stuartmorgan): Switch to FileDialogOptions if we ever need to
  // duplicate this to add a parameter.
  @Deprecated('Use getSaveLocation instead')
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) {
    throw UnimplementedError('getSavePath() has not been implemented.');
  }

  /// Opens a file dialog for saving files and returns a file location at which
  /// to save.
  ///
  /// Returns `null` if the user cancels the operation.
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async {
    final String? path = await getSavePath(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: options.initialDirectory,
      suggestedName: options.suggestedName,
      confirmButtonText: options.confirmButtonText,
    );
    return path == null ? null : FileSaveLocation(path);
  }

  /// Opens a file dialog for loading directories and returns a directory path.
  ///
  /// Returns `null` if the user cancels the operation.
  // TODO(stuartmorgan): Switch to FileDialogOptions if we ever need to
  // duplicate this to add a parameter.
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) {
    throw UnimplementedError('getDirectoryPath() has not been implemented.');
  }

  /// Opens a file dialog for loading directories and returns multiple directory
  /// paths.
  ///
  /// Returns an empty list if the user cancels the operation.
  // TODO(stuartmorgan): Switch to FileDialogOptions if we ever need to
  // duplicate this to add a parameter.
  Future<List<String>> getDirectoryPaths({
    String? initialDirectory,
    String? confirmButtonText,
  }) {
    throw UnimplementedError('getDirectoryPaths() has not been implemented.');
  }
}
