// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:file/memory.dart';
import 'package:file_testing/file_testing.dart';
import 'package:flutter_migrate/src/base/common.dart';
import 'package:flutter_migrate/src/base/file_system.dart';
import 'package:flutter_migrate/src/base/io.dart';
import 'package:flutter_migrate/src/base/logger.dart';
import 'package:flutter_migrate/src/base/signals.dart';
import 'package:test/fake.dart';

import '../src/common.dart';

class LocalFileSystemFake extends LocalFileSystem {
  LocalFileSystemFake.test({required super.signals}) : super.test();

  @override
  Directory get superSystemTempDirectory => directory('/does_not_exist');
}

void main() {
  group('fsUtils', () {
    late MemoryFileSystem fs;
    late FileSystemUtils fsUtils;

    setUp(() {
      fs = MemoryFileSystem.test();
      fsUtils = FileSystemUtils(
        fileSystem: fs,
      );
    });

    testWithoutContext('getUniqueFile creates a unique file name', () async {
      final File fileA = fsUtils.getUniqueFile(
          fs.currentDirectory, 'foo', 'json')
        ..createSync();
      final File fileB =
          fsUtils.getUniqueFile(fs.currentDirectory, 'foo', 'json');

      expect(fileA.path, '/foo_01.json');
      expect(fileB.path, '/foo_02.json');
    });

    testWithoutContext('getUniqueDirectory creates a unique directory name',
        () async {
      final Directory directoryA =
          fsUtils.getUniqueDirectory(fs.currentDirectory, 'foo')..createSync();
      final Directory directoryB =
          fsUtils.getUniqueDirectory(fs.currentDirectory, 'foo');

      expect(directoryA.path, '/foo_01');
      expect(directoryB.path, '/foo_02');
    });
  });

  group('copyDirectorySync', () {
    /// Test file_systems.copyDirectorySync() using MemoryFileSystem.
    /// Copies between 2 instances of file systems which is also supported by copyDirectorySync().
    testWithoutContext('test directory copy', () async {
      final MemoryFileSystem sourceMemoryFs = MemoryFileSystem.test();
      const String sourcePath = '/some/origin';
      final Directory sourceDirectory =
          await sourceMemoryFs.directory(sourcePath).create(recursive: true);
      sourceMemoryFs.currentDirectory = sourcePath;
      final File sourceFile1 = sourceMemoryFs.file('some_file.txt')
        ..writeAsStringSync('bleh');
      final DateTime writeTime = sourceFile1.lastModifiedSync();
      sourceMemoryFs
          .file('sub_dir/another_file.txt')
          .createSync(recursive: true);
      sourceMemoryFs.directory('empty_directory').createSync();

      // Copy to another memory file system instance.
      final MemoryFileSystem targetMemoryFs = MemoryFileSystem.test();
      const String targetPath = '/some/non-existent/target';
      final Directory targetDirectory = targetMemoryFs.directory(targetPath);

      copyDirectory(sourceDirectory, targetDirectory);

      expect(targetDirectory.existsSync(), true);
      targetMemoryFs.currentDirectory = targetPath;
      expect(targetMemoryFs.directory('empty_directory').existsSync(), true);
      expect(
          targetMemoryFs.file('sub_dir/another_file.txt').existsSync(), true);
      expect(targetMemoryFs.file('some_file.txt').readAsStringSync(), 'bleh');

      // Assert that the copy operation hasn't modified the original file in some way.
      expect(
          sourceMemoryFs.file('some_file.txt').lastModifiedSync(), writeTime);
      // There's still 3 things in the original directory as there were initially.
      expect(sourceMemoryFs.directory(sourcePath).listSync().length, 3);
    });

    testWithoutContext('Skip files if shouldCopyFile returns false', () {
      final MemoryFileSystem fileSystem = MemoryFileSystem.test();
      final Directory origin = fileSystem.directory('/origin');
      origin.createSync();
      fileSystem
          .file(fileSystem.path.join('origin', 'a.txt'))
          .writeAsStringSync('irrelevant');
      fileSystem.directory('/origin/nested').createSync();
      fileSystem
          .file(fileSystem.path.join('origin', 'nested', 'a.txt'))
          .writeAsStringSync('irrelevant');
      fileSystem
          .file(fileSystem.path.join('origin', 'nested', 'b.txt'))
          .writeAsStringSync('irrelevant');

      final Directory destination = fileSystem.directory('/destination');
      copyDirectory(origin, destination,
          shouldCopyFile: (File origin, File dest) {
        return origin.basename == 'b.txt';
      });

      expect(destination.existsSync(), isTrue);
      expect(destination.childDirectory('nested').existsSync(), isTrue);
      expect(
          destination.childDirectory('nested').childFile('b.txt').existsSync(),
          isTrue);

      expect(destination.childFile('a.txt').existsSync(), isFalse);
      expect(
          destination.childDirectory('nested').childFile('a.txt').existsSync(),
          isFalse);
    });

    testWithoutContext('Skip directories if shouldCopyDirectory returns false',
        () {
      final MemoryFileSystem fileSystem = MemoryFileSystem.test();
      final Directory origin = fileSystem.directory('/origin');
      origin.createSync();
      fileSystem
          .file(fileSystem.path.join('origin', 'a.txt'))
          .writeAsStringSync('irrelevant');
      fileSystem.directory('/origin/nested').createSync();
      fileSystem
          .file(fileSystem.path.join('origin', 'nested', 'a.txt'))
          .writeAsStringSync('irrelevant');
      fileSystem
          .file(fileSystem.path.join('origin', 'nested', 'b.txt'))
          .writeAsStringSync('irrelevant');

      final Directory destination = fileSystem.directory('/destination');
      copyDirectory(origin, destination,
          shouldCopyDirectory: (Directory directory) {
        return !directory.path.endsWith('nested');
      });

      expect(destination, exists);
      expect(destination.childDirectory('nested'), isNot(exists));
      expect(destination.childDirectory('nested').childFile('b.txt'),
          isNot(exists));
    });
  });

  group('LocalFileSystem', () {
    late FakeProcessSignal fakeSignal;
    late ProcessSignal signalUnderTest;

    setUp(() {
      fakeSignal = FakeProcessSignal();
      signalUnderTest = ProcessSignal(fakeSignal);
    });

    testWithoutContext('runs shutdown hooks', () async {
      final Signals signals = Signals.test();
      final LocalFileSystem localFileSystem = LocalFileSystem.test(
        signals: signals,
      );
      final Directory temp = localFileSystem.systemTempDirectory;

      expect(temp.existsSync(), isTrue);
      expect(localFileSystem.shutdownHooks.registeredHooks, hasLength(1));
      final BufferLogger logger = BufferLogger.test();
      await localFileSystem.shutdownHooks.runShutdownHooks(logger);
      expect(temp.existsSync(), isFalse);
      expect(logger.traceText, contains('Running 1 shutdown hook'));
    });

    testWithoutContext('deletes system temp entry on a fatal signal', () async {
      final Completer<void> completer = Completer<void>();
      final Signals signals = Signals.test();
      final LocalFileSystem localFileSystem = LocalFileSystem.test(
        signals: signals,
        fatalSignals: <ProcessSignal>[signalUnderTest],
      );
      final Directory temp = localFileSystem.systemTempDirectory;

      signals.addHandler(signalUnderTest, (ProcessSignal s) {
        completer.complete();
      });

      expect(temp.existsSync(), isTrue);

      fakeSignal.controller.add(fakeSignal);
      await completer.future;

      expect(temp.existsSync(), isFalse);
    });

    testWithoutContext('throwToolExit when temp not found', () async {
      final Signals signals = Signals.test();
      final LocalFileSystemFake localFileSystem = LocalFileSystemFake.test(
        signals: signals,
      );

      try {
        localFileSystem.systemTempDirectory;
        fail('expected tool exit');
      } on ToolExit catch (e) {
        expect(
            e.message,
            'Your system temp directory (/does_not_exist) does not exist. '
            'Did you set an invalid override in your environment? '
            'See issue https://github.com/flutter/flutter/issues/74042 for more context.');
      }
    });
  });
}

