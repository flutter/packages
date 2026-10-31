// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:objective_c/objective_c.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'ffi_bindings.g.dart';
import 'foundation_paths.dart';

/// The iOS and macOS implementation of [PathProviderPlatform].
class PathProviderFoundation extends PathProviderPlatform {
  /// Creates the implementation; every argument exists so tests can replace a part of it.
  ///
  /// [platform] says which operating system to act as, [foundationPaths] reads the folders from
  /// Foundation, and [containerURLForSecurityApplicationGroupIdentifier] finds the container of an
  /// app group.
  PathProviderFoundation({
    @visibleForTesting PathProviderPlatformProvider? platform,
    @visibleForTesting FoundationPaths? foundationPaths,
    @visibleForTesting NSURL? Function(NSString)? containerURLForSecurityApplicationGroupIdentifier,
  }) : _platformProvider = platform ?? PathProviderPlatformProvider(),
       _foundationPaths = foundationPaths ?? const FoundationPaths(),
       _containerURLForSecurityApplicationGroupIdentifier =
           containerURLForSecurityApplicationGroupIdentifier ??
           _sharedNSFileManagerContainerURLForSecurityApplicationGroupIdentifier;

  final PathProviderPlatformProvider _platformProvider;
  final FoundationPaths _foundationPaths;
  final NSURL? Function(NSString) _containerURLForSecurityApplicationGroupIdentifier;

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    PathProviderPlatform.instance = PathProviderFoundation();
  }

  @override
  Future<String?> getTemporaryPath() async {
    return _getDirectoryPath(NSSearchPathDirectory.NSCachesDirectory);
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    final String? path = _getDirectoryPath(NSSearchPathDirectory.NSApplicationSupportDirectory);
    if (path != null) {
      // Ensure the directory exists before returning it, for consistency with
      // other platforms.
      await Directory(path).create(recursive: true);
    }
    return path;
  }

  @override
  Future<String?> getLibraryPath() async {
    return _getDirectoryPath(NSSearchPathDirectory.NSLibraryDirectory);
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return _getDirectoryPath(NSSearchPathDirectory.NSDocumentDirectory);
  }

  @override
  Future<String?> getApplicationCachePath() async {
    final String? path = _getDirectoryPath(NSSearchPathDirectory.NSCachesDirectory);
    if (path != null) {
      // Ensure the directory exists before returning it, for consistency with
      // other platforms.
      await Directory(path).create(recursive: true);
    }
    return path;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    throw UnsupportedError('getExternalStoragePath is not supported on this platform');
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    throw UnsupportedError('getExternalCachePaths is not supported on this platform');
  }

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async {
    throw UnsupportedError('getExternalStoragePaths is not supported on this platform');
  }

  @override
  Future<String?> getDownloadsPath() async {
    return _getDirectoryPath(NSSearchPathDirectory.NSDownloadsDirectory);
  }

  /// Returns the path to the container of the specified App Group.
  /// This is only supported for iOS.
  Future<String?> getContainerPath({required String appGroupIdentifier}) async {
    if (!_platformProvider.isIOS) {
      throw UnsupportedError('getContainerPath is not supported on this platform');
    }
    return _containerURLForSecurityApplicationGroupIdentifier(
      NSString(appGroupIdentifier),
    )?.path?.toDartString();
  }

  /// Returns the current user's folder of the given kind, or `null` if there is none.
  ///
  /// Reads through [_foundationPaths] and never through `package:objective_c`, because the first
  /// use of that package opens its native library and blocks the calling isolate for several
  /// milliseconds.
  String? _getDirectoryPath(NSSearchPathDirectory directory) {
    String? path = _foundationPaths.userDirectory(directory);
    if (path != null && _platformProvider.isMacOS) {
      // In a non-sandboxed app, these are shared directories where applications
      // are expected to use their bundle ID as a subdirectory. For
      // non-sandboxed apps, adding the extra path is harmless.
      // This is not done for iOS, for compatibility with older versions of the
      // plugin.
      if (directory == NSSearchPathDirectory.NSApplicationSupportDirectory ||
          directory == NSSearchPathDirectory.NSCachesDirectory) {
        final String? bundleIdentifier = _foundationPaths.mainBundleIdentifier;
        if (bundleIdentifier != null) {
          // Joined by hand so that package:objective_c is not loaded. A trailing
          // slash is dropped first, so the result never contains "//".
          final String folder = path.endsWith('/') ? path.substring(0, path.length - 1) : path;
          path = '$folder/$bundleIdentifier';
        }
      }
    }
    return path;
  }
}

/// Helper class for returning information about the current platform.
@visibleForTesting
class PathProviderPlatformProvider {
  /// Specifies whether the current platform is iOS.
  bool get isIOS => Platform.isIOS;

  /// Specifies whether the current platform is macOS.
  bool get isMacOS => Platform.isMacOS;
}

NSURL? _sharedNSFileManagerContainerURLForSecurityApplicationGroupIdentifier(
  NSString groupIdentifier,
) => NSFileManager.getDefaultManager().containerURLForSecurityApplicationGroupIdentifier(
  groupIdentifier,
);
