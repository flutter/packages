// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart' show TaskQueueType;
import 'package:pigeon/src/ast.dart';
import 'package:pigeon/src/generator_tools.dart' show defaultNativeInteropInstanceName;
import 'package:pigeon/src/kotlin/kotlin_generator.dart';
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
  test('gen one class', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('data class Foobar ('));
    expect(code, contains('val field1: Long? = null'));
    expect(code, contains('fun fromList(pigeonVar_list: List<Any?>): Foobar'));
    expect(code, contains('fun toList(): List<Any?>'));
    expect(code, isNot(contains('containsKey')));
  });

  test('fileSpecificClassNameComponent defaults to UpperCamelCase from kotlinOut', () {
    final kotlinOptions = InternalKotlinOptions.fromKotlinOptions(
      const KotlinOptions(),
      kotlinOut: 'path/to/messages.g.kt',
    );
    expect(kotlinOptions.fileSpecificClassNameComponent, equals('Messages'));
  });

  test('gen one enum', () {
    final anEnum = Enum(
      name: 'Foobar',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[anEnum]);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('enum class Foobar(val raw: Int) {'));
    expect(code, contains('ONE(0)'));
    expect(code, contains('TWO(1)'));
  });

  test('gen class with enum', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Bar',
          fields: <NamedType>[
            NamedType(
              name: 'field1',
              type: TypeDeclaration(baseName: 'Foo', isNullable: false, associatedEnum: emptyEnum),
            ),
            NamedType(
              name: 'field2',
              type: const TypeDeclaration(baseName: 'String', isNullable: false),
            ),
          ],
        ),
      ],
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('enum class Foo(val raw: Int) {'));
    expect(code, contains('data class Bar ('));
    expect(code, contains('val field1: Foo,'));
    expect(code, contains('val field2: String'));
    expect(code, contains('fun fromList(pigeonVar_list: List<Any?>): Bar'));
    expect(code, contains('Foo.ofRaw(it.toInt())'));
    expect(code, contains('val field1 = pigeonVar_list[0] as Foo'));
    expect(code, contains('val field2 = pigeonVar_list[1] as String\n'));
    expect(code, contains('fun toList(): List<Any?>'));
  });

  test('primitive enum host', () {
    final root = Root(
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
                    isNullable: false,
                    associatedEnum: emptyEnum,
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('enum class Foo(val raw: Int) {'));
    expect(code, contains('Foo.ofRaw(it.toInt())'));
  });

  test('gen one host api', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('interface Api'));
    expect(code, contains('fun doSomething(input: Input): Output'));
    expect(
      code,
      contains('''
    @JvmOverloads
    fun setUp(binaryMessenger: BinaryMessenger, api: Api?, messageChannelSuffix: String = "") {
    '''),
    );
    expect(code, contains('channel.setMessageHandler'));
    expect(
      code,
      contains('''
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val inputArg = args[0] as Input
            val wrapped: List<Any?> = try {
              listOf(api.doSomething(inputArg))
            } catch (exception: Throwable) {
              PigeonUtils.wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
    '''),
    );
  });

  test('all the simple datatypes header', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'bool', isNullable: false),
              name: 'aBool',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'int', isNullable: false),
              name: 'aInt',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'double', isNullable: false),
              name: 'aDouble',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: false),
              name: 'aString',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Uint8List', isNullable: true),
              name: 'aUint8List',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Int32List', isNullable: false),
              name: 'aInt32List',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Int64List', isNullable: false),
              name: 'aInt64List',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Float64List', isNullable: false),
              name: 'aFloat64List',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'bool', isNullable: true),
              name: 'aNullableBool',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'int', isNullable: true),
              name: 'aNullableInt',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'double', isNullable: true),
              name: 'aNullableDouble',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
              name: 'aNullableString',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Uint8List', isNullable: true),
              name: 'aNullableUint8List',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Int32List', isNullable: true),
              name: 'aNullableInt32List',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Int64List', isNullable: true),
              name: 'aNullableInt64List',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Float64List', isNullable: true),
              name: 'aNullableFloat64List',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );

    final sink = StringBuffer();

    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('val aBool: Boolean'));
    expect(code, contains('val aInt: Long'));
    expect(code, contains('val aDouble: Double'));
    expect(code, contains('val aString: String'));
    expect(code, contains('val aUint8List: ByteArray'));
    expect(code, contains('val aInt32List: IntArray'));
    expect(code, contains('val aInt64List: LongArray'));
    expect(code, contains('val aFloat64List: DoubleArray'));
    expect(code, contains('val aNullableBool: Boolean? = null'));
    expect(code, contains('val aNullableInt: Long? = null'));
    expect(code, contains('val aNullableDouble: Double? = null'));
    expect(code, contains('val aNullableString: String? = null'));
    expect(code, contains('val aNullableUint8List: ByteArray? = null'));
    expect(code, contains('val aNullableInt32List: IntArray? = null'));
    expect(code, contains('val aNullableInt64List: LongArray? = null'));
    expect(code, contains('val aNullableFloat64List: DoubleArray? = null'));
  });

  test('gen one flutter api', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(
      code,
      contains(
        'class Api(private val binaryMessenger: BinaryMessenger, private val messageChannelSuffix: String = "")',
      ),
    );
    expect(code, matches('fun doSomething.*Input.*Output'));
  });

  test('gen host void api', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, isNot(matches('.*doSomething(.*) ->')));
    expect(code, matches('doSomething(.*)'));
  });

  test('gen flutter void return api', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('suspend fun doSomething(arg0Arg: Input)'));
    expect(code, contains('continuation.resume(Unit)'));
    // Lines should not end in semicolons.
    expect(code, isNot(contains(RegExp(r';\n'))));
  });

  test('gen host void argument api', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('fun doSomething(): Output'));
    expect(code, contains('listOf(api.doSomething())'));
    expect(code, contains('wrapError(exception)'));
    expect(code, contains('reply(wrapped)'));
  });

  test('gen flutter void argument api', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('suspend fun doSomething(): Output'));
    expect(code, contains('channel.send(null)'));
  });

  test('gen list', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: List<Any?>? = null'));
  });

  test('gen map', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: Map<Any, Any?>? = null'));
  });

  test('gen nested', () {
    final classDefinition = Class(
      name: 'Outer',
      fields: <NamedType>[
        NamedType(
          type: TypeDeclaration(baseName: 'Nested', associatedClass: emptyClass, isNullable: true),
          name: 'nested',
        ),
      ],
    );
    final nestedClass = Class(
      name: 'Nested',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'data',
        ),
      ],
    );
    final root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition, nestedClass],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('data class Outer'));
    expect(code, contains('data class Nested'));
    expect(code, contains('val nested: Nested? = null'));
    expect(code, contains('fun fromList(pigeonVar_list: List<Any?>): Outer'));
    expect(code, contains('val nested = pigeonVar_list[0] as Nested?'));
    expect(code, contains('fun toList(): List<Any?>'));
  });

  test('gen one async Host Api', () {
    final root = Root(
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
                  name: 'arg',
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('interface Api'));
    expect(code, contains('suspend fun doSomething(arg: Input): Output'));
    expect(code, contains('CoroutineScope(Dispatchers.Main).launch {'));
    expect(code, contains('listOf(api.doSomething(argArg))'));
  });

  test('gen one async Flutter Api', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('suspend fun doSomething.*Input.*: Output'));
  });

  test('gen one enum class', () {
    final anEnum = Enum(
      name: 'SampleEnum',
      members: <EnumMember>[
        EnumMember(name: 'sampleVersion'),
        EnumMember(name: 'sampleTest'),
      ],
    );
    final classDefinition = Class(
      name: 'EnumClass',
      fields: <NamedType>[
        NamedType(
          type: TypeDeclaration(
            baseName: 'SampleEnum',
            associatedEnum: emptyEnum,
            isNullable: true,
          ),
          name: 'sampleEnum',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[anEnum]);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('enum class SampleEnum(val raw: Int)'));
    expect(code, contains('SAMPLE_VERSION(0)'));
    expect(code, contains('SAMPLE_TEST(1)'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final sink = StringBuffer();
    final kotlinOptions = InternalKotlinOptions(
      copyrightHeader: makeIterable('hello world'),
      kotlinOut: '',
    );
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  group('generated annotation', () {
    late Root root;
    late KotlinGenerator generator;
    late StringBuffer sink;

    setUp(() {
      root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
      generator = const KotlinGenerator();
      sink = StringBuffer();
    });

    test('with generated annotation', () {
      final kotlinOptions = InternalKotlinOptions(
        copyrightHeader: makeIterable('hello world'),
        kotlinOut: '',
        useGeneratedAnnotation: true,
      );
      generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
      final code = sink.toString();
      expect(code, contains(kotlinGeneratedAnnotation));
    });

    test('without generated annotation', () {
      final kotlinOptions = InternalKotlinOptions(
        copyrightHeader: makeIterable('hello world'),
        kotlinOut: '',
      );
      generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
      final code = sink.toString();
      expect(code, isNot(contains(kotlinGeneratedAnnotation)));
    });
  });

  test('generics - list', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'List',
            isNullable: true,
            typeArguments: <TypeDeclaration>[TypeDeclaration(baseName: 'int', isNullable: true)],
          ),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: List<Long?>'));
  });

  test('generics - maps', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Map',
            isNullable: true,
            typeArguments: <TypeDeclaration>[
              TypeDeclaration(baseName: 'String', isNullable: true),
              TypeDeclaration(baseName: 'String', isNullable: true),
            ],
          ),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: Map<String?, String?>'));
  });

  test('host generics argument', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('fun doit(arg: List<Long?>'));
  });

  test('flutter generics argument', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('fun doit(argArg: List<Long?>'));
  });

  test('host generics return', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('fun doit(): List<Long?>'));
    expect(code, contains('listOf(api.doit())'));
    expect(code, contains('reply.reply(wrapped)'));
  });

  test('flutter generics return', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('suspend fun doit()'));
    expect(code, contains('val output = it[0] as List<Long?>'));
    expect(code, contains('continuation.resume(output)'));
  });

  test('host multiple args', () {
    final root = Root(
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
                  type: const TypeDeclaration(isNullable: false, baseName: 'int'),
                ),
                Parameter(
                  name: 'y',
                  type: const TypeDeclaration(isNullable: false, baseName: 'int'),
                ),
              ],
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('fun add(x: Long, y: Long): Long'));
    expect(code, contains('val args = message as List<Any?>'));
    expect(code, contains('listOf(api.add(xArg, yArg))'));
    expect(code, contains('reply.reply(wrapped)'));
  });

  test('flutter multiple args', () {
    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: false),
                ),
                Parameter(
                  name: 'y',
                  type: const TypeDeclaration(baseName: 'int', isNullable: false),
                ),
              ],
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('val channel = BasicMessageChannel'));
    expect(code, contains('continuation.resume(output)'));
    expect(code, contains('suspend fun add(xArg: Long, yArg: Long)'));
    expect(code, contains('channel.send(listOf(xArg, yArg)) {'));
  });

  test('return nullable host', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('fun doit(): Long?'));
  });

  test('return nullable host async', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              isAsynchronous: true,
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('suspend fun doit(): Long?'));
  });

  test('nullable argument host', () {
    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('val fooArg = args[0]'));
  });

  test('nullable argument flutter', () {
    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('suspend fun doit(fooArg: Long?)'));
  });

  test('nonnull fields', () {
    final root = Root(
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
              type: const TypeDeclaration(baseName: 'String', isNullable: false),
              name: 'input',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('val input: String\n'));
  });

  test('transfers documentation comments', () {
    final comments = <String>[
      ' api comment',
      ' api method comment',
      ' class comment',
      ' class field comment',
      ' enum comment',
      ' enum member comment',
    ];
    var count = 0;

    final unspacedComments = <String>['////////'];
    var unspacedCount = 0;

    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
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
          documentationComments: <String>[comments[count++], unspacedComments[unspacedCount++]],
          members: <EnumMember>[
            EnumMember(name: 'one', documentationComments: <String>[comments[count++]]),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    for (final comment in comments) {
      // This regex finds the comment only between the open and close comment block
      expect(
        RegExp(r'(?<=\/\*\*.*?)' + comment + r'(?=.*?\*\/)', dotAll: true).hasMatch(code),
        true,
      );
    }
    expect(code, isNot(contains('*//')));
  });

  test('creates custom codecs', () {
    final root = Root(
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains(' : StandardMessageCodec() '));
  });

  test('creates api error class for custom errors', () {
    final method = Method(
      name: 'doSomething',
      location: ApiLocation.host,
      returnType: const TypeDeclaration.voidDeclaration(),
      parameters: <Parameter>[],
    );
    final api = AstHostApi(name: 'SomeApi', methods: <Method>[method]);
    final root = Root(apis: <Api>[api], classes: <Class>[], enums: <Enum>[], containsHostApi: true);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(errorClassName: 'SomeError', kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('class SomeError'));
    expect(code, contains('if (exception is SomeError)'));
    expect(code, contains('exception.code,'));
    expect(code, contains('exception.message,'));
    expect(code, contains('exception.details'));
  });

  test('connection error contains channel name', () {
    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
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
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(
      code,
      contains(
        'return FlutterError("channel-error",  "Unable to establish connection on channel: \'\$channelName\'.", "")',
      ),
    );
    expect(
      code,
      contains('continuation.resumeWithException(PigeonUtils.createConnectionError(channelName))'),
    );
  });

  test('gen host uses default error class', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'field',
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('FlutterError'));
  });

  test('gen flutter uses default error class', () {
    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('FlutterError'));
  });

  test('gen host uses error class', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'field',
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const errorClassName = 'FooError';
    const kotlinOptions = InternalKotlinOptions(errorClassName: errorClassName, kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains(errorClassName));
    expect(code, isNot(contains('FlutterError')));
  });

  test('gen flutter uses error class', () {
    final root = Root(
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const errorClassName = 'FooError';
    const kotlinOptions = InternalKotlinOptions(errorClassName: errorClassName, kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains(errorClassName));
    expect(code, isNot(contains('FlutterError')));
  });

  test('error class inherits from RuntimeException', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'field',
                  type: const TypeDeclaration(baseName: 'int', isNullable: true),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains(': RuntimeException()'));
  });

  group('native interop @Keep', () {
    final anEnum = Enum(
      name: 'AnEnum',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ],
    );
    final dataClass = Class(
      name: 'DataClass',
      fields: <NamedType>[
        NamedType(
          name: 'anEnum',
          type: TypeDeclaration(baseName: 'AnEnum', isNullable: true, associatedEnum: anEnum),
        ),
      ],
    );
    final dataClassType = TypeDeclaration(
      baseName: 'DataClass',
      isNullable: false,
      associatedClass: dataClass,
    );
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'HostApi',
          methods: <Method>[
            Method(
              name: 'echo',
              location: ApiLocation.host,
              returnType: dataClassType,
              parameters: <Parameter>[Parameter(name: 'value', type: dataClassType)],
            ),
          ],
        ),
        AstFlutterApi(
          name: 'FlutterApi',
          methods: <Method>[
            Method(
              name: 'onEvent',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[dataClass],
      enums: <Enum>[anEnum],
    );

    String generate({required bool useJni}) {
      final sink = StringBuffer();
      const KotlinGenerator().generate(
        InternalKotlinOptions(errorClassName: 'FooError', kotlinOut: '', useJni: useJni),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      return sink.toString();
    }

    test('is added to every type the generated Dart reaches through JNI', () {
      final String code = generate(useJni: true);
      expect(code, contains('import androidx.annotation.Keep'));
      expect(code, contains('@Keep\nclass FooError ('));
      expect(code, contains('@Keep\nenum class AnEnum('));
      expect(code, contains('@Keep\n  companion object {\n    fun ofRaw(raw: Int): AnEnum?'));
      expect(code, contains('@Keep\ndata class DataClass ('));
      expect(code, contains('@Keep\ninterface HostApi {'));
      expect(
        code,
        contains(
          '@Keep\nclass HostApiRegistrar private constructor(private val engineKey: Long) : HostApi {',
        ),
      );
      expect(code, contains('@Keep\ninterface FlutterApi {'));
      expect(code, contains('@Keep\nclass FlutterApiRegistrar() {'));
    });

    test('is not added when not using JNI', () {
      final String code = generate(useJni: false);
      expect(code, contains('class FooError ('));
      expect(code, contains('enum class AnEnum('));
      expect(code, contains('data class DataClass ('));
      expect(code, isNot(contains('@Keep')));
      expect(code, isNot(contains('import androidx.annotation.Keep')));
    });
  });

  test('do not generate duplicated entries in writeValue', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'FooBar',
          methods: <Method>[
            Method(
              name: 'fooBar',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  name: 'bar',
                  type: const TypeDeclaration(baseName: 'Bar', isNullable: false),
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Foo',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'int', isNullable: false),
              name: 'foo',
            ),
          ],
        ),
        Class(
          name: 'Bar',
          fields: <NamedType>[
            NamedType(
              type: const TypeDeclaration(baseName: 'Foo', isNullable: false),
              name: 'foo',
            ),
            NamedType(
              type: const TypeDeclaration(baseName: 'Foo', isNullable: true),
              name: 'foo2',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );

    final sink = StringBuffer();
    const errorClassName = 'FooError';
    const kotlinOptions = InternalKotlinOptions(errorClassName: errorClassName, kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);

    final code = sink.toString();

    // Extract override fun writeValue block
    final int blockStart = code.indexOf('override fun writeValue');
    expect(blockStart, isNot(-1));
    final int blockEnd = code.indexOf('super.writeValue', blockStart);
    expect(blockEnd, isNot(-1));
    final String writeValueBlock = code.substring(blockStart, blockEnd);

    // Count the occurrence of 'is Foo' in the block
    var count = 0;
    var index = 0;
    while (index != -1) {
      index = writeValueBlock.indexOf('is Foo', index);
      if (index != -1) {
        count++;
        index += 'is Foo'.length;
      }
    }

    // There should be only one occurrence of 'is Foo' in the block
    expect(count, 1);
  });

  test('data class equality', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('override fun equals(other: Any?): Boolean {'));
    expect(code, contains('override fun hashCode(): Int {'));
  });

  test('data class equality multi-field', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'field1',
        ),
        NamedType(
          type: const TypeDeclaration(baseName: 'String', isNullable: true),
          name: 'field2',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('override fun equals(other: Any?): Boolean {'));
    expect(code, contains('override fun hashCode(): Int {'));
  });

  test('data class toString', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('override fun toString(): String {'));
    expect(code, contains(r'return "Foobar(field1=$field1)"'));
  });

  test('data class toString multi-field', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(baseName: 'int', isNullable: true),
          name: 'field1',
        ),
        NamedType(
          type: const TypeDeclaration(baseName: 'String', isNullable: true),
          name: 'field2',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('override fun toString(): String {'));
    expect(code, contains(r'return "Foobar(field1=$field1, field2=$field2)"'));
  });

  test('gen constants', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[],
      enums: <Enum>[],
      constants: <Constant>[
        Constant(
          name: 'stringConst',
          type: const TypeDeclaration(baseName: 'String', isNullable: false),
          value: 'hello',
        ),
        Constant(
          name: 'intConst',
          type: const TypeDeclaration(baseName: 'int', isNullable: false),
          value: 42,
        ),
        Constant(
          name: 'doubleConst',
          type: const TypeDeclaration(baseName: 'double', isNullable: false),
          value: 3.14,
        ),
        Constant(
          name: 'boolConst',
          type: const TypeDeclaration(baseName: 'bool', isNullable: false),
          value: true,
        ),
        Constant(
          name: 'stringWithBackslashDollar',
          type: const TypeDeclaration(baseName: 'String', isNullable: false),
          value: r'\$',
        ),
        Constant(
          name: 'stringWithTwoBackslashesDollar',
          type: const TypeDeclaration(baseName: 'String', isNullable: false),
          value: r'\\$',
        ),
      ],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('const val stringConst: String = "hello"'));
    expect(code, contains('const val intConst: Long = 42L'));
    expect(code, contains('const val doubleConst: Double = 3.14'));
    expect(code, contains('const val boolConst: Boolean = true'));
    expect(code, contains(r'const val stringWithBackslashDollar: String = "\\\$"'));
    expect(code, contains(r'const val stringWithTwoBackslashesDollar: String = "\\\\\$"'));
  });

  test(
    'kotlin generator handles HostApi and FlutterApi multi-instance registration and unregister',
    () {
      final root = Root(
        apis: <Api>[
          AstHostApi(
            name: 'HostApi',
            methods: <Method>[
              Method(
                name: 'doSomething',
                location: ApiLocation.host,
                returnType: const TypeDeclaration.voidDeclaration(),
                parameters: <Parameter>[],
              ),
            ],
          ),
          AstFlutterApi(
            name: 'FlutterApi',
            methods: <Method>[
              Method(
                name: 'onEvent',
                location: ApiLocation.flutter,
                returnType: const TypeDeclaration.voidDeclaration(),
                parameters: <Parameter>[],
              ),
            ],
          ),
        ],
        classes: <Class>[],
        enums: <Enum>[],
      );
      final sink = StringBuffer();
      const kotlinOptions = InternalKotlinOptions(kotlinOut: '', useJni: true);
      const generator = KotlinGenerator();
      generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
      final code = sink.toString();
      expect(
        code,
        contains('val HostApiInstances: MutableMap<String, MutableList<HostApiRegistrar>>'),
      );
      expect(code, isNot(contains('private val HostApiInstances')));
      expect(
        code,
        contains('private const val defaultInstanceName = "$defaultNativeInteropInstanceName"'),
      );
      expect(code, contains('interface HostApi {'));
      expect(
        code,
        contains(
          'class HostApiRegistrar private constructor(private val engineKey: Long) : HostApi {',
        ),
      );
      expect(code, contains('constructor() : this(PigeonEngineKeys.NO_KEY)'));
      expect(code, isNot(contains('api: HostApi?,')));
      expect(
        code,
        isNot(contains('fun register(api: HostApi, name: String = defaultInstanceName)')),
      );
      expect(code, isNot(contains('): HostApiRegistrar {')));
      expect(code, isNot(contains('name: String?')));
      expect(code, isNot(contains('resolvedName')));
      expect(code, contains('HostApiInstances.remove(name)'));
      expect(code, isNot(contains('fun getInstance(name: String')));
      expect(code, contains('private var api: HostApi? = null'));
      expect(code, contains('@Volatile private var api: HostApi? = null'));
      expect(
        code,
        contains('throw FlutterError("unregistered-instance", "HostApi has not been registered.")'),
      );
      expect(code, isNot(contains('error("HostApi has not been registered")')));
      expect(code, contains('kotlin.synchronized(HostApiInstances) {'));
      expect(code, isNot(contains('HostApiInstances[name]?.lastOrNull()')));
      expect(
        code,
        contains('val index = list.indexOfFirst { it.api === api && it.engineKey == engineKey }'),
      );
      expect(code, contains('list.add(list.removeAt(index))'));
      expect(code, contains('val wrapper = HostApiRegistrar(engineKey)'));
      expect(code, contains(' * Registers [api] under [name]'));
      expect(code, contains(' * Instances are matched by identity.'));
      expect(code, isNot(contains(' * Returns an instance registered under [name]')));
      expect(
        code,
        contains(
          'val registeredFlutterApi: MutableMap<String, MutableList<FlutterApiRegistration>>',
        ),
      );
      expect(code, isNot(contains('private val registeredFlutterApi')));
      expect(
        code,
        contains(
          'class FlutterApiRegistration(val api: FlutterApi, val engineId: Long, val affinityKey: Long)',
        ),
      );
      expect(code, isNot(contains('private class FlutterApiRegistration')));
      expect(code, contains('class FlutterApiRegistrar() {'));
      expect(code, contains('registeredFlutterApi.remove(name)'));
      expect(
        code,
        isNot(contains('fun getInstance(name: String = defaultInstanceName): FlutterApi?')),
      );
    },
  );

  group('JNI engine-keyed registration', () {
    Root buildRoot({bool host = true, bool flutter = true}) {
      return Root(
        apis: <Api>[
          if (host)
            AstHostApi(
              name: 'HostApi',
              methods: <Method>[
                Method(
                  name: 'doSomething',
                  location: ApiLocation.host,
                  returnType: const TypeDeclaration.voidDeclaration(),
                  parameters: <Parameter>[],
                ),
              ],
            ),
          if (flutter)
            AstFlutterApi(
              name: 'FlutterApi',
              methods: <Method>[
                Method(
                  name: 'onEvent',
                  location: ApiLocation.flutter,
                  returnType: const TypeDeclaration.voidDeclaration(),
                  parameters: <Parameter>[],
                ),
              ],
            ),
        ],
        classes: <Class>[],
        enums: <Enum>[],
      );
    }

    String generate(Root root, {bool useJni = true, String? fileSpecificClassNameComponent}) {
      final sink = StringBuffer();
      const KotlinGenerator().generate(
        InternalKotlinOptions(
          kotlinOut: '',
          useJni: useJni,
          fileSpecificClassNameComponent: fileSpecificClassNameComponent,
        ),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      return sink.toString();
    }

    void expectInOrder(String code, List<String> snippets) {
      var previous = -1;
      for (final snippet in snippets) {
        final int index = code.indexOf(snippet);
        expect(index, greaterThan(previous), reason: 'Expected "$snippet" after previous snippet');
        previous = index;
      }
    }

    test('imports Flutter engine types only when there is a host or Flutter API', () {
      const engineImport = 'import io.flutter.embedding.engine.FlutterEngine';
      const pluginImport = 'import io.flutter.embedding.engine.plugins.FlutterPlugin';
      final String withHost = generate(buildRoot(flutter: false));
      expect(withHost, contains(engineImport));
      expect(withHost, contains(pluginImport));
      final String withFlutter = generate(buildRoot(host: false));
      expect(withFlutter, contains(engineImport));
      expect(withFlutter, contains(pluginImport));
      final String withNone = generate(buildRoot(host: false, flutter: false));
      expect(withNone, isNot(contains(engineImport)));
      expect(withNone, isNot(contains('PigeonEngineKeys')));
      final String nonJni = generate(buildRoot(), useJni: false);
      expect(nonJni, isNot(contains(engineImport)));
      expect(nonJni, isNot(contains('PigeonEngineKeys')));
    });

    test('emits a file-private engine key helper', () {
      final String code = generate(buildRoot());
      expect(code, contains('private object PigeonEngineKeys {'));
      expect(code, contains('const val NO_KEY: Long = Long.MIN_VALUE'));
      expect(code, contains('private val getEngineIdMethod: java.lang.reflect.Method? by lazy {'));
      expect(
        code,
        contains('FlutterPlugin.FlutterPluginBinding::class.java.getMethod("getEngineId")'),
      );
      expect(code, contains('val engineId = method.invoke(binding) as Long'));
      expect(code, contains('if (engineId != 0L) {'));
      expect(
        code,
        contains('@Synchronized\n  fun keyOf(binding: FlutterPlugin.FlutterPluginBinding): Long {'),
      );
      expect(code, contains('@Synchronized\n  private fun keyOfMessenger(messenger: Any): Long {'));
      expect(code, contains('private val messengerKeys = java.util.WeakHashMap<Any, Long>()'));
      expect(code, contains('private var nextSyntheticKey: Long = -1L'));
      expect(code, contains('fun keyOf(binding: FlutterPlugin.FlutterPluginBinding): Long {'));
      expect(code, contains('return keyOfMessenger(binding.binaryMessenger)'));
      expect(code, contains('fun keyOf(engine: FlutterEngine): Long {'));
      expect(code, contains('val key = engine.engineId'));
      expect(code, contains('messengerKeys[engine.dartExecutor] = key'));
      expect(code, contains('messengerKeys.getOrPut(messenger) { nextSyntheticKey-- }'));
      expect(code, isNot(contains('flutterEngine')));
      expect(code, isNot(contains('getFlutterEngine')));
    });

    test('engine key helper name is file-specific', () {
      final String code = generate(buildRoot(), fileSpecificClassNameComponent: 'Foo');
      expect(code, contains('private object FooPigeonEngineKeys {'));
      expect(code, contains('FooPigeonEngineKeys.keyOf(binding)'));
      expect(code, contains('FooPigeonEngineKeys.NO_KEY'));
    });

    test('host API registrar members are declared in the order Dart expects', () {
      final String code = generate(buildRoot(flutter: false));
      expectInOrder(code, <String>[
        'fun register(api: HostApi, binding: FlutterPlugin.FlutterPluginBinding, name: String = defaultInstanceName) {',
        'fun register(api: HostApi, engine: FlutterEngine, name: String = defaultInstanceName) {',
        'fun unregister(api: HostApi, binding: FlutterPlugin.FlutterPluginBinding, name: String = defaultInstanceName) {',
        'fun unregister(api: HostApi, engine: FlutterEngine, name: String = defaultInstanceName) {',
        'private fun registerWithKey(',
        'private fun unregisterWithKey(',
        'companion object {',
        'fun pigeonResolveInstance(engineId: Long, affinityKey: Long, name: String = defaultInstanceName): HostApiRegistrar? {',
        'fun pigeonEngineKeyOf(instance: HostApiRegistrar): Long {',
        'override fun doSomething()',
      ]);
      // Only the Dart-facing internal helpers are static.
      expect('@JvmStatic\n    @Keep\n    fun '.allMatches(code).length, 2);
    });

    test('host API register and unregister compute engine keys', () {
      final String code = generate(buildRoot(flutter: false));
      expect(code, contains('registerWithKey(api, PigeonEngineKeys.keyOf(binding), name)'));
      expect(code, contains('registerWithKey(api, PigeonEngineKeys.keyOf(engine), name)'));
      expect(code, contains('unregisterWithKey(api, PigeonEngineKeys.keyOf(binding), name)'));
      expect(code, contains('unregisterWithKey(api, PigeonEngineKeys.keyOf(engine), name)'));
    });

    test('host API unregister falls back to identity only for a single engine', () {
      final String code = generate(buildRoot(flutter: false));
      expectInOrder(code, <String>[
        'if (list.any { it.api === api && it.engineKey == engineKey }) {',
        'list.filter { it.api === api }.map { it.engineKey }.distinct().singleOrNull() ?: return',
        'if (entry.api === api && entry.engineKey == removeKey) {',
      ]);
      expect(code, contains('entry.api = null'));
      expect(code, isNot(contains('!matchKey')));
    });

    test('engine keys are cached per binding', () {
      final String code = generate(buildRoot(flutter: false));
      expect(
        code,
        contains(
          'private val bindingKeys = java.util.WeakHashMap<FlutterPlugin.FlutterPluginBinding, Long>()',
        ),
      );
      expect(code, contains('return bindingKeys.getOrPut(binding) { computeKey(binding) }'));
    });

    test('host API resolves by engine id, then affinity, then most recent registration', () {
      final String code = generate(buildRoot(flutter: false));
      expectInOrder(code, <String>[
        'return kotlin.synchronized(HostApiInstances) {',
        'val list = HostApiInstances[name] ?: return null',
        'val exact = if (engineId != PigeonEngineKeys.NO_KEY) list.lastOrNull { it.engineKey == engineId } else null',
        'val affine = if (affinityKey != PigeonEngineKeys.NO_KEY) list.lastOrNull { it.engineKey == affinityKey } else null',
        'exact ?: affine ?: list.lastOrNull()',
      ]);
      expect(code, contains('return instance.engineKey'));
    });

    test('Flutter API registrar methods are declared in the order Dart expects', () {
      final String code = generate(buildRoot(host: false));
      expectInOrder(code, <String>[
        'fun registerInstance(api: FlutterApi, engineId: Long, affinityKey: Long, name: String = defaultInstanceName) {',
        'fun unregisterInstance(api: FlutterApi, name: String = defaultInstanceName) {',
        'fun getInstance(binding: FlutterPlugin.FlutterPluginBinding, name: String = defaultInstanceName): FlutterApi? {',
        'fun getInstance(engine: FlutterEngine, name: String = defaultInstanceName): FlutterApi? {',
        'private fun getInstanceWithKey(engineKey: Long, name: String): FlutterApi? {',
      ]);
      expect(code, isNot(contains('@JvmStatic')));
      expect(code, isNot(contains('companion object')));
    });

    test('Flutter API registration dedups by identity and looks up by engine', () {
      final String code = generate(buildRoot(host: false));
      expectInOrder(code, <String>[
        'val index = list.indexOfFirst { it.api === api }',
        'list[index] = registration',
        'list.add(registration)',
      ]);
      expect(
        code,
        contains('val registration = FlutterApiRegistration(api, engineId, affinityKey)'),
      );
      expect(code, contains('return getInstanceWithKey(PigeonEngineKeys.keyOf(binding), name)'));
      expect(code, contains('return getInstanceWithKey(PigeonEngineKeys.keyOf(engine), name)'));
      expectInOrder(code, <String>[
        'if (engineKey != PigeonEngineKeys.NO_KEY) {',
        'val match = list.lastOrNull { it.engineId == engineKey } ?: list.lastOrNull { it.affinityKey == engineKey }',
        'return list.lastOrNull()?.api',
      ]);
      expect(code, isNot(contains('it.engineId == engineKey || it.affinityKey == engineKey')));
    });
  });

  test('asyncCallback emits callback-based host api method', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              isAsynchronous: true,
              isAsynchronousCallback: true,
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('fun doit(callback: (Result<Long?>) -> Unit'));
  });

  test('async method with TaskQueue generates CoroutineScope(Dispatchers.Unconfined)', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              isAsynchronous: true,
              taskQueueType: TaskQueueType.serialBackgroundThread,
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const kotlinOptions = InternalKotlinOptions(kotlinOut: '');
    const generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();
    expect(code, contains('suspend fun doit(): Long?'));
    expect(code, contains('CoroutineScope(Dispatchers.Unconfined).launch'));
    expect(code, isNot(contains('CoroutineScope(Dispatchers.Main).launch')));
  });
}
