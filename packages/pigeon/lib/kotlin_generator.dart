// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
import 'generator_tools.dart';
import 'pigeon_lib.dart' show TaskQueueType;

/// Options that control how Kotlin code will be generated.
class KotlinOptions {
  /// Creates a [KotlinOptions] object
  const KotlinOptions({
    this.package,
    this.copyrightHeader,
  });

  /// The package where the generated class will live.
  final String? package;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Creates a [KotlinOptions] from a Map representation where:
  /// `x = KotlinOptions.fromMap(x.toMap())`.
  static KotlinOptions fromMap(Map<String, Object> map) {
    return KotlinOptions(
      package: map['package'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
    );
  }

  /// Converts a [KotlinOptions] to a Map representation where:
  /// `x = KotlinOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (package != null) 'package': package!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [KotlinOptions].
  KotlinOptions merge(KotlinOptions options) {
    return KotlinOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Calculates the name of the codec that will be generated for [api].
String _getCodecName(Api api) => '${api.name}Codec';

/// Writes the codec class that will be used by [api].
/// Example:
/// private static class FooCodec extends StandardMessageCodec {...}
void _writeCodec(Indent indent, Api api, Root root) {
  final String codecName = _getCodecName(api);
  indent.writeln('@Suppress("UNCHECKED_CAST")');
  indent.write('private object $codecName : StandardMessageCodec() ');
  indent.scoped('{', '}', () {
    if (getCodecClasses(api, root).isNotEmpty) {
      indent.write(
          'override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? ');
      indent.scoped('{', '}', () {
        indent.write('return when (type) ');
        indent.scoped('{', '}', () {
          for (final EnumeratedClass customClass
              in getCodecClasses(api, root)) {
            indent.write('${customClass.enumeration}.toByte() -> ');
            indent.scoped('{', '}', () {
              indent.write(
                  'return (readValue(buffer) as? Map<String, Any?>)?.let ');
              indent.scoped('{', '}', () {
                indent.writeln('${customClass.name}.fromMap(it)');
              });
            });
          }
          indent.writeln('else -> super.readValueOfType(type, buffer)');
        });
      });

      indent.write(
          'override fun writeValue(stream: ByteArrayOutputStream, value: Any?) ');
      indent.writeScoped('{', '}', () {
        indent.write('when (value) ');
        indent.scoped('{', '}', () {
          for (final EnumeratedClass customClass
              in getCodecClasses(api, root)) {
            indent.write('is ${customClass.name} -> ');
            indent.scoped('{', '}', () {
              indent.writeln('stream.write(${customClass.enumeration})');
              indent.writeln('writeValue(stream, value.toMap())');
            });
          }
          indent.writeln('else -> super.writeValue(stream, value)');
        });
      });
    }
  });
}

/// Write the kotlin code that represents a host [Api], [api].
/// Example:
/// interface Foo {
///   Int add(x: Int, y: Int);
///   companion object {
///     fun setUp(binaryMessenger: BinaryMessenger, api: Api) {...}
///   }
/// }
void _writeHostApi(Indent indent, Api api, Root root) {
  assert(api.location == ApiLocation.host);

  final String apiName = api.name;

  indent.writeln(
      '/** Generated interface from Pigeon that represents a handler of messages from Flutter. */');
  indent.write('interface $apiName ');
  indent.scoped('{', '}', () {
    for (final Method method in api.methods) {
      final List<String> argSignature = <String>[];
      if (method.arguments.isNotEmpty) {
        final Iterable<String> argTypes = method.arguments
            .map((NamedType e) => _nullsafeKotlinTypeForDartType(e.type));
        final Iterable<String> argNames =
            method.arguments.map((NamedType e) => e.name);
        argSignature
            .addAll(map2(argTypes, argNames, (String argType, String argName) {
          return '$argName: $argType';
        }));
      }

      final String returnType = method.returnType.isVoid
          ? ''
          : _nullsafeKotlinTypeForDartType(method.returnType);
      if (method.isAsynchronous) {
        argSignature.add('callback: ($returnType) -> Unit');
        indent.writeln('fun ${method.name}(${argSignature.join(', ')})');
      } else if (method.returnType.isVoid) {
        indent.writeln('fun ${method.name}(${argSignature.join(', ')})');
      } else {
        indent.writeln(
            'fun ${method.name}(${argSignature.join(', ')}): $returnType');
      }
    }

    indent.addln('');
    indent.write('companion object ');
    indent.scoped('{', '}', () {
      indent.writeln('/** The codec used by $apiName. */');
      indent.scoped('val codec: MessageCodec<Any?> by lazy {', '}', () {
        indent.writeln(_getCodecName(api));
      });
      indent.writeln(
          '/** Sets up an instance of `$apiName` to handle messages through the `binaryMessenger`. */');
      indent.writeln('@Suppress("UNCHECKED_CAST")');
      indent.write(
          'fun setUp(binaryMessenger: BinaryMessenger, api: $apiName?) ');
      indent.scoped('{', '}', () {
        for (final Method method in api.methods) {
          indent.write('');
          indent.scoped('run {', '}', () {
            String? taskQueue;
            if (method.taskQueueType != TaskQueueType.serial) {
              taskQueue = 'taskQueue';
              indent.writeln(
                  'val $taskQueue = binaryMessenger.makeBackgroundTaskQueue()');
            }

            final String channelName = makeChannelName(api, method);

            indent.write(
                'val channel = BasicMessageChannel<Any?>(binaryMessenger, "$channelName", codec');

            if (taskQueue != null) {
              indent.addln(', $taskQueue)');
            } else {
              indent.addln(')');
            }

            indent.write('if (api != null) ');
            indent.scoped('{', '}', () {
              final String messageVarName =
                  method.arguments.isNotEmpty ? 'message' : '_';

              indent.write('channel.setMessageHandler ');
              indent.scoped('{ $messageVarName, reply ->', '}', () {
                indent.writeln('val wrapped = hashMapOf<String, Any?>()');

                indent.write('try ');
                indent.scoped('{', '}', () {
                  final List<String> methodArgument = <String>[];
                  if (method.arguments.isNotEmpty) {
                    indent.writeln('val args = message as List<Any?>');
                    enumerate(method.arguments, (int index, NamedType arg) {
                      final String argName = _getSafeArgumentName(index, arg);
                      final String argIndex = 'args[$index]';
                      indent.writeln(
                          'val $argName = ${_castForceUnwrap(argIndex, arg.type, root)}');
                      methodArgument.add(argName);
                    });
                  }
                  final String call =
                      'api.${method.name}(${methodArgument.join(', ')})';
                  if (method.isAsynchronous) {
                    indent.write('$call ');
                    if (method.returnType.isVoid) {
                      indent.scoped('{', '}', () {
                        indent.writeln('reply.reply(null)');
                      });
                    } else {
                      indent.scoped('{', '}', () {
                        indent.writeln('reply.reply(wrapResult(it))');
                      });
                    }
                  } else if (method.returnType.isVoid) {
                    indent.writeln(call);
                    indent.writeln('wrapped["${Keys.result}"] = null');
                  } else {
                    indent.writeln('wrapped["${Keys.result}"] = $call');
                  }
                }, addTrailingNewline: false);
                indent.add(' catch (exception: Error) ');
                indent.scoped('{', '}', () {
                  indent.writeln(
                      'wrapped["${Keys.error}"] = wrapError(exception)');
                  if (method.isAsynchronous) {
                    indent.writeln('reply.reply(wrapped)');
                  }
                });
                if (!method.isAsynchronous) {
                  indent.writeln('reply.reply(wrapped)');
                }
              });
            }, addTrailingNewline: false);
            indent.scoped(' else {', '}', () {
              indent.writeln('channel.setMessageHandler(null)');
            });
          });
        }
      });
    });
  });
}

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : argument.name;

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}Arg';

/// Writes the code for a flutter [Api], [api].
/// Example:
/// class Foo(private val binaryMessenger: BinaryMessenger) {
///   fun add(x: Int, y: Int, callback: (Int?) -> Unit) {...}
/// }
void _writeFlutterApi(Indent indent, Api api) {
  assert(api.location == ApiLocation.flutter);
  indent.writeln(
      '/** Generated class from Pigeon that represents Flutter messages that can be called from Kotlin. */');
  final String apiName = api.name;
  indent.writeln('@Suppress("UNCHECKED_CAST")');
  indent.write('class $apiName(private val binaryMessenger: BinaryMessenger) ');
  indent.scoped('{', '}', () {
    indent.write('companion object ');
    indent.scoped('{', '}', () {
      indent.writeln('/** The codec used by $apiName. */');
      indent.write('val codec: MessageCodec<Any?> by lazy ');
      indent.scoped('{', '}', () {
        indent.writeln(_getCodecName(api));
      });
    });

    for (final Method func in api.methods) {
      final String channelName = makeChannelName(api, func);
      final String returnType = func.returnType.isVoid
          ? ''
          : _nullsafeKotlinTypeForDartType(func.returnType);
      String sendArgument;
      if (func.arguments.isEmpty) {
        indent.write('fun ${func.name}(callback: ($returnType) -> Unit) ');
        sendArgument = 'null';
      } else {
        final Iterable<String> argTypes = func.arguments
            .map((NamedType e) => _nullsafeKotlinTypeForDartType(e.type));
        final Iterable<String> argNames =
            indexMap(func.arguments, _getSafeArgumentName);
        sendArgument = 'listOf(${argNames.join(', ')})';
        final String argsSignature = map2(argTypes, argNames,
            (String type, String name) => '$name: $type').join(', ');
        if (func.returnType.isVoid) {
          indent
              .write('fun ${func.name}($argsSignature, callback: () -> Unit) ');
        } else {
          indent.write(
              'fun ${func.name}($argsSignature, callback: ($returnType) -> Unit) ');
        }
      }
      indent.scoped('{', '}', () {
        const String channel = 'channel';
        indent.writeln(
            'val $channel = BasicMessageChannel<Any?>(binaryMessenger, "$channelName", codec)');
        indent.write('$channel.send($sendArgument) ');
        if (func.returnType.isVoid) {
          indent.scoped('{', '}', () {
            indent.writeln('callback()');
          });
        } else {
          final String forceUnwrap = func.returnType.isNullable ? '?' : '';
          indent.scoped('{', '}', () {
            indent.writeln('val result = it as$forceUnwrap $returnType');
            indent.writeln('callback(result)');
          });
        }
      });
    }
  });
}

String _castForceUnwrap(String value, TypeDeclaration type, Root root) {
  if (isEnum(root, type)) {
    final String forceUnwrap = type.isNullable ? '' : '!!';
    final String nullableConditionPrefix =
        type.isNullable ? '$value == null ? null : ' : '';
    return '$nullableConditionPrefix${_kotlinTypeForDartType(type)}.ofRaw($value as Int)$forceUnwrap';
  } else {
    final String castUnwrap = type.isNullable ? '?' : '';

    // The StandardMessageCodec can give us [Integer, Long] for
    // a Dart 'int'.  To keep things simple we just use 64bit
    // longs in Pigeon with Kotlin.
    if (type.baseName == 'int') {
      return '$value.let { if (it is Int) it.toLong() else it as$castUnwrap Long }';
    } else {
      return '$value as$castUnwrap ${_kotlinTypeForDartType(type)}';
    }
  }
}

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in Kotlin code.
String _flattenTypeArguments(List<TypeDeclaration> args) {
  return args.map(_kotlinTypeForDartType).join(', ');
}

String _kotlinTypeForBuiltinGenericDartType(TypeDeclaration type) {
  if (type.typeArguments.isEmpty) {
    switch (type.baseName) {
      case 'List':
        return 'List<Any?>';
      case 'Map':
        return 'Map<Any, Any?>';
      default:
        return 'Any';
    }
  } else {
    switch (type.baseName) {
      case 'List':
        return 'List<${_nullsafeKotlinTypeForDartType(type.typeArguments.first)}>';
      case 'Map':
        return 'Map<${_nullsafeKotlinTypeForDartType(type.typeArguments.first)}, ${_nullsafeKotlinTypeForDartType(type.typeArguments.last)}>';
      default:
        return '${type.baseName}<${_flattenTypeArguments(type.typeArguments)}>';
    }
  }
}

String? _kotlinTypeForBuiltinDartType(TypeDeclaration type) {
  const Map<String, String> kotlinTypeForDartTypeMap = <String, String>{
    'void': 'Void',
    'bool': 'Boolean',
    'String': 'String',
    'int': 'Long',
    'double': 'Double',
    'Uint8List': 'ByteArray',
    'Int32List': 'IntArray',
    'Int64List': 'LongArray',
    'Float32List': 'FloatArray',
    'Float64List': 'DoubleArray',
    'Object': 'Any',
  };
  if (kotlinTypeForDartTypeMap.containsKey(type.baseName)) {
    return kotlinTypeForDartTypeMap[type.baseName];
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return _kotlinTypeForBuiltinGenericDartType(type);
  } else {
    return null;
  }
}

String _kotlinTypeForDartType(TypeDeclaration type) {
  return _kotlinTypeForBuiltinDartType(type) ?? type.baseName;
}

String _nullsafeKotlinTypeForDartType(TypeDeclaration type) {
  final String nullSafe = type.isNullable ? '?' : '';
  return '${_kotlinTypeForDartType(type)}$nullSafe';
}

/// Generates the ".kotlin" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateKotlin(KotlinOptions options, Root root, StringSink sink) {
  final Set<String> rootClassNameSet =
      root.classes.map((Class x) => x.name).toSet();
  final Set<String> rootEnumNameSet =
      root.enums.map((Enum x) => x.name).toSet();
  final Indent indent = Indent(sink);

  HostDatatype getHostDatatype(NamedType field) {
    return getFieldHostDatatype(field, root.classes, root.enums,
        (TypeDeclaration x) => _kotlinTypeForBuiltinDartType(x));
  }

  void writeHeader() {
    if (options.copyrightHeader != null) {
      addLines(indent, options.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
    indent.writeln('// $seeAlsoWarning');
  }

  void writeImports() {
    indent.writeln('import android.util.Log');
    indent.writeln('import io.flutter.plugin.common.BasicMessageChannel');
    indent.writeln('import io.flutter.plugin.common.BinaryMessenger');
    indent.writeln('import io.flutter.plugin.common.MessageCodec');
    indent.writeln('import io.flutter.plugin.common.StandardMessageCodec');
    indent.writeln('import java.io.ByteArrayOutputStream');
    indent.writeln('import java.nio.ByteBuffer');
  }

  void writeEnum(Enum anEnum) {
    indent.write('enum class ${anEnum.name}(val raw: Int) ');
    indent.scoped('{', '}', () {
      // We use explicit indexing here as use of the ordinal() method is
      // discouraged. The toMap and fromMap API matches class API to allow
      // the same code to work with enums and classes, but this
      // can also be done directly in the host and flutter APIs.
      int index = 0;
      for (final String member in anEnum.members) {
        indent.write('${member.toUpperCase()}($index)');
        if (index != anEnum.members.length - 1) {
          indent.addln(',');
        } else {
          indent.addln(';');
        }
        index++;
      }

      indent.writeln('');
      indent.write('companion object ');
      indent.scoped('{', '}', () {
        indent.write('fun ofRaw(raw: Int): ${anEnum.name}? ');
        indent.scoped('{', '}', () {
          indent.writeln('return values().firstOrNull { it.raw == raw }');
        });
      });
    });
  }

  void writeDataClass(Class klass) {
    void writeField(NamedType field) {
      indent.write(
          'val ${field.name}: ${_nullsafeKotlinTypeForDartType(field.type)}');
      final String defaultNil = field.type.isNullable ? ' = null' : '';
      indent.add(defaultNil);
    }

    void writeToMap() {
      indent.write('fun toMap(): Map<String, Any?> ');
      indent.scoped('{', '}', () {
        indent.writeln('val map = mutableMapOf<String, Any?>()');

        for (final NamedType field in klass.fields) {
          final HostDatatype hostDatatype = getHostDatatype(field);
          String toWriteValue = '';
          final String fieldName = field.name;
          final String prefix = field.type.isNullable ? 'it' : fieldName;
          if (!hostDatatype.isBuiltin &&
              rootClassNameSet.contains(field.type.baseName)) {
            toWriteValue = '$prefix.toMap()';
          } else if (!hostDatatype.isBuiltin &&
              rootEnumNameSet.contains(field.type.baseName)) {
            toWriteValue = '$prefix.raw';
          } else {
            toWriteValue = prefix;
          }

          if (field.type.isNullable) {
            indent.writeln(
                '$fieldName?.let { map["${field.name}"] = $toWriteValue }');
          } else {
            indent.writeln('map["${field.name}"] = $toWriteValue');
          }
        }

        indent.writeln('return map');
      });
    }

    void writeFromMap() {
      final String className = klass.name;

      indent.write('companion object ');
      indent.scoped('{', '}', () {
        indent.writeln('@Suppress("UNCHECKED_CAST")');
        indent.write('fun fromMap(map: Map<String, Any?>): $className ');

        indent.scoped('{', '}', () {
          for (final NamedType field in klass.fields) {
            final HostDatatype hostDatatype = getHostDatatype(field);

            // The StandardMessageCodec can give us [Integer, Long] for
            // a Dart 'int'.  To keep things simple we just use 64bit
            // longs in Pigeon with Kotlin.
            final bool isInt = field.type.baseName == 'int';

            final String mapValue = 'map["${field.name}"]';
            final String fieldType = _kotlinTypeForDartType(field.type);

            if (field.type.isNullable) {
              if (!hostDatatype.isBuiltin &&
                  rootClassNameSet.contains(field.type.baseName)) {
                indent.write('val ${field.name}: $fieldType? = ');
                indent.add('($mapValue as? Map<String, Any?>)?.let ');
                indent.scoped('{', '}', () {
                  indent.writeln('$fieldType.fromMap(it)');
                });
              } else if (!hostDatatype.isBuiltin &&
                  rootEnumNameSet.contains(field.type.baseName)) {
                indent.write('val ${field.name}: $fieldType? = ');
                indent.add('($mapValue as? Int)?.let ');
                indent.scoped('{', '}', () {
                  indent.writeln('$fieldType.ofRaw(it)');
                });
              } else if (isInt) {
                indent.write('val ${field.name} = $mapValue');
                indent.addln(
                    '.let { if (it is Int) it.toLong() else it as? Long }');
              } else {
                indent.writeln('val ${field.name} = $mapValue as? $fieldType');
              }
            } else {
              if (!hostDatatype.isBuiltin &&
                  rootClassNameSet.contains(field.type.baseName)) {
                indent.writeln(
                    'val ${field.name} = $fieldType.fromMap($mapValue as Map<String, Any?>)');
              } else if (!hostDatatype.isBuiltin &&
                  rootEnumNameSet.contains(field.type.baseName)) {
                indent.write(
                    'val ${field.name} = $fieldType.ofRaw($mapValue as Int)!!');
              } else {
                indent.writeln('val ${field.name} = $mapValue as $fieldType');
              }
            }
          }

          indent.writeln('');
          indent.write('return $className(');
          for (final NamedType field in klass.fields) {
            final String comma = klass.fields.last == field ? '' : ', ';
            indent.add('${field.name}$comma');
          }
          indent.addln(')');
        });
      });
    }

    indent.writeln(
        '/** Generated class from Pigeon that represents data sent in messages. */');
    indent.write('data class ${klass.name}(');
    indent.scoped('', '', () {
      for (final NamedType element in klass.fields) {
        writeField(element);
        if (klass.fields.last != element) {
          indent.addln(',');
        }
      }
    });

    indent.scoped(') {', '}', () {
      writeFromMap();
      writeToMap();
    });
  }

  void writeApi(Api api) {
    if (api.location == ApiLocation.host) {
      _writeHostApi(indent, api, root);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApi(indent, api);
    }
  }

  void writeWrapResult() {
    indent.write('private fun wrapResult(result: Any?): Map<String, Any?> ');
    indent.scoped('{', '}', () {
      indent.writeln('return hashMapOf("result" to result)');
    });
  }

  void writeWrapError() {
    indent.write(
        'private fun wrapError(exception: Throwable): Map<String, Any> ');
    indent.scoped('{', '}', () {
      indent.write('return ');
      indent.scoped('hashMapOf<String, Any>(', ')', () {
        indent.write('"error" to ');
        indent.scoped('hashMapOf<String, Any>(', ')', () {
          indent.writeln(
              '"${Keys.errorCode}" to exception.javaClass.simpleName,');
          indent.writeln('"${Keys.errorMessage}" to exception.toString(),');
          indent.writeln(
              '"${Keys.errorDetails}" to "Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)');
        });
      });
    });
  }

  writeHeader();
  indent.addln('');
  if (options.package != null) {
    indent.writeln('package ${options.package}');
  }
  indent.addln('');
  writeImports();
  indent.addln('');
  indent.writeln('/** Generated class from Pigeon. */');
  for (final Enum anEnum in root.enums) {
    indent.writeln('');
    writeEnum(anEnum);
  }

  for (final Class klass in root.classes) {
    indent.addln('');
    writeDataClass(klass);
  }

  if (root.apis.any((Api api) =>
      api.location == ApiLocation.host &&
      api.methods.any((Method it) => it.isAsynchronous))) {
    indent.addln('');
  }

  for (final Api api in root.apis) {
    _writeCodec(indent, api, root);
    indent.addln('');
    writeApi(api);
  }

  indent.addln('');
  writeWrapResult();
  indent.addln('');
  writeWrapError();
}
