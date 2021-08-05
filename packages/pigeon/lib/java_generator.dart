// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

const Map<String, String> _javaTypeForDartTypeMap = <String, String>{
  'bool': 'Boolean',
  'int': 'Long',
  'String': 'String',
  'double': 'Double',
  'Uint8List': 'byte[]',
  'Int32List': 'int[]',
  'Int64List': 'long[]',
  'Float64List': 'double[]',
  'List': 'List<Object>',
  'Map': 'Map<Object, Object>',
};

/// Options that control how Java code will be generated.
class JavaOptions {
  /// Creates a [JavaOptions] object
  const JavaOptions({
    this.className,
    this.package,
    this.copyrightHeader,
  });

  /// The name of the class that will house all the generated classes.
  final String? className;

  /// The package where the generated class will live.
  final String? package;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Creates a [JavaOptions] from a Map representation where:
  /// `x = JavaOptions.fromMap(x.toMap())`.
  static JavaOptions fromMap(Map<String, Object> map) {
    return JavaOptions(
      className: map['className'] as String?,
      package: map['package'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
    );
  }

  /// Converts a [JavaOptions] to a Map representation where:
  /// `x = JavaOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (className != null) 'className': className!,
      if (package != null) 'package': package!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [JavaOptions].
  JavaOptions merge(JavaOptions options) {
    return JavaOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

String _getCodecName(Api api) => '${api.name}Codec';

void _writeCodec(Indent indent, Api api) {
  final String codecName = _getCodecName(api);
  indent.write('private static class $codecName extends StandardMessageCodec ');
  indent.scoped('{', '}', () {
    indent
        .writeln('public static final $codecName INSTANCE = new $codecName();');
    indent.writeln('private $codecName() {}');
    if (getCodecClasses(api).isNotEmpty) {
      indent.writeln('@Override');
      indent.write(
          'protected Object readValueOfType(byte type, ByteBuffer buffer) ');
      indent.scoped('{', '}', () {
        indent.write('switch (type) ');
        indent.scoped('{', '}', () {
          for (final EnumeratedClass customClass in getCodecClasses(api)) {
            indent.write('case (byte)${customClass.enumeration}: ');
            indent.writeScoped('', '', () {
              indent.writeln(
                  'return ${customClass.name}.fromMap((Map<String, Object>) readValue(buffer));');
            });
          }
          indent.write('default:');
          indent.writeScoped('', '', () {
            indent.writeln('return super.readValueOfType(type, buffer);');
          });
        });
      });
      indent.writeln('@Override');
      indent.write(
          'protected void writeValue(ByteArrayOutputStream stream, Object value) ');
      indent.writeScoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api)) {
          indent.write('if (value instanceof ${customClass.name}) ');
          indent.scoped('{', '} else ', () {
            indent.writeln('stream.write(${customClass.enumeration});');
            indent.writeln(
                'writeValue(stream, ((${customClass.name}) value).toMap());');
          });
        }
        indent.scoped('{', '}', () {
          indent.writeln('super.writeValue(stream, value);');
        });
      });
    }
  });
}

/// This performs Dart to Java type conversions.  If performs a passthrough of
/// the input if it can't be converted.
// TODO(gaaclarke): Remove this method and unify it with `_javaTypeForDartType`.
String _javaTypeForDartTypePassthrough(String type) {
  const Map<String, String> map = <String, String>{
    'int': 'Integer',
    'bool': 'Boolean',
    'double': 'Double',
    'Int32List': 'int[]',
    'Uint8List': 'byte[]',
    'Int64List': 'long[]',
    'Float64List': 'double[]',
  };
  return map[type] ?? type;
}

