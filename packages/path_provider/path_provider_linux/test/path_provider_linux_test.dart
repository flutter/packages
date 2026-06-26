// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_linux/path_provider_linux.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderLinux.registerWith();

  // These tests use the actual filesystem, since an injectable filesystem
  // would add a runtime dependency to the package, so everything is contained
  // to a temporary directory.
  late Directory testRoot;
  final fakeEnv = <String, String>{};

  setUp(() async {
    testRoot = Directory.systemTemp.createTempSync();
    fakeEnv['XDG_CACHE_HOME'] = p.join(testRoot.path, 'application', 'cache', 'path');
    fakeEnv['XDG_DATA_HOME'] = p.join(testRoot.path, 'application', 'support', 'path');
    xdg.xdgEnvironmentOverride = (String key) => fakeEnv[key];
  });

  tearDown(() {
    fakeEnv.clear();
    testRoot.deleteSync(recursive: true);
  });

  test('registered instance', () {
    expect(PathProviderPlatform.instance, isA<PathProviderLinux>());
  });

  test('getTemporaryPath defaults to TMPDIR', () async {
    final PathProviderPlatform plugin = PathProviderLinux.private(
      environment: <String, String>{'TMPDIR': '/run/user/0/tmp'},
    );
    expect(await plugin.getTemporaryPath(), '/run/user/0/tmp');
  });

  test('getTemporaryPath uses fallback if TMPDIR is empty', () async {
    final PathProviderPlatform plugin = PathProviderLinux.private(
      environment: <String, String>{'TMPDIR': ''},
    );
    expect(await plugin.getTemporaryPath(), '/tmp');
  });

  test('getTemporaryPath uses fallback if TMPDIR is unset', () async {
    final PathProviderPlatform plugin = PathProviderLinux.private(environment: <String, String>{});
    expect(await plugin.getTemporaryPath(), '/tmp');
  });

  test('getApplicationSupportPath', () async {
    final PathProviderPlatform plugin = PathProviderLinux.private(
      executableName: 'path_provider_linux_test_binary',
      applicationId: 'com.example.Test',
    );
    expect(await plugin.getApplicationSupportPath(), '${xdg.dataHome.path}/com.example.Test');
  });

  test('getApplicationSupportPath uses executable name if no application Id', () async {
    final PathProviderPlatform plugin = PathProviderLinux.private(
      executableName: 'path_provider_linux_test_binary',
    );
    expect(
      await plugin.getApplicationSupportPath(),
      '${xdg.dataHome.path}/path_provider_linux_test_binary',
    );
  });

  test(
    'getApplicationSupportPath uses executable name fallback if subdir already exists',
    () async {
      final PathProviderPlatform plugin = PathProviderLinux.private(
        executableName: 'path_provider_linux_test_binary',
        applicationId: 'com.example.Test',
      );
      final executableNameDir = Directory(
        p.join(xdg.dataHome.path, 'path_provider_linux_test_binary'),
      );
      await executableNameDir.create(recursive: true);
      expect(await plugin.getApplicationSupportPath(), executableNameDir.path);
    },
  );

  test('getApplicationDocumentsPath', () async {
    final PathProviderPlatform plugin = PathProviderPlatform.instance;
    expect(await plugin.getApplicationDocumentsPath(), startsWith('/'));
  });

  test('getApplicationCachePath', () async {
    final PathProviderPlatform plugin = PathProviderLinux.private(
      executableName: 'path_provider_linux_test_binary',
      applicationId: 'com.example.Test',
    );
    expect(await plugin.getApplicationCachePath(), '${xdg.cacheHome.path}/com.example.Test');
  });

  test('getApplicationCachePath uses executable name if no application Id', () async {
    final PathProviderPlatform plugin = PathProviderLinux.private(
      executableName: 'path_provider_linux_test_binary',
    );
    expect(
      await plugin.getApplicationCachePath(),
      '${xdg.cacheHome.path}/path_provider_linux_test_binary',
    );
  });

  test('getApplicationCachePath uses executable name fallback if subdir already exists', () async {
    final PathProviderPlatform plugin = PathProviderLinux.private(
      executableName: 'path_provider_linux_test_binary',
      applicationId: 'com.example.Test',
    );
    final executableNameDir = Directory(
      p.join(xdg.cacheHome.path, 'path_provider_linux_test_binary'),
    );
    await executableNameDir.create(recursive: true);
    expect(await plugin.getApplicationCachePath(), executableNameDir.path);
  });

  test('getDownloadsPath', () async {
    final PathProviderPlatform plugin = PathProviderPlatform.instance;
    expect(await plugin.getDownloadsPath(), startsWith('/'));
  });
}
