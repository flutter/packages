// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/src/ast.dart';
import 'package:pigeon/src/swift/swift_generator.dart';
import 'package:test/test.dart';

import 'dart_generator_test.dart';

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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: Int64? = nil'));
    expect(code,
        contains('static func fromList(_ pigeonVar_list: [Any?]) -> Foobar?'));
    expect(code, contains('func toList() -> [Any?]'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum Foobar: Int'));
    expect(code, contains('  case one = 0'));
    expect(code, contains('  case two = 1'));
    expect(code, isNot(contains('if (')));
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
                    associatedEnum: emptyEnum,
                    isNullable: false,
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum Foo: Int'));
    expect(
        code,
        contains(
            'let enumResultAsInt: Int? = nilOrValue(self.readValue() as! Int?)'));
    expect(code, contains('return Foo(rawValue: enumResultAsInt)'));
    expect(code, contains('let fooArg = args[0] as! Foo'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('protocol Api'));
    expect(code, matches('func doSomething.*Input.*Output'));
    expect(code, contains('doSomethingChannel.setMessageHandler'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('var aBool: Bool? = nil'));
    expect(code, contains('var aInt: Int64? = nil'));
    expect(code, contains('var aDouble: Double? = nil'));
    expect(code, contains('var aString: String? = nil'));
    expect(code, contains('var aUint8List: FlutterStandardTypedData? = nil'));
    expect(code, contains('var aInt32List: FlutterStandardTypedData? = nil'));
    expect(code, contains('var aInt64List: FlutterStandardTypedData? = nil'));
    expect(code, contains('var aFloat64List: FlutterStandardTypedData? = nil'));
  });

  test('gen pigeon error type', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();

    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class PigeonError: Error'));
    expect(code, contains('let code: String'));
    expect(code, contains('let message: String?'));
    expect(code, contains('let details: Sendable?'));
    expect(code,
        contains('init(code: String, message: String?, details: Sendable?)'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(
        code,
        contains(
            'init(binaryMessenger: FlutterBinaryMessenger, messageChannelSuffix: String = "")'));
    expect(code, matches('func doSomething.*Input.*Output'));
    expect(code, isNot(contains('if (')));
    expect(code, isNot(matches(RegExp(r';$', multiLine: true))));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, isNot(matches('.*doSomething(.*) ->')));
    expect(code, matches('doSomething(.*)'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code,
        contains('completion: @escaping (Result<Void, PigeonError>) -> Void'));
    expect(code, contains('completion(.success(Void()))'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doSomething() throws -> Output'));
    expect(code, contains('let result = try api.doSomething()'));
    expect(code, contains('reply(wrapResult(result))'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'func doSomething(completion: @escaping (Result<Output, PigeonError>) -> Void)'));
    expect(code, contains('channel.sendMessage(nil'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [Any?]? = nil'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [AnyHashable?: Any?]? = nil'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Outer'));
    expect(code, contains('struct Nested'));
    expect(code, contains('var nested: Nested? = nil'));
    expect(code,
        contains('static func fromList(_ pigeonVar_list: [Any?]) -> Outer?'));
    expect(
        code, contains('let nested: Nested? = nilOrValue(pigeonVar_list[0])'));
    expect(code, contains('func toList() -> [Any?]'));
    expect(code, isNot(contains('if (')));
    // Single-element list serializations should not have a trailing comma.
    expect(code, matches(RegExp(r'return \[\s*data\s*]')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('protocol Api'));
    expect(code, contains('api.doSomething(arg: argArg) { result in'));
    expect(code, contains('reply(wrapResult(res))'));
    expect(code, isNot(contains('if (')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('func doSomething.*Input.*completion.*Output.*Void'));
    expect(code, isNot(contains('if (')));
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
            name: 'enum1'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[anEnum],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('enum Enum1: Int'));
    expect(code, contains('case one = 0'));
    expect(code, contains('case two = 1'));
    expect(code, isNot(contains('if (')));
  });

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions(
      copyrightHeader: <String>['hello world', ''],
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
    // There should be no trailing whitespace on generated comments.
    expect(code, isNot(matches(RegExp(r'^//.* $', multiLine: true))));
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
            name: 'field1'),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[classDefinition],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [Int64?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [String?: String?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doit(arg: [Int64?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doit(arg argArg: [Int64?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doit() throws -> [Int64?]'));
    expect(code, contains('let result = try api.doit()'));
    expect(code, contains('reply(wrapResult(result))'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'func doit(completion: @escaping (Result<[Int64?], PigeonError>) -> Void)'));
    expect(code, contains('let result = listResponse[0] as! [Int64?]'));
    expect(code, contains('completion(.success(result))'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func add(x: Int64, y: Int64) throws -> Int64'));
    expect(code, contains('let args = message as! [Any?]'));
    expect(code, contains('let xArg = args[0] as! Int64'));
    expect(code, contains('let yArg = args[1] as! Int64'));
    expect(code, contains('let result = try api.add(x: xArg, y: yArg)'));
    expect(code, contains('reply(wrapResult(result))'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('let channel = FlutterBasicMessageChannel'));
    expect(code, contains('let result = listResponse[0] as! Int64'));
    expect(code, contains('completion(.success(result))'));
    expect(
        code,
        contains(
            'func add(x xArg: Int64, y yArg: Int64, completion: @escaping (Result<Int64, PigeonError>) -> Void)'));
    expect(code,
        contains('channel.sendMessage([xArg, yArg] as [Any?]) { response in'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func doit() throws -> Int64?'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'func doit(completion: @escaping (Result<Int64?, Error>) -> Void'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('let fooArg: Int64? = nilOrValue(args[0])'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(
        code,
        contains(
            'func doit(foo fooArg: Int64?, completion: @escaping (Result<Void, PigeonError>) -> Void)'));
  });

  test('nonnull fields', () {
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
              isNullable: false,
            ),
            name: 'input')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('var input: String\n'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains(': FlutterStandardReader '));
  });

  test('swift function signature', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
          Method(
            name: 'set',
            location: ApiLocation.host,
            parameters: <Parameter>[
              Parameter(
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                ),
                name: 'value',
              ),
              Parameter(
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                ),
                name: 'key',
              ),
            ],
            swiftFunction: 'setValue(_:for:)',
            returnType: const TypeDeclaration.voidDeclaration(),
          )
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func setValue(_ value: Int64, for key: String)'));
  });

  test('swift function signature with same name argument', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
          Method(
            name: 'set',
            location: ApiLocation.host,
            parameters: <Parameter>[
              Parameter(
                type: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                ),
                name: 'key',
              ),
            ],
            swiftFunction: 'removeValue(key:)',
            returnType: const TypeDeclaration.voidDeclaration(),
          )
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func removeValue(key: String)'));
  });

  test('swift function signature with no arguments', () {
    final Root root = Root(
      apis: <Api>[
        AstHostApi(name: 'Api', methods: <Method>[
          Method(
            name: 'clear',
            location: ApiLocation.host,
            parameters: <Parameter>[],
            swiftFunction: 'removeAll()',
            returnType: const TypeDeclaration.voidDeclaration(),
          )
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: DEFAULT_PACKAGE_NAME,
    );
    final String code = sink.toString();
    expect(code, contains('func removeAll()'));
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
      containsFlutterApi: true,
    );
    final StringBuffer sink = StringBuffer();
    const SwiftOptions kotlinOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
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
            'completion(.failure(createConnectionError(withChannelName: channelName)))'));
    expect(
        code,
        contains(
            'return PigeonError(code: "channel-error", message: "Unable to establish connection on channel: \'\\(channelName)\'.", details: "")'));
  });
}
