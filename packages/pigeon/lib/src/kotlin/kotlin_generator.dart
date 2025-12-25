// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:graphs/graphs.dart';

import '../ast.dart';
import '../functional.dart';
import '../generator.dart';
import '../generator_tools.dart';
import '../types/task_queue.dart';
import 'templates.dart';

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

const String _codecName = 'PigeonCodec';

/// Name of field used for host API codec.
const String _pigeonMethodChannelCodec = 'PigeonMethodCodec';

const String _overflowClassName = '${classNamePrefix}CodecOverflow';

/// Options that control how Kotlin code will be generated.
class KotlinOptions {
  /// Creates a [KotlinOptions] object
  const KotlinOptions({
    this.package,
    this.copyrightHeader,
    this.errorClassName,
    this.includeErrorClass = true,
    this.fileSpecificClassNameComponent,
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

  /// A String to augment class names to avoid cross file collisions.
  final String? fileSpecificClassNameComponent;

  /// Creates a [KotlinOptions] from a Map representation where:
  /// `x = KotlinOptions.fromMap(x.toMap())`.
  static KotlinOptions fromMap(Map<String, Object> map) {
    return KotlinOptions(
      package: map['package'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      errorClassName: map['errorClassName'] as String?,
      includeErrorClass: map['includeErrorClass'] as bool? ?? true,
      fileSpecificClassNameComponent:
          map['fileSpecificClassNameComponent'] as String?,
    );
  }

  /// Converts a [KotlinOptions] to a Map representation where:
  /// `x = KotlinOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final result = <String, Object>{
      if (package != null) 'package': package!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (errorClassName != null) 'errorClassName': errorClassName!,
      'includeErrorClass': includeErrorClass,
      if (fileSpecificClassNameComponent != null)
        'fileSpecificClassNameComponent': fileSpecificClassNameComponent!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [KotlinOptions].
  KotlinOptions merge(KotlinOptions options) {
    return KotlinOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

///
class InternalKotlinOptions extends InternalOptions {
  /// Creates a [InternalKotlinOptions] object
  const InternalKotlinOptions({
    this.package,
    required this.kotlinOut,
    this.copyrightHeader,
    this.errorClassName,
    this.includeErrorClass = true,
    this.fileSpecificClassNameComponent,
  });

  /// Creates InternalKotlinOptions from KotlinOptions.
  InternalKotlinOptions.fromKotlinOptions(
    KotlinOptions options, {
    required this.kotlinOut,
    Iterable<String>? copyrightHeader,
  }) : package = options.package,
       copyrightHeader = options.copyrightHeader ?? copyrightHeader,
       errorClassName = options.errorClassName,
       includeErrorClass = options.includeErrorClass,
       fileSpecificClassNameComponent =
           options.fileSpecificClassNameComponent ??
           kotlinOut.split('/').lastOrNull?.split('.').first;

  /// The package where the generated class will live.
  final String? package;

  /// Path to the kotlin file that will be generated.
  final String kotlinOut;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The name of the error class used for passing custom error parameters.
  final String? errorClassName;

  /// Whether to include the error class in generation.
  ///
  /// This should only ever be set to false if you have another generated
  /// Kotlin file in the same directory.
  final bool includeErrorClass;

  /// A String to augment class names to avoid cross file collisions.
  final String? fileSpecificClassNameComponent;
}

/// Options that control how Kotlin code will be generated for a specific
/// ProxyApi.
class KotlinProxyApiOptions {
  /// Construct a [KotlinProxyApiOptions].
  const KotlinProxyApiOptions({this.fullClassName, this.minAndroidApi});

  /// The name of the full runtime Kotlin class name (including the package).
  final String? fullClassName;

  /// The minimum Android api version.
  ///
  /// This adds the [RequiresApi](https://developer.android.com/reference/androidx/annotation/RequiresApi)
  /// annotations on top of any constructor, field, or method that references
  /// this element.
  final int? minAndroidApi;
}

/// Options for Kotlin implementation of Event Channels.
class KotlinEventChannelOptions {
  /// Construct a [KotlinEventChannelOptions].
  const KotlinEventChannelOptions({this.includeSharedClasses = true});

  /// Whether to include the shared Event Channel classes in generation.
  ///
  /// This should only ever be set to false if you have another generated
  /// Kotlin file with Event Channels in the same directory.
  final bool includeSharedClasses;
}

/// Class that manages all Kotlin code generation.
class KotlinGenerator extends StructuredGenerator<InternalKotlinOptions> {
  /// Instantiates a Kotlin Generator.
  const KotlinGenerator();

  @override
  void writeFilePrologue(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln('@file:Suppress("UNCHECKED_CAST", "ArrayInDataClass")');
  }

  @override
  void writeFileImports(
    InternalKotlinOptions generatorOptions,
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
    indent.writeln('import io.flutter.plugin.common.EventChannel');
    indent.writeln('import io.flutter.plugin.common.MessageCodec');
    indent.writeln('import io.flutter.plugin.common.StandardMethodCodec');
    indent.writeln('import io.flutter.plugin.common.StandardMessageCodec');
    indent.writeln('import java.io.ByteArrayOutputStream');
    indent.writeln('import java.nio.ByteBuffer');
  }

  @override
  void writeEnum(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
      indent,
      anEnum.documentationComments,
      _docCommentSpec,
    );
    indent.write('enum class ${anEnum.name}(val raw: Int) ');
    indent.addScoped('{', '}', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
          indent,
          member.documentationComments,
          _docCommentSpec,
        );
        final String nameScreamingSnakeCase = toScreamingSnakeCase(member.name);
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
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final generatedMessages = <String>[
      ' Generated class from Pigeon that represents data sent in messages.',
    ];
    if (classDefinition.isSealed) {
      generatedMessages.add(
        ' This class should not be extended by any user class outside of the generated file.',
      );
    }
    indent.newln();
    addDocumentationComments(
      indent,
      classDefinition.documentationComments,
      _docCommentSpec,
      generatorComments: generatedMessages,
    );
    _writeDataClassSignature(indent, classDefinition);
    if (classDefinition.isSealed) {
      return;
    }
    indent.addScoped(' {', '}', () {
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
      writeClassEquality(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
    });
  }

  @override
  void writeClassEquality(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.writeScoped('override fun equals(other: Any?): Boolean {', '}', () {
      indent.writeScoped('if (other !is ${classDefinition.name}) {', '}', () {
        indent.writeln('return false');
      });
      indent.writeScoped('if (this === other) {', '}', () {
        indent.writeln('return true');
      });
      indent.write(
        'return ${_getUtilsClassName(generatorOptions)}.deepEquals(toList(), other.toList())',
      );
    });

    indent.newln();
    indent.writeln('override fun hashCode(): Int = toList().hashCode()');
  }

  void _writeDataClassSignature(
    Indent indent,
    Class classDefinition, {
    bool private = false,
  }) {
    final privateString = private ? 'private ' : '';
    final classType = classDefinition.isSealed ? 'sealed' : 'data';
    final inheritance = classDefinition.superClass != null
        ? ' : ${classDefinition.superClassName}()'
        : '';
    indent.write('$privateString$classType class ${classDefinition.name} ');
    if (classDefinition.isSealed) {
      return;
    }
    indent.addScoped('(', ')$inheritance', () {
      for (final NamedType element in getFieldsInSerializationOrder(
        classDefinition,
      )) {
        _writeClassField(indent, element);
        if (getFieldsInSerializationOrder(classDefinition).last != element) {
          indent.addln(',');
        } else {
          indent.newln();
        }
      }
    });
  }

  @override
  void writeClassEncode(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.write('fun toList(): List<Any?> ');
    indent.addScoped('{', '}', () {
      indent.write('return listOf');
      indent.addScoped('(', ')', () {
        for (final NamedType field in getFieldsInSerializationOrder(
          classDefinition,
        )) {
          final String fieldName = field.name;
          indent.writeln('$fieldName,');
        }
      });
    });
  }

  @override
  void writeClassDecode(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String className = classDefinition.name;

    indent.write('companion object ');
    indent.addScoped('{', '}', () {
      indent.write(
        'fun fromList(${varNamePrefix}list: List<Any?>): $className ',
      );

      indent.addScoped('{', '}', () {
        enumerate(getFieldsInSerializationOrder(classDefinition), (
          int index,
          final NamedType field,
        ) {
          final listValue = '${varNamePrefix}list[$index]';
          indent.writeln(
            'val ${field.name} = ${_cast(indent, listValue, type: field.type)}',
          );
        });

        indent.write('return $className(');
        for (final NamedType field in getFieldsInSerializationOrder(
          classDefinition,
        )) {
          final comma =
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
      indent,
      field.documentationComments,
      _docCommentSpec,
    );
    indent.write(
      'val ${field.name}: ${_nullSafeKotlinTypeForDartType(field.type)}',
    );
    final defaultNil = field.type.isNullable ? ' = null' : '';
    indent.add(defaultNil);
  }

  @override
  void writeApis(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.apis.any(
      (Api api) =>
          api is AstHostApi &&
          api.methods.any((Method it) => it.isAsynchronous),
    )) {
      indent.newln();
    }
    super.writeApis(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
  }

  @override
  void writeGeneralCodec(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final List<EnumeratedType> enumeratedTypes = getEnumeratedTypes(
      root,
      excludeSealedClasses: true,
    ).toList();

    void writeEncodeLogic(EnumeratedType customType) {
      final encodeString = customType.type == CustomTypes.customClass
          ? 'toList()'
          : 'raw.toLong()';
      final valueString = customType.enumeration < maximumCodecFieldKey
          ? 'value.$encodeString'
          : 'wrap.toList()';
      final int enumeration = customType.enumeration < maximumCodecFieldKey
          ? customType.enumeration
          : maximumCodecFieldKey;
      indent.writeScoped('is ${customType.name} -> {', '}', () {
        if (customType.enumeration >= maximumCodecFieldKey) {
          indent.writeln(
            'val wrap = ${generatorOptions.fileSpecificClassNameComponent}$_overflowClassName(type = ${customType.enumeration - maximumCodecFieldKey}, wrapped = value.$encodeString)',
          );
        }
        indent.writeln('stream.write($enumeration)');
        indent.writeln('writeValue(stream, $valueString)');
      });
    }

    void writeDecodeLogic(EnumeratedType customType) {
      indent.write('${customType.enumeration}.toByte() -> ');
      indent.addScoped('{', '}', () {
        if (customType.type == CustomTypes.customClass) {
          indent.write('return (readValue(buffer) as? List<Any?>)?.let ');
          indent.addScoped('{', '}', () {
            indent.writeln('${customType.name}.fromList(it)');
          });
        } else if (customType.type == CustomTypes.customEnum) {
          indent.write('return (readValue(buffer) as Long?)?.let ');
          indent.addScoped('{', '}', () {
            indent.writeln('${customType.name}.ofRaw(it.toInt())');
          });
        }
      });
    }

    final overflowClass = EnumeratedType(
      '${generatorOptions.fileSpecificClassNameComponent}$_overflowClassName',
      maximumCodecFieldKey,
      CustomTypes.customClass,
    );

    if (root.requiresOverflowClass) {
      _writeCodecOverflowUtilities(
        generatorOptions,
        root,
        indent,
        enumeratedTypes,
        dartPackageName: dartPackageName,
      );
    }

    indent.write(
      'private open class ${generatorOptions.fileSpecificClassNameComponent}$_codecName : StandardMessageCodec() ',
    );
    indent.addScoped('{', '}', () {
      indent.write(
        'override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? ',
      );
      indent.addScoped('{', '}', () {
        indent.write('return ');
        if (root.classes.isNotEmpty || root.enums.isNotEmpty) {
          indent.add('when (type) ');
          indent.addScoped('{', '}', () {
            for (final customType in enumeratedTypes) {
              if (customType.enumeration < maximumCodecFieldKey) {
                writeDecodeLogic(customType);
              }
            }
            if (root.requiresOverflowClass) {
              writeDecodeLogic(overflowClass);
            }
            indent.writeln('else -> super.readValueOfType(type, buffer)');
          });
        } else {
          indent.writeln('super.readValueOfType(type, buffer)');
        }
      });

      indent.write(
        'override fun writeValue(stream: ByteArrayOutputStream, value: Any?) ',
      );
      indent.writeScoped('{', '}', () {
        if (root.classes.isNotEmpty || root.enums.isNotEmpty) {
          indent.write('when (value) ');
          indent.addScoped('{', '}', () {
            enumeratedTypes.forEach(writeEncodeLogic);
            indent.writeln('else -> super.writeValue(stream, value)');
          });
        } else {
          indent.writeln('super.writeValue(stream, value)');
        }
      });
    });
    indent.newln();
    if (root.containsEventChannel) {
      indent.writeln(
        'val ${generatorOptions.fileSpecificClassNameComponent}$_pigeonMethodChannelCodec = StandardMethodCodec(${generatorOptions.fileSpecificClassNameComponent}$_codecName())',
      );
      indent.newln();
    }
  }

  void _writeCodecOverflowUtilities(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    List<EnumeratedType> types, {
    required String dartPackageName,
  }) {
    final overflowInt = NamedType(
      name: 'type',
      type: const TypeDeclaration(baseName: 'int', isNullable: false),
    );
    final overflowObject = NamedType(
      name: 'wrapped',
      type: const TypeDeclaration(baseName: 'Object', isNullable: true),
    );
    final overflowFields = <NamedType>[overflowInt, overflowObject];
    final overflowClass = Class(
      name:
          '${generatorOptions.fileSpecificClassNameComponent}$_overflowClassName',
      fields: overflowFields,
    );

    _writeDataClassSignature(indent, overflowClass, private: true);
    indent.addScoped(' {', '}', () {
      writeClassEncode(
        generatorOptions,
        root,
        indent,
        overflowClass,
        dartPackageName: dartPackageName,
      );

      indent.format('''
companion object {
  fun fromList(${varNamePrefix}list: List<Any?>): Any? {
    val wrapper = ${generatorOptions.fileSpecificClassNameComponent}$_overflowClassName(
      type = ${varNamePrefix}list[0] as Long,
      wrapped = ${varNamePrefix}list[1],
    );
    return wrapper.unwrap()
  }
}
''');

      indent.writeScoped('fun unwrap(): Any? {', '}', () {
        indent.format('''
if (wrapped == null) {
  return null
}
    ''');
        indent.writeScoped('when (type.toInt()) {', '}', () {
          for (int i = totalCustomCodecKeysAllowed; i < types.length; i++) {
            indent.writeScoped('${i - totalCustomCodecKeysAllowed} ->', '', () {
              if (types[i].type == CustomTypes.customClass) {
                indent.writeln(
                  'return ${types[i].name}.fromList(wrapped as List<Any?>)',
                );
              } else if (types[i].type == CustomTypes.customEnum) {
                indent.writeln(
                  'return ${types[i].name}.ofRaw((wrapped as Long).toInt())',
                );
              }
            });
          }
        });
        indent.writeln('return null');
      });
    });
  }

  /// Writes the code for a flutter [Api], [api].
  /// Example:
  /// class Foo(private val binaryMessenger: BinaryMessenger) {
  ///   fun add(x: Int, y: Int, callback: (Int?) -> Unit) {...}
  /// }
  @override
  void writeFlutterApi(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    const generatedMessages = <String>[
      ' Generated class from Pigeon that represents Flutter messages that can be called from Kotlin.',
    ];
    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
      generatorComments: generatedMessages,
    );

    final String apiName = api.name;
    indent.write(
      'class $apiName(private val binaryMessenger: BinaryMessenger, private val messageChannelSuffix: String = "") ',
    );
    indent.addScoped('{', '}', () {
      indent.write('companion object ');
      indent.addScoped('{', '}', () {
        indent.writeln('/** The codec used by $apiName. */');
        indent.write('val codec: MessageCodec<Any?> by lazy ');
        indent.addScoped('{', '}', () {
          indent.writeln(
            '${generatorOptions.fileSpecificClassNameComponent}$_codecName()',
          );
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
          onWriteBody:
              (
                Indent indent, {
                required InternalKotlinOptions generatorOptions,
                required List<Parameter> parameters,
                required TypeDeclaration returnType,
                required String channelName,
                required String errorClassName,
              }) {
                indent.writeln(
                  r'val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""',
                );
                _writeFlutterMethodMessageCall(
                  indent,
                  generatorOptions: generatorOptions,
                  parameters: parameters,
                  returnType: returnType,
                  channelName: '$channelName\$separatedMessageChannelSuffix',
                  errorClassName: errorClassName,
                );
              },
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
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    final String apiName = api.name;

    const generatedMessages = <String>[
      ' Generated interface from Pigeon that represents a handler of messages from Flutter.',
    ];
    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
      generatorComments: generatedMessages,
    );

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
          indent.writeln(
            '${generatorOptions.fileSpecificClassNameComponent}$_codecName()',
          );
        });
        indent.writeln(
          '/** Sets up an instance of `$apiName` to handle messages through the `binaryMessenger`. */',
        );
        indent.writeln('@JvmOverloads');
        indent.write(
          'fun setUp(binaryMessenger: BinaryMessenger, api: $apiName?, messageChannelSuffix: String = "") ',
        );
        indent.addScoped('{', '}', () {
          indent.writeln(
            r'val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""',
          );
          String? serialBackgroundQueue;
          if (api.methods.any(
            (Method m) =>
                m.taskQueueType == TaskQueueType.serialBackgroundThread,
          )) {
            serialBackgroundQueue = 'taskQueue';
            indent.writeln(
              'val $serialBackgroundQueue = binaryMessenger.makeBackgroundTaskQueue()',
            );
          }
          for (final Method method in api.methods) {
            _writeHostMethodMessageHandler(
              indent,
              generatorOptions: generatorOptions,
              name: method.name,
              channelName:
                  '${makeChannelName(api, method, dartPackageName)}\$separatedMessageChannelSuffix',
              taskQueueType: method.taskQueueType,
              parameters: method.parameters,
              returnType: method.returnType,
              isAsynchronous: method.isAsynchronous,
              serialBackgroundQueue:
                  method.taskQueueType == TaskQueueType.serialBackgroundThread
                  ? serialBackgroundQueue
                  : null,
            );
          }
        });
      });
    });
  }

  @override
  void writeInstanceManager(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.format(instanceManagerTemplate(generatorOptions));
    indent.newln();
  }

  @override
  void writeInstanceManagerApi(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final instanceManagerApiName =
        '${kotlinInstanceManagerClassName(generatorOptions)}Api';

    addDocumentationComments(indent, <String>[
      ' Generated API for managing the Dart and native `InstanceManager`s.',
    ], _docCommentSpec);
    indent.writeScoped(
      'private class $instanceManagerApiName(val binaryMessenger: BinaryMessenger) {',
      '}',
      () {
        indent.writeScoped('companion object {', '}', () {
          addDocumentationComments(indent, <String>[
            ' The codec used by $instanceManagerApiName.',
          ], _docCommentSpec);
          indent.writeScoped('val codec: MessageCodec<Any?> by lazy {', '}', () {
            indent.writeln(
              '${generatorOptions.fileSpecificClassNameComponent}$_codecName()',
            );
          });
          indent.newln();

          addDocumentationComments(indent, <String>[
            ' Sets up an instance of `$instanceManagerApiName` to handle messages from the',
            ' `binaryMessenger`.',
          ], _docCommentSpec);
          indent.writeScoped(
            'fun setUpMessageHandlers(binaryMessenger: BinaryMessenger, instanceManager: ${kotlinInstanceManagerClassName(generatorOptions)}?) {',
            '}',
            () {
              const setHandlerCondition = 'instanceManager != null';
              _writeHostMethodMessageHandler(
                indent,
                generatorOptions: generatorOptions,
                name: 'removeStrongReference',
                channelName: makeRemoveStrongReferenceChannelName(
                  dartPackageName,
                ),
                taskQueueType: TaskQueueType.serial,
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
                setHandlerCondition: setHandlerCondition,
                onCreateCall:
                    (List<String> safeArgNames, {required String apiVarName}) {
                      return 'instanceManager.remove<Any?>(${safeArgNames.single})';
                    },
              );
              _writeHostMethodMessageHandler(
                indent,
                generatorOptions: generatorOptions,
                name: 'clear',
                channelName: makeClearChannelName(dartPackageName),
                taskQueueType: TaskQueueType.serial,
                parameters: <Parameter>[],
                returnType: const TypeDeclaration.voidDeclaration(),
                setHandlerCondition: setHandlerCondition,
                onCreateCall:
                    (List<String> safeArgNames, {required String apiVarName}) {
                      return 'instanceManager.clear()';
                    },
              );
            },
          );
        });
        indent.newln();

        _writeFlutterMethod(
          indent,
          generatorOptions: generatorOptions,
          name: 'removeStrongReference',
          parameters: <Parameter>[
            Parameter(
              name: 'identifier',
              type: const TypeDeclaration(baseName: 'int', isNullable: false),
            ),
          ],
          returnType: const TypeDeclaration.voidDeclaration(),
          channelName: makeRemoveStrongReferenceChannelName(dartPackageName),
          dartPackageName: dartPackageName,
        );
      },
    );
  }

  @override
  void writeProxyApiBaseCodec(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
  ) {
    final Iterable<AstProxyApi> allProxyApis = root.apis
        .whereType<AstProxyApi>();

    _writeProxyApiRegistrar(
      indent,
      generatorOptions: generatorOptions,
      allProxyApis: allProxyApis,
    );

    // Sort APIs where edges are an API's super class and interfaces.
    //
    // This sorts the APIs to have child classes be listed before their parent
    // classes. This prevents the scenario where a method might return the super
    // class of the actual class, so the incorrect Dart class gets created
    // because the 'value is <SuperClass>' was checked first in the codec. For
    // example:
    //
    // class Shape {}
    // class Circle extends Shape {}
    //
    // class SomeClass {
    //   Shape giveMeAShape() => Circle();
    // }
    final List<AstProxyApi> sortedApis = topologicalSort(allProxyApis, (
      AstProxyApi api,
    ) {
      return <AstProxyApi>[
        if (api.superClass?.associatedProxyApi != null)
          api.superClass!.associatedProxyApi!,
        ...api.interfaces.map(
          (TypeDeclaration interface) => interface.associatedProxyApi!,
        ),
      ];
    });

    indent.writeScoped(
      'private class ${proxyApiCodecName(generatorOptions)}(val registrar: ${proxyApiRegistrarName(generatorOptions)}) : '
          '${generatorOptions.fileSpecificClassNameComponent}$_codecName() {',
      '}',
      () {
        indent.format('''
          override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
            return when (type) {
              $proxyApiCodecInstanceManagerKey.toByte() -> {
                val identifier: Long = readValue(buffer) as Long
                val instance: Any? = registrar.instanceManager.getInstance(identifier)
                if (instance == null) {
                  Log.e(
                    "${proxyApiCodecName(const InternalKotlinOptions(kotlinOut: ''))}",
                    "Failed to find instance with identifier: \$identifier"
                  )
                }
                return instance
              }
              else -> super.readValueOfType(type, buffer)
            }
          }''');
        indent.newln();

        indent.writeScoped(
          'override fun writeValue(stream: ByteArrayOutputStream, value: Any?) {',
          '}',
          () {
            final nonProxyApiTypes = <String>[
              'Boolean',
              'ByteArray',
              'Double',
              'DoubleArray',
              'FloatArray',
              'Int',
              'IntArray',
              'List<*>',
              'Long',
              'LongArray',
              'Map<*, *>',
              'String',
              ...root.enums.map((Enum anEnum) => anEnum.name),
            ];
            final String isSupportedExpression = nonProxyApiTypes
                .map((String kotlinType) => 'value is $kotlinType')
                .followedBy(<String>['value == null'])
                .join(' || ');
            // Non ProxyApi types are checked first to handle the scenario
            // where a client wraps the `Object` class which all the
            // classes above extend.
            indent.writeScoped('if ($isSupportedExpression) {', '}', () {
              indent.writeln('super.writeValue(stream, value)');
              indent.writeln('return');
            });
            indent.newln();

            indent.format('''
              fun logNewInstanceFailure(apiName: String, value: Any, exception: Throwable?) {
                Log.w(
                  "${proxyApiCodecName(const InternalKotlinOptions(kotlinOut: ''))}",
                  "Failed to create new Dart proxy instance of \$apiName: \$value. \$exception"
                )
              }
              ''');

            enumerate(sortedApis, (int index, AstProxyApi api) {
              final String className =
                  api.kotlinOptions?.fullClassName ?? api.name;

              final int? minApi = api.kotlinOptions?.minAndroidApi;
              final versionCheck = minApi != null
                  ? 'android.os.Build.VERSION.SDK_INT >= $minApi && '
                  : '';

              indent.format('''
                  ${index > 0 ? ' else ' : ''}if (${versionCheck}value is $className) {
                    registrar.get$hostProxyApiPrefix${api.name}().${classMemberNamePrefix}newInstance(value) {
                      if (it.isFailure) {
                        logNewInstanceFailure("${api.name}", value, it.exceptionOrNull())
                      }
                    }
                  }''');
            });
            indent.newln();

            indent.format('''
              when {
                registrar.instanceManager.containsInstance(value) -> {
                  stream.write($proxyApiCodecInstanceManagerKey)
                  writeValue(stream, registrar.instanceManager.getIdentifierForStrongReference(value))
                }
                else -> throw IllegalArgumentException("Unsupported value: '\$value' of type '\${value.javaClass.name}'")
              }''');
          },
        );
      },
    );
  }

  @override
  void writeProxyApi(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    AstProxyApi api, {
    required String dartPackageName,
  }) {
    final kotlinApiName = '$hostProxyApiPrefix${api.name}';

    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
    );
    indent.writeln('@Suppress("UNCHECKED_CAST")');
    // The API only needs to be abstract if there are methods to override.
    final classModifier = api.hasMethodsRequiringImplementation()
        ? 'abstract'
        : 'open';
    indent.writeScoped(
      '$classModifier class $kotlinApiName(open val pigeonRegistrar: ${proxyApiRegistrarName(generatorOptions)}) {',
      '}',
      () {
        final String fullKotlinClassName =
            api.kotlinOptions?.fullClassName ?? api.name;

        final apiAsTypeDeclaration = TypeDeclaration(
          baseName: api.name,
          isNullable: false,
          associatedProxyApi: api,
        );

        _writeProxyApiConstructorAbstractMethods(
          indent,
          api,
          apiAsTypeDeclaration: apiAsTypeDeclaration,
        );

        _writeProxyApiAttachedFieldAbstractMethods(
          indent,
          api,
          apiAsTypeDeclaration: apiAsTypeDeclaration,
        );

        if (api.hasCallbackConstructor()) {
          _writeProxyApiUnattachedFieldAbstractMethods(
            indent,
            api,
            apiAsTypeDeclaration: apiAsTypeDeclaration,
          );
        }

        _writeProxyApiHostMethodAbstractMethods(
          indent,
          api,
          apiAsTypeDeclaration: apiAsTypeDeclaration,
        );

        if (api.constructors.isNotEmpty ||
            api.attachedFields.isNotEmpty ||
            api.hostMethods.isNotEmpty) {
          indent.writeScoped('companion object {', '}', () {
            _writeProxyApiMessageHandlerMethod(
              indent,
              api,
              apiAsTypeDeclaration: apiAsTypeDeclaration,
              kotlinApiName: kotlinApiName,
              dartPackageName: dartPackageName,
              fullKotlinClassName: fullKotlinClassName,
              generatorOptions: generatorOptions,
            );
          });
          indent.newln();
        }

        _writeProxyApiNewInstanceMethod(
          indent,
          api,
          generatorOptions: generatorOptions,
          apiAsTypeDeclaration: apiAsTypeDeclaration,
          newInstanceMethodName: '${classMemberNamePrefix}newInstance',
          dartPackageName: dartPackageName,
        );

        _writeProxyApiFlutterMethods(
          indent,
          api,
          generatorOptions: generatorOptions,
          apiAsTypeDeclaration: apiAsTypeDeclaration,
          dartPackageName: dartPackageName,
        );

        _writeProxyApiInheritedApiMethods(indent, api);
      },
    );
  }

  @override
  void writeEventChannelApi(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent,
    AstEventChannelApi api, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.format('''
        private class ${generatorOptions.fileSpecificClassNameComponent}PigeonStreamHandler<T>(
            val wrapper: ${generatorOptions.fileSpecificClassNameComponent}PigeonEventChannelWrapper<T>
        ) : EventChannel.StreamHandler {
          var pigeonSink: PigeonEventSink<T>? = null

          override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            pigeonSink = PigeonEventSink<T>(sink)
            wrapper.onListen(p0, pigeonSink!!)
          }

          override fun onCancel(p0: Any?) {
            pigeonSink = null
            wrapper.onCancel(p0)
          }
        }

        interface ${generatorOptions.fileSpecificClassNameComponent}PigeonEventChannelWrapper<T> {
          open fun onListen(p0: Any?, sink: PigeonEventSink<T>) {}

          open fun onCancel(p0: Any?) {}
        }
        ''');

    if (api.kotlinOptions?.includeSharedClasses ?? true) {
      indent.format('''
        class PigeonEventSink<T>(private val sink: EventChannel.EventSink) {
          fun success(value: T) {
            sink.success(value)
          }

          fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            sink.error(errorCode, errorMessage, errorDetails)
          }

          fun endOfStream() {
            sink.endOfStream()
          }
        }
      ''');
    }
    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
    );
    for (final Method func in api.methods) {
      indent.format('''
        abstract class ${toUpperCamelCase(func.name)}StreamHandler : ${generatorOptions.fileSpecificClassNameComponent}PigeonEventChannelWrapper<${_kotlinTypeForDartType(func.returnType)}> {
          companion object {
            fun register(messenger: BinaryMessenger, streamHandler: ${toUpperCamelCase(func.name)}StreamHandler, instanceName: String = "") {
              var channelName: String = "${makeChannelName(api, func, dartPackageName)}"
              if (instanceName.isNotEmpty()) {
                channelName += ".\$instanceName"
              }
              val internalStreamHandler = ${generatorOptions.fileSpecificClassNameComponent}PigeonStreamHandler<${_kotlinTypeForDartType(func.returnType)}>(streamHandler)
              EventChannel(messenger, channelName, ${generatorOptions.fileSpecificClassNameComponent}$_pigeonMethodChannelCodec).setStreamHandler(internalStreamHandler)
            }
          }
        // Implement methods from ${generatorOptions.fileSpecificClassNameComponent}PigeonEventChannelWrapper
        override fun onListen(p0: Any?, sink: PigeonEventSink<${_kotlinTypeForDartType(func.returnType)}>) {}

        override fun onCancel(p0: Any?) {}
        }
      ''');
    }
  }

  void _writeWrapResult(Indent indent) {
    indent.newln();
    indent.write('fun wrapResult(result: Any?): List<Any?> ');
    indent.addScoped('{', '}', () {
      indent.writeln('return listOf(result)');
    });
  }

  void _writeWrapError(InternalKotlinOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.write('fun wrapError(exception: Throwable): List<Any?> ');
    indent.addScoped('{', '}', () {
      indent.write(
        'return if (exception is ${_getErrorClassName(generatorOptions)}) ',
      );
      indent.addScoped('{', '}', () {
        indent.writeScoped('listOf(', ')', () {
          indent.writeln('exception.code,');
          indent.writeln('exception.message,');
          indent.writeln('exception.details');
        });
      }, addTrailingNewline: false);
      indent.addScoped(' else {', '}', () {
        indent.writeScoped('listOf(', ')', () {
          indent.writeln('exception.javaClass.simpleName,');
          indent.writeln('exception.toString(),');
          indent.writeln(
            '"Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)',
          );
        });
      });
    });
  }

  void _writeErrorClass(InternalKotlinOptions generatorOptions, Indent indent) {
    indent.newln();
    indent.writeln('/**');
    indent.writeln(
      ' * Error class for passing custom error details to Flutter via a thrown PlatformException.',
    );
    indent.writeln(' * @property code The error code.');
    indent.writeln(' * @property message The error message.');
    indent.writeln(
      ' * @property details The error details. Must be a datatype supported by the api codec.',
    );
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
    InternalKotlinOptions generatorOptions,
    Indent indent,
  ) {
    final String errorClassName = _getErrorClassName(generatorOptions);
    indent.newln();
    indent.write(
      'fun createConnectionError(channelName: String): $errorClassName ',
    );
    indent.addScoped('{', '}', () {
      indent.write(
        'return $errorClassName("channel-error",  "Unable to establish connection on channel: \'\$channelName\'.", "")',
      );
    });
  }

  void _writeDeepEquals(InternalKotlinOptions generatorOptions, Indent indent) {
    indent.format('''
fun deepEquals(a: Any?, b: Any?): Boolean {
  if (a is ByteArray && b is ByteArray) {
      return a.contentEquals(b)
  }
  if (a is IntArray && b is IntArray) {
      return a.contentEquals(b)
  }
  if (a is LongArray && b is LongArray) {
      return a.contentEquals(b)
  }
  if (a is DoubleArray && b is DoubleArray) {
      return a.contentEquals(b)
  }
  if (a is Array<*> && b is Array<*>) {
    return a.size == b.size &&
        a.indices.all{ deepEquals(a[it], b[it]) }
  }
  if (a is List<*> && b is List<*>) {
    return a.size == b.size &&
        a.indices.all{ deepEquals(a[it], b[it]) }
  }
  if (a is Map<*, *> && b is Map<*, *>) {
    return a.size == b.size && a.all {
        (b as Map<Any?, Any?>).contains(it.key) &&
        deepEquals(it.value, b[it.key])
    }
  }
  return a == b
}
    ''');
  }

  @override
  void writeGeneralUtilities(
    InternalKotlinOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeScoped(
      'private object ${_getUtilsClassName(generatorOptions)} {',
      '}',
      () {
        if (root.containsFlutterApi || root.containsProxyApi) {
          _writeCreateConnectionError(generatorOptions, indent);
        }
        if (root.containsHostApi || root.containsProxyApi) {
          _writeWrapResult(indent);
          _writeWrapError(generatorOptions, indent);
        }
        if (root.classes.isNotEmpty) {
          _writeDeepEquals(generatorOptions, indent);
        }
      },
    );

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
    bool isOpen = false,
    bool isAbstract = false,
    String Function(int index, NamedType type) getArgumentName =
        _getArgumentName,
  }) {
    final argSignature = <String>[];
    if (parameters.isNotEmpty) {
      final Iterable<String> argTypes = parameters.map(
        (NamedType e) => _nullSafeKotlinTypeForDartType(e.type),
      );
      final Iterable<String> argNames = indexMap(parameters, getArgumentName);
      argSignature.addAll(
        map2(argTypes, argNames, (String argType, String argName) {
          return '$argName: $argType';
        }),
      );
    }

    final String returnTypeString = returnType.isVoid
        ? ''
        : _nullSafeKotlinTypeForDartType(returnType);

    final resultType = returnType.isVoid ? 'Unit' : returnTypeString;
    addDocumentationComments(indent, documentationComments, _docCommentSpec);

    if (minApiRequirement != null) {
      indent.writeln(
        '@androidx.annotation.RequiresApi(api = $minApiRequirement)',
      );
    }

    final openKeyword = isOpen ? 'open ' : '';
    final abstractKeyword = isAbstract ? 'abstract ' : '';

    if (isAsynchronous) {
      argSignature.add('callback: (Result<$resultType>) -> Unit');
      indent.writeln(
        '$openKeyword${abstractKeyword}fun $name(${argSignature.join(', ')})',
      );
    } else if (returnType.isVoid) {
      indent.writeln(
        '$openKeyword${abstractKeyword}fun $name(${argSignature.join(', ')})',
      );
    } else {
      indent.writeln(
        '$openKeyword${abstractKeyword}fun $name(${argSignature.join(', ')}): $returnTypeString',
      );
    }
  }

  void _writeHostMethodMessageHandler(
    Indent indent, {
    required InternalKotlinOptions generatorOptions,
    required String name,
    required String channelName,
    required TaskQueueType taskQueueType,
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    String setHandlerCondition = 'api != null',
    bool isAsynchronous = false,
    String? serialBackgroundQueue,
    String Function(List<String> safeArgNames, {required String apiVarName})?
    onCreateCall,
  }) {
    indent.write('run ');
    indent.addScoped('{', '}', () {
      indent.write(
        'val channel = BasicMessageChannel<Any?>(binaryMessenger, "$channelName", codec',
      );

      if (serialBackgroundQueue != null) {
        indent.addln(', $serialBackgroundQueue)');
      } else {
        indent.addln(')');
      }

      indent.write('if ($setHandlerCondition) ');
      indent.addScoped('{', '}', () {
        final messageVarName = parameters.isNotEmpty ? 'message' : '_';

        indent.write('channel.setMessageHandler ');
        indent.addScoped('{ $messageVarName, reply ->', '}', () {
          final methodArguments = <String>[];
          if (parameters.isNotEmpty) {
            indent.writeln('val args = message as List<Any?>');
            enumerate(parameters, (int index, NamedType arg) {
              final String argName = _getSafeArgumentName(index, arg);
              final argIndex = 'args[$index]';
              indent.writeln(
                'val $argName = ${_castForceUnwrap(argIndex, arg.type, indent)}',
              );
              methodArguments.add(argName);
            });
          }
          final String call = onCreateCall != null
              ? onCreateCall(methodArguments, apiVarName: 'api')
              : 'api.$name(${methodArguments.join(', ')})';

          if (isAsynchronous) {
            final String resultType = returnType.isVoid
                ? 'Unit'
                : _nullSafeKotlinTypeForDartType(returnType);
            indent.write(methodArguments.isNotEmpty ? '$call ' : 'api.$name');
            indent.addScoped('{ result: Result<$resultType> ->', '}', () {
              indent.writeln('val error = result.exceptionOrNull()');
              indent.writeScoped('if (error != null) {', '}', () {
                indent.writeln(
                  'reply.reply(${_getUtilsClassName(generatorOptions)}.wrapError(error))',
                );
              }, addTrailingNewline: false);
              indent.addScoped(' else {', '}', () {
                if (returnType.isVoid) {
                  indent.writeln(
                    'reply.reply(${_getUtilsClassName(generatorOptions)}.wrapResult(null))',
                  );
                } else {
                  indent.writeln('val data = result.getOrNull()');
                  indent.writeln(
                    'reply.reply(${_getUtilsClassName(generatorOptions)}.wrapResult(data))',
                  );
                }
              });
            });
          } else {
            indent.writeScoped('val wrapped: List<Any?> = try {', '}', () {
              if (returnType.isVoid) {
                indent.writeln(call);
                indent.writeln('listOf(null)');
              } else {
                indent.writeln('listOf($call)');
              }
            }, addTrailingNewline: false);
            indent.add(' catch (exception: Throwable) ');
            indent.addScoped('{', '}', () {
              indent.writeln(
                '${_getUtilsClassName(generatorOptions)}.wrapError(exception)',
              );
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
    required InternalKotlinOptions generatorOptions,
    required String name,
    required List<Parameter> parameters,
    required TypeDeclaration returnType,
    required String channelName,
    required String dartPackageName,
    List<String> documentationComments = const <String>[],
    int? minApiRequirement,
    void Function(
          Indent indent, {
          required InternalKotlinOptions generatorOptions,
          required List<Parameter> parameters,
          required TypeDeclaration returnType,
          required String channelName,
          required String errorClassName,
        })
        onWriteBody =
        _writeFlutterMethodMessageCall,
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
      onWriteBody(
        indent,
        generatorOptions: generatorOptions,
        parameters: parameters,
        returnType: returnType,
        channelName: channelName,
        errorClassName: errorClassName,
      );
    });
  }

  static void _writeFlutterMethodMessageCall(
    Indent indent, {
    required InternalKotlinOptions generatorOptions,
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
            _getEnumSafeArgumentExpression(count, type),
      );
      sendArgument = 'listOf(${enumSafeArgNames.join(', ')})';
    }

    const channel = 'channel';
    indent.writeln('val channelName = "$channelName"');
    indent.writeln(
      'val $channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)',
    );
    indent.writeScoped('$channel.send($sendArgument) {', '}', () {
      indent.writeScoped('if (it is List<*>) {', '} ', () {
        indent.writeScoped('if (it.size > 1) {', '} ', () {
          indent.writeln(
            'callback(Result.failure($errorClassName(it[0] as String, it[1] as String, it[2] as String?)))',
          );
        }, addTrailingNewline: false);
        if (!returnType.isNullable && !returnType.isVoid) {
          indent.addScoped('else if (it[0] == null) {', '} ', () {
            indent.writeln(
              'callback(Result.failure($errorClassName("null-error", "Flutter api returned null value for non-null return value.", "")))',
            );
          }, addTrailingNewline: false);
        }
        indent.addScoped('else {', '}', () {
          if (returnType.isVoid) {
            indent.writeln('callback(Result.success(Unit))');
          } else {
            indent.writeln(
              'val output = ${_cast(indent, 'it[0]', type: returnType)}',
            );

            indent.writeln('callback(Result.success(output))');
          }
        });
      }, addTrailingNewline: false);
      indent.addScoped('else {', '} ', () {
        indent.writeln(
          'callback(Result.failure(${_getUtilsClassName(generatorOptions)}.createConnectionError(channelName)))',
        );
      });
    });
  }

  void _writeProxyApiRegistrar(
    Indent indent, {
    required InternalKotlinOptions generatorOptions,
    required Iterable<AstProxyApi> allProxyApis,
  }) {
    final String registrarName = proxyApiRegistrarName(generatorOptions);
    final String instanceManagerName = kotlinInstanceManagerClassName(
      generatorOptions,
    );
    final instanceManagerApiName = '${instanceManagerName}Api';

    addDocumentationComments(indent, <String>[
      ' Provides implementations for each ProxyApi implementation and provides access to resources',
      ' needed by any implementation.',
    ], _docCommentSpec);
    indent.writeScoped(
      'abstract class $registrarName(val binaryMessenger: BinaryMessenger) {',
      '}',
      () {
        addDocumentationComments(indent, <String>[
          ' Whether APIs should ignore calling to Dart.',
        ], _docCommentSpec);
        indent.writeln('public var ignoreCallsToDart = false');
        indent.format('''
          val instanceManager: $instanceManagerName
          private var _codec: MessageCodec<Any?>? = null
          val codec: MessageCodec<Any?>
            get() {
              if (_codec == null) {
                _codec = ${proxyApiCodecName(generatorOptions)}(this)
              }
              return _codec!!
            }

          init {
            val api = $instanceManagerApiName(binaryMessenger)
            instanceManager = $instanceManagerName.create(
              object : $instanceManagerName.PigeonFinalizationListener {
                override fun onFinalize(identifier: Long) {
                  api.removeStrongReference(identifier) {
                    if (it.isFailure) {
                      Log.e(
                        "${proxyApiClassNamePrefix}ProxyApiRegistrar",
                        "Failed to remove Dart strong reference with identifier: \$identifier"
                      )
                    }
                  }
                }
              }
            )
          }''');
        for (final api in allProxyApis) {
          _writeMethodDeclaration(
            indent,
            name: 'get$hostProxyApiPrefix${api.name}',
            isAbstract:
                api.hasAnyHostMessageCalls() || api.unattachedFields.isNotEmpty,
            isOpen:
                !api.hasAnyHostMessageCalls() && api.unattachedFields.isEmpty,
            documentationComments: <String>[
              ' An implementation of [$hostProxyApiPrefix${api.name}] used to add a new Dart instance of',
              ' `${api.name}` to the Dart `InstanceManager`.',
            ],
            returnType: TypeDeclaration(
              baseName: '$hostProxyApiPrefix${api.name}',
              isNullable: false,
            ),
            parameters: <Parameter>[],
          );

          // Use the default API implementation if this API does not have any
          // methods to implement.
          if (!api.hasMethodsRequiringImplementation()) {
            indent.writeScoped('{', '}', () {
              indent.writeln('return $hostProxyApiPrefix${api.name}(this)');
            });
          }
          indent.newln();
        }

        indent.writeScoped('fun setUp() {', '}', () {
          indent.writeln(
            '$instanceManagerApiName.setUpMessageHandlers(binaryMessenger, instanceManager)',
          );
          for (final api in allProxyApis) {
            final bool hasHostMessageCalls =
                api.constructors.isNotEmpty ||
                api.attachedFields.isNotEmpty ||
                api.hostMethods.isNotEmpty;
            if (hasHostMessageCalls) {
              indent.writeln(
                '$hostProxyApiPrefix${api.name}.setUpMessageHandlers(binaryMessenger, get$hostProxyApiPrefix${api.name}())',
              );
            }
          }
        });

        indent.writeScoped('fun tearDown() {', '}', () {
          indent.writeln(
            '$instanceManagerApiName.setUpMessageHandlers(binaryMessenger, null)',
          );
          for (final api in allProxyApis) {
            if (api.hasAnyHostMessageCalls()) {
              indent.writeln(
                '$hostProxyApiPrefix${api.name}.setUpMessageHandlers(binaryMessenger, null)',
              );
            }
          }
        });
      },
    );
  }

  // Writes the abstract method that instantiates a new instance of the Kotlin
  // class.
  void _writeProxyApiConstructorAbstractMethods(
    Indent indent,
    AstProxyApi api, {
    required TypeDeclaration apiAsTypeDeclaration,
  }) {
    for (final Constructor constructor in api.constructors) {
      _writeMethodDeclaration(
        indent,
        name: constructor.name.isNotEmpty
            ? constructor.name
            : '${classMemberNamePrefix}defaultConstructor',
        returnType: apiAsTypeDeclaration,
        documentationComments: constructor.documentationComments,
        minApiRequirement: _findAndroidHighestApiRequirement(<TypeDeclaration>[
          apiAsTypeDeclaration,
          ...constructor.parameters.map(
            (Parameter parameter) => parameter.type,
          ),
        ])?.version,
        isAbstract: true,
        parameters: <Parameter>[
          ...api.unattachedFields.map((ApiField field) {
            return Parameter(name: field.name, type: field.type);
          }),
          ...constructor.parameters,
        ],
      );
      indent.newln();
    }
  }

  // Writes the abstract method that handles instantiating an attached field.
  void _writeProxyApiAttachedFieldAbstractMethods(
    Indent indent,
    AstProxyApi api, {
    required TypeDeclaration apiAsTypeDeclaration,
  }) {
    for (final ApiField field in api.attachedFields) {
      _writeMethodDeclaration(
        indent,
        name: field.name,
        documentationComments: field.documentationComments,
        returnType: field.type,
        isAbstract: true,
        minApiRequirement: _findAndroidHighestApiRequirement(<TypeDeclaration>[
          apiAsTypeDeclaration,
          field.type,
        ])?.version,
        parameters: <Parameter>[
          if (!field.isStatic)
            Parameter(
              name: '${classMemberNamePrefix}instance',
              type: apiAsTypeDeclaration,
            ),
        ],
      );
      indent.newln();
    }
  }

  // Writes the abstract method that handles accessing an unattached field.
  void _writeProxyApiUnattachedFieldAbstractMethods(
    Indent indent,
    AstProxyApi api, {
    required TypeDeclaration apiAsTypeDeclaration,
  }) {
    for (final ApiField field in api.unattachedFields) {
      _writeMethodDeclaration(
        indent,
        name: field.name,
        documentationComments: field.documentationComments,
        returnType: field.type,
        isAbstract: true,
        minApiRequirement: _findAndroidHighestApiRequirement(<TypeDeclaration>[
          apiAsTypeDeclaration,
          field.type,
        ])?.version,
        parameters: <Parameter>[
          Parameter(
            name: '${classMemberNamePrefix}instance',
            type: apiAsTypeDeclaration,
          ),
        ],
      );
      indent.newln();
    }
  }

  // Writes the abstract method that handles making a call from for a host
  // method.
  void _writeProxyApiHostMethodAbstractMethods(
    Indent indent,
    AstProxyApi api, {
    required TypeDeclaration apiAsTypeDeclaration,
  }) {
    for (final Method method in api.hostMethods) {
      _writeMethodDeclaration(
        indent,
        name: method.name,
        returnType: method.returnType,
        documentationComments: method.documentationComments,
        isAsynchronous: method.isAsynchronous,
        isAbstract: true,
        minApiRequirement: _findAndroidHighestApiRequirement(<TypeDeclaration>[
          if (!method.isStatic) apiAsTypeDeclaration,
          method.returnType,
          ...method.parameters.map((Parameter p) => p.type),
        ])?.version,
        parameters: <Parameter>[
          if (!method.isStatic)
            Parameter(
              name: '${classMemberNamePrefix}instance',
              type: apiAsTypeDeclaration,
            ),
          ...method.parameters,
        ],
      );
      indent.newln();
    }
  }

  // Writes the `..setUpMessageHandler` method to ensure incoming messages are
  // handled by the correct abstract host methods.
  void _writeProxyApiMessageHandlerMethod(
    Indent indent,
    AstProxyApi api, {
    required TypeDeclaration apiAsTypeDeclaration,
    required String kotlinApiName,
    required String dartPackageName,
    required String fullKotlinClassName,
    required InternalKotlinOptions generatorOptions,
  }) {
    indent.writeln('@Suppress("LocalVariableName")');
    indent.writeScoped(
      'fun setUpMessageHandlers(binaryMessenger: BinaryMessenger, api: $kotlinApiName?) {',
      '}',
      () {
        indent.writeln(
          'val codec = api?.pigeonRegistrar?.codec ?: ${generatorOptions.fileSpecificClassNameComponent}$_codecName()',
        );
        void writeWithApiCheckIfNecessary(
          List<TypeDeclaration> types, {
          required String channelName,
          required void Function() onWrite,
        }) {
          final ({TypeDeclaration type, int version})? typeWithRequirement =
              _findAndroidHighestApiRequirement(types);
          if (typeWithRequirement != null) {
            final int apiRequirement = typeWithRequirement.version;
            indent.writeScoped(
              'if (android.os.Build.VERSION.SDK_INT >= $apiRequirement) {',
              '}',
              onWrite,
              addTrailingNewline: false,
            );
            indent.writeScoped(' else {', '}', () {
              final String className =
                  typeWithRequirement
                      .type
                      .associatedProxyApi!
                      .kotlinOptions
                      ?.fullClassName ??
                  typeWithRequirement.type.baseName;
              indent.format('''
                val channel = BasicMessageChannel<Any?>(
                  binaryMessenger,
                  "$channelName",
                  codec
                )
                if (api != null) {
                  channel.setMessageHandler { _, reply ->
                    reply.reply(${_getUtilsClassName(generatorOptions)}.wrapError(UnsupportedOperationException(
                      "Call references class `$className`, which requires api version $apiRequirement."
                    )))
                  }
                } else {
                  channel.setMessageHandler(null)
                }''');
            });
          } else {
            onWrite();
          }
        }

        for (final Constructor constructor in api.constructors) {
          final String name = constructor.name.isNotEmpty
              ? constructor.name
              : '${classMemberNamePrefix}defaultConstructor';
          final String channelName = makeChannelNameWithStrings(
            apiName: api.name,
            methodName: name,
            dartPackageName: dartPackageName,
          );
          writeWithApiCheckIfNecessary(
            <TypeDeclaration>[
              apiAsTypeDeclaration,
              ...api.unattachedFields.map((ApiField f) => f.type),
              ...constructor.parameters.map((Parameter p) => p.type),
            ],
            channelName: channelName,
            onWrite: () {
              _writeHostMethodMessageHandler(
                indent,
                generatorOptions: generatorOptions,
                name: name,
                channelName: channelName,
                taskQueueType: TaskQueueType.serial,
                returnType: const TypeDeclaration.voidDeclaration(),
                onCreateCall:
                    (
                      List<String> methodParameters, {
                      required String apiVarName,
                    }) {
                      return '$apiVarName.pigeonRegistrar.instanceManager.addDartCreatedInstance('
                          '$apiVarName.$name(${methodParameters.skip(1).join(',')}), ${methodParameters.first})';
                    },
                parameters: <Parameter>[
                  Parameter(
                    name: '${classMemberNamePrefix}identifier',
                    type: const TypeDeclaration(
                      baseName: 'int',
                      isNullable: false,
                    ),
                  ),
                  ...api.unattachedFields.map((ApiField field) {
                    return Parameter(name: field.name, type: field.type);
                  }),
                  ...constructor.parameters,
                ],
              );
            },
          );
        }

        for (final ApiField field in api.attachedFields) {
          final String channelName = makeChannelNameWithStrings(
            apiName: api.name,
            methodName: field.name,
            dartPackageName: dartPackageName,
          );
          writeWithApiCheckIfNecessary(
            <TypeDeclaration>[apiAsTypeDeclaration, field.type],
            channelName: channelName,
            onWrite: () {
              _writeHostMethodMessageHandler(
                indent,
                generatorOptions: generatorOptions,
                name: field.name,
                channelName: channelName,
                taskQueueType: TaskQueueType.serial,
                returnType: const TypeDeclaration.voidDeclaration(),
                onCreateCall:
                    (
                      List<String> methodParameters, {
                      required String apiVarName,
                    }) {
                      final String param = methodParameters.length > 1
                          ? methodParameters.first
                          : '';
                      return '$apiVarName.pigeonRegistrar.instanceManager.addDartCreatedInstance('
                          '$apiVarName.${field.name}($param), ${methodParameters.last})';
                    },
                parameters: <Parameter>[
                  if (!field.isStatic)
                    Parameter(
                      name: '${classMemberNamePrefix}instance',
                      type: apiAsTypeDeclaration,
                    ),
                  Parameter(
                    name: '${classMemberNamePrefix}identifier',
                    type: const TypeDeclaration(
                      baseName: 'int',
                      isNullable: false,
                    ),
                  ),
                ],
              );
            },
          );
        }

        for (final Method method in api.hostMethods) {
          final String channelName = makeChannelName(
            api,
            method,
            dartPackageName,
          );
          writeWithApiCheckIfNecessary(
            <TypeDeclaration>[
              if (!method.isStatic) apiAsTypeDeclaration,
              method.returnType,
              ...method.parameters.map((Parameter p) => p.type),
            ],
            channelName: channelName,
            onWrite: () {
              _writeHostMethodMessageHandler(
                indent,
                generatorOptions: generatorOptions,
                name: method.name,
                channelName: makeChannelName(api, method, dartPackageName),
                taskQueueType: method.taskQueueType,
                returnType: method.returnType,
                isAsynchronous: method.isAsynchronous,
                parameters: <Parameter>[
                  if (!method.isStatic)
                    Parameter(
                      name: '${classMemberNamePrefix}instance',
                      type: TypeDeclaration(
                        baseName: fullKotlinClassName,
                        isNullable: false,
                        associatedProxyApi: api,
                      ),
                    ),
                  ...method.parameters,
                ],
              );
            },
          );
        }
      },
    );
  }

  // Writes the method that calls to Dart to instantiate a new Dart instance.
  void _writeProxyApiNewInstanceMethod(
    Indent indent,
    AstProxyApi api, {
    required InternalKotlinOptions generatorOptions,
    required TypeDeclaration apiAsTypeDeclaration,
    required String newInstanceMethodName,
    required String dartPackageName,
  }) {
    indent.writeln('@Suppress("LocalVariableName", "FunctionName")');
    _writeFlutterMethod(
      indent,
      generatorOptions: generatorOptions,
      name: newInstanceMethodName,
      returnType: const TypeDeclaration.voidDeclaration(),
      documentationComments: <String>[
        ' Creates a Dart instance of ${api.name} and attaches it to [${classMemberNamePrefix}instanceArg].',
      ],
      channelName: makeChannelNameWithStrings(
        apiName: api.name,
        methodName: newInstanceMethodName,
        dartPackageName: dartPackageName,
      ),
      minApiRequirement: _findAndroidHighestApiRequirement(<TypeDeclaration>[
        apiAsTypeDeclaration,
        ...api.unattachedFields.map((ApiField field) => field.type),
      ])?.version,
      dartPackageName: dartPackageName,
      parameters: <Parameter>[
        Parameter(
          name: '${classMemberNamePrefix}instance',
          type: TypeDeclaration(
            baseName: api.name,
            isNullable: false,
            associatedProxyApi: api,
          ),
        ),
      ],
      onWriteBody:
          (
            Indent indent, {
            required InternalKotlinOptions generatorOptions,
            required List<Parameter> parameters,
            required TypeDeclaration returnType,
            required String channelName,
            required String errorClassName,
          }) {
            indent.writeScoped(
              'if (pigeonRegistrar.ignoreCallsToDart) {',
              '}',
              () {
                indent.format(
                  '''
              callback(
                  Result.failure(
                      $errorClassName("ignore-calls-error", "Calls to Dart are being ignored.", "")))''',
                );
              },
              addTrailingNewline: false,
            );
            indent.writeScoped(
              ' else if (pigeonRegistrar.instanceManager.containsInstance(${classMemberNamePrefix}instanceArg)) {',
              '}',
              () {
                indent.writeln('callback(Result.success(Unit))');
              },
              addTrailingNewline: false,
            );
            indent.writeScoped(' else {', '}', () {
              if (api.hasCallbackConstructor()) {
                indent.writeln(
                  'val ${classMemberNamePrefix}identifierArg = pigeonRegistrar.instanceManager.addHostCreatedInstance(${classMemberNamePrefix}instanceArg)',
                );
                enumerate(api.unattachedFields, (int index, ApiField field) {
                  final String argName = _getSafeArgumentName(index, field);
                  indent.writeln(
                    'val $argName = ${field.name}(${classMemberNamePrefix}instanceArg)',
                  );
                });

                indent.writeln(
                  'val binaryMessenger = pigeonRegistrar.binaryMessenger',
                );
                indent.writeln('val codec = pigeonRegistrar.codec');
                _writeFlutterMethodMessageCall(
                  indent,
                  generatorOptions: generatorOptions,
                  returnType: returnType,
                  channelName: channelName,
                  errorClassName: errorClassName,
                  parameters: <Parameter>[
                    Parameter(
                      name: '${classMemberNamePrefix}identifier',
                      type: const TypeDeclaration(
                        baseName: 'int',
                        isNullable: false,
                      ),
                    ),
                    ...api.unattachedFields.map((ApiField field) {
                      return Parameter(name: field.name, type: field.type);
                    }),
                  ],
                );
              } else {
                indent.format(
                  '''
              callback(
                  Result.failure(
                      $errorClassName("new-instance-error", "Attempting to create a new Dart instance of ${api.name}, but the class has a nonnull callback method.", "")))''',
                );
              }
            });
          },
    );
    indent.newln();
  }

  // Writes the Flutter methods that call back to Dart.
  void _writeProxyApiFlutterMethods(
    Indent indent,
    AstProxyApi api, {
    required InternalKotlinOptions generatorOptions,
    required TypeDeclaration apiAsTypeDeclaration,
    required String dartPackageName,
  }) {
    for (final Method method in api.flutterMethods) {
      _writeFlutterMethod(
        indent,
        generatorOptions: generatorOptions,
        name: method.name,
        returnType: method.returnType,
        channelName: makeChannelName(api, method, dartPackageName),
        dartPackageName: dartPackageName,
        documentationComments: method.documentationComments,
        minApiRequirement: _findAndroidHighestApiRequirement(<TypeDeclaration>[
          apiAsTypeDeclaration,
          method.returnType,
          ...method.parameters.map((Parameter parameter) => parameter.type),
        ])?.version,
        parameters: <Parameter>[
          Parameter(
            name: '${classMemberNamePrefix}instance',
            type: TypeDeclaration(
              baseName: api.name,
              isNullable: false,
              associatedProxyApi: api,
            ),
          ),
          ...method.parameters,
        ],
        onWriteBody:
            (
              Indent indent, {
              required InternalKotlinOptions generatorOptions,
              required List<Parameter> parameters,
              required TypeDeclaration returnType,
              required String channelName,
              required String errorClassName,
            }) {
              indent.writeScoped(
                'if (pigeonRegistrar.ignoreCallsToDart) {',
                '}',
                () {
                  indent.format('''
                callback(
                    Result.failure(
                        $errorClassName("ignore-calls-error", "Calls to Dart are being ignored.", "")))
                return''');
                },
                addTrailingNewline: false,
              );
              indent.writeScoped(
                ' else if (!pigeonRegistrar.instanceManager.containsInstance(${classMemberNamePrefix}instanceArg)) {',
                '}',
                () {
                  indent.format('''
                callback(
                    Result.failure(
                        $errorClassName("missing-instance-error", "Callback to `${api.name}.${method.name}` failed because native instance was not in the instance manager.", "")))
                return''');
                },
              );
              indent.writeln(
                'val binaryMessenger = pigeonRegistrar.binaryMessenger',
              );
              indent.writeln('val codec = pigeonRegistrar.codec');
              _writeFlutterMethodMessageCall(
                indent,
                generatorOptions: generatorOptions,
                returnType: returnType,
                channelName: channelName,
                errorClassName: errorClassName,
                parameters: parameters,
              );
            },
      );
      indent.newln();
    }
  }

  // Writes the getters for accessing the implementation of other ProxyApis.
  //
  // These are used for inherited Flutter methods.
  void _writeProxyApiInheritedApiMethods(Indent indent, AstProxyApi api) {
    final inheritedApiNames = <String>{
      if (api.superClass != null) api.superClass!.baseName,
      ...api.interfaces.map((TypeDeclaration type) => type.baseName),
    };
    for (final name in inheritedApiNames) {
      indent.writeln('@Suppress("FunctionName")');
      final apiName = '$hostProxyApiPrefix$name';
      _writeMethodDeclaration(
        indent,
        name: '${classMemberNamePrefix}get$apiName',
        documentationComments: <String>[
          ' An implementation of [$apiName] used to access callback methods',
        ],
        returnType: TypeDeclaration(baseName: apiName, isNullable: false),
        parameters: <Parameter>[],
      );

      indent.writeScoped('{', '}', () {
        indent.writeln('return pigeonRegistrar.get$apiName()');
      });
      indent.newln();
    }
  }
}

({TypeDeclaration type, int version})? _findAndroidHighestApiRequirement(
  Iterable<TypeDeclaration> types,
) {
  return findHighestApiRequirement(
    types,
    onGetApiRequirement: (TypeDeclaration type) {
      return type.associatedProxyApi?.kotlinOptions?.minAndroidApi;
    },
    onCompare: (int first, int second) => first.compareTo(second),
  );
}

String _getErrorClassName(InternalKotlinOptions generatorOptions) =>
    generatorOptions.errorClassName ?? 'FlutterError';

/// Calculates the name of the private utils class that will be generated for
/// the file.
String _getUtilsClassName(InternalKotlinOptions options) {
  return toUpperCamelCase(
    '${options.fileSpecificClassNameComponent ?? ''}PigeonUtils',
  );
}

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : argument.name;

/// Returns an argument name that can be used in a context where it is possible to collide
/// and append `.index` to enums.
String _getEnumSafeArgumentExpression(int count, NamedType argument) {
  return '${_getArgumentName(count, argument)}Arg';
}

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}Arg';

String _castForceUnwrap(String value, TypeDeclaration type, Indent indent) {
  return _cast(indent, value, type: type);
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
  const kotlinTypeForDartTypeMap = <String, String>{
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

String? _kotlinTypeForProxyApiType(TypeDeclaration type) {
  if (type.isProxyApi) {
    return type.associatedProxyApi!.kotlinOptions?.fullClassName ??
        type.associatedProxyApi!.name;
  }

  return null;
}

String _kotlinTypeForDartType(TypeDeclaration type) {
  return _kotlinTypeForBuiltinDartType(type) ??
      _kotlinTypeForProxyApiType(type) ??
      type.baseName;
}

String _nullSafeKotlinTypeForDartType(TypeDeclaration type) {
  final nullSafe = type.isNullable ? '?' : '';
  return '${_kotlinTypeForDartType(type)}$nullSafe';
}

/// Returns an expression to cast [variable] to [kotlinType].
String _cast(Indent indent, String variable, {required TypeDeclaration type}) {
  // Special-case Any, since no-op casts cause warnings.
  final String typeString = _kotlinTypeForDartType(type);
  if (type.isNullable && typeString == 'Any') {
    return variable;
  }
  return '$variable as ${_nullSafeKotlinTypeForDartType(type)}';
}
