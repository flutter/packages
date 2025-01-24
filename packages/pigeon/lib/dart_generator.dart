// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import 'ast.dart';
import 'dart/templates.dart';
import 'functional.dart';
import 'generator.dart';
import 'generator_tools.dart';

/// Documentation comment open symbol.
const String _docCommentPrefix = '///';

/// Name of the variable that contains the message channel suffix for APIs.
const String _suffixVarName = '${varNamePrefix}messageChannelSuffix';

/// Name of the `InstanceManager` variable for a ProxyApi class;
const String _instanceManagerVarName =
    '${classMemberNamePrefix}instanceManager';

/// Name of field used for host API codec.
const String _pigeonChannelCodec = 'pigeonChannelCodec';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_docCommentPrefix);

/// The custom codec used for all pigeon APIs.
const String _pigeonMessageCodec = '_PigeonCodec';

/// Name of field used for host API codec.
const String _pigeonMethodChannelCodec = 'pigeonMethodCodec';

const String _overflowClassName = '_PigeonCodecOverflow';

/// Options that control how Dart code will be generated.
class DartOptions {
  /// Constructor for DartOptions.
  const DartOptions({
    this.copyrightHeader,
    this.sourceOutPath,
    this.testOutPath,
  });

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Path to output generated Dart file.
  final String? sourceOutPath;

  /// Path to output generated Test file for tests.
  final String? testOutPath;

  /// Creates a [DartOptions] from a Map representation where:
  /// `x = DartOptions.fromMap(x.toMap())`.
  static DartOptions fromMap(Map<String, Object> map) {
    final Iterable<dynamic>? copyrightHeader =
        map['copyrightHeader'] as Iterable<dynamic>?;
    return DartOptions(
      copyrightHeader: copyrightHeader?.cast<String>(),
      sourceOutPath: map['sourceOutPath'] as String?,
      testOutPath: map['testOutPath'] as String?,
    );
  }

  /// Converts a [DartOptions] to a Map representation where:
  /// `x = DartOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (sourceOutPath != null) 'sourceOutPath': sourceOutPath!,
      if (testOutPath != null) 'testOutPath': testOutPath!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [DartOptions].
  DartOptions merge(DartOptions options) {
    return DartOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Class that manages all Dart code generation.
class DartGenerator extends StructuredGenerator<DartOptions> {
  /// Instantiates a Dart Generator.
  const DartGenerator();

  @override
  void writeFilePrologue(
    DartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln(
      '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import, no_leading_underscores_for_local_identifiers',
    );
    indent.newln();
  }

  @override
  void writeFileImports(
    DartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln("import 'dart:async';");
    indent.writeln(
      "import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;",
    );
    indent.newln();

    indent.writeln(
        "import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer${root.containsProxyApi ? ', immutable, protected' : ''};");
    indent.writeln("import 'package:flutter/services.dart';");
    if (root.containsProxyApi) {
      indent.writeln(
        "import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;",
      );
    }
  }

  @override
  void writeEnum(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.write('enum ${anEnum.name} ');
    indent.addScoped('{', '}', () {
      for (final EnumMember member in anEnum.members) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.writeln('${member.name},');
      }
    });
  }

  @override
  void writeDataClass(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, classDefinition.documentationComments, _docCommentSpec);
    final String sealed = classDefinition.isSealed ? 'sealed ' : '';
    final String implements = classDefinition.superClassName != null
        ? 'extends ${classDefinition.superClassName} '
        : '';

    indent.write('${sealed}class ${classDefinition.name} $implements');
    indent.addScoped('{', '}', () {
      if (classDefinition.fields.isEmpty) {
        return;
      }
      _writeConstructor(indent, classDefinition);
      indent.newln();
      for (final NamedType field
          in getFieldsInSerializationOrder(classDefinition)) {
        addDocumentationComments(
            indent, field.documentationComments, _docCommentSpec);

        final String datatype = _addGenericTypesNullable(field.type);
        indent.writeln('$datatype ${field.name};');
        indent.newln();
      }
      writeClassEncode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
      indent.newln();
      writeClassDecode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
    });
  }

  void _writeConstructor(Indent indent, Class classDefinition) {
    indent.write(classDefinition.name);
    indent.addScoped('({', '});', () {
      for (final NamedType field
          in getFieldsInSerializationOrder(classDefinition)) {
        final String required =
            !field.type.isNullable && field.defaultValue == null
                ? 'required '
                : '';
        final String defaultValueString =
            field.defaultValue == null ? '' : ' = ${field.defaultValue}';
        indent.writeln('${required}this.${field.name}$defaultValueString,');
      }
    });
  }

  @override
  void writeClassEncode(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.write('Object encode() ');
    indent.addScoped('{', '}', () {
      indent.write(
        'return <Object?>',
      );
      indent.addScoped('[', '];', () {
        for (final NamedType field
            in getFieldsInSerializationOrder(classDefinition)) {
          indent.writeln('${field.name},');
        }
      });
    });
  }

  @override
  void writeClassDecode(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    void writeValueDecode(NamedType field, int index) {
      final String resultAt = 'result[$index]';
      final String castCallPrefix = field.type.isNullable ? '?' : '!';
      final String genericType = _makeGenericTypeArguments(field.type);
      final String castCall = _makeGenericCastCall(field.type);
      final String nullableTag = field.type.isNullable ? '?' : '';
      if (field.type.typeArguments.isNotEmpty) {
        indent.add(
          '($resultAt as $genericType?)$castCallPrefix$castCall',
        );
      } else {
        final String castCallForcePrefix = field.type.isNullable ? '' : '!';
        final String castString = field.type.baseName == 'Object'
            ? ''
            : ' as $genericType$nullableTag';

        indent.add(
          '$resultAt$castCallForcePrefix$castString',
        );
      }
    }

    indent.write(
      'static ${classDefinition.name} decode(Object result) ',
    );
    indent.addScoped('{', '}', () {
      indent.writeln('result as List<Object?>;');
      indent.write('return ${classDefinition.name}');
      indent.addScoped('(', ');', () {
        enumerate(getFieldsInSerializationOrder(classDefinition),
            (int index, final NamedType field) {
          indent.write('${field.name}: ');
          writeValueDecode(field, index);
          indent.addln(',');
        });
      });
    });
  }

  @override
  void writeGeneralCodec(
    DartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    void writeEncodeLogic(
        EnumeratedType customType, int nonSerializedClassCount) {
      indent.writeScoped('else if (value is ${customType.name}) {', '}', () {
        if (customType.offset(nonSerializedClassCount) < maximumCodecFieldKey) {
          indent.writeln(
              'buffer.putUint8(${customType.offset(nonSerializedClassCount)});');
          if (customType.type == CustomTypes.customClass) {
            indent.writeln('writeValue(buffer, value.encode());');
          } else if (customType.type == CustomTypes.customEnum) {
            indent.writeln('writeValue(buffer, value.index);');
          }
        } else {
          final String encodeString = customType.type == CustomTypes.customClass
              ? '.encode()'
              : '.index';
          indent.writeln(
              'final $_overflowClassName wrap = $_overflowClassName(type: ${customType.offset(nonSerializedClassCount) - maximumCodecFieldKey}, wrapped: value$encodeString);');
          indent.writeln('buffer.putUint8($maximumCodecFieldKey);');
          indent.writeln('writeValue(buffer, wrap.encode());');
        }
      }, addTrailingNewline: false);
    }

    void writeDecodeLogic(
        EnumeratedType customType, int nonSerializedClassCount) {
      indent.writeln('case ${customType.offset(nonSerializedClassCount)}: ');
      indent.nest(1, () {
        if (customType.type == CustomTypes.customClass) {
          if (customType.offset(nonSerializedClassCount) ==
              maximumCodecFieldKey) {
            indent.writeln(
                'final ${customType.name} wrapper = ${customType.name}.decode(readValue(buffer)!);');
            indent.writeln('return wrapper.unwrap();');
          } else {
            indent.writeln(
                'return ${customType.name}.decode(readValue(buffer)!);');
          }
        } else if (customType.type == CustomTypes.customEnum) {
          indent.writeln('final int? value = readValue(buffer) as int?;');
          indent.writeln(
              'return value == null ? null : ${customType.name}.values[value];');
        }
      });
    }

    final EnumeratedType overflowClass = EnumeratedType(
        _overflowClassName, maximumCodecFieldKey, CustomTypes.customClass);

    indent.newln();
    final List<EnumeratedType> enumeratedTypes =
        getEnumeratedTypes(root, excludeSealedClasses: true).toList();
    if (root.requiresOverflowClass) {
      _writeCodecOverflowUtilities(indent, enumeratedTypes);
    }
    indent.newln();
    indent.write('class $_pigeonMessageCodec extends StandardMessageCodec');
    indent.addScoped(' {', '}', () {
      indent.writeln('const $_pigeonMessageCodec();');
      indent.writeln('@override');
      indent.write('void writeValue(WriteBuffer buffer, Object? value) ');
      indent.addScoped('{', '}', () {
        indent.writeScoped('if (value is int) {', '}', () {
          indent.writeln('buffer.putUint8(4);');
          indent.writeln('buffer.putInt64(value);');
        }, addTrailingNewline: false);
        int nonSerializedClassCount = 0;
        enumerate(enumeratedTypes,
            (int index, final EnumeratedType customType) {
          if (customType.associatedClass?.isSealed ?? false) {
            nonSerializedClassCount += 1;
            return;
          }
          writeEncodeLogic(customType, nonSerializedClassCount);
        });
        indent.addScoped(' else {', '}', () {
          indent.writeln('super.writeValue(buffer, value);');
        });
      });
      indent.newln();
      indent.writeln('@override');
      indent.write('Object? readValueOfType(int type, ReadBuffer buffer) ');
      indent.addScoped('{', '}', () {
        indent.write('switch (type) ');
        indent.addScoped('{', '}', () {
          int nonSerializedClassCount = 0;
          for (final EnumeratedType customType in enumeratedTypes) {
            if (customType.associatedClass?.isSealed ?? false) {
              nonSerializedClassCount++;
            } else if (customType.offset(nonSerializedClassCount) <
                maximumCodecFieldKey) {
              writeDecodeLogic(customType, nonSerializedClassCount);
            }
          }
          if (root.requiresOverflowClass) {
            writeDecodeLogic(overflowClass, 0);
          }
          indent.writeln('default:');
          indent.nest(1, () {
            indent.writeln('return super.readValueOfType(type, buffer);');
          });
        });
      });
    });
    if (root.containsEventChannel) {
      indent.newln();
      indent.writeln(
          'const StandardMethodCodec $_pigeonMethodChannelCodec = StandardMethodCodec($_pigeonMessageCodec());');
    }
  }

