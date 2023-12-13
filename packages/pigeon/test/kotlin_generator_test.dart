// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/kotlin_generator.dart';
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
  test('gen one class', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'int',
            isNullable: true,
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
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar ('));
    expect(code, contains('val field1: Long? = null'));
    expect(code, contains('fun fromList(list: List<Any?>): Foobar'));
    expect(code, contains('fun toList(): List<Any?>'));
  });

  test('gen one enum', () {
    final Enum anEnum = Enum(
      name: 'Foobar',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum class Foobar(val raw: Int) {'));
    expect(code, contains('ONE(0)'));
    expect(code, contains('TWO(1)'));
  });

  test('gen class with enum', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Bar',
          fields: <NamedType>[
            NamedType(
              name: 'field1',
              type: TypeDeclaration(
                baseName: 'Foo',
                isNullable: false,
                associatedEnum: emptyEnum,
              ),
            ),
            NamedType(
              name: 'field2',
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: false,
              ),
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
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum class Foo(val raw: Int) {'));
    expect(code, contains('data class Bar ('));
    expect(code, contains('val field1: Foo,'));
    expect(code, contains('val field2: String'));
    expect(code, contains('fun fromList(list: List<Any?>): Bar'));
    expect(code, contains('val field1 = Foo.ofRaw(list[0] as Int)!!\n'));
    expect(code, contains('val field2 = list[1] as String\n'));
    expect(code, contains('fun toList(): List<Any?>'));
  });

  test('primitive enum host', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Bar', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'bar',
            returnType: const TypeDeclaration.voidDeclaration(),
            parameters: <Parameter>[
              Parameter(
                  name: 'foo',
                  type: TypeDeclaration(
                    baseName: 'Foo',
                    isNullable: false,
                    associatedEnum: emptyEnum,
                  ))
            ])
      ])
    ], classes: <Class>[], enums: <Enum>[
      Enum(name: 'Foo', members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ])
    ]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum class Foo(val raw: Int) {'));
    expect(code, contains('val fooArg = Foo.ofRaw(args[0] as Int)'));
  });

  test('gen one host api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              name: 'input',
            )
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            associatedClass: emptyClass,
            isNullable: false,
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
          name: 'input',
        )
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'String',
            isNullable: true,
          ),
          name: 'output',
        )
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('interface Api'));
    expect(code, contains('fun doSomething(input: Input): Output'));
    expect(code, contains('channel.setMessageHandler'));
    expect(code, contains('''
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val inputArg = args[0] as Input
            var wrapped: List<Any?>
            try {
              wrapped = listOf<Any?>(api.doSomething(inputArg))
            } catch (exception: Throwable) {
              wrapped = wrapError(exception)
            }
            reply.reply(wrapped)
          }
        } else {
          channel.setMessageHandler(null)
        }
    '''));
  });

  test('all the simple datatypes header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'bool',
            isNullable: false,
          ),
          name: 'aBool',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'int',
            isNullable: false,
          ),
          name: 'aInt',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'double',
            isNullable: false,
          ),
          name: 'aDouble',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'String',
            isNullable: false,
          ),
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
            isNullable: false,
          ),
          name: 'aInt32List',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Int64List',
            isNullable: false,
          ),
          name: 'aInt64List',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Float64List',
            isNullable: false,
          ),
          name: 'aFloat64List',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'bool',
            isNullable: true,
          ),
          name: 'aNullableBool',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'int',
            isNullable: true,
          ),
          name: 'aNullableInt',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'double',
            isNullable: true,
          ),
          name: 'aNullableDouble',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'String',
            isNullable: true,
          ),
          name: 'aNullableString',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Uint8List',
            isNullable: true,
          ),
          name: 'aNullableUint8List',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Int32List',
            isNullable: true,
          ),
          name: 'aNullableInt32List',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Int64List',
            isNullable: true,
          ),
          name: 'aNullableInt64List',
        ),
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Float64List',
            isNullable: true,
          ),
          name: 'aNullableFloat64List',
        ),
      ]),
    ], enums: <Enum>[]);

    final StringBuffer sink = StringBuffer();

    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('val aBool: Boolean'));
    expect(code, contains('val aInt: Long'));
    expect(code, contains('val aDouble: Double'));
    expect(code, contains('val aString: String'));
    expect(code, contains('val aUint8List: ByteArray'));
    expect(code, contains('val aInt32List: IntArray'));
    expect(code, contains('val aInt64List: LongArray'));
    expect(code, contains('val aFloat64List: DoubleArray'));
    expect(
        code,
        contains(
            'val aInt = list[1].let { if (it is Int) it.toLong() else it as Long }'));
    expect(code, contains('val aNullableBool: Boolean? = null'));
    expect(code, contains('val aNullableInt: Long? = null'));
    expect(code, contains('val aNullableDouble: Double? = null'));
    expect(code, contains('val aNullableString: String? = null'));
    expect(code, contains('val aNullableUint8List: ByteArray? = null'));
    expect(code, contains('val aNullableInt32List: IntArray? = null'));
    expect(code, contains('val aNullableInt64List: LongArray? = null'));
    expect(code, contains('val aNullableFloat64List: DoubleArray? = null'));
    expect(
        code,
        contains(
            'val aNullableInt = list[9].let { if (it is Int) it.toLong() else it as Long? }'));
  });

  test('gen one flutter api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              name: '',
            )
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            associatedClass: emptyClass,
            isNullable: false,
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
          name: 'input',
        )
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'String',
            isNullable: true,
          ),
          name: 'output',
        )
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code,
        contains('class Api(private val binaryMessenger: BinaryMessenger)'));
    expect(code, matches('fun doSomething.*Input.*Output'));
  });

  test('gen host void api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              name: '',
            )
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
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
        )
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(matches('.*doSomething(.*) ->')));
    expect(code, matches('doSomething(.*)'));
  });

  test('gen flutter void return api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              name: '',
            )
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
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
        )
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('callback: (Result<Unit>) -> Unit'));
    expect(code, contains('callback(Result.success(Unit))'));
    // Lines should not end in semicolons.
    expect(code, isNot(contains(RegExp(r';\n'))));
  });

  test('gen host void argument api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[],
          returnType: TypeDeclaration(
            baseName: 'Output',
            associatedClass: emptyClass,
            isNullable: false,
          ),
        )
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'String',
            isNullable: true,
          ),
          name: 'output',
        )
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doSomething(): Output'));
    expect(code, contains('wrapped = listOf<Any?>(api.doSomething())'));
    expect(code, contains('wrapped = wrapError(exception)'));
    expect(code, contains('reply(wrapped)'));
  });

  test('gen flutter void argument api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[],
          returnType: TypeDeclaration(
            baseName: 'Output',
            associatedClass: emptyClass,
            isNullable: false,
          ),
        )
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'String',
            isNullable: true,
          ),
          name: 'output',
        )
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code, contains('fun doSomething(callback: (Result<Output>) -> Unit)'));
    expect(code, contains('channel.send(null)'));
  });

  test('gen list', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'List',
            isNullable: true,
          ),
          name: 'field1',
        )
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: List<Any?>? = null'));
  });

  test('gen map', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'Map',
            isNullable: true,
          ),
          name: 'field1',
        )
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: Map<Any, Any?>? = null'));
  });

  test('gen nested', () {
    final Class classDefinition = Class(
      name: 'Outer',
      fields: <NamedType>[
        NamedType(
          type: TypeDeclaration(
            baseName: 'Nested',
            associatedClass: emptyClass,
            isNullable: true,
          ),
          name: 'nested',
        )
      ],
    );
    final Class nestedClass = Class(
      name: 'Nested',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'int',
            isNullable: true,
          ),
          name: 'data',
        )
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition, nestedClass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Outer'));
    expect(code, contains('data class Nested'));
    expect(code, contains('val nested: Nested? = null'));
    expect(code, contains('fun fromList(list: List<Any?>): Outer'));
    expect(
        code, contains('val nested: Nested? = (list[0] as List<Any?>?)?.let'));
    expect(code, contains('Nested.fromList(it)'));
    expect(code, contains('fun toList(): List<Any?>'));
  });

  test('gen one async Host Api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              name: 'arg',
            )
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            associatedClass: emptyClass,
            isNullable: false,
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
          name: 'input',
        )
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'String',
            isNullable: true,
          ),
          name: 'output',
        )
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('interface Api'));
    expect(code, contains('api.doSomething(argArg) {'));
    expect(code, contains('reply.reply(wrapResult(data))'));
  });

  test('gen one async Flutter Api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              name: '',
            )
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            associatedClass: emptyClass,
            isNullable: false,
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
          name: 'input',
        )
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'String',
            isNullable: true,
          ),
          name: 'output',
        )
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('fun doSomething.*Input.*callback.*Output.*Unit'));
  });

  test('gen one enum class', () {
    final Enum anEnum = Enum(
      name: 'Enum1',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ],
    );
    final Class classDefinition = Class(
      name: 'EnumClass',
      fields: <NamedType>[
        NamedType(
          type: TypeDeclaration(
            baseName: 'Enum1',
            associatedEnum: emptyEnum,
            isNullable: true,
          ),
          name: 'enum1',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum class Enum1(val raw: Int)'));
    expect(code, contains('ONE(0)'));
    expect(code, contains('TWO(1)'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    final KotlinOptions kotlinOptions = KotlinOptions(
      copyrightHeader: makeIterable('hello world'),
    );
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('generics - list', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
              baseName: 'List',
              isNullable: true,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(baseName: 'int', isNullable: true)
              ]),
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
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: List<Long?>'));
  });

  test('generics - maps', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
              baseName: 'Map',
              isNullable: true,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(baseName: 'String', isNullable: true),
                TypeDeclaration(baseName: 'String', isNullable: true),
              ]),
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
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('data class Foobar'));
    expect(code, contains('val field1: Map<String?, String?>'));
  });

  test('host generics argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                      baseName: 'List',
                      isNullable: false,
                      typeArguments: <TypeDeclaration>[
                        TypeDeclaration(baseName: 'int', isNullable: true)
                      ]),
                  name: 'arg',
                )
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(arg: List<Long?>'));
  });

  test('flutter generics argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                      baseName: 'List',
                      isNullable: false,
                      typeArguments: <TypeDeclaration>[
                        TypeDeclaration(baseName: 'int', isNullable: true)
                      ]),
                  name: 'arg',
                )
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(argArg: List<Long?>'));
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
              parameters: <Parameter>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(): List<Long?>'));
    expect(code, contains('wrapped = listOf<Any?>(api.doit())'));
    expect(code, contains('reply.reply(wrapped)'));
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
              parameters: <Parameter>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(callback: (Result<List<Long?>>) -> Unit)'));
    expect(code, contains('val output = it[0] as List<Long?>'));
    expect(code, contains('callback(Result.success(output))'));
  });

  test('host multiple args', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'add',
          parameters: <Parameter>[
            Parameter(
                name: 'x',
                type:
                    const TypeDeclaration(isNullable: false, baseName: 'int')),
            Parameter(
                name: 'y',
                type:
                    const TypeDeclaration(isNullable: false, baseName: 'int')),
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun add(x: Long, y: Long): Long'));
    expect(code, contains('val args = message as List<Any?>'));
    expect(
        code,
        contains(
            'val xArg = args[0].let { if (it is Int) it.toLong() else it as Long }'));
    expect(
        code,
        contains(
            'val yArg = args[1].let { if (it is Int) it.toLong() else it as Long }'));
    expect(code, contains('wrapped = listOf<Any?>(api.add(xArg, yArg))'));
    expect(code, contains('reply.reply(wrapped)'));
  });

  test('flutter multiple args', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'add',
          parameters: <Parameter>[
            Parameter(
                name: 'x',
                type:
                    const TypeDeclaration(baseName: 'int', isNullable: false)),
            Parameter(
                name: 'y',
                type:
                    const TypeDeclaration(baseName: 'int', isNullable: false)),
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('val channel = BasicMessageChannel'));
    expect(
      code,
      contains(
          'val output = it[0].let { if (it is Int) it.toLong() else it as Long }'),
    );
    expect(code, contains('callback(Result.success(output))'));
    expect(
        code,
        contains(
            'fun add(xArg: Long, yArg: Long, callback: (Result<Long>) -> Unit)'));
    expect(code, contains('channel.send(listOf(xArg, yArg)) {'));
  });

  test('return nullable host', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              parameters: <Parameter>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(): Long?'));
  });

  test('return nullable host async', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              isAsynchronous: true,
              parameters: <Parameter>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('fun doit(callback: (Result<Long?>) -> Unit'));
  });

  test('nullable argument host', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
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
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'val fooArg = args[0].let { if (it is Int) it.toLong() else it as Long? }'));
  });

  test('nullable argument flutter', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
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
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains('fun doit(fooArg: Long?, callback: (Result<Unit>) -> Unit)'),
    );
  });

  test('nonnull fields', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
              type: TypeDeclaration(
                baseName: 'Input',
                associatedClass: emptyClass,
                isNullable: false,
              ),
              name: '',
            )
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
          type: const TypeDeclaration(
            baseName: 'String',
            isNullable: false,
          ),
          name: 'input',
        )
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('val input: String\n'));
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
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    for (final String comment in comments) {
      // This regex finds the comment only between the open and close comment block
      expect(
          RegExp(r'(?<=\/\*\*.*?)' + comment + r'(?=.*?\*\/)', dotAll: true)
              .hasMatch(code),
          true);
    }
    expect(code, isNot(contains('*//')));
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
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(contains(' : StandardMessageCodec() ')));
    expect(code, contains('StandardMessageCodec'));
  });

  test('creates custom codecs if custom datatypes present', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          parameters: <Parameter>[
            Parameter(
                type: TypeDeclaration(
                  baseName: 'Input',
                  associatedClass: emptyClass,
                  isNullable: false,
                ),
                name: '')
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            associatedClass: emptyClass,
            isNullable: false,
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
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(' : StandardMessageCodec() '));
  });

  test('creates api error class for custom errors', () {
    final Method method = Method(
        name: 'doSomething',
        returnType: const TypeDeclaration.voidDeclaration(),
        parameters: <Parameter>[]);
    final Api api = Api(
        name: 'SomeApi', location: ApiLocation.host, methods: <Method>[method]);
    final Root root = Root(
      apis: <Api>[api],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const KotlinOptions kotlinOptions =
        KotlinOptions(errorClassName: 'SomeError');
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class SomeError'));
    expect(code, contains('if (exception is SomeError)'));
    expect(code, contains('exception.code,'));
    expect(code, contains('exception.message,'));
    expect(code, contains('exception.details'));
  });

  test('connection error contains channel name', () {
    final Root root = Root(
      apis: <Api>[
        Api(
          name: 'Api',
          location: ApiLocation.flutter,
          methods: <Method>[
            Method(
              name: 'method',
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
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'return FlutterError("channel-error",  "Unable to establish connection on channel: \'\$channelName\'.", "")'));
    expect(
        code,
        contains(
            'callback(Result.failure(createConnectionError(channelName)))'));
  });

  test('gen host uses default error class', () {
    final Root root = Root(
      apis: <Api>[
        Api(
          name: 'Api',
          location: ApiLocation.host,
          methods: <Method>[
            Method(
              name: 'method',
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
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('FlutterError'));
  });

  test('gen flutter uses default error class', () {
    final Root root = Root(
      apis: <Api>[
        Api(
          name: 'Api',
          location: ApiLocation.flutter,
          methods: <Method>[
            Method(
              name: 'method',
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
    const KotlinOptions kotlinOptions = KotlinOptions();
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('FlutterError'));
  });

  test('gen host uses error class', () {
    final Root root = Root(
      apis: <Api>[
        Api(
          name: 'Api',
          location: ApiLocation.host,
          methods: <Method>[
            Method(
              name: 'method',
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
    const String errorClassName = 'FooError';
    const KotlinOptions kotlinOptions =
        KotlinOptions(errorClassName: errorClassName);
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(errorClassName));
    expect(code, isNot(contains('FlutterError')));
  });

  test('gen flutter uses error class', () {
    final Root root = Root(
      apis: <Api>[
        Api(
          name: 'Api',
          location: ApiLocation.flutter,
          methods: <Method>[
            Method(
              name: 'method',
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
    const String errorClassName = 'FooError';
    const KotlinOptions kotlinOptions =
        KotlinOptions(errorClassName: errorClassName);
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(errorClassName));
    expect(code, isNot(contains('FlutterError')));
  });
}
