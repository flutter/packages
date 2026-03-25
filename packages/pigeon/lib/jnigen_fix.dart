// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// Applies a post-generation patch to fix generic typing bugs in the jnigen output.
/// See specific issue with casting mapped types using older jnigen generators.
void fixJniBindings(String jnigenOutputPath) {
  final file = File(jnigenOutputPath);
  if (!file.existsSync()) {
    // ignore: avoid_print
    print('WARNING: fixJniBindings could not find file: $jnigenOutputPath');
    return;
  }
  String content = file.readAsStringSync();

  final regex = RegExp(
    r'\$o(\??)\.as<(.+?)>\(\s*(jni\$_.[A-Za-z0-9_]+\.type),\s*releaseOriginal:',
  );

  content = content.replaceAllMapped(regex, (Match match) {
    final String? optional = match.group(1);
    final String? type = match.group(2);
    final String? jniType = match.group(3);
    return '\$o$optional.as<$type>(\n      $jniType as jni\$_.JType<$type>,\n      releaseOriginal:';
  });

  file.writeAsStringSync(content);
}
