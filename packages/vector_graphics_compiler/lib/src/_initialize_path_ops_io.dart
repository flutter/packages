// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';
import 'svg/path_ops.dart';

/// Look up the location of the pathops from flutter's artifact cache.
bool initializePathOpsFromFlutterCache() {
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
    executable = 'path_ops.dll';
  } else if (Platform.isMacOS) {
    platform = 'darwin-x64';
    executable = 'libpath_ops.dylib';
  } else if (Platform.isLinux) {
    platform = 'linux-x64';
    executable = 'libpath_ops.so';
  } else {
    print('path_ops not supported on ${Platform.localeName}');
    return false;
  }
  final String pathops =
      '${cacheRoot.path}/artifacts/engine/$platform/$executable';
  if (!File(pathops).existsSync()) {
    print('Could not locate libpathops at $pathops.');
    print('Ensure you are on a supported version of flutter and then run ');
    print('"flutter precache".');
    return false;
  }
  initializeLibPathOps(pathops);
  return true;
}
