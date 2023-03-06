// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Directory, File, FileSystemEntity;

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

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
      DartOptions generatorOptions, Root root, Indent indent) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln(
      '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import',
    );
    indent.newln();
  }

  @override
  void writeFileImports(
      DartOptions generatorOptions, Root root, Indent indent) {
    indent.writeln("import 'dart:async';");
    indent.writeln(
      "import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;",
    );
    indent.newln();
    indent.writeln(
        "import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;");
    indent.writeln("import 'package:flutter/services.dart';");
  }

  @override
  void writeEnum(
      DartOptions generatorOptions, Root root, Indent indent, Enum anEnum) {
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
      DartOptions generatorOptions, Root root, Indent indent, Class klass) {
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
      writeClassEncode(generatorOptions, root, indent, klass, customClassNames,
          customEnumNames);
      indent.newln();
      writeClassDecode(generatorOptions, root, indent, klass, customClassNames,
          customEnumNames);
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
    Set<String> customEnumNames,
  ) {
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
    Set<String> customEnumNames,
  ) {
    void writeValueDecode(NamedType field, int index) {
      final String resultAt = 'result[$index]';
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
        final String genericType = _makeGenericTypeArguments(field.type);
        final String castCall = _makeGenericCastCall(field.type);
        final String castCallPrefix = field.type.isNullable ? '?' : '!';
        indent.add(
          '($resultAt as $genericType?)$castCallPrefix$castCall',
        );
      } else {
        final String genericdType = _addGenericTypesNullable(field.type);
        if (field.type.isNullable) {
          indent.add(
            '$resultAt as $genericdType',
          );
        } else {
          indent.add(
            '$resultAt! as $genericdType',
          );
        }
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
  }) {
    assert(api.location == ApiLocation.flutter);
    final List<String> customEnumNames =
        root.enums.map((Enum x) => x.name).toList();
    String codecName = _standardMessageCodec;
    if (getCodecClasses(api, root).isNotEmpty) {
      codecName = _getCodecName(api);
      _writeCodec(indent, codecName, api, root);
    }
    indent.newln();
    addDocumentationComments(
        indent, api.documentationComments, _docCommentSpec);

    indent.write('abstract class ${api.name} ');
    indent.addScoped('{', '}', () {
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
                ? makeChannelName(api, func)
                : channelNameFunc(func);
            indent.nest(2, () {
              indent.writeln("'$channelName', codec,");
              indent.writeln(
                'binaryMessenger: binaryMessenger);',
              );
            });
            final String messageHandlerSetter =
                isMockHandler ? 'setMockMessageHandler' : 'setMessageHandler';
            indent.write('if (api == null) ');
            indent.addScoped('{', '}', () {
              indent.writeln('channel.$messageHandlerSetter(null);');
            }, addTrailingNewline: false);
            indent.add(' else ');
            indent.addScoped('{', '}', () {
              indent.write(
                'channel.$messageHandlerSetter((Object? message) async ',
              );
              indent.addScoped('{', '});', () {
                final String returnType =
                    _addGenericTypesNullable(func.returnType);
                final bool isAsync = func.isAsynchronous;
                final String emptyReturnStatement = isMockHandler
                    ? 'return <Object?>[];'
                    : func.returnType.isVoid
                        ? 'return;'
                        : 'return null;';
                String call;
                if (func.arguments.isEmpty) {
                  indent.writeln('// ignore message');
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
                          '$leftHandSide = $argsArray[$count] == null ? null : $argType.values[$argsArray[$count] as int];');
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
                  final String returnStatement = isMockHandler
                      ? 'return <Object?>[$returnExpression];'
                      : 'return $returnExpression;';
                  indent.writeln(returnStatement);
                }
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
  /// If the message recieved was succesful,
  /// the result will be contained at the 0'th index.
  ///
  /// If the message was a failure, the list will contain 3 items:
  /// a code, a message, and details in that order.
  @override
  void writeHostApi(
      DartOptions generatorOptions, Root root, Indent indent, Api api) {
    assert(api.location == ApiLocation.host);
    String codecName = _standardMessageCodec;
    if (getCodecClasses(api, root).isNotEmpty) {
      codecName = _getCodecName(api);
      _writeCodec(indent, codecName, api, root);
    }
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
          final String channelName = makeChannelName(api, func);
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
          final String returnStatement = func.returnType.isVoid
              ? 'return;'
              : 'return $nullablyTypedAccessor$nullHandler$genericCastCall;';
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
  void generateTest(DartOptions generatorOptions, Root root, StringSink sink) {
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
    late final String? packageName = _deducePackageName(sourceOutPath);
    if (!relativeDartPath.contains('/lib/') || packageName == null) {
      // If we can't figure out the package name or the relative path doesn't
      // include a 'lib' directory, try relative path import which only works in
      // certain (older) versions of Dart.
      // TODO(gaaclarke): We should add a command-line parameter to override this import.
      indent.writeln(
          "import '${_escapeForDartSingleQuotedString(relativeDartPath)}';");
    } else {
      final String path =
          relativeDartPath.replaceFirst(RegExp(r'^.*/lib/'), '');
      indent.writeln("import 'package:$packageName/$path';");
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
          channelNameFunc: (Method func) => makeChannelName(api, func),
          isMockHandler: true,
        );
      }
    }
  }

  /// Writes file header to sink.
  void _writeTestPrologue(DartOptions opt, Root root, Indent indent) {
    if (opt.copyrightHeader != null) {
      addLines(indent, opt.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
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
}

String _escapeForDartSingleQuotedString(String raw) {
  return raw
      .replaceAll(r'\', r'\\')
      .replaceAll(r'$', r'\$')
      .replaceAll(r"'", r"\'");
}

/// Calculates the name of the codec class that will be generated for [api].
String _getCodecName(Api api) => '_${api.name}Codec';

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
  return func.arguments.isEmpty
      ? ''
      : indexMap(func.arguments, (int index, NamedType arg) {
          final String type = _addGenericTypesNullable(arg.type);
          final String argName = getArgumentName(index, arg);
          return '$type $argName';
        }).join(', ');
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
  final String genericdType = _addGenericTypes(type);
  return type.isNullable ? '$genericdType?' : genericdType;
}

/// Crawls up the path of [dartFilePath] until it finds a pubspec.yaml in a
/// parent directory and returns its path.
String? _findPubspecPath(String dartFilePath) {
  try {
    Directory dir = File(dartFilePath).parent;
    String? pubspecPath;
    while (pubspecPath == null) {
      if (dir.existsSync()) {
        final Iterable<String> pubspecPaths = dir
            .listSync()
            .map((FileSystemEntity e) => e.path)
            .where((String path) => path.endsWith('pubspec.yaml'));
        if (pubspecPaths.isNotEmpty) {
          pubspecPath = pubspecPaths.first;
        } else {
          dir = dir.parent;
        }
      } else {
        break;
      }
    }
    return pubspecPath;
  } catch (ex) {
    return null;
  }
}

/// Given the path of a Dart file, [mainDartFile], the name of the package will
/// be deduced by locating and parsing its associated pubspec.yaml.
String? _deducePackageName(String mainDartFile) {
  final String? pubspecPath = _findPubspecPath(mainDartFile);
  if (pubspecPath == null) {
    return null;
  }

  try {
    final String text = File(pubspecPath).readAsStringSync();
    return (yaml.loadYaml(text) as Map<dynamic, dynamic>)['name'] as String?;
  } catch (_) {
    return null;
  }
}

/// Converts [inputPath] to a posix absolute path.
String _posixify(String inputPath) {
  final path.Context context = path.Context(style: path.Style.posix);
  return context.fromUri(path.toUri(path.absolute(inputPath)));
}
