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

/// The standard codec for Flutter, used for any non custom codecs and extended for custom codecs.
const String _codecName = 'PigeonCodec';

/// Options that control how Java code will be generated.
class JavaOptions {
  /// Creates a [JavaOptions] object
  const JavaOptions({
    this.className,
    this.package,
    this.copyrightHeader,
    this.useGeneratedAnnotation,
  });

  /// The name of the class that will house all the generated classes.
  final String? className;

  /// The package where the generated class will live.
  final String? package;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Determines if the `javax.annotation.Generated` is used in the output. This
  /// is false by default since that dependency isn't available in plugins by
  /// default .
  final bool? useGeneratedAnnotation;

  /// Creates a [JavaOptions] from a Map representation where:
  /// `x = JavaOptions.fromMap(x.toMap())`.
  static JavaOptions fromMap(Map<String, Object> map) {
    final Iterable<dynamic>? copyrightHeader =
        map['copyrightHeader'] as Iterable<dynamic>?;
    return JavaOptions(
      className: map['className'] as String?,
      package: map['package'] as String?,
      copyrightHeader: copyrightHeader?.cast<String>(),
      useGeneratedAnnotation: map['useGeneratedAnnotation'] as bool?,
    );
  }

  /// Converts a [JavaOptions] to a Map representation where:
  /// `x = JavaOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (className != null) 'className': className!,
      if (package != null) 'package': package!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (useGeneratedAnnotation != null)
        'useGeneratedAnnotation': useGeneratedAnnotation!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [JavaOptions].
  JavaOptions merge(JavaOptions options) {
    return JavaOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Class that manages all Java code generation.
class JavaGenerator extends StructuredGenerator<JavaOptions> {
  /// Instantiates a Java Generator.
  const JavaGenerator();

  @override
  void writeFilePrologue(
    JavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.newln();
  }

  @override
  void writeFileImports(
    JavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.package != null) {
      indent.writeln('package ${generatorOptions.package};');
      indent.newln();
    }
    if (root.classes.isNotEmpty) {
      indent.writeln('import static java.lang.annotation.ElementType.METHOD;');
      indent
          .writeln('import static java.lang.annotation.RetentionPolicy.CLASS;');
      indent.newln();
    }
    indent.writeln('import android.util.Log;');
    indent.writeln('import androidx.annotation.NonNull;');
    indent.writeln('import androidx.annotation.Nullable;');
    indent.writeln('import io.flutter.plugin.common.BasicMessageChannel;');
    indent.writeln('import io.flutter.plugin.common.BinaryMessenger;');
    indent.writeln('import io.flutter.plugin.common.MessageCodec;');
    indent.writeln('import io.flutter.plugin.common.StandardMessageCodec;');
    indent.writeln('import java.io.ByteArrayOutputStream;');
    if (root.classes.isNotEmpty) {
      indent.writeln('import java.lang.annotation.Retention;');
      indent.writeln('import java.lang.annotation.Target;');
    }
    indent.writeln('import java.nio.ByteBuffer;');
    indent.writeln('import java.util.ArrayList;');
    indent.writeln('import java.util.Arrays;');
    indent.writeln('import java.util.Collections;');
    indent.writeln('import java.util.HashMap;');
    indent.writeln('import java.util.List;');
    indent.writeln('import java.util.Map;');
    indent.writeln('import java.util.Objects;');
    indent.newln();
  }

  @override
  void writeOpenNamespace(
    JavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln(
        '$_docCommentPrefix Generated class from Pigeon.$_docCommentSuffix');
    indent.writeln(
        '@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression", "serial"})');
    if (generatorOptions.useGeneratedAnnotation ?? false) {
      indent.writeln('@javax.annotation.Generated("dev.flutter.pigeon")');
    }
    indent.writeln('public class ${generatorOptions.className!} {');
    indent.inc();
  }

  @override
  void writeEnum(
    JavaOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    String camelToSnake(String camelCase) {
      final RegExp regex = RegExp('([a-z])([A-Z]+)');
      return camelCase
          .replaceAllMapped(regex, (Match m) => '${m[1]}_${m[2]}')
          .toUpperCase();
    }

    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);

    indent.write('public enum ${anEnum.name} ');
    indent.addScoped('{', '}', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.writeln(
            '${camelToSnake(member.name)}($index)${index == anEnum.members.length - 1 ? ';' : ','}');
      });
      indent.newln();
      // This uses default access (package-private), because private causes
      // SyntheticAccessor warnings in the serialization code.
      indent.writeln('final int index;');
      indent.newln();
      indent.write('private ${anEnum.name}(final int index) ');
      indent.addScoped('{', '}', () {
        indent.writeln('this.index = index;');
      });
    });
  }

  @override
  void writeDataClass(
    JavaOptions generatorOptions,
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

    indent.write('public static final class ${classDefinition.name} ');
    indent.addScoped('{', '}', () {
      for (final NamedType field
          in getFieldsInSerializationOrder(classDefinition)) {
        _writeClassField(generatorOptions, root, indent, field);
        indent.newln();
      }

      if (getFieldsInSerializationOrder(classDefinition)
          .map((NamedType e) => !e.type.isNullable)
          .any((bool e) => e)) {
        indent.writeln(
            '$_docCommentPrefix Constructor is non-public to enforce null safety; use Builder.$_docCommentSuffix');
        indent.writeln('${classDefinition.name}() {}');
        indent.newln();
      }
      _writeEquality(indent, classDefinition);

      _writeClassBuilder(generatorOptions, root, indent, classDefinition);
      writeClassEncode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
      writeClassDecode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
    });
  }

  void _writeClassField(
      JavaOptions generatorOptions, Root root, Indent indent, NamedType field) {
    final HostDatatype hostDatatype = getFieldHostDatatype(
        field, (TypeDeclaration x) => _javaTypeForBuiltinDartType(x));
    final String nullability = field.type.isNullable ? '@Nullable' : '@NonNull';
    addDocumentationComments(
        indent, field.documentationComments, _docCommentSpec);

    indent.writeln(
        'private $nullability ${hostDatatype.datatype} ${field.name};');
    indent.newln();
    indent.write(
        'public $nullability ${hostDatatype.datatype} ${_makeGetter(field)}() ');
    indent.addScoped('{', '}', () {
      indent.writeln('return ${field.name};');
    });
    indent.newln();
    indent.writeScoped(
        'public void ${_makeSetter(field)}($nullability ${hostDatatype.datatype} setterArg) {',
        '}', () {
      if (!field.type.isNullable) {
        indent.writeScoped('if (setterArg == null) {', '}', () {
          indent.writeln(
              'throw new IllegalStateException("Nonnull field \\"${field.name}\\" is null.");');
        });
      }
      indent.writeln('this.${field.name} = setterArg;');
    });
  }

  void _writeEquality(Indent indent, Class classDefinition) {
    // Implement equals(...).
    indent.writeln('@Override');
    indent.writeScoped('public boolean equals(Object o) {', '}', () {
      indent.writeln('if (this == o) { return true; }');
      indent.writeln(
          'if (o == null || getClass() != o.getClass()) { return false; }');
      indent.writeln(
          '${classDefinition.name} that = (${classDefinition.name}) o;');
      final Iterable<String> checks = classDefinition.fields.map(
        (NamedType field) {
          // Objects.equals only does pointer equality for array types.
          if (_javaTypeIsArray(field.type)) {
            return 'Arrays.equals(${field.name}, that.${field.name})';
          }
          return field.type.isNullable
              ? 'Objects.equals(${field.name}, that.${field.name})'
              : '${field.name}.equals(that.${field.name})';
        },
      );
      indent.writeln('return ${checks.join(' && ')};');
    });
    indent.newln();

    // Implement hashCode().
    indent.writeln('@Override');
    indent.writeScoped('public int hashCode() {', '}', () {
      // As with equalty checks, arrays need special handling.
      final Iterable<String> arrayFieldNames = classDefinition.fields
          .where((NamedType field) => _javaTypeIsArray(field.type))
          .map((NamedType field) => field.name);
      final Iterable<String> nonArrayFieldNames = classDefinition.fields
          .where((NamedType field) => !_javaTypeIsArray(field.type))
          .map((NamedType field) => field.name);
      final String nonArrayHashValue = nonArrayFieldNames.isNotEmpty
          ? 'Objects.hash(${nonArrayFieldNames.join(', ')})'
          : '0';

      if (arrayFieldNames.isEmpty) {
        // Return directly if there are no array variables, to avoid redundant
        // variable lint warnings.
        indent.writeln('return $nonArrayHashValue;');
      } else {
        const String resultVar = '${varNamePrefix}result';
        indent.writeln('int $resultVar = $nonArrayHashValue;');
        // Manually mix in the Arrays.hashCode values.
        for (final String name in arrayFieldNames) {
          indent.writeln(
              '$resultVar = 31 * $resultVar + Arrays.hashCode($name);');
        }
        indent.writeln('return $resultVar;');
      }
    });
    indent.newln();
  }

  void _writeClassBuilder(
    JavaOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition,
  ) {
    indent.write('public static final class Builder ');
    indent.addScoped('{', '}', () {
      for (final NamedType field
          in getFieldsInSerializationOrder(classDefinition)) {
        final HostDatatype hostDatatype = getFieldHostDatatype(
            field, (TypeDeclaration x) => _javaTypeForBuiltinDartType(x));
        final String nullability =
            field.type.isNullable ? '@Nullable' : '@NonNull';
        indent.newln();
        indent.writeln(
            'private @Nullable ${hostDatatype.datatype} ${field.name};');
        indent.newln();
        indent.writeln('@CanIgnoreReturnValue');
        indent.writeScoped(
            'public @NonNull Builder ${_makeSetter(field)}($nullability ${hostDatatype.datatype} setterArg) {',
            '}', () {
          indent.writeln('this.${field.name} = setterArg;');
          indent.writeln('return this;');
        });
      }
      indent.newln();
      indent.write('public @NonNull ${classDefinition.name} build() ');
      indent.addScoped('{', '}', () {
        const String returnVal = 'pigeonReturn';
        indent.writeln(
            '${classDefinition.name} $returnVal = new ${classDefinition.name}();');
        for (final NamedType field
            in getFieldsInSerializationOrder(classDefinition)) {
          indent.writeln('$returnVal.${_makeSetter(field)}(${field.name});');
        }
        indent.writeln('return $returnVal;');
      });
    });
  }

  @override
  void writeClassEncode(
    JavaOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('@NonNull');
    indent.write('ArrayList<Object> toList() ');
    indent.addScoped('{', '}', () {
      indent.writeln(
          'ArrayList<Object> toListResult = new ArrayList<Object>(${classDefinition.fields.length});');
      for (final NamedType field
          in getFieldsInSerializationOrder(classDefinition)) {
        indent.writeln('toListResult.add(${field.name});');
      }
      indent.writeln('return toListResult;');
    });
  }

  @override
  void writeClassDecode(
    JavaOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.write(
        'static @NonNull ${classDefinition.name} fromList(@NonNull ArrayList<Object> ${varNamePrefix}list) ');
    indent.addScoped('{', '}', () {
      const String result = 'pigeonResult';
      indent.writeln(
          '${classDefinition.name} $result = new ${classDefinition.name}();');
      enumerate(getFieldsInSerializationOrder(classDefinition),
          (int index, final NamedType field) {
        final String fieldVariable = field.name;
        final String setter = _makeSetter(field);
        indent.writeln(
            'Object $fieldVariable = ${varNamePrefix}list.get($index);');
        indent
            .writeln('$result.$setter(${_castObject(field, fieldVariable)});');
      });
      indent.writeln('return $result;');
    });
  }

  @override
  void writeGeneralCodec(
    JavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final Iterable<EnumeratedType> enumeratedTypes = getEnumeratedTypes(root);
    indent.newln();
    indent.write(
        'private static class $_codecName extends StandardMessageCodec ');
    indent.addScoped('{', '}', () {
      indent.writeln(
          'public static final $_codecName INSTANCE = new $_codecName();');
      indent.newln();
      indent.writeln('private $_codecName() {}');
      indent.newln();
      indent.writeln('@Override');
      indent.write(
          'protected Object readValueOfType(byte type, @NonNull ByteBuffer buffer) ');
      indent.addScoped('{', '}', () {
        indent.write('switch (type) ');
        indent.addScoped('{', '}', () {
          for (final EnumeratedType customType in enumeratedTypes) {
            indent.writeln('case (byte) ${customType.enumeration}:');
            indent.nest(1, () {
              if (customType.type == CustomTypes.customClass) {
                indent.writeln(
                    'return ${customType.name}.fromList((ArrayList<Object>) readValue(buffer));');
              } else if (customType.type == CustomTypes.customEnum) {
                indent.writeln('Object value = readValue(buffer);');
                indent.writeln(
                    'return ${_intToEnum('value', customType.name, true)};');
              }
            });
          }
          indent.writeln('default:');
          indent.nest(1, () {
            indent.writeln('return super.readValueOfType(type, buffer);');
          });
        });
      });
      indent.newln();
      indent.writeln('@Override');
      indent.write(
          'protected void writeValue(@NonNull ByteArrayOutputStream stream, Object value) ');
      indent.addScoped('{', '}', () {
        bool firstClass = true;
        for (final EnumeratedType customType in enumeratedTypes) {
          if (firstClass) {
            indent.write('');
            firstClass = false;
          }
          indent.add('if (value instanceof ${customType.name}) ');
          indent.addScoped('{', '} else ', () {
            indent.writeln('stream.write(${customType.enumeration});');
            if (customType.type == CustomTypes.customClass) {
              indent.writeln(
                  'writeValue(stream, ((${customType.name}) value).toList());');
            } else {
              indent.writeln(
                  'writeValue(stream, value == null ? null : ((${customType.name}) value).index);');
            }
          }, addTrailingNewline: false);
        }
        indent.addScoped('{', '}', () {
          indent.writeln('super.writeValue(stream, value);');
        });
      });
    });
    indent.newln();
  }

  /// Writes the code for a flutter [Api], [api].
  /// Example:
  /// public static final class Foo {
  ///   public Foo(BinaryMessenger argBinaryMessenger) {...}
  ///   public interface Result<T> {
  ///     void reply(T reply);
  ///   }
  ///   public int add(int x, int y, Result<int> result) {...}
  /// }
  @override
  void writeFlutterApi(
    JavaOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    /// Returns an argument name that can be used in a context where it is possible to collide.
    String getSafeArgumentExpression(int count, NamedType argument) {
      return '${_getArgumentName(count, argument)}Arg';
    }

    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents Flutter messages that can be called from Java.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('public static class ${api.name} ');
    indent.addScoped('{', '}', () {
      indent.writeln('private final @NonNull BinaryMessenger binaryMessenger;');
      indent.writeln('private final String messageChannelSuffix;');
      indent.newln();
      indent.write(
          'public ${api.name}(@NonNull BinaryMessenger argBinaryMessenger) ');
      indent.addScoped('{', '}', () {
        indent.writeln('this(argBinaryMessenger, "");');
      });
      indent.write(
          'public ${api.name}(@NonNull BinaryMessenger argBinaryMessenger, @NonNull String messageChannelSuffix) ');
      indent.addScoped('{', '}', () {
        indent.writeln('this.binaryMessenger = argBinaryMessenger;');
        indent.writeln(
            'this.messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;');
      });
      indent.newln();
      indent.writeln('/** Public interface for sending reply. */ ');
      indent.writeln('/** The codec used by ${api.name}. */');
      indent.write('static @NonNull MessageCodec<Object> getCodec() ');
      indent.addScoped('{', '}', () {
        indent.writeln('return $_codecName.INSTANCE;');
      });

      for (final Method func in api.methods) {
        final String resultType = _getResultType(func.returnType);
        final String returnType = func.returnType.isVoid
            ? 'Void'
            : _javaTypeForDartType(func.returnType);
        String sendArgument;
        addDocumentationComments(
            indent, func.documentationComments, _docCommentSpec);
        if (func.parameters.isEmpty) {
          indent
              .write('public void ${func.name}(@NonNull $resultType result) ');
          sendArgument = 'null';
        } else {
          final Iterable<String> argTypes = func.parameters
              .map((NamedType e) => _nullsafeJavaTypeForDartType(e.type));
          final Iterable<String> argNames =
              indexMap(func.parameters, _getSafeArgumentName);
          final Iterable<String> enumSafeArgNames =
              indexMap(func.parameters, getSafeArgumentExpression);
          if (func.parameters.length == 1) {
            sendArgument =
                'new ArrayList<Object>(Collections.singletonList(${enumSafeArgNames.first}))';
          } else {
            sendArgument =
                'new ArrayList<Object>(Arrays.asList(${enumSafeArgNames.join(', ')}))';
          }
          final String argsSignature =
              map2(argTypes, argNames, (String x, String y) => '$x $y')
                  .join(', ');
          indent.write(
              'public void ${func.name}($argsSignature, @NonNull $resultType result) ');
        }
        indent.addScoped('{', '}', () {
          const String channel = 'channel';
          indent.writeln(
              'final String channelName = "${makeChannelName(api, func, dartPackageName)}" + messageChannelSuffix;');
          indent.writeln('BasicMessageChannel<Object> $channel =');
          indent.nest(2, () {
            indent.writeln('new BasicMessageChannel<>(');
            indent.nest(2, () {
              indent.writeln('binaryMessenger, channelName, getCodec());');
            });
          });
          indent.writeln('$channel.send(');
          indent.nest(2, () {
            indent.writeln('$sendArgument,');
            indent.write('channelReply -> ');
            indent.addScoped('{', '});', () {
              indent.writeScoped('if (channelReply instanceof List) {', '} ',
                  () {
                indent.writeln(
                    'List<Object> listReply = (List<Object>) channelReply;');
                indent.writeScoped('if (listReply.size() > 1) {', '} ', () {
                  indent.writeln(
                      'result.error(new FlutterError((String) listReply.get(0), (String) listReply.get(1), (String) listReply.get(2)));');
                }, addTrailingNewline: false);
                if (!func.returnType.isNullable && !func.returnType.isVoid) {
                  indent.addScoped('else if (listReply.get(0) == null) {', '} ',
                      () {
                    indent.writeln(
                        'result.error(new FlutterError("null-error", "Flutter api returned null value for non-null return value.", ""));');
                  }, addTrailingNewline: false);
                }
                indent.addScoped('else {', '}', () {
                  if (func.returnType.isVoid) {
                    indent.writeln('result.success();');
                  } else {
                    const String output = 'output';
                    final String outputExpression;
                    indent.writeln('@SuppressWarnings("ConstantConditions")');
                    if (func.returnType.baseName == 'int') {
                      outputExpression =
                          'listReply.get(0) == null ? null : ((Number) listReply.get(0)).longValue();';
                    } else {
                      outputExpression =
                          '${_cast('listReply.get(0)', javaType: returnType)};';
                    }
                    indent.writeln('$returnType $output = $outputExpression');
                    indent.writeln('result.success($output);');
                  }
                });
              }, addTrailingNewline: false);
              indent.addScoped(' else {', '} ', () {
                indent.writeln(
                    'result.error(createConnectionError(channelName));');
              });
            });
          });
        });
      }
    });
  }

  @override
  void writeApis(
    JavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.apis.any((Api api) =>
        api is AstHostApi &&
            api.methods.any((Method it) => it.isAsynchronous) ||
        api is AstFlutterApi)) {
      indent.newln();
      _writeResultInterfaces(indent);
    }
    super.writeApis(generatorOptions, root, indent,
        dartPackageName: dartPackageName);
  }

  /// Write the java code that represents a host [Api], [api].
  /// Example:
  /// public interface Foo {
  ///   int add(int x, int y);
  ///   static void setUp(BinaryMessenger binaryMessenger, Foo api) {...}
  /// }
  @override
  void writeHostApi(
    JavaOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    const List<String> generatedMessages = <String>[
      ' Generated interface from Pigeon that represents a handler of messages from Flutter.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('public interface ${api.name} ');
    indent.addScoped('{', '}', () {
      for (final Method method in api.methods) {
        _writeInterfaceMethod(generatorOptions, root, indent, api, method);
      }
      indent.newln();
      indent.writeln('/** The codec used by ${api.name}. */');
      indent.write('static @NonNull MessageCodec<Object> getCodec() ');
      indent.addScoped('{', '}', () {
        indent.writeln('return $_codecName.INSTANCE;');
      });

      indent.writeln(
          '${_docCommentPrefix}Sets up an instance of `${api.name}` to handle messages through the `binaryMessenger`.$_docCommentSuffix');
      indent.writeScoped(
          'static void setUp(@NonNull BinaryMessenger binaryMessenger, @Nullable ${api.name} api) {',
          '}', () {
        indent.writeln('setUp(binaryMessenger, "", api);');
      });
      indent.write(
          'static void setUp(@NonNull BinaryMessenger binaryMessenger, @NonNull String messageChannelSuffix, @Nullable ${api.name} api) ');
      indent.addScoped('{', '}', () {
        indent.writeln(
            'messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;');
        for (final Method method in api.methods) {
          _writeMethodSetUp(
            generatorOptions,
            root,
            indent,
            api,
            method,
            dartPackageName: dartPackageName,
          );
        }
      });
    });
  }

  /// Write a method in the interface.
  /// Example:
  ///   int add(int x, int y);
  void _writeInterfaceMethod(JavaOptions generatorOptions, Root root,
      Indent indent, Api api, final Method method) {
    final String resultType = _getResultType(method.returnType);
    final String nullableType = method.isAsynchronous
        ? ''
        : _nullabilityAnnotationFromType(method.returnType);
    final String returnType = method.isAsynchronous
        ? 'void'
        : _javaTypeForDartType(method.returnType);
    final List<String> argSignature = <String>[];
    if (method.parameters.isNotEmpty) {
      final Iterable<String> argTypes = method.parameters
          .map((NamedType e) => _nullsafeJavaTypeForDartType(e.type));
      final Iterable<String> argNames =
          method.parameters.map((NamedType e) => e.name);
      argSignature
          .addAll(map2(argTypes, argNames, (String argType, String argName) {
        return '$argType $argName';
      }));
    }
    if (method.isAsynchronous) {
      argSignature.add('@NonNull $resultType result');
    }
    if (method.documentationComments.isNotEmpty) {
      addDocumentationComments(
          indent, method.documentationComments, _docCommentSpec);
    } else {
      indent.newln();
    }
    if (nullableType != '') {
      indent.writeln(nullableType);
    }
    indent.writeln('$returnType ${method.name}(${argSignature.join(', ')});');
  }

  /// Write a static setUp function in the interface.
  /// Example:
  ///   static void setUp(BinaryMessenger binaryMessenger, Foo api) {...}
  void _writeMethodSetUp(
    JavaOptions generatorOptions,
    Root root,
    Indent indent,
    Api api,
    final Method method, {
    required String dartPackageName,
  }) {
    final String channelName = makeChannelName(api, method, dartPackageName);
    indent.write('');
    indent.addScoped('{', '}', () {
      String? taskQueue;
      if (method.taskQueueType != TaskQueueType.serial) {
        taskQueue = 'taskQueue';
        indent.writeln(
            'BinaryMessenger.TaskQueue taskQueue = binaryMessenger.makeBackgroundTaskQueue();');
      }
      indent.writeln('BasicMessageChannel<Object> channel =');
      indent.nest(2, () {
        indent.writeln('new BasicMessageChannel<>(');
        indent.nest(2, () {
          indent.write(
              'binaryMessenger, "$channelName" + messageChannelSuffix, getCodec()');
          if (taskQueue != null) {
            indent.addln(', $taskQueue);');
          } else {
            indent.addln(');');
          }
        });
      });
      indent.write('if (api != null) ');
      indent.addScoped('{', '} else {', () {
        indent.writeln('channel.setMessageHandler(');
        indent.nest(2, () {
          indent.write('(message, reply) -> ');
          indent.addScoped('{', '});', () {
            final String returnType = method.returnType.isVoid
                ? 'Void'
                : _javaTypeForDartType(method.returnType);
            indent.writeln(
                'ArrayList<Object> wrapped = new ArrayList<Object>();');
            final List<String> methodArgument = <String>[];
            if (method.parameters.isNotEmpty) {
              indent.writeln(
                  'ArrayList<Object> args = (ArrayList<Object>) message;');
              enumerate(method.parameters, (int index, NamedType arg) {
                // The StandardMessageCodec can give us [Integer, Long] for
                // a Dart 'int'.  To keep things simple we just use 64bit
                // longs in Pigeon with Java.
                final bool isInt = arg.type.baseName == 'int';
                final String argType =
                    isInt ? 'Number' : _javaTypeForDartType(arg.type);
                final String argName = _getSafeArgumentName(index, arg);
                final String argExpression = isInt
                    ? '($argName == null) ? null : $argName.longValue()'
                    : argName;
                String accessor = 'args.get($index)';
                if (argType != 'Object') {
                  accessor = _cast(accessor, javaType: argType);
                }
                indent.writeln('$argType $argName = $accessor;');
                methodArgument.add(argExpression);
              });
            }
            if (method.isAsynchronous) {
              final String resultValue =
                  method.returnType.isVoid ? 'null' : 'result';
              final String resultType = _getResultType(method.returnType);
              final String resultParam =
                  method.returnType.isVoid ? '' : '$returnType result';
              final String addResultArg =
                  method.returnType.isVoid ? 'null' : resultValue;
              const String resultName = 'resultCallback';
              indent.format('''
$resultType $resultName =
\t\tnew $resultType() {
\t\t\tpublic void success($resultParam) {
\t\t\t\twrapped.add(0, $addResultArg);
\t\t\t\treply.reply(wrapped);
\t\t\t}

\t\t\tpublic void error(Throwable error) {
\t\t\t\tArrayList<Object> wrappedError = wrapError(error);
\t\t\t\treply.reply(wrappedError);
\t\t\t}
\t\t};
''');
              methodArgument.add(resultName);
            }
            final String call =
                'api.${method.name}(${methodArgument.join(', ')})';
            if (method.isAsynchronous) {
              indent.writeln('$call;');
            } else {
              indent.write('try ');
              indent.addScoped('{', '}', () {
                if (method.returnType.isVoid) {
                  indent.writeln('$call;');
                  indent.writeln('wrapped.add(0, null);');
                } else {
                  indent.writeln('$returnType output = $call;');
                  indent.writeln('wrapped.add(0, output);');
                }
              });
              indent.add(' catch (Throwable exception) ');
              indent.addScoped('{', '}', () {
                indent.writeln(
                    'ArrayList<Object> wrappedError = wrapError(exception);');
                if (method.isAsynchronous) {
                  indent.writeln('reply.reply(wrappedError);');
                } else {
                  indent.writeln('wrapped = wrappedError;');
                }
              });
              indent.writeln('reply.reply(wrapped);');
            }
          });
        });
      });
      indent.addScoped(null, '}', () {
        indent.writeln('channel.setMessageHandler(null);');
      });
    });
  }

  void _writeResultInterfaces(Indent indent) {
    indent.writeln(
        '/** Asynchronous error handling return type for non-nullable API method returns. */');
    indent.write('public interface Result<T> ');
    indent.addScoped('{', '}', () {
      indent
          .writeln('/** Success case callback method for handling returns. */');
      indent.writeln('void success(@NonNull T result);');
      indent.newln();
      indent
          .writeln('/** Failure case callback method for handling errors. */');
      indent.writeln('void error(@NonNull Throwable error);');
    });

    indent.writeln(
        '/** Asynchronous error handling return type for nullable API method returns. */');
    indent.write('public interface NullableResult<T> ');
    indent.addScoped('{', '}', () {
      indent
          .writeln('/** Success case callback method for handling returns. */');
      indent.writeln('void success(@Nullable T result);');
      indent.newln();
      indent
          .writeln('/** Failure case callback method for handling errors. */');
      indent.writeln('void error(@NonNull Throwable error);');
    });

    indent.writeln(
        '/** Asynchronous error handling return type for void API method returns. */');
    indent.write('public interface VoidResult ');
    indent.addScoped('{', '}', () {
      indent
          .writeln('/** Success case callback method for handling returns. */');
      indent.writeln('void success();');
      indent.newln();
      indent
          .writeln('/** Failure case callback method for handling errors. */');
      indent.writeln('void error(@NonNull Throwable error);');
    });
  }

  void _writeErrorClass(Indent indent) {
    indent.writeln(
        '/** Error class for passing custom error details to Flutter via a thrown PlatformException. */');
    indent.write('public static class FlutterError extends RuntimeException ');
    indent.addScoped('{', '}', () {
      indent.newln();
      indent.writeln('/** The error code. */');
      indent.writeln('public final String code;');
      indent.newln();
      indent.writeln(
          '/** The error details. Must be a datatype supported by the api codec. */');
      indent.writeln('public final Object details;');
      indent.newln();
      indent.writeln(
          'public FlutterError(@NonNull String code, @Nullable String message, @Nullable Object details) ');
      indent.writeScoped('{', '}', () {
        indent.writeln('super(message);');
        indent.writeln('this.code = code;');
        indent.writeln('this.details = details;');
      });
    });
  }

  void _writeWrapError(Indent indent) {
    indent.format('''
@NonNull
protected static ArrayList<Object> wrapError(@NonNull Throwable exception) {
\tArrayList<Object> errorList = new ArrayList<Object>(3);
\tif (exception instanceof FlutterError) {
\t\tFlutterError error = (FlutterError) exception;
\t\terrorList.add(error.code);
\t\terrorList.add(error.getMessage());
\t\terrorList.add(error.details);
\t} else {
\t\terrorList.add(exception.toString());
\t\terrorList.add(exception.getClass().getSimpleName());
\t\terrorList.add(
\t\t\t"Cause: " + exception.getCause() + ", Stacktrace: " + Log.getStackTraceString(exception));
\t}
\treturn errorList;
}''');
  }

  void _writeCreateConnectionError(Indent indent) {
    indent.writeln('@NonNull');
    indent.writeScoped(
        'protected static FlutterError createConnectionError(@NonNull String channelName) {',
        '}', () {
      indent.writeln(
          'return new FlutterError("channel-error",  "Unable to establish connection on channel: " + channelName + ".", "");');
    });
  }

  // We are emitting our own definition of [@CanIgnoreReturnValue] to support
  // clients who use CheckReturnValue, without having to force Pigeon clients
  // to take a new dependency on error_prone_annotations.
  void _writeCanIgnoreReturnValueAnnotation(
      JavaOptions opt, Root root, Indent indent) {
    indent.newln();
    indent.writeln('@Target(METHOD)');
    indent.writeln('@Retention(CLASS)');
    indent.writeln('@interface CanIgnoreReturnValue {}');
  }

  @override
  void writeGeneralUtilities(
    JavaOptions generatorOptions,
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

    indent.newln();
    _writeErrorClass(indent);
    if (hasHostApi) {
      indent.newln();
      _writeWrapError(indent);
    }
    if (hasFlutterApi) {
      indent.newln();
      _writeCreateConnectionError(indent);
    }
    if (root.classes.isNotEmpty) {
      _writeCanIgnoreReturnValueAnnotation(generatorOptions, root, indent);
    }
  }

  @override
  void writeCloseNamespace(
    JavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.dec();
    indent.addln('}');
  }
}

