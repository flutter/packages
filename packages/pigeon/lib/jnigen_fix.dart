// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

// TODO(tarrinneal): Remove this file when the issue is fixed: https://github.com/dart-lang/native/issues/3235
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

  // Pattern for JList null casts
  final listRegex = RegExp(
    r'(\$o\?\.as<jni\$_\.JList>\([^)]+\)\s+)as (jni\$_\.JList<.*?>);',
  );
  content = content.replaceAllMapped(listRegex, (Match match) {
    return '${match.group(1)}as ${match.group(2)}?;';
  });

  // Pattern for JMap null casts
  final mapRegex = RegExp(
    r'(\$o\?\.as<jni\$_\.JMap>\([^)]+\)\s+)as (jni\$_\.JMap<.*?>);',
  );
  content = content.replaceAllMapped(mapRegex, (Match match) {
    return '${match.group(1)}as ${match.group(2)}?;';
  });

  file.writeAsStringSync(content);
}