void _writeHostApi(Indent indent, Api api) {
  assert(api.location == ApiLocation.host);

  indent.writeln(
      '/** Generated interface from Pigeon that represents a handler of messages from Flutter.*/');
  indent.write('public interface ${api.name} ');
  indent.scoped('{', '}', () {
    for (final Method method in api.methods) {
      final String argType = _javaTypeForDartTypePassthrough(method.argType);
      final String returnType = method.isAsynchronous
          ? 'void'
          : _javaTypeForDartTypePassthrough(method.returnType);
      final List<String> argSignature = <String>[];
      if (method.argType != 'void') {
        argSignature.add('$argType arg');
      }
      if (method.isAsynchronous) {
        final String returnType =
            method.returnType == 'void' ? 'Void' : method.returnType;
        argSignature.add('Result<$returnType> result');
      }
      indent.writeln('$returnType ${method.name}(${argSignature.join(', ')});');
    }
    indent.addln('');
    final String codecName = _getCodecName(api);
    indent.format('''
/** The codec used by ${api.name}. */
static MessageCodec<Object> getCodec() {
\treturn $codecName.INSTANCE;
}
''');
    indent.writeln(
        '/** Sets up an instance of `${api.name}` to handle messages through the `binaryMessenger`. */');
    indent.write(
        'static void setup(BinaryMessenger binaryMessenger, ${api.name} api) ');
    indent.scoped('{', '}', () {
      for (final Method method in api.methods) {
        final String channelName = makeChannelName(api, method);
        indent.write('');
        indent.scoped('{', '}', () {
          indent.writeln('BasicMessageChannel<Object> channel =');
          indent.inc();
          indent.inc();
          indent.writeln(
              'new BasicMessageChannel<>(binaryMessenger, "$channelName", getCodec());');
          indent.dec();
          indent.dec();
          indent.write('if (api != null) ');
          indent.scoped('{', '} else {', () {
            indent.write('channel.setMessageHandler((message, reply) -> ');
            indent.scoped('{', '});', () {
              final String argType =
                  _javaTypeForDartTypePassthrough(method.argType);
              final String returnType =
                  _javaTypeForDartTypePassthrough(method.returnType);
              indent.writeln('Map<String, Object> wrapped = new HashMap<>();');
              indent.write('try ');
              indent.scoped('{', '}', () {
                final List<String> methodArgument = <String>[];
                if (argType != 'void') {
                  indent.writeln('@SuppressWarnings("ConstantConditions")');
                  indent.writeln('$argType input = ($argType)message;');
                  indent.write('if (input == null) ');
                  indent.scoped('{', '}', () {
                    indent.writeln(
                        'throw new NullPointerException("Message unexpectedly null.");');
                  });
                  methodArgument.add('input');
                }
                if (method.isAsynchronous) {
                  final String resultValue =
                      method.returnType == 'void' ? 'null' : 'result';
                  methodArgument.add(
                    'result -> { '
                    'wrapped.put("${Keys.result}", $resultValue); '
                    'reply.reply(wrapped); '
                    '}',
                  );
                }
                final String call =
                    'api.${method.name}(${methodArgument.join(', ')})';
                if (method.isAsynchronous) {
                  indent.writeln('$call;');
                } else if (method.returnType == 'void') {
                  indent.writeln('$call;');
                  indent.writeln('wrapped.put("${Keys.result}", null);');
                } else {
                  indent.writeln('$returnType output = $call;');
                  indent.writeln('wrapped.put("${Keys.result}", output);');
                }
              });
              indent.write('catch (Error | RuntimeException exception) ');
              indent.scoped('{', '}', () {
                indent.writeln(
                    'wrapped.put("${Keys.error}", wrapError(exception));');
                if (method.isAsynchronous) {
                  indent.writeln('reply.reply(wrapped);');
                }
              });
              if (!method.isAsynchronous) {
                indent.writeln('reply.reply(wrapped);');
              }
            });
          });
          indent.scoped(null, '}', () {
            indent.writeln('channel.setMessageHandler(null);');
          });
        });
      }
    });
  });
}