/// Converts an expression that evaluates to an nullable int to an expression
/// that evaluates to a nullable enum.
String _intToEnum(String expression, String enumName, bool nullable) => nullable
    ? '$expression == null ? null : $enumName.values()[(int) $expression]'
    : '$enumName.values()[(int) $expression]';

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : argument.name;

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}Arg';

String _makeGetter(NamedType field) {
  final String uppercased =
      field.name.substring(0, 1).toUpperCase() + field.name.substring(1);
  return 'get$uppercased';
}

String _makeSetter(NamedType field) {
  final String uppercased =
      field.name.substring(0, 1).toUpperCase() + field.name.substring(1);
  return 'set$uppercased';
}

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in Java code.
String _flattenTypeArguments(List<TypeDeclaration> args) {
  return args.map<String>(_javaTypeForDartType).join(', ');
}

String _javaTypeForBuiltinGenericDartType(
  TypeDeclaration type,
  int numberTypeArguments,
) {
  if (type.typeArguments.isEmpty) {
    return '${type.baseName}<${repeat('Object', numberTypeArguments).join(', ')}>';
  } else {
    return '${type.baseName}<${_flattenTypeArguments(type.typeArguments)}>';
  }
}

bool _javaTypeIsArray(TypeDeclaration type) {
  return _javaTypeForBuiltinDartType(type)?.endsWith('[]') ?? false;
}

