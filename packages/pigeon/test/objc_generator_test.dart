// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart' show Error, TaskQueueType;
import 'package:pigeon/src/ast.dart';
import 'package:pigeon/src/generator_tools.dart';
import 'package:pigeon/src/objc/objc_generator.dart';
import 'package:test/test.dart';

const String DEFAULT_PACKAGE_NAME = 'test_package';

final Class emptyClass = Class(
  name: 'className',
  fields: <NamedType>[
    NamedType(
      name: 'namedTypeName',
      type: const TypeDeclaration(baseName: 'baseName', isNullable: false),
    ),
  ],
);

final Enum emptyEnum = Enum(
  name: 'enumName',
  members: <EnumMember>[EnumMember(name: 'enumMemberName')],
);

void main() {
  test('gen one class header', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[],
      enums: <Enum>[
        Enum(
          name: 'Enum1',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[],
      enums: <Enum>[
        Enum(
          name: 'Enum1',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            prefix: 'PREFIX',
            headerIncludePath: '',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'field1',
            ),
            NamedType(
              type: TypeDeclaration(
                baseName: 'Enum1',
                associatedEnum: emptyEnum,
                isNullable: true,
              ),
              name: 'enum1',
            ),
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
        ),
      ],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        'return enumAsNumber == nil ? nil : [[Enum1Box alloc] initWithValue:[enumAsNumber integerValue]];',
      ),
    );
  });

  test('primitive enum host', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Bar',
          methods: <Method>[
            Method(
              name: 'bar',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'foo',
                  type: TypeDeclaration(
                    baseName: 'Foo',
                    associatedEnum: emptyEnum,
                    isNullable: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[
        Enum(
          name: 'Foo',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final StringBuffer sink = StringBuffer();
    const InternalObjcOptions options = InternalObjcOptions(
      headerIncludePath: 'foo.h',
      prefix: 'AC',
      objcHeaderOut: '',
      objcSourceOut: '',
    );
    {
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
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
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
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
          'return enumAsNumber == nil ? nil : [[ACFooBox alloc] initWithValue:[enumAsNumber integerValue]];',
        ),
      );

      expect(code, contains('ACFooBox *box = (ACFooBox *)value;'));
    }
  });

  test('validate nullable primitive enum', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Bar',
          methods: <Method>[
            Method(
              name: 'bar',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'foo',
                  type: TypeDeclaration(
                    baseName: 'Foo',
                    associatedEnum: emptyEnum,
                    isNullable: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[
        Enum(
          name: 'Foo',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    const InternalObjcOptions options = InternalObjcOptions(
      headerIncludePath: 'foo.h',
      objcHeaderOut: '',
      objcSourceOut: '',
    );
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
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'field1',
            ),
            NamedType(
              type: TypeDeclaration(
                baseName: 'Enum1',
                associatedEnum: emptyEnum,
                isNullable: true,
              ),
              name: 'enum1',
            ),
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
        ),
      ],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
      contains('@property(nonatomic, strong, nullable) Enum1Box * enum1;'),
    );
  });

  test('gen one api header', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    expect(code, matches('SetUpApi.*<Api>.*_Nullable'));
  });

  test('gen one api source', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    expect(code, contains('SetUpApi('));
    expect(
      code,
      contains(
        'NSCAssert([api respondsToSelector:@selector(doSomething:error:)',
      ),
    );
  });

  test('all the simple datatypes header', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'bool', isNullable: true),
              name: 'aBool',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'int', isNullable: true),
              name: 'aInt',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'double', isNullable: true),
              name: 'aDouble',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'aString',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Uint8List',
                isNullable: true,
              ),
              name: 'aUint8List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Int32List',
                isNullable: true,
              ),
              name: 'aInt32List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Int64List',
                isNullable: true,
              ),
              name: 'aInt64List',
            ),
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Float64List',
                isNullable: true,
              ),
              name: 'aFloat64List',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );

    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    expect(
      code,
      matches('@property.*strong.*FlutterStandardTypedData.*aUint8List'),
    );
    expect(
      code,
      matches('@property.*strong.*FlutterStandardTypedData.*aInt32List'),
    );
    expect(
      code,
      matches('@property.*strong.*FlutterStandardTypedData.*Int64List'),
    );
    expect(
      code,
      matches('@property.*strong.*FlutterStandardTypedData.*Float64List'),
    );
  });

  test('bool source', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'bool', isNullable: true),
              name: 'aBool',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );

    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
        );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@implementation Foobar'));
    expect(
      code,
      contains('pigeonResult.aBool = GetNullableObjectAtIndex(list, 0);'),
    );
  });

  test('nested class header', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Nested',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: true,
              ),
              name: 'nested',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
      contains('@property(nonatomic, strong, nullable) Input * nested;'),
    );
  });

  test('nested class source', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Nested',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: true,
              ),
              name: 'nested',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
      contains('pigeonResult.nested = GetNullableObjectAtIndex(list, 0);'),
    );
  });

  test('prefix class header', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Nested',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Nested',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: true,
              ),
              name: 'nested',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Nested',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Nested',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: true,
              ),
              name: 'nested',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    expect(code, contains('void SetUpABCApi('));
  });

  test('gen flutter api header', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        'initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;',
      ),
    );
    expect(code, matches('void.*doSomething.*Input.*Output'));
  });

  test('gen flutter api source', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
  });

  test('gen host void header', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '(void)doSomethingWithCompletion:(void (^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion',
      ),
    );
  });

  test('gen flutter void arg source', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '(void)doSomethingWithCompletion:(void (^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion',
      ),
    );
    expect(code, contains('channel sendMessage:nil'));
  });

  test('gen list', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'List', isNullable: true),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'Map', isNullable: true),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(
                baseName: 'Map',
                isNullable: true,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'String', isNullable: true),
                  TypeDeclaration(baseName: 'Object', isNullable: true),
                ],
              ),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
        '@property(nonatomic, copy, nullable) NSDictionary<NSString *, id> *',
      ),
    );
  });

  test('gen map argument with object', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'foo',
                  type: const TypeDeclaration(
                    baseName: 'Map',
                    isNullable: false,
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(baseName: 'String', isNullable: true),
                      TypeDeclaration(baseName: 'Object', isNullable: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: 'input',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '(void)doSomethingInput:(ABCInput *)input completion:(void (^)(FlutterError *_Nullable))completion',
      ),
    );
  });

  test('async output(input) HostApi header', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: 'input',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '(void)doSomethingInput:(ABCInput *)input completion:(void (^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion',
      ),
    );
  });

  test('async output(void) HostApi header', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '(void)doSomethingWithCompletion:(void (^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion',
      ),
    );
  });

  test('async void (void) HostApi header', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration.voidDeclaration(),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '(void)doSomethingWithCompletion:(void (^)(FlutterError *_Nullable))completion',
      ),
    );
  });

  test('async output(input) HostApi source', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '[api doSomething:arg0 completion:^(ABCOutput *_Nullable output, FlutterError *_Nullable error) {',
      ),
    );
  });

  test('async void (input) HostApi source', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: 'foo',
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '[api doSomethingFoo:arg_foo completion:^(FlutterError *_Nullable error) {',
      ),
    );
  });

  test('async void (void) HostApi source', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration.voidDeclaration(),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '[api doSomethingWithCompletion:^(FlutterError *_Nullable error) {',
      ),
    );
  });

  test('async output(void) HostApi source', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        '[api doSomethingWithCompletion:^(ABCOutput *_Nullable output, FlutterError *_Nullable error) {',
      ),
    );
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('source copyright', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            copyrightHeader: makeIterable('hello world'),
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            copyrightHeader: makeIterable('hello world'),
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'List',
            isNullable: true,
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(baseName: 'int', isNullable: true),
            ],
          ),
          name: 'field1',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            headerIncludePath: 'foo.h',
            prefix: 'ABC',
            objcHeaderOut: '',
            objcSourceOut: '',
          ),
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
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'List',
                    isNullable: false,
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(baseName: 'int', isNullable: true),
                    ],
                  ),
                  name: 'arg',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
          'NSArray<NSNumber *> *arg_arg = GetNullableObjectAtIndex(args, 0)',
        ),
      );
    }
  });

  test('flutter generics argument', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'List',
                    isNullable: false,
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(baseName: 'int', isNullable: true),
                    ],
                  ),
                  name: 'arg',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'List',
                    isNullable: false,
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(
                        baseName: 'List',
                        isNullable: true,
                        typeArguments: <TypeDeclaration>[
                          TypeDeclaration(baseName: 'bool', isNullable: true),
                        ],
                      ),
                    ],
                  ),
                  name: 'arg',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(
                baseName: 'List',
                isNullable: false,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'int', isNullable: true),
                ],
              ),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
        contains('- (nullable NSArray<NSNumber *> *)doitWithError:'),
      );
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration(
                baseName: 'List',
                isNullable: false,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'int', isNullable: true),
                ],
              ),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
        contains('doitWithCompletion:(void (^)(NSArray<NSNumber *> *'),
      );
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
        contains('doitWithCompletion:(void (^)(NSArray<NSNumber *> *'),
      );
    }
  });

  test('host multiple args', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'add',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  name: 'x',
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                ),
                Parameter(
                  name: 'y',
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                ),
              ],
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
          '- (nullable NSNumber *)addX:(NSInteger)x y:(NSInteger)y error:(FlutterError *_Nullable *_Nonnull)error;',
        ),
      );
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
          );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('NSArray<id> *args = message;'));
      expect(
        code,
        contains(
          'NSInteger arg_x = [GetNullableObjectAtIndex(args, 0) integerValue];',
        ),
      );
      expect(
        code,
        contains(
          'NSInteger arg_y = [GetNullableObjectAtIndex(args, 1) integerValue];',
        ),
      );
      expect(
        code,
        contains('NSNumber *output = [api addX:arg_x y:arg_y error:&error]'),
      );
    }
  });

  test('host multiple args async', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'add',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  name: 'x',
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                ),
                Parameter(
                  name: 'y',
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                ),
              ],
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: false,
              ),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
          '- (void)addX:(NSInteger)x y:(NSInteger)y completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;',
        ),
      );
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
          );
      generator.generate(
        generatorOptions,
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      expect(code, contains('NSArray<id> *args = message;'));
      expect(
        code,
        contains(
          'NSInteger arg_x = [GetNullableObjectAtIndex(args, 0) integerValue];',
        ),
      );
      expect(
        code,
        contains(
          'NSInteger arg_y = [GetNullableObjectAtIndex(args, 1) integerValue];',
        ),
      );
      expect(code, contains('[api addX:arg_x y:arg_y completion:'));
    }
  });

  test('flutter multiple args', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'add',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  name: 'x',
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                ),
                Parameter(
                  name: 'y',
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                ),
              ],
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: false,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
          '- (void)addX:(NSInteger)x y:(NSInteger)y completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;',
        ),
      );
    }
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
          '- (void)addX:(NSInteger)arg_x y:(NSInteger)arg_y completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {',
        ),
      );
      expect(
        code,
        contains('[channel sendMessage:@[@(arg_x), @(arg_y)] reply:'),
      );
    }
  });

  Root getDivideRoot(ApiLocation location) => Root(
    apis: <Api>[
      switch (location) {
        ApiLocation.host => AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'divide',
              location: location,
              objcSelector: 'divideValue:by:',
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: false,
                  ),
                  name: 'x',
                ),
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: false,
                  ),
                  name: 'y',
                ),
              ],
              returnType: const TypeDeclaration(
                baseName: 'double',
                isNullable: false,
              ),
            ),
          ],
        ),
        ApiLocation.flutter => AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'divide',
              location: location,
              objcSelector: 'divideValue:by:',
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: false,
                  ),
                  name: 'x',
                ),
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: false,
                  ),
                  name: 'y',
                ),
              ],
              returnType: const TypeDeclaration(
                baseName: 'double',
                isNullable: false,
              ),
            ),
          ],
        ),
      },
    ],
    classes: <Class>[],
    enums: <Enum>[],
  );

  test('host custom objc selector', () {
    final Root divideRoot = getDivideRoot(ApiLocation.host);
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              headerIncludePath: 'foo.h',
              prefix: 'ABC',
              objcHeaderOut: '',
              objcSourceOut: '',
            ),
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
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: false,
              ),
              name: 'field1',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
        r'doitWithCompletion.*void.*NSNumber \*_Nullable.*FlutterError.*completion;',
      ),
    );
  });

  test('return nullable flutter source', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'foo',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              objcHeaderOut: '',
              objcSourceOut: '',
              headerIncludePath: '',
            ),
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
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              objcHeaderOut: '',
              objcSourceOut: '',
              headerIncludePath: '',
            ),
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
        contains('NSNumber *arg_foo = GetNullableObjectAtIndex(args, 0);'),
      );
    }
  });

  test('nullable argument flutter', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'foo',
                  type: const TypeDeclaration(
                    baseName: 'int',
                    isNullable: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      const ObjcGenerator generator = ObjcGenerator();
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.header,
            languageOptions: const InternalObjcOptions(
              objcHeaderOut: '',
              objcSourceOut: '',
              headerIncludePath: '',
            ),
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
      final OutputFileOptions<InternalObjcOptions> generatorOptions =
          OutputFileOptions<InternalObjcOptions>(
            fileType: FileType.source,
            languageOptions: const InternalObjcOptions(
              objcHeaderOut: '',
              objcSourceOut: '',
              headerIncludePath: '',
            ),
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
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              parameters: <Parameter>[],
              taskQueueType: TaskQueueType.serialBackgroundThread,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
        'NSObject<FlutterTaskQueue> *taskQueue = [binaryMessenger makeBackgroundTaskQueue];',
      ),
    );
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
        AstFlutterApi(
          name: 'api',
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
            ),
          ],
        ),
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
                ],
              ),
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
            unspacedComments[unspacedCount++],
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
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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

  test('creates custom codecs', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    associatedClass: emptyClass,
                    isNullable: false,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Input',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'input',
            ),
          ],
        ),
        Class(
          name: 'Output',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'output',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
      containsFlutterApi: true,
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
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
        'return [FlutterError errorWithCode:@"channel-error" message:[NSString stringWithFormat:@"%@/%@/%@", @"Unable to establish connection on channel: \'", channelName, @"\'."] details:@""]',
      ),
    );
    expect(code, contains('completion(createConnectionError(channelName))'));
  });

  test('header of FlutterApi uses correct enum name with prefix', () {
    final Enum enum1 = Enum(
      name: 'Enum1',
      members: <EnumMember>[EnumMember(name: 'one'), EnumMember(name: 'two')],
    );
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              isAsynchronous: true,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Enum1',
                isNullable: false,
                associatedEnum: enum1,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[enum1],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            prefix: 'FLT',
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
        );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(contains('FLTFLT')));
    expect(code, contains('FLTEnum1Box'));
  });

  test('source of FlutterApi uses correct enum name with prefix', () {
    final Enum enum1 = Enum(
      name: 'Enum1',
      members: <EnumMember>[EnumMember(name: 'one'), EnumMember(name: 'two')],
    );
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.flutter,
              isAsynchronous: true,
              parameters: <Parameter>[],
              returnType: TypeDeclaration(
                baseName: 'Enum1',
                isNullable: false,
                associatedEnum: enum1,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[enum1],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            prefix: 'FLT',
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
        );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(contains('FLTFLT')));
    expect(code, contains('FLTEnum1Box'));
  });

  test('header of HostApi uses correct enum name with prefix', () {
    final Enum enum1 = Enum(
      name: 'Enum1',
      members: <EnumMember>[EnumMember(name: 'one'), EnumMember(name: 'two')],
    );
    final TypeDeclaration enumType = TypeDeclaration(
      baseName: 'Enum1',
      isNullable: false,
      associatedEnum: enum1,
    );
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              isAsynchronous: true,
              parameters: <Parameter>[Parameter(name: 'value', type: enumType)],
              returnType: enumType,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[enum1],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.header,
          languageOptions: const InternalObjcOptions(
            prefix: 'FLT',
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
        );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(contains('FLTFLT')));
    expect(code, contains('FLTEnum1Box'));
  });

  test('source of HostApi uses correct enum name with prefix', () {
    final Enum enum1 = Enum(
      name: 'Enum1',
      members: <EnumMember>[EnumMember(name: 'one'), EnumMember(name: 'two')],
    );
    final TypeDeclaration enumType = TypeDeclaration(
      baseName: 'Enum1',
      isNullable: false,
      associatedEnum: enum1,
    );
    final Root root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              isAsynchronous: true,
              parameters: <Parameter>[Parameter(name: 'value', type: enumType)],
              returnType: enumType,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[enum1],
    );
    final StringBuffer sink = StringBuffer();
    const ObjcGenerator generator = ObjcGenerator();
    final OutputFileOptions<InternalObjcOptions> generatorOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: FileType.source,
          languageOptions: const InternalObjcOptions(
            prefix: 'FLT',
            objcHeaderOut: '',
            objcSourceOut: '',
            headerIncludePath: '',
          ),
        );
    generator.generate(
      generatorOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(contains('FLTFLT')));
    expect(code, contains('FLTEnum1Box'));
  });
}