void _writeFlutterApi(Indent indent, Api api) {
  assert(api.location == ApiLocation.flutter);
  indent.writeln(
      '/** Generated class from Pigeon that represents Flutter messages that can be called from Java.*/');
  indent.write('public static class ${api.name} ');
  indent.scoped('{', '}', () {
    indent.writeln('private final BinaryMessenger binaryMessenger;');
    indent.write('public ${api.name}(BinaryMessenger argBinaryMessenger)');
    indent.scoped('{', '}', () {
      indent.writeln('this.binaryMessenger = argBinaryMessenger;');
    });
    indent.write('public interface Reply<T> ');
    indent.scoped('{', '}', () {
      indent.writeln('void reply(T reply);');
    });
    final String codecName = _getCodecName(api);
    indent.format('''
static MessageCodec<Object> getCodec() {
\treturn $codecName.INSTANCE;
}
''');
    for (final Method func in api.methods) {
      final String channelName = makeChannelName(api, func);
      final String returnType = func.returnType == 'void'
          ? 'Void'
          : _javaTypeForDartTypePassthrough(func.returnType);
      final String argType = _javaTypeForDartTypePassthrough(func.argType);
      String sendArgument;
      if (func.argType == 'void') {
        indent.write('public void ${func.name}(Reply<$returnType> callback) ');
        sendArgument = 'null';
      } else {
        indent.write(
            'public void ${func.name}($argType argInput, Reply<$returnType> callback) ');
        sendArgument = 'argInput';
      }
      indent.scoped('{', '}', () {
        indent.writeln('BasicMessageChannel<Object> channel =');
        indent.inc();
        indent.inc();
        indent.writeln(
            'new BasicMessageChannel<>(binaryMessenger, "$channelName", getCodec());');
        indent.dec();
        indent.dec();
        indent.write('channel.send($sendArgument, channelReply -> ');
        indent.scoped('{', '});', () {
          if (func.returnType == 'void') {
            indent.writeln('callback.reply(null);');
          } else {
            indent.writeln('@SuppressWarnings("ConstantConditions")');
            indent.writeln('$returnType output = ($returnType)channelReply;');
            indent.writeln('callback.reply(output);');
          }
        });
      });
    }
  });
}

String _makeGetter(Field field) {
  final String uppercased =
      field.name.substring(0, 1).toUpperCase() + field.name.substring(1);
  return 'get$uppercased';
}

String _makeSetter(Field field) {
  final String uppercased =
      field.name.substring(0, 1).toUpperCase() + field.name.substring(1);
  return 'set$uppercased';
}

String? _javaTypeForDartType(String datatype) {
  return _javaTypeForDartTypeMap[datatype];
}

String _castObject(
    Field field, List<Class> classes, List<Enum> enums, String varName) {
  final HostDatatype hostDatatype =
      getHostDatatype(field, classes, enums, _javaTypeForDartType);
  if (field.dataType == 'int') {
    return '($varName == null) ? null : (($varName instanceof Integer) ? (Integer)$varName : (${hostDatatype.datatype})$varName)';
  } else if (!hostDatatype.isBuiltin &&
      classes.map((Class x) => x.name).contains(field.dataType)) {
    return '${hostDatatype.datatype}.fromMap((Map)$varName)';
  } else {
    return '(${hostDatatype.datatype})$varName';
  }
}

