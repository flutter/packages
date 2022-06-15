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
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'inputField',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
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
      expect(code, contains('bool input_field()'));
      expect(code, contains('void set_input_field(bool value_arg)'));
      expect(code, contains('bool output_field()'));
      expect(code, contains('void set_output_field(bool value_arg)'));
      // Instance variables should be adjusted.
      expect(code, contains('bool input_field_'));
      expect(code, contains('bool output_field_'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(code, contains('pointer_input_field'));
      expect(code, contains('Output::output_field()'));
      expect(code, contains('Output::set_output_field(bool value_arg)'));
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

  test('data classes handle nullable fields', () {
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
          returnType: const TypeDeclaration.voidDeclaration(),
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: true,
            ),
            name: 'nestedValue',
            offset: null),
      ]),
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: true,
            ),
            name: 'nullableBool',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: true,
            ),
            name: 'nullableInt',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'nullableString',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Nested',
              isNullable: true,
            ),
            name: 'nullableNested',
            offset: null),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader('', const CppOptions(), root, sink);
      final String code = sink.toString();
      // Getters should return const pointers.
      expect(code, contains('const bool* nullable_bool()'));
      expect(code, contains('const int64_t* nullable_int()'));
      expect(code, contains('const std::string* nullable_string()'));
      expect(code, contains('const Nested* nullable_nested()'));
      // Setters should take const pointers.
      expect(code, contains('void set_nullable_bool(const bool* value_arg)'));
      expect(code, contains('void set_nullable_int(const int64_t* value_arg)'));
      // Strings should be string_view rather than string as an argument.
      expect(
          code,
          contains(
              'void set_nullable_string(const std::string_view* value_arg)'));
      expect(
          code, contains('void set_nullable_nested(const Nested* value_arg)'));
      // Setters should have non-null-style variants.
      expect(code, contains('void set_nullable_bool(bool value_arg)'));
      expect(code, contains('void set_nullable_int(int64_t value_arg)'));
      expect(code,
          contains('void set_nullable_string(std::string_view value_arg)'));
      expect(
          code, contains('void set_nullable_nested(const Nested& value_arg)'));
      // Instance variables should be std::optionals.
      expect(code, contains('std::optional<bool> nullable_bool_'));
      expect(code, contains('std::optional<int64_t> nullable_int_'));
      expect(code, contains('std::optional<std::string> nullable_string_'));
      expect(code, contains('std::optional<Nested> nullable_nested_'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(), root, sink);
      final String code = sink.toString();
      // Getters extract optionals.
      expect(code,
          contains('return nullable_bool_ ? &(*nullable_bool_) : nullptr;'));
      expect(code,
          contains('return nullable_int_ ? &(*nullable_int_) : nullptr;'));
      expect(
          code,
          contains(
              'return nullable_string_ ? &(*nullable_string_) : nullptr;'));
      expect(
          code,
          contains(
              'return nullable_nested_ ? &(*nullable_nested_) : nullptr;'));
      // Setters convert to optionals.
      expect(
          code,
          contains('nullable_bool_ = value_arg ? '
              'std::optional<bool>(*value_arg) : std::nullopt;'));
      expect(
          code,
          contains('nullable_int_ = value_arg ? '
              'std::optional<int64_t>(*value_arg) : std::nullopt;'));
      expect(
          code,
          contains('nullable_string_ = value_arg ? '
              'std::optional<std::string>(*value_arg) : std::nullopt;'));
      expect(
          code,
          contains('nullable_nested_ = value_arg ? '
              'std::optional<Nested>(*value_arg) : std::nullopt;'));
      // Serialization handles optionals.
      expect(
          code,
          contains('{flutter::EncodableValue("nullableBool"), '
              'nullable_bool_ ? flutter::EncodableValue(*nullable_bool_) '
              ': flutter::EncodableValue()}'));
      expect(
          code,
          contains('{flutter::EncodableValue("nullableNested"), '
              'nullable_nested_ ? nullable_nested_->ToEncodableMap() '
              ': flutter::EncodableValue()}'));
    }
  });

  test('data classes handle non-nullable fields', () {
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
          returnType: const TypeDeclaration.voidDeclaration(),
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'nestedValue',
            offset: null),
      ]),
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'nonNullableBool',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: false,
            ),
            name: 'nonNullableInt',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: false,
            ),
            name: 'nonNullableString',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Nested',
              isNullable: false,
            ),
            name: 'nonNullableNested',
            offset: null),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader('', const CppOptions(), root, sink);
      final String code = sink.toString();
      // POD getters should return copies references.
      expect(code, contains('bool non_nullable_bool()'));
      expect(code, contains('int64_t non_nullable_int()'));
      // Non-POD getters should return const references.
      expect(code, contains('const std::string& non_nullable_string()'));
      expect(code, contains('const Nested& non_nullable_nested()'));
      // POD setters should take values.
      expect(code, contains('void set_non_nullable_bool(bool value_arg)'));
      expect(code, contains('void set_non_nullable_int(int64_t value_arg)'));
      // Strings should be string_view as an argument.
      expect(code,
          contains('void set_non_nullable_string(std::string_view value_arg)'));
      // Other non-POD setters should take const references.
      expect(code,
          contains('void set_non_nullable_nested(const Nested& value_arg)'));
      // Instance variables should be plain types.
      expect(code, contains('bool non_nullable_bool_;'));
      expect(code, contains('int64_t non_nullable_int_;'));
      expect(code, contains('std::string non_nullable_string_;'));
      expect(code, contains('Nested non_nullable_nested_;'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(), root, sink);
      final String code = sink.toString();
      // Getters just return the value.
      expect(code, contains('return non_nullable_bool_;'));
      expect(code, contains('return non_nullable_int_;'));
      expect(code, contains('return non_nullable_string_;'));
      expect(code, contains('return non_nullable_nested_;'));
      // Setters just assign the value.
      expect(code, contains('non_nullable_bool_ = value_arg;'));
      expect(code, contains('non_nullable_int_ = value_arg;'));
      expect(code, contains('non_nullable_string_ = value_arg;'));
      expect(code, contains('non_nullable_nested_ = value_arg;'));
      // Serialization uses the value directly.
      expect(
          code,
          contains('{flutter::EncodableValue("nonNullableBool"), '
              'flutter::EncodableValue(non_nullable_bool_)}'));
      expect(
          code,
          contains('{flutter::EncodableValue("nonNullableNested"), '
              'non_nullable_nested_.ToEncodableMap()}'));
    }
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
