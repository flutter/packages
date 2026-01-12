// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

/// Writes the AST representation of [root] to [sink].
void generateAst(Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  final String output = root.toString();
  bool isFirst = true;
  for (final int ch in output.runes) {
    final String chStr = String.fromCharCode(ch);
    if (chStr == '(') {
      if (isFirst) {
        isFirst = false;
      } else {
        indent.inc();
        indent.addln('');
        indent.write('');
      }
    } else if (chStr == ')') {
      indent.dec();
    }
    indent.add(chStr);
  }
  indent.addln('');
}
