// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Directory, File;

import 'package:path/path.dart' as path;
import 'package:pigeon/ast.dart';
import 'package:pigeon/dart_generator.dart';
import 'package:pigeon/generator_tools.dart';
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
            type: TypeDeclaration(
              baseName: 'dataType1',
              isNullable: true,
              associatedClass: emptyClass,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  dataType1? field1;'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum Foobar'));
    expect(code, contains('  one,'));
    expect(code, contains('  two,'));
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
                  isNullable: false,
                  associatedClass: emptyClass,
                ),
                name: 'input')
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('Future<Output> doSomething(Input input)'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('Future<int> add(int x, int y)'));
    expect(code, contains('await __pigeon_channel.send(<Object?>[x, y])'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('int add(int x, int y)'));
    expect(code,
        contains('final List<Object?> args = (message as List<Object?>?)!'));
    expect(code, contains('final int? arg_x = (args[0] as int?)'));
    expect(code, contains('final int? arg_y = (args[1] as int?)'));
    expect(code, contains('final int output = api.add(arg_x!, arg_y!)'));
  });

  test('nested class', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(
        name: 'Input',
        fields: <NamedType>[
          NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: true,
              ),
              name: 'input')
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
              name: 'nested')
        ],
      )
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains(
        'nested?.encode(),',
      ),
    );
    expect(
      code.replaceAll('\n', ' ').replaceAll('  ', ''),
      contains(
        'nested: result[0] != null ? Input.decode(result[0]! as List<Object?>) : null',
      ),
    );
  });

  test('nested non-nullable class', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(
        name: 'Input',
        fields: <NamedType>[
          NamedType(
              type: const TypeDeclaration(
                baseName: 'String',
                isNullable: false,
              ),
              name: 'input')
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
              name: 'nested')
        ],
      )
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
      code,
      contains(
        'nested.encode(),',
      ),
    );
    expect(
      code.replaceAll('\n', ' ').replaceAll('  ', ''),
      contains(
        'nested: Input.decode(result[0]! as List<Object?>)',
      ),
    );
  });

  test('flutterApi', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
                name: 'input')
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('static void setup(Api'));
    expect(code, contains('Output doSomething(Input input)'));
  });

  test('host void', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<void> doSomething'));
    expect(code, contains('return;'));
  });

  test('flutter void return', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    // The next line verifies that we're not setting a variable to the value of "doSomething", but
    // ignores the line where we assert the value of the argument isn't null, since on that line
    // we mention "doSomething" in the assertion message.
    expect(code, isNot(matches('[^!]=.*doSomething')));
    expect(code, contains('doSomething('));
  });

  test('flutter void argument', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.flutter,
          parameters: <Parameter>[],
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches('output.*=.*doSomething[(][)]'));
    expect(code, contains('Output doSomething();'));
  });

  test('flutter enum argument with enum class', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
                name: 'enumClass')
          ],
          returnType: TypeDeclaration(
            baseName: 'EnumClass',
            isNullable: false,
            associatedClass: emptyClass,
          ),
        )
      ])
    ], classes: <Class>[
      Class(name: 'EnumClass', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(
              baseName: 'Enum',
              isNullable: true,
              associatedEnum: emptyEnum,
            ),
            name: 'enum1')
      ]),
    ], enums: <Enum>[
      Enum(
        name: 'Enum',
        members: <EnumMember>[
          EnumMember(name: 'one'),
          EnumMember(name: 'two'),
        ],
      )
    ]);
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum1?.index,'));
    expect(code, contains('? Enum.values[result[0]! as int]'));
    expect(code, contains('EnumClass doSomething(EnumClass enumClass);'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum Foo {'));
    expect(code, contains('Future<void> bar(Foo? foo) async'));
    expect(code, contains('__pigeon_channel.send(<Object?>[foo?.index])'));
  });

  test('flutter non-nullable enum argument with enum class', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
                name: '')
          ],
          returnType: TypeDeclaration(
            baseName: 'EnumClass',
            isNullable: false,
            associatedClass: emptyClass,
          ),
        )
      ])
    ], classes: <Class>[
      Class(name: 'EnumClass', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(
              baseName: 'Enum',
              isNullable: false,
              associatedEnum: emptyEnum,
            ),
            name: 'enum1')
      ]),
    ], enums: <Enum>[
      Enum(
        name: 'Enum',
        members: <EnumMember>[
          EnumMember(name: 'one'),
          EnumMember(name: 'two'),
        ],
      )
    ]);
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum1.index,'));
    expect(code, contains('enum1: Enum.values[result[0]! as int]'));
  });

  test('host void argument', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'doSomething',
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches('__pigeon_channel.send[(]null[)]'));
  });

  test('mock dart handler', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', dartHostTestHandler: 'ApiMock', methods: <Method>[
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
                name: '')
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
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
              baseName: 'String',
              isNullable: true,
            ),
            name: 'output')
      ])
    ], enums: <Enum>[]);
    final StringBuffer mainCodeSink = StringBuffer();
    final StringBuffer testCodeSink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      mainCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String mainCode = mainCodeSink.toString();
    expect(mainCode, isNot(contains(r"import 'fo\'o.dart';")));
    expect(mainCode, contains('class Api {'));
    expect(mainCode, isNot(contains('abstract class ApiMock')));
    expect(mainCode, isNot(contains('.ApiMock.doSomething')));
    expect(mainCode, isNot(contains("'${Keys.result}': output")));
    expect(mainCode, isNot(contains('return <Object>[];')));

    const DartGenerator testGenerator = DartGenerator();
    testGenerator.generateTest(
      const DartOptions(
        sourceOutPath: "fo'o.dart",
        testOutPath: 'test.dart',
      ),
      root,
      testCodeSink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String testCode = testCodeSink.toString();
    expect(testCode, contains(r"import 'fo\'o.dart';"));
    expect(testCode, isNot(contains('class Api {')));
    expect(testCode, contains('abstract class ApiMock'));
    expect(testCode, isNot(contains('.ApiMock.doSomething')));
    expect(testCode, contains('output'));
    expect(testCode, contains('return <Object?>[output];'));
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
                  isNullable: false,
                  associatedClass: emptyClass,
                ),
                name: 'input')
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('abstract class Api'));
    expect(code, contains('Future<Output> doSomething(Input input);'));
    expect(code,
        contains('final Output output = await api.doSomething(arg_input!);'));
  });

  test('gen one async Flutter Api with void return', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
                name: '')
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(matches('=.s*doSomething')));
    expect(code, contains('await api.doSomething('));
    expect(code, isNot(contains('._toMap()')));
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
                  isNullable: false,
                  associatedClass: emptyClass,
                ),
                name: '')
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('Output.*doSomething.*Input'));
  });

  test('async host void argument', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, matches('__pigeon_channel.send[(]null[)]'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();

    const DartGenerator generator = DartGenerator();
    generator.generate(
      DartOptions(copyrightHeader: makeIterable('hello world')),
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  List<int?>? field1;'));
  });

  test('map generics', () {
    final Class classDefinition = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
            type: const TypeDeclaration(
                baseName: 'Map',
                isNullable: true,
                typeArguments: <TypeDeclaration>[
                  TypeDeclaration(baseName: 'String', isNullable: true),
                  TypeDeclaration(baseName: 'int', isNullable: true),
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Foobar'));
    expect(code, contains('  Map<String?, int?>? field1;'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('doit(List<int?> arg'));
  });

  test('flutter generics argument with void return', () {
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('doit(List<int?> arg'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<List<int?>> doit('));
    expect(
        code,
        contains(
            'return (__pigeon_replyList[0] as List<Object?>?)!.cast<int?>();'));
  });

  test('flutter generics argument non void return', () {
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
              parameters: <Parameter>[
                Parameter(
                    type: const TypeDeclaration(
                        baseName: 'List',
                        isNullable: false,
                        typeArguments: <TypeDeclaration>[
                          TypeDeclaration(baseName: 'int', isNullable: true)
                        ]),
                    name: 'foo')
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('List<int?> doit('));
    expect(
        code,
        contains(
            'final List<int?>? arg_foo = (args[0] as List<Object?>?)?.cast<int?>()'));
    expect(code, contains('final List<int?> output = api.doit(arg_foo!)'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<int?> doit()'));
    expect(code, contains('return (__pigeon_replyList[0] as int?);'));
  });

  test('return nullable collection host', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
          Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(
                  baseName: 'List',
                  isNullable: true,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<List<int?>?> doit()'));
    expect(
        code,
        contains(
            'return (__pigeon_replyList[0] as List<Object?>?)?.cast<int?>();'));
  });

  test('return nullable async host', () {
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
              parameters: <Parameter>[],
              isAsynchronous: true)
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<int?> doit()'));
    expect(code, contains('return (__pigeon_replyList[0] as int?);'));
  });

  test('return nullable flutter', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(name: 'Api', methods: <Method>[
          Method(
              name: 'doit',
              location: ApiLocation.flutter,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('int? doit();'));
    expect(code, contains('final int? output = api.doit();'));
  });

  test('return nullable async flutter', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(name: 'Api', methods: <Method>[
          Method(
              name: 'doit',
              location: ApiLocation.flutter,
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: true,
              ),
              parameters: <Parameter>[],
              isAsynchronous: true)
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<int?> doit();'));
    expect(code, contains('final int? output = await api.doit();'));
  });

  test('platform error for return nil on nonnull', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
          Method(
              name: 'doit',
              location: ApiLocation.host,
              returnType: const TypeDeclaration(
                baseName: 'int',
                isNullable: false,
              ),
              parameters: <Parameter>[])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'Host platform returned null value for non-null return value.'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('Future<void> doit(int? foo) async {'));
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('void doit(int? foo);'));
  });

  test('uses output package name for imports', () {
    const String overriddenPackageName = 'custom_name';
    const String outputPackageName = 'some_output_package';
    assert(outputPackageName != DEFAULT_PACKAGE_NAME);
    final Directory tempDir = Directory.systemTemp.createTempSync('pigeon');
    try {
      final Directory foo = Directory(path.join(tempDir.path, 'lib', 'foo'));
      foo.createSync(recursive: true);
      final File pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
name: foobar
''');
      final Root root =
          Root(classes: <Class>[], apis: <Api>[], enums: <Enum>[]);
      final StringBuffer sink = StringBuffer();
      const DartGenerator testGenerator = DartGenerator();
      testGenerator.generateTest(
        DartOptions(
          sourceOutPath: path.join(foo.path, 'bar.dart'),
          testOutPath: path.join(tempDir.path, 'test', 'bar_test.dart'),
        ),
        root,
        sink,
        dartPackageName: overriddenPackageName,
        dartOutputPackageName: outputPackageName,
      );
      final String code = sink.toString();
      expect(
          code, contains("import 'package:$outputPackageName/foo/bar.dart';"));
    } finally {
      tempDir.deleteSync(recursive: true);
    }
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
                name: 'field1'),
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    for (final String comment in comments) {
      expect(code, contains('///$comment'));
    }
    expect(code, contains('/// ///'));
  });

  test("doesn't create codecs if no custom datatypes", () {
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(contains('extends StandardMessageCodec')));
    expect(code, contains('StandardMessageCodec'));
  });

  test('creates custom codecs if custom datatypes present', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
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
                name: '')
          ],
          returnType: TypeDeclaration(
            baseName: 'Output',
            isNullable: false,
            associatedClass: emptyClass,
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
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('extends StandardMessageCodec'));
  });

  test('host test code handles enums', () {
    final Root root = Root(
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
                        name: 'anEnum')
                  ])
            ])
      ],
      classes: <Class>[],
      enums: <Enum>[
        Enum(
          name: 'Enum',
          members: <EnumMember>[
            EnumMember(name: 'one'),
            EnumMember(name: 'two'),
          ],
        )
      ],
    );
    final StringBuffer sink = StringBuffer();

    const DartGenerator testGenerator = DartGenerator();
    testGenerator.generateTest(
      const DartOptions(
        sourceOutPath: 'code.dart',
        testOutPath: 'test.dart',
      ),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
      dartOutputPackageName: DEFAULT_PACKAGE_NAME,
    );

    final String testCode = sink.toString();
    expect(
        testCode,
        contains(
            'final Enum? arg_anEnum = args[0] == null ? null : Enum.values[args[0]! as int]'));
  });

  test('connection error contains channel name', () {
    final Root root = Root(apis: <Api>[
      AstHostApi(name: 'Api', methods: <Method>[
        Method(
          name: 'method',
          location: ApiLocation.host,
          parameters: <Parameter>[],
          returnType:
              const TypeDeclaration(baseName: 'Output', isNullable: false),
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const DartGenerator generator = DartGenerator();
    generator.generate(
      const DartOptions(),
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code, contains('throw _createConnectionError(__pigeon_channelName);'));
    expect(
        code,
        contains(
            '\'Unable to establish connection on channel: "\$channelName".\''));
  });

  group('ProxyApi', () {
    test('one api', () {
      final Root root = Root(apis: <Api>[
        AstProxyApi(name: 'Api', constructors: <Constructor>[
          Constructor(name: 'name', parameters: <Parameter>[
            Parameter(
              type: const TypeDeclaration(
                baseName: 'Input',
                isNullable: false,
              ),
              name: 'input',
            ),
          ]),
        ], fields: <Field>[
          Field(
            name: 'someField',
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: false,
            ),
          )
        ], methods: <Method>[
          Method(
            name: 'doSomething',
            location: ApiLocation.host,
            parameters: <Parameter>[
              Parameter(
                type: const TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                ),
                name: 'input',
              )
            ],
            returnType: const TypeDeclaration(
              baseName: 'String',
              isNullable: false,
            ),
          ),
          Method(
            name: 'doSomethingElse',
            location: ApiLocation.flutter,
            parameters: <Parameter>[
              Parameter(
                type: const TypeDeclaration(
                  baseName: 'Input',
                  isNullable: false,
                ),
                name: 'input',
              )
            ],
            returnType: const TypeDeclaration(
              baseName: 'String',
              isNullable: false,
            ),
          ),
        ])
      ], classes: <Class>[], enums: <Enum>[]);
      final StringBuffer sink = StringBuffer();
      const DartGenerator generator = DartGenerator();
      generator.generate(
        const DartOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      final String collapsedCode = _collapseNewlineAndIndentation(code);

      // Instance Manager
      expect(code, contains(r'class $InstanceManager'));
      expect(code, contains(r'class _InstanceManagerApi'));

      // Codec and class
      expect(code, contains('class _ApiCodec'));
      expect(code, contains(r'class Api implements $Copyable'));

      // Constructors
      expect(
        collapsedCode,
        contains(
          r'Api.name({ this.$binaryMessenger, $InstanceManager? $instanceManager, required this.someField, this.doSomethingElse, required Input input, })',
        ),
      );
      expect(
        code,
        contains(
          r'Api.$detached',
        ),
      );

      // Field
      expect(code, contains('final int someField;'));

      // Dart -> Host method
      expect(code, contains('Future<String> doSomething(Input input)'));

      // Host -> Dart method
      expect(code, contains(r'static void $setUpMessageHandlers({'));
      expect(
        collapsedCode,
        contains(
          'final String Function( Api instance, Input input, )? doSomethingElse;',
        ),
      );

      // Copy method
      expect(code, contains(r'Api $copy'));
    });

    group('inheritance', () {
      test('extends', () {
        final Root root = Root(apis: <Api>[
          AstProxyApi(
            name: 'Api',
            constructors: <Constructor>[],
            fields: <Field>[],
            methods: <Method>[],
            superClassName: 'Api2',
          ),
          AstProxyApi(
            name: 'Api2',
            constructors: <Constructor>[],
            fields: <Field>[],
            methods: <Method>[],
          )
        ], classes: <Class>[], enums: <Enum>[]);
        final StringBuffer sink = StringBuffer();
        const DartGenerator generator = DartGenerator();
        generator.generate(
          const DartOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(code, contains(r'class Api extends Api2'));
        expect(
          collapsedCode,
          contains(
            r'Api.$detached({ super.$binaryMessenger, super.$instanceManager, }) : super.$detached();',
          ),
        );
      });

      test('implements', () {
        final Root root = Root(apis: <Api>[
          AstProxyApi(
            name: 'Api',
            constructors: <Constructor>[],
            fields: <Field>[],
            methods: <Method>[],
            interfacesNames: <String>{'Api2'},
          ),
          AstProxyApi(
            name: 'Api2',
            constructors: <Constructor>[],
            fields: <Field>[],
            methods: <Method>[],
          )
        ], classes: <Class>[], enums: <Enum>[]);
        final StringBuffer sink = StringBuffer();
        const DartGenerator generator = DartGenerator();
        generator.generate(
          const DartOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains(r'class Api implements Api2'));
      });

      test('implements 2 ProxyApis', () {
        final Root root = Root(apis: <Api>[
          AstProxyApi(
            name: 'Api',
            constructors: <Constructor>[],
            fields: <Field>[],
            methods: <Method>[],
            interfacesNames: <String>{'Api2', 'Api3'},
          ),
          AstProxyApi(
            name: 'Api2',
            constructors: <Constructor>[],
            fields: <Field>[],
            methods: <Method>[],
          ),
          AstProxyApi(
            name: 'Api3',
            constructors: <Constructor>[],
            fields: <Field>[],
            methods: <Method>[],
          ),
        ], classes: <Class>[], enums: <Enum>[]);
        final StringBuffer sink = StringBuffer();
        const DartGenerator generator = DartGenerator();
        generator.generate(
          const DartOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains(r'class Api implements Api2, Api3'));
      });
    });

    group('Constructors', () {
      test('empty name and no params constructor', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(name: 'Api', constructors: <Constructor>[
              Constructor(
                name: '',
                parameters: <Parameter>[],
              )
            ], fields: <Field>[], methods: <Method>[]),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const DartGenerator generator = DartGenerator();
        generator.generate(
          const DartOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(code, contains('class Api'));
        expect(
          collapsedCode,
          contains(
            r'Api({ this.$binaryMessenger, '
            r'$InstanceManager? $instanceManager, })',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r"const String __pigeon_channelName = r'dev.flutter.pigeon.test_package.Api.$defaultConstructor';",
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'__pigeon_channel.send(<Object?>[ '
            r'this.$instanceManager.addDartCreatedInstance(this) ])',
          ),
        );
      });

      test('multiple params constructor', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(name: 'Api', constructors: <Constructor>[
              Constructor(
                name: 'name',
                parameters: <Parameter>[
                  Parameter(
                    type: const TypeDeclaration(
                      isNullable: false,
                      baseName: 'int',
                    ),
                    name: 'validType',
                  ),
                  Parameter(
                    type: const TypeDeclaration(
                      isNullable: false,
                      baseName: 'AnEnum',
                    ),
                    name: 'enumType',
                  ),
                  Parameter(
                    type: const TypeDeclaration(
                      isNullable: false,
                      baseName: 'Api2',
                    ),
                    name: 'proxyApiType',
                  ),
                  Parameter(
                    type: const TypeDeclaration(
                      isNullable: true,
                      baseName: 'int',
                    ),
                    name: 'nullableValidType',
                  ),
                  Parameter(
                    type: const TypeDeclaration(
                      isNullable: true,
                      baseName: 'AnEnum',
                    ),
                    name: 'nullableEnumType',
                  ),
                  Parameter(
                    type: const TypeDeclaration(
                      isNullable: true,
                      baseName: 'Api2',
                    ),
                    name: 'nullableProxyApiType',
                  ),
                ],
              )
            ], fields: <Field>[], methods: <Method>[]),
            AstProxyApi(
              name: 'Api2',
              constructors: <Constructor>[],
              fields: <Field>[],
              methods: <Method>[],
            )
          ],
          classes: <Class>[],
          enums: <Enum>[
            Enum(
              name: 'AnEnum',
              members: <EnumMember>[EnumMember(name: 'one')],
            ),
          ],
        );
        final StringBuffer sink = StringBuffer();
        const DartGenerator generator = DartGenerator();
        generator.generate(
          const DartOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(code, contains('class Api'));
        expect(
          collapsedCode,
          contains(
            r'Api.name({ this.$binaryMessenger, '
            r'$InstanceManager? $instanceManager, '
            r'required int validType, '
            r'required AnEnum enumType, '
            r'required Api2 proxyApiType, '
            r'int? nullableValidType, '
            r'AnEnum? nullableEnumType, '
            r'Api2? nullableProxyApiType, })',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'__pigeon_channel.send(<Object?>[ '
            r'this.$instanceManager.addDartCreatedInstance(this), '
            r'validType, enumType, proxyApiType, '
            r'nullableValidType, nullableEnumType, nullableProxyApiType, ])',
          ),
        );
      });
    });

    group('Host methods', () {
      test('multiple params host method', () {
        final Root root = Root(apis: <Api>[
          AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <Field>[],
              methods: <Method>[
                Method(
                  name: 'doSomething',
                  location: ApiLocation.host,
                  parameters: <Parameter>[
                    Parameter(
                      type: const TypeDeclaration(
                          isNullable: false, baseName: 'int'),
                      name: 'x',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                          isNullable: false, baseName: 'int'),
                      name: 'y',
                    ),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                )
              ])
        ], classes: <Class>[], enums: <Enum>[]);
        final StringBuffer sink = StringBuffer();
        const DartGenerator generator = DartGenerator();
        generator.generate(
          const DartOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(code, contains('class Api'));
        expect(
          collapsedCode,
          contains(r'Future<void> doSomething( int x, int y, )'),
        );
        expect(
          collapsedCode,
          contains(r'await __pigeon_channel.send(<Object?>[ this, x, y, ])'),
        );
      });
    });

    group('Flutter methods', () {
      test('multiple params flutter method', () {
        final Root root = Root(apis: <Api>[
          AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <Field>[],
              methods: <Method>[
                Method(
                  name: 'doSomething',
                  location: ApiLocation.flutter,
                  parameters: <Parameter>[
                    Parameter(
                      type: const TypeDeclaration(
                          isNullable: false, baseName: 'int'),
                      name: 'x',
                    ),
                    Parameter(
                      type: const TypeDeclaration(
                          isNullable: false, baseName: 'int'),
                      name: 'y',
                    ),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                )
              ])
        ], classes: <Class>[], enums: <Enum>[]);
        final StringBuffer sink = StringBuffer();
        const DartGenerator generator = DartGenerator();
        generator.generate(
          const DartOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(code, contains('class Api'));
        expect(
          collapsedCode,
          contains(
            r'final void Function( Api instance, int x, int y, )? doSomething;',
          ),
        );
        expect(
          collapsedCode,
          contains(
              r'void Function( Api instance, int x, int y, )? doSomething'),
        );
        expect(
          code,
          contains(r'final Api? instance = (args[0] as Api?);'),
        );
        expect(
          code,
          contains(r'final int? arg_x = (args[1] as int?);'),
        );
        expect(
          code,
          contains(r'final int? arg_y = (args[2] as int?);'),
        );
        expect(
          collapsedCode,
          contains(
            r'(doSomething ?? instance!.doSomething)?.call( instance!, arg_x!, arg_y!, );',
          ),
        );
      });
    });
  });
}

/// Replaces a new line and the indentation with a single white space
///
/// This
///
/// ```dart
/// void method(
///   int param1,
///   int param2,
/// )
/// ```
///
/// converts to
///
/// ```dart
/// void method( int param1, int param2, )
/// ```
String _collapseNewlineAndIndentation(String string) {
  final StringBuffer result = StringBuffer();
  for (final String line in string.split('\n')) {
    result.write('${line.trimLeft()} ');
  }
  return result.toString().trim();
}
