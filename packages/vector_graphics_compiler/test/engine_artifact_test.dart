// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:cli_util/cli_util.dart' as cli_util;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vector_graphics_compiler/src/engine_artifact.dart';

void main() {
  String? pathOps(Abi abi) => engineArtifactSubpath(
    windowsFile: 'path_ops.dll',
    macOSFile: 'libpath_ops.dylib',
    linuxFile: 'libpath_ops.so',
    abi: abi,
  );

  String? tessellator(Abi abi) => engineArtifactSubpath(
    windowsFile: 'libtessellator.dll',
    macOSFile: 'libtessellator.dylib',
    linuxFile: 'libtessellator.so',
    abi: abi,
  );

  group('engineArtifactSubpath', () {
    group('Windows', () {
      test('windowsX64 -> windows-x64/<file>', () {
        expect(pathOps(Abi.windowsX64), 'windows-x64/path_ops.dll');
        expect(tessellator(Abi.windowsX64), 'windows-x64/libtessellator.dll');
      });

      test('windowsArm64 falls back to windows-x64 (x64 emulation)', () {
        expect(pathOps(Abi.windowsArm64), 'windows-x64/path_ops.dll');
      });
    });

    group('macOS', () {
      test('macosX64 -> darwin-x64/<file>', () {
        expect(pathOps(Abi.macosX64), 'darwin-x64/libpath_ops.dylib');
        expect(tessellator(Abi.macosX64), 'darwin-x64/libtessellator.dylib');
      });

      test('macosArm64 -> darwin-x64/<file>', () {
        expect(pathOps(Abi.macosArm64), 'darwin-x64/libpath_ops.dylib');
      });
    });

    group('Linux', () {
      test('linuxX64 -> linux-x64/<file>', () {
        expect(pathOps(Abi.linuxX64), 'linux-x64/libpath_ops.so');
        expect(tessellator(Abi.linuxX64), 'linux-x64/libtessellator.so');
      });

      test('linuxArm64 -> linux-arm64/<file>', () {
        expect(pathOps(Abi.linuxArm64), 'linux-arm64/libpath_ops.so');
        expect(tessellator(Abi.linuxArm64), 'linux-arm64/libtessellator.so');
      });
    });

    group('unsupported hosts return null', () {
      test('android', () {
        expect(pathOps(Abi.androidArm64), isNull);
      });

      test('iOS', () {
        expect(pathOps(Abi.iosArm64), isNull);
      });

      test('fuchsia', () {
        expect(pathOps(Abi.fuchsiaArm64), isNull);
      });

      test('linuxArm (32-bit)', () {
        expect(pathOps(Abi.linuxArm), isNull);
      });

      test('linuxIA32', () {
        expect(pathOps(Abi.linuxIA32), isNull);
      });

      test('linuxRiscv32', () {
        expect(pathOps(Abi.linuxRiscv32), isNull);
      });

      test('linuxRiscv64', () {
        expect(pathOps(Abi.linuxRiscv64), isNull);
      });

      test('windowsIA32', () {
        expect(pathOps(Abi.windowsIA32), isNull);
      });
    });
  });

  group('resolveFlutterCacheRoot', () {
    late Directory tempDir;
    late Directory flutterRoot;
    late Directory cacheDir;
    late Directory dartSdkDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('vgc_engine_artifact_test_');
      flutterRoot = Directory(p.join(tempDir.path, 'flutter'));
      cacheDir = Directory(p.join(flutterRoot.path, 'bin', 'cache'));
      dartSdkDir = Directory(p.join(cacheDir.path, 'dart-sdk'));
      Directory(p.join(cacheDir.path, 'artifacts', 'engine')).createSync(recursive: true);
      File(p.join(dartSdkDir.path, 'lib', 'libraries.json')).createSync(recursive: true);
      File(p.join(dartSdkDir.path, 'version')).createSync(recursive: true);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('resolves from flutter_tester executable', () {
      final String testerExe = p.join(
        cacheDir.path,
        'artifacts',
        'engine',
        'linux-x64',
        'flutter_tester',
      );
      final Directory? resolved = resolveFlutterCacheRoot(resolvedExecutable: testerExe);
      expect(resolved?.path, cacheDir.path);
    });

    test('resolves from Flutter dart-sdk via cli_util when compiled to AOT binary', () {
      final String aotExe = p.join(
        tempDir.path,
        '.dart_install',
        'bin',
        'vector_graphics_compiler',
      );
      final Directory? resolved = runZoned(
        () => resolveFlutterCacheRoot(resolvedExecutable: aotExe),
        zoneValues: <Object, Object>{
          cli_util.environmentOverridesKey: <String, String>{
            '_DART_RESOLVED_EXECUTABLE': aotExe,
            'FLUTTER_ROOT': flutterRoot.path,
          },
        },
      );
      expect(resolved?.path, cacheDir.path);
    });

    test('resolves via DART_SDK when compiled to AOT binary', () {
      final String aotExe = p.join(tempDir.path, 'bin', 'vector_graphics_compiler');
      final Directory? resolved = runZoned(
        () => resolveFlutterCacheRoot(resolvedExecutable: aotExe),
        zoneValues: <Object, Object>{
          cli_util.environmentOverridesKey: <String, String>{
            '_DART_RESOLVED_EXECUTABLE': aotExe,
            'DART_SDK': dartSdkDir.path,
          },
        },
      );
      expect(resolved?.path, cacheDir.path);
    });

    test('returns null for AOT binary when no Flutter SDK is available', () {
      final String aotExe = p.join(tempDir.path, 'bin', 'vector_graphics_compiler');
      final Directory? resolved = runZoned(
        () => resolveFlutterCacheRoot(resolvedExecutable: aotExe),
        zoneValues: <Object, Object>{
          cli_util.environmentOverridesKey: <String, String>{'_DART_RESOLVED_EXECUTABLE': aotExe},
        },
      );
      expect(resolved, isNull);
    });
  });
}
