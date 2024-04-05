// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/cpp_generator.dart';
import 'package:pigeon/generator_tools.dart';
import 'package:pigeon/pigeon.dart' show Error;
import 'package:test/test.dart';

const String DEFAULT_PACKAGE_NAME = 'test_package';

final Class emptyClass = Class(name: 'className', fields: <NamedType>[
  NamedType(
    name: 'namedTypeName',
    type: const TypeDeclaration(baseName: 'baseName', isNullable: false),
  )
]);

final Enum emptyEnum = Enum(
  name: 'enumName',
  members: <EnumMember>[EnumMember(name: 'enumMemberName')],
);

void main() {
  test('gen one api', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
                type: TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                  associatedClass: emptyClass,
                ),
                name: 'input')
          ],
          location: ApiLocation.host,
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
          ),
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(generatorOptions, root, sink,
          dartPackageName: DEFAULT_PACKAGE_NAME);
      final String code = sink.toString();
      expect(code, contains('class Input'));
      expect(code, contains('class Output'));
      expect(code, contains('class Api'));
      expect(code, contains('virtual ~Api() {}\n'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(),
      );
      generator.generate(generatorOptions, root, sink,
          dartPackageName: DEFAULT_PACKAGE_NAME);
      final String code = sink.toString();
      expect(code, contains('Input::Input()'));
      expect(code, contains('Output::Output'));
      expect(
          code,
          contains(RegExp(r'void Api::SetUp\(\s*'
              r'flutter::BinaryMessenger\* binary_messenger,\s*'
              r'Api\* api\s*\)')));
    }
  });

  test('naming follows style', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
                type: TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                  associatedClass: emptyClass,
                ),
                name: 'someInput')
          ],
          location: ApiLocation.host,
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
          ),
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(generatorOptions, root, sink,
          dartPackageName: DEFAULT_PACKAGE_NAME);
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(),
      );
      generator.generate(generatorOptions, root, sink,
          dartPackageName: DEFAULT_PACKAGE_NAME);
      final String code = sink.toString();
      expect(code, contains('encodable_some_input'));
      expect(code, contains('Output::output_field()'));
      expect(code, contains('Output::set_output_field(bool value_arg)'));
    }
  });

  test('FlutterError fields are private with public accessors', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
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
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(generatorOptions, root, sink,
          dartPackageName: DEFAULT_PACKAGE_NAME);
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
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
                type: TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                  associatedClass: emptyClass,
                ),
                name: 'input')
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
          ),
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, isNot(contains('){')));
      expect(code, isNot(contains('const{')));
    }
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, isNot(contains('){')));
      expect(code, isNot(contains('const{')));
    }
  });

  test('include blocks follow style', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(headerIncludePath: 'a_header.h'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
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
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(namespace: 'foo'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('namespace foo {'));
      expect(code, contains('}  // namespace foo'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(namespace: 'foo'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('namespace foo {'));
      expect(code, contains('}  // namespace foo'));
    }
  });

  test('data classes handle nullable fields', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
                type: TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                  associatedClass: emptyClass,
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
            type: TypeDeclaration(
              baseName: 'Nested',
              isNullable: true,
              associatedClass: emptyClass,
            ),
            name: 'nullableNested'),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();

      // There should be a default constructor.
      expect(code, contains('Nested();'));
      // There should be a convenience constructor.
      expect(
          code,
          contains(
              RegExp(r'explicit Nested\(\s*const bool\* nested_value\s*\)')));

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
      // Most instance variables should be std::optionals.
      expect(code, contains('std::optional<bool> nullable_bool_'));
      expect(code, contains('std::optional<int64_t> nullable_int_'));
      expect(code, contains('std::optional<std::string> nullable_string_'));
      // Custom classes are the exception, to avoid inline storage.
      expect(code, contains('std::unique_ptr<Nested> nullable_nested_'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();

      // There should be a default constructor.
      expect(code, contains('Nested::Nested() {}'));
      // There should be a convenience constructor.
      expect(
          code,
          contains(RegExp(r'Nested::Nested\(\s*const bool\* nested_value\s*\)'
              r'\s*:\s*nested_value_\(nested_value \? '
              r'std::optional<bool>\(\*nested_value\) : std::nullopt\)\s*{}')));

      // Getters extract optionals.
      expect(code,
          contains('return nullable_bool_ ? &(*nullable_bool_) : nullptr;'));
      expect(code,
          contains('return nullable_int_ ? &(*nullable_int_) : nullptr;'));
      expect(
          code,
          contains(
              'return nullable_string_ ? &(*nullable_string_) : nullptr;'));
      expect(code, contains('return nullable_nested_.get();'));
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
          contains(
              'nullable_nested_ = value_arg ? std::make_unique<Nested>(*value_arg) : nullptr;'));
      // Serialization handles optionals.
      expect(
          code,
          contains('nullable_bool_ ? EncodableValue(*nullable_bool_) '
              ': EncodableValue()'));
      expect(
          code,
          contains(
              'nullable_nested_ ? EncodableValue(nullable_nested_->ToEncodableList()) '
              ': EncodableValue()'));

      // Serialization should use push_back, not initializer lists, to avoid
      // copies.
      expect(code, contains('list.reserve(4)'));
      expect(
          code,
          contains('list.push_back(nullable_bool_ ? '
              'EncodableValue(*nullable_bool_) : '
              'EncodableValue())'));
    }
  });

  test('data classes handle non-nullable fields', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
                type: TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                  associatedClass: emptyClass,
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
            type: TypeDeclaration(
              baseName: 'Nested',
              isNullable: false,
              associatedClass: emptyClass,
            ),
            name: 'nonNullableNested'),
      ]),
    ], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();

      // There should not be a default constructor.
      expect(code, isNot(contains('Nested();')));
      // There should be a convenience constructor.
      expect(code,
          contains(RegExp(r'explicit Nested\(\s*bool nested_value\s*\)')));

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
      // Except for custom classes.
      expect(code, contains('std::unique_ptr<Nested> non_nullable_nested_;'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();

      // There should not be a default constructor.
      expect(code, isNot(contains('Nested::Nested() {}')));
      // There should be a convenience constructor.
      expect(
          code,
          contains(RegExp(r'Nested::Nested\(\s*bool nested_value\s*\)'
              r'\s*:\s*nested_value_\(nested_value\)\s*{}')));

      // Getters just return the value.
      expect(code, contains('return non_nullable_bool_;'));
      expect(code, contains('return non_nullable_int_;'));
      expect(code, contains('return non_nullable_string_;'));
      // Unless it's a custom class.
      expect(code, contains('return *non_nullable_nested_;'));
      // Setters just assign the value.
      expect(code, contains('non_nullable_bool_ = value_arg;'));
      expect(code, contains('non_nullable_int_ = value_arg;'));
      expect(code, contains('non_nullable_string_ = value_arg;'));
      // Unless it's a custom class.
      expect(
          code,
          contains(
              'non_nullable_nested_ = std::make_unique<Nested>(value_arg);'));
      // Serialization uses the value directly.
      expect(code, contains('EncodableValue(non_nullable_bool_)'));
      expect(code, contains('non_nullable_nested_->ToEncodableList()'));

      // Serialization should use push_back, not initializer lists, to avoid
      // copies.
      expect(code, contains('list.reserve(4)'));
      expect(
          code, contains('list.push_back(EncodableValue(non_nullable_bool_))'));
    }
  });

  test('host nullable return types map correctly', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'returnNullableBool',
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: const TypeDeclaration(
            baseName: 'bool',
            isNullable: true,
          ),
        ),
        Method(
          name: 'returnNullableInt',
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: const TypeDeclaration(
            baseName: 'int',
            isNullable: true,
          ),
        ),
        Method(
          name: 'returnNullableString',
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: const TypeDeclaration(
            baseName: 'String',
            isNullable: true,
          ),
        ),
        Method(
          name: 'returnNullableList',
          location: ApiLocation.host,
          parameters: <Parameter>[],
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
          location: ApiLocation.host,
          parameters: <Parameter>[],
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
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: TypeDeclaration(
            baseName: 'ReturnData',
            isNullable: true,
            associatedClass: emptyClass,
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
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
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'returnBool',
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: const TypeDeclaration(
            baseName: 'bool',
            isNullable: false,
          ),
        ),
        Method(
          name: 'returnInt',
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: const TypeDeclaration(
            baseName: 'int',
            isNullable: false,
          ),
        ),
        Method(
          name: 'returnString',
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: const TypeDeclaration(
            baseName: 'String',
            isNullable: false,
          ),
        ),
        Method(
          name: 'returnList',
          location: ApiLocation.host,
          parameters: <Parameter>[],
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
          location: ApiLocation.host,
          parameters: <Parameter>[],
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
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: TypeDeclaration(
            baseName: 'ReturnData',
            isNullable: false,
            associatedClass: emptyClass,
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
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
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
                name: 'aBool',
                type: const TypeDeclaration(
                  baseName: 'bool',
                  isNullable: true,
                )),
            Parameter(
                name: 'anInt',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: true,
                )),
            Parameter(
                name: 'aString',
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: true,
                )),
            Parameter(
                name: 'aList',
                type: const TypeDeclaration(
                  baseName: 'List',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'Object', isNullable: true)
                  ],
                  isNullable: true,
                )),
            Parameter(
                name: 'aMap',
                type: const TypeDeclaration(
                  baseName: 'Map',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: true),
                    TypeDeclaration(baseName: 'Object', isNullable: true),
                  ],
                  isNullable: true,
                )),
            Parameter(
                name: 'anObject',
                type: TypeDeclaration(
                  baseName: 'ParameterObject',
                  isNullable: true,
                  associatedClass: emptyClass,
                )),
            Parameter(
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(
          code,
          contains(RegExp(r'DoSomething\(\s*'
              r'const bool\* a_bool,\s*'
              r'const int64_t\* an_int,\s*'
              r'const std::string\* a_string,\s*'
              r'const flutter::EncodableList\* a_list,\s*'
              r'const flutter::EncodableMap\* a_map,\s*'
              r'const ParameterObject\* an_object,\s*'
              r'const flutter::EncodableValue\* a_generic_object\s*\)')));
    }
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
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
              'const auto* a_list_arg = std::get_if<EncodableList>(&encodable_a_list_arg);'));
      expect(
          code,
          contains(
              'const auto* a_map_arg = std::get_if<EncodableMap>(&encodable_a_map_arg);'));
      // Ints are complicated since there are two possible pointer types, but
      // the parameter always needs an int64_t*.
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
              'const auto* an_object_arg = &(std::any_cast<const ParameterObject&>(std::get<CustomEncodableValue>(encodable_an_object_arg)));'));
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
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
                name: 'aBool',
                type: const TypeDeclaration(
                  baseName: 'bool',
                  isNullable: false,
                )),
            Parameter(
                name: 'anInt',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                )),
            Parameter(
                name: 'aString',
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                )),
            Parameter(
                name: 'aList',
                type: const TypeDeclaration(
                  baseName: 'List',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'Object', isNullable: true)
                  ],
                  isNullable: false,
                )),
            Parameter(
                name: 'aMap',
                type: const TypeDeclaration(
                  baseName: 'Map',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: true),
                    TypeDeclaration(baseName: 'Object', isNullable: true),
                  ],
                  isNullable: false,
                )),
            Parameter(
                name: 'anObject',
                type: TypeDeclaration(
                  baseName: 'ParameterObject',
                  isNullable: false,
                  associatedClass: emptyClass,
                )),
            Parameter(
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(
          code,
          contains(RegExp(r'DoSomething\(\s*'
              r'bool a_bool,\s*'
              r'int64_t an_int,\s*'
              r'const std::string& a_string,\s*'
              r'const flutter::EncodableList& a_list,\s*'
              r'const flutter::EncodableMap& a_map,\s*'
              r'const ParameterObject& an_object,\s*'
              r'const flutter::EncodableValue& a_generic_object\s*\)')));
    }
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
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
              'const auto& a_list_arg = std::get<EncodableList>(encodable_a_list_arg);'));
      expect(
          code,
          contains(
              'const auto& a_map_arg = std::get<EncodableMap>(encodable_a_map_arg);'));
      // Ints use a copy since there are two possible reference types, but
      // the parameter always needs an int64_t.
      expect(
          code,
          contains(
            'const int64_t an_int_arg = encodable_an_int_arg.LongValue();',
          ));
      // Custom class types require an extra layer of extraction.
      expect(
          code,
          contains(
              'const auto& an_object_arg = std::any_cast<const ParameterObject&>(std::get<CustomEncodableValue>(encodable_an_object_arg));'));
      // "Object" requires no extraction at all since it has to use
      // EncodableValue directly.
      expect(
          code,
          contains(
              'const auto& a_generic_object_arg = encodable_a_generic_object_arg;'));
    }
  });

  test('flutter nullable arguments map correctly', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.flutter,
          parameters: <Parameter>[
            Parameter(
                name: 'aBool',
                type: const TypeDeclaration(
                  baseName: 'bool',
                  isNullable: true,
                )),
            Parameter(
                name: 'anInt',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: true,
                )),
            Parameter(
                name: 'aString',
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: true,
                )),
            Parameter(
                name: 'aList',
                type: const TypeDeclaration(
                  baseName: 'List',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'Object', isNullable: true)
                  ],
                  isNullable: true,
                )),
            Parameter(
                name: 'aMap',
                type: const TypeDeclaration(
                  baseName: 'Map',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: true),
                    TypeDeclaration(baseName: 'Object', isNullable: true),
                  ],
                  isNullable: true,
                )),
            Parameter(
                name: 'anObject',
                type: TypeDeclaration(
                  baseName: 'ParameterObject',
                  isNullable: true,
                  associatedClass: emptyClass,
                )),
            Parameter(
                name: 'aGenericObject',
                type: const TypeDeclaration(
                  baseName: 'Object',
                  isNullable: true,
                )),
          ],
          returnType: const TypeDeclaration(
            baseName: 'bool',
            isNullable: true,
          ),
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      // Nullable arguments should all be pointers. This will make them somewhat
      // awkward for some uses (literals, values that could be inlined) but
      // unlike setters there's no way to provide reference-based alternatives
      // since it's not always just one argument.
      // TODO(stuartmorgan): Consider generating a second variant using
      // `std::optional`s; that may be more ergonomic, but the perf implications
      // would need to be considered.
      expect(
          code,
          contains(RegExp(r'DoSomething\(\s*'
              r'const bool\* a_bool,\s*'
              r'const int64_t\* an_int,\s*'
              // Nullable strings use std::string* rather than std::string_view*
              // since there's no implicit conversion for pointer types.
              r'const std::string\* a_string,\s*'
              r'const flutter::EncodableList\* a_list,\s*'
              r'const flutter::EncodableMap\* a_map,\s*'
              r'const ParameterObject\* an_object,\s*'
              r'const flutter::EncodableValue\* a_generic_object,')));
      // The callback should pass a pointer as well.
      expect(
          code,
          contains(
              RegExp(r'std::function<void\(const bool\*\)>&& on_success,\s*'
                  r'std::function<void\(const FlutterError&\)>&& on_error\)')));
    }
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      // All types pass nulls values when the pointer is null.
      // Standard types are wrapped an EncodableValues.
      expect(
          code,
          contains(
              'a_bool_arg ? EncodableValue(*a_bool_arg) : EncodableValue()'));
      expect(
          code,
          contains(
              'an_int_arg ? EncodableValue(*an_int_arg) : EncodableValue()'));
      expect(
          code,
          contains(
              'a_string_arg ? EncodableValue(*a_string_arg) : EncodableValue()'));
      expect(
          code,
          contains(
              'a_list_arg ? EncodableValue(*a_list_arg) : EncodableValue()'));
      expect(
          code,
          contains(
              'a_map_arg ? EncodableValue(*a_map_arg) : EncodableValue()'));
      // Class types use ToEncodableList.
      expect(
          code,
          contains(
              'an_object_arg ? CustomEncodableValue(*an_object_arg) : EncodableValue()'));
    }
  });

  test('flutter non-nullable arguments map correctly', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.flutter,
          parameters: <Parameter>[
            Parameter(
                name: 'aBool',
                type: const TypeDeclaration(
                  baseName: 'bool',
                  isNullable: false,
                )),
            Parameter(
                name: 'anInt',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                )),
            Parameter(
                name: 'aString',
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                )),
            Parameter(
                name: 'aList',
                type: const TypeDeclaration(
                  baseName: 'List',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'Object', isNullable: true)
                  ],
                  isNullable: false,
                )),
            Parameter(
                name: 'aMap',
                type: const TypeDeclaration(
                  baseName: 'Map',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: true),
                    TypeDeclaration(baseName: 'Object', isNullable: true),
                  ],
                  isNullable: false,
                )),
            Parameter(
                name: 'anObject',
                type: TypeDeclaration(
                  baseName: 'ParameterObject',
                  isNullable: false,
                  associatedClass: emptyClass,
                )),
            Parameter(
                name: 'aGenericObject',
                type: const TypeDeclaration(
                  baseName: 'Object',
                  isNullable: false,
                )),
          ],
          returnType: const TypeDeclaration(
            baseName: 'bool',
            isNullable: false,
          ),
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
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.header,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(
          code,
          contains(RegExp(r'DoSomething\(\s*'
              r'bool a_bool,\s*'
              r'int64_t an_int,\s*'
              // Non-nullable strings use std::string for consistency with
              // nullable strings.
              r'const std::string& a_string,\s*'
              // Non-POD types use const references.
              r'const flutter::EncodableList& a_list,\s*'
              r'const flutter::EncodableMap& a_map,\s*'
              r'const ParameterObject& an_object,\s*'
              r'const flutter::EncodableValue& a_generic_object,\s*')));
      // The callback should pass a value.
      expect(
          code,
          contains(RegExp(r'std::function<void\(bool\)>&& on_success,\s*'
              r'std::function<void\(const FlutterError&\)>&& on_error\s*\)')));
    }
    {
      final StringBuffer sink = StringBuffer();
      const CppGenerator generator = CppGenerator();
      final OutputFileOptions<CppOptions> generatorOptions =
          OutputFileOptions<CppOptions>(
        fileType: FileType.source,
        languageOptions: const CppOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      // Standard types are wrapped an EncodableValues.
      expect(code, contains('EncodableValue(a_bool_arg)'));
      expect(code, contains('EncodableValue(an_int_arg)'));
      expect(code, contains('EncodableValue(a_string_arg)'));
      expect(code, contains('EncodableValue(a_list_arg)'));
      expect(code, contains('EncodableValue(a_map_arg)'));
      // Class types use ToEncodableList.
      expect(code, contains('CustomEncodableValue(an_object_arg)'));
    }
  });

  test('host API argument extraction uses references', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
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
    const CppGenerator generator = CppGenerator();
    final OutputFileOptions<CppOptions> generatorOptions =
        OutputFileOptions<CppOptions>(
      fileType: FileType.source,
      languageOptions: const CppOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    // A bare 'auto' here would create a copy, not a reference, which is
    // inefficient.
    expect(
        code, contains('const auto& args = std::get<EncodableList>(message);'));
    expect(code, contains('const auto& encodable_an_arg_arg = args.at(0);'));
  });

  test('enum argument', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Bar', methods: <Method>[
          Method(
              name: 'bar',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'foo',
                  type: TypeDeclaration(
                    baseName: 'Foo',
                    isNullable: false,
                    associatedEnum: emptyEnum,
                  ),
                )
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
        AstFlutterApi(
          name: 'Api',
          documentationComments: <String>[comments[count++]],
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              documentationComments: <String>[comments[count++]],
              parameters: <Parameter>[
                Parameter(
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
    const CppGenerator generator = CppGenerator();
    final OutputFileOptions<CppOptions> generatorOptions =
        OutputFileOptions<CppOptions>(
      fileType: FileType.header,
      languageOptions: const CppOptions(headerIncludePath: 'foo'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    for (final String comment in comments) {
      expect(code, contains('//$comment'));
    }
    expect(code, contains('// ///'));
  });

  test("doesn't create codecs if no custom datatypes", () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
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
    const CppGenerator generator = CppGenerator();
    final OutputFileOptions<CppOptions> generatorOptions =
        OutputFileOptions<CppOptions>(
      fileType: FileType.header,
      languageOptions: const CppOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(contains(' : public flutter::StandardCodecSerializer')));
  });

  test('creates custom codecs if custom datatypes present', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.flutter,
          parameters: <Parameter>[
            Parameter(
                type: TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                  associatedClass: emptyClass,
                ),
                name: '')
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
          ),
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
    const CppGenerator generator = CppGenerator();
    final OutputFileOptions<CppOptions> generatorOptions =
        OutputFileOptions<CppOptions>(
      fileType: FileType.header,
      languageOptions: const CppOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(' : public flutter::StandardCodecSerializer'));
  });

  test('Does not send unwrapped EncodableLists', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
                name: 'aBool',
                type: const TypeDeclaration(
                  baseName: 'bool',
                  isNullable: false,
                )),
            Parameter(
                name: 'anInt',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                )),
            Parameter(
                name: 'aString',
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                )),
            Parameter(
                name: 'aList',
                type: const TypeDeclaration(
                  baseName: 'List',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'Object', isNullable: true)
                  ],
                  isNullable: false,
                )),
            Parameter(
                name: 'aMap',
                type: const TypeDeclaration(
                  baseName: 'Map',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'String', isNullable: true),
                    TypeDeclaration(baseName: 'Object', isNullable: true),
                  ],
                  isNullable: false,
                )),
            Parameter(
                name: 'anObject',
                type: TypeDeclaration(
                  baseName: 'ParameterObject',
                  isNullable: false,
                  associatedClass: emptyClass,
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
    const CppGenerator generator = CppGenerator();
    final OutputFileOptions<CppOptions> generatorOptions =
        OutputFileOptions<CppOptions>(
      fileType: FileType.source,
      languageOptions: const CppOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(contains('reply(wrap')));
    expect(code, contains('reply(EncodableValue('));
  });

  test('does not keep unowned references in async handlers', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'HostApi', methods: <Method>[
        Method(
          name: 'noop',
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: const TypeDeclaration.voidDeclaration(),
          isAsynchronous: true,
        ),
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
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
      AstFlutterApi(name: 'FlutterApi', methods: <Method>[
        Method(
          name: 'noop',
          location: ApiLocation.flutter,
          parameters: <Parameter>[],
          returnType: const TypeDeclaration.voidDeclaration(),
          isAsynchronous: true,
        ),
        Method(
          name: 'doSomething',
          location: ApiLocation.flutter,
          parameters: <Parameter>[
            Parameter(
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
    const CppGenerator generator = CppGenerator();
    final OutputFileOptions<CppOptions> generatorOptions =
        OutputFileOptions<CppOptions>(
      fileType: FileType.source,
      languageOptions: const CppOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
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

  test('connection error contains channel name', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
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
    const CppGenerator generator = CppGenerator();
    final OutputFileOptions<CppOptions> generatorOptions =
        OutputFileOptions<CppOptions>(
      fileType: FileType.source,
      languageOptions: const CppOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            '"Unable to establish connection on channel: \'" + channel_name + "\'."'));
    expect(code, contains('on_error(CreateConnectionError(channel_name));'));
  });

  test('stack allocates the message channel.', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
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
    const CppGenerator generator = CppGenerator();
    final OutputFileOptions<CppOptions> generatorOptions =
        OutputFileOptions<CppOptions>(
      fileType: FileType.source,
      languageOptions: const CppOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'BasicMessageChannel<> channel(binary_messenger_, channel_name, &GetCodec());'));
    expect(code, contains('channel.Send'));
  });
}
