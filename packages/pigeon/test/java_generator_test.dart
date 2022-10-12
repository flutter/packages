// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/java_generator.dart';
import 'package:pigeon/pigeon.dart';
import 'package:test/test.dart';

void main() {
  test('gen one class', () {
    final Class klass = Class(
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
      classes: <Class>[klass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public class Messages'));
    expect(code, contains('public static class Foobar'));
    expect(code, contains('public static final class Builder'));
    expect(code, contains('private @Nullable Long field1;'));
    expect(
        code,
        contains(
            '@NonNull private static Map<String, Object> wrapError(@NonNull Throwable exception)'));
  });

  test('gen one enum', () {
    final Enum anEnum = Enum(
      name: 'Foobar',
      members: <String>[
        'one',
        'twoThreeFour',
        'remoteDB',
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public enum Foobar'));
    expect(code, contains('    ONE(0),'));
    expect(code, contains('    TWO_THREE_FOUR(1),'));
    expect(code, contains('    REMOTE_DB(2);'));
    expect(code, contains('private int index;'));
    expect(code, contains('private Foobar(final int index) {'));
    expect(code, contains('      this.index = index;'));
  });

  test('package', () {
    final Class klass = Class(
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
      classes: <Class>[klass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions =
        JavaOptions(className: 'Messages', package: 'com.google.foobar');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('package com.google.foobar;'));
    expect(code, contains('Map<String, Object> toMap()'));
  });

  test('gen one host api', () {
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
    generateJava(javaOptions, root, sink);
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
    generateJava(javaOptions, root, sink);
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
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Api'));
    expect(code, matches('doSomething.*Input.*Output'));
  });

  test('gen host void api', () {
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
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, isNot(matches('=.*doSomething')));
    expect(code, contains('doSomething('));
  });

  test('gen flutter void return api', () {
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
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('Reply<Void>'));
    expect(code, contains('callback.reply(null)'));
  });

  test('gen host void argument api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[],
          returnType:
              const TypeDeclaration(baseName: 'Output', isNullable: false),
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
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('Output doSomething()'));
    expect(code, contains('api.doSomething()'));
  });

  test('gen flutter void argument api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          arguments: <NamedType>[],
          returnType:
              const TypeDeclaration(baseName: 'Output', isNullable: false),
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
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('doSomething(Reply<Output>'));
    expect(code, contains('channel.send(null'));
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
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Foobar'));
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
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Foobar'));
    expect(code, contains('private @Nullable Map<Object, Object> field1;'));
  });

  test('gen nested', () {
    final Class klass = Class(
      name: 'Outer',
      fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Nested',
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
      classes: <Class>[klass, nestedClass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public class Messages'));
    expect(code, contains('public static class Outer'));
    expect(code, contains('public static class Nested'));
    expect(code, contains('private @Nullable Nested nested;'));
    expect(code,
        contains('(nested == null) ? null : Nested.fromMap((Map)nested)'));
    expect(code,
        contains('put("nested", (nested == null) ? null : nested.toMap());'));
  });

  test('gen one async Host Api', () {
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
                name: 'arg')
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public interface Api'));
    expect(code, contains('public interface Result<T> {'));
    expect(code, contains('void error(Throwable error);'));
    expect(
        code,
        contains(
            'void doSomething(@NonNull Input arg, Result<Output> result);'));
    expect(code, contains('api.doSomething(argArg, resultCallback);'));
    expect(code, contains('channel.setMessageHandler(null)'));
  });

  test('gen one async Flutter Api', () {
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Api'));
    expect(code, matches('doSomething.*Input.*Output'));
  });

  test('gen one enum class', () {
    final Enum anEnum = Enum(
      name: 'Enum1',
      members: <String>[
        'one',
        'twoThreeFour',
        'remoteDB',
      ],
    );
    final Class klass = Class(
      name: 'EnumClass',
      fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Enum1',
              isNullable: true,
            ),
            name: 'enum1'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[klass],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public enum Enum1'));
    expect(code, contains('    ONE(0),'));
    expect(code, contains('    TWO_THREE_FOUR(1),'));
    expect(code, contains('    REMOTE_DB(2);'));
    expect(code, contains('private int index;'));
    expect(code, contains('private Enum1(final int index) {'));
    expect(code, contains('      this.index = index;'));

    expect(
        code,
        contains(
            'toMapResult.put("enum1", enum1 == null ? null : enum1.index);'));
    expect(
        code,
        contains(
            'pigeonResult.setEnum1(enum1 == null ? null : Enum1.values()[(int)enum1])'));
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
                      const TypeDeclaration(baseName: 'Foo', isNullable: true))
            ])
      ])
    ], classes: <Class>[], enums: <Enum>[
      Enum(name: 'Foo', members: <String>['one', 'two'])
    ]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public enum Foo'));
    expect(
        code,
        contains(
            'Foo fooArg = args.get(0) == null ? null : Foo.values()[(int)args.get(0)];'));
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
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('generics', () {
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('List<Long> field1;'));
  });

  test('generics - maps', () {
    final Class klass = Class(
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
      classes: <Class>[klass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('Map<String, String> field1;'));
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('doit(@NonNull List<Long> arg'));
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('doit(@NonNull List<Long> arg'));
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('List<Long> doit('));
    expect(code, contains('List<Long> output ='));
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('doit(Reply<List<Long>> callback)'));
    expect(code, contains('List<Long> output ='));
  });

  test('flutter int return', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType:
                  const TypeDeclaration(baseName: 'int', isNullable: false),
              arguments: <NamedType>[],
              isAsynchronous: true)
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('doit(Reply<Long> callback)'));
    expect(
        code,
        contains(
            'Long output = channelReply == null ? null : ((Number)channelReply).longValue();'));
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('class Messages'));
    expect(code, contains('Long add(@NonNull Long x, @NonNull Long y)'));
    expect(
        code, contains('ArrayList<Object> args = (ArrayList<Object>)message;'));
    expect(code, contains('Number xArg = (Number)args.get(0)'));
    expect(code, contains('Number yArg = (Number)args.get(1)'));
    expect(
        code,
        contains(
            'Long output = api.add((xArg == null) ? null : xArg.longValue(), (yArg == null) ? null : yArg.longValue())'));
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('class Messages'));
    expect(code, contains('BasicMessageChannel<Object> channel'));
    expect(code, contains('Long output'));
    expect(
        code,
        contains(
            'public void add(@NonNull Long xArg, @NonNull Long yArg, Reply<Long> callback)'));
    expect(
        code,
        contains(
            'channel.send(new ArrayList<Object>(Arrays.asList(xArg, yArg)), channelReply ->'));
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
              arguments: <NamedType>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('@Nullable Long doit();'));
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
              arguments: <NamedType>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    // Java doesn't accept nullability annotations in type arguments.
    expect(code, contains('Result<Long>'));
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('  void doit(@Nullable Long foo);'));
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            'public void doit(@Nullable Long fooArg, Reply<Void> callback) {'));
  });

  test('background platform channel', () {
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
              ],
              taskQueueType: TaskQueueType.serialBackgroundThread)
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            'BinaryMessenger.TaskQueue taskQueue = binaryMessenger.makeBackgroundTaskQueue();'));
    expect(
        code,
        contains(
            'new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.Api.doit", getCodec(), taskQueue)'));
  });

  test('generated annotation', () {
    final Class klass = Class(
      name: 'Foobar',
      fields: <NamedType>[],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[klass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions =
        JavaOptions(className: 'Messages', useGeneratedAnnotation: true);
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('@javax.annotation.Generated("dev.flutter.pigeon")'));
  });

  test('no generated annotation', () {
    final Class klass = Class(
      name: 'Foobar',
      fields: <NamedType>[],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[klass],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
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
    ];
    int count = 0;

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
          documentationComments: <String>[comments[count++]],
          members: <String>[
            'one',
            'two',
          ],
        ),
      ],
    );
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    for (final String comment in comments) {
      // This regex finds the comment only between the open and close comment block
      expect(
          RegExp(r'(?<=\/\*\*.*?)' + comment + r'(?=.*?\*\/)', dotAll: true)
              .hasMatch(code),
          true);
    }
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, isNot(contains(' extends StandardMessageCodec')));
    expect(code, contains('StandardMessageCodec'));
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
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains(' extends StandardMessageCodec'));
  });
}
