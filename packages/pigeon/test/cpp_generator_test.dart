// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/cpp_generator.dart';
import 'package:pigeon/pigeon.dart' show Error;
import 'package:test/test.dart';

void main() {
  test('gen one api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                type: const TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                ),
                name: 'input',
                offset: null)
          ],
          returnType:
              const TypeDeclaration(baseName: 'Output', isNullable: false),
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'output',
            offset: null)
      ])
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader('', const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(code, contains('class Input'));
      expect(code, contains('class Output'));
      expect(code, contains('class Api'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(code, contains('Input::Input()'));
      expect(code, contains('Output::Output'));
      expect(
          code,
          contains(
              'void Api::SetUp(flutter::BinaryMessenger* binary_messenger, Api* api)'));
    }
  });

  test('doesn\'t support nullable fields', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(name: 'Foo', fields: <NamedType>[
          NamedType(
              name: 'foo',
              type: const TypeDeclaration(baseName: 'int', isNullable: false))
        ])
      ],
      enums: <Enum>[],
    );
    final List<Error> errors = validateCpp(const CppOptions(), root);
    expect(errors.length, 1);
    expect(errors[0].message, contains('foo'));
    expect(errors[0].message, contains('Foo'));
  });
}
