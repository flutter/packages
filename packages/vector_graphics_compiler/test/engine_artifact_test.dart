// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
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
}
