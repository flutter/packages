// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
import 'generator_tools.dart';

/// Options that control how Dart code will be generated.
class DartOptions {
  /// Constructor for DartOptions.
  const DartOptions({this.isNullSafe = true, this.copyrightHeader});

  /// Determines if the generated code has null safety annotations (Dart >=2.12 required).
  final bool isNullSafe;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Creates a [DartOptions] from a Map representation where:
  /// `x = DartOptions.fromMap(x.toMap())`.
  static DartOptions fromMap(Map<String, Object> map) {
    final Iterable<dynamic>? copyrightHeader =
        map['copyrightHeader'] as Iterable<dynamic>?;
    return DartOptions(
      isNullSafe: map['isNullSafe'] as bool? ?? true,
      copyrightHeader: copyrightHeader?.cast<String>(),
    );
  }

  /// Converts a [DartOptions] to a Map representation where:
  /// `x = DartOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (isNullSafe != null) 'isNullSafe': isNullSafe,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [DartOptions].
  DartOptions merge(DartOptions options) {
    return DartOptions.fromMap(mergeMaps(toMap(), options.toMap()));
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
  indent.write('class $codecName extends StandardMessageCodec ');
  indent.scoped('{', '}', () {
    indent.writeln('const $codecName();');
    if (getCodecClasses(api, root).isNotEmpty) {
      indent.writeln('@override');
      indent.write('void writeValue(WriteBuffer buffer, Object? value) ');
      indent.scoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          indent.write('if (value is ${customClass.name}) ');
          indent.scoped('{', '} else ', () {
            indent.writeln('buffer.putUint8(${customClass.enumeration});');
            indent.writeln('writeValue(buffer, value.encode());');
          });
        }
        indent.scoped('{', '}', () {
          indent.writeln('super.writeValue(buffer, value);');
        });
      });
      indent.writeln('@override');
      indent.write('Object? readValueOfType(int type, ReadBuffer buffer) ');
      indent.scoped('{', '}', () {
        indent.write('switch (type) ');
        indent.scoped('{', '}', () {
          for (final EnumeratedClass customClass
              in getCodecClasses(api, root)) {
            indent.write('case ${customClass.enumeration}: ');
            indent.writeScoped('', '', () {
              indent.writeln(
                  'return ${customClass.name}.decode(readValue(buffer)!);');
            });
          }
          indent.write('default:');
          indent.writeScoped('', '', () {
            indent.writeln('return super.readValueOfType(type, buffer);');
          });
        });
      });
    }
  });
}

/// Creates a Dart type where all type arguments are [Objects].
String _makeGenericTypeArguments(TypeDeclaration type, String nullTag) {
  return type.typeArguments.isNotEmpty
      ? '${type.baseName}<${type.typeArguments.map<String>((TypeDeclaration e) => 'Object$nullTag').join(', ')}>'
      : _addGenericTypes(type, nullTag);
}

/// Creates a `.cast<>` call for an type. Returns an empty string if the
/// type has no type arguments.
String _makeGenericCastCall(TypeDeclaration type, String nullTag) {
  return type.typeArguments.isNotEmpty
      ? '.cast<${_flattenTypeArguments(type.typeArguments, nullTag)}>()'
      : '';
}

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType field) =>
    field.name.isEmpty ? 'arg$count' : 'arg_' + field.name;

/// Generates an argument name if one isn't defined.
String _getArgumentName(int count, NamedType field) =>
    field.name.isEmpty ? 'arg$count' : field.name;

