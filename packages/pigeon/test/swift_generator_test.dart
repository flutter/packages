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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: Int? = nil'));
    expect(code,
        contains('static func fromMap(_ map: [String: Any?]) -> Foobar?'));
    expect(code, contains('func toMap() -> [String: Any?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('enum Foobar: Int'));
    expect(code, contains('  case one = 0'));
    expect(code, contains('  case two = 1'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('var aBool: Bool? = nil'));
    expect(code, contains('var aInt: Int? = nil'));
    expect(code, contains('var aDouble: Double? = nil'));
    expect(code, contains('var aString: String? = nil'));
    expect(code, contains('var aUint8List: [UInt8]? = nil'));
    expect(code, contains('var aInt32List: [Int32]? = nil'));
    expect(code, contains('var aInt64List: [Int64]? = nil'));
    expect(code, contains('var aFloat64List: [Float64]? = nil'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doSomething() -> Output'));
    expect(code, contains('let result = api.doSomething()'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
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
            name: 'field1',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [Any?]? = nil'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [AnyHashable: Any?]? = nil'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Outer'));
    expect(code, contains('struct Nested'));
    expect(code, contains('var nested: Nested? = nil'));
    expect(
        code, contains('static func fromMap(_ map: [String: Any?]) -> Outer?'));
    expect(code, contains('nested = Nested.fromMap(nestedMap)'));
    expect(code, contains('func toMap() -> [String: Any?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('protocol Api'));
    expect(code, contains('api.doSomething(arg: argArg) { result in'));
    expect(code, contains('reply(wrapResult(result))'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('class Api'));
    expect(code, matches('func doSomething.*Input.*completion.*Output.*Void'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('enum Enum1: Int'));
    expect(code, contains('case one = 0'));
    expect(code, contains('case two = 1'));
  });

  Iterable<String> _makeIterable(String string) sync* {
    yield string;
  }

  test('header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    final SwiftOptions swiftOptions = SwiftOptions(
      copyrightHeader: _makeIterable('hello world'),
    );
    generateSwift(swiftOptions, root, sink);
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('struct Foobar'));
    expect(code, contains('var field1: [Int?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
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
                    name: 'arg',
                    offset: null)
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit(arg: [Int?]'));
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
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit(arg argArg: [Int?]'));
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
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit() -> [Int?]'));
    expect(code, contains('let result = api.doit()'));
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
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit(completion: @escaping ([Int?]) -> Void'));
    expect(code, contains('let result = response as! [Int?]'));
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
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func add(x: Int, y: Int) -> Int'));
    expect(code, contains('guard let args = message as? [Any?]'));
    expect(code, contains('guard args.count == 2'));
    expect(code, contains('guard let xArg = args[0] as? Int'));
    expect(code, contains('let yArg = args[1] as? Int'));
    expect(code, contains('let result = api.add(x: xArg, y: yArg)'));
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
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    const SwiftOptions swiftOptions = SwiftOptions();
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('let channel = FlutterBasicMessageChannel'));
    expect(code, contains('let result = response as! Int'));
    expect(code, contains('completion(result)'));
    expect(
        code,
        contains(
            'func add(x xArg: Int, y yArg: Int, completion: @escaping (Int) -> Void)'));
    expect(code, contains('channel.sendMessage([xArg, yArg]) { response in'));
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
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit() -> Int?'));
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
    generateSwift(swiftOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('func doit(completion: @escaping (Int?) -> Void'));
  });
}
