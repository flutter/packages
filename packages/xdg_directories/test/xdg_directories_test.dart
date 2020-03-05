// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:mockito/mockito.dart' show Fake;
import 'package:process/process.dart';

import 'package:xdg_directories/xdg_directories.dart' as xdg;

void main() {
  final Map<String, String> fakeEnv = <String, String>{};
  Directory tmpDir;
  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('xdg_test');
    fakeEnv.clear();
    fakeEnv['HOME'] = tmpDir.path;
    fakeEnv['XDG_CACHE_HOME'] = path.join(tmpDir.path, '.test_cache');
    fakeEnv['XDG_CONFIG_DIRS'] = path.join(tmpDir.path, 'etc/test_xdg');
    fakeEnv['XDG_CONFIG_HOME'] = path.join(tmpDir.path, '.test_config');
    fakeEnv['XDG_DATA_DIRS'] = '${path.join(tmpDir.path, 'usr/local/test_share')}:${path.join(tmpDir.path, 'usr/test_share')}';
    fakeEnv['XDG_DATA_HOME'] = path.join(tmpDir.path, '.local/test_share');
    fakeEnv['XDG_RUNTIME_DIR'] = path.join(tmpDir.path, '.local/test_runtime');
    Directory(fakeEnv['XDG_CONFIG_HOME']).createSync(recursive: true);
    Directory(fakeEnv['XDG_CACHE_HOME']).createSync(recursive: true);
    Directory(fakeEnv['XDG_DATA_HOME']).createSync(recursive: true);
    Directory(fakeEnv['XDG_RUNTIME_DIR']).createSync(recursive: true);
    File(path.join(fakeEnv['XDG_CONFIG_HOME'], 'user-dirs.dirs')).writeAsStringSync(r'''
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_VIDEOS_DIR="$HOME/Videos"
''');
    xdg.xdgEnvironmentOverride = (String key) => fakeEnv[key];
  });
  tearDown(() {
    if (tmpDir != null) {
      tmpDir.deleteSync(recursive: true);
    }
    // Stop overriding the environment accessor.
    xdg.xdgEnvironmentOverride = null;
  });
  void expectDirList(List<Directory> values, List<String> expected) {
    final List<String> valueStr = values.map<String>((Directory directory) => directory.path).toList();
    expect(valueStr, orderedEquals(expected));
  }

  test('Default fallback values work', () {
    fakeEnv.clear();
    fakeEnv['HOME'] = tmpDir.path;
    expect(xdg.cacheHome.path, equals(path.join(tmpDir.path, '.cache')));
    expect(xdg.configHome.path, equals(path.join(tmpDir.path, '.config')));
    expect(xdg.dataHome.path, equals(path.join(tmpDir.path, '.local/share')));
    expect(xdg.runtimeDir, isNull);

    expectDirList(xdg.configDirs, <String>['/etc/xdg']);
    expectDirList(xdg.dataDirs, <String>['/usr/local/share', '/usr/share']);
  });
  test('Values pull from environment', () {
    expect(xdg.cacheHome.path, equals(path.join(tmpDir.path, '.test_cache')));
    expect(xdg.configHome.path, equals(path.join(tmpDir.path, '.test_config')));
    expect(xdg.dataHome.path, equals(path.join(tmpDir.path, '.local/test_share')));
    expect(xdg.runtimeDir.path, equals(path.join(tmpDir.path, '.local/test_runtime')));

    expectDirList(xdg.configDirs, <String>[path.join(tmpDir.path, 'etc/test_xdg')]);
    expectDirList(xdg.dataDirs, <String>[
      path.join(tmpDir.path, 'usr/local/test_share'),
      path.join(tmpDir.path, 'usr/test_share'),
    ]);
  });
  test('Can get userDirs', () {
    final Map<String, String> expected = <String, String>{
      'DESKTOP': path.join(tmpDir.path, 'Desktop'),
      'DOCUMENTS': path.join(tmpDir.path, 'Documents'),
      'DOWNLOAD': path.join(tmpDir.path, 'Downloads'),
      'MUSIC': path.join(tmpDir.path, 'Music'),
      'PICTURES': path.join(tmpDir.path, 'Pictures'),
      'PUBLICSHARE': path.join(tmpDir.path, 'Public'),
      'TEMPLATES': path.join(tmpDir.path, 'Templates'),
      'VIDEOS': path.join(tmpDir.path, 'Videos'),
    };
    xdg.xdgProcessManager = FakeProcessManager(expected);
    final Set<String> userDirs = xdg.getUserDirectoryNames();
    expect(userDirs, equals(expected.keys.toSet()));
    for (String key in userDirs) {
      expect(xdg.getUserDirectory(key).path, equals(expected[key]), reason: 'Path $key value not correct');
    }
    xdg.xdgProcessManager = const LocalProcessManager();
  });
  test('Throws StateError when HOME not set', () {
    fakeEnv.clear();
    expect(() {
      xdg.configHome;
    }, throwsStateError);
  });
}

class FakeProcessManager extends Fake implements ProcessManager {
  FakeProcessManager(this.expected);

  Map<String, String> expected;

  @override
  ProcessResult runSync(
    List<dynamic> command, {
    String workingDirectory,
    Map<String, String> environment,
    bool includeParentEnvironment: true,
    bool runInShell: false,
    Encoding stdoutEncoding: systemEncoding,
    Encoding stderrEncoding: systemEncoding,
  }) {
    return ProcessResult(0, 0, expected[command[1]].codeUnits, <int>[]);
  }
}
