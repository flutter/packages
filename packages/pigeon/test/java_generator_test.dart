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
      fields: <Field>[
        Field(
          name: 'field1',
          dataType: 'int',
          isNullable: true,
        ),
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
      fields: <Field>[
        Field(
          name: 'field1',
          dataType: 'int',
          isNullable: true,
        )
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
          argType: 'Input',
          isArgNullable: true,
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <Field>[
        Field(name: 'input', dataType: 'String', isNullable: true)
      ]),
      Class(name: 'Output', fields: <Field>[
        Field(name: 'output', dataType: 'String', isNullable: true)
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
      Class(name: 'Foobar', fields: <Field>[
        Field(name: 'aBool', dataType: 'bool', isNullable: true),
        Field(name: 'aInt', dataType: 'int', isNullable: true),
        Field(name: 'aDouble', dataType: 'double', isNullable: true),
        Field(name: 'aString', dataType: 'String', isNullable: true),
        Field(name: 'aUint8List', dataType: 'Uint8List', isNullable: true),
        Field(name: 'aInt32List', dataType: 'Int32List', isNullable: true),
        Field(name: 'aInt64List', dataType: 'Int64List', isNullable: true),
        Field(name: 'aFloat64List', dataType: 'Float64List', isNullable: true),
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
          argType: 'Input',
          isArgNullable: false,
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <Field>[
        Field(name: 'input', dataType: 'String', isNullable: true)
      ]),
      Class(name: 'Output', fields: <Field>[
        Field(name: 'output', dataType: 'String', isNullable: true)
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
          argType: 'Input',
          isArgNullable: false,
          returnType: 'void',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <Field>[
        Field(name: 'input', dataType: 'String', isNullable: true)
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
          argType: 'Input',
          isArgNullable: false,
          returnType: 'void',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <Field>[
        Field(name: 'input', dataType: 'String', isNullable: true)
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
          argType: 'void',
          isArgNullable: false,
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <Field>[
        Field(name: 'output', dataType: 'String', isNullable: true)
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
          argType: 'void',
          isArgNullable: false,
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <Field>[
        Field(name: 'output', dataType: 'String', isNullable: true)
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
      Class(name: 'Foobar', fields: <Field>[
        Field(name: 'field1', dataType: 'List', isNullable: true)
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
      Class(name: 'Foobar', fields: <Field>[
        Field(name: 'field1', dataType: 'Map', isNullable: true)
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
      fields: <Field>[
        Field(
          name: 'nested',
          dataType: 'Nested',
          isNullable: true,
        )
      ],
    );
    final Class nestedClass = Class(
      name: 'Nested',
      fields: <Field>[
        Field(
          name: 'data',
          dataType: 'int',
          isNullable: true,
        )
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
    expect(code, contains('put("nested", nested.toMap());'));
  });

  test('gen one async Host Api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          isArgNullable: false,
          returnType: 'Output',
          isAsynchronous: true,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <Field>[
        Field(name: 'input', dataType: 'String', isNullable: true)
      ]),
      Class(name: 'Output', fields: <Field>[
        Field(name: 'output', dataType: 'String', isNullable: true)
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public interface Api'));
    expect(code, contains('public interface Result<T> {'));
    expect(
        code, contains('void doSomething(Input arg, Result<Output> result);'));
    expect(
        code,
        contains(
            'api.doSomething(input, result -> { wrapped.put("result", result.toMap()); reply.reply(wrapped); });'));
    expect(code, contains('channel.setMessageHandler(null)'));
  });

  test('gen one async Flutter Api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          isArgNullable: false,
          returnType: 'Output',
          isAsynchronous: true,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <Field>[
        Field(name: 'input', dataType: 'String', isNullable: true)
      ]),
      Class(name: 'Output', fields: <Field>[
        Field(name: 'output', dataType: 'String', isNullable: true)
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
      fields: <Field>[
        Field(
          name: 'enum1',
          dataType: 'Enum1',
          isNullable: true,
        ),
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

    expect(code, contains('toMapResult.put("enum1", enum1.index);'));
    expect(code, contains('fromMapResult.enum1 = Enum1.values()[(int)enum1];'));
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
}
