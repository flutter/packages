// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:jni/jni.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'src/third_party/path_provider.g.dart';

/// The Android implementation of [PathProviderPlatform].
class PathProviderAndroid extends PathProviderPlatform {
  late final Context _applicationContext = Context.fromReference(
    Jni.getCachedApplicationContext(),
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
    return PathUtils.getFilesDir(_applicationContext)
        .toDartString(releaseOriginal: true);
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return PathUtils.getDataDirectory(_applicationContext)
        .toDartString(releaseOriginal: true);
  }

  @override
  Future<String?> getApplicationCachePath() async {
    final File? file = _applicationContext.getCacheDir();
    final String? path = file?.getPath()?.toDartString(releaseOriginal: true);
    file?.release();
    return path;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    final File? dir = _applicationContext.getExternalFilesDir(null);
    if (dir != null) {
      final String? path =
          dir.getAbsolutePath()?.toDartString(releaseOriginal: true);
      dir.release();
      return path;
    }

    return null;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    final JArray<File?>? files = _applicationContext.getExternalCacheDirs();
    if (files != null) {
      return _toStringList(files);
    }

    return null;
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    final JArray<File?>? files = _applicationContext.getExternalFilesDirs(
      type != null ? _toNativeStorageDirectory(type) : null,
    );
    if (files != null) {
      return _toStringList(files);
    }

    return null;
  }

  @override
  Future<String?> getDownloadsPath() async {
    final List<String>? paths =
        await getExternalStoragePaths(type: StorageDirectory.downloads);
    if (paths != null && paths.isNotEmpty) {
      return paths.first;
    }

    return null;
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
  final List<String> paths = [];
  final Iterator<File?> filesIterator = files.iterator;
  while (filesIterator.moveNext()) {
    final File? file = filesIterator.current;
    if (file != null) {
      final String? path =
          file.getAbsolutePath()?.toDartString(releaseOriginal: true);
      if (path != null) {
        paths.add(path);
      }

      file.release();
    }
  }

  return paths;
}
