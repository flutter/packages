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

  test('naming follows style', () {
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
                name: 'someInput',
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
            name: 'inputField',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'outputField',
            offset: null)
      ])
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader('', const CppOptions(), root, sink);
      final String code = sink.toString();
      // Method name and argument names should be adjusted.
      expect(code, contains(' DoSomething(const Input& some_input)'));
      // Getters and setters should use optional getter/setter style.
      expect(code, contains('const std::string& input_field()'));
      expect(
          code, contains('void set_input_field(const std::string& value_arg)'));
      expect(code, contains('const std::string& output_field()'));
      expect(code,
          contains('void set_output_field(const std::string& value_arg)'));
      // Instance variables should be adjusted.
      expect(code, contains('std::string input_field_'));
      expect(code, contains('std::string output_field_'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(code, contains('pointer_input_field'));
      expect(code, contains('Output::output_field()'));
      expect(code,
          contains('Output::set_output_field(const std::string& value_arg)'));
      expect(code, contains('encodable_output_field'));
    }
  });

  test('Spaces before {', () {
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
      expect(code, isNot(contains('){')));
      expect(code, isNot(contains('const{')));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(code, isNot(contains('){')));
      expect(code, isNot(contains('const{')));
    }
  });

  test('include blocks follow style', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: true,
                ),
                name: 'input',
                offset: null)
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader('', const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(code, contains('''
#include <flutter/basic_message_channel.h>
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/standard_message_codec.h>

#include <map>
#include <optional>
#include <string>
'''));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(header: 'a_header.h'), root, sink);
      final String code = sink.toString();
      expect(code, contains('''
#include "a_header.h"

#include <flutter/basic_message_channel.h>
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/standard_message_codec.h>

#include <map>
#include <optional>
#include <string>
'''));
    }
  });

  test('namespaces follows style', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: true,
                ),
                name: 'input',
                offset: null)
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader('', const CppOptions(namespace: 'foo'), root, sink);
      final String code = sink.toString();
      expect(code, contains('namespace foo {'));
      expect(code, contains('}  // namespace foo'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(namespace: 'foo'), root, sink);
      final String code = sink.toString();
      expect(code, contains('namespace foo {'));
      expect(code, contains('}  // namespace foo'));
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

  test('enum argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Bar', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'bar',
              returnType: const TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                    name: 'foo',
                    type: const TypeDeclaration(
                        baseName: 'Foo', isNullable: false))
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[
        Enum(name: 'Foo', members: <String>['one', 'two'])
      ],
    );
    final List<Error> errors = validateCpp(const CppOptions(), root);
    expect(errors.length, 1);
  });
}
