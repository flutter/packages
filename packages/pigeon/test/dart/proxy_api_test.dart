// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/dart_generator.dart';
import 'package:test/test.dart';

const String DEFAULT_PACKAGE_NAME = 'test_package';

void main() {
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
        ], fields: <ApiField>[
          ApiField(
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
            isRequired: false,
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
      expect(code, contains(r'class PigeonInternalInstanceManager'));
      expect(code, contains(r'class _PigeonInternalInstanceManagerApi'));

      // Base Api class
      expect(
        code,
        contains(r'abstract class PigeonInternalProxyApiBaseClass'),
      );

      // Codec and class
      expect(code, contains('class _PigeonInternalProxyApiBaseCodec'));
      expect(
          code, contains(r'class Api extends PigeonInternalProxyApiBaseClass'));

      // Constructors
      expect(
        collapsedCode,
        contains(
          r'Api.name({ super.pigeon_binaryMessenger, super.pigeon_instanceManager, required this.someField, this.doSomethingElse, required Input input, })',
        ),
      );
      expect(
        code,
        contains(
          r'Api.pigeon_detached',
        ),
      );

      // Field
      expect(code, contains('final int someField;'));

      // Dart -> Host method
      expect(code, contains('Future<String> doSomething(Input input)'));

      // Host -> Dart method
      expect(code, contains(r'static void pigeon_setUpMessageHandlers({'));
      expect(
        collapsedCode,
        contains(
          'final String Function( Api pigeon_instance, Input input, )? doSomethingElse;',
        ),
      );

      // Copy method
      expect(code, contains(r'Api pigeon_copy('));
    });

    test('InstanceManagerApi', () {
      final Root root = Root(apis: <Api>[
        AstProxyApi(
          name: 'Api',
          constructors: <Constructor>[],
          fields: <ApiField>[],
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

      expect(code, contains(r'class _PigeonInternalInstanceManagerApi'));

      expect(
        code,
        contains(
          'Future<void> removeStrongReference(int identifier)',
        ),
      );
      expect(
        code,
        contains(
          'dev.flutter.pigeon.$DEFAULT_PACKAGE_NAME.PigeonInternalInstanceManagerApi.removeStrongReference',
        ),
      );
      expect(
        collapsedCode,
        contains(
          '(instanceManager ?? PigeonInternalInstanceManager.instance) .remove(arg_identifier!);',
        ),
      );

      expect(code, contains('Future<void> clear()'));
      expect(
        code,
        contains(
          'dev.flutter.pigeon.$DEFAULT_PACKAGE_NAME.PigeonInternalInstanceManagerApi.clear',
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
              baseName: 'Api2',
              isNullable: false,
              associatedProxyApi: api2,
            ),
          ),
          api2,
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
            r'Api.pigeon_detached({ super.pigeon_binaryMessenger, super.pigeon_instanceManager, }) : super.pigeon_detached();',
          ),
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
                baseName: 'Api2',
                isNullable: false,
                associatedProxyApi: api2,
              )
            },
          ),
          api2,
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
          code,
          contains(
            r'class Api extends PigeonInternalProxyApiBaseClass implements Api2',
          ),
        );
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
                baseName: 'Api2',
                isNullable: false,
                associatedProxyApi: api2,
              ),
              TypeDeclaration(
                baseName: 'Api3',
                isNullable: false,
                associatedProxyApi: api2,
              ),
            },
          ),
          api2,
          api3,
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
          code,
          contains(
            r'class Api extends PigeonInternalProxyApiBaseClass implements Api2, Api3',
          ),
        );
      });

      test('implements inherits flutter methods', () {
        final AstProxyApi api2 = AstProxyApi(
          name: 'Api2',
          constructors: <Constructor>[],
          fields: <ApiField>[],
          methods: <Method>[
            Method(
              name: 'aFlutterMethod',
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[],
              location: ApiLocation.flutter,
            ),
            Method(
              name: 'aNullableFlutterMethod',
              returnType: const TypeDeclaration.voidDeclaration(),
              parameters: <Parameter>[],
              location: ApiLocation.flutter,
              isRequired: false,
            ),
          ],
        );
        final Root root = Root(apis: <Api>[
          AstProxyApi(
            name: 'Api',
            constructors: <Constructor>[],
            fields: <ApiField>[],
            methods: <Method>[],
            interfaces: <TypeDeclaration>{
              TypeDeclaration(
                baseName: 'Api2',
                isNullable: false,
                associatedProxyApi: api2,
              )
            },
          ),
          api2,
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
        expect(
          code,
          contains(
            r'class Api extends PigeonInternalProxyApiBaseClass implements Api2',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'Api.pigeon_detached({ super.pigeon_binaryMessenger, '
            r'super.pigeon_instanceManager, '
            r'required this.aFlutterMethod, '
            r'this.aNullableFlutterMethod, })',
          ),
        );
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
            r'Api({ super.pigeon_binaryMessenger, '
            r'super.pigeon_instanceManager, })',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r"const String pigeonVar_channelName = 'dev.flutter.pigeon.test_package.Api.pigeon_defaultConstructor';",
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'pigeonVar_channel .send(<Object?>[pigeonVar_instanceIdentifier])',
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
            r'Api.name({ super.pigeon_binaryMessenger, '
            r'super.pigeon_instanceManager, '
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
            r'pigeonVar_channel.send(<Object?>[ '
            r'pigeonVar_instanceIdentifier, '
            r'validType, enumType, proxyApiType, '
            r'nullableValidType, nullableEnumType, nullableProxyApiType ])',
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
            r'Api.name({ super.pigeon_binaryMessenger, '
            r'super.pigeon_instanceManager, '
            r'required this.validType, '
            r'required this.enumType, '
            r'required this.proxyApiType, '
            r'this.nullableValidType, '
            r'this.nullableEnumType, '
            r'this.nullableProxyApiType, })',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'pigeonVar_channel.send(<Object?>[ '
            r'pigeonVar_instanceIdentifier, '
            r'validType, enumType, proxyApiType, '
            r'nullableValidType, nullableEnumType, nullableProxyApiType ])',
          ),
        );
        expect(
          code,
          contains(r'final int validType;'),
        );
        expect(
          code,
          contains(r'final AnEnum enumType;'),
        );
        expect(
          code,
          contains(r'final Api2 proxyApiType;'),
        );
        expect(
          code,
          contains(r'final int? nullableValidType;'),
        );
        expect(
          code,
          contains(r'final AnEnum? nullableEnumType;'),
        );
        expect(
          code,
          contains(r'final Api2? nullableProxyApiType;'),
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
        const DartGenerator generator = DartGenerator();
        generator.generate(
          const DartOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains('class Api'));
        expect(code, contains(r'late final Api2 aField = pigeonVar_aField();'));
        expect(code, contains(r'Api2 pigeonVar_aField()'));
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
        const DartGenerator generator = DartGenerator();
        generator.generate(
          const DartOptions(),
          root,
          sink,
          dartPackageName: DEFAULT_PACKAGE_NAME,
        );
        final String code = sink.toString();
        expect(code, contains('class Api'));
        expect(
            code, contains(r'static final Api2 aField = pigeonVar_aField();'));
        expect(code, contains(r'static Api2 pigeonVar_aField()'));
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
            r'Future<void> doSomething( int validType, AnEnum enumType, '
            r'Api2 proxyApiType, int? nullableValidType, '
            r'AnEnum? nullableEnumType, Api2? nullableProxyApiType, )',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'await pigeonVar_channel.send(<Object?>[ this, validType, '
            r'enumType, proxyApiType, nullableValidType, '
            r'nullableEnumType, nullableProxyApiType ])',
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
            r'static Future<void> doSomething({ BinaryMessenger? pigeon_binaryMessenger, '
            r'PigeonInternalInstanceManager? pigeon_instanceManager, })',
          ),
        );
        expect(
          collapsedCode,
          contains(r'await pigeonVar_channel.send(null)'),
        );
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
                  isRequired: false,
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
              ])
        ], classes: <Class>[], enums: <Enum>[
          anEnum
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
        final String collapsedCode = _collapseNewlineAndIndentation(code);
        expect(code, contains('class Api'));
        expect(
          collapsedCode,
          contains(
            r'final void Function( Api pigeon_instance, int validType, '
            r'AnEnum enumType, Api2 proxyApiType, int? nullableValidType, '
            r'AnEnum? nullableEnumType, Api2? nullableProxyApiType, )? '
            r'doSomething;',
          ),
        );
        expect(
          collapsedCode,
          contains(
              r'void Function( Api pigeon_instance, int validType, AnEnum enumType, '
              r'Api2 proxyApiType, int? nullableValidType, '
              r'AnEnum? nullableEnumType, Api2? nullableProxyApiType, )? '
              r'doSomething'),
        );
        expect(
          code,
          contains(r'final Api? arg_pigeon_instance = (args[0] as Api?);'),
        );
        expect(
          code,
          contains(r'final int? arg_validType = (args[1] as int?);'),
        );
        expect(
          code,
          contains(
            r'final AnEnum? arg_enumType = (args[2] as AnEnum?);',
          ),
        );
        expect(
          code,
          contains(r'final Api2? arg_proxyApiType = (args[3] as Api2?);'),
        );
        expect(
          code,
          contains(r'final int? arg_nullableValidType = (args[4] as int?);'),
        );
        expect(
          code,
          contains(
            r'final AnEnum? arg_nullableEnumType = (args[5] as AnEnum?);',
          ),
        );
        expect(
          collapsedCode,
          contains(
            r'(doSomething ?? arg_pigeon_instance!.doSomething)?.call( arg_pigeon_instance!, '
            r'arg_validType!, arg_enumType!, arg_proxyApiType!, '
            r'arg_nullableValidType, arg_nullableEnumType, '
            r'arg_nullableProxyApiType);',
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
