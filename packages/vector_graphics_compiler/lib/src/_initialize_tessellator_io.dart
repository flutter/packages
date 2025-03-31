// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';
import 'svg/tessellator.dart';

/// Look up the location of the tessellator from flutter's artifact cache.
bool initializeTessellatorFromFlutterCache() {
  final Directory cacheRoot;
  if (Platform.resolvedExecutable.contains('flutter_tester')) {
    cacheRoot = File(Platform.resolvedExecutable).parent.parent.parent.parent;
  } else if (Platform.resolvedExecutable.contains('dart')) {
    cacheRoot = File(Platform.resolvedExecutable).parent.parent.parent;
  } else {
    print('Unknown executable: ${Platform.resolvedExecutable}');
    return false;
  }

  final String platform;
  final String executable;
  if (Platform.isWindows) {
    platform = 'windows-x64';
    executable = 'libtessellator.dll';
  } else if (Platform.isMacOS) {
    platform = 'darwin-x64';
    executable = 'libtessellator.dylib';
  } else if (Platform.isLinux) {
    platform = 'linux-x64';
    executable = 'libtessellator.so';
  } else {
    print('Tesselation not supported on ${Platform.localeName}');
    return false;
  }
  final String tessellator =
      '${cacheRoot.path}/artifacts/engine/$platform/$executable';
  if (!File(tessellator).existsSync()) {
    print('Could not locate libtessellator at $tessellator.');
    print('Ensure you are on a supported version of flutter and then run ');
    print('"flutter precache".');
    return false;
  }
  initializeLibTesselator(tessellator);
  return true;
}
