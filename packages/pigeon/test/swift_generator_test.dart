// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/swift_generator.dart';
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: Int32? = nil'));
    expect(code, contains('static func fromList(_ list: [Any]) -> Foobar?'));
    expect(code, contains('func toList() -> [Any?]'));
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('enum Foobar: Int'));
    expect(code, contains('  case one = 0'));
    expect(code, contains('  case two = 1'));
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
                      const TypeDeclaration(baseName: 'Foo', isNullable: false))
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('enum Foo: Int'));
    expect(code, contains('let fooArg = Foo(rawValue: args[0] as! Int)!'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('protocol Api'));
    expect(code, matches('func doSomething.*Input.*Output'));
    expect(code, contains('doSomethingChannel.setMessageHandler'));
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('var aBool: Bool? = nil'));
    expect(code, contains('var aInt: Int32? = nil'));
    expect(code, contains('var aDouble: Double? = nil'));
    expect(code, contains('var aString: String? = nil'));
    expect(code, contains('var aUint8List: FlutterStandardTypedData? = nil'));
    expect(code, contains('var aInt32List: FlutterStandardTypedData? = nil'));
    expect(code, contains('var aInt64List: FlutterStandardTypedData? = nil'));
    expect(code, contains('var aFloat64List: FlutterStandardTypedData? = nil'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, contains('init(binaryMessenger: FlutterBinaryMessenger)'));
    expect(code, matches('func doSomething.*Input.*Output'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, isNot(matches('.*doSomething(.*) ->')));
    expect(code, matches('doSomething(.*)'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('completion: @escaping () -> Void'));
    expect(code, contains('completion()'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doSomething() throws -> Output'));
    expect(code, contains('let result = try api.doSomething()'));
    expect(code, contains('reply(wrapResult(result))'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code,
        contains('func doSomething(completion: @escaping (Output) -> Void)'));
    expect(code, contains('channel.sendMessage(nil'));
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [Any]? = nil'));
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [AnyHashable: Any]? = nil'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Outer'));
    expect(code, contains('struct Nested'));
    expect(code, contains('var nested: Nested? = nil'));
    expect(code, contains('static func fromList(_ list: [Any]) -> Outer?'));
    expect(code, contains('nested = Nested.fromList(nestedList as [Any])'));
    expect(code, contains('func toList() -> [Any?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('protocol Api'));
    expect(code, contains('api.doSomething(arg: argArg) { result in'));
    expect(code, contains('reply(wrapResult(res))'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('func doSomething.*Input.*completion.*Output.*Void'));
  });

  test('gen one enum class', () {
    final Enum anEnum = Enum(
      name: 'Enum1',
      members: <EnumMember>[
        EnumMember(name: 'one'),
        EnumMember(name: 'two'),
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('enum Enum1: Int'));
    expect(code, contains('case one = 0'));
    expect(code, contains('case two = 1'));
  });

  Iterable<String> makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    final SwiftOptions swiftOptions = SwiftOptions(
      copyrightHeader: makeIterable('hello world'),
    );
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('generics - list', () {
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [Int32?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [String?: String?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit(arg: [Int32?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit(arg argArg: [Int32?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit() throws -> [Int32?]'));
    expect(code, contains('let result = try api.doit()'));
    expect(code, contains('reply(wrapResult(result))'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(
        code, contains('func doit(completion: @escaping ([Int32?]) -> Void'));
    expect(code, contains('let result = response as! [Int32?]'));
    expect(code, contains('completion(result)'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func add(x: Int32, y: Int32) throws -> Int32'));
    expect(code, contains('let args = message as! [Any]'));
    expect(code, contains('let xArg = args[0] as! Int32'));
    expect(code, contains('let yArg = args[1] as! Int32'));
    expect(code, contains('let result = try api.add(x: xArg, y: yArg)'));
    expect(code, contains('reply(wrapResult(result))'));
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
                    const TypeDeclaration(baseName: 'int', isNullable: false)),
            NamedType(
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('let channel = FlutterBasicMessageChannel'));
    expect(code, contains('let result = response as! Int32'));
    expect(code, contains('completion(result)'));
    expect(
        code,
        contains(
            'func add(x xArg: Int32, y yArg: Int32, completion: @escaping (Int32) -> Void)'));
    expect(code,
        contains('channel.sendMessage([xArg, yArg] as [Any?]) { response in'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit() throws -> Int32?'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            'func doit(completion: @escaping (Result<Int32?, Error>) -> Void'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('let fooArg = args[0] as! Int32?'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            'func doit(foo fooArg: Int32?, completion: @escaping () -> Void'));
  });

  test('nonnull fields', () {
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
              isNullable: false,
            ),
            name: 'input')
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    for (final String comment in comments) {
      expect(code, contains('///$comment'));
    }
    expect(code, contains('/// ///'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, isNot(contains(': FlutterStandardReader ')));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains(': FlutterStandardReader '));
  });

  test('swift function signature', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
            name: 'set',
            arguments: <NamedType>[
              NamedType(
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                ),
                name: 'value',
              ),
              NamedType(
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func setValue(_ value: Int32, for key: String)'));
  });

  test('swift function signature with same name argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
            name: 'set',
            arguments: <NamedType>[
              NamedType(
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func removeValue(key: String)'));
  });

  test('swift function signature with no arguments', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
            name: 'clear',
            arguments: <NamedType>[],
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
    generator.generate(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func removeAll()'));
  });
}
