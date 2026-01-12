// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/src/services/binary_messenger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_android/messages.g.dart' as messages;
import 'package:path_provider_android/path_provider_android.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';
const String kApplicationCachePath = 'applicationCachePath';
const String kExternalCachePaths = 'externalCachePaths';
const String kExternalStoragePaths = 'externalStoragePaths';

class _Api implements messages.PathProviderApi {
  bool returnsExternalStoragePaths = true;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      kApplicationDocumentsPath;

  @override
  Future<String?> getApplicationSupportPath() async => kApplicationSupportPath;

  @override
  Future<String?> getApplicationCachePath() async => kApplicationCachePath;

  @override
  Future<List<String>> getExternalCachePaths() async => <String>[
    kExternalCachePaths,
  ];

  @override
  Future<String?> getExternalStoragePath() async => kExternalStoragePaths;

  @override
  Future<List<String>> getExternalStoragePaths(
    messages.StorageDirectory directory,
  ) async {
    return <String>[if (returnsExternalStoragePaths) kExternalStoragePaths];
  }

  @override
  Future<String?> getTemporaryPath() async => kTemporaryPath;

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}

void main() {
  late _Api api;

  group('PathProviderAndroid', () {
    late PathProviderAndroid pathProvider;

    setUp(() async {
      api = _Api();
      pathProvider = PathProviderAndroid(api: api);
    });

    test('getTemporaryPath', () async {
      final String? path = await pathProvider.getTemporaryPath();
      expect(path, kTemporaryPath);
    });

    test('getApplicationSupportPath', () async {
      final String? path = await pathProvider.getApplicationSupportPath();
      expect(path, kApplicationSupportPath);
    });

    test('getApplicationCachePath', () async {
      final String? path = await pathProvider.getApplicationCachePath();
      expect(path, kApplicationCachePath);
    });

    test('getLibraryPath fails', () async {
      try {
        await pathProvider.getLibraryPath();
        fail('should throw UnsupportedError');
      } catch (e) {
        expect(e, isUnsupportedError);
      }
    });

    test('getApplicationDocumentsPath', () async {
      final String? path = await pathProvider.getApplicationDocumentsPath();
      expect(path, kApplicationDocumentsPath);
    });

    test('getExternalCachePaths succeeds', () async {
      final List<String>? result = await pathProvider.getExternalCachePaths();
      expect(result!.length, 1);
      expect(result.first, kExternalCachePaths);
    });

    for (final StorageDirectory? type in <StorageDirectory>[
      ...StorageDirectory.values,
    ]) {
      test('getExternalStoragePaths (type: $type) android succeeds', () async {
        final List<String>? result = await pathProvider.getExternalStoragePaths(
          type: type,
        );
        expect(result!.length, 1);
        expect(result.first, kExternalStoragePaths);
      });
    } // end of for-loop

    test('getDownloadsPath succeeds', () async {
      final String? path = await pathProvider.getDownloadsPath();
      expect(path, kExternalStoragePaths);
    });

    test('getDownloadsPath returns null, when getExternalStoragePaths returns '
        'an empty list', () async {
      api.returnsExternalStoragePaths = false;
      final String? path = await pathProvider.getDownloadsPath();
      expect(path, null);
    });
  });
}
