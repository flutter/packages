// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/objc_generator.dart';
import 'package:test/test.dart';

void main() {
  test('gen one class header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'field1',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(), root, sink);
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(code, matches('@property.*NSString.*field1'));
  });

  test('gen one class source', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'field1',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code, contains('#import "foo.h"'));
    expect(code, contains('@implementation Foobar'));
  });

  test('gen one enum header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[
      Enum(
        name: 'Enum1',
        members: <String>[
          'one',
          'two',
        ],
      )
    ]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(), root, sink);
    final String code = sink.toString();
    expect(code, contains('typedef NS_ENUM(NSUInteger, Enum1) {'));
    expect(code, contains('  Enum1One = 0,'));
    expect(code, contains('  Enum1Two = 1,'));
  });

  test('gen one enum header with prefix', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[
      Enum(
        name: 'Enum1',
        members: <String>[
          'one',
          'two',
        ],
      )
    ]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(prefix: 'PREFIX'), root, sink);
    final String code = sink.toString();
    expect(code, contains('typedef NS_ENUM(NSUInteger, PREFIXEnum1) {'));
    expect(code, contains('  PREFIXEnum1One = 0,'));
    expect(code, contains('  PREFIXEnum1Two = 1,'));
  });

  test('gen one class source with enum', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
                type: TypeDeclaration(baseName: 'String', isNullable: true),
                name: 'field1',
                offset: null),
            NamedType(
                type: TypeDeclaration(baseName: 'Enum1', isNullable: true),
                name: 'enum1',
                offset: null),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'Enum1',
          members: <String>[
            'one',
            'two',
          ],
        )
      ],
    );
    final StringBuffer sink = StringBuffer();
    generateObjcSource(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code, contains('#import "foo.h"'));
    expect(code, contains('@implementation Foobar'));
    expect(code, contains('result.enum1 = [dict[@"enum1"] integerValue];'));
  });

  test('gen one class header with enum', () {
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[
        Class(
          name: 'Foobar',
          fields: <NamedType>[
            NamedType(
                type: TypeDeclaration(baseName: 'String', isNullable: true),
                name: 'field1',
                offset: null),
            NamedType(
                type: TypeDeclaration(baseName: 'Enum1', isNullable: true),
                name: 'enum1',
                offset: null),
          ],
        ),
      ],
      enums: <Enum>[
        Enum(
          name: 'Enum1',
          members: <String>[
            'one',
            'two',
          ],
        )
      ],
    );
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code, contains('@property(nonatomic, assign) Enum1 enum1'));
  });

  test('gen one api header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(baseName: 'Input', isNullable: false),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(), root, sink);
    final String code = sink.toString();
    expect(code, contains('@interface Input'));
    expect(code, contains('@interface Output'));
    expect(code, contains('@protocol Api'));
    expect(code, matches('nullable Output.*doSomething.*Input.*FlutterError'));
    expect(code, matches('ApiSetup.*<Api>.*_Nullable'));
  });

  test('gen one api source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code, contains('#import "foo.h"'));
    expect(code, contains('@implementation Input'));
    expect(code, contains('@implementation Output'));
    expect(code, contains('ApiSetup('));
  });

  test('all the simple datatypes header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'bool', isNullable: true),
            name: 'aBool',
            offset: null),
        NamedType(
            type: TypeDeclaration(baseName: 'int', isNullable: true),
            name: 'aInt',
            offset: null),
        NamedType(
            type: TypeDeclaration(baseName: 'double', isNullable: true),
            name: 'aDouble',
            offset: null),
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'aString',
            offset: null),
        NamedType(
            type: TypeDeclaration(baseName: 'Uint8List', isNullable: true),
            name: 'aUint8List',
            offset: null),
        NamedType(
            type: TypeDeclaration(baseName: 'Int32List', isNullable: true),
            name: 'aInt32List',
            offset: null),
        NamedType(
            type: TypeDeclaration(baseName: 'Int64List', isNullable: true),
            name: 'aInt64List',
            offset: null),
        NamedType(
            type: TypeDeclaration(baseName: 'Float64List', isNullable: true),
            name: 'aFloat64List',
            offset: null),
      ]),
    ], enums: <Enum>[]);

    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(code, contains('@class FlutterStandardTypedData;'));
    expect(code, matches('@property.*strong.*NSNumber.*aBool'));
    expect(code, matches('@property.*strong.*NSNumber.*aInt'));
    expect(code, matches('@property.*strong.*NSNumber.*aDouble'));
    expect(code, matches('@property.*copy.*NSString.*aString'));
    expect(code,
        matches('@property.*strong.*FlutterStandardTypedData.*aUint8List'));
    expect(code,
        matches('@property.*strong.*FlutterStandardTypedData.*aInt32List'));
    expect(code,
        matches('@property.*strong.*FlutterStandardTypedData.*Int64List'));
    expect(code,
        matches('@property.*strong.*FlutterStandardTypedData.*Float64List'));
  });

  test('bool source', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'bool', isNullable: true),
            name: 'aBool',
            offset: null),
      ]),
    ], enums: <Enum>[]);

    final StringBuffer sink = StringBuffer();
    generateObjcSource(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code, contains('@implementation Foobar'));
    expect(code, contains('result.aBool = dict[@"aBool"];'));
  });

  test('nested class header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'Input', isNullable: true),
            name: 'nested',
            offset: null)
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code,
        contains('@property(nonatomic, strong, nullable) Input * nested;'));
  });

  test('nested class source', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'Input', isNullable: true),
            name: 'nested',
            offset: null)
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code, contains('result.nested = [Input fromMap:dict[@"nested"]];'));
    expect(code, matches('[self.nested toMap].*@"nested"'));
  });

  test('prefix class header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'field1',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, contains('@interface ABCFoobar'));
  });

  test('prefix class source', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'field1',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(const ObjcOptions(prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, contains('@implementation ABCFoobar'));
  });

  test('prefix nested class header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration(baseName: 'Nested', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'Input', isNullable: true),
            name: 'nested',
            offset: null)
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, matches('property.*ABCInput'));
    expect(code, matches('ABCNested.*doSomething.*ABCInput'));
    expect(code, contains('@protocol ABCApi'));
  });

  test('prefix nested class source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration(baseName: 'Nested', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Nested', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'Input', isNullable: true),
            name: 'nested',
            offset: null)
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(const ObjcOptions(prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, contains('ABCInput fromMap'));
    expect(code, matches('ABCInput.*=.*message'));
    expect(code, contains('void ABCApiSetup('));
  });

  test('gen flutter api header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code, contains('@interface Api : NSObject'));
    expect(
        code,
        contains(
            'initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;'));
    expect(code, matches('void.*doSomething.*Input.*Output'));
  });

  test('gen flutter api source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ])
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(const ObjcOptions(header: 'foo.h'), root, sink);
    final String code = sink.toString();
    expect(code, contains('@implementation Api'));
    expect(code, matches('void.*doSomething.*Input.*Output.*{'));
  });

  test('gen host void header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration.voidDeclaration())
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, contains('(void)doSomething:'));
  });

  test('gen host void source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration.voidDeclaration())
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, isNot(matches('=.*doSomething')));
    expect(code, matches('[.*doSomething:.*]'));
    expect(code, contains('callback(wrapResult(nil, error))'));
  });

  test('gen flutter void return header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration.voidDeclaration())
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, contains('completion:(void(^)(NSError* _Nullable))'));
  });

  test('gen flutter void return source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration.voidDeclaration())
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, contains('completion:(void(^)(NSError* _Nullable))'));
    expect(code, contains('completion(nil)'));
  });

  test('gen host void arg header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, matches('ABCOutput.*doSomething:[(]FlutterError'));
  });

  test('gen host void arg source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, matches('output.*=.*api doSomething:&error'));
  });

  test('gen flutter void arg header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            '(void)doSomething:(void(^)(ABCOutput*, NSError* _Nullable))completion'));
  });

  test('gen flutter void arg header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false))
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            '(void)doSomething:(void(^)(ABCOutput*, NSError* _Nullable))completion'));
    expect(code, contains('channel sendMessage:nil'));
  });

  test('gen list', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'List', isNullable: true),
            name: 'field1',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(), root, sink);
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(code, matches('@property.*NSArray.*field1'));
  });

  test('gen map', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'Map', isNullable: true),
            name: 'field1',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(const ObjcOptions(), root, sink);
    final String code = sink.toString();
    expect(code, contains('@interface Foobar'));
    expect(code, matches('@property.*NSDictionary.*field1'));
  });

  test('async void(input) HostApi header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration.voidDeclaration(),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            '(void)doSomething:(nullable ABCInput *)input completion:(void(^)(FlutterError *_Nullable))completion'));
  });

  test('async output(input) HostApi header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            '(void)doSomething:(nullable ABCInput *)input completion:(void(^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion'));
  });

  test('async output(void) HostApi header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            '(void)doSomething:(void(^)(ABCOutput *_Nullable, FlutterError *_Nullable))completion'));
  });

  test('async void(void) HostApi header', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: TypeDeclaration.voidDeclaration(),
            isAsynchronous: true)
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            '(void)doSomething:(void(^)(FlutterError *_Nullable))completion'));
  });

  test('async output(input) HostApi source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            '[api doSomething:input completion:^(ABCOutput *_Nullable output, FlutterError *_Nullable error) {'));
  });

  test('async void(input) HostApi source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[
              NamedType(
                  type: TypeDeclaration(
                    baseName: 'Input',
                    isNullable: false,
                  ),
                  name: '',
                  offset: null)
            ],
            returnType: TypeDeclaration.voidDeclaration(),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Input', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'input',
            offset: null)
      ]),
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            '[api doSomething:input completion:^(FlutterError *_Nullable error) {'));
  });

  test('async void(void) HostApi source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: TypeDeclaration.voidDeclaration(),
            isAsynchronous: true)
      ])
    ], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code, contains('[api doSomething:^(FlutterError *_Nullable error) {'));
  });

  test('async output(void) HostApi source', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
            name: 'doSomething',
            arguments: <NamedType>[],
            returnType: TypeDeclaration(baseName: 'Output', isNullable: false),
            isAsynchronous: true)
      ])
    ], classes: <Class>[
      Class(name: 'Output', fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(baseName: 'String', isNullable: true),
            name: 'output',
            offset: null)
      ]),
    ], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(
        code,
        contains(
            '[api doSomething:^(ABCOutput *_Nullable output, FlutterError *_Nullable error) {'));
  });

  Iterable<String> _makeIterable(String string) sync* {
    yield string;
  }

  test('source copyright', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcSource(
      ObjcOptions(
          header: 'foo.h',
          prefix: 'ABC',
          copyrightHeader: _makeIterable('hello world')),
      root,
      sink,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('header copyright', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    final StringBuffer sink = StringBuffer();
    generateObjcHeader(
      ObjcOptions(
          header: 'foo.h',
          prefix: 'ABC',
          copyrightHeader: _makeIterable('hello world')),
      root,
      sink,
    );
    final String code = sink.toString();
    expect(code, startsWith('// hello world'));
  });

  test('field generics', () {
    final Class klass = Class(
      name: 'Foobar',
      fields: <NamedType>[
        NamedType(
            type: TypeDeclaration(
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
    generateObjcHeader(
        const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
    final String code = sink.toString();
    expect(code, contains('NSArray<NSNumber *> * field1'));
  });

  test('host generics argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                    type: TypeDeclaration(
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
    {
      final StringBuffer sink = StringBuffer();
      generateObjcHeader(
          const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
      final String code = sink.toString();
      expect(code, contains('doit:(NSArray<NSNumber *>*)input'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateObjcSource(
          const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
      final String code = sink.toString();
      expect(code, contains('NSArray<NSNumber *> *input = message'));
    }
  });

  test('flutter generics argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType: TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                    type: TypeDeclaration(
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
    {
      final StringBuffer sink = StringBuffer();
      generateObjcHeader(
          const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
      final String code = sink.toString();
      expect(code, contains('doit:(NSArray<NSNumber *>*)input'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateObjcSource(
          const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
      final String code = sink.toString();
      expect(code, contains('doit:(NSArray<NSNumber *>*)input'));
    }
  });

  test('host nested generic argument', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: TypeDeclaration.voidDeclaration(),
              arguments: <NamedType>[
                NamedType(
                    type: TypeDeclaration(
                        baseName: 'List',
                        isNullable: false,
                        typeArguments: <TypeDeclaration>[
                          TypeDeclaration(
                              baseName: 'List',
                              isNullable: true,
                              typeArguments: <TypeDeclaration>[
                                TypeDeclaration(
                                    baseName: 'bool', isNullable: true)
                              ]),
                        ]),
                    name: 'arg',
                    offset: null)
              ])
        ])
      ],
      classes: <Class>[],
      enums: <Enum>[],
    );
    {
      final StringBuffer sink = StringBuffer();
      generateObjcHeader(
          const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
      final String code = sink.toString();
      expect(code, contains('doit:(NSArray<NSArray<NSNumber *> *>*)input'));
    }
  });

  test('host generics return', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
          Method(
              name: 'doit',
              returnType: TypeDeclaration(
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
    {
      final StringBuffer sink = StringBuffer();
      generateObjcHeader(
          const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
      final String code = sink.toString();
      expect(code, contains('-(nullable NSArray<NSNumber *> *)doit:'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateObjcSource(
          const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
      final String code = sink.toString();
      expect(code, contains('NSArray<NSNumber *> *output ='));
    }
  });

  test('host generics return', () {
    final Root root = Root(
      apis: <Api>[
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
          Method(
              name: 'doit',
              returnType: TypeDeclaration(
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
    {
      final StringBuffer sink = StringBuffer();
      generateObjcHeader(
          const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
      final String code = sink.toString();
      expect(code, contains('doit:(void(^)(NSArray<NSNumber *>*'));
    }
    {
      final StringBuffer sink = StringBuffer();
      generateObjcSource(
          const ObjcOptions(header: 'foo.h', prefix: 'ABC'), root, sink);
      final String code = sink.toString();
      expect(code, contains('doit:(void(^)(NSArray<NSNumber *>*'));
    }
  });
}
