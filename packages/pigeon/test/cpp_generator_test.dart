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
                name: 'input')
          ],
          returnType:
              const TypeDeclaration(baseName: 'Output', isNullable: false),
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'output')
      ])
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
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
                name: 'someInput')
          ],
          returnType:
              const TypeDeclaration(baseName: 'Output', isNullable: false),
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'inputField')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'outputField')
      ])
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
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

  test('FlutterError fields are private with public accessors', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                ),
                name: 'someInput')
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
      final String code = sink.toString();

      expect(
          code.split('\n'),
          containsAllInOrder(<Matcher>[
            contains('class FlutterError {'),
            contains(' public:'),
            contains('  const std::string& code() const { return code_; }'),
            contains(
                '  const std::string& message() const { return message_; }'),
            contains(
                '  const flutter::EncodableValue& details() const { return details_; }'),
            contains(' private:'),
            contains('  std::string code_;'),
            contains('  std::string message_;'),
            contains('  flutter::EncodableValue details_;'),
          ]));
    }
  });

  test('Error field is private with public accessors', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                ),
                name: 'someInput')
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
      final String code = sink.toString();

      expect(
          code.split('\n'),
          containsAllInOrder(<Matcher>[
            contains('class ErrorOr {'),
            contains(' public:'),
            contains('  bool has_error() const {'),
            contains('  const T& value() const {'),
            contains('  const FlutterError& error() const {'),
            contains(' private:'),
            contains('  std::variant<T, FlutterError> v_;'),
          ]));
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
                name: 'input')
          ],
          returnType:
              const TypeDeclaration(baseName: 'Output', isNullable: false),
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'output')
      ])
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
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
                name: 'input')
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
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
      generateCppSource(
          const CppOptions(headerIncludePath: 'a_header.h'), root, sink);
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
                name: 'input')
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(namespace: 'foo'), root, sink);
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
                name: 'someInput')
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
        )
      ])
    ], classes: <Class>[
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: true,
            ),
            name: 'nestedValue'),
      ]),
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: true,
            ),
            name: 'nullableBool'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: true,
            ),
            name: 'nullableInt'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'nullableString'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Nested',
              isNullable: true,
            ),
            name: 'nullableNested'),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
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
          contains('nullable_bool_ ? flutter::EncodableValue(*nullable_bool_) '
              ': flutter::EncodableValue()'));
      expect(
          code,
          contains(
              'nullable_nested_ ? flutter::EncodableValue(nullable_nested_->ToEncodableList()) '
              ': flutter::EncodableValue()'));
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
                name: 'someInput')
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
        )
      ])
    ], classes: <Class>[
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'nestedValue'),
      ]),
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'nonNullableBool'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: false,
            ),
            name: 'nonNullableInt'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: false,
            ),
            name: 'nonNullableString'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Nested',
              isNullable: false,
            ),
            name: 'nonNullableNested'),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
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
      expect(code, contains('flutter::EncodableValue(non_nullable_bool_)'));
      expect(code, contains('non_nullable_nested_.ToEncodableList()'));
    }
  });

  test('host nullable return types map correctly', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'returnNullableBool',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'bool',
            isNullable: true,
          ),
        ),
        Method(
          name: 'returnNullableInt',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'int',
            isNullable: true,
          ),
        ),
        Method(
          name: 'returnNullableString',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'String',
            isNullable: true,
          ),
        ),
        Method(
          name: 'returnNullableList',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'List',
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              )
            ],
            isNullable: true,
          ),
        ),
        Method(
          name: 'returnNullableMap',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'Map',
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              ),
              TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              )
            ],
            isNullable: true,
          ),
        ),
        Method(
          name: 'returnNullableDataClass',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'ReturnData',
            isNullable: true,
          ),
        ),
      ])
    ], classes: <Class>[
      Class(name: 'ReturnData', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'aValue'),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(
          code, contains('ErrorOr<std::optional<bool>> ReturnNullableBool()'));
      expect(code,
          contains('ErrorOr<std::optional<int64_t>> ReturnNullableInt()'));
      expect(
          code,
          contains(
              'ErrorOr<std::optional<std::string>> ReturnNullableString()'));
      expect(
          code,
          contains(
              'ErrorOr<std::optional<flutter::EncodableList>> ReturnNullableList()'));
      expect(
          code,
          contains(
              'ErrorOr<std::optional<flutter::EncodableMap>> ReturnNullableMap()'));
      expect(
          code,
          contains(
              'ErrorOr<std::optional<ReturnData>> ReturnNullableDataClass()'));
    }
  });

  test('host non-nullable return types map correctly', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'returnBool',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'bool',
            isNullable: false,
          ),
        ),
        Method(
          name: 'returnInt',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'int',
            isNullable: false,
          ),
        ),
        Method(
          name: 'returnString',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'String',
            isNullable: false,
          ),
        ),
        Method(
          name: 'returnList',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'List',
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              )
            ],
            isNullable: false,
          ),
        ),
        Method(
          name: 'returnMap',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'Map',
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              ),
              TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              )
            ],
            isNullable: false,
          ),
        ),
        Method(
          name: 'returnDataClass',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration(
            baseName: 'ReturnData',
            isNullable: false,
          ),
        ),
      ])
    ], classes: <Class>[
      Class(name: 'ReturnData', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'aValue'),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(code, contains('ErrorOr<bool> ReturnBool()'));
      expect(code, contains('ErrorOr<int64_t> ReturnInt()'));
      expect(code, contains('ErrorOr<std::string> ReturnString()'));
      expect(code, contains('ErrorOr<flutter::EncodableList> ReturnList()'));
      expect(code, contains('ErrorOr<flutter::EncodableMap> ReturnMap()'));
      expect(code, contains('ErrorOr<ReturnData> ReturnDataClass()'));
    }
  });

  test('host nullable arguments map correctly', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                name: 'aBool',
                type: const TypeDeclaration(
                  baseName: 'bool',
                  isNullable: true,
                )),
            NamedType(
                name: 'anInt',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: true,
                )),
            NamedType(
                name: 'aString',
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: true,
                )),
            NamedType(
                name: 'aList',
                type: const TypeDeclaration(
                  baseName: 'List',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'Object', isNullable: true)
                  ],
                  isNullable: true,
                )),
            NamedType(
                name: 'aMap',
                type: const TypeDeclaration(
                  baseName: 'Map',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: true),
                    TypeDeclaration(baseName: 'Object', isNullable: true),
                  ],
                  isNullable: true,
                )),
            NamedType(
                name: 'anObject',
                type: const TypeDeclaration(
                  baseName: 'ParameterObject',
                  isNullable: true,
                )),
            NamedType(
                name: 'aGenericObject',
                type: const TypeDeclaration(
                  baseName: 'Object',
                  isNullable: true,
                )),
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
        ),
      ])
    ], classes: <Class>[
      Class(name: 'ParameterObject', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'aValue'),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(
          code,
          contains('DoSomething(const bool* a_bool, '
              'const int64_t* an_int, '
              'const std::string* a_string, '
              'const flutter::EncodableList* a_list, '
              'const flutter::EncodableMap* a_map, '
              'const ParameterObject* an_object, '
              'const flutter::EncodableValue* a_generic_object)'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(), root, sink);
      final String code = sink.toString();
      // Most types should just use get_if, since the parameter is a pointer,
      // and get_if will automatically handle null values (since a null
      // EncodableValue will not match the queried type, so get_if will return
      // nullptr).
      expect(
          code,
          contains(
              'const auto* a_bool_arg = std::get_if<bool>(&encodable_a_bool_arg);'));
      expect(
          code,
          contains(
              'const auto* a_string_arg = std::get_if<std::string>(&encodable_a_string_arg);'));
      expect(
          code,
          contains(
              'const auto* a_list_arg = std::get_if<flutter::EncodableList>(&encodable_a_list_arg);'));
      expect(
          code,
          contains(
              'const auto* a_map_arg = std::get_if<flutter::EncodableMap>(&encodable_a_map_arg);'));
      // Ints are complicated since there are two possible pointer types, but
      // the paramter always needs an int64_t*.
      expect(
          code,
          contains(
              'const int64_t an_int_arg_value = encodable_an_int_arg.IsNull() ? 0 : encodable_an_int_arg.LongValue();'));
      expect(
          code,
          contains(
              'const auto* an_int_arg = encodable_an_int_arg.IsNull() ? nullptr : &an_int_arg_value;'));
      // Custom class types require an extra layer of extraction.
      expect(
          code,
          contains(
              'const auto* an_object_arg = &(std::any_cast<const ParameterObject&>(std::get<flutter::CustomEncodableValue>(encodable_an_object_arg)));'));
      // "Object" requires no extraction at all since it has to use
      // EncodableValue directly.
      expect(
          code,
          contains(
              'const auto* a_generic_object_arg = &encodable_a_generic_object_arg;'));
    }
  });

  test('host non-nullable arguments map correctly', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                name: 'aBool',
                type: const TypeDeclaration(
                  baseName: 'bool',
                  isNullable: false,
                )),
            NamedType(
                name: 'anInt',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                )),
            NamedType(
                name: 'aString',
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                )),
            NamedType(
                name: 'aList',
                type: const TypeDeclaration(
                  baseName: 'List',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'Object', isNullable: true)
                  ],
                  isNullable: false,
                )),
            NamedType(
                name: 'aMap',
                type: const TypeDeclaration(
                  baseName: 'Map',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: true),
                    TypeDeclaration(baseName: 'Object', isNullable: true),
                  ],
                  isNullable: false,
                )),
            NamedType(
                name: 'anObject',
                type: const TypeDeclaration(
                  baseName: 'ParameterObject',
                  isNullable: false,
                )),
            NamedType(
                name: 'aGenericObject',
                type: const TypeDeclaration(
                  baseName: 'Object',
                  isNullable: false,
                )),
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
        ),
      ])
    ], classes: <Class>[
      Class(name: 'ParameterObject', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'aValue'),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      generateCppHeader(const CppOptions(), root, sink);
      final String code = sink.toString();
      expect(
          code,
          contains('DoSomething(bool a_bool, '
              'int64_t an_int, '
              'const std::string& a_string, '
              'const flutter::EncodableList& a_list, '
              'const flutter::EncodableMap& a_map, '
              'const ParameterObject& an_object, '
              'const flutter::EncodableValue& a_generic_object)'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateCppSource(const CppOptions(), root, sink);
      final String code = sink.toString();
      // Most types should extract references. Since the type is non-nullable,
      // there's only one possible type.
      expect(
          code,
          contains(
              'const auto& a_bool_arg = std::get<bool>(encodable_a_bool_arg);'));
      expect(
          code,
          contains(
              'const auto& a_string_arg = std::get<std::string>(encodable_a_string_arg);'));
      expect(
          code,
          contains(
              'const auto& a_list_arg = std::get<flutter::EncodableList>(encodable_a_list_arg);'));
      expect(
          code,
          contains(
              'const auto& a_map_arg = std::get<flutter::EncodableMap>(encodable_a_map_arg);'));
      // Ints use a copy since there are two possible reference types, but
      // the paramter always needs an int64_t.
      expect(
          code,
          contains(
            'const int64_t an_int_arg = encodable_an_int_arg.LongValue();',
          ));
      // Custom class types require an extra layer of extraction.
      expect(
          code,
          contains(
              'const auto& an_object_arg = std::any_cast<const ParameterObject&>(std::get<flutter::CustomEncodableValue>(encodable_an_object_arg));'));
      // "Object" requires no extraction at all since it has to use
      // EncodableValue directly.
      expect(
          code,
          contains(
              'const auto& a_generic_object_arg = encodable_a_generic_object_arg;'));
    }
  });

  test('host API argument extraction uses references', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                name: 'anArg',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                )),
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
        ),
      ])
    ], classes: <Class>[], enums: <Enum>[]);

    final StringBuffer sink = StringBuffer();
    generateCppSource(const CppOptions(), root, sink);
    final String code = sink.toString();
    // A bare 'auto' here would create a copy, not a reference, which is
    // ineffecient.
    expect(
        code,
        contains(
            'const auto& args = std::get<flutter::EncodableList>(message);'));
    expect(code, contains('const auto& encodable_an_arg_arg = args.at(0);'));
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
        Enum(name: 'Foo', members: <EnumMember>[
          EnumMember(name: 'one'),
          EnumMember(name: 'two'),
        ])
      ],
    );
    final List<Error> errors = validateCpp(const CppOptions(), root);
    expect(errors.length, 1);
  });

  test('transfers documentation comments', () {
    final List<String> comments = <String>[
      ' api comment',
      ' api method comment',
      ' class comment',
      ' class field comment',
      ' enum comment',
      ' enum member comment',
    ];
    int count = 0;

    final List<String> unspacedComments = <String>['////////'];
    int unspacedCount = 0;

    final Root root = Root(
      apis: <Api>[
        Api(
          name: 'Api',
          location: ApiLocation.flutter,
          documentationComments: <String>[comments[count++]],
          methods: <Method>[
            Method(
              name: 'method',
              returnType: const TypeDeclaration.voidDeclaration(),
              documentationComments: <String>[comments[count++]],
              arguments: <NamedType>[
                NamedType(
                  name: 'field',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: true,
                  ),
                ),
              ],
            )
          ],
        )
      ],
      classes: <Class>[
        Class(
          name: 'class',
          documentationComments: <String>[comments[count++]],
          fields: <NamedType>[
            NamedType(
                documentationComments: <String>[comments[count++]],
                type: const TypeDeclaration(
                    baseName: 'Map',
                    isNullable: true,
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(baseName: 'String', isNullable: true),
                      TypeDeclaration(baseName: 'int', isNullable: true),
                    ]),
                name: 'field1'),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'enum',
          documentationComments: <String>[
            comments[count++],
            unspacedComments[unspacedCount++]
          ],
          members: <EnumMember>[
            EnumMember(
              name: 'one',
              documentationComments: <String>[comments[count++]],
            ),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final StringBuffer sink = StringBuffer();
    generateCppHeader(const CppOptions(headerIncludePath: 'foo'), root, sink);
    final String code = sink.toString();
    for (final String comment in comments) {
      expect(code, contains('//$comment'));
    }
    expect(code, contains('// ///'));
  });

  test('doesnt create codecs if no custom datatypes', () {
    final Root root = Root(
      apis: <Api>[
        Api(
          name: 'Api',
          location: ApiLocation.flutter,
          methods: <Method>[
            Method(
              name: 'method',
              returnType: const TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                  name: 'field',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: true,
                  ),
                ),
              ],
            )
          ],
        )
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    generateCppHeader(const CppOptions(), root, sink);
    final String code = sink.toString();
    expect(code, isNot(contains(' : public flutter::StandardCodecSerializer')));
  });

  test('creates custom codecs if custom datatypes present', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                type: const TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                ),
                name: '')
          ],
          returnType:
              const TypeDeclaration(baseName: 'Output', isNullable: false),
          isAsynchronous: true,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'output')
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateCppHeader(const CppOptions(), root, sink);
    final String code = sink.toString();
    expect(code, contains(' : public flutter::StandardCodecSerializer'));
  });

  test('Does not send unwrapped EncodableLists', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                name: 'aBool',
                type: const TypeDeclaration(
                  baseName: 'bool',
                  isNullable: false,
                )),
            NamedType(
                name: 'anInt',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                )),
            NamedType(
                name: 'aString',
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                )),
            NamedType(
                name: 'aList',
                type: const TypeDeclaration(
                  baseName: 'List',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'Object', isNullable: true)
                  ],
                  isNullable: false,
                )),
            NamedType(
                name: 'aMap',
                type: const TypeDeclaration(
                  baseName: 'Map',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: true),
                    TypeDeclaration(baseName: 'Object', isNullable: true),
                  ],
                  isNullable: false,
                )),
            NamedType(
                name: 'anObject',
                type: const TypeDeclaration(
                  baseName: 'ParameterObject',
                  isNullable: false,
                )),
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
        ),
      ])
    ], classes: <Class>[
      Class(name: 'ParameterObject', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: false,
            ),
            name: 'aValue'),
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateCppSource(const CppOptions(), root, sink);
    final String code = sink.toString();
    expect(code, isNot(contains('reply(wrap')));
    expect(code, contains('reply(flutter::EncodableValue('));
  });

  test('does not keep unowned references in async handlers', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'HostApi', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'noop',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration.voidDeclaration(),
          isAsynchronous: true,
        ),
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                ),
                name: '')
          ],
          returnType:
              const TypeDeclaration(baseName: 'double', isNullable: false),
          isAsynchronous: true,
        ),
      ]),
      Api(name: 'FlutterApi', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'noop',
          arguments: <NamedType>[],
          returnType: const TypeDeclaration.voidDeclaration(),
          isAsynchronous: true,
        ),
        Method(
          name: 'doSomething',
          arguments: <NamedType>[
            NamedType(
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                ),
                name: '')
          ],
          returnType:
              const TypeDeclaration(baseName: 'bool', isNullable: false),
          isAsynchronous: true,
        ),
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateCppSource(const CppOptions(), root, sink);
    final String code = sink.toString();
    // Nothing should be captured by reference for async handlers, since their
    // lifetime is unknown (and expected to be longer than the stack's).
    expect(code, isNot(contains('&reply')));
    expect(code, isNot(contains('&wrapped')));
    // Check for the exact capture format that is currently being used, to
    // ensure that the negative tests above get updated if there are any
    // changes to lambda capture.
    expect(code, contains('[reply]('));
  });
}