/// Generates the ".java" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateJava(JavaOptions options, Root root, StringSink sink) {
  final Set<String> rootClassNameSet =
      root.classes.map((Class x) => x.name).toSet();
  final Set<String> rootEnumNameSet =
      root.enums.map((Enum x) => x.name).toSet();
  final Indent indent = Indent(sink);
  if (options.copyrightHeader != null) {
    addLines(indent, options.copyrightHeader!, linePrefix: '// ');
  }
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.addln('');
  if (options.package != null) {
    indent.writeln('package ${options.package};');
  }
  indent.addln('');
  indent.writeln('import io.flutter.plugin.common.BasicMessageChannel;');
  indent.writeln('import io.flutter.plugin.common.BinaryMessenger;');
  indent.writeln('import io.flutter.plugin.common.MessageCodec;');
  indent.writeln('import io.flutter.plugin.common.StandardMessageCodec;');
  indent.writeln('import java.io.ByteArrayOutputStream;');
  indent.writeln('import java.nio.ByteBuffer;');
  indent.writeln('import java.util.List;');
  indent.writeln('import java.util.Map;');
  indent.writeln('import java.util.HashMap;');

  indent.addln('');
  indent.writeln('/** Generated class from Pigeon. */');
  indent.writeln(
      '@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression"})');
  indent.write('public class ${options.className!} ');
  indent.scoped('{', '}', () {
    for (final Enum anEnum in root.enums) {
      indent.writeln('');
      indent.write('public enum ${anEnum.name} ');
      indent.scoped('{', '}', () {
        int index = 0;
        for (final String member in anEnum.members) {
          indent.writeln(
              '$member($index)${index == anEnum.members.length - 1 ? ';' : ','}');
          index++;
        }
        indent.writeln('');
        // We use explicit indexing here as use of the ordinal() method is
        // discouraged. The toMap and fromMap API matches class API to allow
        // the same code to work with enums and classes, but this
        // can also be done directly in the host and flutter APIs.
        indent.writeln('private int index;');
        indent.write('private ${anEnum.name}(final int index) ');
        indent.scoped('{', '}', () {
          indent.writeln('this.index = index;');
        });
      });
    }

    for (final Class klass in root.classes) {
      indent.addln('');
      indent.writeln(
          '/** Generated class from Pigeon that represents data sent in messages. */');
      indent.write('public static class ${klass.name} ');
      indent.scoped('{', '}', () {
        for (final Field field in klass.fields) {
          final HostDatatype hostDatatype = getHostDatatype(
              field, root.classes, root.enums, _javaTypeForDartType);
          indent.writeln('private ${hostDatatype.datatype} ${field.name};');
          indent.writeln(
              'public ${hostDatatype.datatype} ${_makeGetter(field)}() { return ${field.name}; }');
          indent.writeln(
              'public void ${_makeSetter(field)}(${hostDatatype.datatype} setterArg) { this.${field.name} = setterArg; }');
          indent.addln('');
        }
        indent.write('Map<String, Object> toMap() ');
        indent.scoped('{', '}', () {
          indent.writeln('Map<String, Object> toMapResult = new HashMap<>();');
          for (final Field field in klass.fields) {
            final HostDatatype hostDatatype = getHostDatatype(
                field, root.classes, root.enums, _javaTypeForDartType);
            String toWriteValue = '';
            if (!hostDatatype.isBuiltin &&
                rootClassNameSet.contains(field.dataType)) {
              final String fieldName = field.name;
              toWriteValue = '($fieldName == null) ? null : $fieldName.toMap()';
            } else if (!hostDatatype.isBuiltin &&
                rootEnumNameSet.contains(field.dataType)) {
              toWriteValue = '${field.name}.index';
            } else {
              toWriteValue = field.name;
            }
            indent.writeln('toMapResult.put("${field.name}", $toWriteValue);');
          }
          indent.writeln('return toMapResult;');
        });
        indent.write('static ${klass.name} fromMap(Map<String, Object> map) ');
        indent.scoped('{', '}', () {
          indent.writeln('${klass.name} fromMapResult = new ${klass.name}();');
          for (final Field field in klass.fields) {
            indent.writeln('Object ${field.name} = map.get("${field.name}");');
            if (rootEnumNameSet.contains(field.dataType)) {
              indent.writeln(
                  'fromMapResult.${field.name} = ${field.dataType}.values()[(int)${field.name}];');
            } else {
              indent.writeln(
                  'fromMapResult.${field.name} = ${_castObject(field, root.classes, root.enums, field.name)};');
            }
          }
          indent.writeln('return fromMapResult;');
        });
      });
    }

    if (root.apis.any((Api api) =>
        api.location == ApiLocation.host &&
        api.methods.any((Method it) => it.isAsynchronous))) {
      indent.addln('');
      indent.write('public interface Result<T> ');
      indent.scoped('{', '}', () {
        indent.writeln('void success(T result);');
      });
    }

    for (final Api api in root.apis) {
      _writeCodec(indent, api);
      indent.addln('');
      if (api.location == ApiLocation.host) {
        _writeHostApi(indent, api);
      } else if (api.location == ApiLocation.flutter) {
        _writeFlutterApi(indent, api);
      }
    }

    indent.format('''
private static Map<String, Object> wrapError(Throwable exception) {
\tMap<String, Object> errorMap = new HashMap<>();
\terrorMap.put("${Keys.errorMessage}", exception.toString());
\terrorMap.put("${Keys.errorCode}", exception.getClass().getSimpleName());
\terrorMap.put("${Keys.errorDetails}", null);
\treturn errorMap;
}''');
  });
}
