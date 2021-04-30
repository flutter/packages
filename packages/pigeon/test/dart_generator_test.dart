// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/dart_generator.dart';
import 'package:pigeon/generator_tools.dart';
import 'package:test/test.dart';

void main() {
  test('gen one class', () {
    final Class klass = Class(
      name: 'Foobar',
      fields: <Field>[
        Field(
          name: 'field1',
          dataType: 'dataType1',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[klass],
    );
    final StringBuffer sink = StringBuffer();
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  dataType1 field1;'));
  });

  test('gen one host api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'Output',
          isAsynchronous: false,
        )
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
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('Output.*doSomething.*Input'));
  });

  test('nested class', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(
        name: 'Input',
        fields: <Field>[Field(name: 'input', dataType: 'String')],
      ),
      Class(
        name: 'Nested',
        fields: <Field>[Field(name: 'nested', dataType: 'Input')],
      )
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(
      code,
      contains(
        'pigeonMap[\'nested\'] = nested == null ? null : nested.encode()',
      ),
    );
    expect(
      code.replaceAll('\n', ' ').replaceAll('  ', ''),
      contains(
        '..nested = pigeonMap[\'nested\'] != null ? Input.decode(pigeonMap[\'nested\']) : null;',
      ),
    );
  });

  test('flutterapi', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'Output',
          isAsynchronous: false,
        )
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
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('static void setup(Api'));
  });

  test('host void', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'void',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, contains('Future<void> doSomething'));
    expect(code, contains('// noop'));
  });

  test('flutter void return', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'void',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    // The next line verifies that we're not setting a variable to the value of "doSomething", but
    // ignores the line where we assert the value of the argument isn't null, since on that line
    // we mention "doSomething" in the assertion message.
    expect(code, isNot(matches('[^!]=.*doSomething')));
    expect(code, contains('doSomething('));
    expect(code, isNot(contains('.encode()')));
  });

  test('flutter void argument', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'void',
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, matches('output.*=.*doSomething[(][)]'));
    expect(code, contains('Output doSomething();'));
  });

  test('host void argument', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'void',
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, matches('channel.send[(]null[)]'));
  });

  test('mock dart handler', () {
    final Root root = Root(apis: <Api>[
      Api(
          name: 'Api',
          location: ApiLocation.host,
          dartHostTestHandler: 'ApiMock',
          methods: <Method>[
            Method(
              name: 'doSomething',
              argType: 'Input',
              returnType: 'Output',
              isAsynchronous: false,
            ),
            Method(
              name: 'voidReturner',
              argType: 'Input',
              returnType: 'void',
              isAsynchronous: false,
            )
          ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')])
    ]);
    final StringBuffer mainCodeSink = StringBuffer();
    final StringBuffer testCodeSink = StringBuffer();
    generateDart(DartOptions(isNullSafe: false), root, mainCodeSink);
    final String mainCode = mainCodeSink.toString();
    expect(mainCode, isNot(contains('import \'fo\\\'o.dart\';')));
    expect(mainCode, contains('class Api {'));
    expect(mainCode, isNot(contains('abstract class ApiMock')));
    expect(mainCode, isNot(contains('.ApiMock.doSomething')));
    expect(mainCode, isNot(contains('\'${Keys.result}\': output.encode()')));
    expect(mainCode, isNot(contains('return <Object, Object>{};')));
    generateTestDart(
        DartOptions(isNullSafe: false), root, testCodeSink, "fo'o.dart");
    final String testCode = testCodeSink.toString();
    expect(testCode, contains('import \'fo\\\'o.dart\';'));
    expect(testCode, isNot(contains('class Api {')));
    expect(testCode, contains('abstract class ApiMock'));
    expect(testCode, isNot(contains('.ApiMock.doSomething')));
    expect(testCode, contains('\'${Keys.result}\': output.encode()'));
    expect(testCode, contains('return <Object, Object>{};'));
  });

  test('opt out of nndb', () {
    final Class klass = Class(
      name: 'Foobar',
      fields: <Field>[
        Field(
          name: 'field1',
          dataType: 'dataType1',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[klass],
    );
    final StringBuffer sink = StringBuffer();
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, contains('// @dart = 2.8'));
  });

  test('gen one async Flutter Api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'Output',
          isAsynchronous: true,
        )
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
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('Future<Output> doSomething(Input arg);'));
    expect(
        code, contains('final Output output = await api.doSomething(input);'));
  });

  test('gen one async Flutter Api with void return', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'void',
          isAsynchronous: true,
        )
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
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, isNot(matches('=.s*doSomething')));
    expect(code, contains('await api.doSomething('));
    expect(code, isNot(contains('._toMap()')));
  });

  test('gen one async Host Api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'Output',
          isAsynchronous: true,
        )
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
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('Output.*doSomething.*Input'));
  });

  test('async host void argument', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'void',
          returnType: 'Output',
          isAsynchronous: true,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    generateDart(DartOptions(isNullSafe: false), root, sink);
    final String code = sink.toString();
    expect(code, matches('channel.send[(]null[)]'));
  });
}
