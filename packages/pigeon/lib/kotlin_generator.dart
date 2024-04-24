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
    this.errorClassName,
    this.includeErrorClass = true,
  });

  /// The package where the generated class will live.
  final String? package;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The name of the error class used for passing custom error parameters.
  final String? errorClassName;

  /// Whether to include the error class in generation.
  ///
  /// This should only ever be set to false if you have another generated
  /// Kotlin file in the same directory.
  final bool includeErrorClass;

  /// Creates a [KotlinOptions] from a Map representation where:
  /// `x = KotlinOptions.fromMap(x.toMap())`.
  static KotlinOptions fromMap(Map<String, Object> map) {
    return KotlinOptions(
      package: map['package'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      errorClassName: map['errorClassName'] as String?,
      includeErrorClass: map['includeErrorClass'] as bool? ?? true,
    );
  }

  /// Converts a [KotlinOptions] to a Map representation where:
  /// `x = KotlinOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (package != null) 'package': package!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (errorClassName != null) 'errorClassName': errorClassName!,
      'includeErrorClass': includeErrorClass,
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
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
  }

  @override
  void writeFileImports(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    if (generatorOptions.package != null) {
      indent.writeln('package ${generatorOptions.package}');
    }
    indent.newln();
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
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.write('enum class ${anEnum.name}(val raw: Int) ');
    indent.addScoped('{', '}', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        final String nameScreamingSnakeCase = member.name
            .replaceAllMapped(
                RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => '_${m.group(0)}')
            .toUpperCase();
        indent.write('$nameScreamingSnakeCase($index)');
        if (index != anEnum.members.length - 1) {
          indent.addln(',');
        } else {
          indent.addln(';');
        }
      });

      indent.newln();
      indent.write('companion object ');
      indent.addScoped('{', '}', () {
        indent.write('fun ofRaw(raw: Int): ${anEnum.name}? ');
        indent.addScoped('{', '}', () {
          indent.writeln('return values().firstOrNull { it.raw == raw }');
        });
      });
    });
  }

  @override
  void writeDataClass(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents data sent in messages.'
    ];
    indent.newln();
    addDocumentationComments(
        indent, classDefinition.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('data class ${classDefinition.name} ');
    indent.addScoped('(', '', () {
      for (final NamedType element
          in getFieldsInSerializationOrder(classDefinition)) {
        _writeClassField(indent, element);
        if (getFieldsInSerializationOrder(classDefinition).last != element) {
          indent.addln(',');
        } else {
          indent.newln();
        }
      }
    });

    indent.addScoped(') {', '}', () {
      writeClassDecode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
      writeClassEncode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
    });
  }

  @override
  void writeClassEncode(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.write('fun toList(): List<Any?> ');
    indent.addScoped('{', '}', () {
      indent.write('return listOf<Any?>');
      indent.addScoped('(', ')', () {
        for (final NamedType field
            in getFieldsInSerializationOrder(classDefinition)) {
          final HostDatatype hostDatatype = _getHostDatatype(root, field);
          String toWriteValue = '';
          final String fieldName = field.name;
          final String safeCall = field.type.isNullable ? '?' : '';
          if (field.type.isClass) {
            toWriteValue = '$fieldName$safeCall.toList()';
          } else if (!hostDatatype.isBuiltin && field.type.isEnum) {
            toWriteValue = '$fieldName$safeCall.raw';
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
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String className = classDefinition.name;

    indent.write('companion object ');
    indent.addScoped('{', '}', () {
      indent.writeln('@Suppress("UNCHECKED_CAST")');
      indent.write('fun fromList(list: List<Any?>): $className ');

      indent.addScoped('{', '}', () {
        enumerate(getFieldsInSerializationOrder(classDefinition),
            (int index, final NamedType field) {
          final String listValue = 'list[$index]';
          final String fieldType = _kotlinTypeForDartType(field.type);

          if (field.type.isNullable) {
            if (field.type.isClass) {
              indent.write('val ${field.name}: $fieldType? = ');
              indent.add('($listValue as List<Any?>?)?.let ');
              indent.addScoped('{', '}', () {
                indent.writeln('$fieldType.fromList(it)');
              });
            } else if (field.type.isEnum) {
              indent.write('val ${field.name}: $fieldType? = ');
              indent.add('($listValue as Int?)?.let ');
              indent.addScoped('{', '}', () {
                indent.writeln('$fieldType.ofRaw(it)');
              });
            } else {
              indent.writeln(
                  'val ${field.name} = ${_cast(indent, listValue, type: field.type)}');
            }
          } else {
            if (field.type.isClass) {
              indent.writeln(
                  'val ${field.name} = $fieldType.fromList($listValue as List<Any?>)');
            } else if (field.type.isEnum) {
              indent.writeln(
                  'val ${field.name} = $fieldType.ofRaw($listValue as Int)!!');
            } else {
              indent.writeln(
                  'val ${field.name} = ${_cast(indent, listValue, type: field.type)}');
            }
          }
        });

        indent.write('return $className(');
        for (final NamedType field
            in getFieldsInSerializationOrder(classDefinition)) {
          final String comma =
              getFieldsInSerializationOrder(classDefinition).last == field
                  ? ''
                  : ', ';
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
        'val ${field.name}: ${_nullSafeKotlinTypeForDartType(field.type)}');
    final String defaultNil = field.type.isNullable ? ' = null' : '';
    indent.add(defaultNil);
  }

  @override
  void writeApis(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.apis.any((Api api) =>
        api is AstHostApi &&
        api.methods.any((Method it) => it.isAsynchronous))) {
      indent.newln();
    }
    super.writeApis(generatorOptions, root, indent,
        dartPackageName: dartPackageName);
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
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
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
    indent.write(
        'class $apiName(private val binaryMessenger: BinaryMessenger, private val messageChannelSuffix: String = "") ');
    indent.addScoped('{', '}', () {
      indent.write('companion object ');
      indent.addScoped('{', '}', () {
        indent.writeln('/** The codec used by $apiName. */');
        indent.write('val codec: MessageCodec<Any?> by lazy ');
        indent.addScoped('{', '}', () {
          if (isCustomCodec) {
            indent.writeln(_getCodecName(api));
          } else {
            indent.writeln('StandardMessageCodec()');
          }
        });
      });

      for (final Method method in api.methods) {
        _writeFlutterMethod(
          indent,
          generatorOptions: generatorOptions,
          name: method.name,
          parameters: method.parameters,
          returnType: method.returnType,
          channelName: makeChannelName(api, method, dartPackageName),
          documentationComments: method.documentationComments,
          dartPackageName: dartPackageName,
        );
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
  ///
  @override
  void writeHostApi(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
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
    indent.addScoped('{', '}', () {
      for (final Method method in api.methods) {
        _writeMethodDeclaration(
          indent,
          name: method.name,
          documentationComments: method.documentationComments,
          returnType: method.returnType,
          parameters: method.parameters,
          isAsynchronous: method.isAsynchronous,
        );
      }

      indent.newln();
      indent.write('companion object ');
      indent.addScoped('{', '}', () {
        indent.writeln('/** The codec used by $apiName. */');
        indent.write('val codec: MessageCodec<Any?> by lazy ');
        indent.addScoped('{', '}', () {
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
            'fun setUp(binaryMessenger: BinaryMessenger, api: $apiName?, messageChannelSuffix: String = "") ');
        indent.addScoped('{', '}', () {
          indent.writeln(
              r'val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""');
          for (final Method method in api.methods) {
            _writeHostMethodMessageHandler(
              indent,
              api: api,
              name: method.name,
              channelName: makeChannelName(api, method, dartPackageName),
              taskQueueType: method.taskQueueType,
              parameters: method.parameters,
              returnType: method.returnType,
              isAsynchronous: method.isAsynchronous,
            );
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
    indent.addScoped('{', '}', () {
      indent.write(
          'override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? ');
      indent.addScoped('{', '}', () {
        indent.write('return when (type) ');
        indent.addScoped('{', '}', () {
          for (final EnumeratedClass customClass in codecClasses) {
            indent.write('${customClass.enumeration}.toByte() -> ');
            indent.addScoped('{', '}', () {
              indent.write('return (readValue(buffer) as? List<Any?>)?.let ');
              indent.addScoped('{', '}', () {
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
        indent.addScoped('{', '}', () {
          for (final EnumeratedClass customClass in codecClasses) {
            indent.write('is ${customClass.name} -> ');
            indent.addScoped('{', '}', () {
              indent.writeln('stream.write(${customClass.enumeration})');
              indent.writeln('writeValue(stream, value.toList())');
            });
          }
          indent.writeln('else -> super.writeValue(stream, value)');
        });
      });
    });
    indent.newln();
  }

  void _writeWrapResult(Indent indent) {
    indent.newln();
    indent.write('private fun wrapResult(result: Any?): List<Any?> ');
    indent.addScoped('{', '}', () {
      indent.writeln('return listOf(result)');
    });
  }

  void _writeWrapError(KotlinOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.write('private fun wrapError(exception: Throwable): List<Any?> ');
    indent.addScoped('{', '}', () {
      indent
          .write('if (exception is ${_getErrorClassName(generatorOptions)}) ');
      indent.addScoped('{', '}', () {
        indent.write('return ');
        indent.addScoped('listOf(', ')', () {
          indent.writeln('exception.code,');
          indent.writeln('exception.message,');
          indent.writeln('exception.details');
        });
      }, addTrailingNewline: false);
      indent.addScoped(' else {', '}', () {
        indent.write('return ');
        indent.addScoped('listOf(', ')', () {
          indent.writeln('exception.javaClass.simpleName,');
          indent.writeln('exception.toString(),');
          indent.writeln(
              '"Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)');
        });
      });
    });
  }

  void _writeErrorClass(KotlinOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.writeln('/**');
    indent.writeln(
        ' * Error class for passing custom error details to Flutter via a thrown PlatformException.');
    indent.writeln(' * @property code The error code.');
    indent.writeln(' * @property message The error message.');
    indent.writeln(
        ' * @property details The error details. Must be a datatype supported by the api codec.');
    indent.writeln(' */');
    indent.write('class ${_getErrorClassName(generatorOptions)} ');
    indent.addScoped('(', ')', () {
      indent.writeln('val code: String,');
      indent.writeln('override val message: String? = null,');
      indent.writeln('val details: Any? = null');
    }, addTrailingNewline: false);
    indent.addln(' : Throwable()');
  }

  void _writeCreateConnectionError(
      KotlinOptions generatorOptions, Indent indent) {
    final String errorClassName = _getErrorClassName(generatorOptions);
    indent.newln();
    indent.write(
        'private fun createConnectionError(channelName: String): $errorClassName ');
    indent.addScoped('{', '}', () {
      indent.write(
          'return $errorClassName("channel-error",  "Unable to establish connection on channel: \'\$channelName\'.", "")');
    });
  }

  @override
  void writeGeneralUtilities(
    KotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final bool hasHostApi = root.apis
        .whereType<AstHostApi>()
        .any((Api api) => api.methods.isNotEmpty);
    final bool hasFlutterApi = root.apis
        .whereType<AstFlutterApi>()
        .any((Api api) => api.methods.isNotEmpty);

    if (hasHostApi) {
      _writeWrapResult(indent);
      _writeWrapError(generatorOptions, indent);
    }
    if (hasFlutterApi) {
      _writeCreateConnectionError(generatorOptions, indent);
    }
    if (generatorOptions.includeErrorClass) {
      _writeErrorClass(generatorOptions, indent);
    }
  }

  static void _writeMethodDeclaration(
    Indent indent, {
    required String name,
    required TypeDeclaration returnType,
    required List<Parameter> parameters,
    List<String> documentationComments = const <String>[],
    int? minApiRequirement,
    bool isAsynchronous = false,
    bool isAbstract = false,
    String Function(int index, NamedType type) getArgumentName =
        _getArgumentName,
  }) {
    final List<String> argSignature = <String>[];
    if (parameters.isNotEmpty) {
      final Iterable<String> argTypes = parameters
          .map((NamedType e) => _nullSafeKotlinTypeForDartType(e.type));
      final Iterable<String> argNames = indexMap(parameters, getArgumentName);
      argSignature.addAll(
        map2(
          argTypes,
          argNames,
          (String argType, String argName) {
            return '$argName: $argType';
          },
        ),
      );
    }

    final String returnTypeString =
        returnType.isVoid ? '' : _nullSafeKotlinTypeForDartType(returnType);

    final String resultType = returnType.isVoid ? 'Unit' : returnTypeString;
    addDocumentationComments(indent, documentationComments, _docCommentSpec);

    if (minApiRequirement != null) {
      indent.writeln(
        '@androidx.annotation.RequiresApi(api = $minApiRequirement)',
      );
    }

    final String abstractKeyword = isAbstract ? 'abstract ' : '';

    if (isAsynchronous) {
      argSignature.add('callback: (Result<$resultType>) -> Unit');
      indent.writeln('${abstractKeyword}fun $name(${argSignature.join(', ')})');
    } else if (returnType.isVoid) {
      indent.writeln('${abstractKeyword}fun $name(${argSignature.join(', ')})');
    } else {
      indent.writeln(
        '${abstractKeyword}fun $name(${argSignature.join(', ')}): $returnTypeString',
      );
    }
  }

  void _writeHostMethodMessageHandler(
    Indent indent, {
    required Api api,
    required String name,
    required String channelName,
    required TaskQueueType taskQueueType,
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    bool isAsynchronous = false,
    String Function(List<String> safeArgNames, {required String apiVarName})?
        onCreateCall,
  }) {
    indent.write('run ');
    indent.addScoped('{', '}', () {
      String? taskQueue;
      if (taskQueueType != TaskQueueType.serial) {
        taskQueue = 'taskQueue';
        indent.writeln(
            'val $taskQueue = binaryMessenger.makeBackgroundTaskQueue()');
      }
      indent.write(
          'val channel = BasicMessageChannel<Any?>(binaryMessenger, "$channelName\$separatedMessageChannelSuffix", codec');

      if (taskQueue != null) {
        indent.addln(', $taskQueue)');
      } else {
        indent.addln(')');
      }

      indent.write('if (api != null) ');
      indent.addScoped('{', '}', () {
        final String messageVarName = parameters.isNotEmpty ? 'message' : '_';

        indent.write('channel.setMessageHandler ');
        indent.addScoped('{ $messageVarName, reply ->', '}', () {
          final List<String> methodArguments = <String>[];
          if (parameters.isNotEmpty) {
            indent.writeln('val args = message as List<Any?>');
            enumerate(parameters, (int index, NamedType arg) {
              final String argName = _getSafeArgumentName(index, arg);
              final String argIndex = 'args[$index]';
              indent.writeln(
                  'val $argName = ${_castForceUnwrap(argIndex, arg.type, indent)}');
              methodArguments.add(argName);
            });
          }
          final String call = onCreateCall != null
              ? onCreateCall(methodArguments, apiVarName: 'api')
              : 'api.$name(${methodArguments.join(', ')})';

          if (isAsynchronous) {
            indent.write('$call ');
            final String resultType = returnType.isVoid
                ? 'Unit'
                : _nullSafeKotlinTypeForDartType(returnType);
            indent.addScoped('{ result: Result<$resultType> ->', '}', () {
              indent.writeln('val error = result.exceptionOrNull()');
              indent.writeScoped('if (error != null) {', '}', () {
                indent.writeln('reply.reply(wrapError(error))');
              }, addTrailingNewline: false);
              indent.addScoped(' else {', '}', () {
                final String enumTagNullablePrefix =
                    returnType.isNullable ? '?' : '!!';
                final String enumTag =
                    returnType.isEnum ? '$enumTagNullablePrefix.raw' : '';
                if (returnType.isVoid) {
                  indent.writeln('reply.reply(wrapResult(null))');
                } else {
                  indent.writeln('val data = result.getOrNull()');
                  indent.writeln('reply.reply(wrapResult(data$enumTag))');
                }
              });
            });
          } else {
            indent.writeln('var wrapped: List<Any?>');
            indent.write('try ');
            indent.addScoped('{', '}', () {
              if (returnType.isVoid) {
                indent.writeln(call);
                indent.writeln('wrapped = listOf<Any?>(null)');
              } else {
                String enumTag = '';
                if (returnType.isEnum) {
                  final String safeUnwrap = returnType.isNullable ? '?' : '';
                  enumTag = '$safeUnwrap.raw';
                }
                indent.writeln('wrapped = listOf<Any?>($call$enumTag)');
              }
            }, addTrailingNewline: false);
            indent.add(' catch (exception: Throwable) ');
            indent.addScoped('{', '}', () {
              indent.writeln('wrapped = wrapError(exception)');
            });
            indent.writeln('reply.reply(wrapped)');
          }
        });
      }, addTrailingNewline: false);
      indent.addScoped(' else {', '}', () {
        indent.writeln('channel.setMessageHandler(null)');
      });
    });
  }

  void _writeFlutterMethod(
    Indent indent, {
    required KotlinOptions generatorOptions,
    required String name,
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    required String channelName,
    required String dartPackageName,
    List<String> documentationComments = const <String>[],
    int? minApiRequirement,
  }) {
    _writeMethodDeclaration(
      indent,
      name: name,
      returnType: returnType,
      parameters: parameters,
      documentationComments: documentationComments,
      isAsynchronous: true,
      minApiRequirement: minApiRequirement,
      getArgumentName: _getSafeArgumentName,
    );

    final String errorClassName = _getErrorClassName(generatorOptions);
    indent.addScoped('{', '}', () {
      _writeFlutterMethodMessageCall(
        indent,
        parameters: parameters,
        returnType: returnType,
        channelName: channelName,
        errorClassName: errorClassName,
      );
    });
  }

  static void _writeFlutterMethodMessageCall(
    Indent indent, {
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    required String channelName,
    required String errorClassName,
  }) {
    String sendArgument;

    if (parameters.isEmpty) {
      sendArgument = 'null';
    } else {
      final Iterable<String> enumSafeArgNames = indexMap(
          parameters,
          (int count, NamedType type) =>
              _getEnumSafeArgumentExpression(count, type));
      sendArgument = 'listOf(${enumSafeArgNames.join(', ')})';
    }

    const String channel = 'channel';
    indent.writeln(
        r'val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""');
    indent.writeln(
        'val channelName = "$channelName\$separatedMessageChannelSuffix"');
    indent.writeln(
        'val $channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)');
    indent.writeScoped('$channel.send($sendArgument) {', '}', () {
      indent.writeScoped('if (it is List<*>) {', '} ', () {
        indent.writeScoped('if (it.size > 1) {', '} ', () {
          indent.writeln(
              'callback(Result.failure($errorClassName(it[0] as String, it[1] as String, it[2] as String?)))');
        }, addTrailingNewline: false);
        if (!returnType.isNullable && !returnType.isVoid) {
          indent.addScoped('else if (it[0] == null) {', '} ', () {
            indent.writeln(
                'callback(Result.failure($errorClassName("null-error", "Flutter api returned null value for non-null return value.", "")))');
          }, addTrailingNewline: false);
        }
        indent.addScoped('else {', '}', () {
          if (returnType.isVoid) {
            indent.writeln('callback(Result.success(Unit))');
          } else {
            const String output = 'output';
            // Nullable enums require special handling.
            if (returnType.isEnum && returnType.isNullable) {
              indent.writeScoped('val $output = (it[0] as Int?)?.let {', '}',
                  () {
                indent.writeln('${returnType.baseName}.ofRaw(it)');
              });
            } else {
              indent.writeln(
                  'val $output = ${_cast(indent, 'it[0]', type: returnType)}');
            }
            indent.writeln('callback(Result.success($output))');
          }
        });
      }, addTrailingNewline: false);
      indent.addScoped('else {', '} ', () {
        indent.writeln(
            'callback(Result.failure(createConnectionError(channelName)))');
      });
    });
  }
}

HostDatatype _getHostDatatype(Root root, NamedType field) {
  return getFieldHostDatatype(
      field, (TypeDeclaration x) => _kotlinTypeForBuiltinDartType(x));
}

/// Calculates the name of the codec that will be generated for [api].
String _getCodecName(Api api) => '${api.name}Codec';

String _getErrorClassName(KotlinOptions generatorOptions) =>
    generatorOptions.errorClassName ?? 'FlutterError';

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : argument.name;

/// Returns an argument name that can be used in a context where it is possible to collide
/// and append `.index` to enums.
String _getEnumSafeArgumentExpression(int count, NamedType argument) {
  if (argument.type.isEnum) {
    return argument.type.isNullable
        ? '${_getArgumentName(count, argument)}Arg?.raw'
        : '${_getArgumentName(count, argument)}Arg.raw';
  }
  return '${_getArgumentName(count, argument)}Arg';
}

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}Arg';

String _castForceUnwrap(String value, TypeDeclaration type, Indent indent) {
  if (type.isEnum) {
    final String forceUnwrap = type.isNullable ? '' : '!!';
    final String nullableConditionPrefix =
        type.isNullable ? 'if ($value == null) null else ' : '';
    return '$nullableConditionPrefix${_kotlinTypeForDartType(type)}.ofRaw($value as Int)$forceUnwrap';
  } else {
    return _cast(indent, value, type: type);
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
        return 'List<${_nullSafeKotlinTypeForDartType(type.typeArguments.first)}>';
      case 'Map':
        return 'Map<${_nullSafeKotlinTypeForDartType(type.typeArguments.first)}, ${_nullSafeKotlinTypeForDartType(type.typeArguments.last)}>';
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

String _nullSafeKotlinTypeForDartType(TypeDeclaration type) {
  final String nullSafe = type.isNullable ? '?' : '';
  return '${_kotlinTypeForDartType(type)}$nullSafe';
}

/// Returns an expression to cast [variable] to [kotlinType].
String _cast(Indent indent, String variable, {required TypeDeclaration type}) {
  // Special-case Any, since no-op casts cause warnings.
  final String typeString = _kotlinTypeForDartType(type);
  if (type.isNullable && typeString == 'Any') {
    return variable;
  }
  if (typeString == 'Int' || typeString == 'Long') {
    return '$variable${_castInt(type.isNullable)}';
  }
  if (type.isEnum) {
    if (type.isNullable) {
      return '($variable as Int?)?.let {\n'
          '${indent.str}  $typeString.ofRaw(it)\n'
          '${indent.str}}';
    }
    return '${type.baseName}.ofRaw($variable as Int)!!';
  }
  return '$variable as ${_nullSafeKotlinTypeForDartType(type)}';
}

String _castInt(bool isNullable) {
  final String nullability = isNullable ? '?' : '';
  return '.let { if (it is Int) it.toLong() else it as Long$nullability }';
}