/// Generates the arguments code for [func]
/// Example: (func, getArgumentName, nullTag) -> 'String? foo, int bar'
String _getMethodArgumentsSignature(
  Method func,
  String Function(int index, NamedType arg) getArgumentName,
  String nullTag,
) {
  return func.arguments.isEmpty
      ? ''
      : indexMap(func.arguments, (int index, NamedType arg) {
          final String type = _addGenericTypes(arg.type, nullTag);
          final String argName = getArgumentName(index, arg);
          return '$type $argName';
        }).join(', ');
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
void _writeHostApi(DartOptions opt, Indent indent, Api api, Root root) {
  assert(api.location == ApiLocation.host);
  final String codecName = _getCodecName(api);
  _writeCodec(indent, codecName, api, root);
  indent.addln('');
  final String nullTag = opt.isNullSafe ? '?' : '';
  final String unwrapOperator = opt.isNullSafe ? '!' : '';
  bool first = true;
  indent.write('class ${api.name} ');
  indent.scoped('{', '}', () {
    indent.format('''
/// Constructor for [${api.name}].  The [binaryMessenger] named argument is
/// available for dependency injection.  If it is left null, the default
/// BinaryMessenger will be used which routes to the host platform.
${api.name}({BinaryMessenger$nullTag binaryMessenger}) : _binaryMessenger = binaryMessenger;

final BinaryMessenger$nullTag _binaryMessenger;
''');

    indent.writeln('static const MessageCodec<Object?> codec = $codecName();');
    indent.addln('');
    for (final Method func in api.methods) {
      if (!first) {
        indent.writeln('');
      } else {
        first = false;
      }
      String argSignature = '';
      String sendArgument = 'null';
      if (func.arguments.isNotEmpty) {
        String argNameFunc(int index, NamedType type) =>
            _getSafeArgumentName(index, type);
        final Iterable<String> argNames = indexMap(func.arguments, argNameFunc);
        sendArgument = '<Object>[${argNames.join(', ')}]';
        argSignature = _getMethodArgumentsSignature(func, argNameFunc, nullTag);
      }
      indent.write(
        'Future<${_addGenericTypesNullable(func.returnType, nullTag)}> ${func.name}($argSignature) async ',
      );
      indent.scoped('{', '}', () {
        final String channelName = makeChannelName(api, func);
        indent.writeln(
            'final BasicMessageChannel<Object$nullTag> channel = BasicMessageChannel<Object$nullTag>(');
        indent.nest(2, () {
          indent.writeln(
            '\'$channelName\', codec, binaryMessenger: _binaryMessenger);',
          );
        });
        final String returnType =
            _makeGenericTypeArguments(func.returnType, nullTag);
        final String castCall = _makeGenericCastCall(func.returnType, nullTag);
        const String accessor = 'replyMap[\'${Keys.result}\']';
        final String unwrapper =
            func.returnType.isNullable ? '' : unwrapOperator;
        final String returnStatement = func.returnType.isVoid
            ? 'return;'
            : 'return ($accessor as $returnType$nullTag)$unwrapper$castCall;';
        // On iOS we can return nil from functions to accommodate error
        // handling.  Returning a nil value and not returning an error is an
        // exception.
        final String nullCheck = func.returnType.isNullable
            ? ''
            : '''

} else if (replyMap['${Keys.result}'] == null) {
\tthrow PlatformException(
\t\tcode: 'null-error',
\t\tmessage: 'Host platform returned null value for non-null return value.',
\t\tdetails: null,
\t);''';
        indent.format('''
final Map<Object$nullTag, Object$nullTag>$nullTag replyMap =\n\t\tawait channel.send($sendArgument) as Map<Object$nullTag, Object$nullTag>$nullTag;
if (replyMap == null) {
\tthrow PlatformException(
\t\tcode: 'channel-error',
\t\tmessage: 'Unable to establish connection on channel.',
\t\tdetails: null,
\t);
} else if (replyMap['error'] != null) {
\tfinal Map<Object$nullTag, Object$nullTag> error = (replyMap['${Keys.error}'] as Map<Object$nullTag, Object$nullTag>$nullTag)$unwrapOperator;
\tthrow PlatformException(
\t\tcode: (error['${Keys.errorCode}'] as String$nullTag)$unwrapOperator,
\t\tmessage: error['${Keys.errorMessage}'] as String$nullTag,
\t\tdetails: error['${Keys.errorDetails}'],
\t);$nullCheck
} else {
\t$returnStatement
}''');
      });
    }
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
void _writeFlutterApi(
  DartOptions opt,
  Indent indent,
  Api api,
  Root root, {
  String Function(Method)? channelNameFunc,
  bool isMockHandler = false,
}) {
  assert(api.location == ApiLocation.flutter);
  final String codecName = _getCodecName(api);
  _writeCodec(indent, codecName, api, root);
  final String nullTag = opt.isNullSafe ? '?' : '';
  final String unwrapOperator = opt.isNullSafe ? '!' : '';
  indent.write('abstract class ${api.name} ');
  indent.scoped('{', '}', () {
    indent.writeln('static const MessageCodec<Object?> codec = $codecName();');
    indent.addln('');
    for (final Method func in api.methods) {
      final bool isAsync = func.isAsynchronous;
      final String returnType = isAsync
          ? 'Future<${_addGenericTypesNullable(func.returnType, nullTag)}>'
          : _addGenericTypesNullable(func.returnType, nullTag);
      final String argSignature = _getMethodArgumentsSignature(
        func,
        _getArgumentName,
        nullTag,
      );
      indent.writeln('$returnType ${func.name}($argSignature);');
    }
    indent.write(
        'static void setup(${api.name}$nullTag api, {BinaryMessenger$nullTag binaryMessenger}) ');
    indent.scoped('{', '}', () {
      for (final Method func in api.methods) {
        indent.write('');
        indent.scoped('{', '}', () {
          indent.writeln(
            'final BasicMessageChannel<Object$nullTag> channel = BasicMessageChannel<Object$nullTag>(',
          );
          final String channelName = channelNameFunc == null
              ? makeChannelName(api, func)
              : channelNameFunc(func);
          indent.nest(2, () {
            indent.writeln(
              '\'$channelName\', codec, binaryMessenger: binaryMessenger);',
            );
          });
          final String messageHandlerSetter =
              isMockHandler ? 'setMockMessageHandler' : 'setMessageHandler';
          indent.write('if (api == null) ');
          indent.scoped('{', '}', () {
            indent.writeln('channel.$messageHandlerSetter(null);');
          }, addTrailingNewline: false);
          indent.add(' else ');
          indent.scoped('{', '}', () {
            indent.write(
              'channel.$messageHandlerSetter((Object$nullTag message) async ',
            );
            indent.scoped('{', '});', () {
              final String returnType =
                  _addGenericTypesNullable(func.returnType, nullTag);
              final bool isAsync = func.isAsynchronous;
              final String emptyReturnStatement = isMockHandler
                  ? 'return <Object$nullTag, Object$nullTag>{};'
                  : func.returnType.isVoid
                      ? 'return;'
                      : 'return null;';
              String call;
              if (func.arguments.isEmpty) {
                indent.writeln('// ignore message');
                call = 'api.${func.name}()';
              } else {
                indent.writeln(
                  'assert(message != null, \'Argument for $channelName was null.\');',
                );
                const String argsArray = 'args';
                indent.writeln(
                    'final List<Object$nullTag> $argsArray = (message as List<Object$nullTag>$nullTag)$unwrapOperator;');
                String argNameFunc(int index, NamedType type) =>
                    _getSafeArgumentName(index, type);
                enumerate(func.arguments, (int count, NamedType arg) {
                  final String argType = _addGenericTypes(arg.type, nullTag);
                  final String argName = argNameFunc(count, arg);
                  final String genericArgType =
                      _makeGenericTypeArguments(arg.type, nullTag);
                  final String castCall =
                      _makeGenericCastCall(arg.type, nullTag);

                  indent.writeln(
                      'final $argType$nullTag $argName = ($argsArray[$count] as $genericArgType$nullTag)${castCall.isEmpty ? '' : '$nullTag$castCall'};');
                  indent.writeln(
                      'assert($argName != null, \'Argument for $channelName was null, expected non-null $argType.\');');
                });
                final Iterable<String> argNames =
                    indexMap(func.arguments, argNameFunc);
                call =
                    'api.${func.name}(${argNames.map<String>((String x) => '$x$unwrapOperator').join(', ')})';
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
                    ? 'return <Object$nullTag, Object$nullTag>{\'${Keys.result}\': $returnExpression};'
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

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in Dart code.
String _flattenTypeArguments(List<TypeDeclaration> args, String nullTag) {
  return args
      .map<String>((TypeDeclaration arg) => arg.typeArguments.isEmpty
          ? '${arg.baseName}$nullTag'
          : '${arg.baseName}<${_flattenTypeArguments(arg.typeArguments, nullTag)}>$nullTag')
      .join(', ');
}

/// Creates the type declaration for use in Dart code from a [NamedType] making sure
/// that type arguments are used for primitive generic types.
String _addGenericTypes(TypeDeclaration type, String nullTag) {
  final List<TypeDeclaration> typeArguments = type.typeArguments;
  switch (type.baseName) {
    case 'List':
      return (typeArguments.isEmpty)
          ? 'List<Object$nullTag>'
          : 'List<${_flattenTypeArguments(typeArguments, nullTag)}>';
    case 'Map':
      return (typeArguments.isEmpty)
          ? 'Map<Object$nullTag, Object$nullTag>'
          : 'Map<${_flattenTypeArguments(typeArguments, nullTag)}>';
    default:
      return type.baseName;
  }
}

String _addGenericTypesNullable(TypeDeclaration type, String nullTag) {
  final String genericdType = _addGenericTypes(type, nullTag);
  return type.isNullable ? '$genericdType$nullTag' : genericdType;
}

/// Generates Dart source code for the given AST represented by [root],
/// outputting the code to [sink].
void generateDart(DartOptions opt, Root root, StringSink sink) {
  final String nullTag = opt.isNullSafe ? '?' : '';
  final String unwrapOperator = opt.isNullSafe ? '!' : '';
  final List<String> customClassNames =
      root.classes.map((Class x) => x.name).toList();
  final List<String> customEnumNames =
      root.enums.map((Enum x) => x.name).toList();
  final Indent indent = Indent(sink);

  void writeHeader() {
    if (opt.copyrightHeader != null) {
      addLines(indent, opt.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln(
      '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name',
    );
    indent.writeln('// @dart = ${opt.isNullSafe ? '2.12' : '2.8'}');
  }

  void writeEnums() {
    for (final Enum anEnum in root.enums) {
      indent.writeln('');
      indent.write('enum ${anEnum.name} ');
      indent.scoped('{', '}', () {
        for (final String member in anEnum.members) {
          indent.writeln('$member,');
        }
      });
    }
  }

  void writeImports() {
    indent.writeln('import \'dart:async\';');
    indent.writeln(
      'import \'dart:typed_data\' show Uint8List, Int32List, Int64List, Float64List;',
    );
    indent.addln('');
    indent.writeln(
        'import \'package:flutter/foundation.dart\' show WriteBuffer, ReadBuffer;');
    indent.writeln('import \'package:flutter/services.dart\';');
  }

  void writeDataClass(Class klass) {
    void writeConstructor() {
      indent.write(klass.name);
      indent.scoped('({', '});', () {
        for (final NamedType field in klass.fields) {
          final String required = field.type.isNullable ? '' : 'required ';
          indent.writeln('${required}this.${field.name},');
        }
      });
    }

    void writeEncode() {
      indent.write('Object encode() ');
      indent.scoped('{', '}', () {
        indent.writeln(
          'final Map<Object$nullTag, Object$nullTag> pigeonMap = <Object$nullTag, Object$nullTag>{};',
        );
        for (final NamedType field in klass.fields) {
          indent.write('pigeonMap[\'${field.name}\'] = ');
          if (customClassNames.contains(field.type.baseName)) {
            indent.addln(
              '${field.name} == null ? null : ${field.name}$unwrapOperator.encode();',
            );
          } else if (customEnumNames.contains(field.type.baseName)) {
            indent.addln(
              '${field.name} == null ? null : ${field.name}$unwrapOperator.index;',
            );
          } else {
            indent.addln('${field.name};');
          }
        }
        indent.writeln('return pigeonMap;');
      });
    }

    void writeDecode() {
      void writeValueDecode(NamedType field) {
        if (customClassNames.contains(field.type.baseName)) {
          indent.format('''
pigeonMap['${field.name}'] != null
\t\t? ${field.type.baseName}.decode(pigeonMap['${field.name}']$unwrapOperator)
\t\t: null''', leadingSpace: false, trailingNewline: false);
        } else if (customEnumNames.contains(field.type.baseName)) {
          indent.format('''
pigeonMap['${field.name}'] != null
\t\t? ${field.type.baseName}.values[pigeonMap['${field.name}']$unwrapOperator as int]
\t\t: null''', leadingSpace: false, trailingNewline: false);
        } else if (field.type.typeArguments.isNotEmpty) {
          final String genericType =
              _makeGenericTypeArguments(field.type, nullTag);
          final String castCall = _makeGenericCastCall(field.type, nullTag);
          final String castCallPrefix =
              field.type.isNullable ? nullTag : unwrapOperator;
          indent.add(
            '(pigeonMap[\'${field.name}\'] as $genericType$nullTag)$castCallPrefix$castCall',
          );
        } else {
          final String genericdType =
              _addGenericTypesNullable(field.type, nullTag);
          if (field.type.isNullable) {
            indent.add(
              'pigeonMap[\'${field.name}\'] as $genericdType',
            );
          } else {
            indent.add(
              'pigeonMap[\'${field.name}\']$unwrapOperator as $genericdType',
            );
          }
        }
      }

      indent.write(
        'static ${klass.name} decode(Object message) ',
      );
      indent.scoped('{', '}', () {
        indent.writeln(
          'final Map<Object$nullTag, Object$nullTag> pigeonMap = message as Map<Object$nullTag, Object$nullTag>;',
        );
        indent.write('return ${klass.name}');
        indent.scoped('(', ');', () {
          for (int index = 0; index < klass.fields.length; index += 1) {
            final NamedType field = klass.fields[index];
            indent.write('${field.name}: ');
            writeValueDecode(field);
            indent.addln(',');
          }
        });
      });
    }

    indent.write('class ${klass.name} ');
    indent.scoped('{', '}', () {
      writeConstructor();
      indent.addln('');
      for (final NamedType field in klass.fields) {
        final String datatype = _addGenericTypesNullable(field.type, nullTag);
        indent.writeln('$datatype ${field.name};');
      }
      if (klass.fields.isNotEmpty) {
        indent.writeln('');
      }
      writeEncode();
      indent.writeln('');
      writeDecode();
    });
  }

  void writeApi(Api api) {
    if (api.location == ApiLocation.host) {
      _writeHostApi(opt, indent, api, root);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApi(opt, indent, api, root);
    }
  }

  writeHeader();
  writeImports();
  writeEnums();
  for (final Class klass in root.classes) {
    indent.writeln('');
    writeDataClass(klass);
  }
  for (final Api api in root.apis) {
    indent.writeln('');
    writeApi(api);
  }
}

/// Generates Dart source code for test support libraries based on the
/// given AST represented by [root], outputting the code to [sink].
void generateTestDart(
  DartOptions opt,
  Root root,
  StringSink sink,
  String mainDartFile,
) {
  final Indent indent = Indent(sink);
  if (opt.copyrightHeader != null) {
    addLines(indent, opt.copyrightHeader!, linePrefix: '// ');
  }
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln(
    '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis',
  );
  indent.writeln('// ignore_for_file: avoid_relative_lib_imports');
  indent.writeln('// @dart = ${opt.isNullSafe ? '2.12' : '2.8'}');
  indent.writeln('import \'dart:async\';');
  indent.writeln(
    'import \'dart:typed_data\' show Uint8List, Int32List, Int64List, Float64List;',
  );
  indent.writeln(
      'import \'package:flutter/foundation.dart\' show WriteBuffer, ReadBuffer;');
  indent.writeln('import \'package:flutter/services.dart\';');
  indent.writeln('import \'package:flutter_test/flutter_test.dart\';');
  indent.writeln('');
  // TODO(gaaclarke): Switch from relative paths to URIs. This fails in new versions of Dart,
  // https://github.com/flutter/flutter/issues/97744.
  indent.writeln(
    'import \'${_escapeForDartSingleQuotedString(mainDartFile)}\';',
  );
  for (final Api api in root.apis) {
    if (api.location == ApiLocation.host && api.dartHostTestHandler != null) {
      final Api mockApi = Api(
        name: api.dartHostTestHandler!,
        methods: api.methods,
        location: ApiLocation.flutter,
        dartHostTestHandler: api.dartHostTestHandler,
      );
      indent.writeln('');
      _writeFlutterApi(
        opt,
        indent,
        mockApi,
        root,
        channelNameFunc: (Method func) => makeChannelName(api, func),
        isMockHandler: true,
      );
    }
  }
}
