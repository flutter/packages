// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/kotlin_generator.dart';
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
        const KotlinOptions(),
        root,
        sink,
        dartPackageName: DEFAULT_PACKAGE_NAME,
      );
      final String code = sink.toString();

      // Instance Manager
      expect(code, contains(r'class PigeonInstanceManager'));
      expect(code, contains(r'class PigeonInstanceManagerApi'));

      // Codec and class
      expect(code, contains('class PigeonProxyApiBaseCodec'));
      expect(
        code,
        contains(
          r'abstract class PigeonApiApi(val codec: PigeonProxyApiBaseCodec)',
        ),
      );
    });
  });
}
