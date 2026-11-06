// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Directory, File;

import 'package:path/path.dart' as path;
import 'package:pigeon/src/ast.dart';
import 'package:pigeon/src/dart/dart_generator.dart';
import 'package:pigeon/src/generator_tools.dart';
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
          type: TypeDeclaration(
            baseName: 'dataType1',
            isNullable: true,
            associatedClass: emptyClass,
          ),
          name: 'field1',
        ),
      ],
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  dataType1? field1;'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('enum Foobar'));
    expect(code, contains('  one,'));
    expect(code, contains('  two;'));
  });

  test('gen event channel api with usage docs on the generated method', () {
    final api = AstEventChannelApi(
      name: 'EventApi',
      methods: <Method>[
        Method(
          name: 'streamEvents',
          location: ApiLocation.host,
          returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
          parameters: <Parameter>[],
          documentationComments: <String>[' An example event stream.'],
        ),
      ],
    );
    final root = Root(apis: <Api>[api], classes: <Class>[], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Stream<int> streamEvents('));
    // The user's own documentation comments are emitted.
    expect(code, contains('/// An example event stream.'));
    // The generated usage documentation explains the channel-owning and
    // broadcast semantics.
    expect(
      code,
      contains('/// Returns a broadcast [Stream] of events from the `streamEvents` event channel.'),
    );
    expect(code, contains('not be called multiple times for the same `instanceName`'));
    // The usage documentation is attached directly above the generated method.
    expect(
      code.indexOf('not be called multiple times'),
      lessThan(code.indexOf('Stream<int> streamEvents(')),
    );
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: 'input',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('Future<Output> doSomething(Input input)'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('Future<int> add(int x, int y)'));
    expect(code, contains('pigeonVar_sendFuture = pigeonVar_channel.send(<Object?>[x, y])'));
    expect(code, contains('await pigeonVar_sendFuture'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('int add(int x, int y)'));
    expect(code, contains('final List<Object?> args = message! as List<Object?>'));
    expect(code, contains('final int arg_x = args[0]! as int'));
    expect(code, contains('final int arg_y = args[1]! as int'));
    expect(code, contains('final int output = api.add(arg_x, arg_y)'));
  });

  test('nested class', () {
    final root = Root(
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
                isNullable: true,
                associatedClass: emptyClass,
              ),
              name: 'nested',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('nested,'));
    expect(code, contains('nested: result[0] as Input?'));
  });

  test('nested non-nullable class', () {
    final root = Root(
      apis: <Api>[],
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
        Class(
          name: 'Nested',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(
                baseName: 'Input',
                isNullable: false,
                associatedClass: emptyClass,
              ),
              name: 'nested',
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('nested,'));
    expect(code, contains('nested: result[0]! as Input'));
  });

  test('flutterApi', () {
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: 'input',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('static void setUp(Api'));
    expect(code, contains('Output doSomething(Input input)'));
  });

  test('host void', () {
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
                    isNullable: false,
                    associatedClass: emptyClass,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<void> doSomething'));
  });

  test('flutter void return', () {
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
                    isNullable: false,
                    associatedClass: emptyClass,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    // The next line verifies that we're not setting a variable to the value of "doSomething", but
    // ignores the line where we assert the value of the argument isn't null, since on that line
    // we mention "doSomething" in the assertion message.
    expect(code, isNot(matches('[^!]=.*doSomething')));
    expect(code, contains('doSomething('));
  });

  test('flutter void argument', () {
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
                isNullable: false,
                associatedClass: emptyClass,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, matches('output.*=.*doSomething[(][)]'));
    expect(code, contains('Output doSomething();'));
  });

  test('flutter enum argument with enum class', () {
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
                    baseName: 'EnumClass',
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: 'enumClass',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'EnumClass',
                isNullable: false,
                associatedClass: emptyClass,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'EnumClass',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(baseName: 'Enum', isNullable: true, associatedEnum: emptyEnum),
              name: 'enum1',
            ),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'Enum',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('return value == null ? null : Enum.values[value];'));
    expect(code, contains('writeValue(buffer, value.index);'));
    expect(code, contains('final EnumClass arg_enumClass = args[0]! as EnumClass;'));
    expect(code, contains('EnumClass doSomething(EnumClass enumClass);'));
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
                    isNullable: true,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('enum Foo {'));
    expect(code, contains('Future<void> bar(Foo? foo) async'));
    expect(code, contains('pigeonVar_sendFuture = pigeonVar_channel.send(<Object?>[foo])'));
    expect(code, contains('await pigeonVar_sendFuture'));
  });

  test('flutter non-nullable enum argument with enum class', () {
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
                    baseName: 'EnumClass',
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'EnumClass',
                isNullable: false,
                associatedClass: emptyClass,
              ),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'EnumClass',
          fields: <NamedType>[
            NamedType(
              type: TypeDeclaration(baseName: 'Enum', isNullable: false, associatedEnum: emptyEnum),
              name: 'enum1',
            ),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'Enum',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('writeValue(buffer, value.index)'));
    expect(code, contains('return value == null ? null : Enum.values[value];'));
    expect(code, contains('enum1: result[0]! as Enum,'));
  });

  test('host void argument', () {
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
                isNullable: false,
                associatedClass: emptyClass,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, matches('pigeonVar_sendFuture = pigeonVar_channel.send[(]null[)]'));
  });

  test('mock Dart handler', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          dartHostTestHandler: 'ApiMock',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
              ),
            ),
            Method(
              name: 'voidReturner',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                    associatedClass: emptyClass,
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
    final mainCodeSink = StringBuffer();
    final testCodeSink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      mainCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final mainCode = mainCodeSink.toString();
    expect(mainCode, isNot(contains(r"import 'fo\'o.dart';")));
    expect(mainCode, contains('class Api {'));
    expect(mainCode, isNot(contains('abstract class ApiMock')));
    expect(mainCode, isNot(contains('.ApiMock.doSomething')));
    expect(mainCode, isNot(contains("'${Keys.result}': output")));
    expect(mainCode, isNot(contains('return <Object>[];')));

    const testGenerator = DartGenerator();
    testGenerator.generateTest(
      const InternalDartOptions(dartOut: "fo'o.dart", testOut: 'test.dart', ignoreLints: false),
      root,
      testCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );
    final testCode = testCodeSink.toString();
    expect(testCode, contains(r"import 'fo\'o.dart';"));
    expect(testCode, isNot(contains('class Api {')));
    expect(testCode, contains('abstract class ApiMock'));
    expect(testCode, isNot(contains('.ApiMock.doSomething')));
    expect(testCode, contains('output'));
    expect(testCode, contains('return <Object?>[output];'));
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: 'input',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('Future<Output> doSomething(Input input);'));
    expect(code, contains('final Output output = await api.doSomething(arg_input);'));
  });

  test('gen one async Flutter Api with void return', () {
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, isNot(matches('=.s*doSomething')));
    expect(code, contains('await api.doSomething('));
    expect(code, isNot(contains('._toMap()')));
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('Output.*doSomething.*Input'));
  });

  test('async host void argument', () {
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
                isNullable: false,
                associatedClass: emptyClass,
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
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, matches('pigeonVar_channel.send[(]null[)]'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final sink = StringBuffer();

    const generator = DartGenerator();
    generator.generate(
      InternalDartOptions(copyrightHeader: makeIterable('hello world'), ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('generics', () {
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  List<int?>? field1;'));
  });

  test('map generics', () {
    final classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
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
    );
    final root = Root(apis: <Api>[], classes: <Class>[classDefinition], enums: <Enum>[]);
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  Map<String?, int?>? field1;'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('doit(List<int?> arg'));
  });

  test('flutter generics argument with void return', () {
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('doit(List<int?> arg'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<List<int?>> doit('));
    expect(code, contains('return (pigeonVar_replyValue! as List<Object?>).cast<int?>();'));
  });

  test('flutter generics argument non void return', () {
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
              parameters: <Parameter>[
                Parameter(
                  type: const TypeDeclaration(
                    baseName: 'List',
                    isNullable: false,
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(baseName: 'int', isNullable: true),
                    ],
                  ),
                  name: 'foo',
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('List<int?> doit('));
    expect(code, contains('final List<int?> arg_foo = (args[0]! as List<Object?>).cast<int?>()'));
    expect(code, contains('final List<int?> output = api.doit(arg_foo)'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<int?> doit()'));
    expect(code, contains('return pigeonVar_replyValue as int?;'));
  });

  test('return nullable collection host', () {
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
                isNullable: true,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<List<int?>?> doit()'));
    expect(code, contains('return (pigeonVar_replyValue as List<Object?>?)?.cast<int?>();'));
  });

  test('return nullable async host', () {
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
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<int?> doit()'));
    expect(code, contains('return pigeonVar_replyValue as int?;'));
  });

  test('return nullable flutter', () {
    final root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('int? doit();'));
    expect(code, contains('final int? output = api.doit();'));
  });

  test('return nullable async flutter', () {
    final root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: true),
              parameters: <Parameter>[],
              isAsynchronous: true,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<int?> doit();'));
    expect(code, contains('final int? output = await api.doit();'));
  });

  test('platform error for return nil on nonnull', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
      containsHostApi: true,
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Host platform returned null value for non-null return value.'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('Future<void> doit(int? foo) async {'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('void doit(int? foo);'));
  });

  test('named argument flutter', () {
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
                  type: const TypeDeclaration(baseName: 'int', isNullable: false),
                  isNamed: true,
                  isPositional: false,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('void doit({required int foo});'));
    expect(code, contains('api.doit(foo: arg_foo)'));
  });

  test('uses output package name for imports', () {
    const overriddenPackageName = 'custom_name';
    const outputPackageName = 'some_output_package';
    assert(outputPackageName != DEFAULT_PACKAGE_NAME);
    final Directory tempDir = Directory.systemTemp.createTempSync('pigeon');
    try {
      final foo = Directory(path.join(tempDir.path, 'lib', 'foo'));
      foo.createSync(recursive: true);
      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
name: foobar
''');
      final root = Root(classes: <Class>[], apis: <Api>[], enums: <Enum>[]);
      final sink = StringBuffer();
      const testGenerator = DartGenerator();
      testGenerator.generateTest(
        InternalDartOptions(
          dartOut: path.join(foo.path, 'bar.dart'),
          testOut: path.join(tempDir.path, 'test', 'bar_test.dart'),
          ignoreLints: false,
        ),
        root,
        sink,
        dartPackageName: overriddenPackageName,
        dartOutputPackageName: outputPackageName,
      );
      final code = sink.toString();
      expect(code, contains("import 'package:$outputPackageName/foo/bar.dart';"));
    } finally {
      tempDir.deleteSync(recursive: true);
    }
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
          name: 'Api',
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    for (final comment in comments) {
      expect(code, contains('///$comment'));
    }
    expect(code, contains('/// ///'));
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
                    isNullable: false,
                    associatedClass: emptyClass,
                  ),
                  name: '',
                ),
              ],
              returnType: TypeDeclaration(
                baseName: 'Output',
                isNullable: false,
                associatedClass: emptyClass,
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('extends StandardMessageCodec'));
  });

  test('host test code handles enums', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          dartHostTestHandler: 'ApiMock',
          methods: <Method>[
            Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[
                Parameter(
                  type: TypeDeclaration(
                    baseName: 'Enum',
                    isNullable: false,
                    associatedEnum: emptyEnum,
                  ),
                  name: 'anEnum',
                ),
              ],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[
        Enum(
          name: 'Enum',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        ),
      ],
    );
    final sink = StringBuffer();

    const testGenerator = DartGenerator();
    testGenerator.generateTest(
      const InternalDartOptions(dartOut: 'code.dart', testOut: 'test.dart', ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );

    final testCode = sink.toString();
    expect(testCode, contains('final Enum arg_anEnum = args[0]! as Enum;'));
    expect(testCode, contains('return value == null ? null : Enum.values[value];'));
    expect(testCode, contains('writeValue(buffer, value.index);'));
  });

  test('connection error contains channel name', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'method',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'Output', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
      containsHostApi: true,
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('\'Unable to establish connection on channel: "\$channelName".\''));
  });

  test('generate wrapResponse if is generating tests', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          dartHostTestHandler: 'ApiMock',
          methods: <Method>[
            Method(
              name: 'foo',
              location: ApiLocation.host,
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[],
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );

    final mainCodeSink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(testOut: 'test.dart', ignoreLints: false),
      root,
      mainCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final mainCode = mainCodeSink.toString();
    expect(mainCode, contains('List<Object?> wrapResponse('));
  });

  test('writes custom int codec without custom types', () {
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('if (value is int) {'));
    expect(code, contains('buffer.putUint8(4);'));
    expect(code, contains('buffer.putInt64(value);'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('bool operator ==(Object other) {'));
    expect(code, contains('int get hashCode =>'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('bool operator ==(Object other) {'));
    expect(code, contains('int get hashCode =>'));
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
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains('String toString() {'));
    expect(code, contains(r"return 'Foobar(field1: $field1)';"));
  });

  test('native interop host api unsupported error - getInstance', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    const options = InternalDartOptions(
      ignoreLints: false,
      useFfi: true,
      useJni: true,
      dartOut: 'lib/foo.dart',
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(options, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
    final code = sink.toString();

    expect(code, contains('Native Interop is not supported on this platform. Use Api instead.'));

    final nativeInteropSink = StringBuffer();
    generator.generateNativeInterop(
      options,
      root,
      nativeInteropSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    expect(
      nativeInteropSink.toString(),
      contains('Native Interop is not supported on this platform. Use Api instead.'),
    );
  });

  test('native interop host api unsupported error - createWithNativeInteropApi', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        dartOut: 'lib/foo.dart',
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(
      code,
      contains(
        'Native Interop is not supported on this platform. Use the default constructor of Api instead.',
      ),
    );
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
      ],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generate(
      const InternalDartOptions(ignoreLints: false),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();
    expect(code, contains("const String stringConst = 'hello';"));
    expect(code, contains('const int intConst = 42;'));
    expect(code, contains('const double doubleConst = 3.14;'));
    expect(code, contains('const bool boolConst = true;'));
  });

  test('fromJni handles field named type without colliding with static JType member', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foo',
          fields: <NamedType>[
            NamedType(
              name: 'type',
              type: const TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(ignoreLints: false, useJni: true, dartOut: 'lib/foo.dart'),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains(r'type: jniClass.type$1'));
  });

  test('native interop host api invokes jni methods correctly', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'isGetter',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'bool', isNullable: false),
            ),
            Method(
              name: 'getGetter',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'int', isNullable: false),
            ),
            Method(
              name: 'setSetter',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  name: 'value',
                  type: const TypeDeclaration(baseName: 'int', isNullable: false),
                ),
              ],
              returnType: const TypeDeclaration(baseName: 'void', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useJni: true,
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('return _jniApi.isGetter;'));
    expect(code, contains('return _jniApi.getter;'));
    expect(code, contains('_jniApi.setter = value;'));
  });

  test('native interop converts sealed classes through their subclasses', () {
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useJni: true,
        useFfi: true,
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      buildSealedClassRoot(),
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('jni_bridge.Shape toJni() {'));
    expect(code, contains('final Circle child => child.toJni(),'));
    expect(code, contains('static Shape? fromJni(jni_bridge.Shape? jniClass) {'));
    expect(code, contains('if (jniClass.isA<jni_bridge.Circle>(jni_bridge.Circle.type)) {'));
    expect(
      code,
      contains(
        'return PigeonInternalCircleNativeInterop.fromJni(jniClass.as(jni_bridge.Circle.type));',
      ),
    );
    expect(code, contains('ffi_bridge.ShapeBridge toFfi() {'));
    expect(code, contains('final Circle child => child.toFfi(),'));
    expect(code, contains('static Shape? fromFfi(ffi_bridge.ShapeBridge? ffiClass) {'));
    expect(code, contains('if (ffi_bridge.CircleBridge.isA(ffiClass)) {'));
    expect(
      code,
      contains(
        'return PigeonInternalCircleNativeInterop.fromFfi(ffi_bridge.CircleBridge.as(ffiClass));',
      ),
    );
    expect(code, contains('jni_bridge.Circle toJni() {'));
    expect(code, contains('ffi_bridge.CircleBridge toFfi() {'));
    expect(
      code,
      contains('final jni_bridge.Shape pigeonVar_res = _jniApi.echoShape(shape.toJni());'),
    );
    expect(
      code,
      contains(
        'final Shape pigeonVar_dartTypeRes = PigeonInternalShapeNativeInterop.fromJni(pigeonVar_res)!;',
      ),
    );
  });

  test('native interop codecs have no branch for sealed classes', () {
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useJni: true,
        useFfi: true,
        dartOut: 'lib/foo.dart',
      ),
      buildSealedClassRoot(),
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('value.isInstanceOf(_classCircle)'));
    expect(code, isNot(contains('value.isInstanceOf(_classShape)')));
    expect(code, contains('ffi_bridge.CircleBridge.isA(value)'));
    expect(code, isNot(contains('ffi_bridge.ShapeBridge.isA(value)')));
    expect(code, contains('value is Circle)'));
    expect(code, isNot(contains('value is Shape)')));
  });

  test('ffi toFfi allocates the bridge for a class without fields', () {
    final root = Root(
      apis: <Api>[],
      classes: <Class>[Class(name: 'Empty', fields: <NamedType>[])],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(ignoreLints: false, useFfi: true, dartOut: 'lib/foo.dart'),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('return ffi_bridge.EmptyBridge.alloc().init();'));
  });

  test('native interop code uses the member names that JNIgen generates', () {
    const string = TypeDeclaration(baseName: 'String', isNullable: false);
    const nullableString = TypeDeclaration(baseName: 'String', isNullable: true);
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'release',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'register',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'isNullable',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration(baseName: 'bool', isNullable: true),
            ),
            Method(
              name: 'getDefault',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: string,
            ),
          ],
        ),
        AstFlutterApi(
          name: 'Callbacks',
          methods: <Method>[
            Method(
              name: 'type',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: string,
            ),
            Method(
              name: 'implementIn',
              location: ApiLocation.flutter,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Data',
          fields: <NamedType>[
            NamedType(name: 'release', type: nullableString),
            NamedType(name: 'isNull', type: nullableString),
            NamedType(name: 'equals', type: nullableString),
            NamedType(
              name: 'isEnabled',
              type: const TypeDeclaration(baseName: 'bool', isNullable: false),
            ),
            NamedType(
              name: 'isMaybe',
              type: const TypeDeclaration(baseName: 'bool', isNullable: true),
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useJni: true,
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    // Data class properties.
    expect(code, contains(r'release: jniClass.release$1?.'));
    expect(code, contains(r'isNull: jniClass.isNull$1()?.'));
    expect(code, contains('equals: jniClass.equals?.'));
    expect(code, contains('isEnabled: jniClass.isEnabled,'));
    expect(code, contains('isMaybe: jniClass.isMaybe()?.'));
    // Host API registrar members.
    expect(code, contains(r'_jniApi.release$1('));
    expect(code, contains(r'_jniApi.register$1('));
    expect(code, contains('_jniApi.isNullable()'));
    expect(code, contains(r'_jniApi.default$;'));
    // Flutter API interface overrides.
    expect(code, contains(r'JString type$1()'));
    expect(code, contains(r'JString implementIn$1(JString arg_value)'));
  });

  test('native interop code does not shadow parameters', () {
    const string = TypeDeclaration(baseName: 'String', isNullable: false);
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'echo',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(name: 'res', type: string),
                Parameter(name: 'error', type: string),
              ],
              returnType: string,
            ),
            Method(
              name: 'later',
              location: ApiLocation.host,
              isAsynchronous: true,
              parameters: <Parameter>[Parameter(name: 'completer', type: string)],
              returnType: string,
            ),
            Method(
              name: 'convert',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'dartTypeRes', type: string)],
              returnType: string,
            ),
          ],
        ),
        AstFlutterApi(
          name: 'Callbacks',
          methods: <Method>[
            Method(
              name: 'send',
              location: ApiLocation.flutter,
              parameters: <Parameter>[
                Parameter(name: 'response', type: string),
                Parameter(name: 'errorOut', type: string),
              ],
              returnType: string,
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        ffiErrorClassName: 'PigeonError',
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(
      code,
      contains(
        'final JString pigeonVar_res = _jniApi.echo(_PigeonJniCodec.writeValue<JString>(res), _PigeonJniCodec.writeValue<JString>(error));',
      ),
    );
    expect(code, contains('final pigeonVar_error = ffi_bridge.PigeonError();'));
    expect(
      code,
      contains(
        'error: _PigeonFfiCodec.writeValue<NSString>(error), wrappedError: pigeonVar_error)',
      ),
    );
    expect(code, contains('final Completer<String> pigeonVar_completer = Completer<String>();'));
    expect(code, contains('_jniApi.convert(_PigeonJniCodec.writeValue<JString>(dartTypeRes))'));
    expect(
      code,
      contains('_PigeonFfiCodec.writeValue<NSString>(dartTypeRes), wrappedError: pigeonVar_error)'),
    );
    expect(code, contains('return pigeonVar_dartTypeRes;'));
    expect(code, isNot(contains(' dartTypeRes = ')));
    expect(code, contains('JString send(JString arg_response,JString arg_errorOut,)'));
    expect(
      code,
      contains('(NSString? arg_response, NSString? arg_errorOut, ffi_bridge.PigeonError errorOut)'),
    );
  });

  test('test file does not include native interop code', () {
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          dartHostTestHandler: 'ApiMock',
          methods: <Method>[
            Method(
              name: 'echo',
              location: ApiLocation.host,
              parameters: <Parameter>[
                Parameter(
                  name: 'value',
                  type: const TypeDeclaration(baseName: 'String', isNullable: false),
                ),
              ],
              returnType: const TypeDeclaration(baseName: 'String', isNullable: false),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateTest(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        dartOut: 'lib/foo.dart',
        testOut: 'test/foo_test.dart',
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('abstract class ApiMock'));
    expect(code, isNot(contains('jni_bridge')));
    expect(code, isNot(contains('ffi_bridge')));
    expect(code, isNot(contains('JString')));
    expect(code, isNot(contains('NSString')));
  });

  test('native interop codecs skip collections of ProxyApis', () {
    final proxyApi = AstProxyApi(
      name: 'Proxy',
      constructors: <Constructor>[],
      fields: <ApiField>[],
      methods: <Method>[],
    );
    final proxyType = TypeDeclaration(
      baseName: 'Proxy',
      isNullable: false,
      associatedProxyApi: proxyApi,
    );
    final root = Root(
      apis: <Api>[
        proxyApi,
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'doSomething',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[],
      enums: <Enum>[],
      lists: <String, TypeDeclaration>{
        'List<Proxy>': TypeDeclaration(
          baseName: 'List',
          isNullable: false,
          typeArguments: <TypeDeclaration>[proxyType],
        ),
      },
      maps: <String, TypeDeclaration>{
        'Map<String, Proxy>': TypeDeclaration(
          baseName: 'Map',
          isNullable: false,
          typeArguments: <TypeDeclaration>[
            const TypeDeclaration(baseName: 'String', isNullable: false),
            proxyType,
          ],
        ),
      },
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        dartOut: 'lib/foo.dart',
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('class _PigeonJniCodec'));
    expect(code, contains('class _PigeonFfiCodec'));
    expect(code, isNot(contains('There is something wrong')));
  });

  test('ffi code uses the selectors that Swift infers', () {
    const string = TypeDeclaration(baseName: 'String', isNullable: false);
    final root = Root(
      apis: <Api>[
        AstHostApi(
          name: 'Api',
          methods: <Method>[
            Method(
              name: 'signIn',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'signOut',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'lookUp',
              location: ApiLocation.host,
              parameters: <Parameter>[Parameter(name: 'inList', type: string)],
              returnType: string,
            ),
            Method(
              name: 'goTo',
              location: ApiLocation.host,
              parameters: <Parameter>[],
              returnType: string,
            ),
          ],
        ),
        AstFlutterApi(
          name: 'Callbacks',
          methods: <Method>[
            Method(
              name: 'implementIn',
              location: ApiLocation.flutter,
              parameters: <Parameter>[Parameter(name: 'value', type: string)],
              returnType: string,
            ),
            Method(
              name: 'goTo',
              location: ApiLocation.flutter,
              parameters: <Parameter>[],
              returnType: string,
            ),
            Method(
              name: 'goToAsync',
              location: ApiLocation.flutter,
              isAsynchronous: true,
              parameters: <Parameter>[],
              returnType: string,
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Data',
          fields: <NamedType>[
            NamedType(
              name: 'forKey',
              type: const TypeDeclaration(baseName: 'String', isNullable: true),
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final sink = StringBuffer();
    const generator = DartGenerator();
    generator.generateNativeInterop(
      const InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        ffiErrorClassName: 'PigeonError',
        dartOut: 'lib/foo.dart',
        nativeInteropTransport: NativeInteropTransport.objects,
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final code = sink.toString();

    expect(code, contains('_ffiApi.signInValue('));
    expect(code, contains('_ffiApi.signOutWithValue('));
    expect(code, contains('_ffiApi.lookUpInList('));
    expect(code, contains('_ffiApi.goToWrappedError('));
    expect(code, contains('.implementInValue_error_'));
    expect(code, contains('.goToError_'));
    expect(code, contains('.goToAsyncWithError_completionHandler_'));
    expect(code, contains('DataBridge.alloc().initForKey('));
  });

  group('hybrid native interop transport', () {
    final dataClass = Class(
      name: 'Data',
      fields: <NamedType>[
        NamedType(
          name: 'value',
          type: const TypeDeclaration(baseName: 'int', isNullable: false),
        ),
      ],
    );
    final anEnum = Enum(
      name: 'Color',
      members: <EnumMember>[
        EnumMember(name: 'red'),
        EnumMember(name: 'green'),
      ],
    );
    TypeDeclaration dataType({bool isNullable = false}) =>
        TypeDeclaration(baseName: 'Data', isNullable: isNullable, associatedClass: dataClass);
    TypeDeclaration enumType({bool isNullable = false}) =>
        TypeDeclaration(baseName: 'Color', isNullable: isNullable, associatedEnum: anEnum);
    const intType = TypeDeclaration(baseName: 'int', isNullable: false);

    List<Method> methods(ApiLocation location) => <Method>[
      Method(
        name: 'echoData',
        location: location,
        parameters: <Parameter>[
          Parameter(name: 'count', type: intType),
          Parameter(name: 'data', type: dataType()),
          Parameter(
            name: 'list',
            type: TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[dataType(isNullable: true)],
            ),
          ),
        ],
        returnType: dataType(isNullable: true),
      ),
      Method(
        name: 'add',
        location: location,
        parameters: <Parameter>[
          Parameter(name: 'a', type: intType),
          Parameter(name: 'b', type: intType),
        ],
        returnType: intType,
      ),
      Method(
        name: 'echoColor',
        location: location,
        parameters: <Parameter>[Parameter(name: 'color', type: enumType(isNullable: true))],
        returnType: enumType(isNullable: true),
      ),
      Method(
        name: 'echoAsyncData',
        location: location,
        isAsynchronous: true,
        parameters: <Parameter>[Parameter(name: 'data', type: dataType())],
        returnType: dataType(isNullable: true),
      ),
    ];

    String generate({required bool useJni, required bool useFfi, bool hybrid = true}) {
      final root = Root(
        apis: <Api>[
          AstHostApi(name: 'HostApi', methods: methods(ApiLocation.host)),
          AstFlutterApi(name: 'FlutterApi', methods: methods(ApiLocation.flutter)),
        ],
        classes: <Class>[dataClass],
        enums: <Enum>[anEnum],
      );
      final sink = StringBuffer();
      const DartGenerator().generateNativeInterop(
        InternalDartOptions(
          ignoreLints: false,
          useJni: useJni,
          useFfi: useFfi,
          ffiErrorClassName: 'PigeonError',
          jniErrorClassName: 'FlutterError',
          dartOut: 'lib/foo.dart',
          nativeInteropTransport: hybrid
              ? NativeInteropTransport.hybrid
              : NativeInteropTransport.objects,
        ),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      return sink.toString();
    }

    test('jni host methods encode structured arguments into one buffer', () {
      final String code = generate(useJni: true, useFfi: false);
      expect(
        code,
        contains(
          'final JByteArray pigeonVar_args = _PigeonJniBuffers.encode(<Object?>[data, list]);',
        ),
      );
      expect(code, contains('_jniApi.echoData(count, pigeonVar_args)'));
      expect(code, contains('await _jniApi.echoAsyncData(pigeonVar_args)'));
      expect(code, contains('return _PigeonJniBuffers.decode(pigeonVar_res) as Data?;'));
      expect(code, contains('pigeonVar_args.release();'));
    });

    test('jni host methods pass scalars and enums directly', () {
      final String code = generate(useJni: true, useFfi: false);
      expect(code, contains('return _jniApi.add(a, b);'));
      expect(code, contains('_jniApi.echoColor(color?.index ?? -1)'));
      expect(code, contains('return pigeonVar_res == -1 ? null : Color.values[pigeonVar_res];'));
    });

    test('jni flutter api implements the buffer bridge', () {
      final String code = generate(useJni: true, useFfi: false);
      expect(code, contains(r'final class _FlutterApiRegistrar with jni_bridge.$FlutterApiBridge'));
      expect(code, contains('jni_bridge.FlutterApiBridge.implement(this)'));
      expect(code, contains('JByteArray? echoData(int arg_count, JByteArray pigeonVar_args)'));
      expect(code, contains('return _PigeonJniBuffers.encodeOrNull(response);'));
      expect(code, contains('int add(int arg_a, int arg_b)'));
    });

    test('jni error details are decoded from the buffer', () {
      final String code = generate(useJni: true, useFfi: false);
      expect(
        code,
        contains('details: _PigeonJniBuffers.decode(pigeonError.details as JByteArray?)'),
      );
    });

    test('ffi host methods encode structured arguments into one buffer', () {
      final String code = generate(useJni: false, useFfi: true);
      expect(
        code,
        contains('final NSData pigeonVar_args = _PigeonFfiBuffers.encode(<Object?>[data, list]);'),
      );
      expect(
        code,
        contains(
          '_ffiApi.echoDataWithCount(count, pigeonVar_args: pigeonVar_args, wrappedError: pigeonVar_error)',
        ),
      );
      expect(code, contains('return _PigeonFfiBuffers.decode(pigeonVar_res) as Data?;'));
      expect(code, contains('_ffiApi.addWithA(a, b: b, wrappedError: pigeonVar_error)'));
    });

    test('ffi flutter api implements the buffer protocol', () {
      final String code = generate(useJni: false, useFfi: true);
      expect(
        code,
        contains(r'FlutterApiBridge$Builder.echoDataWithCount_pigeonVar_args_error_.implement('),
      );
      expect(code, contains(r'FlutterApiBridge$Builder.addWithA_b_error_.implement('));
      expect(code, contains('return _PigeonFfiBuffers.encodeOrNull(response);'));
    });

    test('objects transport does not generate buffer helpers', () {
      final String code = generate(useJni: true, useFfi: true, hybrid: false);
      expect(code, isNot(contains('_PigeonJniBuffers')));
      expect(code, isNot(contains('_PigeonFfiBuffers')));
      expect(code, isNot(contains('pigeonVar_args')));
    });

    test('jni codec looks up each class once', () {
      final String code = generate(useJni: true, useFfi: false, hybrid: false);
      expect(code, contains('static final JClass _longClass = JLong.type.jClass;'));
      expect(code, contains('static final JClass _classData = jni_bridge.Data.type.jClass;'));
      expect(code, contains('if (value.isInstanceOf(_longClass)) {'));
      expect(code, isNot(contains('value.isA<')));
    });

    test(
      'jni hybrid binding namer resolves JavaBean property collisions across enums and buffers',
      () {
        final root = Root(
          apis: <Api>[
            AstHostApi(
              name: 'BeanHostApi',
              methods: <Method>[
                Method(
                  name: 'getMode',
                  location: ApiLocation.host,
                  parameters: <Parameter>[],
                  returnType: enumType(),
                ),
                Method(
                  name: 'setMode',
                  location: ApiLocation.host,
                  parameters: <Parameter>[
                    Parameter(name: 'mode', type: enumType(isNullable: true)),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
                Method(
                  name: 'getCount',
                  location: ApiLocation.host,
                  parameters: <Parameter>[],
                  returnType: intType,
                ),
                Method(
                  name: 'setCount',
                  location: ApiLocation.host,
                  parameters: <Parameter>[
                    Parameter(name: 'count', type: enumType(isNullable: true)),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
                Method(
                  name: 'getData',
                  location: ApiLocation.host,
                  parameters: <Parameter>[],
                  returnType: dataType(),
                ),
                Method(
                  name: 'setData',
                  location: ApiLocation.host,
                  parameters: <Parameter>[
                    Parameter(
                      name: 'items',
                      type: const TypeDeclaration(
                        baseName: 'List',
                        isNullable: false,
                        typeArguments: <TypeDeclaration>[intType],
                      ),
                    ),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
              ],
            ),
          ],
          classes: <Class>[dataClass],
          enums: <Enum>[anEnum],
        );
        final sink = StringBuffer();
        const DartGenerator().generateNativeInterop(
          const InternalDartOptions(
            ignoreLints: false,
            useJni: true,
            jniErrorClassName: 'FlutterError',
            dartOut: 'lib/foo.dart',
          ),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final code = sink.toString();
        expect(code, contains('final int pigeonVar_res = _jniApi.mode;'));
        expect(code, contains('_jniApi.mode = mode?.index ?? -1;'));
        expect(code, contains('return _jniApi.count;'));
        expect(code, contains('_jniApi.count = count?.index ?? -1;'));
        expect(code, contains('final JByteArray? pigeonVar_res = _jniApi.data;'));
        expect(code, contains('_jniApi.data = pigeonVar_args;'));
      },
    );

    test(
      'jni hybrid host and flutter methods avoid parameter name collisions and release JNI temporaries',
      () {
        const stringType = TypeDeclaration(baseName: 'String', isNullable: false);
        final collisionMethods = <Method>[
          Method(
            name: 'sendWithArgsName',
            location: ApiLocation.host,
            parameters: <Parameter>[
              Parameter(name: 'args', type: stringType),
              Parameter(name: 'data', type: dataType()),
            ],
            returnType: dataType(isNullable: true),
          ),
        ];
        final flutterCollisionMethods = <Method>[
          Method(
            name: 'onWithArgsName',
            location: ApiLocation.flutter,
            parameters: <Parameter>[
              Parameter(name: 'args', type: stringType),
              Parameter(name: 'data', type: dataType()),
            ],
            returnType: dataType(isNullable: true),
          ),
        ];
        final root = Root(
          apis: <Api>[
            AstHostApi(name: 'HostApi', methods: collisionMethods),
            AstFlutterApi(name: 'FlutterApi', methods: flutterCollisionMethods),
          ],
          classes: <Class>[dataClass],
          enums: <Enum>[anEnum],
        );
        final sink = StringBuffer();
        const DartGenerator().generateNativeInterop(
          const InternalDartOptions(
            ignoreLints: false,
            useJni: true,
            jniErrorClassName: 'FlutterError',
            dartOut: 'lib/foo.dart',
          ),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final code = sink.toString();
        // Verify `pigeonVar_args` is encoded before allocating `pigeonVar_arg_args`,
        // and that `args` does not collide with `pigeonVar_args`.
        final int encodeIndex = code.indexOf(
          'final JByteArray pigeonVar_args = _PigeonJniBuffers.encode(<Object?>[data]);',
        );
        final int allocDirectIndex = code.indexOf(
          'final JString pigeonVar_arg_args = args.toJString();',
        );
        expect(encodeIndex, greaterThanOrEqualTo(0));
        expect(allocDirectIndex, greaterThan(encodeIndex));
        expect(code, contains('_jniApi.sendWithArgsName(pigeonVar_arg_args, pigeonVar_args)'));
        expect(code, contains('pigeonVar_arg_args.release();'));

        // Verify FlutterApi releases direct JNI parameters before decoding the buffer.
        final int releaseDirectFlutterIndex = code.indexOf(
          'final String pigeonVar_arg_args = arg_args.toDartString(releaseOriginal: true);',
        );
        final int decodeFlutterIndex = code.indexOf(
          'final List<Object?> pigeonVar_decodedArgs = _PigeonJniBuffers.decode(pigeonVar_args)!',
        );
        expect(releaseDirectFlutterIndex, greaterThanOrEqualTo(0));
        expect(decodeFlutterIndex, greaterThan(releaseDirectFlutterIndex));
      },
    );
  });

  test(
    'main dart output with native interop is web-safe and conditionally imports native interop file',
    () {
      expect(getNativeInteropDartPath('lib/src/foo.g.dart'), 'lib/src/foo.native_interop.g.dart');
      expect(
        getNativeInteropDartPath('lib/src/foo.gen.dart'),
        'lib/src/foo.native_interop.gen.dart',
      );
      expect(getNativeInteropDartPath('lib/src/foo.dart'), 'lib/src/foo.native_interop.dart');

      const string = TypeDeclaration(baseName: 'String', isNullable: false);
      final root = Root(
        apis: <Api>[
          AstHostApi(
            name: 'Api',
            methods: <Method>[
              Method(
                name: 'echo',
                location: ApiLocation.host,
                parameters: <Parameter>[Parameter(name: 'value', type: string)],
                returnType: string,
              ),
            ],
          ),
          AstFlutterApi(
            name: 'Callbacks',
            methods: <Method>[
              Method(
                name: 'onEvent',
                location: ApiLocation.flutter,
                parameters: <Parameter>[Parameter(name: 'value', type: string)],
                returnType: const TypeDeclaration.voidDeclaration(),
              ),
            ],
          ),
        ],
        classes: <Class>[
          Class(
            name: 'Data',
            fields: <NamedType>[NamedType(name: 'value', type: string)],
          ),
        ],
        enums: <Enum>[
          Enum(
            name: 'MyEnum',
            members: <EnumMember>[EnumMember(name: 'one')],
          ),
        ],
      );
      const options = InternalDartOptions(
        ignoreLints: false,
        useFfi: true,
        useJni: true,
        ffiErrorClassName: 'PigeonError',
        jniErrorClassName: 'PigeonError',
        dartOut: 'lib/foo.g.dart',
      );
      final sink = StringBuffer();
      const generator = DartGenerator();
      generator.generate(options, root, sink, dartPackageName: DEFAULT_PACKAGE_NAME);
      final code = sink.toString();

      expect(code, isNot(contains("import 'dart:ffi'")));
      expect(code, isNot(contains("import 'dart:io'")));
      expect(code, isNot(contains("import 'package:ffi/ffi.dart'")));
      expect(code, isNot(contains("import 'package:jni/jni.dart'")));
      expect(code, isNot(contains("import 'package:objective_c/objective_c.dart'")));
      expect(code, isNot(contains('ffi_bridge')));
      expect(code, isNot(contains('jni_bridge')));
      expect(code, isNot(contains('toJni')));
      expect(code, isNot(contains('toFfi')));
      expect(
        code,
        contains(
          "import './foo.g.dart'\n"
          "    if (dart.library.ffi) './foo.native_interop.g.dart'\n"
          '    as pigeon_native;',
        ),
      );
      expect(code, contains("import 'package:flutter/foundation.dart' show kIsWeb;"));
      expect(code, contains('if (!kIsWeb) {'));
      expect(code, contains('if (!kIsWeb && api != null) {'));
      expect(
        code,
        contains(
          "import 'package:meta/meta.dart' show immutable, internal, protected, visibleForTesting;",
        ),
      );
      expect(code, contains('@internal\nApiForNativeInterop? pigeon_getInstance_Api({'));
      expect(code, contains('pigeon_native.pigeon_getInstance_Api(channelName: channelName)'));
      expect(code, contains('@internal\nCallbacks pigeon_register_Callbacks('));
      expect(code, contains('final class CallbacksRegistrar'));
      expect(code, contains('pigeon_native.pigeon_register_Callbacks(api, name: name)'));

      final nativeInteropSink = StringBuffer();
      generator.generateNativeInterop(
        options,
        root,
        nativeInteropSink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final nativeInteropCode = nativeInteropSink.toString();
      expect(nativeInteropCode, contains("import './foo.g.dart';"));
      expect(nativeInteropCode, contains('extension PigeonInternalDataNativeInterop on Data'));
      expect(nativeInteropCode, contains('extension PigeonInternalMyEnumNativeInterop on MyEnum'));
      expect(
        nativeInteropCode,
        contains('class _ApiForNativeInterop implements ApiForNativeInterop'),
      );
      expect(nativeInteropCode, contains('final class _CallbacksRegistrar'));
      expect(nativeInteropCode, contains('_CallbacksRegistrar(this.dartApi);'));
      expect(nativeInteropCode, contains('final Callbacks dartApi;'));
      expect(nativeInteropCode, isNot(contains('if (dartApi != null)')));

      // Verify single-platform import isolation in generateNativeInterop.
      final jniOnlySink = StringBuffer();
      generator.generateNativeInterop(
        const InternalDartOptions(
          ignoreLints: false,
          useJni: true,
          jniErrorClassName: 'PigeonError',
          dartOut: 'lib/foo.g.dart',
        ),
        root,
        jniOnlySink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final jniOnlyCode = jniOnlySink.toString();
      expect(jniOnlyCode, contains("import 'package:jni/jni.dart';"));
      expect(jniOnlyCode, contains("import './foo.g.jni.dart' as jni_bridge;"));
      expect(jniOnlyCode, isNot(contains("import 'dart:ffi';")));
      expect(jniOnlyCode, isNot(contains("import 'package:ffi/ffi.dart';")));
      expect(jniOnlyCode, isNot(contains("import 'package:objective_c/objective_c.dart';")));
      expect(jniOnlyCode, isNot(contains('ffi_bridge')));

      final ffiOnlySink = StringBuffer();
      generator.generateNativeInterop(
        const InternalDartOptions(
          ignoreLints: false,
          useFfi: true,
          ffiErrorClassName: 'PigeonError',
          dartOut: 'lib/foo.g.dart',
        ),
        root,
        ffiOnlySink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final ffiOnlyCode = ffiOnlySink.toString();
      expect(ffiOnlyCode, contains("import 'dart:ffi';"));
      expect(ffiOnlyCode, contains("import 'package:ffi/ffi.dart';"));
      expect(ffiOnlyCode, contains("import 'package:objective_c/objective_c.dart';"));
      expect(ffiOnlyCode, contains("import './foo.g.ffi.dart' as ffi_bridge;"));
      expect(ffiOnlyCode, isNot(contains("import 'package:jni/jni.dart';")));
      expect(ffiOnlyCode, isNot(contains('jni_bridge')));
    },
  );
}

/// Builds a root with a sealed class `Shape`, its subclasses `Circle` (one
/// field) and `EmptyShape` (no fields), and a host API that echoes `Shape`.
Root buildSealedClassRoot() {
  final shape = Class(name: 'Shape', fields: <NamedType>[], isSealed: true);
  final circle = Class(
    name: 'Circle',
    fields: <NamedType>[
      NamedType(
        name: 'radius',
        type: const TypeDeclaration(baseName: 'double', isNullable: false),
      ),
    ],
    superClassName: 'Shape',
    superClass: shape,
  );
  final emptyShape = Class(
    name: 'EmptyShape',
    fields: <NamedType>[],
    superClassName: 'Shape',
    superClass: shape,
  );
  shape.children.addAll(<Class>[circle, emptyShape]);
  final shapeType = TypeDeclaration(baseName: 'Shape', isNullable: false, associatedClass: shape);
  final nullableShapeType = TypeDeclaration(
    baseName: 'Shape',
    isNullable: true,
    associatedClass: shape,
  );
  return Root(
    apis: <Api>[
      AstHostApi(
        name: 'Api',
        methods: <Method>[
          Method(
            name: 'echoShape',
            location: ApiLocation.host,
            parameters: <Parameter>[Parameter(name: 'shape', type: shapeType)],
            returnType: shapeType,
          ),
          Method(
            name: 'echoNullableShape',
            location: ApiLocation.host,
            parameters: <Parameter>[Parameter(name: 'shape', type: nullableShapeType)],
            returnType: nullableShapeType,
          ),
        ],
      ),
    ],
    classes: <Class>[shape, circle, emptyShape],
    enums: <Enum>[],
  );
}
