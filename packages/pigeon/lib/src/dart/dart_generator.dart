// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import '../ast.dart';
import '../functional.dart';
import '../generator.dart';
import '../generator_tools.dart';
import 'proxy_api_generator_helper.dart' as proxy_api_helper;
import 'templates.dart';

/// Documentation comment open symbol.
const String _docCommentPrefix = '///';

/// Name of the variable that contains the message channel suffix for APIs.
const String _suffixVarName = '${varNamePrefix}messageChannelSuffix';

/// Name of the `InstanceManager` variable for the Dart proxy class of a ProxyAPI.
const String instanceManagerVarName = '${classMemberNamePrefix}instanceManager';

/// Name of field used for host API codec.
const String pigeonChannelCodec = 'pigeonChannelCodec';

/// Documentation comment spec.
const DocumentCommentSpecification docCommentSpec =
    DocumentCommentSpecification(_docCommentPrefix);

/// The custom codec used for all pigeon APIs.
const String _pigeonMessageCodec = '_PigeonCodec';

/// Name of field used for host API codec.
const String _pigeonMethodChannelCodec = 'pigeonMethodCodec';

const String _overflowClassName = '_PigeonCodecOverflow';

/// Name of the overrides class for overriding constructors and static members
/// of Dart proxy classes.
const String proxyApiOverridesClassName = '${proxyApiClassNamePrefix}Overrides';

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

/// Options that control how Dart code will be generated.
class InternalDartOptions extends InternalOptions {
  /// Constructor for InternalDartOptions.
  const InternalDartOptions({
    this.copyrightHeader,
    this.dartOut,
    this.testOut,
  });

  /// Creates InternalDartOptions from DartOptions.
  InternalDartOptions.fromDartOptions(
    DartOptions options, {
    Iterable<String>? copyrightHeader,
    String? dartOut,
    String? testOut,
  })  : copyrightHeader = copyrightHeader ?? options.copyrightHeader,
        dartOut = (dartOut ?? options.sourceOutPath)!,
        testOut = testOut ?? options.testOutPath;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Path to output generated Dart file.
  final String? dartOut;

  /// Path to output generated Test file for tests.
  final String? testOut;
}

/// Class that manages all Dart code generation.
class DartGenerator extends StructuredGenerator<InternalDartOptions> {
  /// Instantiates a Dart Generator.
  const DartGenerator();

  // Formatter used to format code from `code_builder`.
  DartFormatter get _formatter {
    return DartFormatter(languageVersion: Version(3, 6, 0));
  }

  @override
  void writeFilePrologue(
    InternalDartOptions generatorOptions,
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
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln("import 'dart:async';");
    if (root.containsProxyApi) {
      indent.writeln("import 'dart:io' show Platform;");
    }
    indent.writeln(
      "import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;",
    );
    indent.newln();

    indent.writeln(
        "import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer${root.containsProxyApi ? ', immutable, protected, visibleForTesting' : ''};");
    indent.writeln("import 'package:flutter/services.dart';");
    if (root.containsProxyApi) {
      indent.writeln(
        "import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;",
      );
    }
  }

