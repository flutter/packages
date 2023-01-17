// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
import 'generator.dart';
import 'generator_tools.dart';
import 'pigeon_lib.dart' show TaskQueueType;

/// Documentation open symbol.
const String _docCommentPrefix = '/**';

/// Documentation continuation symbol.
const String _docCommentContinuation = ' *';

/// Documentation close symbol.
const String _docCommentSuffix = ' */';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(
  _docCommentPrefix,
  closeCommentToken: _docCommentSuffix,
  blockContinuationToken: _docCommentContinuation,
);

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

/// Class that manages all Kotlin code generation.
class KotlinGenerator extends StructuredGenerator<KotlinOptions> {
  /// Instantiates a Kotlin Generator.
  const KotlinGenerator();

  @override
  void writeFilePrologue(
      KotlinOptions generatorOptions, Root root, Indent indent) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
    indent.writeln('// $seeAlsoWarning');
  }

  @override
  void writeFileImports(
      KotlinOptions generatorOptions, Root root, Indent indent) {
    indent.addln('');
    if (generatorOptions.package != null) {
      indent.writeln('package ${generatorOptions.package}');
    }
    indent.addln('');
    indent.writeln('import android.util.Log');
    indent.writeln('import io.flutter.plugin.common.BasicMessageChannel');
    indent.writeln('import io.flutter.plugin.common.BinaryMessenger');
    indent.writeln('import io.flutter.plugin.common.MessageCodec');
    indent.writeln('import io.flutter.plugin.common.StandardMessageCodec');
    indent.writeln('import java.io.ByteArrayOutputStream');
    indent.writeln('import java.nio.ByteBuffer');
  }

  @override
  void writeEnum(
      KotlinOptions generatorOptions, Root root, Indent indent, Enum anEnum) {
    indent.writeln('');
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.write('enum class ${anEnum.name}(val raw: Int) ');
    indent.scoped('{', '}', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.write('${member.name.toUpperCase()}($index)');
        if (index != anEnum.members.length - 1) {
          indent.addln(',');
        } else {
          indent.addln(';');
        }
      });

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

  @override
  void writeDataClass(
      KotlinOptions generatorOptions, Root root, Indent indent, Class klass) {
    final Set<String> customClassNames =
        root.classes.map((Class x) => x.name).toSet();
    final Set<String> customEnumNames =
        root.enums.map((Enum x) => x.name).toSet();

    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents data sent in messages.'
    ];
    indent.addln('');
    addDocumentationComments(
        indent, klass.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('data class ${klass.name} ');
    indent.scoped('(', '', () {
      for (final NamedType element in getFieldsInSerializationOrder(klass)) {
        _writeClassField(indent, element);
        if (getFieldsInSerializationOrder(klass).last != element) {
          indent.addln(',');
        } else {
          indent.addln('');
        }
      }
    });

    indent.scoped(') {', '}', () {
      writeClassDecode(generatorOptions, root, indent, klass, customClassNames,
          customEnumNames);
      writeClassEncode(generatorOptions, root, indent, klass, customClassNames,
          customEnumNames);
    });
  }

  @override
  void writeClassEncode(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  ) {
    indent.write('fun toList(): List<Any?> ');
    indent.scoped('{', '}', () {
      indent.write('return listOf<Any?>');
      indent.scoped('(', ')', () {
        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          final HostDatatype hostDatatype = _getHostDatatype(root, field);
          String toWriteValue = '';
          final String fieldName = field.name;
          if (!hostDatatype.isBuiltin &&
              customClassNames.contains(field.type.baseName)) {
            toWriteValue = '$fieldName?.toList()';
          } else if (!hostDatatype.isBuiltin &&
              customEnumNames.contains(field.type.baseName)) {
            toWriteValue = '$fieldName?.raw';
          } else {
            toWriteValue = fieldName;
          }
          indent.writeln('$toWriteValue,');
        }
      });
    });
  }

  @override
  void writeClassDecode(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  ) {
    final String className = klass.name;

    indent.write('companion object ');
    indent.scoped('{', '}', () {
      indent.writeln('@Suppress("UNCHECKED_CAST")');
      indent.write('fun fromList(list: List<Any?>): $className ');

      indent.scoped('{', '}', () {
        enumerate(getFieldsInSerializationOrder(klass),
            (int index, final NamedType field) {
          final HostDatatype hostDatatype = _getHostDatatype(root, field);

          // The StandardMessageCodec can give us [Integer, Long] for
          // a Dart 'int'.  To keep things simple we just use 64bit
          // longs in Pigeon with Kotlin.
          final bool isInt = field.type.baseName == 'int';

          final String listValue = 'list[$index]';
          final String fieldType = _kotlinTypeForDartType(field.type);

          if (field.type.isNullable) {
            if (!hostDatatype.isBuiltin &&
                customClassNames.contains(field.type.baseName)) {
              indent.write('val ${field.name}: $fieldType? = ');
              indent.add('($listValue as? List<Any?>)?.let ');
              indent.scoped('{', '}', () {
                indent.writeln('$fieldType.fromList(it)');
              });
            } else if (!hostDatatype.isBuiltin &&
                customEnumNames.contains(field.type.baseName)) {
              indent.write('val ${field.name}: $fieldType? = ');
              indent.add('($listValue as? Int)?.let ');
              indent.scoped('{', '}', () {
                indent.writeln('$fieldType.ofRaw(it)');
              });
            } else if (isInt) {
              indent.write('val ${field.name} = $listValue');
              indent.addln(
                  '.let { if (it is Int) it.toLong() else it as? Long }');
            } else {
              indent.writeln('val ${field.name} = $listValue as? $fieldType');
            }
          } else {
            if (!hostDatatype.isBuiltin &&
                customClassNames.contains(field.type.baseName)) {
              indent.writeln(
                  'val ${field.name} = $fieldType.fromList($listValue as List<Any?>)');
            } else if (!hostDatatype.isBuiltin &&
                customEnumNames.contains(field.type.baseName)) {
              indent.writeln(
                  'val ${field.name} = $fieldType.ofRaw($listValue as Int)!!');
            } else {
              indent.writeln('val ${field.name} = $listValue as $fieldType');
            }
          }
        });

        indent.write('return $className(');
        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          final String comma =
              getFieldsInSerializationOrder(klass).last == field ? '' : ', ';
          indent.add('${field.name}$comma');
        }
        indent.addln(')');
      });
    });
  }

  void _writeClassField(Indent indent, NamedType field) {
    addDocumentationComments(
        indent, field.documentationComments, _docCommentSpec);
    indent.write(
        'val ${field.name}: ${_nullsafeKotlinTypeForDartType(field.type)}');
    final String defaultNil = field.type.isNullable ? ' = null' : '';
    indent.add(defaultNil);
  }

  @override
  void writeApis(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
  ) {
    if (root.apis.any((Api api) =>
        api.location == ApiLocation.host &&
        api.methods.any((Method it) => it.isAsynchronous))) {
      indent.addln('');
    }
    super.writeApis(generatorOptions, root, indent);
  }

  /// Writes the code for a flutter [Api], [api].
  /// Example:
  /// class Foo(private val binaryMessenger: BinaryMessenger) {
  ///   fun add(x: Int, y: Int, callback: (Int?) -> Unit) {...}
  /// }
  @override
  void writeFlutterApi(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Api api,
  ) {
    assert(api.location == ApiLocation.flutter);
    final bool isCustomCodec = getCodecClasses(api, root).isNotEmpty;
    if (isCustomCodec) {
      _writeCodec(indent, api, root);
    }

    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents Flutter messages that can be called from Kotlin.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    final String apiName = api.name;
    indent.writeln('@Suppress("UNCHECKED_CAST")');
    indent
        .write('class $apiName(private val binaryMessenger: BinaryMessenger) ');
    indent.scoped('{', '}', () {
      indent.write('companion object ');
      indent.scoped('{', '}', () {
        indent.writeln('/** The codec used by $apiName. */');
        indent.write('val codec: MessageCodec<Any?> by lazy ');
        indent.scoped('{', '}', () {
          if (isCustomCodec) {
            indent.writeln(_getCodecName(api));
          } else {
            indent.writeln('StandardMessageCodec()');
          }
        });
      });

      for (final Method func in api.methods) {
        final String channelName = makeChannelName(api, func);
        final String returnType = func.returnType.isVoid
            ? ''
            : _nullsafeKotlinTypeForDartType(func.returnType);
        String sendArgument;

        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);

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
            indent.write(
                'fun ${func.name}($argsSignature, callback: () -> Unit) ');
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

  /// Write the kotlin code that represents a host [Api], [api].
  /// Example:
  /// interface Foo {
  ///   Int add(x: Int, y: Int);
  ///   companion object {
  ///     fun setUp(binaryMessenger: BinaryMessenger, api: Api) {...}
  ///   }
  /// }
  @override
  void writeHostApi(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Api api,
  ) {
    assert(api.location == ApiLocation.host);

    final String apiName = api.name;

    final bool isCustomCodec = getCodecClasses(api, root).isNotEmpty;
    if (isCustomCodec) {
      _writeCodec(indent, api, root);
    }

    const List<String> generatedMessages = <String>[
      ' Generated interface from Pigeon that represents a handler of messages from Flutter.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('interface $apiName ');
    indent.scoped('{', '}', () {
      for (final Method method in api.methods) {
        final List<String> argSignature = <String>[];
        if (method.arguments.isNotEmpty) {
          final Iterable<String> argTypes = method.arguments
              .map((NamedType e) => _nullsafeKotlinTypeForDartType(e.type));
          final Iterable<String> argNames =
              method.arguments.map((NamedType e) => e.name);
          argSignature.addAll(
              map2(argTypes, argNames, (String argType, String argName) {
            return '$argName: $argType';
          }));
        }

        final String returnType = method.returnType.isVoid
            ? ''
            : _nullsafeKotlinTypeForDartType(method.returnType);

        addDocumentationComments(
            indent, method.documentationComments, _docCommentSpec);

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
        indent.write('val codec: MessageCodec<Any?> by lazy ');
        indent.scoped('{', '}', () {
          if (isCustomCodec) {
            indent.writeln(_getCodecName(api));
          } else {
            indent.writeln('StandardMessageCodec()');
          }
        });
        indent.writeln(
            '/** Sets up an instance of `$apiName` to handle messages through the `binaryMessenger`. */');
        indent.writeln('@Suppress("UNCHECKED_CAST")');
        indent.write(
            'fun setUp(binaryMessenger: BinaryMessenger, api: $apiName?) ');
        indent.scoped('{', '}', () {
          for (final Method method in api.methods) {
            indent.write('run ');
            indent.scoped('{', '}', () {
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
                  indent.writeln('var wrapped = listOf<Any?>()');
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
                      final String resultValue =
                          method.returnType.isVoid ? 'null' : 'it';
                      indent.scoped('{', '}', () {
                        indent.writeln('reply.reply(wrapResult($resultValue))');
                      });
                    } else if (method.returnType.isVoid) {
                      indent.writeln(call);
                      indent.writeln('wrapped = listOf<Any?>(null)');
                    } else {
                      indent.writeln('wrapped = listOf<Any?>($call)');
                    }
                  }, addTrailingNewline: false);
                  indent.add(' catch (exception: Error) ');
                  indent.scoped('{', '}', () {
                    indent.writeln('wrapped = wrapError(exception)');
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

  /// Writes the codec class that will be used by [api].
  /// Example:
  /// private static class FooCodec extends StandardMessageCodec {...}
  void _writeCodec(Indent indent, Api api, Root root) {
    assert(getCodecClasses(api, root).isNotEmpty);
    final Iterable<EnumeratedClass> codecClasses = getCodecClasses(api, root);
    final String codecName = _getCodecName(api);
    indent.writeln('@Suppress("UNCHECKED_CAST")');
    indent.write('private object $codecName : StandardMessageCodec() ');
    indent.scoped('{', '}', () {
      indent.write(
          'override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? ');
      indent.scoped('{', '}', () {
        indent.write('return when (type) ');
        indent.scoped('{', '}', () {
          for (final EnumeratedClass customClass in codecClasses) {
            indent.write('${customClass.enumeration}.toByte() -> ');
            indent.scoped('{', '}', () {
              indent.write('return (readValue(buffer) as? List<Any?>)?.let ');
              indent.scoped('{', '}', () {
                indent.writeln('${customClass.name}.fromList(it)');
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
          for (final EnumeratedClass customClass in codecClasses) {
            indent.write('is ${customClass.name} -> ');
            indent.scoped('{', '}', () {
              indent.writeln('stream.write(${customClass.enumeration})');
              indent.writeln('writeValue(stream, value.toList())');
            });
          }
          indent.writeln('else -> super.writeValue(stream, value)');
        });
      });
    });
    indent.addln('');
  }

  void _writeWrapResult(Indent indent) {
    indent.addln('');
    indent.write('private fun wrapResult(result: Any?): List<Any?> ');
    indent.scoped('{', '}', () {
      indent.writeln('return listOf(result)');
    });
  }

  void _writeWrapError(Indent indent) {
    indent.addln('');
    indent.write('private fun wrapError(exception: Throwable): List<Any> ');
    indent.scoped('{', '}', () {
      indent.write('return ');
      indent.scoped('listOf<Any>(', ')', () {
        indent.writeln('exception.javaClass.simpleName,');
        indent.writeln('exception.toString(),');
        indent.writeln(
            '"Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)');
      });
    });
  }

  @override
  void writeGeneralUtilities(
      KotlinOptions generatorOptions, Root root, Indent indent) {
    _writeWrapResult(indent);
    _writeWrapError(indent);
  }
}

HostDatatype _getHostDatatype(Root root, NamedType field) {
  return getFieldHostDatatype(field, root.classes, root.enums,
      (TypeDeclaration x) => _kotlinTypeForBuiltinDartType(x));
}

/// Calculates the name of the codec that will be generated for [api].
String _getCodecName(Api api) => '${api.name}Codec';

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : argument.name;

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}Arg';

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
