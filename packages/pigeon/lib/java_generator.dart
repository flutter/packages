// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
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
const String _standardMessageCodec = 'StandardMessageCodec';

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

/// Calculates the name of the codec that will be generated for [api].
String _getCodecName(Api api) => '${api.name}Codec';

/// Converts an expression that evaluates to an nullable int to an expression
/// that evaluates to a nullable enum.
String _intToEnum(String expression, String enumName) =>
    '$expression == null ? null : $enumName.values()[(int)$expression]';

/// Writes the codec class that will be used by [api].
/// Example:
/// private static class FooCodec extends StandardMessageCodec {...}
void _writeCodec(Indent indent, Api api, Root root) {
  assert(getCodecClasses(api, root).isNotEmpty);
  final Iterable<EnumeratedClass> codecClasses = getCodecClasses(api, root);
  final String codecName = _getCodecName(api);
  indent
      .write('private static class $codecName extends $_standardMessageCodec ');
  indent.scoped('{', '}', () {
    indent
        .writeln('public static final $codecName INSTANCE = new $codecName();');
    indent.writeln('private $codecName() {}');
    indent.writeln('@Override');
    indent.write(
        'protected Object readValueOfType(byte type, @NonNull ByteBuffer buffer) ');
    indent.scoped('{', '}', () {
      indent.write('switch (type) ');
      indent.scoped('{', '}', () {
        for (final EnumeratedClass customClass in codecClasses) {
          indent.write('case (byte)${customClass.enumeration}: ');
          indent.writeScoped('', '', () {
            indent.writeln(
                'return ${customClass.name}.fromList((ArrayList<Object>) readValue(buffer));');
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
        'protected void writeValue(@NonNull ByteArrayOutputStream stream, Object value) ');
    indent.writeScoped('{', '}', () {
      for (final EnumeratedClass customClass in codecClasses) {
        indent.write('if (value instanceof ${customClass.name}) ');
        indent.scoped('{', '} else ', () {
          indent.writeln('stream.write(${customClass.enumeration});');
          indent.writeln(
              'writeValue(stream, ((${customClass.name}) value).toList());');
        });
      }
      indent.scoped('{', '}', () {
        indent.writeln('super.writeValue(stream, value);');
      });
    });
  });
}

/// Write the java code that represents a host [Api], [api].
/// Example:
/// public interface Foo {
///   int add(int x, int y);
///   static void setup(BinaryMessenger binaryMessenger, Foo api) {...}
/// }
void _writeHostApi(Indent indent, Api api, Root root) {
  assert(api.location == ApiLocation.host);

  bool isEnum(TypeDeclaration type) =>
      root.enums.map((Enum e) => e.name).contains(type.baseName);

  /// Write a method in the interface.
  /// Example:
  ///   int add(int x, int y);
  void writeInterfaceMethod(final Method method) {
    final String returnType = method.isAsynchronous
        ? 'void'
        : _nullsafeJavaTypeForDartType(method.returnType);
    final List<String> argSignature = <String>[];
    if (method.arguments.isNotEmpty) {
      final Iterable<String> argTypes = method.arguments
          .map((NamedType e) => _nullsafeJavaTypeForDartType(e.type));
      final Iterable<String> argNames =
          method.arguments.map((NamedType e) => e.name);
      argSignature
          .addAll(map2(argTypes, argNames, (String argType, String argName) {
        return '$argType $argName';
      }));
    }
    if (method.isAsynchronous) {
      final String resultType = method.returnType.isVoid
          ? 'Void'
          : _javaTypeForDartType(method.returnType);
      argSignature.add('Result<$resultType> result');
    }
    addDocumentationComments(
        indent, method.documentationComments, _docCommentSpec);

    indent.writeln('$returnType ${method.name}(${argSignature.join(', ')});');
  }

  /// Write a static setup function in the interface.
  /// Example:
  ///   static void setup(BinaryMessenger binaryMessenger, Foo api) {...}
  void writeMethodSetup(final Method method) {
    final String channelName = makeChannelName(api, method);
    indent.write('');
    indent.scoped('{', '}', () {
      String? taskQueue;
      if (method.taskQueueType != TaskQueueType.serial) {
        taskQueue = 'taskQueue';
        indent.writeln(
            'BinaryMessenger.TaskQueue taskQueue = binaryMessenger.makeBackgroundTaskQueue();');
      }
      indent.writeln('BasicMessageChannel<Object> channel =');
      indent.inc();
      indent.inc();
      indent.write(
          'new BasicMessageChannel<>(binaryMessenger, "$channelName", getCodec()');
      if (taskQueue != null) {
        indent.addln(', $taskQueue);');
      } else {
        indent.addln(');');
      }
      indent.dec();
      indent.dec();
      indent.write('if (api != null) ');
      indent.scoped('{', '} else {', () {
        indent.write('channel.setMessageHandler((message, reply) -> ');
        indent.scoped('{', '});', () {
          final String returnType = method.returnType.isVoid
              ? 'Void'
              : _javaTypeForDartType(method.returnType);
          indent.writeln('ArrayList wrapped = new ArrayList<>();');
          indent.write('try ');
          indent.scoped('{', '}', () {
            final List<String> methodArgument = <String>[];
            if (method.arguments.isNotEmpty) {
              indent.writeln(
                  'ArrayList<Object> args = (ArrayList<Object>)message;');
              indent.writeln('assert args != null;');
              enumerate(method.arguments, (int index, NamedType arg) {
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
                if (isEnum(arg.type)) {
                  accessor = _intToEnum(accessor, arg.type.baseName);
                } else if (argType != 'Object') {
                  accessor = '($argType)$accessor';
                }
                indent.writeln('$argType $argName = $accessor;');
                if (!arg.type.isNullable) {
                  indent.write('if ($argName == null) ');
                  indent.scoped('{', '}', () {
                    indent.writeln(
                        'throw new NullPointerException("$argName unexpectedly null.");');
                  });
                }
                methodArgument.add(argExpression);
              });
            }
            if (method.isAsynchronous) {
              final String resultValue =
                  method.returnType.isVoid ? 'null' : 'result';
              const String resultName = 'resultCallback';
              indent.format('''
Result<$returnType> $resultName = new Result<$returnType>() {
\tpublic void success($returnType result) {
\t\twrapped.add(0, $resultValue);
\t\treply.reply(wrapped);
\t}
\tpublic void error(Throwable error) {
\t\tArrayList<Object> wrappedError = wrapError(error);
\t\treply.reply(wrappedError);
\t}
};
''');
              methodArgument.add(resultName);
            }
            final String call =
                'api.${method.name}(${methodArgument.join(', ')})';
            if (method.isAsynchronous) {
              indent.writeln('$call;');
            } else if (method.returnType.isVoid) {
              indent.writeln('$call;');
              indent.writeln('wrapped.add(0, null);');
            } else {
              indent.writeln('$returnType output = $call;');
              indent.writeln('wrapped.add(0, output);');
            }
          });
          indent.write('catch (Error | RuntimeException exception) ');
          indent.scoped('{', '}', () {
            indent.writeln(
                'ArrayList<Object> wrappedError = wrapError(exception);');
            if (method.isAsynchronous) {
              indent.writeln('reply.reply(wrappedError);');
            } else {
              indent.writeln('wrapped = wrappedError;');
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

  const List<String> generatedMessages = <String>[
    ' Generated interface from Pigeon that represents a handler of messages from Flutter.'
  ];
  addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
      generatorComments: generatedMessages);

  indent.write('public interface ${api.name} ');
  indent.scoped('{', '}', () {
    api.methods.forEach(writeInterfaceMethod);
    indent.addln('');
    final String codecName = _getCodecName(api);
    indent.writeln('/** The codec used by ${api.name}. */');
    indent.write('static MessageCodec<Object> getCodec() ');
    indent.scoped('{', '}', () {
      indent.write('return ');
      if (getCodecClasses(api, root).isNotEmpty) {
        indent.write('$codecName.INSTANCE;');
      } else {
        indent.write('new $_standardMessageCodec();');
      }
    });

    indent.writeln(
        '${_docCommentPrefix}Sets up an instance of `${api.name}` to handle messages through the `binaryMessenger`.$_docCommentSuffix');
    indent.write(
        'static void setup(BinaryMessenger binaryMessenger, ${api.name} api) ');
    indent.scoped('{', '}', () {
      api.methods.forEach(writeMethodSetup);
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
/// public static class Foo {
///   public Foo(BinaryMessenger argBinaryMessenger) {...}
///   public interface Reply<T> {
///     void reply(T reply);
///   }
///   public int add(int x, int y, Reply<int> callback) {...}
/// }
void _writeFlutterApi(Indent indent, Api api, Root root) {
  assert(api.location == ApiLocation.flutter);
  const List<String> generatedMessages = <String>[
    ' Generated class from Pigeon that represents Flutter messages that can be called from Java.'
  ];
  addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
      generatorComments: generatedMessages);

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
    indent.writeln('/** The codec used by ${api.name}. */');
    indent.write('static MessageCodec<Object> getCodec() ');
    indent.scoped('{', '}', () {
      indent.write('return ');
      if (getCodecClasses(api, root).isNotEmpty) {
        indent.writeln('$codecName.INSTANCE;');
      } else {
        indent.writeln('new $_standardMessageCodec();');
      }
    });

    for (final Method func in api.methods) {
      final String channelName = makeChannelName(api, func);
      final String returnType = func.returnType.isVoid
          ? 'Void'
          : _javaTypeForDartType(func.returnType);
      String sendArgument;
      addDocumentationComments(
          indent, func.documentationComments, _docCommentSpec);
      if (func.arguments.isEmpty) {
        indent.write('public void ${func.name}(Reply<$returnType> callback) ');
        sendArgument = 'null';
      } else {
        final Iterable<String> argTypes = func.arguments
            .map((NamedType e) => _nullsafeJavaTypeForDartType(e.type));
        final Iterable<String> argNames =
            indexMap(func.arguments, _getSafeArgumentName);
        if (func.arguments.length == 1) {
          sendArgument =
              'new ArrayList<Object>(Collections.singletonList(${argNames.first}))';
        } else {
          sendArgument =
              'new ArrayList<Object>(Arrays.asList(${argNames.join(', ')}))';
        }
        final String argsSignature =
            map2(argTypes, argNames, (String x, String y) => '$x $y')
                .join(', ');
        indent.write(
            'public void ${func.name}($argsSignature, Reply<$returnType> callback) ');
      }
      indent.scoped('{', '}', () {
        const String channel = 'channel';
        indent.writeln('BasicMessageChannel<Object> $channel =');
        indent.inc();
        indent.inc();
        indent.writeln(
            'new BasicMessageChannel<>(binaryMessenger, "$channelName", getCodec());');
        indent.dec();
        indent.dec();
        indent.write('$channel.send($sendArgument, channelReply -> ');
        indent.scoped('{', '});', () {
          if (func.returnType.isVoid) {
            indent.writeln('callback.reply(null);');
          } else {
            const String output = 'output';
            indent.writeln('@SuppressWarnings("ConstantConditions")');
            if (func.returnType.baseName == 'int') {
              indent.writeln(
                  '$returnType $output = channelReply == null ? null : ((Number)channelReply).longValue();');
            } else {
              indent
                  .writeln('$returnType $output = ($returnType)channelReply;');
            }
            indent.writeln('callback.reply($output);');
          }
        });
      });
    }
  });
}

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

String _nullsafeJavaTypeForDartType(TypeDeclaration type) {
  final String nullSafe =
      type.isVoid ? '' : (type.isNullable ? '@Nullable ' : '@NonNull ');
  return '$nullSafe${_javaTypeForDartType(type)}';
}

/// Casts variable named [varName] to the correct host datatype for [field].
/// This is for use in codecs where we may have a map representation of an
/// object.
String _castObject(
    NamedType field, List<Class> classes, List<Enum> enums, String varName) {
  final HostDatatype hostDatatype = getFieldHostDatatype(field, classes, enums,
      (TypeDeclaration x) => _javaTypeForBuiltinDartType(x));
  if (field.type.baseName == 'int') {
    return '($varName == null) ? null : (($varName instanceof Integer) ? (Integer)$varName : (${hostDatatype.datatype})$varName)';
  } else if (!hostDatatype.isBuiltin &&
      classes.map((Class x) => x.name).contains(field.type.baseName)) {
    return '($varName == null) ? null : ${hostDatatype.datatype}.fromList((ArrayList<Object>)$varName)';
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

  void writeHeader() {
    if (options.copyrightHeader != null) {
      addLines(indent, options.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// $generatedCodeWarning');
    indent.writeln('// $seeAlsoWarning');
  }

  void writeImports() {
    indent.writeln('import android.util.Log;');
    indent.writeln('import androidx.annotation.NonNull;');
    indent.writeln('import androidx.annotation.Nullable;');
    indent.writeln('import io.flutter.plugin.common.BasicMessageChannel;');
    indent.writeln('import io.flutter.plugin.common.BinaryMessenger;');
    indent.writeln('import io.flutter.plugin.common.MessageCodec;');
    indent.writeln('import io.flutter.plugin.common.StandardMessageCodec;');
    indent.writeln('import java.io.ByteArrayOutputStream;');
    indent.writeln('import java.nio.ByteBuffer;');
    indent.writeln('import java.util.Arrays;');
    indent.writeln('import java.util.ArrayList;');
    indent.writeln('import java.util.Collections;');
    indent.writeln('import java.util.List;');
    indent.writeln('import java.util.Map;');
    indent.writeln('import java.util.HashMap;');
  }

  String camelToSnake(String camelCase) {
    final RegExp regex = RegExp('([a-z])([A-Z]+)');
    return camelCase
        .replaceAllMapped(regex, (Match m) => '${m[1]}_${m[2]}')
        .toUpperCase();
  }

  void writeEnum(Enum anEnum) {
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);

    indent.write('public enum ${anEnum.name} ');
    indent.scoped('{', '}', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.writeln(
            '${camelToSnake(member.name)}($index)${index == anEnum.members.length - 1 ? ';' : ','}');
      });
      indent.writeln('');
      indent.writeln('private final int index;');
      indent.write('private ${anEnum.name}(final int index) ');
      indent.scoped('{', '}', () {
        indent.writeln('this.index = index;');
      });
    });
  }

  void writeDataClass(Class klass) {
    void writeField(NamedType field) {
      final HostDatatype hostDatatype = getFieldHostDatatype(
          field,
          root.classes,
          root.enums,
          (TypeDeclaration x) => _javaTypeForBuiltinDartType(x));
      final String nullability =
          field.type.isNullable ? '@Nullable' : '@NonNull';
      addDocumentationComments(
          indent, field.documentationComments, _docCommentSpec);

      indent.writeln(
          'private $nullability ${hostDatatype.datatype} ${field.name};');
      indent.writeln(
          'public $nullability ${hostDatatype.datatype} ${_makeGetter(field)}() { return ${field.name}; }');
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

    void writeToList() {
      indent.write('@NonNull ArrayList<Object> toList() ');
      indent.scoped('{', '}', () {
        indent.writeln(
            'ArrayList<Object> toListResult = new ArrayList<Object>(${klass.fields.length});');
        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          final HostDatatype hostDatatype = getFieldHostDatatype(
              field,
              root.classes,
              root.enums,
              (TypeDeclaration x) => _javaTypeForBuiltinDartType(x));
          String toWriteValue = '';
          final String fieldName = field.name;
          if (!hostDatatype.isBuiltin &&
              rootClassNameSet.contains(field.type.baseName)) {
            toWriteValue = '($fieldName == null) ? null : $fieldName.toList()';
          } else if (!hostDatatype.isBuiltin &&
              rootEnumNameSet.contains(field.type.baseName)) {
            toWriteValue = '$fieldName == null ? null : $fieldName.index';
          } else {
            toWriteValue = field.name;
          }
          indent.writeln('toListResult.add($toWriteValue);');
        }
        indent.writeln('return toListResult;');
      });
    }

    void writeFromList() {
      indent.write(
          'static @NonNull ${klass.name} fromList(@NonNull ArrayList<Object> list) ');
      indent.scoped('{', '}', () {
        const String result = 'pigeonResult';
        indent.writeln('${klass.name} $result = new ${klass.name}();');
        enumerate(getFieldsInSerializationOrder(klass),
            (int index, final NamedType field) {
          final String fieldVariable = field.name;
          final String setter = _makeSetter(field);
          indent.writeln('Object $fieldVariable = list.get($index);');
          if (rootEnumNameSet.contains(field.type.baseName)) {
            indent.writeln(
                '$result.$setter(${_intToEnum(fieldVariable, field.type.baseName)});');
          } else {
            indent.writeln(
                '$result.$setter(${_castObject(field, root.classes, root.enums, fieldVariable)});');
          }
        });
        indent.writeln('return $result;');
      });
    }

    void writeBuilder() {
      indent.write('public static final class Builder ');
      indent.scoped('{', '}', () {
        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          final HostDatatype hostDatatype = getFieldHostDatatype(
              field,
              root.classes,
              root.enums,
              (TypeDeclaration x) => _javaTypeForBuiltinDartType(x));
          final String nullability =
              field.type.isNullable ? '@Nullable' : '@NonNull';
          indent.writeln(
              'private @Nullable ${hostDatatype.datatype} ${field.name};');
          indent.writeScoped(
              'public @NonNull Builder ${_makeSetter(field)}($nullability ${hostDatatype.datatype} setterArg) {',
              '}', () {
            indent.writeln('this.${field.name} = setterArg;');
            indent.writeln('return this;');
          });
        }
        indent.write('public @NonNull ${klass.name} build() ');
        indent.scoped('{', '}', () {
          const String returnVal = 'pigeonReturn';
          indent.writeln('${klass.name} $returnVal = new ${klass.name}();');
          for (final NamedType field in getFieldsInSerializationOrder(klass)) {
            indent.writeln('$returnVal.${_makeSetter(field)}(${field.name});');
          }
          indent.writeln('return $returnVal;');
        });
      });
    }

    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents data sent in messages.'
    ];
    addDocumentationComments(
        indent, klass.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('public static class ${klass.name} ');
    indent.scoped('{', '}', () {
      for (final NamedType field in getFieldsInSerializationOrder(klass)) {
        writeField(field);
        indent.addln('');
      }

      if (getFieldsInSerializationOrder(klass)
          .map((NamedType e) => !e.type.isNullable)
          .any((bool e) => e)) {
        indent.writeln(
            '${_docCommentPrefix}Constructor is private to enforce null safety; use Builder.$_docCommentSuffix');
        indent.writeln('private ${klass.name}() {}');
      }

      writeBuilder();
      writeToList();
      writeFromList();
    });
  }

  void writeResultInterface() {
    indent.write('public interface Result<T> ');
    indent.scoped('{', '}', () {
      indent.writeln('void success(T result);');
      indent.writeln('void error(Throwable error);');
    });
  }

  void writeApi(Api api) {
    if (api.location == ApiLocation.host) {
      _writeHostApi(indent, api, root);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApi(indent, api, root);
    }
  }

  void writeWrapError() {
    indent.format('''
@NonNull private static ArrayList<Object> wrapError(@NonNull Throwable exception) {
\tArrayList<Object> errorList = new ArrayList<>(3);
\terrorList.add(exception.toString());
\terrorList.add(exception.getClass().getSimpleName());
\terrorList.add("Cause: " + exception.getCause() + ", Stacktrace: " + Log.getStackTraceString(exception));
\treturn errorList;
}''');
  }

  writeHeader();
  indent.addln('');
  if (options.package != null) {
    indent.writeln('package ${options.package};');
  }
  indent.addln('');
  writeImports();
  indent.addln('');
  indent.writeln(
      '$_docCommentPrefix Generated class from Pigeon.$_docCommentSuffix');
  indent.writeln(
      '@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression"})');
  if (options.useGeneratedAnnotation ?? false) {
    indent.writeln('@javax.annotation.Generated("dev.flutter.pigeon")');
  }
  indent.write('public class ${options.className!} ');
  indent.scoped('{', '}', () {
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
      writeResultInterface();
    }

    for (final Api api in root.apis) {
      if (getCodecClasses(api, root).isNotEmpty) {
        _writeCodec(indent, api, root);
        indent.addln('');
      }
      writeApi(api);
    }

    writeWrapError();
  });
}
