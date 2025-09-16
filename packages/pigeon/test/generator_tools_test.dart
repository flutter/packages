// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/src/ast.dart';
import 'package:pigeon/src/generator_tools.dart';
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

final Class emptyClass = Class(
  name: 'className',
  fields: <NamedType>[
    NamedType(
      name: 'namedTypeName',
      type: const TypeDeclaration(baseName: 'baseName', isNullable: false),
    ),
  ],
);

void main() {
  test('test merge maps', () {
    final Map<String, Object> source = <String, Object>{
      '1': '1',
      '2': <String, Object>{'1': '1', '3': '3'},
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
      '2': <String, Object>{'1': '1', '2': '2', '3': '3'},
      '3': '3',
    };
    expect(_equalMaps(expected, mergeMaps(source, modification)), isTrue);
  });

  test('get codec types from all classes and enums', () {
    final Root root = Root(
      classes: <Class>[
        Class(
          name: 'name',
          fields: <NamedType>[
            NamedType(
              name: 'name',
              type: const TypeDeclaration(baseName: 'name', isNullable: true),
            ),
          ],
        ),
      ],
      apis: <Api>[],
      enums: <Enum>[
        Enum(
          name: 'enum',
          members: <EnumMember>[EnumMember(name: 'enumMember')],
        ),
      ],
    );
    final List<EnumeratedType> types = getEnumeratedTypes(root).toList();
    expect(types.length, 2);
  });

  test('getEnumeratedTypes:ed type arguments', () {
    final Root root = Root(
      apis: <Api>[
        AstFlutterApi(
          name: 'Api',
          methods: <Method>[
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
                      ),
                    ],
                  ),
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Foo',
          fields: <NamedType>[
            NamedType(
              name: 'bar',
              type: TypeDeclaration(
                baseName: 'Bar',
                isNullable: true,
                associatedClass: emptyClass,
              ),
            ),
          ],
        ),
        Class(
          name: 'Bar',
          fields: <NamedType>[
            NamedType(
              name: 'value',
              type: const TypeDeclaration(baseName: 'int', isNullable: true),
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final List<EnumeratedType> classes = getEnumeratedTypes(root).toList();
    expect(classes.length, 2);
    expect(
      classes.where((EnumeratedType element) => element.name == 'Foo').length,
      1,
    );
    expect(
      classes.where((EnumeratedType element) => element.name == 'Bar').length,
      1,
    );
  });

  test('getEnumeratedTypes: Object', () {
    final Root root = Root(
      apis: <Api>[
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
                      TypeDeclaration(baseName: 'Object', isNullable: true),
                    ],
                  ),
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Foo',
          fields: <NamedType>[
            NamedType(
              name: 'bar',
              type: const TypeDeclaration(baseName: 'int', isNullable: true),
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final List<EnumeratedType> classes = getEnumeratedTypes(root).toList();
    expect(classes.length, 1);
    expect(
      classes.where((EnumeratedType element) => element.name == 'Foo').length,
      1,
    );
  });

  test('getEnumeratedTypes:ue entries', () {
    final Root root = Root(
      apis: <Api>[
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
                  ),
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
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
                  ),
                ),
              ],
              returnType: const TypeDeclaration.voidDeclaration(),
            ),
          ],
        ),
      ],
      classes: <Class>[
        Class(
          name: 'Foo',
          fields: <NamedType>[
            NamedType(
              name: 'bar',
              type: const TypeDeclaration(baseName: 'int', isNullable: true),
            ),
          ],
        ),
      ],
      enums: <Enum>[],
    );
    final List<EnumeratedType> classes = getEnumeratedTypes(root).toList();
    expect(classes.length, 1);
    expect(
      classes.where((EnumeratedType element) => element.name == 'Foo').length,
      1,
    );
  });

  test('deduces package name successfully', () {
    final String? dartPackageName = deducePackageName(
      './pigeons/core_tests.dart',
    );

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

    expect(
      api.allSuperClasses().toList(),
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

    expect(
      api.apisOfInterfaces(),
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
        TypeDeclaration(
          baseName: 'B',
          isNullable: false,
          associatedProxyApi: b,
        ),
      };
      b.interfaces = <TypeDeclaration>{
        TypeDeclaration(
          baseName: 'C',
          isNullable: false,
          associatedProxyApi: c,
        ),
      };
      c.interfaces = <TypeDeclaration>{
        TypeDeclaration(
          baseName: 'A',
          isNullable: false,
          associatedProxyApi: a,
        ),
      };

      expect(() => a.apisOfInterfaces(), throwsArgumentError);
    },
  );

  test('findHighestApiRequirement', () {
    final TypeDeclaration typeWithoutMinApi = TypeDeclaration(
      baseName: 'TypeWithoutMinApi',
      isNullable: false,
      associatedProxyApi: AstProxyApi(
        name: 'TypeWithoutMinApi',
        methods: <Method>[],
        constructors: <Constructor>[],
        fields: <ApiField>[],
      ),
    );

    final TypeDeclaration typeWithMinApi = TypeDeclaration(
      baseName: 'TypeWithMinApi',
      isNullable: false,
      associatedProxyApi: AstProxyApi(
        name: 'TypeWithMinApi',
        methods: <Method>[],
        constructors: <Constructor>[],
        fields: <ApiField>[],
      ),
    );

    final TypeDeclaration typeWithHighestMinApi = TypeDeclaration(
      baseName: 'TypeWithHighestMinApi',
      isNullable: false,
      associatedProxyApi: AstProxyApi(
        name: 'TypeWithHighestMinApi',
        methods: <Method>[],
        constructors: <Constructor>[],
        fields: <ApiField>[],
      ),
    );

    final ({TypeDeclaration type, int version})? result =
        findHighestApiRequirement(
          <TypeDeclaration>[
            typeWithoutMinApi,
            typeWithMinApi,
            typeWithHighestMinApi,
          ],
          onGetApiRequirement: (TypeDeclaration type) {
            if (type == typeWithMinApi) {
              return 1;
            } else if (type == typeWithHighestMinApi) {
              return 2;
            }

            return null;
          },
          onCompare: (int one, int two) => one.compareTo(two),
        );

    expect(result?.type, typeWithHighestMinApi);
    expect(result?.version, 2);
  });

  test('Indent.format trims indentation', () {
    final StringBuffer buffer = StringBuffer();
    final Indent indent = Indent(buffer);

    indent.format('''
      void myMethod() {

        print('hello');
      }''');

    expect(buffer.toString(), '''
void myMethod() {

  print('hello');
}
''');
  });
}