  /// Writes the code for host [Api], [api].
  /// Example:
  /// class FooCodec extends StandardMessageCodec {...}
  ///
  /// abstract class Foo {
  ///   static const MessageCodec<Object?> codec = FooCodec();
  ///   int add(int x, int y);
  ///   static void setUp(Foo api, {BinaryMessenger? binaryMessenger}) {...}
  /// }
  @override
  void writeFlutterApi(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    String Function(Method)? channelNameFunc,
    bool isMockHandler = false,
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, api.documentationComments, _docCommentSpec);

    indent.write('abstract class ${api.name} ');
    indent.addScoped('{', '}', () {
      if (isMockHandler) {
        indent.writeln(
            'static TestDefaultBinaryMessengerBinding? get _testBinaryMessengerBinding => TestDefaultBinaryMessengerBinding.instance;');
      }
      indent.writeln(
          'static const MessageCodec<Object?> $_pigeonChannelCodec = $_pigeonMessageCodec();');
      indent.newln();
      for (final Method func in api.methods) {
        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);

        final bool isAsync = func.isAsynchronous;
        final String returnType = isAsync
            ? 'Future<${_addGenericTypesNullable(func.returnType)}>'
            : _addGenericTypesNullable(func.returnType);
        final String argSignature =
            _getMethodParameterSignature(func.parameters);
        indent.writeln('$returnType ${func.name}($argSignature);');
        indent.newln();
      }
      indent.write(
          "static void setUp(${api.name}? api, {BinaryMessenger? binaryMessenger, String messageChannelSuffix = '',}) ");
      indent.addScoped('{', '}', () {
        indent.writeln(
            r"messageChannelSuffix = messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';");

        for (final Method func in api.methods) {
          _writeFlutterMethodMessageHandler(
            indent,
            name: func.name,
            parameters: func.parameters,
            returnType: func.returnType,
            addSuffixVariable: true,
            channelName: channelNameFunc == null
                ? makeChannelName(api, func, dartPackageName)
                : channelNameFunc(func),
            isMockHandler: isMockHandler,
            isAsynchronous: func.isAsynchronous,
          );
        }
      });
    });
  }

  /// Writes the code for host [Api], [api].
  /// Example:
  /// class FooCodec extends StandardMessageCodec {...}
  ///
  /// class Foo {
  ///   Foo(BinaryMessenger? binaryMessenger) {}
  ///   static const MessageCodec<Object?> codec = FooCodec();
  ///   Future<int> add(int x, int y) async {...}
  /// }
  ///
  /// Messages will be sent and received in a list.
  ///
  /// If the message received was successful,
  /// the result will be contained at the 0'th index.
  ///
  /// If the message was a failure, the list will contain 3 items:
  /// a code, a message, and details in that order.
  @override
  void writeHostApi(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    indent.newln();
    bool first = true;
    addDocumentationComments(
        indent, api.documentationComments, _docCommentSpec);
    indent.write('class ${api.name} ');
    indent.addScoped('{', '}', () {
      indent.format('''
/// Constructor for [${api.name}].  The [binaryMessenger] named argument is
/// available for dependency injection.  If it is left null, the default
/// BinaryMessenger will be used which routes to the host platform.
${api.name}({BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
    : ${varNamePrefix}binaryMessenger = binaryMessenger,
      ${varNamePrefix}messageChannelSuffix = messageChannelSuffix.isNotEmpty ? '.\$messageChannelSuffix' : '';
final BinaryMessenger? ${varNamePrefix}binaryMessenger;
''');

      indent.writeln(
          'static const MessageCodec<Object?> $_pigeonChannelCodec = $_pigeonMessageCodec();');
      indent.newln();
      indent.writeln('final String $_suffixVarName;');
      indent.newln();
      for (final Method func in api.methods) {
        if (!first) {
          indent.newln();
        } else {
          first = false;
        }
        _writeHostMethod(
          indent,
          name: func.name,
          parameters: func.parameters,
          returnType: func.returnType,
          documentationComments: func.documentationComments,
          channelName: makeChannelName(api, func, dartPackageName),
          addSuffixVariable: true,
        );
      }
    });
  }

  @override
  void writeEventChannelApi(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    AstEventChannelApi api, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, api.documentationComments, _docCommentSpec);
    for (final Method func in api.methods) {
      indent.format('''
      Stream<${func.returnType.baseName}> ${func.name}(${_getMethodParameterSignature(func.parameters, addTrailingComma: true)} {String instanceName = ''}) {
        if (instanceName.isNotEmpty) {
          instanceName = '.\$instanceName';
        }
        final EventChannel ${func.name}Channel =
            EventChannel('${makeChannelName(api, func, dartPackageName)}\$instanceName', $_pigeonMethodChannelCodec);
        return ${func.name}Channel.receiveBroadcastStream().map((dynamic event) {
          return event as ${func.returnType.baseName};
        });
      }
    ''');
    }
  }

  @override
  void writeInstanceManager(
    DartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.format(proxyApiBaseClass);

    indent.format(
      instanceManagerTemplate(
        allProxyApiNames: root.apis
            .whereType<AstProxyApi>()
            .map((AstProxyApi api) => api.name),
      ),
    );
  }

  @override
  void writeInstanceManagerApi(
    DartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final cb.Parameter binaryMessengerParameter = cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = 'binaryMessenger'
        ..type = cb.refer('BinaryMessenger?')
        ..named = true,
    );

    final cb.Field binaryMessengerField = cb.Field(
      (cb.FieldBuilder builder) => builder
        ..name = '${varNamePrefix}binaryMessenger'
        ..type = cb.refer('BinaryMessenger?')
        ..modifier = cb.FieldModifier.final$,
    );

    final cb.Class instanceManagerApi = cb.Class(
      (cb.ClassBuilder builder) => builder
        ..name = dartInstanceManagerApiClassName
        ..docs.add(
          '/// Generated API for managing the Dart and native `$dartInstanceManagerClassName`s.',
        )
        ..constructors.add(
          cb.Constructor(
            (cb.ConstructorBuilder builder) {
              builder
                ..docs.add(
                    '/// Constructor for [$dartInstanceManagerApiClassName].')
                ..optionalParameters.add(binaryMessengerParameter)
                ..initializers.add(
                  cb.Code(
                    '${binaryMessengerField.name} = ${binaryMessengerParameter.name}',
                  ),
                );
            },
          ),
        )
        ..fields.addAll(
          <cb.Field>[
            binaryMessengerField,
            cb.Field(
              (cb.FieldBuilder builder) {
                builder
                  ..name = _pigeonChannelCodec
                  ..type = cb.refer('MessageCodec<Object?>')
                  ..static = true
                  ..modifier = cb.FieldModifier.constant
                  ..assignment = const cb.Code('$_pigeonMessageCodec()');
              },
            )
          ],
        )
        ..methods.add(
          cb.Method(
            (cb.MethodBuilder builder) {
              builder
                ..name = 'setUpMessageHandlers'
                ..static = true
                ..returns = cb.refer('void')
                ..optionalParameters.addAll(<cb.Parameter>[
                  cb.Parameter(
                    (cb.ParameterBuilder builder) => builder
                      ..name = '${classMemberNamePrefix}clearHandlers'
                      ..type = cb.refer('bool')
                      ..named = true
                      ..defaultTo = const cb.Code('false'),
                  ),
                  binaryMessengerParameter,
                  cb.Parameter(
                    (cb.ParameterBuilder builder) => builder
                      ..name = 'instanceManager'
                      ..named = true
                      ..type = cb.refer('$dartInstanceManagerClassName?'),
                  ),
                ])
                ..body = cb.Block.of(
                  cb.Block(
                    (cb.BlockBuilder builder) {
                      final StringBuffer messageHandlerSink = StringBuffer();
                      _writeFlutterMethodMessageHandler(
                        Indent(messageHandlerSink),
                        name: 'removeStrongReferenceName',
                        parameters: <Parameter>[
                          Parameter(
                            name: 'identifier',
                            type: const TypeDeclaration(
                              baseName: 'int',
                              isNullable: false,
                            ),
                          )
                        ],
                        returnType: const TypeDeclaration.voidDeclaration(),
                        channelName: makeRemoveStrongReferenceChannelName(
                          dartPackageName,
                        ),
                        isMockHandler: false,
                        isAsynchronous: false,
                        nullHandlerExpression:
                            '${classMemberNamePrefix}clearHandlers',
                        onCreateApiCall: (
                          String methodName,
                          Iterable<Parameter> parameters,
                          Iterable<String> safeArgumentNames,
                        ) {
                          return '(instanceManager ?? $dartInstanceManagerClassName.instance).remove(${safeArgumentNames.single})';
                        },
                      );
                      builder.statements.add(
                        cb.Code(messageHandlerSink.toString()),
                      );
                    },
                  ).statements,
                );
            },
          ),
        )
        ..methods.addAll(
          <cb.Method>[
            cb.Method(
              (cb.MethodBuilder builder) {
                builder
                  ..name = 'removeStrongReference'
                  ..returns = cb.refer('Future<void>')
                  ..modifier = cb.MethodModifier.async
                  ..requiredParameters.add(
                    cb.Parameter(
                      (cb.ParameterBuilder builder) => builder
                        ..name = 'identifier'
                        ..type = cb.refer('int'),
                    ),
                  )
                  ..body = cb.Block(
                    (cb.BlockBuilder builder) {
                      final StringBuffer messageCallSink = StringBuffer();
                      _writeHostMethodMessageCall(
                        Indent(messageCallSink),
                        addSuffixVariable: false,
                        channelName: makeRemoveStrongReferenceChannelName(
                            dartPackageName),
                        parameters: <Parameter>[
                          Parameter(
                            name: 'identifier',
                            type: const TypeDeclaration(
                              baseName: 'int',
                              isNullable: false,
                            ),
                          ),
                        ],
                        returnType: const TypeDeclaration.voidDeclaration(),
                      );
                      builder.statements.addAll(<cb.Code>[
                        cb.Code(messageCallSink.toString()),
                      ]);
                    },
                  );
              },
            ),
            cb.Method(
              (cb.MethodBuilder builder) {
                builder
                  ..name = 'clear'
                  ..returns = cb.refer('Future<void>')
                  ..modifier = cb.MethodModifier.async
                  ..docs.addAll(<String>[
                    '/// Clear the native `$dartInstanceManagerClassName`.',
                    '///',
                    '/// This is typically called after a hot restart.',
                  ])
                  ..body = cb.Block(
                    (cb.BlockBuilder builder) {
                      final StringBuffer messageCallSink = StringBuffer();
                      _writeHostMethodMessageCall(
                        Indent(messageCallSink),
                        addSuffixVariable: false,
                        channelName: makeClearChannelName(dartPackageName),
                        parameters: <Parameter>[],
                        returnType: const TypeDeclaration.voidDeclaration(),
                      );
                      builder.statements.addAll(<cb.Code>[
                        cb.Code(messageCallSink.toString()),
                      ]);
                    },
                  );
              },
            ),
          ],
        ),
    );

    final cb.DartEmitter emitter = cb.DartEmitter(useNullSafetySyntax: true);
    indent.format(
      DartFormatter(languageVersion: Version(3, 6, 0))
          .format('${instanceManagerApi.accept(emitter)}'),
    );
  }

  @override
  void writeProxyApiBaseCodec(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
  ) {
    indent.format(proxyApiBaseCodec);
  }

  @override
  void writeProxyApi(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    AstProxyApi api, {
    required String dartPackageName,
  }) {
    const String codecName = '_${classNamePrefix}ProxyApiBaseCodec';

    // Each API has a private codec instance used by every host method,
    // constructor, or non-static field.
    final String codecInstanceName = '_${varNamePrefix}codec${api.name}';

    // AST class used by code_builder to generate the code.
    final cb.Class proxyApi = cb.Class(
      (cb.ClassBuilder builder) => builder
        ..name = api.name
        ..extend = api.superClass != null
            ? cb.refer(api.superClass!.baseName)
            : cb.refer(proxyApiBaseClassName)
        ..implements.addAll(
          api.interfaces.map(
            (TypeDeclaration type) => cb.refer(type.baseName),
          ),
        )
        ..docs.addAll(
          asDocumentationComments(api.documentationComments, _docCommentSpec),
        )
        ..constructors.addAll(_proxyApiConstructors(
          api.constructors,
          apiName: api.name,
          dartPackageName: dartPackageName,
          codecName: codecName,
          codecInstanceName: codecInstanceName,
          superClassApi: api.superClass?.associatedProxyApi,
          unattachedFields: api.unattachedFields,
          flutterMethodsFromSuperClasses: api.flutterMethodsFromSuperClasses(),
          flutterMethodsFromInterfaces: api.flutterMethodsFromInterfaces(),
          declaredFlutterMethods: api.flutterMethods,
        ))
        ..constructors.add(
          _proxyApiDetachedConstructor(
            apiName: api.name,
            superClassApi: api.superClass?.associatedProxyApi,
            unattachedFields: api.unattachedFields,
            flutterMethodsFromSuperClasses:
                api.flutterMethodsFromSuperClasses(),
            flutterMethodsFromInterfaces: api.flutterMethodsFromInterfaces(),
            declaredFlutterMethods: api.flutterMethods,
          ),
        )
        ..fields.addAll(<cb.Field>[
          if (api.constructors.isNotEmpty ||
              api.attachedFields.any((ApiField field) => !field.isStatic) ||
              api.hostMethods.isNotEmpty)
            _proxyApiCodecInstanceField(
              codecInstanceName: codecInstanceName,
              codecName: codecName,
            ),
        ])
        ..fields.addAll(_proxyApiUnattachedFields(api.unattachedFields))
        ..fields.addAll(_proxyApiFlutterMethodFields(
          api.flutterMethods,
          apiName: api.name,
        ))
        ..fields.addAll(_proxyApiInterfaceApiFields(api.apisOfInterfaces()))
        ..fields.addAll(_proxyApiAttachedFields(api.attachedFields))
        ..methods.add(
          _proxyApiSetUpMessageHandlerMethod(
            flutterMethods: api.flutterMethods,
            apiName: api.name,
            dartPackageName: dartPackageName,
            codecName: codecName,
            unattachedFields: api.unattachedFields,
            hasCallbackConstructor: api.hasCallbackConstructor(),
          ),
        )
        ..methods.addAll(
          _proxyApiAttachedFieldMethods(
            api.attachedFields,
            apiName: api.name,
            dartPackageName: dartPackageName,
            codecInstanceName: codecInstanceName,
            codecName: codecName,
          ),
        )
        ..methods.addAll(_proxyApiHostMethods(
          api.hostMethods,
          apiName: api.name,
          dartPackageName: dartPackageName,
          codecInstanceName: codecInstanceName,
          codecName: codecName,
        ))
        ..methods.add(
          _proxyApiCopyMethod(
            apiName: api.name,
            unattachedFields: api.unattachedFields,
            declaredAndInheritedFlutterMethods: api
                .flutterMethodsFromSuperClasses()
                .followedBy(api.flutterMethodsFromInterfaces())
                .followedBy(api.flutterMethods),
          ),
        ),
    );

    final cb.DartEmitter emitter = cb.DartEmitter(useNullSafetySyntax: true);
    indent.format(DartFormatter(languageVersion: Version(3, 6, 0))
        .format('${proxyApi.accept(emitter)}'));
  }

  /// Generates Dart source code for test support libraries based on the given AST
  /// represented by [root], outputting the code to [sink]. [sourceOutPath] is the
  /// path of the generated Dart code to be tested. [testOutPath] is where the
  /// test code will be generated.
  void generateTest(
    DartOptions generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
    required String dartOutputPackageName,
  }) {
    final Indent indent = Indent(sink);
    final String sourceOutPath = generatorOptions.sourceOutPath ?? '';
    final String testOutPath = generatorOptions.testOutPath ?? '';
    _writeTestPrologue(generatorOptions, root, indent);
    _writeTestImports(generatorOptions, root, indent);
    final String relativeDartPath =
        path.Context(style: path.Style.posix).relative(
      _posixify(sourceOutPath),
      from: _posixify(path.dirname(testOutPath)),
    );
    if (!relativeDartPath.contains('/lib/')) {
      // If we can't figure out the package name or the relative path doesn't
      // include a 'lib' directory, try relative path import which only works in
      // certain (older) versions of Dart.
      // TODO(gaaclarke): We should add a command-line parameter to override this import.
      indent.writeln(
          "import '${_escapeForDartSingleQuotedString(relativeDartPath)}';");
    } else {
      final String path =
          relativeDartPath.replaceFirst(RegExp(r'^.*/lib/'), '');
      indent.writeln("import 'package:$dartOutputPackageName/$path';");
    }
    writeGeneralCodec(generatorOptions, root, indent,
        dartPackageName: dartPackageName);
    for (final AstHostApi api in root.apis.whereType<AstHostApi>()) {
      if (api.dartHostTestHandler != null) {
        final AstFlutterApi mockApi = AstFlutterApi(
          name: api.dartHostTestHandler!,
          methods: api.methods,
          documentationComments: api.documentationComments,
        );
        writeFlutterApi(
          generatorOptions,
          root,
          indent,
          mockApi,
          channelNameFunc: (Method func) =>
              makeChannelName(api, func, dartPackageName),
          isMockHandler: true,
          dartPackageName: dartPackageName,
        );
      }
    }
  }

  /// Writes file header to sink.
  void _writeTestPrologue(DartOptions opt, Root root, Indent indent) {
    if (opt.copyrightHeader != null) {
      addLines(indent, opt.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln(
      '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, unnecessary_import, no_leading_underscores_for_local_identifiers',
    );
    indent.writeln('// ignore_for_file: avoid_relative_lib_imports');
  }

  /// Writes file imports to sink.
  void _writeTestImports(DartOptions opt, Root root, Indent indent) {
    indent.writeln("import 'dart:async';");
    indent.writeln(
      "import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;",
    );
    indent.writeln(
        "import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;");
    indent.writeln("import 'package:flutter/services.dart';");
    indent.writeln("import 'package:flutter_test/flutter_test.dart';");
    indent.newln();
  }

  @override
  void writeGeneralUtilities(
    DartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.containsHostApi || root.containsProxyApi) {
      _writeCreateConnectionError(indent);
    }
    if (root.containsFlutterApi ||
        root.containsProxyApi ||
        generatorOptions.testOutPath != null) {
      _writeWrapResponse(generatorOptions, root, indent);
    }
  }

  /// Writes [wrapResponse] method.
  void _writeWrapResponse(DartOptions opt, Root root, Indent indent) {
    indent.newln();
    indent.writeScoped(
        'List<Object?> wrapResponse({Object? result, PlatformException? error, bool empty = false}) {',
        '}', () {
      indent.writeScoped('if (empty) {', '}', () {
        indent.writeln('return <Object?>[];');
      });
      indent.writeScoped('if (error == null) {', '}', () {
        indent.writeln('return <Object?>[result];');
      });
      indent.writeln(
          'return <Object?>[error.code, error.message, error.details];');
    });
  }

  void _writeCreateConnectionError(Indent indent) {
    indent.newln();
    indent.format('''
PlatformException _createConnectionError(String channelName) {
\treturn PlatformException(
\t\tcode: 'channel-error',
\t\tmessage: 'Unable to establish connection on channel: "\$channelName".',
\t);
}''');
  }

  void _writeCodecOverflowUtilities(Indent indent, List<EnumeratedType> types) {
    indent.newln();
    indent.writeln('// ignore: camel_case_types');
    indent.writeScoped('class $_overflowClassName {', '}', () {
      indent.format('''
$_overflowClassName({required this.type, required this.wrapped});

int type;
Object? wrapped;

Object encode() {
  return <Object?>[type, wrapped];
}

static $_overflowClassName decode(Object result) {
  result as List<Object?>;
  return $_overflowClassName(
    type: result[0]! as int,
    wrapped: result[1],
  );
}
''');
      indent.writeScoped('Object? unwrap() {', '}', () {
        indent.format('''
if (wrapped == null) {
  return null;
}
''');
        indent.writeScoped('switch (type) {', '}', () {
          int nonSerializedClassCount = 0;
          for (int i = totalCustomCodecKeysAllowed; i < types.length; i++) {
            if (types[i].associatedClass?.isSealed ?? false) {
              nonSerializedClassCount++;
            } else {
              indent.writeScoped(
                  'case ${i - nonSerializedClassCount - totalCustomCodecKeysAllowed}:',
                  '', () {
                if (types[i].type == CustomTypes.customClass) {
                  indent.writeln('return ${types[i].name}.decode(wrapped!);');
                } else if (types[i].type == CustomTypes.customEnum) {
                  indent.writeln(
                      'return ${types[i].name}.values[wrapped! as int];');
                }
              });
            }
          }
        });
        indent.writeln('return null;');
      });
    });
  }

  void _writeHostMethod(
    Indent indent, {
    required String name,
    required Iterable<Parameter> parameters,
    required TypeDeclaration returnType,
    required List<String> documentationComments,
    required String channelName,
    required bool addSuffixVariable,
  }) {
    addDocumentationComments(indent, documentationComments, _docCommentSpec);
    final String argSignature = _getMethodParameterSignature(parameters);
    indent.write(
      'Future<${_addGenericTypesNullable(returnType)}> $name($argSignature) async ',
    );
    indent.addScoped('{', '}', () {
      _writeHostMethodMessageCall(
        indent,
        channelName: channelName,
        parameters: parameters,
        returnType: returnType,
        addSuffixVariable: addSuffixVariable,
      );
    });
  }

  void _writeHostMethodMessageCall(
    Indent indent, {
    required String channelName,
    required Iterable<Parameter> parameters,
    required TypeDeclaration returnType,
    required bool addSuffixVariable,
  }) {
    String sendArgument = 'null';
    if (parameters.isNotEmpty) {
      final Iterable<String> argExpressions =
          indexMap(parameters, (int index, NamedType type) {
        final String name = _getParameterName(index, type);
        return name;
      });
      sendArgument = '<Object?>[${argExpressions.join(', ')}]';
    }
    final String channelSuffix = addSuffixVariable ? '\$$_suffixVarName' : '';
    final String constOrFinal = addSuffixVariable ? 'final' : 'const';
    indent.writeln(
        "$constOrFinal String ${varNamePrefix}channelName = '$channelName$channelSuffix';");
    indent.writeScoped(
        'final BasicMessageChannel<Object?> ${varNamePrefix}channel = BasicMessageChannel<Object?>(',
        ');', () {
      indent.writeln('${varNamePrefix}channelName,');
      indent.writeln('$_pigeonChannelCodec,');
      indent.writeln('binaryMessenger: ${varNamePrefix}binaryMessenger,');
    });
    final String returnTypeName = _makeGenericTypeArguments(returnType);
    final String genericCastCall = _makeGenericCastCall(returnType);
    const String accessor = '${varNamePrefix}replyList[0]';
    // Avoid warnings from pointlessly casting to `Object?`.
    final String nullablyTypedAccessor = returnTypeName == 'Object'
        ? accessor
        : '($accessor as $returnTypeName?)';
    final String nullHandler =
        returnType.isNullable ? (genericCastCall.isEmpty ? '' : '?') : '!';
    String returnStatement = 'return';
    if (!returnType.isVoid) {
      returnStatement =
          '$returnStatement $nullablyTypedAccessor$nullHandler$genericCastCall';
    }
    returnStatement = '$returnStatement;';

    indent.format('''
final List<Object?>? ${varNamePrefix}replyList =
\t\tawait ${varNamePrefix}channel.send($sendArgument) as List<Object?>?;
if (${varNamePrefix}replyList == null) {
\tthrow _createConnectionError(${varNamePrefix}channelName);
} else if (${varNamePrefix}replyList.length > 1) {
\tthrow PlatformException(
\t\tcode: ${varNamePrefix}replyList[0]! as String,
\t\tmessage: ${varNamePrefix}replyList[1] as String?,
\t\tdetails: ${varNamePrefix}replyList[2],
\t);''');
    // On iOS we can return nil from functions to accommodate error
    // handling.  Returning a nil value and not returning an error is an
    // exception.
    if (!returnType.isNullable && !returnType.isVoid) {
      indent.format('''
} else if (${varNamePrefix}replyList[0] == null) {
\tthrow PlatformException(
\t\tcode: 'null-error',
\t\tmessage: 'Host platform returned null value for non-null return value.',
\t);''');
    }
    indent.format('''
} else {
\t$returnStatement
}''');
  }

  void _writeFlutterMethodMessageHandler(
    Indent indent, {
    required String name,
    required Iterable<Parameter> parameters,
    required TypeDeclaration returnType,
    required String channelName,
    required bool isMockHandler,
    required bool isAsynchronous,
    bool addSuffixVariable = false,
    String nullHandlerExpression = 'api == null',
    String Function(String methodName, Iterable<Parameter> parameters,
            Iterable<String> safeArgumentNames)
        onCreateApiCall = _createFlutterApiMethodCall,
  }) {
    indent.write('');
    indent.addScoped('{', '}', () {
      indent.writeln(
        'final BasicMessageChannel<Object?> ${varNamePrefix}channel = BasicMessageChannel<Object?>(',
      );
      indent.nest(2, () {
        final String channelSuffix =
            addSuffixVariable ? r'$messageChannelSuffix' : '';
        indent.writeln("'$channelName$channelSuffix', $_pigeonChannelCodec,");
        indent.writeln(
          'binaryMessenger: binaryMessenger);',
        );
      });
      final String messageHandlerSetterWithOpeningParentheses = isMockHandler
          ? '_testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(${varNamePrefix}channel, '
          : '${varNamePrefix}channel.setMessageHandler(';
      indent.write('if ($nullHandlerExpression) ');
      indent.addScoped('{', '}', () {
        indent.writeln('${messageHandlerSetterWithOpeningParentheses}null);');
      }, addTrailingNewline: false);
      indent.add(' else ');
      indent.addScoped('{', '}', () {
        indent.write(
          '$messageHandlerSetterWithOpeningParentheses(Object? message) async ',
        );
        indent.addScoped('{', '});', () {
          final String returnTypeString = _addGenericTypesNullable(returnType);
          final bool isAsync = isAsynchronous;
          const String emptyReturnStatement =
              'return wrapResponse(empty: true);';
          String call;
          if (parameters.isEmpty) {
            call = 'api.$name()';
          } else {
            indent.writeln('assert(message != null,');
            indent.writeln("'Argument for $channelName was null.');");
            const String argsArray = 'args';
            indent.writeln(
                'final List<Object?> $argsArray = (message as List<Object?>?)!;');
            String argNameFunc(int index, NamedType type) =>
                _getSafeArgumentName(index, type);
            enumerate(parameters, (int count, NamedType arg) {
              final String argType = _addGenericTypes(arg.type);
              final String argName = argNameFunc(count, arg);
              final String genericArgType = _makeGenericTypeArguments(arg.type);
              final String castCall = _makeGenericCastCall(arg.type);

              final String leftHandSide = 'final $argType? $argName';

              indent.writeln(
                  '$leftHandSide = ($argsArray[$count] as $genericArgType?)${castCall.isEmpty ? '' : '?$castCall'};');

              if (!arg.type.isNullable) {
                indent.writeln('assert($argName != null,');
                indent.writeln(
                    "    'Argument for $channelName was null, expected non-null $argType.');");
              }
            });
            final Iterable<String> argNames =
                indexMap(parameters, (int index, Parameter field) {
              final String name = _getSafeArgumentName(index, field);
              return '${field.isNamed ? '${field.name}: ' : ''}$name${field.type.isNullable ? '' : '!'}';
            });
            call = onCreateApiCall(name, parameters, argNames);
          }
          indent.writeScoped('try {', '} ', () {
            if (returnType.isVoid) {
              if (isAsync) {
                indent.writeln('await $call;');
              } else {
                indent.writeln('$call;');
              }
              indent.writeln(emptyReturnStatement);
            } else {
              if (isAsync) {
                indent.writeln('final $returnTypeString output = await $call;');
              } else {
                indent.writeln('final $returnTypeString output = $call;');
              }

              const String returnExpression = 'output';
              final String returnStatement = isMockHandler
                  ? 'return <Object?>[$returnExpression];'
                  : 'return wrapResponse(result: $returnExpression);';
              indent.writeln(returnStatement);
            }
          }, addTrailingNewline: false);
          indent.addScoped('on PlatformException catch (e) {', '}', () {
            indent.writeln('return wrapResponse(error: e);');
          }, addTrailingNewline: false);

          indent.writeScoped('catch (e) {', '}', () {
            indent.writeln(
                "return wrapResponse(error: PlatformException(code: 'error', message: e.toString()));");
          });
        });
      });
    });
  }

  static String _createFlutterApiMethodCall(
    String methodName,
    Iterable<Parameter> parameters,
    Iterable<String> safeArgumentNames,
  ) {
    return 'api.$methodName(${safeArgumentNames.join(', ')})';
  }

  /// Converts Constructors from the pigeon AST to a `code_builder` Constructor
  /// for a ProxyApi.
  Iterable<cb.Constructor> _proxyApiConstructors(
    Iterable<Constructor> constructors, {
    required String apiName,
    required String dartPackageName,
    required String codecName,
    required String codecInstanceName,
    required AstProxyApi? superClassApi,
    required Iterable<ApiField> unattachedFields,
    required Iterable<Method> flutterMethodsFromSuperClasses,
    required Iterable<Method> flutterMethodsFromInterfaces,
    required Iterable<Method> declaredFlutterMethods,
  }) sync* {
    final cb.Parameter binaryMessengerParameter = cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = '${classMemberNamePrefix}binaryMessenger'
        ..named = true
        ..toSuper = true,
    );
    final cb.Parameter instanceManagerParameter = cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = _instanceManagerVarName
        ..named = true
        ..toSuper = true,
    );
    for (final Constructor constructor in constructors) {
      yield cb.Constructor(
        (cb.ConstructorBuilder builder) {
          final String channelName = makeChannelNameWithStrings(
            apiName: apiName,
            methodName: constructor.name.isNotEmpty
                ? constructor.name
                : '${classMemberNamePrefix}defaultConstructor',
            dartPackageName: dartPackageName,
          );
          builder
            ..name = constructor.name.isNotEmpty ? constructor.name : null
            ..docs.addAll(asDocumentationComments(
              constructor.documentationComments,
              _docCommentSpec,
            ))
            ..optionalParameters.addAll(
              <cb.Parameter>[
                binaryMessengerParameter,
                instanceManagerParameter,
                for (final ApiField field in unattachedFields)
                  cb.Parameter(
                    (cb.ParameterBuilder builder) => builder
                      ..name = field.name
                      ..named = true
                      ..toThis = true
                      ..required = !field.type.isNullable,
                  ),
                for (final Method method in flutterMethodsFromSuperClasses)
                  cb.Parameter(
                    (cb.ParameterBuilder builder) => builder
                      ..name = method.name
                      ..named = true
                      ..toSuper = true
                      ..required = method.isRequired,
                  ),
                for (final Method method in flutterMethodsFromInterfaces
                    .followedBy(declaredFlutterMethods))
                  cb.Parameter(
                    (cb.ParameterBuilder builder) => builder
                      ..name = method.name
                      ..named = true
                      ..toThis = true
                      ..required = method.isRequired,
                  ),
                ...indexMap(
                  constructor.parameters,
                  (int index, NamedType parameter) => cb.Parameter(
                    (cb.ParameterBuilder builder) => builder
                      ..name = _getParameterName(index, parameter)
                      ..type = _refer(parameter.type)
                      ..named = true
                      ..required = !parameter.type.isNullable,
                  ),
                )
              ],
            )
            ..initializers.addAll(
              <cb.Code>[
                if (superClassApi != null)
                  const cb.Code('super.${classMemberNamePrefix}detached()')
              ],
            )
            ..body = cb.Block(
              (cb.BlockBuilder builder) {
                final StringBuffer messageCallSink = StringBuffer();
                _writeHostMethodMessageCall(
                  Indent(messageCallSink),
                  addSuffixVariable: false,
                  channelName: channelName,
                  parameters: <Parameter>[
                    Parameter(
                      name: '${varNamePrefix}instanceIdentifier',
                      type: const TypeDeclaration(
                        baseName: 'int',
                        isNullable: false,
                      ),
                    ),
                    ...unattachedFields.map(
                      (ApiField field) => Parameter(
                        name: field.name,
                        type: field.type,
                      ),
                    ),
                    ...constructor.parameters,
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                );

                builder.statements.addAll(<cb.Code>[
                  const cb.Code(
                    'final int ${varNamePrefix}instanceIdentifier = $_instanceManagerVarName.addDartCreatedInstance(this);',
                  ),
                  cb.Code('final $codecName $_pigeonChannelCodec =\n'
                      '    $codecInstanceName;'),
                  cb.Code(
                    'final BinaryMessenger? ${varNamePrefix}binaryMessenger = ${binaryMessengerParameter.name};',
                  ),
                  const cb.Code('() async {'),
                  cb.Code(messageCallSink.toString()),
                  const cb.Code('}();'),
                ]);
              },
            );
        },
      );
    }
  }

  /// The detached constructor present for every ProxyApi.
  ///
  /// This constructor doesn't include a host method call to create a new native
  /// class instance. It is mainly used when the native side wants to create a
  /// Dart instance or when the `InstanceManager` wants to create a copy for
  /// automatic garbage collection.
  cb.Constructor _proxyApiDetachedConstructor({
    required String apiName,
    required AstProxyApi? superClassApi,
    required Iterable<ApiField> unattachedFields,
    required Iterable<Method> flutterMethodsFromSuperClasses,
    required Iterable<Method> flutterMethodsFromInterfaces,
    required Iterable<Method> declaredFlutterMethods,
  }) {
    final cb.Parameter binaryMessengerParameter = cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = '${classMemberNamePrefix}binaryMessenger'
        ..named = true
        ..toSuper = true,
    );
    final cb.Parameter instanceManagerParameter = cb.Parameter(
      (cb.ParameterBuilder builder) => builder
        ..name = _instanceManagerVarName
        ..named = true
        ..toSuper = true,
    );
    return cb.Constructor(
      (cb.ConstructorBuilder builder) => builder
        ..name = '${classMemberNamePrefix}detached'
        ..docs.addAll(<String>[
          '/// Constructs [$apiName] without creating the associated native object.',
          '///',
          '/// This should only be used by subclasses created by this library or to',
          '/// create copies for an [$dartInstanceManagerClassName].',
        ])
        ..annotations.add(cb.refer('protected'))
        ..optionalParameters.addAll(<cb.Parameter>[
          binaryMessengerParameter,
          instanceManagerParameter,
          for (final ApiField field in unattachedFields)
            cb.Parameter(
              (cb.ParameterBuilder builder) => builder
                ..name = field.name
                ..named = true
                ..toThis = true
                ..required = !field.type.isNullable,
            ),
          for (final Method method in flutterMethodsFromSuperClasses)
            cb.Parameter(
              (cb.ParameterBuilder builder) => builder
                ..name = method.name
                ..named = true
                ..toSuper = true
                ..required = method.isRequired,
            ),
          for (final Method method in flutterMethodsFromInterfaces
              .followedBy(declaredFlutterMethods))
            cb.Parameter(
              (cb.ParameterBuilder builder) => builder
                ..name = method.name
                ..named = true
                ..toThis = true
                ..required = method.isRequired,
            ),
        ])
        ..initializers.addAll(<cb.Code>[
          if (superClassApi != null)
            const cb.Code('super.${classMemberNamePrefix}detached()'),
        ]),
    );
  }

  /// A private Field of the base codec.
  cb.Field _proxyApiCodecInstanceField({
    required String codecInstanceName,
    required String codecName,
  }) {
    return cb.Field(
      (cb.FieldBuilder builder) => builder
        ..name = codecInstanceName
        ..type = cb.refer(codecName)
        ..late = true
        ..modifier = cb.FieldModifier.final$
        ..assignment = cb.Code('$codecName($_instanceManagerVarName)'),
    );
  }

  /// Converts unattached fields from the pigeon AST to `code_builder`
  /// Fields.
  Iterable<cb.Field> _proxyApiUnattachedFields(
    Iterable<ApiField> fields,
  ) sync* {
    for (final ApiField field in fields) {
      yield cb.Field(
        (cb.FieldBuilder builder) => builder
          ..name = field.name
          ..type = cb.refer(_addGenericTypesNullable(field.type))
          ..modifier = cb.FieldModifier.final$
          ..docs.addAll(asDocumentationComments(
            field.documentationComments,
            _docCommentSpec,
          )),
      );
    }
  }

  /// Converts Flutter methods from the pigeon AST to `code_builder` Fields.
  ///
  /// Flutter methods of a ProxyApi are set as an anonymous function of a class
  /// instance, so this converts methods to a `Function` type field instance.
  Iterable<cb.Field> _proxyApiFlutterMethodFields(
    Iterable<Method> methods, {
    required String apiName,
  }) sync* {
    for (final Method method in methods) {
      yield cb.Field(
        (cb.FieldBuilder builder) => builder
          ..name = method.name
          ..modifier = cb.FieldModifier.final$
          ..docs.addAll(asDocumentationComments(
            <String>[
              ...method.documentationComments,
              ...<String>[
                if (method.documentationComments.isEmpty) 'Callback method.',
                '',
                'For the associated Native object to be automatically garbage collected,',
                "it is required that the implementation of this `Function` doesn't have a",
                'strong reference to the encapsulating class instance. When this `Function`',
                'references a non-local variable, it is strongly recommended to access it',
                'with a `WeakReference`:',
                '',
                '```dart',
                'final WeakReference weakMyVariable = WeakReference(myVariable);',
                'final $apiName instance = $apiName(',
                '  ${method.name}: ($apiName ${classMemberNamePrefix}instance, ...) {',
                '    print(weakMyVariable?.target);',
                '  },',
                ');',
                '```',
                '',
                'Alternatively, [$dartInstanceManagerClassName.removeWeakReference] can be used to',
                'release the associated Native object manually.',
              ],
            ],
            _docCommentSpec,
          ))
          ..type = cb.FunctionType(
            (cb.FunctionTypeBuilder builder) => builder
              ..returnType = _refer(
                method.returnType,
                asFuture: method.isAsynchronous,
              )
              ..isNullable = !method.isRequired
              ..requiredParameters.addAll(<cb.Reference>[
                cb.refer('$apiName ${classMemberNamePrefix}instance'),
                ...indexMap(
                  method.parameters,
                  (int index, NamedType parameter) {
                    return cb.refer(
                      '${_addGenericTypesNullable(parameter.type)} ${_getParameterName(index, parameter)}',
                    );
                  },
                ),
              ]),
          ),
      );
    }
  }

  /// Converts the Flutter methods from the pigeon AST to `code_builder` Fields.
  ///
  /// Flutter methods of a ProxyApi are set as an anonymous function of a class
  /// instance, so this converts methods to a `Function` type field instance.
  ///
  /// This is similar to [_proxyApiFlutterMethodFields] except all the methods are
  /// inherited from apis that are being implemented (following the `implements`
  /// keyword).
  Iterable<cb.Field> _proxyApiInterfaceApiFields(
    Iterable<AstProxyApi> apisOfInterfaces,
  ) sync* {
    for (final AstProxyApi proxyApi in apisOfInterfaces) {
      for (final Method method in proxyApi.methods) {
        yield cb.Field(
          (cb.FieldBuilder builder) => builder
            ..name = method.name
            ..modifier = cb.FieldModifier.final$
            ..annotations.add(cb.refer('override'))
            ..docs.addAll(asDocumentationComments(
              method.documentationComments,
              _docCommentSpec,
            ))
            ..type = cb.FunctionType(
              (cb.FunctionTypeBuilder builder) => builder
                ..returnType = _refer(
                  method.returnType,
                  asFuture: method.isAsynchronous,
                )
                ..isNullable = !method.isRequired
                ..requiredParameters.addAll(<cb.Reference>[
                  cb.refer(
                    '${proxyApi.name} ${classMemberNamePrefix}instance',
                  ),
                  ...indexMap(
                    method.parameters,
                    (int index, NamedType parameter) {
                      return cb.refer(
                        '${_addGenericTypesNullable(parameter.type)} ${_getParameterName(index, parameter)}',
                      );
                    },
                  ),
                ]),
            ),
        );
      }
    }
  }

  /// Converts attached Fields from the pigeon AST to `code_builder` Field.
  ///
  /// Attached fields are set lazily by calling a private method that returns
  /// it.
  ///
  /// Example Output:
  ///
  /// ```dart
  /// final MyOtherProxyApiClass value = _pigeon_value();
  /// ```
  Iterable<cb.Field> _proxyApiAttachedFields(Iterable<ApiField> fields) sync* {
    for (final ApiField field in fields) {
      yield cb.Field(
        (cb.FieldBuilder builder) => builder
          ..name = field.name
          ..type = cb.refer(_addGenericTypesNullable(field.type))
          ..modifier = cb.FieldModifier.final$
          ..static = field.isStatic
          ..late = !field.isStatic
          ..docs.addAll(asDocumentationComments(
            field.documentationComments,
            _docCommentSpec,
          ))
          ..assignment = cb.Code('$varNamePrefix${field.name}()'),
      );
    }
  }

  /// Creates the static `setUpMessageHandlers` method for a ProxyApi.
  ///
  /// This method handles setting the message handler for every un-inherited
  /// Flutter method.
  ///
  /// This also adds a handler to receive a call from the platform to
  /// instantiate a new Dart instance if [hasCallbackConstructor] is set to
  /// true.
  cb.Method _proxyApiSetUpMessageHandlerMethod({
    required Iterable<Method> flutterMethods,
    required String apiName,
    required String dartPackageName,
    required String codecName,
    required Iterable<ApiField> unattachedFields,
    required bool hasCallbackConstructor,
  }) {
    final bool hasAnyMessageHandlers =
        hasCallbackConstructor || flutterMethods.isNotEmpty;
    return cb.Method.returnsVoid(
      (cb.MethodBuilder builder) => builder
        ..name = '${classMemberNamePrefix}setUpMessageHandlers'
        ..returns = cb.refer('void')
        ..static = true
        ..optionalParameters.addAll(<cb.Parameter>[
          cb.Parameter(
            (cb.ParameterBuilder builder) => builder
              ..name = '${classMemberNamePrefix}clearHandlers'
              ..type = cb.refer('bool')
              ..named = true
              ..defaultTo = const cb.Code('false'),
          ),
          cb.Parameter(
            (cb.ParameterBuilder builder) => builder
              ..name = '${classMemberNamePrefix}binaryMessenger'
              ..named = true
              ..type = cb.refer('BinaryMessenger?'),
          ),
          cb.Parameter(
            (cb.ParameterBuilder builder) => builder
              ..name = _instanceManagerVarName
              ..named = true
              ..type = cb.refer('$dartInstanceManagerClassName?'),
          ),
          if (hasCallbackConstructor)
            cb.Parameter(
              (cb.ParameterBuilder builder) => builder
                ..name = '${classMemberNamePrefix}newInstance'
                ..named = true
                ..type = cb.FunctionType(
                  (cb.FunctionTypeBuilder builder) => builder
                    ..returnType = cb.refer(apiName)
                    ..isNullable = true
                    ..requiredParameters.addAll(
                      indexMap(
                        unattachedFields,
                        (int index, ApiField field) {
                          return cb.refer(
                            '${_addGenericTypesNullable(field.type)} ${_getParameterName(index, field)}',
                          );
                        },
                      ),
                    ),
                ),
            ),
          for (final Method method in flutterMethods)
            cb.Parameter(
              (cb.ParameterBuilder builder) => builder
                ..name = method.name
                ..type = cb.FunctionType(
                  (cb.FunctionTypeBuilder builder) => builder
                    ..returnType = _refer(
                      method.returnType,
                      asFuture: method.isAsynchronous,
                    )
                    ..isNullable = true
                    ..requiredParameters.addAll(<cb.Reference>[
                      cb.refer('$apiName ${classMemberNamePrefix}instance'),
                      ...indexMap(
                        method.parameters,
                        (int index, NamedType parameter) {
                          return cb.refer(
                            '${_addGenericTypesNullable(parameter.type)} ${_getParameterName(index, parameter)}',
                          );
                        },
                      ),
                    ]),
                ),
            ),
        ])
        ..body = cb.Block.of(<cb.Code>[
          if (hasAnyMessageHandlers) ...<cb.Code>[
            cb.Code(
              'final $codecName $_pigeonChannelCodec = $codecName($_instanceManagerVarName ?? $dartInstanceManagerClassName.instance);',
            ),
            const cb.Code(
              'final BinaryMessenger? binaryMessenger = ${classMemberNamePrefix}binaryMessenger;',
            )
          ],
          if (hasCallbackConstructor)
            ...cb.Block((cb.BlockBuilder builder) {
              final StringBuffer messageHandlerSink = StringBuffer();
              const String methodName = '${classMemberNamePrefix}newInstance';
              _writeFlutterMethodMessageHandler(
                Indent(messageHandlerSink),
                name: methodName,
                parameters: <Parameter>[
                  Parameter(
                    name: '${classMemberNamePrefix}instanceIdentifier',
                    type: const TypeDeclaration(
                      baseName: 'int',
                      isNullable: false,
                    ),
                  ),
                  ...unattachedFields.map(
                    (ApiField field) {
                      return Parameter(name: field.name, type: field.type);
                    },
                  ),
                ],
                returnType: const TypeDeclaration.voidDeclaration(),
                channelName: makeChannelNameWithStrings(
                  apiName: apiName,
                  methodName: methodName,
                  dartPackageName: dartPackageName,
                ),
                isMockHandler: false,
                isAsynchronous: false,
                nullHandlerExpression: '${classMemberNamePrefix}clearHandlers',
                onCreateApiCall: (
                  String methodName,
                  Iterable<Parameter> parameters,
                  Iterable<String> safeArgumentNames,
                ) {
                  final String argsAsNamedParams = map2(
                    parameters,
                    safeArgumentNames,
                    (Parameter parameter, String safeArgName) {
                      return '${parameter.name}: $safeArgName,\n';
                    },
                  ).skip(1).join();
                  return '($_instanceManagerVarName ?? $dartInstanceManagerClassName.instance)\n'
                      '    .addHostCreatedInstance(\n'
                      '  $methodName?.call(${safeArgumentNames.skip(1).join(',')}) ??\n'
                      '      $apiName.${classMemberNamePrefix}detached('
                      '        ${classMemberNamePrefix}binaryMessenger: ${classMemberNamePrefix}binaryMessenger,\n'
                      '        $_instanceManagerVarName: $_instanceManagerVarName,\n'
                      '        $argsAsNamedParams\n'
                      '      ),\n'
                      '  ${safeArgumentNames.first},\n'
                      ')';
                },
              );
              builder.statements.add(cb.Code(messageHandlerSink.toString()));
            }).statements,
          for (final Method method in flutterMethods)
            ...cb.Block((cb.BlockBuilder builder) {
              final StringBuffer messageHandlerSink = StringBuffer();
              _writeFlutterMethodMessageHandler(
                Indent(messageHandlerSink),
                name: method.name,
                parameters: <Parameter>[
                  Parameter(
                    name: '${classMemberNamePrefix}instance',
                    type: TypeDeclaration(
                      baseName: apiName,
                      isNullable: false,
                    ),
                  ),
                  ...method.parameters,
                ],
                returnType: TypeDeclaration(
                  baseName: method.returnType.baseName,
                  isNullable:
                      !method.isRequired || method.returnType.isNullable,
                  typeArguments: method.returnType.typeArguments,
                  associatedEnum: method.returnType.associatedEnum,
                  associatedClass: method.returnType.associatedClass,
                  associatedProxyApi: method.returnType.associatedProxyApi,
                ),
                channelName: makeChannelNameWithStrings(
                  apiName: apiName,
                  methodName: method.name,
                  dartPackageName: dartPackageName,
                ),
                isMockHandler: false,
                isAsynchronous: method.isAsynchronous,
                nullHandlerExpression: '${classMemberNamePrefix}clearHandlers',
                onCreateApiCall: (
                  String methodName,
                  Iterable<Parameter> parameters,
                  Iterable<String> safeArgumentNames,
                ) {
                  final String nullability = method.isRequired ? '' : '?';
                  return '($methodName ?? ${safeArgumentNames.first}.$methodName)$nullability.call(${safeArgumentNames.join(',')})';
                },
              );
              builder.statements.add(cb.Code(messageHandlerSink.toString()));
            }).statements,
        ]),
    );
  }

  /// Converts attached fields from the pigeon AST to `code_builder` Methods.
  ///
  /// These private methods are used to lazily instantiate attached fields. The
  /// instance is created and returned synchronously while the native instance
  /// is created asynchronously. This is similar to how constructors work.
  Iterable<cb.Method> _proxyApiAttachedFieldMethods(
    Iterable<ApiField> fields, {
    required String apiName,
    required String dartPackageName,
    required String codecInstanceName,
    required String codecName,
  }) sync* {
    for (final ApiField field in fields) {
      yield cb.Method(
        (cb.MethodBuilder builder) {
          final String type = _addGenericTypesNullable(field.type);
          const String instanceName = '${varNamePrefix}instance';
          const String identifierInstanceName =
              '${varNamePrefix}instanceIdentifier';
          builder
            ..name = '$varNamePrefix${field.name}'
            ..static = field.isStatic
            ..returns = cb.refer(type)
            ..body = cb.Block(
              (cb.BlockBuilder builder) {
                final StringBuffer messageCallSink = StringBuffer();
                _writeHostMethodMessageCall(
                  Indent(messageCallSink),
                  addSuffixVariable: false,
                  channelName: makeChannelNameWithStrings(
                    apiName: apiName,
                    methodName: field.name,
                    dartPackageName: dartPackageName,
                  ),
                  parameters: <Parameter>[
                    if (!field.isStatic)
                      Parameter(
                        name: 'this',
                        type: TypeDeclaration(
                          baseName: apiName,
                          isNullable: false,
                        ),
                      ),
                    Parameter(
                      name: identifierInstanceName,
                      type: const TypeDeclaration(
                        baseName: 'int',
                        isNullable: false,
                      ),
                    ),
                  ],
                  returnType: const TypeDeclaration.voidDeclaration(),
                );
                builder.statements.addAll(<cb.Code>[
                  if (!field.isStatic) ...<cb.Code>[
                    cb.Code(
                      'final $type $instanceName = $type.${classMemberNamePrefix}detached(\n'
                      '  ${classMemberNamePrefix}binaryMessenger: ${classMemberNamePrefix}binaryMessenger,\n'
                      '  ${classMemberNamePrefix}instanceManager: ${classMemberNamePrefix}instanceManager,\n'
                      ');',
                    ),
                    cb.Code('final $codecName $_pigeonChannelCodec =\n'
                        '    $codecInstanceName;'),
                    const cb.Code(
                      'final BinaryMessenger? ${varNamePrefix}binaryMessenger = ${classMemberNamePrefix}binaryMessenger;',
                    ),
                    const cb.Code(
                      'final int $identifierInstanceName = $_instanceManagerVarName.addDartCreatedInstance($instanceName);',
                    ),
                  ] else ...<cb.Code>[
                    cb.Code(
                      'final $type $instanceName = $type.${classMemberNamePrefix}detached();',
                    ),
                    cb.Code(
                      'final $codecName $_pigeonChannelCodec = $codecName($dartInstanceManagerClassName.instance);',
                    ),
                    const cb.Code(
                      'final BinaryMessenger ${varNamePrefix}binaryMessenger = ServicesBinding.instance.defaultBinaryMessenger;',
                    ),
                    const cb.Code(
                      'final int $identifierInstanceName = $dartInstanceManagerClassName.instance.addDartCreatedInstance($instanceName);',
                    ),
                  ],
                  const cb.Code('() async {'),
                  cb.Code(messageCallSink.toString()),
                  const cb.Code('}();'),
                  const cb.Code('return $instanceName;'),
                ]);
              },
            );
        },
      );
    }
  }

  /// Converts host methods from pigeon AST to `code_builder` Methods.
  ///
  /// This creates methods like a HostApi except that it includes the calling
  /// instance if the method is not static.
  Iterable<cb.Method> _proxyApiHostMethods(
    Iterable<Method> methods, {
    required String apiName,
    required String dartPackageName,
    required String codecInstanceName,
    required String codecName,
  }) sync* {
    for (final Method method in methods) {
      assert(method.location == ApiLocation.host);
      yield cb.Method(
        (cb.MethodBuilder builder) => builder
          ..name = method.name
          ..static = method.isStatic
          ..modifier = cb.MethodModifier.async
          ..docs.addAll(asDocumentationComments(
            method.documentationComments,
            _docCommentSpec,
          ))
          ..returns = _refer(method.returnType, asFuture: true)
          ..requiredParameters.addAll(
            indexMap(
              method.parameters,
              (int index, NamedType parameter) => cb.Parameter(
                (cb.ParameterBuilder builder) => builder
                  ..name = _getParameterName(index, parameter)
                  ..type = cb.refer(
                    _addGenericTypesNullable(parameter.type),
                  ),
              ),
            ),
          )
          ..optionalParameters.addAll(<cb.Parameter>[
            if (method.isStatic) ...<cb.Parameter>[
              cb.Parameter(
                (cb.ParameterBuilder builder) => builder
                  ..name = '${classMemberNamePrefix}binaryMessenger'
                  ..type = cb.refer('BinaryMessenger?')
                  ..named = true,
              ),
              cb.Parameter(
                (cb.ParameterBuilder builder) => builder
                  ..name = _instanceManagerVarName
                  ..type = cb.refer('$dartInstanceManagerClassName?'),
              ),
            ],
          ])
          ..body = cb.Block(
            (cb.BlockBuilder builder) {
              final StringBuffer messageCallSink = StringBuffer();
              _writeHostMethodMessageCall(
                Indent(messageCallSink),
                addSuffixVariable: false,
                channelName: makeChannelNameWithStrings(
                  apiName: apiName,
                  methodName: method.name,
                  dartPackageName: dartPackageName,
                ),
                parameters: <Parameter>[
                  if (!method.isStatic)
                    Parameter(
                      name: 'this',
                      type: TypeDeclaration(
                        baseName: apiName,
                        isNullable: false,
                      ),
                    ),
                  ...method.parameters,
                ],
                returnType: method.returnType,
              );
              builder.statements.addAll(<cb.Code>[
                if (!method.isStatic)
                  cb.Code('final $codecName $_pigeonChannelCodec =\n'
                      '    $codecInstanceName;')
                else
                  cb.Code(
                    'final $codecName $_pigeonChannelCodec = $codecName($_instanceManagerVarName ?? $dartInstanceManagerClassName.instance);',
                  ),
                const cb.Code(
                  'final BinaryMessenger? ${varNamePrefix}binaryMessenger = ${classMemberNamePrefix}binaryMessenger;',
                ),
                cb.Code(messageCallSink.toString()),
              ]);
            },
          ),
      );
    }
  }

  /// Creates the copy method for a ProxyApi.
  ///
  /// This method returns a copy of the instance with all the Flutter methods
  /// and unattached fields passed to the new instance. This method is inherited
  /// from the base ProxyApi class.
  cb.Method _proxyApiCopyMethod({
    required String apiName,
    required Iterable<ApiField> unattachedFields,
    required Iterable<Method> declaredAndInheritedFlutterMethods,
  }) {
    return cb.Method(
      (cb.MethodBuilder builder) => builder
        ..name = '${classMemberNamePrefix}copy'
        ..returns = cb.refer(apiName)
        ..annotations.add(cb.refer('override'))
        ..body = cb.Block.of(<cb.Code>[
          cb
              .refer('$apiName.${classMemberNamePrefix}detached')
              .call(
                <cb.Expression>[],
                <String, cb.Expression>{
                  '${classMemberNamePrefix}binaryMessenger':
                      cb.refer('${classMemberNamePrefix}binaryMessenger'),
                  _instanceManagerVarName: cb.refer(_instanceManagerVarName),
                  for (final ApiField field in unattachedFields)
                    field.name: cb.refer(field.name),
                  for (final Method method
                      in declaredAndInheritedFlutterMethods)
                    method.name: cb.refer(method.name),
                },
              )
              .returned
              .statement,
        ]),
    );
  }
}

