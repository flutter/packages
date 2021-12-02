// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/java_generator.dart';
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
            name: 'field1',
            offset: null),
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
    expect(code, contains('private Long field1;'));
  });

  test('gen one enum', () {
    final Enum anEnum = Enum(
      name: 'Foobar',
      members: <String>[
        'one',
        'two',
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
    expect(code, contains('    one(0),'));
    expect(code, contains('    two(1);'));
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
            name: 'field1',
            offset: null)
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
                name: '',
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public interface Api'));
    expect(code, matches('Output.*doSomething.*Input'));
    expect(code, contains('channel.setMessageHandler(null)'));
  });

  test('all the simple datatypes header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'bool',
              isNullable: true,
            ),
            name: 'aBool',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: true,
            ),
            name: 'aInt',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'double',
              isNullable: true,
            ),
            name: 'aDouble',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'aString',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Uint8List',
              isNullable: true,
            ),
            name: 'aUint8List',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Int32List',
              isNullable: true,
            ),
            name: 'aInt32List',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Int64List',
              isNullable: true,
            ),
            name: 'aInt64List',
            offset: null),
        NamedType(
            type: const TypeDeclaration(
              baseName: 'Float64List',
              isNullable: true,
            ),
            name: 'aFloat64List',
            offset: null),
      ]),
    ], enums: <Enum>[]);

    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('private Boolean aBool;'));
    expect(code, contains('private Long aInt;'));
    expect(code, contains('private Double aDouble;'));
    expect(code, contains('private String aString;'));
    expect(code, contains('private byte[] aUint8List;'));
    expect(code, contains('private int[] aInt32List;'));
    expect(code, contains('private long[] aInt64List;'));
    expect(code, contains('private double[] aFloat64List;'));
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
                name: '',
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
                name: '',
                offset: null)
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
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
                name: '',
                offset: null)
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
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
          isAsynchronous: false,
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
            offset: null)
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
          isAsynchronous: false,
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
            offset: null)
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
            name: 'field1',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Foobar'));
    expect(code, contains('private List<Object> field1;'));
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
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Foobar'));
    expect(code, contains('private Map<Object, Object> field1;'));
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
            name: 'nested',
            offset: null)
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
            offset: null)
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
    expect(code, contains('private Nested nested;'));
    expect(code, contains('Nested.fromMap((Map)nested);'));
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
                name: 'arg',
                offset: null)
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
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public interface Api'));
    expect(code, contains('public interface Result<T> {'));
    expect(code, contains('void error(Throwable error);'));
    expect(
        code, contains('void doSomething(Input arg, Result<Output> result);'));
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
                name: '',
                offset: null)
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
        'two',
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
            name: 'enum1',
            offset: null),
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
    expect(code, contains('    one(0),'));
    expect(code, contains('    two(1);'));
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
            'fromMapResult.enum1 = enum1 == null ? null : Enum1.values()[(int)enum1];'));
  });

  Iterable<String> _makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(
      className: 'Messages',
      copyrightHeader: _makeIterable('hello world'),
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
            name: 'field1',
            offset: null),
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
            name: 'field1',
            offset: null),
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
                    name: 'arg',
                    offset: null)
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
    expect(code, contains('doit(List<Long> arg'));
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
                    name: 'arg',
                    offset: null)
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
    expect(code, contains('doit(List<Long> arg'));
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
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('class Messages'));
    expect(code, contains('Long add(Long x, Long y)'));
    expect(
        code, contains('ArrayList<Object> args = (ArrayList<Object>)message;'));
    expect(code, contains('Number xArg = (Number)args.get(0)'));
    expect(code, contains('Number yArg = (Number)args.get(1)'));
    expect(code,
        contains('Long output = api.add(xArg.longValue(), yArg.longValue())'));
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
          isAsynchronous: false,
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
            'public void add(Long xArg, Long yArg, Reply<Long> callback)'));
    expect(
        code,
        contains(
            'channel.send(new ArrayList<Object>(Arrays.asList(xArg, yArg)), channelReply ->'));
  });
}
