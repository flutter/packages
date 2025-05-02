// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/src/ast.dart';
import 'package:pigeon/src/ast_generator.dart';
import 'package:test/test.dart';

void main() {
  test('gen one class', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'dataType1',
              isNullable: true,
            ),
            name: 'field1'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    generateAst(root, sink);
    final String code = sink.toString();
    expect(code, contains('Foobar'));
    expect(code, contains('dataType1'));
    expect(code, contains('field1'));
  });
}