class FakeProcessSignal extends Fake implements io.ProcessSignal {
  final StreamController<io.ProcessSignal> controller =
      StreamController<io.ProcessSignal>();

  @override
  Stream<io.ProcessSignal> watch() => controller.stream;
}

/// Various convenience file system methods.
class FileSystemUtils {
  FileSystemUtils({
    required FileSystem fileSystem,
  }) : _fileSystem = fileSystem;

  final FileSystem _fileSystem;

  /// Appends a number to a filename in order to make it unique under a
  /// directory.
  File getUniqueFile(Directory dir, String baseName, String ext) {
    final FileSystem fs = dir.fileSystem;
    int i = 1;

    while (true) {
      final String name = '${baseName}_${i.toString().padLeft(2, '0')}.$ext';
      final File file = fs.file(dir.fileSystem.path.join(dir.path, name));
      if (!file.existsSync()) {
        file.createSync(recursive: true);
        return file;
      }
      i += 1;
    }
  }

  // /// Appends a number to a filename in order to make it unique under a
  // /// directory.
  // File getUniqueFile(Directory dir, String baseName, String ext) {
  //   return _getUniqueFile(dir, baseName, ext);
  // }

  /// Appends a number to a directory name in order to make it unique under a
  /// directory.
  Directory getUniqueDirectory(Directory dir, String baseName) {
    final FileSystem fs = dir.fileSystem;
    int i = 1;

    while (true) {
      final String name = '${baseName}_${i.toString().padLeft(2, '0')}';
      final Directory directory =
          fs.directory(_fileSystem.path.join(dir.path, name));
      if (!directory.existsSync()) {
        return directory;
      }
      i += 1;
    }
  }
}

