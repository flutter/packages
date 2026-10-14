// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:ffi' show Abi;
import 'dart:io';

import 'engine_artifact.dart';
import 'svg/tessellator.dart';

/// Look up the location of the tessellator from flutter's artifact cache.
bool initializeTessellatorFromFlutterCache() {
  final Directory? cacheRoot = resolveFlutterCacheRoot();
  if (cacheRoot == null) {
    print('Unknown executable: ${Platform.resolvedExecutable}');
    return false;
  }

  final String? subpath = engineArtifactSubpath(
    windowsFile: 'libtessellator.dll',
    macOSFile: 'libtessellator.dylib',
    linuxFile: 'libtessellator.so',
    abi: Abi.current(),
  );
  if (subpath == null) {
    print('Tesselation not supported on ${Abi.current()}');
    return false;
  }
  final tessellator = '${cacheRoot.path}/artifacts/engine/$subpath';
  if (!File(tessellator).existsSync()) {
    print('Could not locate libtessellator at $tessellator.');
    print('Ensure you are on a supported version of flutter and then run ');
    print('"flutter precache".');
    return false;
  }
  initializeLibTesselator(tessellator);
  return true;
}
