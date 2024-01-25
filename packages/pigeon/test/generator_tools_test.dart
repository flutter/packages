// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/generator_tools.dart';
import 'package:test/test.dart';

bool _equalSet<T>(Set<T> x, Set<T> y) {
  if (x.length != y.length) {
    return false;
  }
  for (final T object in x) {
    if (!y.contains(object)) {
      return false;
    }
  }
  return true;
}

bool _equalMaps(Map<String, Object> x, Map<String, Object> y) {
  if (!_equalSet(x.keys.toSet(), y.keys.toSet())) {
    return false;
  }
  for (final String key in x.keys) {
    final Object xValue = x[key]!;
    if (xValue is Map<String, Object>) {
      if (!_equalMaps(xValue, (y[key] as Map<String, Object>?)!)) {
        return false;
      }
    } else {
      if (xValue != y[key]) {
        return false;
      }
    }
  }
  return true;
}

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
  test('test merge maps', () {
    final Map<String, Object> source = <String, Object>{
      '1': '1',
      '2': <String, Object>{
        '1': '1',
        '3': '3',
      },
      '3': '3', // not modified
    };
    final Map<String, Object> modification = <String, Object>{
      '1': '2', // modify
      '2': <String, Object>{
        '2': '2', // added
      },
    };
    final Map<String, Object> expected = <String, Object>{
      '1': '2',
      '2': <String, Object>{
        '1': '1',
        '2': '2',
        '3': '3',
      },
      '3': '3',
    };
    expect(_equalMaps(expected, mergeMaps(source, modification)), isTrue);
  });

  test('get codec classes from argument type arguments', () {
    final AstFlutterApi api = AstFlutterApi(name: 'Api', methods: <Method>[
      Method(
        name: 'doSomething',
        location: ApiLocation.flutter,
        parameters: <Parameter>[
          Parameter(
            type: TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(
                  baseName: 'Input',
                  isNullable: true,
                  associatedClass: emptyClass,
                )
              ],
            ),
            name: '',
          )
        ],
        returnType: TypeDeclaration(
          baseName: 'Output',
          isNullable: false,
          associatedClass: emptyClass,
        ),
        isAsynchronous: true,
      )
    ]);
    final Root root =
        Root(classes: <Class>[], apis: <Api>[api], enums: <Enum>[]);
    final List<EnumeratedClass> classes = getCodecClasses(api, root).toList();
    expect(classes.length, 2);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Input')
            .length,
        1);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Output')
            .length,
        1);
  });

  test('get codec classes from return value type arguments', () {
    final AstFlutterApi api = AstFlutterApi(name: 'Api', methods: <Method>[
      Method(
        name: 'doSomething',
        location: ApiLocation.flutter,
        parameters: <Parameter>[
          Parameter(
            type: TypeDeclaration(
              baseName: 'Output',
              isNullable: false,
              associatedClass: emptyClass,
            ),
            name: '',
          )
        ],
        returnType: TypeDeclaration(
          baseName: 'List',
          isNullable: false,
          typeArguments: <TypeDeclaration>[
            TypeDeclaration(
              baseName: 'Input',
              isNullable: true,
              associatedClass: emptyClass,
            )
          ],
        ),
        isAsynchronous: true,
      )
    ]);
    final Root root =
        Root(classes: <Class>[], apis: <Api>[api], enums: <Enum>[]);
    final List<EnumeratedClass> classes = getCodecClasses(api, root).toList();
    expect(classes.length, 2);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Input')
            .length,
        1);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Output')
            .length,
        1);
  });

  test('get codec classes from all arguments', () {
    final AstFlutterApi api = AstFlutterApi(name: 'Api', methods: <Method>[
      Method(
        name: 'doSomething',
        location: ApiLocation.flutter,
        parameters: <Parameter>[
          Parameter(
            type: TypeDeclaration(
              baseName: 'Foo',
              isNullable: false,
              associatedClass: emptyClass,
            ),
            name: '',
          ),
          Parameter(
            type: TypeDeclaration(
              baseName: 'Bar',
              isNullable: false,
              associatedEnum: emptyEnum,
            ),
            name: '',
          ),
        ],
        returnType: const TypeDeclaration(
          baseName: 'List',
          isNullable: false,
          typeArguments: <TypeDeclaration>[TypeDeclaration.voidDeclaration()],
        ),
        isAsynchronous: true,
      )
    ]);
    final Root root =
        Root(classes: <Class>[], apis: <Api>[api], enums: <Enum>[]);
    final List<EnumeratedClass> classes = getCodecClasses(api, root).toList();
    expect(classes.length, 2);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Foo')
            .length,
        1);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Bar')
            .length,
        1);
  });

  test('getCodecClasses: nested type arguments', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(name: 'Api', methods: <Method>[
        Method(
          name: 'foo',
          location: ApiLocation.flutter,
          parameters: <Parameter>[
            Parameter(
                name: 'x',
                type: TypeDeclaration(
                    isNullable: false,
                    baseName: 'List',
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(
                        baseName: 'Foo',
                        isNullable: true,
                        associatedClass: emptyClass,
                      )
                    ])),
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
        )
      ])
    ], classes: <Class>[
      Class(name: 'Foo', fields: <NamedType>[
        NamedType(
            name: 'bar',
            type: TypeDeclaration(
              baseName: 'Bar',
              isNullable: true,
              associatedClass: emptyClass,
            )),
      ]),
      Class(name: 'Bar', fields: <NamedType>[
        NamedType(
            name: 'value',
            type: const TypeDeclaration(
              baseName: 'int',
              isNullable: true,
            ))
      ])
    ], enums: <Enum>[]);
    final List<EnumeratedClass> classes =
        getCodecClasses(root.apis[0], root).toList();
    expect(classes.length, 2);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Foo')
            .length,
        1);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Bar')
            .length,
        1);
  });

  test('getCodecClasses: with Object', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(
        name: 'Api1',
        methods: <Method>[
          Method(
            name: 'foo',
            location: ApiLocation.flutter,
            parameters: <Parameter>[
              Parameter(
                  name: 'x',
                  type: const TypeDeclaration(
                      isNullable: false,
                      baseName: 'List',
                      typeArguments: <TypeDeclaration>[
                        TypeDeclaration(baseName: 'Object', isNullable: true)
                      ])),
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
          )
        ],
      ),
    ], classes: <Class>[
      Class(name: 'Foo', fields: <NamedType>[
        NamedType(
            name: 'bar',
            type: const TypeDeclaration(baseName: 'int', isNullable: true)),
      ]),
    ], enums: <Enum>[]);
    final List<EnumeratedClass> classes =
        getCodecClasses(root.apis[0], root).toList();
    expect(classes.length, 1);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Foo')
            .length,
        1);
  });

  test('getCodecClasses: unique entries', () {
    final Root root = Root(apis: <Api>[
      AstFlutterApi(
        name: 'Api1',
        methods: <Method>[
          Method(
            name: 'foo',
            location: ApiLocation.flutter,
            parameters: <Parameter>[
              Parameter(
                  name: 'x',
                  type: TypeDeclaration(
                    isNullable: false,
                    baseName: 'Foo',
                    associatedClass: emptyClass,
                  )),
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
          )
        ],
      ),
      AstHostApi(
        name: 'Api2',
        methods: <Method>[
          Method(
            name: 'foo',
            location: ApiLocation.host,
            parameters: <Parameter>[
              Parameter(
                  name: 'x',
                  type: TypeDeclaration(
                    isNullable: false,
                    baseName: 'Foo',
                    associatedClass: emptyClass,
                  )),
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
          )
        ],
      )
    ], classes: <Class>[
      Class(name: 'Foo', fields: <NamedType>[
        NamedType(
            name: 'bar',
            type: const TypeDeclaration(baseName: 'int', isNullable: true)),
      ]),
    ], enums: <Enum>[]);
    final List<EnumeratedClass> classes =
        getCodecClasses(root.apis[0], root).toList();
    expect(classes.length, 1);
    expect(
        classes
            .where((EnumeratedClass element) => element.name == 'Foo')
            .length,
        1);
  });

  test('deduces package name successfully', () {
    final String? dartPackageName =
        deducePackageName('./pigeons/core_tests.dart');

    expect(dartPackageName, 'pigeon');
  });

  test('recursiveGetSuperClassApisChain', () {
    final AstProxyApi superClassOfSuperClassApi = AstProxyApi(
      name: 'Api3',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
    );
    final AstProxyApi superClassApi = AstProxyApi(
      name: 'Api2',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
      superClass: TypeDeclaration(
        baseName: 'Api3',
        isNullable: false,
        associatedProxyApi: superClassOfSuperClassApi,
      ),
    );
    final AstProxyApi api = AstProxyApi(
      name: 'Api',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
      superClass: TypeDeclaration(
        baseName: 'Api2',
        isNullable: false,
        associatedProxyApi: superClassApi,
      ),
    );

    final List<AstProxyApi> apiChain = recursiveGetSuperClassApisChain(api);

    expect(
      apiChain,
      containsAllInOrder(<AstProxyApi>[
        superClassApi,
        superClassOfSuperClassApi,
      ]),
    );
  });

  test('recursiveFindAllInterfacesApis', () {
    final AstProxyApi interfaceOfInterfaceApi2 = AstProxyApi(
      name: 'Api5',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
    );
    final AstProxyApi interfaceOfInterfaceApi = AstProxyApi(
      name: 'Api4',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
    );
    final AstProxyApi interfaceApi2 = AstProxyApi(
      name: 'Api3',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
      interfaces: <TypeDeclaration>{
        TypeDeclaration(
          baseName: 'Api5',
          isNullable: false,
          associatedProxyApi: interfaceOfInterfaceApi2,
        ),
      },
    );
    final AstProxyApi interfaceApi = AstProxyApi(
      name: 'Api2',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
      interfaces: <TypeDeclaration>{
        TypeDeclaration(
          baseName: 'Api4',
          isNullable: false,
          associatedProxyApi: interfaceOfInterfaceApi,
        ),
        TypeDeclaration(
          baseName: 'Api5',
          isNullable: false,
          associatedProxyApi: interfaceOfInterfaceApi2,
        ),
      },
    );
    final AstProxyApi api = AstProxyApi(
      name: 'Api',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
      interfaces: <TypeDeclaration>{
        TypeDeclaration(
          baseName: 'Api2',
          isNullable: false,
          associatedProxyApi: interfaceApi,
        ),
        TypeDeclaration(
          baseName: 'Api3',
          isNullable: false,
          associatedProxyApi: interfaceApi2,
        ),
      },
    );

    final Set<AstProxyApi> allInterfaces = recursiveFindAllInterfaceApis(api);

    expect(
      allInterfaces,
      containsAll(<AstProxyApi>[
        interfaceApi,
        interfaceApi2,
        interfaceOfInterfaceApi,
        interfaceOfInterfaceApi2,
      ]),
    );
  });

  test(
      'recursiveFindAllInterfacesApis throws error if api recursively implements itself',
      () {
    final AstProxyApi a = AstProxyApi(
      name: 'A',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
    );
    final AstProxyApi b = AstProxyApi(
      name: 'B',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
    );
    final AstProxyApi c = AstProxyApi(
      name: 'C',
      methods: <Method>[],
      constructors: <Constructor>[],
      fields: <ApiField>[],
    );

    a.interfaces = <TypeDeclaration>{
      TypeDeclaration(baseName: 'B', isNullable: false, associatedProxyApi: b),
    };
    b.interfaces = <TypeDeclaration>{
      TypeDeclaration(baseName: 'C', isNullable: false, associatedProxyApi: c),
    };
    c.interfaces = <TypeDeclaration>{
      TypeDeclaration(baseName: 'A', isNullable: false, associatedProxyApi: a),
    };

    expect(
      () => recursiveFindAllInterfaceApis(a),
      throwsArgumentError,
    );
  });
}
