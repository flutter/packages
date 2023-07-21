// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/generator_tools.dart';
import 'package:pigeon/objc_generator.dart';
import 'package:pigeon/pigeon_lib.dart';
import 'package:test/test.dart';

const String DEFAULT_PACKAGE_NAME = 'test_package';

void main() {
  test('gen one class header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(code, matches('@property.*NSString.*field1'));
  });

  test('gen one class source', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('#import "foo.h"'));
    expect(code, contains('@implementation Foobar'));
  });

  test('gen one enum header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[
      Enum(
        name: 'Enum1',
        members: <EnumMember>[
          EnumMember(name: 'one'),
          EnumMember(name: 'two'),
        ],
      )
    ]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('typedef NS_ENUM(NSUInteger, Enum1) {'));
    expect(code, contains('  Enum1One = 0,'));
    expect(code, contains('  Enum1Two = 1,'));
  });

  test('gen one enum header with prefix', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[
      Enum(
        name: 'Enum1',
        members: <EnumMember>[
          EnumMember(name: 'one'),
          EnumMember(name: 'two'),
        ],
      )
    ]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(prefix: 'PREFIX'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('typedef NS_ENUM(NSUInteger, PREFIXEnum1) {'));
    expect(code, contains('  PREFIXEnum1One = 0,'));
    expect(code, contains('  PREFIXEnum1Two = 1,'));
  });

  test('gen one class source with enum', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
                type:
                    const TypeDeclaration(baseName: 'String', isNullable: true),
                name: 'field1'),
            NamedType(
                type:
                    const TypeDeclaration(baseName: 'Enum1', isNullable: true),
                name: 'enum1'),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'Enum1',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        )
      ],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('#import "foo.h"'));
    expect(code, contains('@implementation Foobar'));
    expect(
        code,
        contains(
            'pigeonResult.enum1 = [GetNullableObjectAtIndex(list, 1) integerValue];'));
  });

  test('primitive enum host', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Bar', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'bar',
            returnType: const TypeDeclaration.voidDeclaration(),
            arguments: <NamedType>[
              NamedType(
                  name: 'foo',
                  type:
                      const TypeDeclaration(baseName: 'Foo', isNullable: false))
            ])
      ])
    ], classes: <Class>[], enums: <Enum>[
      Enum(name: 'Foo', members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ])
    ]);
    final StringBuffer sink = StringBuffer();
    const ObjcOptions options =
        ObjcOptions(headerIncludePath: 'foo.h', prefix: 'AC');
    {
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions: options,
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('typedef NS_ENUM(NSUInteger, ACFoo)'));
      expect(code, contains(':(ACFoo)foo error:'));
    }
    {
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions: options,
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
              'ACFoo arg_foo = [GetNullableObjectAtIndex(args, 0) integerValue];'));
    }
  });

  test('validate nullable primitive enum', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Bar', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'bar',
            returnType: const TypeDeclaration.voidDeclaration(),
            arguments: <NamedType>[
              NamedType(
                  name: 'foo',
                  type:
                      const TypeDeclaration(baseName: 'Foo', isNullable: true))
            ])
      ])
    ], classes: <Class>[], enums: <Enum>[
      Enum(name: 'Foo', members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ])
    ]);
    const ObjcOptions options = ObjcOptions(headerIncludePath: 'foo.h');
    final List<Error> errors = validateObjc(options, root);
    expect(errors.length, 1);
    expect(errors[0].message, contains('Nullable enum'));
  });

  test('gen one class header with enum', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
                type:
                    const TypeDeclaration(baseName: 'String', isNullable: true),
                name: 'field1'),
            NamedType(
                type:
                    const TypeDeclaration(baseName: 'Enum1', isNullable: true),
                name: 'enum1'),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'Enum1',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        )
      ],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@property(nonatomic, assign) Enum1 enum1'));
  });

  test('gen one api header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: const TypeDeclaration(
                      baseName: 'Input', isNullable: false),
                  name: '')
            ],
            returnType:
                const TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@interface Input'));
    expect(code, contains('@interface Output'));
    expect(code, contains('@protocol Api'));
    expect(code, contains('/// @return `nil` only when `error != nil`.'));
    expect(code, matches('nullable Output.*doSomething.*Input.*FlutterError'));
    expect(code, matches('ApiSetup.*<Api>.*_Nullable'));
    expect(code, contains('ApiGetCodec(void)'));
  });

  test('gen one api source', () {
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
                  name: '')
            ],
            returnType:
                const TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('#import "foo.h"'));
    expect(code, contains('@implementation Input'));
    expect(code, contains('@implementation Output'));
    expect(code, contains('ApiSetup('));
    expect(
        code,
        contains(
            'NSCAssert([api respondsToSelector:@selector(doSomething:error:)'));
    expect(code, contains('ApiGetCodec(void) {'));
  });

  test('all the simple datatypes header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'bool', isNullable: true),
            name: 'aBool'),
        NamedType(
            type: const TypeDeclaration(baseName: 'int', isNullable: true),
            name: 'aInt'),
        NamedType(
            type: const TypeDeclaration(baseName: 'double', isNullable: true),
            name: 'aDouble'),
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'aString'),
        NamedType(
            type:
                const TypeDeclaration(baseName: 'Uint8List', isNullable: true),
            name: 'aUint8List'),
        NamedType(
            type:
                const TypeDeclaration(baseName: 'Int32List', isNullable: true),
            name: 'aInt32List'),
        NamedType(
            type:
                const TypeDeclaration(baseName: 'Int64List', isNullable: true),
            name: 'aInt64List'),
        NamedType(
            type: const TypeDeclaration(
                baseName: 'Float64List', isNullable: true),
            name: 'aFloat64List'),
      ]),
    ], enums: <Enum>[]);

    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(code, contains('@class FlutterStandardTypedData;'));
    expect(code, matches('@property.*strong.*NSNumber.*aBool'));
    expect(code, matches('@property.*strong.*NSNumber.*aInt'));
    expect(code, matches('@property.*strong.*NSNumber.*aDouble'));
    expect(code, matches('@property.*copy.*NSString.*aString'));
    expect(code,
        matches('@property.*strong.*FlutterStandardTypedData.*aUint8List'));
    expect(code,
        matches('@property.*strong.*FlutterStandardTypedData.*aInt32List'));
    expect(code,
        matches('@property.*strong.*FlutterStandardTypedData.*Int64List'));
    expect(code,
        matches('@property.*strong.*FlutterStandardTypedData.*Float64List'));
  });

  test('bool source', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'bool', isNullable: true),
            name: 'aBool'),
      ]),
    ], enums: <Enum>[]);

    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@implementation Foobar'));
    expect(code,
        contains('pigeonResult.aBool = GetNullableObjectAtIndex(list, 0);'));
  });

  test('nested class header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'Input', isNullable: true),
            name: 'nested')
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code,
        contains('@property(nonatomic, strong, nullable) Input * nested;'));
  });

  test('nested class source', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'Input', isNullable: true),
            name: 'nested')
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
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
            'pigeonResult.nested = [Input nullableFromList:(GetNullableObjectAtIndex(list, 0))];'));
    expect(
        code, contains('self.nested ? [self.nested toList] : [NSNull null]'));
  });

  test('prefix class header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@interface ABCFoobar'));
  });

  test('prefix class source', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@implementation ABCFoobar'));
  });

  test('prefix nested class header', () {
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
                  name: '')
            ],
            returnType:
                const TypeDeclaration(baseName: 'Nested', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'Input', isNullable: true),
            name: 'nested')
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches('property.*ABCInput'));
    expect(code, matches('ABCNested.*doSomething.*ABCInput'));
    expect(code, contains('@protocol ABCApi'));
  });

  test('prefix nested class source', () {
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
                  name: '')
            ],
            returnType:
                const TypeDeclaration(baseName: 'Nested', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'Input', isNullable: true),
            name: 'nested')
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('ABCInput fromList'));
    expect(code, matches(r'ABCInput.*=.*args.*0.*\;'));
    expect(code, contains('void ABCApiSetup('));
  });

  test('gen flutter api header', () {
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
                const TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@interface Api : NSObject'));
    expect(
        code,
        contains(
            'initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;'));
    expect(code, matches('void.*doSomething.*Input.*Output'));
    expect(code, contains('ApiGetCodec(void)'));
  });

  test('gen flutter api source', () {
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
                const TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(headerIncludePath: 'foo.h'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@implementation Api'));
    expect(code, matches('void.*doSomething.*Input.*Output.*{'));
    expect(code, contains('ApiGetCodec(void) {'));
  });

  test('gen host void header', () {
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
                  name: '')
            ],
            returnType: const TypeDeclaration.voidDeclaration())
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('(void)doSomething:'));
  });

  test('gen host void source', () {
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
                  name: '')
            ],
            returnType: const TypeDeclaration.voidDeclaration())
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(matches('=.*doSomething')));
    expect(code, matches('[.*doSomething:.*]'));
    expect(code, contains('callback(wrapResult(nil, error))'));
  });

  test('gen flutter void return header', () {
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
            returnType: const TypeDeclaration.voidDeclaration())
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('completion:(void (^)(FlutterError *_Nullable))'));
  });

  test('gen flutter void return source', () {
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
            returnType: const TypeDeclaration.voidDeclaration())
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('completion:(void (^)(FlutterError *_Nullable))'));
    expect(code, contains('completion(nil)'));
  });

  test('gen host void arg header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType:
                const TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches('ABCOutput.*doSomethingWithError:[(]FlutterError'));
  });

  test('gen host void arg source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType:
                const TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches('output.*=.*api doSomethingWithError:&error'));
  });

  test('gen flutter void arg header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType:
                const TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '(void)doSomethingWithCompletion:(void (^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion'));
  });

  test('gen flutter void arg source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType:
                const TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '(void)doSomethingWithCompletion:(void (^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion'));
    expect(code, contains('channel sendMessage:nil'));
  });

  test('gen list', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'List', isNullable: true),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(code, matches('@property.*NSArray.*field1'));
  });

  test('gen map', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'Map', isNullable: true),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(code, matches('@property.*NSDictionary.*field1'));
  });

  test('gen map field with object', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
                baseName: 'Map',
                isNullable: true,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'String', isNullable: true),
                  TypeDeclaration(baseName: 'Object', isNullable: true),
                ]),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(
        code,
        contains(
            '@property(nonatomic, strong, nullable) NSDictionary<NSString *, id> *'));
  });

  test('gen map argument with object', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doit',
            returnType: const TypeDeclaration.voidDeclaration(),
            arguments: <NamedType>[
              NamedType(
                  name: 'foo',
                  type: const TypeDeclaration(
                      baseName: 'Map',
                      isNullable: false,
                      typeArguments: <TypeDeclaration>[
                        TypeDeclaration(baseName: 'String', isNullable: true),
                        TypeDeclaration(baseName: 'Object', isNullable: true),
                      ]))
            ]),
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('(NSDictionary<NSString *, id> *)foo'));
  });

  test('async void (input) HostApi header', () {
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
            returnType: const TypeDeclaration.voidDeclaration(),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '(void)doSomethingInput:(ABCInput *)input completion:(void (^)(FlutterError *_Nullable))completion'));
  });

  test('async output(input) HostApi header', () {
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
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '(void)doSomethingInput:(ABCInput *)input completion:(void (^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion'));
  });

  test('async output(void) HostApi header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType:
                const TypeDeclaration(baseName: 'Output', isNullable: false),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '(void)doSomethingWithCompletion:(void (^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion'));
  });

  test('async void (void) HostApi header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: const TypeDeclaration.voidDeclaration(),
            isAsynchronous: true)
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '(void)doSomethingWithCompletion:(void (^)(FlutterError *_Nullable))completion'));
  });

  test('async output(input) HostApi source', () {
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
                  name: '')
            ],
            returnType:
                const TypeDeclaration(baseName: 'Output', isNullable: false),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '[api doSomething:arg0 completion:^(ABCOutput *_Nullable output, FlutterError *_Nullable error) {'));
  });

  test('async void (input) HostApi source', () {
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
                  name: 'foo')
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input')
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '[api doSomethingFoo:arg_foo completion:^(FlutterError *_Nullable error) {'));
  });

  test('async void (void) HostApi source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: const TypeDeclaration.voidDeclaration(),
            isAsynchronous: true)
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '[api doSomethingWithCompletion:^(FlutterError *_Nullable error) {'));
  });

  test('async output(void) HostApi source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType:
                const TypeDeclaration(baseName: 'Output', isNullable: false),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
            '[api doSomethingWithCompletion:^(ABCOutput *_Nullable output, FlutterError *_Nullable error) {'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('source copyright', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: ObjcOptions(
          headerIncludePath: 'foo.h',
          prefix: 'ABC',
          copyrightHeader: makeIterable('hello world')),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('header copyright', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: ObjcOptions(
          headerIncludePath: 'foo.h',
          prefix: 'ABC',
          copyrightHeader: makeIterable('hello world')),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('field generics', () {
    final Class klass = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
                baseName: 'List',
                isNullable: true,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'int', isNullable: true)
                ]),
            name: 'field1'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[klass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions:
          const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('NSArray<NSNumber *> * field1'));
  });

  test('host generics argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                    type: const TypeDeclaration(
                        baseName: 'List',
                        isNullable: false,
                        typeArguments: <TypeDeclaration>[
                          TypeDeclaration(baseName: 'int', isNullable: true)
                        ]),
                    name: 'arg')
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('doitArg:(NSArray<NSNumber *> *)arg'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
              'NSArray<NSNumber *> *arg_arg = GetNullableObjectAtIndex(args, 0)'));
    }
  });

  test('flutter generics argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                    type: const TypeDeclaration(
                        baseName: 'List',
                        isNullable: false,
                        typeArguments: <TypeDeclaration>[
                          TypeDeclaration(baseName: 'int', isNullable: true)
                        ]),
                    name: 'arg')
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('doitArg:(NSArray<NSNumber *> *)arg'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('doitArg:(NSArray<NSNumber *> *)arg'));
    }
  });

  test('host nested generic argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                    type: const TypeDeclaration(
                        baseName: 'List',
                        isNullable: false,
                        typeArguments: <TypeDeclaration>[
                          TypeDeclaration(
                              baseName: 'List',
                              isNullable: true,
                              typeArguments: <TypeDeclaration>[
                                TypeDeclaration(
                                    baseName: 'bool', isNullable: true)
                              ]),
                        ]),
                    name: 'arg')
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('doitArg:(NSArray<NSArray<NSNumber *> *> *)arg'));
    }
  });

  test('host generics return', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration(
                  baseName: 'List',
                  isNullable: false,
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'int', isNullable: true)
                  ]),
              arguments: <NamedType>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(
          code, contains('- (nullable NSArray<NSNumber *> *)doitWithError:'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('NSArray<NSNumber *> *output ='));
    }
  });

  test('flutter generics return', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration(
                  baseName: 'List',
                  isNullable: false,
                  typeArguments: <TypeDeclaration>[
                    TypeDeclaration(baseName: 'int', isNullable: true)
                  ]),
              arguments: <NamedType>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(
          code, contains('doitWithCompletion:(void (^)(NSArray<NSNumber *> *'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(
          code, contains('doitWithCompletion:(void (^)(NSArray<NSNumber *> *'));
    }
  });

  test('host multiple args', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'add',
          arguments: <NamedType>[
            NamedType(
                name: 'x',
                type:
                    const TypeDeclaration(isNullable: false, baseName: 'int')),
            NamedType(
                name: 'y',
                type:
                    const TypeDeclaration(isNullable: false, baseName: 'int')),
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
              '- (nullable NSNumber *)addX:(NSNumber *)x y:(NSNumber *)y error:(FlutterError *_Nullable *_Nonnull)error;'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('NSArray *args = message;'));
      expect(code,
          contains('NSNumber *arg_x = GetNullableObjectAtIndex(args, 0);'));
      expect(code,
          contains('NSNumber *arg_y = GetNullableObjectAtIndex(args, 1);'));
      expect(code,
          contains('NSNumber *output = [api addX:arg_x y:arg_y error:&error]'));
    }
  });

  test('host multiple args async', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'add',
          arguments: <NamedType>[
            NamedType(
                name: 'x',
                type:
                    const TypeDeclaration(isNullable: false, baseName: 'int')),
            NamedType(
                name: 'y',
                type:
                    const TypeDeclaration(isNullable: false, baseName: 'int')),
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
          isAsynchronous: true,
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
              '- (void)addX:(NSNumber *)x y:(NSNumber *)y completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('NSArray *args = message;'));
      expect(code,
          contains('NSNumber *arg_x = GetNullableObjectAtIndex(args, 0);'));
      expect(code,
          contains('NSNumber *arg_y = GetNullableObjectAtIndex(args, 1);'));
      expect(code, contains('[api addX:arg_x y:arg_y completion:'));
    }
  });

  test('flutter multiple args', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'add',
          arguments: <NamedType>[
            NamedType(
                name: 'x',
                type:
                    const TypeDeclaration(isNullable: false, baseName: 'int')),
            NamedType(
                name: 'y',
                type:
                    const TypeDeclaration(isNullable: false, baseName: 'int')),
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
              '- (void)addX:(NSNumber *)x y:(NSNumber *)y completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
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
              '- (void)addX:(NSNumber *)arg_x y:(NSNumber *)arg_y completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {'));
      expect(
          code,
          contains(
              '[channel sendMessage:@[arg_x ?: [NSNull null], arg_y ?: [NSNull null]] reply:'));
    }
  });

  Root getDivideRoot(ApiLocation location) => Root(
        apis: <Api>[
          Api(name: 'Api', location: location, methods: <Method>[
            Method(
                name: 'divide',
                objcSelector: 'divideValue:by:',
                arguments: <NamedType>[
                  NamedType(
                    type: const TypeDeclaration(
                        baseName: 'int', isNullable: false),
                    name: 'x',
                  ),
                  NamedType(
                    type: const TypeDeclaration(
                        baseName: 'int', isNullable: false),
                    name: 'y',
                  ),
                ],
                returnType: const TypeDeclaration(
                    baseName: 'double', isNullable: false))
          ])
        ],
        classes: <Class>[],
        enums: <Enum>[],
      );

  test('host custom objc selector', () {
    final Root divideRoot = getDivideRoot(ApiLocation.host);
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        divideRoot,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, matches('divideValue:.*by:.*error.*;'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        divideRoot,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, matches('divideValue:.*by:.*error.*;'));
    }
  });

  test('flutter custom objc selector', () {
    final Root divideRoot = getDivideRoot(ApiLocation.flutter);
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        divideRoot,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, matches('divideValue:.*by:.*completion.*;'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions:
            const ObjcOptions(headerIncludePath: 'foo.h', prefix: 'ABC'),
      );
      generator.generate(
        generatorOptions,
        divideRoot,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, matches('divideValue:.*by:.*completion.*{'));
    }
  });

  test('test non null field', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(baseName: 'String', isNullable: false),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(code, contains('@property(nonatomic, copy) NSString * field1'));
  });

  test('return nullable flutter header', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              arguments: <NamedType>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
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
        matches(
            r'doitWithCompletion.*void.*NSNumber \*_Nullable.*FlutterError.*completion;'));
  });

  test('return nullable flutter source', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              arguments: <NamedType>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches(r'doitWithCompletion.*NSNumber \*_Nullable'));
  });

  test('return nullable host header', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              arguments: <NamedType>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches(r'nullable NSNumber.*doitWithError'));
  });

  test('nullable argument host', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                    name: 'foo',
                    type: const TypeDeclaration(
                      baseName: 'int',
                      isNullable: true,
                    )),
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions: const ObjcOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('doitFoo:(nullable NSNumber *)foo'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions: const ObjcOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code,
          contains('NSNumber *arg_foo = GetNullableObjectAtIndex(args, 0);'));
    }
  });

  test('nullable argument flutter', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                    name: 'foo',
                    type: const TypeDeclaration(
                      baseName: 'int',
                      isNullable: true,
                    )),
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.header,
        languageOptions: const ObjcOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('doitFoo:(nullable NSNumber *)foo'));
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<ObjcOptions> generatorOptions =
          OutputFileOptions<ObjcOptions>(
        fileType: FileType.source,
        languageOptions: const ObjcOptions(),
      );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('- (void)doitFoo:(nullable NSNumber *)arg_foo'));
    }
  });

  test('background platform channel', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              arguments: <NamedType>[],
              taskQueueType: TaskQueueType.serialBackgroundThread)
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(),
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
            'NSObject<FlutterTaskQueue> *taskQueue = [binaryMessenger makeBackgroundTaskQueue];'));
    expect(code, contains('taskQueue:taskQueue'));
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
          name: 'api',
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
              name: 'field1',
            ),
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
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.header,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    for (final String comment in comments) {
      expect(code, contains('///$comment'));
    }
    expect(code, contains('/// ///'));
  });

  test("doesn't create codecs if no custom datatypes", () {
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
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(contains(' : FlutterStandardReader')));
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
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<ObjcOptions> generatorOptions =
        OutputFileOptions<ObjcOptions>(
      fileType: FileType.source,
      languageOptions: const ObjcOptions(),
    );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(' : FlutterStandardReader'));
  });
}
