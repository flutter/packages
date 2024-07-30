// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/java_generator.dart';
import 'package:pigeon/pigeon.dart';
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
            name: 'field1'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public class Messages'));
    expect(code, contains('public static final class Foobar'));
    expect(code, contains('public static final class Builder'));
    expect(code, contains('private @Nullable Long field1;'));
    expect(code, contains('@CanIgnoreReturnValue'));
  });

  test('gen one enum', () {
    final Enum anEnum = Enum(
      name: 'Foobar',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'twoThreeFour'),
        EnumMember(name: 'remoteDB'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public enum Foobar'));
    expect(code, contains('    ONE(0),'));
    expect(code, contains('    TWO_THREE_FOUR(1),'));
    expect(code, contains('    REMOTE_DB(2);'));
    expect(code, contains('final int index;'));
    expect(code, contains('private Foobar(final int index) {'));
    expect(code, contains('      this.index = index;'));
  });

  test('package', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: true,
            ),
            name: 'field1')
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions =
        JavaOptions(className: 'Messages', package: 'com.google.foobar');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('package com.google.foobar;'));
    expect(code, contains('ArrayList<Object> toList()'));
  });

  test('gen one host api', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
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
                name: '')
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public interface Api'));
    expect(code, matches('Output.*doSomething.*Input'));
    expect(code, contains('channel.setMessageHandler(null)'));
    expect(
        code,
        contains(
            'protected Object readValueOfType(byte type, @NonNull ByteBuffer buffer)'));
    expect(
        code,
        contains(
            'protected void writeValue(@NonNull ByteArrayOutputStream stream, Object value)'));
    expect(
        code,
        contains(RegExp(
            r'@NonNull\s*protected static ArrayList<Object> wrapError\(@NonNull Throwable exception\)')));
    expect(code, isNot(contains('ArrayList ')));
    expect(code, isNot(contains('ArrayList<>')));
  });

  test('all the simple datatypes header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: true,
            ),
            name: 'aBool'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: true,
            ),
            name: 'aInt'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'double',
              isNullable: true,
            ),
            name: 'aDouble'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'aString'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Uint8List',
              isNullable: true,
            ),
            name: 'aUint8List'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Int32List',
              isNullable: true,
            ),
            name: 'aInt32List'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Int64List',
              isNullable: true,
            ),
            name: 'aInt64List'),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Float64List',
              isNullable: true,
            ),
            name: 'aFloat64List'),
      ]),
    ], enums: <Enum>[]);

    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('private @Nullable Boolean aBool;'));
    expect(code, contains('private @Nullable Long aInt;'));
    expect(code, contains('private @Nullable Double aDouble;'));
    expect(code, contains('private @Nullable String aString;'));
    expect(code, contains('private @Nullable byte[] aUint8List;'));
    expect(code, contains('private @Nullable int[] aInt32List;'));
    expect(code, contains('private @Nullable long[] aInt64List;'));
    expect(code, contains('private @Nullable double[] aFloat64List;'));
  });

  test('gen one flutter api', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
                name: '')
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public static class Api'));
    expect(code, matches('doSomething.*Input.*Output'));
  });

  test('gen host void api', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
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
                name: '')
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
            name: 'input')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(matches('=.*doSomething')));
    expect(code, contains('doSomething('));
  });

  test('gen flutter void return api', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
                name: '')
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
            name: 'input')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'public void doSomething(@NonNull Input arg0Arg, @NonNull VoidResult result)'));
    expect(code, contains('result.success();'));
  });

  test('gen host void argument api', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
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
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Output doSomething()'));
    expect(code, contains('api.doSomething()'));
  });

  test('gen flutter void argument api', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.flutter,
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
            name: 'output')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code,
        contains('public void doSomething(@NonNull Result<Output> result)'));
    expect(code, contains(RegExp(r'channel.send\(\s*null')));
  });

  test('gen list', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'List',
              isNullable: true,
            ),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public static final class Foobar'));
    expect(code, contains('private @Nullable List<Object> field1;'));
  });

  test('gen map', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Map',
              isNullable: true,
            ),
            name: 'field1')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public static final class Foobar'));
    expect(code, contains('private @Nullable Map<Object, Object> field1;'));
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
            name: 'nested')
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
            name: 'data')
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition, nestedClass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public class Messages'));
    expect(code, contains('public static final class Outer'));
    expect(code, contains('public static final class Nested'));
    expect(code, contains('private @Nullable Nested nested;'));
    expect(code, contains('add(nested);'));
  });

  test('gen one async Host Api', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
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
                name: 'arg')
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public interface Api'));
    expect(code, contains('public interface Result<T> {'));
    expect(code, contains('void error(@NonNull Throwable error);'));
    expect(
        code,
        contains(
            'void doSomething(@NonNull Input arg, @NonNull Result<Output> result);'));
    expect(code, contains('api.doSomething(argArg, resultCallback);'));
    expect(code, contains('channel.setMessageHandler(null)'));
  });

  test('gen one async Flutter Api', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public static class Api'));
    expect(code, matches('doSomething.*Input.*Output'));
  });

  test('gen one enum class', () {
    final Enum anEnum = Enum(
      name: 'Enum1',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'twoThreeFour'),
        EnumMember(name: 'remoteDB'),
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
            name: 'enum1'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public enum Enum1'));
    expect(code, contains('    ONE(0),'));
    expect(code, contains('    TWO_THREE_FOUR(1),'));
    expect(code, contains('    REMOTE_DB(2);'));
    expect(code, contains('final int index;'));
    expect(code, contains('private Enum1(final int index) {'));
    expect(code, contains('      this.index = index;'));

    expect(code, contains('toListResult.add(enum1);'));
    expect(code, contains('pigeonResult.setEnum1((Enum1) enum1);'));
  });

  test('primitive enum host', () {
    final Root root = Root(apis: <Api>[
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
                  isNullable: true,
                  associatedEnum: emptyEnum,
                ),
              )
            ])
      ])
    ], classes: <Class>[], enums: <Enum>[
      Enum(name: 'Foo', members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
      ])
    ]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public enum Foo'));
    expect(code,
        contains('return value == null ? null : Foo.values()[(int) value];'));
    expect(
        code,
        contains(
            'writeValue(stream, value == null ? null : ((Foo) value).index);'));
    expect(code, contains('Foo fooArg = (Foo) args.get(0);'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(
      className: 'Messages',
      copyrightHeader: makeIterable('hello world'),
    );
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('generics', () {
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
            name: 'field1'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('List<Long> field1;'));
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
            name: 'field1'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('Map<String, String> field1;'));
  });

  test('host generics argument', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
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
                          TypeDeclaration(baseName: 'int', isNullable: true)
                        ]),
                    name: 'arg')
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('doit(@NonNull List<Long> arg'));
  });

  test('flutter generics argument', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(name: 'Api', methods: <Method>[
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
                          TypeDeclaration(baseName: 'int', isNullable: true)
                        ]),
                    name: 'arg')
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('doit(@NonNull List<Long> arg'));
  });

  test('host generics return', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
          Method(
              name: 'doit',
              location: ApiLocation.host,
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('List<Long> doit('));
    expect(code, contains('List<Long> output ='));
  });

  test('flutter generics return', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(name: 'Api', methods: <Method>[
          Method(
              name: 'doit',
              location: ApiLocation.flutter,
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code, contains('public void doit(@NonNull Result<List<Long>> result)'));
    expect(code, contains('List<Long> output = (List<Long>) listReply.get(0)'));
  });

  test('flutter int return', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(name: 'Api', methods: <Method>[
          Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType:
                  const TypeDeclaration(baseName: 'int', isNullable: false),
              parameters: <Parameter>[],
              isAsynchronous: true)
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('public void doit(@NonNull Result<Long> result)'));
    expect(
        code,
        contains(
            'Long output = listReply.get(0) == null ? null : ((Number) listReply.get(0)).longValue();'));
  });

  test('host multiple args', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'add',
          location: ApiLocation.host,
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Messages'));
    expect(code, contains('Long add(@NonNull Long x, @NonNull Long y)'));
    expect(code,
        contains('ArrayList<Object> args = (ArrayList<Object>) message;'));
    expect(code, contains('Number xArg = (Number) args.get(0)'));
    expect(code, contains('Number yArg = (Number) args.get(1)'));
    expect(
        code,
        contains(
            'Long output = api.add((xArg == null) ? null : xArg.longValue(), (yArg == null) ? null : yArg.longValue())'));
  });

  test('if host argType is Object not cast', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'objectTest',
          location: ApiLocation.host,
          parameters: <Parameter>[
            Parameter(
                name: 'x',
                type: const TypeDeclaration(
                    isNullable: false, baseName: 'Object')),
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Api');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Object xArg = args.get(0)'));
  });

  test('flutter multiple args', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
        Method(
          name: 'add',
          location: ApiLocation.flutter,
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Messages'));
    expect(code, contains('BasicMessageChannel<Object> channel'));
    expect(code, contains('Long output'));
    expect(
        code,
        contains(
            'public void add(@NonNull Long xArg, @NonNull Long yArg, @NonNull Result<Long> result)'));
    expect(
        code,
        contains(RegExp(
            r'channel.send\(\s*new ArrayList<Object>\(Arrays.asList\(xArg, yArg\)\),\s*channelReply ->')));
  });

  test('flutter single args', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
        Method(
          name: 'send',
          location: ApiLocation.flutter,
          parameters: <Parameter>[
            Parameter(
                name: 'x',
                type:
                    const TypeDeclaration(isNullable: false, baseName: 'int')),
          ],
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(RegExp(
            r'channel.send\(\s*new ArrayList<Object>\(Collections.singletonList\(xArg\)\),\s*channelReply ->')));
  });

  test('return nullable host', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
          Method(
              name: 'doit',
              location: ApiLocation.host,
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(RegExp(r'@Nullable\s*Long doit\(\);')));
  });

  test('return nullable host async', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
          Method(
              name: 'doit',
              location: ApiLocation.host,
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    // Java doesn't accept nullability annotations in type arguments.
    expect(code, contains('Result<Long>'));
  });

  test('nullable argument host', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
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
                    )),
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('  void doit(@Nullable Long foo);'));
  });

  test('nullable argument flutter', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(name: 'Api', methods: <Method>[
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
                    )),
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'public void doit(@Nullable Long fooArg, @NonNull VoidResult result) {'));
  });

  test('background platform channel', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
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
                    )),
              ],
              taskQueueType: TaskQueueType.serialBackgroundThread)
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'BinaryMessenger.TaskQueue taskQueue = binaryMessenger.makeBackgroundTaskQueue();'));
    expect(
        code,
        contains(RegExp(
            r'new BasicMessageChannel<>\(\s*binaryMessenger, "dev.flutter.pigeon.test_package.Api.doit" \+ messageChannelSuffix, getCodec\(\), taskQueue\)')));
  });

  test('generated annotation', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions =
        JavaOptions(className: 'Messages', useGeneratedAnnotation: true);
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('@javax.annotation.Generated("dev.flutter.pigeon")'));
  });

  test('no generated annotation', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code,
        isNot(contains('@javax.annotation.Generated("dev.flutter.pigeon")')));
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
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

  test('creates custom codecs', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(' extends StandardMessageCodec'));
  });

  test('creates api error class for custom errors', () {
    final Api api = AstHostApi(name: 'Api', methods: <Method>[]);
    final Root root = Root(
      apis: <Api>[api],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class FlutterError'));
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
    const JavaGenerator generator = JavaGenerator();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('createConnectionError(channelName)'));
    expect(
        code,
        contains(
            'return new FlutterError("channel-error",  "Unable to establish connection on channel: " + channelName + ".", "");'));
  });
}
