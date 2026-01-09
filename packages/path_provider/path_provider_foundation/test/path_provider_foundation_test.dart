// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/src/services/binary_messenger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_foundation/messages.g.dart';
import 'package:path_provider_foundation/path_provider_foundation.dart';

void main() {
  group('PathProviderFoundation', () {
    late FakePathProviderApi api;
    // These unit tests use the actual filesystem, since an injectable
    // filesystem would add a runtime dependency to the package, so everything
    // is contained to a temporary directory.
    late Directory testRoot;

    setUp(() async {
      testRoot = Directory.systemTemp.createTempSync();
      api = FakePathProviderApi();
    });

    tearDown(() {
      testRoot.deleteSync(recursive: true);
    });

    test('getTemporaryPath', () async {
      final pathProvider = PathProviderFoundation(pathProviderApi: api);
      final String temporaryPath = p.join(testRoot.path, 'temporary', 'path');
      api.directoryResult = temporaryPath;

      final String? path = await pathProvider.getTemporaryPath();

      expect(api.passedDirectoryType, DirectoryType.temp);
      expect(path, temporaryPath);
    });

    test('getApplicationSupportPath', () async {
      final pathProvider = PathProviderFoundation(pathProviderApi: api);
      final String applicationSupportPath = p.join(
        testRoot.path,
        'application',
        'support',
        'path',
      );
      api.directoryResult = applicationSupportPath;

      final String? path = await pathProvider.getApplicationSupportPath();

      expect(api.passedDirectoryType, DirectoryType.applicationSupport);
      expect(path, applicationSupportPath);
    });

    test(
      'getApplicationSupportPath creates the directory if necessary',
      () async {
        final pathProvider = PathProviderFoundation(pathProviderApi: api);
        final String applicationSupportPath = p.join(
          testRoot.path,
          'application',
          'support',
          'path',
        );
        api.directoryResult = applicationSupportPath;

        final String? path = await pathProvider.getApplicationSupportPath();

        expect(Directory(path!).existsSync(), isTrue);
      },
    );

    test('getLibraryPath', () async {
      final pathProvider = PathProviderFoundation(pathProviderApi: api);
      final String libraryPath = p.join(testRoot.path, 'library', 'path');
      api.directoryResult = libraryPath;

      final String? path = await pathProvider.getLibraryPath();

      expect(api.passedDirectoryType, DirectoryType.library);
      expect(path, libraryPath);
    });

    test('getApplicationDocumentsPath', () async {
      final pathProvider = PathProviderFoundation(pathProviderApi: api);
      final String applicationDocumentsPath = p.join(
        testRoot.path,
        'application',
        'documents',
        'path',
      );
      api.directoryResult = applicationDocumentsPath;

      final String? path = await pathProvider.getApplicationDocumentsPath();

      expect(api.passedDirectoryType, DirectoryType.applicationDocuments);
      expect(path, applicationDocumentsPath);
    });

    test('getApplicationCachePath', () async {
      final pathProvider = PathProviderFoundation(pathProviderApi: api);
      final String applicationCachePath = p.join(
        testRoot.path,
        'application',
        'cache',
        'path',
      );
      api.directoryResult = applicationCachePath;

      final String? path = await pathProvider.getApplicationCachePath();

      expect(api.passedDirectoryType, DirectoryType.applicationCache);
      expect(path, applicationCachePath);
    });

    test(
      'getApplicationCachePath creates the directory if necessary',
      () async {
        final pathProvider = PathProviderFoundation(pathProviderApi: api);
        final String applicationCachePath = p.join(
          testRoot.path,
          'application',
          'cache',
          'path',
        );
        api.directoryResult = applicationCachePath;

        final String? path = await pathProvider.getApplicationCachePath();

        expect(Directory(path!).existsSync(), isTrue);
      },
    );

    test('getDownloadsPath', () async {
      final pathProvider = PathProviderFoundation(pathProviderApi: api);
      final String downloadsPath = p.join(testRoot.path, 'downloads', 'path');
      api.directoryResult = downloadsPath;

      final String? result = await pathProvider.getDownloadsPath();

      expect(api.passedDirectoryType, DirectoryType.downloads);
      expect(result, downloadsPath);
    });

    test('getExternalCachePaths throws', () async {
      final pathProvider = PathProviderFoundation(pathProviderApi: api);
      expect(pathProvider.getExternalCachePaths(), throwsA(isUnsupportedError));
    });

    test('getExternalStoragePath throws', () async {
      final pathProvider = PathProviderFoundation(pathProviderApi: api);
      expect(
        pathProvider.getExternalStoragePath(),
        throwsA(isUnsupportedError),
      );
    });

    test('getExternalStoragePaths throws', () async {
      final pathProvider = PathProviderFoundation(pathProviderApi: api);
      expect(
        pathProvider.getExternalStoragePaths(),
        throwsA(isUnsupportedError),
      );
    });

    test('getContainerPath', () async {
      final pathProvider = PathProviderFoundation(
        pathProviderApi: api,
        platform: FakePlatformProvider(isIOS: true),
      );
      const appGroupIdentifier = 'group.example.test';

      final String containerPath = p.join(testRoot.path, 'container', 'path');
      api.containerResult = containerPath;

      final String? result = await pathProvider.getContainerPath(
        appGroupIdentifier: appGroupIdentifier,
      );

      expect(api.passedAppGroupIdentifier, appGroupIdentifier);
      expect(result, containerPath);
    });

    test('getContainerPath throws on macOS', () async {
      final pathProvider = PathProviderFoundation(
        pathProviderApi: api,
        platform: FakePlatformProvider(isIOS: false),
      );
      expect(
        pathProvider.getContainerPath(appGroupIdentifier: 'group.example.test'),
        throwsA(isUnsupportedError),
      );
    });
  });
}

/// Fake implementation of PathProviderPlatformProvider that returns iOS is true
class FakePlatformProvider implements PathProviderPlatformProvider {
  FakePlatformProvider({required this.isIOS});
  @override
  bool isIOS;
}

class FakePathProviderApi implements PathProviderApi {
  String? directoryResult;
  String? containerResult;

  DirectoryType? passedDirectoryType;
  String? passedAppGroupIdentifier;

  @override
  Future<String?> getDirectoryPath(DirectoryType type) async {
    passedDirectoryType = type;
    return directoryResult;
  }

  @override
  Future<String?> getContainerPath(String appGroupIdentifier) async {
    passedAppGroupIdentifier = appGroupIdentifier;
    return containerResult;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
