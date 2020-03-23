// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:pigeon/dart_generator.dart';
import 'package:pigeon/ast.dart';

void main() {
  test('gen one class', () {
    final Class klass = Class()
      ..name = 'Foobar'
      ..fields = <Field>[
        Field()
          ..name = 'field1'
          ..dataType = 'dataType1'
      ];
    final Root root = Root()
      ..apis = <Api>[]
      ..classes = <Class>[klass];
    final StringBuffer sink = StringBuffer();
    generateDart(root, sink);
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  dataType1 field1;'));
  });

  test('gen one host api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(name: 'doSomething', argType: 'Input', returnType: 'Output')
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')])
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(root, sink);
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('Output.*doSomething.*Input'));
  });

  test('nested class', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
      Class(
          name: 'Nested',
          fields: <Field>[Field(name: 'nested', dataType: 'Input')])
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(root, sink);
    final String code = sink.toString();
    expect(code, contains('dartleMap["nested"] = nested._toMap()'));
    expect(
        code, contains('result.nested = Input._fromMap(dartleMap["nested"]);'));
  });

  test('flutterapi', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(name: 'doSomething', argType: 'Input', returnType: 'Output')
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')])
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(root, sink);
    final String code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('void ApiSetup(Api'));
  });

  test('host void', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(name: 'doSomething', argType: 'Input', returnType: 'void')
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(root, sink);
    final String code = sink.toString();
    expect(code, contains('Future<void> doSomething'));
    expect(code, contains('// noop'));
  });

  test('flutter void', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(name: 'doSomething', argType: 'Input', returnType: 'void')
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(root, sink);
    final String code = sink.toString();
    expect(code, isNot(matches('=.*doSomething')));
    expect(code, contains('doSomething('));
    expect(code, isNot(contains('._toMap()')));
  });
}
