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
    final Api api =
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
      Method(
        name: 'doSomething',
        arguments: <NamedType>[
          NamedType(
            type: const TypeDeclaration(
              baseName: 'List',
              isNullable: false,
              typeArguments: <TypeDeclaration>[
                TypeDeclaration(baseName: 'Input', isNullable: true)
              ],
            ),
            name: '',
            offset: null,
          )
        ],
        returnType:
            const TypeDeclaration(baseName: 'Output', isNullable: false),
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
    final Api api =
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
      Method(
        name: 'doSomething',
        arguments: <NamedType>[
          NamedType(
            type: const TypeDeclaration(baseName: 'Output', isNullable: false),
            name: '',
            offset: null,
          )
        ],
        returnType: const TypeDeclaration(
          baseName: 'List',
          isNullable: false,
          typeArguments: <TypeDeclaration>[
            TypeDeclaration(baseName: 'Input', isNullable: true)
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
    final Api api =
        Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
      Method(
        name: 'doSomething',
        arguments: <NamedType>[
          NamedType(
            type: const TypeDeclaration(baseName: 'Foo', isNullable: false),
            name: '',
            offset: null,
          ),
          NamedType(
            type: const TypeDeclaration(baseName: 'Bar', isNullable: false),
            name: '',
            offset: null,
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
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'foo',
          arguments: <NamedType>[
            NamedType(
                name: 'x',
                type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'List',
                    typeArguments: <TypeDeclaration>[
                      TypeDeclaration(baseName: 'Foo', isNullable: true)
                    ])),
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(name: 'Foo', fields: <NamedType>[
        NamedType(
            name: 'bar',
            type: const TypeDeclaration(baseName: 'Bar', isNullable: true)),
      ]),
      Class(name: 'Bar', fields: <NamedType>[
        NamedType(
            name: 'value',
            type: const TypeDeclaration(baseName: 'int', isNullable: true))
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

  test('getCodecClasses: unique entries', () {
    final Root root = Root(apis: <Api>[
      Api(
        name: 'Api1',
        location: ApiLocation.flutter,
        methods: <Method>[
          Method(
            name: 'foo',
            arguments: <NamedType>[
              NamedType(
                  name: 'x',
                  type: const TypeDeclaration(
                      isNullable: false, baseName: 'Foo')),
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
            isAsynchronous: false,
          )
        ],
      ),
      Api(
        name: 'Api2',
        location: ApiLocation.host,
        methods: <Method>[
          Method(
            name: 'foo',
            arguments: <NamedType>[
              NamedType(
                  name: 'x',
                  type: const TypeDeclaration(
                      isNullable: false, baseName: 'Foo')),
            ],
            returnType: const TypeDeclaration.voidDeclaration(),
            isAsynchronous: false,
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
}
