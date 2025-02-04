// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/src/ast.dart';
import 'package:pigeon/src/kotlin/kotlin_generator.dart';
import 'package:test/test.dart';

const String DEFAULT_PACKAGE_NAME = 'test_package';

void main() {
  group('ProxyApi', () {
    test('one api', () {
      final Root root = Root(
        apis: <Api>[
          AstProxyApi(
            name: 'Api',
            kotlinOptions: const KotlinProxyApiOptions(
              fullClassName: 'my.library.Api',
            ),
            constructors: <Constructor>[
              Constructor(
                name: 'name',
                parameters: <Parameter>[
                  Parameter(
                    type: const TypeDeclaration(
                      baseName: 'Input',
                      isNullable: false,
                    ),
                    name: 'input',
                  ),
                ],
              ),
            ],
            fields: <ApiField>[
              ApiField(
                name: 'someField',
                type: const TypeDeclaration(
                  baseName: 'int',
                  isNullable: false,
                ),
              )
            ],
            methods: <Method>[
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
                isRequired: false,
                parameters: <Parameter>[
                  Parameter(
                    type: const TypeDeclaration(
                      baseName: 'Input',
                      isNullable: false,
                    ),
                    name: 'input',
                  ),
                ],
                returnType: const TypeDeclaration(
                  baseName: 'String',
                  isNullable: false,
                ),
              ),
            ],
          )
        ],
        classes: <Class>[],
        enums: <Enum>[],
      );
      final StringBuffer sink = StringBuffer();
      const KotlinGenerator generator = KotlinGenerator();
      generator.generate(
        const KotlinOptions(fileSpecificClassNameComponent: 'MyFile'),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();
      final String collapsedCode = _collapseNewlineAndIndentation(code);

      // Instance Manager
      expect(code, contains(r'class MyFilePigeonInstanceManager'));
      expect(code, contains(r'class MyFilePigeonInstanceManagerApi'));

      // API registrar
      expect(
        code,
        contains(
          'abstract class MyFilePigeonProxyApiRegistrar(val binaryMessenger: BinaryMessenger)',
        ),
      );

      // Codec
      expect(
          code,
          contains(
              'private class MyFilePigeonProxyApiBaseCodec(val registrar: MyFilePigeonProxyApiRegistrar) : MyFilePigeonCodec()'));

      // Proxy API class
      expect(
        code,
        contains(
          r'abstract class PigeonApiApi(open val pigeonRegistrar: MyFilePigeonProxyApiRegistrar)',
        ),
      );

      // Constructors
      expect(
        collapsedCode,
        contains(
          r'abstract fun name(someField: Long, input: Input)',
        ),
      );
      expect(
        collapsedCode,
        contains(
          r'fun pigeon_newInstance(pigeon_instanceArg: my.library.Api, callback: (Result<Unit>) -> Unit)',
        ),
      );

      // Field
      expect(
        code,
        contains(
          'abstract fun someField(pigeon_instance: my.library.Api): Long',
        ),
      );

      // Dart -> Host method
      expect(
        collapsedCode,
        contains('api.doSomething(pigeon_instanceArg, inputArg)'),
      );

      // Host -> Dart method
      expect(
        code,
        contains(
          r'fun setUpMessageHandlers(binaryMessenger: BinaryMessenger, api: PigeonApiApi?)',
        ),
      );
      expect(
        code,
        contains(
          'fun doSomethingElse(pigeon_instanceArg: my.library.Api, inputArg: Input, callback: (Result<String>) -> Unit)',
        ),
      );
    });

    group('inheritance', () {
      test('extends', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(apis: <Api>[
          AstProxyApi(
            name: 'Api',
            constructors: <Constructor>[],
            fields: <ApiField>[],
            methods: <Method>[],
            superClass: TypeDeclaration(
              baseName: api2.name,
              isNullable: false,
              associatedProxyApi: api2,
            ),
          ),
          api2,
        ], classes: <Class>[], enums: <Enum>[]);
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains('fun pigeon_getPigeonApiApi2(): PigeonApiApi2'),
        );
      });

      test('implements', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(apis: <Api>[
          AstProxyApi(
            name: 'Api',
            constructors: <Constructor>[],
            fields: <ApiField>[],
            methods: <Method>[],
            interfaces: <TypeDeclaration>{
              TypeDeclaration(
                baseName: api2.name,
                isNullable: false,
                associatedProxyApi: api2,
              )
            },
          ),
          api2,
        ], classes: <Class>[], enums: <Enum>[]);
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains('fun pigeon_getPigeonApiApi2(): PigeonApiApi2'));
      });

      test('implements 2 ProxyApis', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final AstProxyApi api3 = AstProxyApi(
          name: 'Api3',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(apis: <Api>[
          AstProxyApi(
            name: 'Api',
            constructors: <Constructor>[],
            fields: <ApiField>[],
            methods: <Method>[],
            interfaces: <TypeDeclaration>{
              TypeDeclaration(
                baseName: api2.name,
                isNullable: false,
                associatedProxyApi: api2,
              ),
              TypeDeclaration(
                baseName: api3.name,
                isNullable: false,
                associatedProxyApi: api3,
              ),
            },
          ),
          api2,
          api3,
        ], classes: <Class>[], enums: <Enum>[]);
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains('fun pigeon_getPigeonApiApi2(): PigeonApiApi2'));
        expect(code, contains('fun pigeon_getPigeonApiApi3(): PigeonApiApi3'));
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
            ], fields: <ApiField>[], methods: <Method>[]),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          code,
          contains(
            'abstract class PigeonApiApi(open val pigeonRegistrar: PigeonProxyApiRegistrar) ',
          ),
        );
        expect(
          collapsedCode,
          contains('abstract fun pigeon_defaultConstructor(): Api'),
        );
        expect(
          collapsedCode,
          contains(
            r'val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.test_package.Api.pigeon_defaultConstructor"',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.pigeonRegistrar.instanceManager.addDartCreatedInstance(api.pigeon_defaultConstructor(',
          ),
        );
      });

      test('multiple params constructor', () {
        final Enum anEnum = Enum(
          name: 'AnEnum',
          members: <EnumMember>[EnumMember(name: 'one')],
        );
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
                    type: TypeDeclaration(
                      isNullable: false,
                      baseName: 'AnEnum',
                      associatedEnum: anEnum,
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
                    type: TypeDeclaration(
                      isNullable: true,
                      baseName: 'AnEnum',
                      associatedEnum: anEnum,
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
            ], fields: <ApiField>[], methods: <Method>[]),
            AstProxyApi(
              name: 'Api2',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[anEnum],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          code,
          contains(
            'abstract class PigeonApiApi(open val pigeonRegistrar: PigeonProxyApiRegistrar) ',
          ),
        );
        expect(
          collapsedCode,
          contains(
            'abstract fun name(validType: Long, enumType: AnEnum, '
            'proxyApiType: Api2, nullableValidType: Long?, '
            'nullableEnumType: AnEnum?, nullableProxyApiType: Api2?): Api',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.pigeonRegistrar.instanceManager.addDartCreatedInstance(api.name('
            r'validTypeArg,enumTypeArg,proxyApiTypeArg,nullableValidTypeArg,'
            r'nullableEnumTypeArg,nullableProxyApiTypeArg), pigeon_identifierArg)',
          ),
        );
      });
    });

    group('Fields', () {
      test('constructor with fields', () {
        final Enum anEnum = Enum(
          name: 'AnEnum',
          members: <EnumMember>[EnumMember(name: 'one')],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[
                Constructor(
                  name: 'name',
                  parameters: <Parameter>[],
                )
              ],
              fields: <ApiField>[
                ApiField(
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'int',
                  ),
                  name: 'validType',
                ),
                ApiField(
                  type: TypeDeclaration(
                    isNullable: false,
                    baseName: 'AnEnum',
                    associatedEnum: anEnum,
                  ),
                  name: 'enumType',
                ),
                ApiField(
                  type: const TypeDeclaration(
                    isNullable: false,
                    baseName: 'Api2',
                  ),
                  name: 'proxyApiType',
                ),
                ApiField(
                  type: const TypeDeclaration(
                    isNullable: true,
                    baseName: 'int',
                  ),
                  name: 'nullableValidType',
                ),
                ApiField(
                  type: TypeDeclaration(
                    isNullable: true,
                    baseName: 'AnEnum',
                    associatedEnum: anEnum,
                  ),
                  name: 'nullableEnumType',
                ),
                ApiField(
                  type: const TypeDeclaration(
                    isNullable: true,
                    baseName: 'Api2',
                  ),
                  name: 'nullableProxyApiType',
                ),
              ],
              methods: <Method>[],
            ),
            AstProxyApi(
              name: 'Api2',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[anEnum],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'abstract fun name(validType: Long, enumType: AnEnum, '
            'proxyApiType: Api2, nullableValidType: Long?, '
            'nullableEnumType: AnEnum?, nullableProxyApiType: Api2?): Api',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.pigeonRegistrar.instanceManager.addDartCreatedInstance(api.name('
            r'validTypeArg,enumTypeArg,proxyApiTypeArg,nullableValidTypeArg,'
            r'nullableEnumTypeArg,nullableProxyApiTypeArg), pigeon_identifierArg)',
          ),
        );
        expect(
          collapsedCode,
          contains(
            'channel.send(listOf(pigeon_identifierArg, validTypeArg, '
            'enumTypeArg, proxyApiTypeArg, nullableValidTypeArg, '
            'nullableEnumTypeArg, nullableProxyApiTypeArg))',
          ),
        );
        expect(
          code,
          contains(r'abstract fun validType(pigeon_instance: Api): Long'),
        );
        expect(
          code,
          contains(r'abstract fun enumType(pigeon_instance: Api): AnEnum'),
        );
        expect(
          code,
          contains(r'abstract fun proxyApiType(pigeon_instance: Api): Api2'),
        );
        expect(
          code,
          contains(
            r'abstract fun nullableValidType(pigeon_instance: Api): Long?',
          ),
        );
        expect(
          code,
          contains(
            r'abstract fun nullableEnumType(pigeon_instance: Api): AnEnum?',
          ),
        );
        expect(
          code,
          contains(
            r'abstract fun nullableProxyApiType(pigeon_instance: Api): Api2?',
          ),
        );
      });

      test('attached field', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[
                ApiField(
                  name: 'aField',
                  isAttached: true,
                  type: TypeDeclaration(
                    baseName: 'Api2',
                    isNullable: false,
                    associatedProxyApi: api2,
                  ),
                ),
              ],
              methods: <Method>[],
            ),
            api2,
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(
          code,
          contains(r'abstract fun aField(pigeon_instance: Api): Api2'),
        );
        expect(
          code,
          contains(
            r'api.pigeonRegistrar.instanceManager.addDartCreatedInstance(api.aField(pigeon_instanceArg), pigeon_identifierArg)',
          ),
        );
      });

      test('static attached field', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[
                ApiField(
                  name: 'aField',
                  isStatic: true,
                  isAttached: true,
                  type: TypeDeclaration(
                    baseName: 'Api2',
                    isNullable: false,
                    associatedProxyApi: api2,
                  ),
                ),
              ],
              methods: <Method>[],
            ),
            api2,
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(
          code,
          contains(r'abstract fun aField(): Api2'),
        );
        expect(
          code,
          contains(
            r'api.pigeonRegistrar.instanceManager.addDartCreatedInstance(api.aField(), pigeon_identifierArg)',
          ),
        );
      });
    });

    group('Host methods', () {
      test('multiple params method', () {
        final Enum anEnum = Enum(
          name: 'AnEnum',
          members: <EnumMember>[EnumMember(name: 'one')],
        );
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[
                Method(
                  name: 'doSomething',
                  location: ApiLocation.host,
                  parameters: <Parameter>[
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: false,
                        baseName: 'int',
                      ),
                      name: 'validType',
                    ),
                    Parameter(
                      type: TypeDeclaration(
                        isNullable: false,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
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
                      type: TypeDeclaration(
                        isNullable: true,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
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
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
              ],
            ),
            AstProxyApi(
              name: 'Api2',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[anEnum],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'abstract fun doSomething(pigeon_instance: Api, validType: Long, '
            'enumType: AnEnum, proxyApiType: Api2, nullableValidType: Long?, '
            'nullableEnumType: AnEnum?, nullableProxyApiType: Api2?)',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'api.doSomething(pigeon_instanceArg, validTypeArg, enumTypeArg, '
            r'proxyApiTypeArg, nullableValidTypeArg, nullableEnumTypeArg, '
            r'nullableProxyApiTypeArg)',
          ),
        );
      });

      test('static method', () {
        final Root root = Root(
          apis: <Api>[
            AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[
                Method(
                  name: 'doSomething',
                  location: ApiLocation.host,
                  isStatic: true,
                  parameters: <Parameter>[],
                  returnType: const TypeDeclaration.voidDeclaration(),
                ),
              ],
            ),
          ],
          classes: <Class>[],
          enums: <Enum>[],
        );
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(collapsedCode, contains('abstract fun doSomething()'));
        expect(collapsedCode, contains(r'api.doSomething()'));
      });
    });

    group('Flutter methods', () {
      test('multiple params flutter method', () {
        final Enum anEnum = Enum(
          name: 'AnEnum',
          members: <EnumMember>[EnumMember(name: 'one')],
        );
        final Root root = Root(apis: <Api>[
          AstProxyApi(
              name: 'Api',
              constructors: <Constructor>[],
              fields: <ApiField>[],
              methods: <Method>[
                Method(
                  name: 'doSomething',
                  location: ApiLocation.flutter,
                  parameters: <Parameter>[
                    Parameter(
                      type: const TypeDeclaration(
                        isNullable: false,
                        baseName: 'int',
                      ),
                      name: 'validType',
                    ),
                    Parameter(
                      type: TypeDeclaration(
                        isNullable: false,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
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
                      type: TypeDeclaration(
                        isNullable: true,
                        baseName: 'AnEnum',
                        associatedEnum: anEnum,
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
                  returnType: const TypeDeclaration.voidDeclaration(),
                )
              ])
        ], classes: <Class>[], enums: <Enum>[
          anEnum
        ]);
        final StringBuffer sink = StringBuffer();
        const KotlinGenerator generator = KotlinGenerator();
        generator.generate(
          const KotlinOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(
          collapsedCode,
          contains(
            'fun doSomething(pigeon_instanceArg: Api, validTypeArg: Long, '
            'enumTypeArg: AnEnum, proxyApiTypeArg: Api2, nullableValidTypeArg: Long?, '
            'nullableEnumTypeArg: AnEnum?, nullableProxyApiTypeArg: Api2?, '
            'callback: (Result<Unit>) -> Unit)',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'channel.send(listOf(pigeon_instanceArg, validTypeArg, enumTypeArg, '
            r'proxyApiTypeArg, nullableValidTypeArg, nullableEnumTypeArg, '
            r'nullableProxyApiTypeArg))',
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
