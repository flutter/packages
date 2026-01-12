// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/src/ast.dart';
import 'package:pigeon/src/ast_generator.dart';
import 'package:test/test.dart';

void main() {
  test('gen one class', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'dataType1', isNullable: true),
          name: 'field1',
        ),
      ],
    );
    final root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    generateAst(root, sink);
    final code = sink.toString();
    expect(code, contains('Foobar'));
    expect(code, contains('dataType1'));
    expect(code, contains('field1'));
  });
}
