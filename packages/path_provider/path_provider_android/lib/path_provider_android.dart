// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'messages.g.dart' as messages;
import 'path_provider_android_jni.dart';

messages.StorageDirectory _convertStorageDirectory(
    StorageDirectory? directory) {
  switch (directory) {
    case null:
      return messages.StorageDirectory.root;
    case StorageDirectory.music:
      return messages.StorageDirectory.music;
    case StorageDirectory.podcasts:
      return messages.StorageDirectory.podcasts;
    case StorageDirectory.ringtones:
      return messages.StorageDirectory.ringtones;
    case StorageDirectory.alarms:
      return messages.StorageDirectory.alarms;
    case StorageDirectory.notifications:
      return messages.StorageDirectory.notifications;
    case StorageDirectory.pictures:
      return messages.StorageDirectory.pictures;
    case StorageDirectory.movies:
      return messages.StorageDirectory.movies;
    case StorageDirectory.downloads:
      return messages.StorageDirectory.downloads;
    case StorageDirectory.dcim:
      return messages.StorageDirectory.dcim;
    case StorageDirectory.documents:
      return messages.StorageDirectory.documents;
  }
}

/// The Android implementation of [PathProviderPlatform].
class PathProviderAndroid extends PathProviderPlatform {
  final messages.PathProviderApi _api = messages.PathProviderApi();

  final PathProviderAndroidJni _jniPlatform = PathProviderAndroidJni();

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    PathProviderPlatform.instance = PathProviderAndroid();
  }

  @override
  Future<String?> getTemporaryPath() {
    return _jniPlatform.getTemporaryPath();
  }

  @override
  Future<String?> getApplicationSupportPath() {
    return _jniPlatform.getApplicationSupportPath();
  }

  @override
  Future<String?> getLibraryPath() {
    throw UnsupportedError('getLibraryPath is not supported on Android');
  }

  @override
  Future<String?> getApplicationDocumentsPath() {
    return _jniPlatform.getApplicationDocumentsPath();
  }

  @override
  Future<String?> getApplicationCachePath() {
    return _jniPlatform.getApplicationCachePath();
  }

  @override
  Future<String?> getExternalStoragePath() {
    return _jniPlatform.getExternalStoragePath();
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return _jniPlatform.getExternalCachePaths();
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return _jniPlatform.getExternalStoragePaths(type: type);
  }

  @override
  Future<String?> getDownloadsPath() async {
    return _jniPlatform.getDownloadsPath();
  }

  Future<List<String>> _getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return _api.getExternalStoragePaths(_convertStorageDirectory(type));
  }
}
