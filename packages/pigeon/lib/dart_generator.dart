// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
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
    return DartOptions(
      isNullSafe: map['isNullSafe'] as bool? ?? true,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
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

String _getCodecName(Api api) => '_${api.name}Codec';

void _writeCodec(Indent indent, String codecName, Api api) {
  indent.write('class $codecName extends StandardMessageCodec ');
  indent.scoped('{', '}', () {
    indent.writeln('const $codecName();');
    if (getCodecClasses(api).isNotEmpty) {
      indent.writeln('@override');
      indent.write('void writeValue(WriteBuffer buffer, Object? value) ');
      indent.scoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api)) {
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
          for (final EnumeratedClass customClass in getCodecClasses(api)) {
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

void _writeHostApi(DartOptions opt, Indent indent, Api api) {
  assert(api.location == ApiLocation.host);
  final String codecName = _getCodecName(api);
  _writeCodec(indent, codecName, api);
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
      if (func.argType != 'void') {
        argSignature = '${func.argType} arg';
        sendArgument = 'arg';
      }
      indent.write(
        'Future<${func.returnType}> ${func.name}($argSignature) async ',
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
        final String returnStatement = func.returnType == 'void'
            ? '// noop'
            : 'return (replyMap[\'${Keys.result}\'] as ${func.returnType}$nullTag)$unwrapOperator;';
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
\t);
} else {
\t$returnStatement
}''');
      });
    }
  });
}

void _writeFlutterApi(
  DartOptions opt,
  Indent indent,
  Api api, {
  String Function(Method)? channelNameFunc,
  bool isMockHandler = false,
}) {
  assert(api.location == ApiLocation.flutter);
  final String codecName = _getCodecName(api);
  _writeCodec(indent, codecName, api);
  final String nullTag = opt.isNullSafe ? '?' : '';
  final String unwrapOperator = opt.isNullSafe ? '!' : '';
  indent.write('abstract class ${api.name} ');
  indent.scoped('{', '}', () {
    indent.writeln('static const MessageCodec<Object?> codec = $codecName();');
    indent.addln('');
    for (final Method func in api.methods) {
      final bool isAsync = func.isAsynchronous;
      final String returnType =
          isAsync ? 'Future<${func.returnType}>' : func.returnType;
      final String argSignature =
          func.argType == 'void' ? '' : '${func.argType} arg';
      indent.writeln('$returnType ${func.name}($argSignature);');
    }
    indent.write('static void setup(${api.name}$nullTag api) ');
    indent.scoped('{', '}', () {
      for (final Method func in api.methods) {
        indent.write('');
        indent.scoped('{', '}', () {
          indent.writeln(
            'const BasicMessageChannel<Object$nullTag> channel = BasicMessageChannel<Object$nullTag>(',
          );
          final String channelName = channelNameFunc == null
              ? makeChannelName(api, func)
              : channelNameFunc(func);
          indent.nest(2, () {
            indent.writeln(
              '\'$channelName\', codec);',
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
              final String argType = func.argType;
              final String returnType = func.returnType;
              final bool isAsync = func.isAsynchronous;
              final String emptyReturnStatement = isMockHandler
                  ? 'return <Object$nullTag, Object$nullTag>{};'
                  : func.returnType == 'void'
                      ? 'return;'
                      : 'return null;';
              String call;
              if (argType == 'void') {
                indent.writeln('// ignore message');
                call = 'api.${func.name}()';
              } else {
                indent.writeln(
                  'assert(message != null, \'Argument for $channelName was null. Expected $argType.\');',
                );
                indent.writeln(
                  'final $argType input = (message as $argType$nullTag)$unwrapOperator;',
                );
                call = 'api.${func.name}(input)';
              }
              if (returnType == 'void') {
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

String _addGenericTypes(String dataType, String nullTag) {
  switch (dataType) {
    case 'List':
      return 'List<Object$nullTag>$nullTag';
    case 'Map':
      return 'Map<Object$nullTag, Object$nullTag>$nullTag';
    default:
      return '$dataType$nullTag';
  }
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
  if (opt.copyrightHeader != null) {
    addLines(indent, opt.copyrightHeader!, linePrefix: '// ');
  }
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln(
    '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name',
  );
  indent.writeln('// @dart = ${opt.isNullSafe ? '2.12' : '2.8'}');
  indent.writeln('import \'dart:async\';');
  indent.writeln(
    'import \'dart:typed_data\' show Uint8List, Int32List, Int64List, Float64List;',
  );
  indent.addln('');
  indent.writeln(
      'import \'package:flutter/foundation.dart\' show WriteBuffer, ReadBuffer;');
  indent.writeln('import \'package:flutter/services.dart\';');
  for (final Enum anEnum in root.enums) {
    indent.writeln('');
    indent.write('enum ${anEnum.name} ');
    indent.scoped('{', '}', () {
      for (final String member in anEnum.members) {
        indent.writeln('$member,');
      }
    });
  }
  for (final Class klass in root.classes) {
    indent.writeln('');
    indent.write('class ${klass.name} ');
    indent.scoped('{', '}', () {
      for (final Field field in klass.fields) {
        final String datatype = _addGenericTypes(field.dataType, nullTag);
        indent.writeln('$datatype ${field.name};');
      }
      if (klass.fields.isNotEmpty) {
        indent.writeln('');
      }
      indent.write('Object encode() ');
      indent.scoped('{', '}', () {
        indent.writeln(
          'final Map<Object$nullTag, Object$nullTag> pigeonMap = <Object$nullTag, Object$nullTag>{};',
        );
        for (final Field field in klass.fields) {
          indent.write('pigeonMap[\'${field.name}\'] = ');
          if (customClassNames.contains(field.dataType)) {
            indent.addln(
              '${field.name} == null ? null : ${field.name}$unwrapOperator.encode();',
            );
          } else if (customEnumNames.contains(field.dataType)) {
            indent.addln(
              '${field.name} == null ? null : ${field.name}$unwrapOperator.index;',
            );
          } else {
            indent.addln('${field.name};');
          }
        }
        indent.writeln('return pigeonMap;');
      });
      indent.writeln('');
      indent.write(
        'static ${klass.name} decode(Object message) ',
      );
      indent.scoped('{', '}', () {
        indent.writeln(
          'final Map<Object$nullTag, Object$nullTag> pigeonMap = message as Map<Object$nullTag, Object$nullTag>;',
        );
        indent.writeln('return ${klass.name}()');
        indent.nest(1, () {
          for (int index = 0; index < klass.fields.length; index += 1) {
            final Field field = klass.fields[index];
            indent.write('..${field.name} = ');
            if (customClassNames.contains(field.dataType)) {
              indent.format('''
pigeonMap['${field.name}'] != null
\t\t? ${field.dataType}.decode(pigeonMap['${field.name}']$unwrapOperator)
\t\t: null''', leadingSpace: false, trailingNewline: false);
            } else if (customEnumNames.contains(field.dataType)) {
              indent.format('''
pigeonMap['${field.name}'] != null
\t\t? ${field.dataType}.values[pigeonMap['${field.name}']$unwrapOperator as int]
\t\t: null''', leadingSpace: false, trailingNewline: false);
            } else {
              indent.add(
                'pigeonMap[\'${field.name}\'] as ${_addGenericTypes(field.dataType, nullTag)}',
              );
            }
            indent.addln(index == klass.fields.length - 1 ? ';' : '');
          }
        });
      });
    });
  }
  for (final Api api in root.apis) {
    indent.writeln('');
    if (api.location == ApiLocation.host) {
      _writeHostApi(opt, indent, api);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApi(opt, indent, api);
    }
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
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln(
    '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import',
  );
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
        channelNameFunc: (Method func) => makeChannelName(api, func),
        isMockHandler: true,
      );
    }
  }
}
