// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:pigeon/java_generator.dart';
import 'package:pigeon/ast.dart';

void main() {
  test('gen one class', () {
    final Class klass = Class()
      ..name = 'Foobar'
      ..fields = <Field>[
        Field()
          ..name = 'field1'
          ..dataType = 'int'
      ];
    final Root root = Root()
      ..apis = <Api>[]
      ..classes = <Class>[klass];
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions();
    javaOptions.className = 'Messages';
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public class Messages'));
    expect(code, contains('public static class Foobar'));
    expect(code, contains('private int field1;'));
  });

  test('package', () {
    final Class klass = Class()
      ..name = 'Foobar'
      ..fields = <Field>[
        Field()
          ..name = 'field1'
          ..dataType = 'int'
      ];
    final Root root = Root()
      ..apis = <Api>[]
      ..classes = <Class>[klass];
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions();
    javaOptions.className = 'Messages';
    javaOptions.package = 'com.google.foobar';
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('package com.google.foobar;'));
    expect(code, contains('HashMap toMap()'));
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
    final JavaOptions javaOptions = JavaOptions();
    javaOptions.className = 'Messages';
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public interface Api'));
    expect(code, matches('Output.*doSomething.*Input'));
  });
}
