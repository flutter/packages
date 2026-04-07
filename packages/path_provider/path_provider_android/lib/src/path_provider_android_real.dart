// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'path_provider.g.dart';

/// The Android implementation of [PathProviderPlatform].
class PathProviderAndroid extends PathProviderPlatform {
  late final Context _applicationContext = androidApplicationContext.as(
    Context.type,
  );

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    PathProviderPlatform.instance = PathProviderAndroid();
  }

  @override
  Future<String?> getTemporaryPath() {
    return getApplicationCachePath();
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return PathUtils.getFilesDir(
      _applicationContext,
    ).toDartString(releaseOriginal: true);
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return PathUtils.getDataDirectory(
      _applicationContext,
    ).toDartString(releaseOriginal: true);
  }

  @override
  Future<String?> getApplicationCachePath() async {
    final File? file = _applicationContext.cacheDir;
    final String? path = file?.path?.toDartString(releaseOriginal: true);
    file?.release();
    return path;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    final File? dir = _applicationContext.getExternalFilesDir(null);
    if (dir != null) {
      final String? path = dir.absolutePath?.toDartString(
        releaseOriginal: true,
      );
      dir.release();
      return path;
    }

    return null;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    final JArray<File?>? files = _applicationContext.externalCacheDirs;
    if (files != null) {
      final List<String> paths = _toStringList(files);
      files.release();
      return paths;
    }

    return null;
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    final JString? directory = type != null
        ? _toNativeStorageDirectory(type)
        : null;
    final JArray<File?>? files = _applicationContext.getExternalFilesDirs(
      directory,
    );
    directory?.release();
    if (files != null) {
      final List<String> paths = _toStringList(files);
      files.release();
      return paths;
    }

    return null;
  }

  @override
  Future<String?> getDownloadsPath() async {
    final List<String>? paths = await getExternalStoragePaths(
      type: StorageDirectory.downloads,
    );
    return paths?.firstOrNull;
  }
}

JString _toNativeStorageDirectory(StorageDirectory directory) {
  switch (directory) {
    case StorageDirectory.music:
      return Environment.DIRECTORY_MUSIC!;
    case StorageDirectory.podcasts:
      return Environment.DIRECTORY_PODCASTS!;
    case StorageDirectory.ringtones:
      return Environment.DIRECTORY_RINGTONES!;
    case StorageDirectory.alarms:
      return Environment.DIRECTORY_ALARMS!;
    case StorageDirectory.notifications:
      return Environment.DIRECTORY_NOTIFICATIONS!;
    case StorageDirectory.pictures:
      return Environment.DIRECTORY_PICTURES!;
    case StorageDirectory.movies:
      return Environment.DIRECTORY_MOVIES!;
    case StorageDirectory.downloads:
      return Environment.DIRECTORY_DOWNLOADS!;
    case StorageDirectory.dcim:
      return Environment.DIRECTORY_DCIM!;
    case StorageDirectory.documents:
      return Environment.DIRECTORY_DOCUMENTS!;
  }
}

List<String> _toStringList(JArray<File?> files) {
  final List<File?> dartList = files.asDart();
  final paths = <String>[];
  for (final file in dartList) {
    if (file != null) {
      final String? path = file.absolutePath?.toDartString(
        releaseOriginal: true,
      );
      if (path != null) {
        paths.add(path);
      }
      file.release();
    }
  }

  return paths;
}