String? _javaTypeForBuiltinDartType(TypeDeclaration type) {
  const Map<String, String> javaTypeForDartTypeMap = <String, String>{
    'bool': 'Boolean',
    'int': 'Long',
    'String': 'String',
    'double': 'Double',
    'Uint8List': 'byte[]',
    'Int32List': 'int[]',
    'Int64List': 'long[]',
    'Float64List': 'double[]',
    'Object': 'Object',
  };
  if (javaTypeForDartTypeMap.containsKey(type.baseName)) {
    return javaTypeForDartTypeMap[type.baseName];
  } else if (type.baseName == 'List') {
    return _javaTypeForBuiltinGenericDartType(type, 1);
  } else if (type.baseName == 'Map') {
    return _javaTypeForBuiltinGenericDartType(type, 2);
  } else {
    return null;
  }
}

String _javaTypeForDartType(TypeDeclaration type) {
  return _javaTypeForBuiltinDartType(type) ?? type.baseName;
}

String _nullabilityAnnotationFromType(TypeDeclaration type) {
  return type.isVoid ? '' : (type.isNullable ? '@Nullable ' : '@NonNull ');
}

String _nullsafeJavaTypeForDartType(TypeDeclaration type) {
  final String nullSafe = _nullabilityAnnotationFromType(type);
  return '$nullSafe${_javaTypeForDartType(type)}';
}

/// Returns an expression to cast [variable] to [javaType].
String _cast(String variable, {required String javaType}) {
  // Special-case Object, since casting to Object doesn't do anything, and
  // causes a warning.
  return javaType == 'Object' ? variable : '($javaType) $variable';
}

/// Casts variable named [varName] to the correct host datatype for [field].
/// This is for use in codecs where we may have a map representation of an
/// object.
String _castObject(NamedType field, String varName) {
  final HostDatatype hostDatatype = getFieldHostDatatype(
      field, (TypeDeclaration x) => _javaTypeForBuiltinDartType(x));
  if (field.type.baseName == 'int') {
    return '($varName == null) ? null : (($varName instanceof Integer) ? (Integer) $varName : (${hostDatatype.datatype}) $varName)';
  } else {
    return _cast(varName, javaType: hostDatatype.datatype);
  }
}

/// Returns string of Result class type for method based on [TypeDeclaration].
String _getResultType(TypeDeclaration type) {
  if (type.isVoid) {
    return 'VoidResult';
  }
  if (type.isNullable) {
    return 'NullableResult<${_javaTypeForDartType(type)}>';
  }
  return 'Result<${_javaTypeForDartType(type)}>';
}
