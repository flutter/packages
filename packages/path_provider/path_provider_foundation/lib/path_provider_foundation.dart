// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'messages.g.dart';
import 'path_provider_platform_provider.dart';

/// The iOS and macOS implementation of [PathProviderPlatform].
class PathProviderFoundation extends PathProviderPlatform {
  /// Constructor that accepts a testable PathProviderPlatformProvider.
  PathProviderFoundation({
    @visibleForTesting PathProviderPlatformProvider? platform,
  }) : platformProvider = platform ?? PathProviderPlatformProvider();

  /// Helper class to provide the platform.
  final PathProviderPlatformProvider platformProvider;

  final PathProviderApi _pathProvider = PathProviderApi();

  /// Registers this class as the default instance of [PathProviderPlatform]
  static void registerWith() {
    PathProviderPlatform.instance = PathProviderFoundation();
  }

  @override
  Future<String?> getTemporaryPath() {
    return _pathProvider.getDirectoryPath(DirectoryType.temp);
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    final String? path =
        await _pathProvider.getDirectoryPath(DirectoryType.applicationSupport);
    if (path != null) {
      // Ensure the directory exists before returning it, for consistency with
      // other platforms.
      await Directory(path).create(recursive: true);
    }
    return path;
  }

  @override
  Future<String?> getLibraryPath() {
    return _pathProvider.getDirectoryPath(DirectoryType.library);
  }

  @override
  Future<String?> getApplicationDocumentsPath() {
    return _pathProvider.getDirectoryPath(DirectoryType.applicationDocuments);
  }

  @override
  Future<String?> getExternalStoragePath() async {
    throw UnsupportedError(
        'getExternalStoragePath is not supported on this platform');
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    throw UnsupportedError(
        'getExternalCachePaths is not supported on this platform');
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    throw UnsupportedError(
        'getExternalStoragePaths is not supported on this platform');
  }

  @override
  Future<String?> getDownloadsPath() {
    return _pathProvider.getDirectoryPath(DirectoryType.downloads);
  }

  /// Returns the path to the container of the specified App Group.
  /// This is only supported for iOS.
  Future<String?> getContainerPath({required String appGroupIdentifier}) async {
    if (!platformProvider.isIOS) {
      throw UnsupportedError(
          'getContainerPath is not supported on this platform');
    }
    return _pathProvider.getContainerPath(appGroupIdentifier);
  }
}