  @override
  void writeEnum(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, docCommentSpec);
    indent.write('enum ${anEnum.name} ');
    indent.addScoped('{', '}', () {
      for (final EnumMember member in anEnum.members) {
        addDocumentationComments(
            indent, member.documentationComments, docCommentSpec);
        indent.writeln('${member.name},');
      }
    });
  }

  @override
  void writeDataClass(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, classDefinition.documentationComments, docCommentSpec);
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
            indent, field.documentationComments, docCommentSpec);

        final String datatype = addGenericTypesNullable(field.type);
        indent.writeln('$datatype ${field.name};');
        indent.newln();
      }
      _writeToList(indent, classDefinition);
      indent.newln();
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
      indent.newln();
      writeClassEquality(
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

  void _writeToList(Indent indent, Class classDefinition) {
    indent.writeScoped('List<Object?> _toList() {', '}', () {
      indent.writeScoped('return <Object?>[', '];', () {
        for (final NamedType field
            in getFieldsInSerializationOrder(classDefinition)) {
          indent.writeln('${field.name},');
        }
      });
    });
  }

  @override
  void writeClassEncode(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.write('Object encode() ');
    indent.addScoped('{', '}', () {
      indent.write(
        'return _toList();',
      );
    });
  }

  @override
  void writeClassDecode(
    InternalDartOptions generatorOptions,
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
  void writeClassEquality(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.writeln('@override');
    indent.writeln('// ignore: avoid_equals_and_hash_code_on_mutable_classes');
    indent.writeScoped('bool operator ==(Object other) {', '}', () {
      indent.writeScoped(
          'if (other is! ${classDefinition.name} || other.runtimeType != runtimeType) {',
          '}', () {
        indent.writeln('return false;');
      });
      indent.writeScoped('if (identical(this, other)) {', '}', () {
        indent.writeln('return true;');
      });
      indent.writeln('return _deepEquals(encode(), other.encode());');
    });
    indent.newln();
    indent.writeln('@override');
    indent.writeln('// ignore: avoid_equals_and_hash_code_on_mutable_classes');
    indent.writeln('int get hashCode => Object.hashAll(_toList())');
    indent.addln(';');
  }

  @override
  void writeGeneralCodec(
    InternalDartOptions generatorOptions,
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
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    String Function(Method)? channelNameFunc,
    bool isMockHandler = false,
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(indent, api.documentationComments, docCommentSpec);

    indent.write('abstract class ${api.name} ');
    indent.addScoped('{', '}', () {
      if (isMockHandler) {
        indent.writeln(
            'static TestDefaultBinaryMessengerBinding? get _testBinaryMessengerBinding => TestDefaultBinaryMessengerBinding.instance;');
      }
      indent.writeln(
          'static const MessageCodec<Object?> $pigeonChannelCodec = $_pigeonMessageCodec();');
      indent.newln();
      for (final Method func in api.methods) {
        addDocumentationComments(
            indent, func.documentationComments, docCommentSpec);

        final bool isAsync = func.isAsynchronous;
        final String returnType = isAsync
            ? 'Future<${addGenericTypesNullable(func.returnType)}>'
            : addGenericTypesNullable(func.returnType);
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
          writeFlutterMethodMessageHandler(
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
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    indent.newln();
    bool first = true;
    addDocumentationComments(indent, api.documentationComments, docCommentSpec);
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
          'static const MessageCodec<Object?> $pigeonChannelCodec = $_pigeonMessageCodec();');
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
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    AstEventChannelApi api, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(indent, api.documentationComments, docCommentSpec);
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
    InternalDartOptions generatorOptions,
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
    InternalDartOptions generatorOptions,
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
                  ..name = pigeonChannelCodec
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
                      writeFlutterMethodMessageHandler(
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
                      writeHostMethodMessageCall(
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
                      writeHostMethodMessageCall(
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
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
  ) {
    indent.format(proxyApiBaseCodec);
  }

  @override
  void writeProxyApi(
    InternalDartOptions generatorOptions,
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
          asDocumentationComments(api.documentationComments, docCommentSpec),
        )
        ..constructors.addAll(proxy_api_helper.constructors(
          api.constructors,
          apiName: api.name,
          dartPackageName: dartPackageName,
          codecName: codecName,
          codecInstanceName: codecInstanceName,
          superClassApi: api.superClass?.associatedProxyApi,
          unattachedFields: api.unattachedFields,
          flutterMethodsFromSuperClasses:
              api.flutterMethodsFromSuperClassesWithApis(),
          flutterMethodsFromInterfaces:
              api.flutterMethodsFromInterfacesWithApis(),
          declaredFlutterMethods: api.flutterMethods,
        ))
        ..constructors.add(
          proxy_api_helper.detachedConstructor(
            apiName: api.name,
            superClassApi: api.superClass?.associatedProxyApi,
            unattachedFields: api.unattachedFields,
            flutterMethodsFromSuperClasses:
                api.flutterMethodsFromSuperClassesWithApis(),
            flutterMethodsFromInterfaces:
                api.flutterMethodsFromInterfacesWithApis(),
            declaredFlutterMethods: api.flutterMethods,
          ),
        )
        ..fields.addAll(<cb.Field>[
          if (api.constructors.isNotEmpty ||
              api.attachedFields.any((ApiField field) => !field.isStatic) ||
              api.hostMethods.isNotEmpty)
            proxy_api_helper.codecInstanceField(
              codecInstanceName: codecInstanceName,
              codecName: codecName,
            ),
        ])
        ..fields.addAll(
          proxy_api_helper.unattachedFields(api.unattachedFields),
        )
        ..fields.addAll(proxy_api_helper.flutterMethodFields(
          api.flutterMethods,
          apiName: api.name,
        ))
        ..fields.addAll(
          proxy_api_helper.interfaceApiFields(
            api.apisOfInterfaces(),
          ),
        )
        ..fields.addAll(
          proxy_api_helper.attachedFields(api.attachedFields),
        )
        ..methods.addAll(proxy_api_helper.staticAttachedFieldsGetters(
          api.attachedFields.where((ApiField field) => field.isStatic),
          apiName: api.name,
        ))
        ..methods.add(
          proxy_api_helper.setUpMessageHandlerMethod(
            flutterMethods: api.flutterMethods,
            apiName: api.name,
            dartPackageName: dartPackageName,
            codecName: codecName,
            unattachedFields: api.unattachedFields,
            hasCallbackConstructor: api.hasCallbackConstructor(),
          ),
        )
        ..methods.addAll(
          proxy_api_helper.attachedFieldMethods(
            api.attachedFields,
            apiName: api.name,
            dartPackageName: dartPackageName,
            codecInstanceName: codecInstanceName,
            codecName: codecName,
          ),
        )
        ..methods.addAll(proxy_api_helper.hostMethods(
          api.hostMethods,
          apiName: api.name,
          dartPackageName: dartPackageName,
          codecInstanceName: codecInstanceName,
          codecName: codecName,
        ))
        ..methods.add(
          proxy_api_helper.copyMethod(
            apiName: api.name,
            unattachedFields: api.unattachedFields,
            flutterMethodsFromSuperClasses:
                api.flutterMethodsFromSuperClassesWithApis(),
            flutterMethodsFromInterfaces:
                api.flutterMethodsFromInterfacesWithApis(),
            declaredFlutterMethods: api.flutterMethods,
          ),
        ),
    );

    final cb.DartEmitter emitter = cb.DartEmitter(useNullSafetySyntax: true);
    indent.format(_formatter.format('${proxyApi.accept(emitter)}'));
  }

  /// Generates Dart source code for test support libraries based on the given AST
  /// represented by [root], outputting the code to [sink]. [sourceOutPath] is the
  /// path of the generated Dart code to be tested. [testOutPath] is where the
  /// test code will be generated.
  void generateTest(
    InternalDartOptions generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
    required String dartOutputPackageName,
  }) {
    final Indent indent = Indent(sink);
    final String sourceOutPath = generatorOptions.dartOut ?? '';
    final String testOutPath = generatorOptions.testOut ?? '';
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
  void _writeTestPrologue(InternalDartOptions opt, Root root, Indent indent) {
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
  void _writeTestImports(InternalDartOptions opt, Root root, Indent indent) {
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
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.containsHostApi || root.containsProxyApi) {
      _writeCreateConnectionError(indent);
    }
    if (root.containsFlutterApi ||
        root.containsProxyApi ||
        generatorOptions.testOut != null) {
      _writeWrapResponse(generatorOptions, root, indent);
    }
    if (root.classes.isNotEmpty) {
      _writeDeepEquals(indent);
    }
    if (root.containsProxyApi) {
      proxy_api_helper.writeProxyApiPigeonOverrides(
        indent,
        formatter: _formatter,
        proxyApis: root.apis.whereType(),
      );
    }
  }

  /// Writes [wrapResponse] method.
  void _writeWrapResponse(InternalDartOptions opt, Root root, Indent indent) {
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

  void _writeDeepEquals(Indent indent) {
    indent.format(r'''
bool _deepEquals(Object? a, Object? b) {
  if (a is List && b is List) {
    return a.length == b.length &&
        a.indexed
        .every(((int, dynamic) item) => _deepEquals(item.$2, b[item.$1]));
  }
  if (a is Map && b is Map) {
    return a.length == b.length && a.entries.every((MapEntry<Object?, Object?> entry) =>
        (b as Map<Object?, Object?>).containsKey(entry.key) &&
        _deepEquals(entry.value, b[entry.key]));
  }
  return a == b;
}
''');
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
    addDocumentationComments(indent, documentationComments, docCommentSpec);
    final String argSignature = _getMethodParameterSignature(parameters);
    indent.write(
      'Future<${addGenericTypesNullable(returnType)}> $name($argSignature) async ',
    );
    indent.addScoped('{', '}', () {
      writeHostMethodMessageCall(
        indent,
        channelName: channelName,
        parameters: parameters,
        returnType: returnType,
        addSuffixVariable: addSuffixVariable,
      );
    });
  }

  /// Writes the message call to a host method to [indent].
  static void writeHostMethodMessageCall(
    Indent indent, {
    required String channelName,
    required Iterable<Parameter> parameters,
    required TypeDeclaration returnType,
    required bool addSuffixVariable,
    bool insideAsyncMethod = true,
  }) {
    String sendArgument = 'null';
    if (parameters.isNotEmpty) {
      final Iterable<String> argExpressions =
          indexMap(parameters, (int index, NamedType type) {
        final String name = getParameterName(index, type);
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
      indent.writeln('$pigeonChannelCodec,');
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

    const String sendFutureVar = '${varNamePrefix}sendFuture';
    indent.writeln(
      'final Future<Object?> $sendFutureVar = ${varNamePrefix}channel.send($sendArgument);',
    );

    // If the message call is not made inside of an async method, this creates
    // an anonymous function to handle the send future.
    if (!insideAsyncMethod) {
      indent.writeln('() async {');
      indent.inc();
    }

    indent.format('''
final List<Object?>? ${varNamePrefix}replyList =
\t\tawait $sendFutureVar as List<Object?>?;
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

    if (!insideAsyncMethod) {
      indent.dec();
      indent.writeln('}();');
    }
  }

  /// Writes the message call handler for a Flutter method to [indent].
  static void writeFlutterMethodMessageHandler(
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
        indent.writeln("'$channelName$channelSuffix', $pigeonChannelCodec,");
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
          final String returnTypeString = addGenericTypesNullable(returnType);
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
}

/// Converts a [TypeDeclaration] to a `code_builder` Reference.
cb.Reference refer(TypeDeclaration type, {bool asFuture = false}) {
  final String symbol = addGenericTypesNullable(type);
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
String getParameterName(int count, NamedType field) =>
    field.name.isEmpty ? 'arg$count' : field.name;

/// Generates the parameters code for [func]
/// Example: (func, getParameterName) -> 'String? foo, int bar'
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

    final String type = addGenericTypesNullable(p.type);

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

/// Converts the type signature of a [TypeDeclaration] that include generic
/// types.
String addGenericTypesNullable(TypeDeclaration type) {
  final String genericType = _addGenericTypes(type);
  return type.isNullable ? '$genericType?' : genericType;
}

/// Converts [inputPath] to a posix absolute path.
String _posixify(String inputPath) {
  final path.Context context = path.Context(style: path.Style.posix);
  return context.fromUri(path.toUri(path.absolute(inputPath)));
}
