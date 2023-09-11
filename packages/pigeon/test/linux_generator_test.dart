// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/generator_tools.dart';
import 'package:pigeon/linux_generator.dart';
import 'package:test/test.dart';

const String DEFAULT_PACKAGE_NAME = 'test_package';

final Class emptyClass = Class(name: 'className', fields: <NamedType>[
  NamedType(
    name: 'namedTypeName',
    type: const TypeDeclaration(baseName: 'baseName', isNullable: false),
  )
]);

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
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.header,
        languageOptions: const LinuxOptions(),
      );
      generator.generate(generatorOptions, root, sink,
          dartPackageName: DEFAULT_PACKAGE_NAME);
      final String code = sink.toString();
      expect(
          code,
          contains(
              'G_DECLARE_FINAL_TYPE(MyInput, my_input, MY, INPUT, GObject)'));
      expect(
          code,
          contains(
              'G_DECLARE_FINAL_TYPE(MyOutput, my_output, MY, OUTPUT, GObject)'));
      expect(code,
          contains('G_DECLARE_FINAL_TYPE(MyApi, my_api, MY, API, GObject)'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.source,
        languageOptions: const LinuxOptions(),
      );
      generator.generate(generatorOptions, root, sink,
          dartPackageName: DEFAULT_PACKAGE_NAME);
      final String code = sink.toString();
      expect(code, contains('static void my_input_init(MyInput* self) {'));
      expect(code, contains('static void my_output_init(MyOutput* self) {'));
      expect(code, contains('static void my_api_init(MyApi* self) {'));
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
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.header,
        languageOptions: const LinuxOptions(),
      );
      generator.generate(generatorOptions, root, sink,
          dartPackageName: DEFAULT_PACKAGE_NAME);
      final String code = sink.toString();
      expect(
          code,
          contains(
              '  MyApiDoSomethingResponse* (*do_something)(MyApi* object, MyInput* some_input, gpointer user_data);'));
      expect(code,
          contains('gboolean my_input_get_input_field(MyInput* object);'));
      expect(code,
          contains('gboolean my_output_get_output_field(MyOutput* object);'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.source,
        languageOptions: const LinuxOptions(),
      );
      generator.generate(generatorOptions, root, sink,
          dartPackageName: DEFAULT_PACKAGE_NAME);
      final String code = sink.toString();
      expect(
          code, contains('gboolean my_input_get_input_field(MyInput* self) {'));
      expect(code,
          contains('gboolean my_output_get_output_field(MyOutput* self) {'));
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
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.header,
        languageOptions: const LinuxOptions(),
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
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.source,
        languageOptions: const LinuxOptions(),
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
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.header,
        languageOptions: const LinuxOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('''
#include <flutter_linux/flutter_linux.h>
'''));
    }
    {
      final StringBuffer sink = StringBuffer();
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.source,
        languageOptions: const LinuxOptions(headerIncludePath: 'a_header.h'),
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
'''));
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
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.header,
        languageOptions: const LinuxOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();

      expect(code, contains('MyNested* my_nested_new(gboolean nested_value);'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.source,
        languageOptions: const LinuxOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();

      expect(
          code, contains('MyNested* my_nested_new(gboolean nested_value) {'));
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
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.header,
        languageOptions: const LinuxOptions(),
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
              '  MyApiReturnBoolResponse* (*return_bool)(MyApi* object, gpointer user_data);'));
      expect(
          code,
          contains(
              '  MyApiReturnIntResponse* (*return_int)(MyApi* object, gpointer user_data);'));
      expect(
          code,
          contains(
              '  MyApiReturnStringResponse* (*return_string)(MyApi* object, gpointer user_data);'));
      expect(
          code,
          contains(
              '  MyApiReturnListResponse* (*return_list)(MyApi* object, gpointer user_data);'));
      expect(
          code,
          contains(
              '  MyApiReturnMapResponse* (*return_map)(MyApi* object, gpointer user_data);'));
      expect(
          code,
          contains(
              '  MyApiReturnDataClassResponse* (*return_data_class)(MyApi* object, gpointer user_data);'));
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
                type: TypeDeclaration(
                  baseName: 'List',
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(
                      baseName: 'Object',
                      isNullable: true,
                      associatedClass: emptyClass,
                    )
                  ],
                  isNullable: false,
                )),
            Parameter(
                name: 'aMap',
                type: TypeDeclaration(
                  baseName: 'Map',
                  typeArguments: <TypeDeclaration>[
                    const TypeDeclaration(baseName: 'String', isNullable: true),
                    TypeDeclaration(
                      baseName: 'Object',
                      isNullable: true,
                      associatedClass: emptyClass,
                    ),
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
                type: TypeDeclaration(
                  baseName: 'Object',
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
    {
      final StringBuffer sink = StringBuffer();
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.header,
        languageOptions: const LinuxOptions(),
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
              '  MyApiDoSomethingResponse* (*do_something)(MyApi* object, gboolean a_bool, int64_t an_int, const gchar* a_string, FlValue* a_list, FlValue* a_map, MyParameterObject* an_object, MyObject* a_generic_object, gpointer user_data);'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const LinuxGenerator generator = LinuxGenerator();
      final OutputFileOptions<LinuxOptions> generatorOptions =
          OutputFileOptions<LinuxOptions>(
        fileType: FileType.source,
        languageOptions: const LinuxOptions(),
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
              '  g_autoptr(MyApiDoSomethingResponse) response = self->vtable->do_something(self, fl_value_get_bool(fl_value_get_list_value(message, 0)), fl_value_get_int(fl_value_get_list_value(message, 1)), fl_value_get_string(fl_value_get_list_value(message, 2)), fl_value_get_list_value(message, 3), fl_value_get_list_value(message, 4), MY_PARAMETER_OBJECT(fl_value_get_custom_value_object(fl_value_get_list_value(message, 5))), MY_OBJECT(fl_value_get_custom_value_object(fl_value_get_list_value(message, 6))), self->user_data);'));
    }
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
    const LinuxGenerator generator = LinuxGenerator();
    final OutputFileOptions<LinuxOptions> generatorOptions =
        OutputFileOptions<LinuxOptions>(
      fileType: FileType.header,
      languageOptions: const LinuxOptions(headerIncludePath: 'foo'),
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
}
