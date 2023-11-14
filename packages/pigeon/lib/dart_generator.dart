// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as path;

import 'ast.dart';
import 'functional.dart';
import 'generator.dart';
import 'generator_tools.dart';

/// Documentation comment open symbol.
const String _docCommentPrefix = '///';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_docCommentPrefix);

/// The standard codec for Flutter, used for any non custom codecs and extended for custom codecs.
const String _standardMessageCodec = 'StandardMessageCodec';

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
      '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import',
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
      "import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer, immutable, protected;",
    );
    indent.writeln("import 'package:flutter/services.dart';");
    // TODO: should be conditional
    indent.writeln(
      "import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;",
    );
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
    Class klass, {
    required String dartPackageName,
  }) {
    final Set<String> customClassNames =
        root.classes.map((Class x) => x.name).toSet();
    final Set<String> customEnumNames =
        root.enums.map((Enum x) => x.name).toSet();

    indent.newln();
    addDocumentationComments(
        indent, klass.documentationComments, _docCommentSpec);

    indent.write('class ${klass.name} ');
    indent.addScoped('{', '}', () {
      _writeConstructor(indent, klass);
      indent.newln();
      for (final NamedType field in getFieldsInSerializationOrder(klass)) {
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
        klass,
        customClassNames,
        customEnumNames,
        dartPackageName: dartPackageName,
      );
      indent.newln();
      writeClassDecode(
        generatorOptions,
        root,
        indent,
        klass,
        customClassNames,
        customEnumNames,
        dartPackageName: dartPackageName,
      );
    });
  }

  void _writeConstructor(Indent indent, Class klass) {
    indent.write(klass.name);
    indent.addScoped('({', '});', () {
      for (final NamedType field in getFieldsInSerializationOrder(klass)) {
        final String required = field.type.isNullable ? '' : 'required ';
        indent.writeln('${required}this.${field.name},');
      }
    });
  }

  @override
  void writeClassEncode(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames, {
    required String dartPackageName,
  }) {
    indent.write('Object encode() ');
    indent.addScoped('{', '}', () {
      indent.write(
        'return <Object?>',
      );
      indent.addScoped('[', '];', () {
        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          final String conditional = field.type.isNullable ? '?' : '';
          if (customClassNames.contains(field.type.baseName)) {
            indent.writeln(
              '${field.name}$conditional.encode(),',
            );
          } else if (customEnumNames.contains(field.type.baseName)) {
            indent.writeln(
              '${field.name}$conditional.index,',
            );
          } else {
            indent.writeln('${field.name},');
          }
        }
      });
    });
  }

  @override
  void writeClassDecode(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames, {
    required String dartPackageName,
  }) {
    void writeValueDecode(NamedType field, int index) {
      final String resultAt = 'result[$index]';
      final String castCallPrefix = field.type.isNullable ? '?' : '!';
      final String genericType = _makeGenericTypeArguments(field.type);
      final String castCall = _makeGenericCastCall(field.type);
      final String nullableTag = field.type.isNullable ? '?' : '';
      if (customClassNames.contains(field.type.baseName)) {
        final String nonNullValue =
            '${field.type.baseName}.decode($resultAt! as List<Object?>)';
        if (field.type.isNullable) {
          indent.format('''
$resultAt != null
\t\t? $nonNullValue
\t\t: null''', leadingSpace: false, trailingNewline: false);
        } else {
          indent.add(nonNullValue);
        }
      } else if (customEnumNames.contains(field.type.baseName)) {
        final String nonNullValue =
            '${field.type.baseName}.values[$resultAt! as int]';
        if (field.type.isNullable) {
          indent.format('''
$resultAt != null
\t\t? $nonNullValue
\t\t: null''', leadingSpace: false, trailingNewline: false);
        } else {
          indent.add(nonNullValue);
        }
      } else if (field.type.typeArguments.isNotEmpty) {
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
      'static ${klass.name} decode(Object result) ',
    );
    indent.addScoped('{', '}', () {
      indent.writeln('result as List<Object?>;');
      indent.write('return ${klass.name}');
      indent.addScoped('(', ');', () {
        enumerate(getFieldsInSerializationOrder(klass),
            (int index, final NamedType field) {
          indent.write('${field.name}: ');
          writeValueDecode(field, index);
          indent.addln(',');
        });
      });
    });
  }

  /// Writes the code for host [Api], [api].
  /// Example:
  /// class FooCodec extends StandardMessageCodec {...}
  ///
  /// abstract class Foo {
  ///   static const MessageCodec<Object?> codec = FooCodec();
  ///   int add(int x, int y);
  ///   static void setup(Foo api, {BinaryMessenger? binaryMessenger}) {...}
  /// }
  @override
  void writeFlutterApi(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    String Function(Method)? channelNameFunc,
    bool isMockHandler = false,
    required String dartPackageName,
  }) {
    assert(api.location == ApiLocation.flutter);
    final List<String> customEnumNames =
        root.enums.map((Enum x) => x.name).toList();
    String codecName = _standardMessageCodec;
    if (getCodecClasses(api, root).isNotEmpty) {
      codecName = _getCodecName(api.name);
      _writeCodec(indent, codecName, api, root);
    }
    indent.newln();
    addDocumentationComments(
        indent, api.documentationComments, _docCommentSpec);

    indent.write('abstract class ${api.name} ');
    indent.addScoped('{', '}', () {
      if (isMockHandler) {
        indent.writeln(
            'static TestDefaultBinaryMessengerBinding? get _testBinaryMessengerBinding => TestDefaultBinaryMessengerBinding.instance;');
      }
      indent
          .writeln('static const MessageCodec<Object?> codec = $codecName();');
      indent.newln();
      for (final Method func in api.methods) {
        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);

        final bool isAsync = func.isAsynchronous;
        final String returnType = isAsync
            ? 'Future<${_addGenericTypesNullable(func.returnType)}>'
            : _addGenericTypesNullable(func.returnType);
        final String argSignature = _getMethodArgumentsSignature(
          func,
          _getArgumentName,
        );
        indent.writeln('$returnType ${func.name}($argSignature);');
        indent.newln();
      }
      indent.write(
          'static void setup(${api.name}? api, {BinaryMessenger? binaryMessenger}) ');
      indent.addScoped('{', '}', () {
        for (final Method func in api.methods) {
          indent.write('');
          indent.addScoped('{', '}', () {
            indent.writeln(
              'final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(',
            );
            final String channelName = channelNameFunc == null
                ? makeChannelName(api, func, dartPackageName)
                : channelNameFunc(func);
            indent.nest(2, () {
              indent.writeln("'$channelName', codec,");
              indent.writeln(
                'binaryMessenger: binaryMessenger);',
              );
            });
            final String messageHandlerSetterWithOpeningParentheses = isMockHandler
                ? '_testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(channel, '
                : 'channel.setMessageHandler(';
            indent.write('if (api == null) ');
            indent.addScoped('{', '}', () {
              indent.writeln(
                  '${messageHandlerSetterWithOpeningParentheses}null);');
            }, addTrailingNewline: false);
            indent.add(' else ');
            indent.addScoped('{', '}', () {
              indent.write(
                '$messageHandlerSetterWithOpeningParentheses(Object? message) async ',
              );
              indent.addScoped('{', '});', () {
                final String returnType =
                    _addGenericTypesNullable(func.returnType);
                final bool isAsync = func.isAsynchronous;
                const String emptyReturnStatement =
                    'return wrapResponse(empty: true);';
                String call;
                if (func.arguments.isEmpty) {
                  call = 'api.${func.name}()';
                } else {
                  indent.writeln('assert(message != null,');
                  indent.writeln("'Argument for $channelName was null.');");
                  const String argsArray = 'args';
                  indent.writeln(
                      'final List<Object?> $argsArray = (message as List<Object?>?)!;');
                  String argNameFunc(int index, NamedType type) =>
                      _getSafeArgumentName(index, type);
                  enumerate(func.arguments, (int count, NamedType arg) {
                    final String argType = _addGenericTypes(arg.type);
                    final String argName = argNameFunc(count, arg);
                    final String genericArgType =
                        _makeGenericTypeArguments(arg.type);
                    final String castCall = _makeGenericCastCall(arg.type);

                    final String leftHandSide = 'final $argType? $argName';
                    if (customEnumNames.contains(arg.type.baseName)) {
                      indent.writeln(
                          '$leftHandSide = $argsArray[$count] == null ? null : $argType.values[$argsArray[$count]! as int];');
                    } else {
                      indent.writeln(
                          '$leftHandSide = ($argsArray[$count] as $genericArgType?)${castCall.isEmpty ? '' : '?$castCall'};');
                    }
                    if (!arg.type.isNullable) {
                      indent.writeln('assert($argName != null,');
                      indent.writeln(
                          "    'Argument for $channelName was null, expected non-null $argType.');");
                    }
                  });
                  final Iterable<String> argNames =
                      indexMap(func.arguments, (int index, NamedType field) {
                    final String name = _getSafeArgumentName(index, field);
                    return '$name${field.type.isNullable ? '' : '!'}';
                  });
                  call = 'api.${func.name}(${argNames.join(', ')})';
                }
                indent.writeScoped('try {', '} ', () {
                  if (func.returnType.isVoid) {
                    if (isAsync) {
                      indent.writeln('await $call;');
                    } else {
                      indent.writeln('$call;');
                    }
                    indent.writeln(emptyReturnStatement);
                  } else {
                    if (isAsync) {
                      indent.writeln('final $returnType output = await $call;');
                    } else {
                      indent.writeln('final $returnType output = $call;');
                    }

                    const String returnExpression = 'output';
                    final String nullability =
                        func.returnType.isNullable ? '?' : '';
                    final String valueExtraction = isEnum(root, func.returnType)
                        ? '$nullability.index'
                        : '';
                    final String returnStatement = isMockHandler
                        ? 'return <Object?>[$returnExpression$valueExtraction];'
                        : 'return wrapResponse(result: $returnExpression$valueExtraction);';
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
    Api api, {
    required String dartPackageName,
  }) {
    assert(api.location == ApiLocation.host);
    String codecName = _standardMessageCodec;
    if (getCodecClasses(api, root).isNotEmpty) {
      codecName = _getCodecName(api.name);
      _writeCodec(indent, codecName, api, root);
    }
    final List<String> customEnumNames =
        root.enums.map((Enum x) => x.name).toList();
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
${api.name}({BinaryMessenger? binaryMessenger})
\t\t: _binaryMessenger = binaryMessenger;
final BinaryMessenger? _binaryMessenger;
''');

      indent
          .writeln('static const MessageCodec<Object?> codec = $codecName();');
      indent.newln();
      for (final Method func in api.methods) {
        if (!first) {
          indent.newln();
        } else {
          first = false;
        }
        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);
        String argSignature = '';
        String sendArgument = 'null';
        if (func.arguments.isNotEmpty) {
          String argNameFunc(int index, NamedType type) =>
              _getSafeArgumentName(index, type);
          final Iterable<String> argExpressions =
              indexMap(func.arguments, (int index, NamedType type) {
            final String name = argNameFunc(index, type);
            if (root.enums
                .map((Enum e) => e.name)
                .contains(type.type.baseName)) {
              return '$name${type.type.isNullable ? '?' : ''}.index';
            } else {
              return name;
            }
          });
          sendArgument = '<Object?>[${argExpressions.join(', ')}]';
          argSignature = _getMethodArgumentsSignature(func, argNameFunc);
        }
        indent.write(
          'Future<${_addGenericTypesNullable(func.returnType)}> ${func.name}($argSignature) async ',
        );
        indent.addScoped('{', '}', () {
          final String channelName =
              makeChannelName(api, func, dartPackageName);
          indent.writeln(
              'final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(');
          indent.nest(2, () {
            indent.writeln("'$channelName', codec,");
            indent.writeln('binaryMessenger: _binaryMessenger);');
          });
          final String returnType = _makeGenericTypeArguments(func.returnType);
          final String genericCastCall = _makeGenericCastCall(func.returnType);
          const String accessor = 'replyList[0]';
          // Avoid warnings from pointlessly casting to `Object?`.
          final String nullablyTypedAccessor =
              returnType == 'Object' ? accessor : '($accessor as $returnType?)';
          final String nullHandler = func.returnType.isNullable
              ? (genericCastCall.isEmpty ? '' : '?')
              : '!';
          String returnStatement = 'return';
          if (customEnumNames.contains(returnType)) {
            if (func.returnType.isNullable) {
              returnStatement =
                  '$returnStatement ($accessor as int?) == null ? null : $returnType.values[$accessor! as int]';
            } else {
              returnStatement =
                  '$returnStatement $returnType.values[$accessor! as int]';
            }
          } else if (!func.returnType.isVoid) {
            returnStatement =
                '$returnStatement $nullablyTypedAccessor$nullHandler$genericCastCall';
          }
          returnStatement = '$returnStatement;';

          indent.format('''
final List<Object?>? replyList =
\t\tawait channel.send($sendArgument) as List<Object?>?;
if (replyList == null) {
\tthrow PlatformException(
\t\tcode: 'channel-error',
\t\tmessage: 'Unable to establish connection on channel.',
\t);
} else if (replyList.length > 1) {
\tthrow PlatformException(
\t\tcode: replyList[0]! as String,
\t\tmessage: replyList[1] as String?,
\t\tdetails: replyList[2],
\t);''');
          // On iOS we can return nil from functions to accommodate error
          // handling.  Returning a nil value and not returning an error is an
          // exception.
          if (!func.returnType.isNullable && !func.returnType.isVoid) {
            indent.format('''
} else if (replyList[0] == null) {
\tthrow PlatformException(
\t\tcode: 'null-error',
\t\tmessage: 'Host platform returned null value for non-null return value.',
\t);''');
          }
          indent.format('''
} else {
\t$returnStatement
}''');
        });
      }
    });
  }

  /// Generates Dart source code for test support libraries based on the given AST
  /// represented by [root], outputting the code to [sink]. [sourceOutPath] is the
  /// path of the generated dart code to be tested. [testOutPath] is where the
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
    for (final Api api in root.apis) {
      if (api.location == ApiLocation.host && api.dartHostTestHandler != null) {
        final Api mockApi = Api(
          name: api.dartHostTestHandler!,
          methods: api.methods,
          location: ApiLocation.flutter,
          dartHostTestHandler: api.dartHostTestHandler,
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
      '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, unnecessary_import',
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
    _writeWrapResponse(generatorOptions, root, indent);
  }

  /// Writes [wrapResponse] method.
  void _writeWrapResponse(DartOptions opt, Root root, Indent indent) {
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

  @override
  void writeInstanceManager(
    DartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln(r'''
/// An immutable object that can provide functional copies of itself.
///
/// All implementers are expected to be immutable as defined by the annotation.
@immutable
mixin $Copyable {
  /// Instantiates and returns a functionally identical object to oneself.
  ///
  /// Outside of tests, this method should only ever be called by
  /// [$InstanceManager].
  ///
  /// Subclasses should always override their parent's implementation of this
  /// method.
  @protected
  $Copyable $copy();
}

/// Maintains instances used to communicate with the native objects they
/// represent.
///
/// Added instances are stored as weak references and their copies are stored
/// as strong references to maintain access to their variables and callback
/// methods. Both are stored with the same identifier.
///
/// When a weak referenced instance becomes inaccessible,
/// [onWeakReferenceRemoved] is called with its associated identifier.
///
/// If an instance is retrieved and has the possibility to be used,
/// (e.g. calling [getInstanceWithWeakReference]) a copy of the strong reference
/// is added as a weak reference with the same identifier. This prevents a
/// scenario where the weak referenced instance was released and then later
/// returned by the host platform.
class $InstanceManager {
  /// Constructs an [$InstanceManager].
  $InstanceManager({required void Function(int) onWeakReferenceRemoved}) {
    this.onWeakReferenceRemoved = (int identifier) {
      _weakInstances.remove(identifier);
      onWeakReferenceRemoved(identifier);
    };
    _finalizer = Finalizer<int>(this.onWeakReferenceRemoved);
  }

  // Identifiers are locked to a specific range to avoid collisions with objects
  // created simultaneously by the host platform.
  // Host uses identifiers >= 2^16 and Dart is expected to use values n where,
  // 0 <= n < 2^16.
  static const int _maxDartCreatedIdentifier = 65536;

  static final $InstanceManager instance = _initInstance();

  // Expando is used because it doesn't prevent its keys from becoming
  // inaccessible. This allows the manager to efficiently retrieve an identifier
  // of an instance without holding a strong reference to that instance.
  //
  // It also doesn't use `==` to search for identifiers, which would lead to an
  // infinite loop when comparing an object to its copy. (i.e. which was caused
  // by calling instanceManager.getIdentifier() inside of `==` while this was a
  // HashMap).
  final Expando<int> _identifiers = Expando<int>();
  final Map<int, WeakReference<$Copyable>> _weakInstances =
      <int, WeakReference<$Copyable>>{};
  final Map<int, $Copyable> _strongInstances = <int, $Copyable>{};
  late final Finalizer<int> _finalizer;
  int _nextIdentifier = 0;

  /// Called when a weak referenced instance is removed by [removeWeakReference]
  /// or becomes inaccessible.
  late final void Function(int) onWeakReferenceRemoved;

  static $InstanceManager _initInstance() {
    WidgetsFlutterBinding.ensureInitialized();
    final $InstanceManagerApi api = $InstanceManagerApi();
    // Clears the native `InstanceManager` on the initial use of the Dart one.
    api.clear();
    return $InstanceManager(onWeakReferenceRemoved: (int identifier) {
      api.removeStrongReference(identifier);
    });
  }

  /// Adds a new instance that was instantiated by Dart.
  ///
  /// In other words, Dart wants to add a new instance that will represent
  /// an object that will be instantiated on the host platform.
  ///
  /// Throws assertion error if the instance has already been added.
  ///
  /// Returns the randomly generated id of the [instance] added.
  int addDartCreatedInstance($Copyable instance) {
    final int identifier = _nextUniqueIdentifier();
    _addInstanceWithIdentifier(instance, identifier);
    return identifier;
  }

  /// Removes the instance, if present, and call [onWeakReferenceRemoved] with
  /// its identifier.
  ///
  /// Returns the identifier associated with the removed instance. Otherwise,
  /// `null` if the instance was not found in this manager.
  ///
  /// This does not remove the strong referenced instance associated with
  /// [instance]. This can be done with [remove].
  int? removeWeakReference($Copyable instance) {
    final int? identifier = getIdentifier(instance);
    if (identifier == null) {
      return null;
    }

    _identifiers[instance] = null;
    _finalizer.detach(instance);
    onWeakReferenceRemoved(identifier);

    return identifier;
  }

  /// Removes [identifier] and its associated strongly referenced instance, if
  /// present, from the manager.
  ///
  /// Returns the strong referenced instance associated with [identifier] before
  /// it was removed. Returns `null` if [identifier] was not associated with
  /// any strong reference.
  ///
  /// This does not remove the weak referenced instance associated with
  /// [identifier]. This can be done with [removeWeakReference].
  T? remove<T extends $Copyable>(int identifier) {
    return _strongInstances.remove(identifier) as T?;
  }

  /// Retrieves the instance associated with identifier.
  ///
  /// The value returned is chosen from the following order:
  ///
  /// 1. A weakly referenced instance associated with identifier.
  /// 2. If the only instance associated with identifier is a strongly
  /// referenced instance, a copy of the instance is added as a weak reference
  /// with the same identifier. Returning the newly created copy.
  /// 3. If no instance is associated with identifier, returns null.
  ///
  /// This method also expects the host `InstanceManager` to have a strong
  /// reference to the instance the identifier is associated with.
  T? getInstanceWithWeakReference<T extends $Copyable>(int identifier) {
    final $Copyable? weakInstance = _weakInstances[identifier]?.target;

    if (weakInstance == null) {
      final $Copyable? strongInstance = _strongInstances[identifier];
      if (strongInstance != null) {
        final $Copyable copy = strongInstance.$copy();
        _identifiers[copy] = identifier;
        _weakInstances[identifier] = WeakReference<$Copyable>(copy);
        _finalizer.attach(copy, identifier, detach: copy);
        return copy as T;
      }
      return strongInstance as T?;
    }

    return weakInstance as T;
  }

  /// Retrieves the identifier associated with instance.
  int? getIdentifier($Copyable instance) {
    return _identifiers[instance];
  }

  /// Adds a new instance that was instantiated by the host platform.
  ///
  /// In other words, the host platform wants to add a new instance that
  /// represents an object on the host platform. Stored with [identifier].
  ///
  /// Throws assertion error if the instance or its identifier has already been
  /// added.
  ///
  /// Returns unique identifier of the [instance] added.
  void addHostCreatedInstance($Copyable instance, int identifier) {
    _addInstanceWithIdentifier(instance, identifier);
  }

  void _addInstanceWithIdentifier($Copyable instance, int identifier) {
    assert(!containsIdentifier(identifier));
    assert(getIdentifier(instance) == null);
    assert(identifier >= 0);

    _identifiers[instance] = identifier;
    _weakInstances[identifier] = WeakReference<$Copyable>(instance);
    _finalizer.attach(instance, identifier, detach: instance);

    final $Copyable copy = instance.$copy();
    _identifiers[copy] = identifier;
    _strongInstances[identifier] = copy;
  }

  /// Whether this manager contains the given [identifier].
  bool containsIdentifier(int identifier) {
    return _weakInstances.containsKey(identifier) ||
        _strongInstances.containsKey(identifier);
  }

  int _nextUniqueIdentifier() {
    late int identifier;
    do {
      identifier = _nextIdentifier;
      _nextIdentifier = (_nextIdentifier + 1) % _maxDartCreatedIdentifier;
    } while (containsIdentifier(identifier));
    return identifier;
  }
}    
''');
  }

  @override
  void writeInstanceManagerApi(
    DartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln(
      '/// API for managing the Dart and native `InstanceManager`s.',
    );
    indent.writeScoped(r'class $InstanceManagerApi {', '}', () {
      indent.format(
        '/// Constructor for [\$InstanceManagerApi].\n'
        '///\n'
        '/// The [binaryMessenger] named argument is available for dependency\n'
        '/// injection. If it is left null, the default [BinaryMessenger] will be used\n'
        '/// which routes to the host platform.\n'
        '\$InstanceManagerApi({BinaryMessenger? binaryMessenger})\n'
        '    : _binaryMessenger = binaryMessenger;\n\n'
        'final BinaryMessenger? _binaryMessenger;\n'
        'static const MessageCodec<Object?> codec = StandardMessageCodec();',
      );
      indent.newln();

      indent.writeScoped(
        'static void setUpDartMessageHandlers({',
        '}) ',
        () {
          indent.writeln('BinaryMessenger? binaryMessenger,');
          indent.writeln(r'$InstanceManager? instanceManager,');
        },
        addTrailingNewline: false,
      );
      indent.writeScoped('{', '}', () {
        indent.writeScoped('{', '}', () {
          final String channelName = makeChannelNameWithStrings(
            apiName: r'$InstanceManagerApi',
            methodName: 'removeStrongReference',
            dartPackageName: dartPackageName,
          );
          indent.writeScoped(
            'final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(',
            ');',
            () {
              indent.writeln("r'$channelName',");
              indent.writeln('codec,');
              indent.writeln('binaryMessenger: binaryMessenger,');
            },
          );
          indent.writeScoped(
            'channel.setMessageHandler((Object? message) async {',
            '});',
            () {
              _writeAssert(
                indent,
                assertion: 'message != null',
                errorMessage: 'Argument for $channelName was null.',
                rawErrorMessageString: true,
              );
              indent.writeln('final int? identifier = message as int?;');
              _writeAssert(
                indent,
                assertion: 'identifier != null',
                errorMessage:
                    'Argument for $channelName, expected non-null int.',
                rawErrorMessageString: true,
              );
              indent.writeln(
                r'(instanceManager ?? $InstanceManager.instance).remove(identifier!);',
              );
              indent.writeln('return;');
            },
          );
        });
      });
      indent.newln();

      indent.writeScoped(
        'Future<void> removeStrongReference(int identifier) async {',
        '}',
        () {
          final String channelName = makeChannelNameWithStrings(
            apiName: r'$InstanceManagerApi',
            methodName: 'removeStrongReference',
            dartPackageName: dartPackageName,
          );
          indent.writeScoped(
            'final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(',
            ');',
            () {
              indent.writeln("r'$channelName',");
              indent.writeln('codec,');
              indent.writeln('binaryMessenger: _binaryMessenger,');
            },
          );
          indent.writeln(
            'final List<Object?>? replyList = await channel.send(identifier) as List<Object?>?;',
          );
          indent.writeScoped('if (replyList == null) {', '} ', () {
            indent.writeScoped('throw PlatformException(', ');', () {
              indent.writeln("code: 'channel-error',");
              indent.writeln(
                "message: 'Unable to establish connection on channel.',",
              );
            });
          }, addTrailingNewline: false);
          indent.writeScoped('else if (replyList.length > 1) {', '} ', () {
            indent.writeScoped('throw PlatformException(', ');', () {
              indent.writeln('code: replyList[0]! as String,');
              indent.writeln('message: replyList[1] as String?,');
              indent.writeln('details: replyList[2],');
            });
          }, addTrailingNewline: false);
          indent.writeScoped('else {', '}', () {
            indent.writeln('return;');
          });
        },
      );
      indent.newln();

      indent.format(
        '/// Clear the native `InstanceManager`.\n'
        '///\n'
        '/// This is typically only used after a hot restart.',
      );
      indent.writeScoped('Future<void> clear() async {', '}', () {
        final String channelName = makeChannelNameWithStrings(
          apiName: r'$InstanceManagerApi',
          methodName: 'clear',
          dartPackageName: dartPackageName,
        );
        indent.writeScoped(
          'final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(',
          ');',
          () {
            indent.writeln("r'$channelName',");
            indent.writeln('codec,');
            indent.writeln('binaryMessenger: _binaryMessenger,');
          },
        );
        indent.writeln(
          'final List<Object?>? replyList = await channel.send(null) as List<Object?>?;',
        );
        indent.writeScoped('if (replyList == null) {', '} ', () {
          indent.writeScoped('throw PlatformException(', ');', () {
            indent.writeln("code: 'channel-error',");
            indent.writeln(
              "message: 'Unable to establish connection on channel.',",
            );
          });
        }, addTrailingNewline: false);
        indent.writeScoped('else if (replyList.length > 1) {', '} ', () {
          indent.writeScoped('throw PlatformException(', ');', () {
            indent.writeln('code: replyList[0]! as String,');
            indent.writeln('message: replyList[1] as String?,');
            indent.writeln('details: replyList[2],');
          });
        }, addTrailingNewline: false);
        indent.writeScoped('else {', '}', () {
          indent.writeln('return;');
        });
      });
    });
  }

  @override
  void writeProxyApi(
    DartOptions generatorOptions,
    Root root,
    Indent indent,
    ProxyApiNode api, {
    required String dartPackageName,
  }) {
    final String codecName = _getCodecName(api.name);

    // Write Codec
    indent.writeln('''
class $codecName extends StandardMessageCodec {
 const $codecName(this.instanceManager);

 final \$InstanceManager instanceManager;

 @override
 void writeValue(WriteBuffer buffer, Object? value) {
   if (value is \$Copyable) {
     buffer.putUint8(128);
     writeValue(buffer, instanceManager.getIdentifier(value));
   } else {
     super.writeValue(buffer, value);
   }
 }

 @override
 Object? readValueOfType(int type, ReadBuffer buffer) {
   switch (type) {
     case 128:
       return instanceManager
           .getInstanceWithWeakReference(readValue(buffer)! as int);
     default:
       return super.readValueOfType(type, buffer);
   }
 }
}
''');

    // Methods implemented on the host side.
    final Iterable<Method> hostMethods = api.methods.where(
      (Method method) => method.location == ApiLocation.host,
    );
    // Methods implemented on the Flutter side.
    final Iterable<Method> flutterMethods = api.methods.where(
      (Method method) => method.location == ApiLocation.flutter,
    );

    final Iterable<Field> attachedFields = api.fields.where(
      (Field field) => field.isAttached,
    );
    final Iterable<Field> nonAttachedFields = api.fields.where(
      (Field field) => !field.isAttached,
    );

    final Iterable<ProxyApiNode> allProxyApis =
        root.apis.whereType<ProxyApiNode>();

    final Set<ProxyApiNode> interfacesApis = _recursiveFindAllInterfacesApis(
      api.interfacesNames,
      root.apis.whereType<ProxyApiNode>(),
    );

    final List<Method> interfacesMethods = <Method>[];
    for (final ProxyApiNode proxyApi in interfacesApis) {
      interfacesMethods.addAll(proxyApi.methods);
    }

    final List<ProxyApiNode> superClassApisChain =
        _recursiveGetSuperClassApisChain(
      api,
      allProxyApis,
    );

    ProxyApiNode? superClassApi;
    if (api.superClassName != null) {
      superClassApi = superClassApisChain.first;
    }

    // A list of inherited methods from super classes that constructors set with
    // `super.<methodName`.
    final List<Method> superClassFlutterMethods = <Method>[];
    if (superClassApi != null) {
      for (final ProxyApiNode proxyApi in superClassApisChain) {
        for (final Method method in proxyApi.methods) {
          if (method.location == ApiLocation.flutter) {
            superClassFlutterMethods.add(method);
          }
        }
      }

      final Set<ProxyApiNode> superClassInterfacesApis =
          _recursiveFindAllInterfacesApis(
        superClassApi.interfacesNames,
        allProxyApis,
      );
      for (final ProxyApiNode proxyApi in superClassInterfacesApis) {
        superClassFlutterMethods.addAll(proxyApi.methods);
      }
    }

    final bool hasARequiredFlutterMethod = api.methods
        .followedBy(superClassFlutterMethods)
        .followedBy(interfacesMethods)
        .any((Method method) {
      return method.location == ApiLocation.flutter && method.mustBeImplemented;
    });

    // api class
    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
    );

    String classInheritance = '';
    if (superClassApi == null && interfacesApis.isEmpty) {
      classInheritance = r'implements $Copyable ';
    } else {
      if (superClassApi != null) {
        classInheritance += 'extends ${superClassApi.name} ';
      }
      if (api.interfacesNames.isNotEmpty) {
        classInheritance += 'implements ${api.interfacesNames.join(', ')} ';
      }
    }
    indent.writeScoped('class ${api.name} $classInheritance{', '}', () {
      // constructors
      for (final Constructor constructor in api.constructors) {
        addDocumentationComments(
          indent,
          constructor.documentationComments,
          _docCommentSpec,
        );

        // Prefixes a constructor name with a '.' if the name is not empty.
        final String constructorNameWithDot =
            constructor.name.isEmpty ? '' : '.${constructor.name}';
        indent.writeScoped('${api.name}$constructorNameWithDot({', '}) ', () {
          indent.writeln(
            '${superClassApi != null ? 'super' : 'this'}.\$binaryMessenger,',
          );
          indent.writeln(
            '${superClassApi != null ? 'super.' : r'$InstanceManager? '}\$instanceManager,',
          );

          for (final Field field in nonAttachedFields) {
            indent.writeln(
              '${field.type.isNullable ? '' : 'required '}this.${field.name},',
            );
          }

          for (final Method method in superClassFlutterMethods) {
            indent.writeln(
              '${method.mustBeImplemented ? 'required ' : ''}super.${method.name},',
            );
          }

          for (final Method method in interfacesMethods) {
            indent.writeln(
              '${method.mustBeImplemented ? 'required ' : ''}this.${method.name},',
            );
          }

          for (final Method method in flutterMethods) {
            indent.writeln(
              '${method.mustBeImplemented ? 'required ' : ''}this.${method.name},',
            );
          }

          enumerate(constructor.arguments, (int index, NamedType parameter) {
            indent.writeln(
              '${_asDeclaredParameter(index, parameter, isNamedParameter: true)},',
            );
          });
        }, addTrailingNewline: false);

        final String initializerStatement = superClassApi != null
            ? r'super.$detached()'
            : r'$instanceManager = $instanceManager ?? $InstanceManager.instance';
        indent.addScoped(': $initializerStatement {', '}', () {
          final String channelName = makeChannelNameForConstructor(
            api,
            constructor,
            dartPackageName,
          );
          _writeBasicMessageChannel(
            indent,
            channelName: channelName,
            codecVariableName:
                '$codecName(${superClassApi != null ? '' : 'this.'}\$instanceManager)',
            binaryMessengerVariableName: r'$binaryMessenger',
          );
          indent.writeln(
            'final int instanceIdentifier = ${superClassApi != null ? '' : 'this.'}\$instanceManager.addDartCreatedInstance(this);',
          );

          final List<String> unAttachedFieldNames = _asParameterNamesList(
            nonAttachedFields,
            root.enums,
            getArgumentName: _getArgumentName,
          );
          final List<String> parameterNames = _asParameterNamesList(
            constructor.arguments,
            root.enums,
          );
          final String channelSendNames =
              (unAttachedFieldNames + parameterNames).join(', ');

          indent.writeScoped(
            'channel.send(<Object?>[instanceIdentifier, $channelSendNames]).then<void>((Object? value) {',
            '});',
            () {
              indent.writeln(
                'final List<Object?>? replyList = value as List<Object?>?;',
              );
              indent.writeScoped('if (replyList == null) {', '} ', () {
                indent.writeScoped('throw PlatformException(', ');', () {
                  indent.writeln("code: 'channel-error',");
                  indent.writeln(
                    "message: 'Unable to establish connection on channel.',",
                  );
                });
              }, addTrailingNewline: false);
              indent.writeScoped(
                'else if (replyList.length > 1) {',
                '} ',
                () {
                  indent.writeScoped('throw PlatformException(', ');', () {
                    indent.writeln('code: replyList[0]! as String,');
                    indent.writeln('message: replyList[1] as String?,');
                    indent.writeln('details: replyList[2],');
                  });
                },
              );
            },
          );
        });
      }
      indent.newln();

      indent.format(
        '/// Constructs ${api.name} without creating the associated native object.\n'
        '///\n'
        '/// This should only be used by subclasses created by this library or to\n'
        '/// create copies.',
      );
      indent.writeScoped('${api.name}.\$detached({', '}) ', () {
        indent.writeln(
          '${superClassApi != null ? 'super' : 'this'}.\$binaryMessenger,',
        );
        indent.writeln(
          '${superClassApi != null ? 'super.' : r'$InstanceManager? '}\$instanceManager,',
        );
        for (final Field field in nonAttachedFields) {
          indent.writeln(
            '${field.type.isNullable ? '' : 'required '}this.${field.name},',
          );
        }
        for (final Method method in superClassFlutterMethods) {
          indent.writeln(
            '${method.mustBeImplemented ? 'required ' : ''}super.${method.name},',
          );
        }
        for (final Method method in interfacesMethods) {
          indent.writeln(
            '${method.mustBeImplemented ? 'required ' : ''}this.${method.name},',
          );
        }
        for (final Method method in flutterMethods) {
          indent.writeln(
            '${method.mustBeImplemented ? 'required ' : ''}this.${method.name},',
          );
        }
      }, addTrailingNewline: false);

      final String initializerStatement = superClassApi != null
          ? r'super.$detached()'
          : r'$instanceManager = $instanceManager ?? $InstanceManager.instance';
      indent.writeln(': $initializerStatement;');
      indent.newln();

      // callback methods
      indent.writeScoped('static void setUpDartMessageHandlers ({', '})', () {
        indent.writeln(r'BinaryMessenger? $binaryMessenger,');
        indent.writeln(r'$InstanceManager? $instanceManager,');

        if (!hasARequiredFlutterMethod) {
          final String nonAttachedFieldsSignature = _getParametersSignature(
            nonAttachedFields.toList(),
            _getArgumentName,
          );
          indent.writeln(
            '${api.name} Function($nonAttachedFieldsSignature)? \$detached,',
          );
        }

        for (final Method method in flutterMethods) {
          final bool isAsync = method.isAsynchronous;
          final String returnType = isAsync
              ? 'Future<${_addGenericTypesNullable(method.returnType)}>'
              : _addGenericTypesNullable(method.returnType);
          final String argSignature = _getMethodArgumentsSignature(
            method,
            _getArgumentName,
          );
          indent.writeln(
            '$returnType Function(${api.name} instance, $argSignature)? ${method.name},',
          );
        }
      }, addTrailingNewline: false);

      final List<String> customEnumNames =
          root.enums.map((Enum x) => x.name).toList();
      indent.writeScoped('{', '}', () {
        if (!hasARequiredFlutterMethod) {
          indent.writeScoped('{', '}', () {
            final String channelName = makeChannelNameWithStrings(
              apiName: api.name,
              methodName: r'$detached',
              dartPackageName: dartPackageName,
            );
            _writeBasicMessageChannel(
              indent,
              channelName: channelName,
              codecVariableName:
                  '$codecName(\$instanceManager ?? \$InstanceManager.instance)',
              binaryMessengerVariableName: r'$binaryMessenger',
            );

            indent.writeScoped(
              'channel.setMessageHandler((Object? message) async {',
              '});',
              () {
                const String argsArray = 'args';

                _writeAssert(
                  indent,
                  assertion: 'message != null',
                  errorMessage: 'Argument for $channelName was null.',
                  rawErrorMessageString: true,
                );
                indent.writeln(
                  'final List<Object?> $argsArray = (message as List<Object?>?)!;',
                );
                indent.writeln(
                  'final int? instanceIdentifier = (args[0] as int?);',
                );
                _writeAssert(
                  indent,
                  assertion: 'instanceIdentifier != null',
                  errorMessage:
                      'Argument for $channelName was null, expected non-null int.',
                  rawErrorMessageString: true,
                );

                late Iterable<String> argsNames;
                if (nonAttachedFields.isEmpty) {
                  argsNames = <String>[];
                } else {
                  enumerate(nonAttachedFields, (int index, NamedType field) {
                    _writeMessageArgumentVariable(
                      indent,
                      // The calling instance is the first arg.
                      index + 1,
                      field,
                      channelName: channelName,
                      customEnumNames: customEnumNames,
                    );
                  });
                  argsNames =
                      indexMap(nonAttachedFields, (int index, NamedType field) {
                    // The calling instance is the first arg.
                    final String name = _getSafeArgumentName(index + 1, field);
                    return '$name${field.type.isNullable ? '' : '!'}';
                  });
                }

                indent.writeScoped(
                  r'($instanceManager ?? $InstanceManager.instance).addHostCreatedInstance(',
                  ');',
                  () {
                    indent.writeScoped(
                      '\$detached?.call(${argsNames.join(', ')}) ?? ${api.name}.\$detached(',
                      '),',
                      () {
                        indent.writeln(r'$binaryMessenger: $binaryMessenger,');
                        indent.writeln(r'$instanceManager: $instanceManager,');
                        enumerate(
                          nonAttachedFields,
                          (int index, NamedType field) {
                            indent.writeln(
                              '${field.name}: ${_getSafeArgumentName(index + 1, field)}${field.type.isNullable ? '' : '!'},',
                            );
                          },
                        );
                      },
                    );
                    indent.writeln('instanceIdentifier!,');
                  },
                );
                indent.writeln('return;');
              },
            );
          });
        }

        for (final Method method in flutterMethods) {
          indent.writeScoped('{', '}', () {
            final String channelName =
                makeChannelName(api, method, dartPackageName);
            _writeBasicMessageChannel(
              indent,
              channelName: channelName,
              codecVariableName:
                  '$codecName(\$instanceManager ?? \$InstanceManager.instance)',
              binaryMessengerVariableName: r'$binaryMessenger',
            );
            indent.writeScoped(
              'channel.setMessageHandler((Object? message) async {',
              '});',
              () {
                final String returnType =
                    _addGenericTypesNullable(method.returnType);
                final bool isAsync = method.isAsynchronous;

                _writeAssert(
                  indent,
                  assertion: 'message != null',
                  errorMessage: 'Argument for $channelName was null.',
                );

                // TODO: global constant argsArrayVariableName
                const String argsArray = 'args';

                indent.writeln(
                  'final List<Object?> $argsArray = (message as List<Object?>?)!;',
                );
                indent.writeln(
                  'final ${api.name}? instance = (args[0] as ${api.name}?);',
                );
                _writeAssert(
                  indent,
                  assertion: 'instance != null',
                  errorMessage:
                      'Argument for $channelName was null, expected non-null ${api.name}.',
                );

                late final Iterable<String> argsNames;
                if (method.arguments.isEmpty) {
                  argsNames = <String>[];
                } else {
                  enumerate(method.arguments, (int index, NamedType parameter) {
                    _writeMessageArgumentVariable(
                      indent,
                      // The calling instance is the first arg.
                      index + 1,
                      parameter,
                      customEnumNames: customEnumNames,
                      channelName: channelName,
                    );
                  });
                  argsNames = indexMap(
                    method.arguments,
                    (int index, NamedType field) {
                      // The calling instance is the first arg.
                      final String name = _getSafeArgumentName(
                        index + 1,
                        field,
                      );
                      return '$name${field.type.isNullable ? '' : '!'}';
                    },
                  );
                }
                final String call =
                    '(${method.name} ?? instance!.${method.name})${method.mustBeImplemented ? '' : '?'}.call(instance!, ${argsNames.join(', ')})';

                indent.writeScoped('try {', '} ', () {
                  if (method.returnType.isVoid) {
                    if (isAsync) {
                      indent.writeln('await $call;');
                    } else {
                      indent.writeln('$call;');
                    }
                    indent.writeln('return wrapResponse(empty: true);');
                  } else {
                    if (isAsync) {
                      indent.writeln('final $returnType output = await $call;');
                    } else {
                      indent.writeln('final $returnType output = $call;');
                    }

                    final String nullability =
                        method.returnType.isNullable ? '?' : '';
                    final String valueExtraction =
                        isEnum(root, method.returnType)
                            ? '$nullability.index'
                            : '';
                    indent.writeln(
                      'return wrapResponse(result: output$valueExtraction);',
                    );
                  }
                }, addTrailingNewline: false);
                indent.writeScoped('on PlatformException catch (e) {', '}', () {
                  indent.writeln('return wrapResponse(error: e);');
                }, addTrailingNewline: false);
                indent.writeScoped('catch (e) {', '}', () {
                  indent.writeln(
                    "return wrapResponse(error: PlatformException(code: 'error', message: e.toString()),);",
                  );
                });
              },
            );
          });
        }
      });
      indent.newln();

      // fields
      if (superClassApi == null) {
        indent.format(
          '/// Sends and receives binary data across the Flutter platform barrier.\n'
          '///\n'
          '/// If it is null, the default BinaryMessenger will be used, which routes to\n'
          '/// the host platform.',
        );
        if (superClassApi == null && interfacesApis.isNotEmpty) {
          indent.writeln('@override');
        }
        indent.writeln(r'final BinaryMessenger? $binaryMessenger;');
        indent.newln();

        indent.format(
          '/// Maintains instances stored to communicate with native language objects.',
        );
        if (superClassApi == null && interfacesApis.isNotEmpty) {
          indent.writeln('@override');
        }
        indent.writeln(r'final $InstanceManager $instanceManager;');
        indent.newln();
      }
      for (final Field field in nonAttachedFields) {
        addDocumentationComments(
          indent,
          field.documentationComments,
          _docCommentSpec,
        );
        indent.writeln(
          'final ${_addGenericTypesNullable(field.type)} ${field.name};',
        );
      }
      for (final ProxyApiNode proxyApi in interfacesApis) {
        for (final Method method in proxyApi.methods) {
          final String returnType = method.isAsynchronous
              ? 'Future<${_addGenericTypesNullable(method.returnType)}>'
              : _addGenericTypesNullable(method.returnType);
          final String argSignature = _getMethodArgumentsSignature(
            method,
            _getArgumentName,
          );
          addDocumentationComments(
            indent,
            method.documentationComments,
            _docCommentSpec,
          );
          indent.writeln('@override');
          indent.writeln(
            'final $returnType Function(${proxyApi.name} instance, $argSignature)${method.mustBeImplemented ? '' : '?'} ${method.name};',
          );
        }
      }
      for (final Method method in flutterMethods) {
        final String returnType = method.isAsynchronous
            ? 'Future<${_addGenericTypesNullable(method.returnType)}>'
            : _addGenericTypesNullable(method.returnType);
        final String argSignature = _getMethodArgumentsSignature(
          method,
          _getArgumentName,
        );
        addDocumentationComments(
          indent,
          method.documentationComments,
          _docCommentSpec,
        );
        indent.writeln(
          'final $returnType Function(${api.name} instance, $argSignature)${method.mustBeImplemented ? '' : '?'} ${method.name};',
        );
      }
      indent.newln();

      // attached fields
      for (final Field field in attachedFields) {
        addDocumentationComments(
          indent,
          field.documentationComments,
          _docCommentSpec,
        );

        final String type = _addGenericTypesNullable(field.type);
        indent.writeln(
            '${field.isStatic ? 'static' : 'late'} final $type ${field.name} = _${field.name}();');
        indent.writeScoped(
          '${field.isStatic ? 'static ' : ''}$type _${field.name}() {',
          '}',
          () {
            indent.writeScoped(
              'final $type instance = $type.\$detached(',
              ');',
              () {
                if (!field.isStatic) {
                  indent.writeln(r'binaryMessenger: $binaryMessenger,');
                  indent.writeln(r'instanceManager: $instanceManager,');
                }
              },
            );

            final String channelName = makeChannelNameForField(
              api,
              field,
              dartPackageName,
            );
            indent.writeScoped(
              'final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(',
              ');',
              () {
                indent.writeln("r'$channelName',");
                indent.writeln(
                    '$codecName(${field.isStatic ? r'$InstanceManager.instance' : r'$instanceManager'}),');
                if (!field.isStatic) {
                  indent.writeln(
                    r'binaryMessenger: $binaryMessenger,',
                  );
                }
              },
            );

            indent.writeln(
              'final int instanceIdentifier = ${field.isStatic ? r'$InstanceManager.instance' : r'$instanceManager'}.addDartCreatedInstance(instance);',
            );
            indent.writeScoped(
              'channel.send(<Object?>[${field.isStatic ? '' : 'this, '}instanceIdentifier]).then<void>((Object? value) {',
              '});',
              () {
                indent.writeln(
                  'final List<Object?>? replyList = value as List<Object?>?;',
                );
                indent.writeScoped('if (replyList == null) {', '} ', () {
                  indent.writeScoped('throw PlatformException(', ');', () {
                    indent.writeln("code: 'channel-error',");
                    indent.writeln(
                      "message: 'Unable to establish connection on channel.',",
                    );
                  });
                }, addTrailingNewline: false);
                indent.writeScoped('else if (replyList.length > 1) {', '} ',
                    () {
                  indent.writeScoped('throw PlatformException(', ');', () {
                    indent.writeln('code: replyList[0]! as String,');
                    indent.writeln('message: replyList[1] as String?,');
                    indent.writeln('details: replyList[2],');
                  });
                });
              },
            );

            indent.writeln('return instance;');
          },
        );
      }

      for (final Method method in hostMethods) {
        addDocumentationComments(
          indent,
          method.documentationComments,
          _docCommentSpec,
        );

        final String staticKeyword = method.isStatic ? 'static ' : '';
        final String returnType = _addGenericTypesNullable(method.returnType);
        final String methodParamsSignature = _getMethodArgumentsSignature(
          method,
          _getSafeArgumentName,
        );
        final String messengerAndManager = method.isStatic
            ? '${method.arguments.isEmpty ? '' : ', '}{BinaryMessenger? \$binaryMessenger, \$InstanceManager? \$instanceManager,}'
            : '';
        indent.writeScoped(
          '${staticKeyword}Future<$returnType> ${method.name}($methodParamsSignature$messengerAndManager) async {',
          '}',
          () {
            final String channelName = makeChannelName(
              api,
              method,
              dartPackageName,
            );
            _writeBasicMessageChannel(
              indent,
              channelName: channelName,
              codecVariableName:
                  '$codecName(\$instanceManager${method.isStatic ? r' ?? $InstanceManager.instance' : ''})',
              binaryMessengerVariableName: r'$binaryMessenger',
            );

            final String sendMessageArgsNames =
                _asParameterNamesList(method.arguments, root.enums).join(', ');
            indent.writeln('final List<Object?>? replyList =');
            indent.nest(2, () {
              indent.writeln(
                'await channel.send(<Object?>[${method.isStatic ? '' : 'this, '}$sendMessageArgsNames]) as List<Object?>?;',
              );
            });
            indent.writeScoped('if (replyList == null) {', '} ', () {
              indent.writeScoped('throw PlatformException(', ');', () {
                indent.writeln("code: 'channel-error',");
                indent.writeln(
                  "message: 'Unable to establish connection on channel.',",
                );
              });
            }, addTrailingNewline: false);
            indent.writeScoped('else if (replyList.length > 1) {', '} ', () {
              indent.writeScoped('throw PlatformException(', ');', () {
                indent.writeln('code: replyList[0]! as String,');
                indent.writeln('message: replyList[1] as String?,');
                indent.writeln('details: replyList[2],');
              });
            }, addTrailingNewline: false);
            // On iOS we can return nil from functions to accommodate error
            // handling.  Returning a nil value and not returning an error is an
            // exception.
            if (!method.returnType.isNullable && !method.returnType.isVoid) {
              indent.writeScoped('else if (replyList[0] == null) {', '} ', () {
                indent.writeScoped('throw PlatformException(', ');', () {
                  indent.writeln("code: 'null-error',");
                  indent.writeln(
                    "message: 'Host platform returned null value for non-null return value.',",
                  );
                });
              }, addTrailingNewline: false);
            }
            indent.writeScoped('else {', '}', () {
              _writeHostReturnStatement(
                indent,
                method.returnType,
                customEnumNames: customEnumNames,
              );
            });
          },
        );
      }

      // copy method
      indent.writeln('@override');
      indent.writeScoped('${api.name} \$copy() {', '}', () {
        indent.writeScoped('return ${api.name}.\$detached(', ');', () {
          indent.writeln(r'$binaryMessenger: $binaryMessenger,');
          indent.writeln(r'$instanceManager: $instanceManager,');
          for (final Field field in nonAttachedFields) {
            indent.writeln('${field.name}: ${field.name},');
          }
          for (final Method method in superClassFlutterMethods) {
            indent.writeln('${method.name}: ${method.name},');
          }
          for (final ProxyApiNode proxyApi in interfacesApis) {
            for (final Method method in proxyApi.methods) {
              indent.writeln('${method.name}: ${method.name},');
            }
          }
          for (final Method method in flutterMethods) {
            indent.writeln('${method.name}: ${method.name},');
          }
        });
      });
    });
  }
}

String _escapeForDartSingleQuotedString(String raw) {
  return raw
      .replaceAll(r'\', r'\\')
      .replaceAll(r'$', r'\$')
      .replaceAll(r"'", r"\'");
}

/// Calculates the name of the codec class that will be generated for [api].
String _getCodecName(String apiName) => '_${apiName}Codec';

/// Writes the codec that will be used by [api].
/// Example:
///
/// class FooCodec extends StandardMessageCodec {...}
void _writeCodec(Indent indent, String codecName, Api api, Root root) {
  assert(getCodecClasses(api, root).isNotEmpty);
  final Iterable<EnumeratedClass> codecClasses = getCodecClasses(api, root);
  indent.newln();
  indent.write('class $codecName extends $_standardMessageCodec');
  indent.addScoped(' {', '}', () {
    indent.writeln('const $codecName();');
    indent.writeln('@override');
    indent.write('void writeValue(WriteBuffer buffer, Object? value) ');
    indent.addScoped('{', '}', () {
      enumerate(codecClasses, (int index, final EnumeratedClass customClass) {
        final String ifValue = 'if (value is ${customClass.name}) ';
        if (index == 0) {
          indent.write('');
        }
        indent.add(ifValue);
        indent.addScoped('{', '} else ', () {
          indent.writeln('buffer.putUint8(${customClass.enumeration});');
          indent.writeln('writeValue(buffer, value.encode());');
        }, addTrailingNewline: false);
      });
      indent.addScoped('{', '}', () {
        indent.writeln('super.writeValue(buffer, value);');
      });
    });
    indent.newln();
    indent.writeln('@override');
    indent.write('Object? readValueOfType(int type, ReadBuffer buffer) ');
    indent.addScoped('{', '}', () {
      indent.write('switch (type) ');
      indent.addScoped('{', '}', () {
        for (final EnumeratedClass customClass in codecClasses) {
          indent.writeln('case ${customClass.enumeration}: ');
          indent.nest(1, () {
            indent.writeln(
                'return ${customClass.name}.decode(readValue(buffer)!);');
          });
        }
        indent.writeln('default:');
        indent.nest(1, () {
          indent.writeln('return super.readValueOfType(type, buffer);');
        });
      });
    });
  });
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

/// Generates an argument name if one isn't defined.
String _getArgumentName(int count, NamedType field) =>
    field.name.isEmpty ? 'arg$count' : field.name;

/// Generates the arguments code for [func]
/// Example: (func, getArgumentName) -> 'String? foo, int bar'
String _getMethodArgumentsSignature(
  Method func,
  String Function(int index, NamedType arg) getArgumentName,
) {
  return _getParametersSignature(func.arguments, getArgumentName);
}

String _getParametersSignature(
  List<NamedType> parameters,
  String Function(int index, NamedType arg) getParameterName,
) {
  return parameters.isEmpty
      ? ''
      : indexMap(parameters, (int index, NamedType arg) {
          final String type = _addGenericTypesNullable(arg.type);
          final String argName = getParameterName(index, arg);
          return '$type $argName';
        }).join(', ');
}

/// Converts a type to a declared parameter of a method/constructor.
///
/// ${isNamedParameter && isNonnull ? 'required' : ''} MyType myParameter
String _asDeclaredParameter(
  int index,
  NamedType parameter, {
  bool isNamedParameter = false,
  String Function(int index, NamedType arg) getArgumentName =
      _getSafeArgumentName,
}) {
  final String type = _addGenericTypesNullable(parameter.type);
  final String argName = getArgumentName(index, parameter);
  final String required =
      !parameter.type.isNullable && isNamedParameter ? 'required' : '';
  return '$required $type $argName';
}

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in Dart code.
String _flattenTypeArguments(List<TypeDeclaration> args) {
  return args
      .map<String>((TypeDeclaration arg) => arg.typeArguments.isEmpty
          ? '${arg.baseName}?'
          : '${arg.baseName}<${_flattenTypeArguments(arg.typeArguments)}>?')
      .join(', ');
}

/// Creates the type declaration for use in Dart code from a [NamedType] making sure
/// that type arguments are used for primitive generic types.
String _addGenericTypes(TypeDeclaration type) {
  final List<TypeDeclaration> typeArguments = type.typeArguments;
  switch (type.baseName) {
    case 'List':
      return (typeArguments.isEmpty)
          ? 'List<Object?>'
          : 'List<${_flattenTypeArguments(typeArguments)}>';
    case 'Map':
      return (typeArguments.isEmpty)
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

/// Write an assertion.
///
/// ```
/// assert(
///   $assertion,
///   ${rawErrorMessageString ? r : ''}'$errorMessage',
/// );
/// ```
void _writeAssert(
  Indent indent, {
  required String assertion,
  required String errorMessage,
  bool rawErrorMessageString = false,
}) {
  indent.writeScoped('assert(', ');', () {
    indent.writeln('$assertion,');
    indent.writeln("${rawErrorMessageString ? 'r' : ''}'$errorMessage',");
  });
}

void _writeBasicMessageChannel(
  Indent indent, {
  required String channelName,
  String codecVariableName = 'codec',
  String binaryMessengerVariableName = 'binaryMessenger',
}) {
  indent.writeScoped(
    'final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(',
    ');',
    () {
      indent.writeln("r'$channelName',");
      indent.writeln('$codecVariableName,');
      indent.writeln('binaryMessenger: $binaryMessengerVariableName,');
    },
  );
}

/// Create a list of parameter names from a list of of parameters.
///
/// Converts enums to use their index.
///
/// ```dart
/// apple, banana, myEnum${type.isNullable : '?' : ''}.index
/// ```
List<String> _asParameterNamesList(
  Iterable<NamedType> parameters,
  List<Enum> enums, {
  String Function(int index, NamedType arg) getArgumentName =
      _getSafeArgumentName,
}) {
  final List<String> names = <String>[];
  enumerate(parameters, (int index, NamedType type) {
    final String name = getArgumentName(index, type);
    if (enums.map((Enum e) => e.name).contains(type.type.baseName)) {
      names.add('$name${type.type.isNullable ? '?' : ''}.index');
    } else {
      names.add(name);
    }
  });
  return names;
}

/// return (replyList[0] as String?)!;
void _writeHostReturnStatement(
  Indent indent,
  TypeDeclaration returnType, {
  required List<String> customEnumNames,
}) {
  final String type = _makeGenericTypeArguments(returnType);
  final String genericCastCall = _makeGenericCastCall(returnType);
  const String accessor = 'replyList[0]';
  // Avoid warnings from pointlessly casting to `Object?`.
  final String nullablyTypedAccessor =
      type == 'Object' ? accessor : '($accessor as $type?)';
  final String nullHandler =
      returnType.isNullable ? (genericCastCall.isEmpty ? '' : '?') : '!';
  String returnStatement = 'return';
  if (customEnumNames.contains(type)) {
    if (returnType.isNullable) {
      returnStatement =
          '$returnStatement ($accessor as int?) == null ? null : $type.values[$accessor! as int]';
    } else {
      returnStatement = '$returnStatement $type.values[$accessor! as int]';
    }
  } else if (!returnType.isVoid) {
    returnStatement =
        '$returnStatement $nullablyTypedAccessor$nullHandler$genericCastCall';
  }
  indent.writeln('$returnStatement;');
}

/// final <type> <name> = (<argsVariableName>[<index>] as <type>);
void _writeMessageArgumentVariable(
  Indent indent,
  int index,
  NamedType parameter, {
  required List<String> customEnumNames,
  required String channelName,
  String argsVariableName = 'args',
}) {
  final String argType = _addGenericTypes(parameter.type);
  final String argName = _getSafeArgumentName(index, parameter);
  final String genericArgType = _makeGenericTypeArguments(parameter.type);
  final String castCall = _makeGenericCastCall(parameter.type);

  final String leftHandSide = 'final $argType? $argName';
  if (customEnumNames.contains(parameter.type.baseName)) {
    indent.writeln(
      '$leftHandSide = $argsVariableName[$index] == null ? null : $argType.values[$argsVariableName[$index]! as int];',
    );
  } else {
    indent.writeln(
      '$leftHandSide = ($argsVariableName[$index] as $genericArgType?)${castCall.isEmpty ? '' : '?$castCall'};',
    );
  }

  if (!parameter.type.isNullable) {
    _writeAssert(
      indent,
      assertion: '$argName != null',
      errorMessage:
          'Argument for $channelName was null, expected non-null $argType.',
      rawErrorMessageString: true,
    );
  }
}

/// Recursively search for all the interfaces apis from a list of names of
/// interfaces.
Set<ProxyApiNode> _recursiveFindAllInterfacesApis(
  Set<String> interfaces,
  Iterable<ProxyApiNode> allProxyApis,
) {
  final Set<ProxyApiNode> interfacesApis = <ProxyApiNode>{};

  for (final ProxyApiNode proxyApi in allProxyApis) {
    if (interfaces.contains(proxyApi.name)) {
      interfacesApis.add(proxyApi);
    }
  }

  for (final ProxyApiNode proxyApi in Set<ProxyApiNode>.from(interfacesApis)) {
    interfacesApis.addAll(
      _recursiveFindAllInterfacesApis(proxyApi.interfacesNames, allProxyApis),
    );
  }

  return interfacesApis;
}

/// Recursively find super classes a place them in order in a list.
List<ProxyApiNode> _recursiveGetSuperClassApisChain(
  ProxyApiNode proxyApi,
  Iterable<ProxyApiNode> allProxyApis,
) {
  final List<ProxyApiNode> proxyApis = <ProxyApiNode>[];

  String? currentProxyApiName = proxyApi.superClassName;
  while (currentProxyApiName != null) {
    ProxyApiNode? nextProxyApi;
    for (final ProxyApiNode node in allProxyApis) {
      if (currentProxyApiName == node.name) {
        nextProxyApi = node;
        proxyApis.add(node);
      }
    }

    currentProxyApiName = nextProxyApi?.superClassName;
  }

  return proxyApis;
}

/// Converts [inputPath] to a posix absolute path.
String _posixify(String inputPath) {
  final path.Context context = path.Context(style: path.Style.posix);
  return context.fromUri(path.toUri(path.absolute(inputPath)));
}