/// Creates `destDir` if needed, then recursively copies `srcDir` to
/// `destDir`, invoking [onFileCopied], if specified, for each
/// source/destination file pair.
///
/// Skips files if [shouldCopyFile] returns `false`.
/// Does not recurse over directories if [shouldCopyDirectory] returns `false`.
void copyDirectory(
  Directory srcDir,
  Directory destDir, {
  bool Function(File srcFile, File destFile)? shouldCopyFile,
  bool Function(Directory)? shouldCopyDirectory,
  void Function(File srcFile, File destFile)? onFileCopied,
}) {
  if (!srcDir.existsSync()) {
    throw Exception(
        'Source directory "${srcDir.path}" does not exist, nothing to copy');
  }

  if (!destDir.existsSync()) {
    destDir.createSync(recursive: true);
  }

  for (final FileSystemEntity entity in srcDir.listSync()) {
    final String newPath =
        destDir.fileSystem.path.join(destDir.path, entity.basename);
    if (entity is Link) {
      final Link newLink = destDir.fileSystem.link(newPath);
      newLink.createSync(entity.targetSync());
    } else if (entity is File) {
      final File newFile = destDir.fileSystem.file(newPath);
      if (shouldCopyFile != null && !shouldCopyFile(entity, newFile)) {
        continue;
      }
      newFile.writeAsBytesSync(entity.readAsBytesSync());
      onFileCopied?.call(entity, newFile);
    } else if (entity is Directory) {
      if (shouldCopyDirectory != null && !shouldCopyDirectory(entity)) {
        continue;
      }
      copyDirectory(
        entity,
        destDir.fileSystem.directory(newPath),
        shouldCopyFile: shouldCopyFile,
        onFileCopied: onFileCopied,
      );
    } else {
      throw Exception(
          '${entity.path} is neither File nor Directory, was ${entity.runtimeType}');
    }
  }
}
