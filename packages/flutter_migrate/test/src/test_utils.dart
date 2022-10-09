// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_migrate/src/base/file_system.dart';
import 'package:flutter_migrate/src/base/io.dart';
import 'package:flutter_migrate/src/base/signals.dart';
import 'package:process/process.dart';

import 'common.dart';

/// The [FileSystem] for the integration test environment.
LocalFileSystem fileSystem =
    LocalFileSystem.test(signals: LocalSignals.instance);

/// The [ProcessManager] for the integration test environment.
const ProcessManager processManager = LocalProcessManager();

/// Creates a temporary directory but resolves any symlinks to return the real
/// underlying path to avoid issues with breakpoints/hot reload.
/// https://github.com/flutter/flutter/pull/21741
Directory createResolvedTempDirectorySync(String prefix) {
  assert(prefix.endsWith('.'));
  final Directory tempDirectory =
      fileSystem.systemTempDirectory.createTempSync('flutter_$prefix');
  return fileSystem.directory(tempDirectory.resolveSymbolicLinksSync());
}

void writeFile(String path, String content,
    {bool writeFutureModifiedDate = false}) {
  final File file = fileSystem.file(path)
    ..createSync(recursive: true)
    ..writeAsStringSync(content, flush: true);
  // Some integration tests on Windows to not see this file as being modified
  // recently enough for the hot reload to pick this change up unless the
  // modified time is written in the future.
  if (writeFutureModifiedDate) {
    file.setLastModifiedSync(DateTime.now().add(const Duration(seconds: 5)));
  }
}

void writePackages(String folder) {
  writeFile(fileSystem.path.join(folder, '.packages'), '''
test:${fileSystem.path.join(fileSystem.currentDirectory.path, 'lib')}/
''');
}

Future<void> getPackages(String folder) async {
  final List<String> command = <String>[
    fileSystem.path.join(getFlutterRoot(), 'bin', 'flutter'),
    'pub',
    'get',
  ];
  final ProcessResult result =
      await processManager.run(command, workingDirectory: folder);
  if (result.exitCode != 0) {
    throw Exception(
        'flutter pub get failed: ${result.stderr}\n${result.stdout}');
  }
}