cb.Reference _refer(TypeDeclaration type, {bool asFuture = false}) {
  final String symbol = _addGenericTypesNullable(type);
  return cb.refer(asFuture ? 'Future<$symbol>' : symbol);
}

String _escapeForDartSingleQuotedString(String raw) {
  return raw
      .replaceAll(r'\', r'\\')
      .replaceAll(r'$', r'\$')
      .replaceAll(r"'", r"\'");
}

/// Creates a Dart type where all type arguments are [Objects].
String _makeGenericTypeArguments(TypeDeclaration type) {
  return type.typeArguments.isNotEmpty
      ? '${type.baseName}<${type.typeArguments.map<String>((TypeDeclaration e) => 'Object?').join(', ')}>'
      : _addGenericTypes(type);
}

/// Creates a `.cast<>` call for an type. Returns an empty string if the
/// type has no type arguments.
String _makeGenericCastCall(TypeDeclaration type) {
  return type.typeArguments.isNotEmpty
      ? '.cast<${_flattenTypeArguments(type.typeArguments)}>()'
      : '';
}

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType field) =>
    field.name.isEmpty ? 'arg$count' : 'arg_${field.name}';

/// Generates a parameter name if one isn't defined.
String _getParameterName(int count, NamedType field) =>
    field.name.isEmpty ? 'arg$count' : field.name;

