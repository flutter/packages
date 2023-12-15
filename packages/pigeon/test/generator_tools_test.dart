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
  test('get codec classes from argument type arguments', () {
    final Api api = AstFlutterApi(name: 'Api', methods: <Method>[
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
    final Api api = AstFlutterApi(name: 'Api', methods: <Method>[
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
    final Api api = AstFlutterApi(name: 'Api', methods: <Method>[
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
      AstFlutterApi(
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
}