/// Generates the parameters code for [func]
/// Example: (func, _getParameterName) -> 'String? foo, int bar'
String _getMethodParameterSignature(
  Iterable<Parameter> parameters, {
  bool addTrailingComma = false,
}) {
  String signature = '';
  if (parameters.isEmpty) {
    return signature;
  }

  final List<Parameter> requiredPositionalParams = parameters
      .where((Parameter p) => p.isPositional && !p.isOptional)
      .toList();
  final List<Parameter> optionalPositionalParams = parameters
      .where((Parameter p) => p.isPositional && p.isOptional)
      .toList();
  final List<Parameter> namedParams =
      parameters.where((Parameter p) => !p.isPositional).toList();

  String getParameterString(Parameter p) {
    final String required = p.isRequired && !p.isPositional ? 'required ' : '';

    final String type = _addGenericTypesNullable(p.type);

    final String defaultValue =
        p.defaultValue == null ? '' : ' = ${p.defaultValue}';
    return '$required$type ${p.name}$defaultValue';
  }

  final String baseParameterString = requiredPositionalParams
      .map((Parameter p) => getParameterString(p))
      .join(', ');
  final String optionalParameterString = optionalPositionalParams
      .map((Parameter p) => getParameterString(p))
      .join(', ');
  final String namedParameterString =
      namedParams.map((Parameter p) => getParameterString(p)).join(', ');

  // Parameter lists can end with either named or optional positional parameters, but not both.
  if (requiredPositionalParams.isNotEmpty) {
    signature = baseParameterString;
  }
  final String trailingComma =
      optionalPositionalParams.isNotEmpty || namedParams.isNotEmpty ? ',' : '';
  final String baseParams =
      signature.isNotEmpty ? '$signature$trailingComma ' : '';
  if (optionalPositionalParams.isNotEmpty) {
    final String trailingComma =
        requiredPositionalParams.length + optionalPositionalParams.length > 2
            ? ','
            : '';
    return '$baseParams[$optionalParameterString$trailingComma]';
  }
  if (namedParams.isNotEmpty) {
    final String trailingComma = addTrailingComma ||
            requiredPositionalParams.length + namedParams.length > 2
        ? ', '
        : '';
    return '$baseParams{$namedParameterString$trailingComma}';
  }
  return signature;
}

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in Dart code.
String _flattenTypeArguments(List<TypeDeclaration> args) {
  return args
      .map<String>((TypeDeclaration arg) => arg.typeArguments.isEmpty
          ? '${arg.baseName}${arg.isNullable ? '?' : ''}'
          : '${arg.baseName}<${_flattenTypeArguments(arg.typeArguments)}>${arg.isNullable ? '?' : ''}')
      .join(', ');
}

/// Creates the type declaration for use in Dart code from a [NamedType] making sure
/// that type arguments are used for primitive generic types.
String _addGenericTypes(TypeDeclaration type) {
  final List<TypeDeclaration> typeArguments = type.typeArguments;
  switch (type.baseName) {
    case 'List':
      return typeArguments.isEmpty
          ? 'List<Object?>'
          : 'List<${_flattenTypeArguments(typeArguments)}>';
    case 'Map':
      return typeArguments.isEmpty
          ? 'Map<Object?, Object?>'
          : 'Map<${_flattenTypeArguments(typeArguments)}>';
    default:
      return type.baseName;
  }
}

String _addGenericTypesNullable(TypeDeclaration type) {
  final String genericType = _addGenericTypes(type);
  return type.isNullable ? '$genericType?' : genericType;
}

/// Converts [inputPath] to a posix absolute path.
String _posixify(String inputPath) {
  final path.Context context = path.Context(style: path.Style.posix);
  return context.fromUri(path.toUri(path.absolute(inputPath)));
}
