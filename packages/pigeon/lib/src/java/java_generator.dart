// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as path;

import '../ast.dart';
import '../functional.dart';
import '../generator.dart';
import '../generator_tools.dart';
import '../types/task_queue.dart';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec = cStyleDocCommentSpec;

/// The standard codec for Flutter, used for any non custom codecs and extended for custom codecs.
const String _codecName = 'PigeonCodec';

const String _overflowClassName = '${classNamePrefix}CodecOverflow';

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
    final copyrightHeader = map['copyrightHeader'] as Iterable<dynamic>?;
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
    final result = <String, Object>{
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

/// Options that control how Java code will be generated.
class InternalJavaOptions extends InternalOptions {
  /// Creates a [InternalJavaOptions] object
  const InternalJavaOptions({
    required this.javaOut,
    this.className,
    this.package,
    this.copyrightHeader,
    this.useGeneratedAnnotation,
  });

  /// Creates InternalJavaOptions from JavaOptions.
  InternalJavaOptions.fromJavaOptions(
    JavaOptions options, {
    required this.javaOut,
    Iterable<String>? copyrightHeader,
  }) : className = options.className ?? path.basenameWithoutExtension(javaOut),
       package = options.package,
       copyrightHeader = options.copyrightHeader ?? copyrightHeader,
       useGeneratedAnnotation = options.useGeneratedAnnotation;

  /// Path to the java file that will be generated.
  final String javaOut;

  /// The name of the class that will house all the generated classes.
  final String? className;

  /// The package where the generated class will live.
  final String? package;

  /// A copyright header that will get prepended to generated code.
  @override
  final Iterable<String>? copyrightHeader;

  /// Determines if the `javax.annotation.Generated` is used in the output. This
  /// is false by default since that dependency isn't available in plugins by
  /// default .
  final bool? useGeneratedAnnotation;
}

/// Class that manages all Java code generation.
class JavaGenerator extends StructuredGenerator<InternalJavaOptions> {
  /// Instantiates a Java Generator.
  const JavaGenerator();

  @override
  void writeFilePrologue(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    super.writeFilePrologue(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
    indent.newln();
  }

  @override
  void writeFileImports(
    InternalJavaOptions generatorOptions,
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
      indent.writeln(
        'import static java.lang.annotation.RetentionPolicy.CLASS;',
      );
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
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln('/** Generated class from Pigeon. */');
    indent.writeln(
      '@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression", "serial"})',
    );
    if (generatorOptions.useGeneratedAnnotation ?? false) {
      indent.writeln(
        '@javax.annotation.Generated("$defaultPluginPackageName")',
      );
    }
    indent.writeln('public class ${generatorOptions.className!} {');
    indent.inc();
    _writeNumberHelpers(indent);
    _writeDeepEquals(indent);
    _writeDeepHashCode(indent);
  }

  @override
  void writeEnum(
    InternalJavaOptions generatorOptions,
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

    indent.write('public enum ${anEnum.name} ');
    indent.addScoped('{', '}', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
          indent,
          member.documentationComments,
          _docCommentSpec,
        );
        indent.writeln(
          '${toScreamingSnakeCase(member.name)}($index)${index == anEnum.members.length - 1 ? ';' : ','}',
        );
      });
      indent.newln();
      // This uses default access (package-private), because private causes
      // SyntheticAccessor warnings in the serialization code.
      indent.writeln('final int index;');
      indent.newln();
      indent.write('${anEnum.name}(final int index) ');
      indent.addScoped('{', '}', () {
        indent.writeln('this.index = index;');
      });
    });
  }

  @override
  void writeDataClass(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    const generatedMessages = <String>[
      ' Generated class from Pigeon that represents data sent in messages.',
    ];
    indent.newln();
    addDocumentationComments(
      indent,
      classDefinition.documentationComments,
      _docCommentSpec,
      generatorComments: generatedMessages,
    );

    _writeDataClassSignature(generatorOptions, indent, classDefinition, () {
      if (getFieldsInSerializationOrder(
        classDefinition,
      ).map((NamedType e) => !e.type.isNullable).any((bool e) => e)) {
        indent.writeln(
          '/** Constructor is non-public to enforce null safety; use Builder. */',
        );
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
    InternalJavaOptions generatorOptions,
    Indent indent,
    NamedType field,
  ) {
    final HostDatatype hostDatatype = getFieldHostDatatype(
      field,
      (TypeDeclaration x) => _javaTypeForBuiltinDartType(x),
    );
    final nullability = field.type.isNullable ? '@Nullable ' : '@NonNull ';
    addDocumentationComments(
      indent,
      field.documentationComments,
      _docCommentSpec,
    );

    indent.writeln(
      'private $nullability${hostDatatype.datatype} ${field.name};',
    );
    indent.newln();
    indent.write(
      'public $nullability${hostDatatype.datatype} ${_makeGetter(field)}() ',
    );
    indent.addScoped('{', '}', () {
      indent.writeln('return ${field.name};');
    });
    indent.newln();
    indent.writeScoped(
      'public void ${_makeSetter(field)}($nullability${hostDatatype.datatype} setterArg) {',
      '}',
      () {
        if (!field.type.isNullable) {
          indent.writeScoped('if (setterArg == null) {', '}', () {
            indent.writeln(
              'throw new IllegalStateException("Nonnull field \\"${field.name}\\" is null.");',
            );
          });
        }
        indent.writeln('this.${field.name} = setterArg;');
      },
    );
  }

  void _writeDataClassSignature(
    InternalJavaOptions generatorOptions,
    Indent indent,
    Class classDefinition,
    void Function() dataClassBody, {
    bool private = false,
  }) {
    indent.write(
      '${private ? 'private' : 'public'} static final class ${classDefinition.name} ',
    );
    indent.addScoped('{', '}', () {
      for (final NamedType field in getFieldsInSerializationOrder(
        classDefinition,
      )) {
        _writeClassField(generatorOptions, indent, field);
        indent.newln();
      }
      dataClassBody();
    });
  }

  void _writeEquality(Indent indent, Class classDefinition) {
    // Implement equals(...).
    indent.writeln('@Override');
    indent.writeScoped('public boolean equals(Object o) {', '}', () {
      indent.writeln('if (this == o) { return true; }');
      indent.writeln(
        'if (o == null || getClass() != o.getClass()) { return false; }',
      );
      indent.writeln(
        '${classDefinition.name} that = (${classDefinition.name}) o;',
      );
      final Iterable<String> checks = classDefinition.fields.map((
        NamedType field,
      ) {
        return 'pigeonDeepEquals(${field.name}, that.${field.name})';
      });
      indent.writeln('return ${checks.join(' && ')};');
    });
    indent.newln();

    // Implement hashCode().
    indent.writeln('@Override');
    indent.writeScoped('public int hashCode() {', '}', () {
      final Iterable<String> fieldNames = classDefinition.fields.map(
        (NamedType field) => field.name,
      );
      if (fieldNames.isEmpty) {
        indent.writeln('return Objects.hash(getClass());');
      } else {
        indent.writeln(
          'Object[] fields = new Object[] {getClass(), ${fieldNames.join(', ')}};',
        );
        indent.writeln('return pigeonDeepHashCode(fields);');
      }
    });
    indent.newln();
  }

  void _writeDeepEquals(Indent indent) {
    indent.writeScoped(
      'static boolean pigeonDeepEquals(Object a, Object b) {',
      '}',
      () {
        indent.writeln('if (a == b) { return true; }');
        indent.writeln('if (a == null || b == null) { return false; }');
        indent.writeScoped(
          'if (a instanceof byte[] && b instanceof byte[]) {',
          '}',
          () {
            indent.writeln('return Arrays.equals((byte[]) a, (byte[]) b);');
          },
        );
        indent.writeScoped(
          'if (a instanceof int[] && b instanceof int[]) {',
          '}',
          () {
            indent.writeln('return Arrays.equals((int[]) a, (int[]) b);');
          },
        );
        indent.writeScoped(
          'if (a instanceof long[] && b instanceof long[]) {',
          '}',
          () {
            indent.writeln('return Arrays.equals((long[]) a, (long[]) b);');
          },
        );
        indent.writeScoped(
          'if (a instanceof double[] && b instanceof double[]) {',
          '}',
          () {
            indent.writeln('double[] da = (double[]) a;');
            indent.writeln('double[] db = (double[]) b;');
            indent.writeScoped('if (da.length != db.length) {', '}', () {
              indent.writeln('return false;');
            });
            indent.writeScoped(
              'for (int i = 0; i < da.length; i++) {',
              '}',
              () {
                indent.writeScoped(
                  'if (!pigeonDoubleEquals(da[i], db[i])) {',
                  '}',
                  () {
                    indent.writeln('return false;');
                  },
                );
              },
            );
            indent.writeln('return true;');
          },
        );
        indent.writeScoped(
          'if (a instanceof List && b instanceof List) {',
          '}',
          () {
            indent.writeln('List<?> listA = (List<?>) a;');
            indent.writeln('List<?> listB = (List<?>) b;');
            indent.writeln(
              'if (listA.size() != listB.size()) { return false; }',
            );
            indent.writeScoped(
              'for (int i = 0; i < listA.size(); i++) {',
              '}',
              () {
                indent.writeScoped(
                  'if (!pigeonDeepEquals(listA.get(i), listB.get(i))) {',
                  '}',
                  () {
                    indent.writeln('return false;');
                  },
                );
              },
            );
            indent.writeln('return true;');
          },
        );
        indent.writeScoped(
          'if (a instanceof Map && b instanceof Map) {',
          '}',
          () {
            indent.writeln('Map<?, ?> mapA = (Map<?, ?>) a;');
            indent.writeln('Map<?, ?> mapB = (Map<?, ?>) b;');
            indent.writeln('if (mapA.size() != mapB.size()) { return false; }');
            indent.writeScoped(
              'for (Map.Entry<?, ?> entryA : mapA.entrySet()) {',
              '}',
              () {
                indent.writeln('Object keyA = entryA.getKey();');
                indent.writeln('Object valueA = entryA.getValue();');
                indent.writeln('boolean found = false;');
                indent.writeScoped(
                  'for (Map.Entry<?, ?> entryB : mapB.entrySet()) {',
                  '}',
                  () {
                    indent.writeln('Object keyB = entryB.getKey();');
                    indent.writeScoped(
                      'if (pigeonDeepEquals(keyA, keyB)) {',
                      '}',
                      () {
                        indent.writeln('Object valueB = entryB.getValue();');
                        indent.writeln(
                          'if (pigeonDeepEquals(valueA, valueB)) {',
                        );
                        indent.nest(1, () {
                          indent.writeln('found = true;');
                          indent.writeln('break;');
                        });
                        indent.writeln('} else {');
                        indent.nest(1, () {
                          indent.writeln('return false;');
                        });
                        indent.writeln('}');
                      },
                    );
                  },
                );
                indent.writeScoped('if (!found) {', '}', () {
                  indent.writeln('return false;');
                });
              },
            );
            indent.writeln('return true;');
          },
        );
        indent.writeScoped(
          'if (a instanceof Double && b instanceof Double) {',
          '}',
          () {
            indent.writeln(
              'return pigeonDoubleEquals((double) a, (double) b);',
            );
          },
        );
        indent.writeScoped(
          'if (a instanceof Float && b instanceof Float) {',
          '}',
          () {
            indent.writeln('return pigeonFloatEquals((float) a, (float) b);');
          },
        );
        indent.writeln('return a.equals(b);');
      },
    );
    indent.newln();
  }

  void _writeDeepHashCode(Indent indent) {
    indent.writeScoped('static int pigeonDeepHashCode(Object value) {', '}', () {
      indent.writeln('if (value == null) { return 0; }');
      indent.writeScoped('if (value instanceof byte[]) {', '}', () {
        indent.writeln('return Arrays.hashCode((byte[]) value);');
      });
      indent.writeScoped('if (value instanceof int[]) {', '}', () {
        indent.writeln('return Arrays.hashCode((int[]) value);');
      });
      indent.writeScoped('if (value instanceof long[]) {', '}', () {
        indent.writeln('return Arrays.hashCode((long[]) value);');
      });
      indent.writeScoped('if (value instanceof double[]) {', '}', () {
        indent.writeln('double[] da = (double[]) value;');
        indent.writeln('int result = 1;');
        indent.writeScoped('for (double d : da) {', '}', () {
          indent.writeln('result = 31 * result + pigeonDoubleHashCode(d);');
        });
        indent.writeln('return result;');
      });
      indent.writeScoped('if (value instanceof List) {', '}', () {
        indent.writeln('int result = 1;');
        indent.writeScoped('for (Object item : (List<?>) value) {', '}', () {
          indent.writeln('result = 31 * result + pigeonDeepHashCode(item);');
        });
        indent.writeln('return result;');
      });
      indent.writeScoped('if (value instanceof Map) {', '}', () {
        indent.writeln('int result = 0;');
        indent.writeScoped(
          'for (Map.Entry<?, ?> entry : ((Map<?, ?>) value).entrySet()) {',
          '}',
          () {
            indent.writeln(
              'result += ((pigeonDeepHashCode(entry.getKey()) * 31) ^ pigeonDeepHashCode(entry.getValue()));',
            );
          },
        );
        indent.writeln('return result;');
      });
      indent.writeScoped('if (value instanceof Object[]) {', '}', () {
        indent.writeln('int result = 1;');
        indent.writeScoped('for (Object item : (Object[]) value) {', '}', () {
          indent.writeln('result = 31 * result + pigeonDeepHashCode(item);');
        });
        indent.writeln('return result;');
      });
      indent.writeScoped('if (value instanceof Double) {', '}', () {
        indent.writeln('return pigeonDoubleHashCode((double) value);');
      });
      indent.writeScoped('if (value instanceof Float) {', '}', () {
        indent.writeln('return pigeonFloatHashCode((float) value);');
      });
      indent.writeln('return value.hashCode();');
    });
    indent.newln();
  }

  void _writeNumberHelpers(Indent indent) {
    indent.writeScoped(
      'static boolean pigeonDoubleEquals(double a, double b) {',
      '}',
      () {
        indent.writeln('// Normalize -0.0 to 0.0 and handle NaN equality.');
        indent.writeln(
          'return (a == 0.0 ? 0.0 : a) == (b == 0.0 ? 0.0 : b) || (Double.isNaN(a) && Double.isNaN(b));',
        );
      },
    );
    indent.newln();
    indent.writeScoped(
      'static boolean pigeonFloatEquals(float a, float b) {',
      '}',
      () {
        indent.writeln('// Normalize -0.0 to 0.0 and handle NaN equality.');
        indent.writeln(
          'return (a == 0.0f ? 0.0f : a) == (b == 0.0f ? 0.0f : b) || (Float.isNaN(a) && Float.isNaN(b));',
        );
      },
    );
    indent.newln();
    indent.writeScoped('static int pigeonDoubleHashCode(double d) {', '}', () {
      indent.writeln(
        '// Normalize -0.0 to 0.0 and handle NaN to ensure consistent hash codes.',
      );
      indent.writeScoped('if (d == 0.0) {', '}', () {
        indent.writeln('d = 0.0;');
      });
      indent.writeln('long bits = Double.doubleToLongBits(d);');
      indent.writeln('return (int) (bits ^ (bits >>> 32));');
    });
    indent.newln();
    indent.writeScoped('static int pigeonFloatHashCode(float f) {', '}', () {
      indent.writeln(
        '// Normalize -0.0 to 0.0 and handle NaN to ensure consistent hash codes.',
      );
      indent.writeScoped('if (f == 0.0f) {', '}', () {
        indent.writeln('f = 0.0f;');
      });
      indent.writeln('return Float.floatToIntBits(f);');
    });
    indent.newln();
  }

  void _writeClassBuilder(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition,
  ) {
    indent.write('public static final class Builder ');
    indent.addScoped('{', '}', () {
      for (final NamedType field in getFieldsInSerializationOrder(
        classDefinition,
      )) {
        final HostDatatype hostDatatype = getFieldHostDatatype(
          field,
          (TypeDeclaration x) => _javaTypeForBuiltinDartType(x),
        );
        final nullability = field.type.isNullable ? '@Nullable' : '@NonNull';
        indent.newln();
        indent.writeln(
          'private @Nullable ${hostDatatype.datatype} ${field.name};',
        );
        indent.newln();
        indent.writeln('@CanIgnoreReturnValue');
        indent.writeScoped(
          'public @NonNull Builder ${_makeSetter(field)}($nullability ${hostDatatype.datatype} setterArg) {',
          '}',
          () {
            indent.writeln('this.${field.name} = setterArg;');
            indent.writeln('return this;');
          },
        );
      }
      indent.newln();
      indent.write('public @NonNull ${classDefinition.name} build() ');
      indent.addScoped('{', '}', () {
        const returnVal = 'pigeonReturn';
        indent.writeln(
          '${classDefinition.name} $returnVal = new ${classDefinition.name}();',
        );
        for (final NamedType field in getFieldsInSerializationOrder(
          classDefinition,
        )) {
          indent.writeln('$returnVal.${_makeSetter(field)}(${field.name});');
        }
        indent.writeln('return $returnVal;');
      });
    });
  }

  @override
  void writeClassEncode(
    InternalJavaOptions generatorOptions,
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
        'ArrayList<Object> toListResult = new ArrayList<>(${classDefinition.fields.length});',
      );
      for (final NamedType field in getFieldsInSerializationOrder(
        classDefinition,
      )) {
        indent.writeln('toListResult.add(${field.name});');
      }
      indent.writeln('return toListResult;');
    });
  }

  @override
  void writeClassDecode(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.write(
      'static @NonNull ${classDefinition.name} fromList(@NonNull ArrayList<Object> ${varNamePrefix}list) ',
    );
    indent.addScoped('{', '}', () {
      const result = 'pigeonResult';
      indent.writeln(
        '${classDefinition.name} $result = new ${classDefinition.name}();',
      );
      enumerate(getFieldsInSerializationOrder(classDefinition), (
        int index,
        final NamedType field,
      ) {
        final String fieldVariable = field.name;
        final String setter = _makeSetter(field);
        indent.writeln(
          'Object $fieldVariable = ${varNamePrefix}list.get($index);',
        );
        indent.writeln(
          '$result.$setter(${_castObject(field, fieldVariable)});',
        );
      });
      indent.writeln('return $result;');
    });
  }

  @override
  void writeGeneralCodec(
    InternalJavaOptions generatorOptions,
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
          : 'index';
      final nullCheck = customType.type == CustomTypes.customEnum
          ? 'value == null ? null : '
          : '';
      final valueString = customType.enumeration < maximumCodecFieldKey
          ? '$nullCheck((${customType.name}) value).$encodeString'
          : 'wrap.toList()';
      final int enumeration = customType.enumeration < maximumCodecFieldKey
          ? customType.enumeration
          : maximumCodecFieldKey;

      indent.add('if (value instanceof ${customType.name}) ');
      indent.addScoped('{', '} else ', () {
        if (customType.enumeration >= maximumCodecFieldKey) {
          indent.writeln(
            '$_overflowClassName wrap = new $_overflowClassName();',
          );
          indent.writeln(
            'wrap.setType(${customType.enumeration - maximumCodecFieldKey}L);',
          );
          indent.writeln(
            'wrap.setWrapped($nullCheck((${customType.name}) value).$encodeString);',
          );
        }
        indent.writeln('stream.write($enumeration);');
        indent.writeln('writeValue(stream, $valueString);');
      }, addTrailingNewline: false);
    }

    void writeDecodeLogic(EnumeratedType customType) {
      indent.write('case (byte) ${customType.enumeration}:');
      if (customType.type == CustomTypes.customClass) {
        indent.newln();
        indent.nest(1, () {
          indent.writeln(
            'return ${customType.name}.fromList((ArrayList<Object>) readValue(buffer));',
          );
        });
      } else if (customType.type == CustomTypes.customEnum) {
        indent.addScoped(' {', '}', () {
          indent.writeln('Object value = readValue(buffer);');
          indent.writeln(
            'return ${_intToEnum('value', customType.name, true)};',
          );
        });
      }
    }

    final overflowClass = EnumeratedType(
      _overflowClassName,
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
    indent.newln();
    indent.write(
      'private static class $_codecName extends StandardMessageCodec ',
    );
    indent.addScoped('{', '}', () {
      indent.writeln(
        'public static final $_codecName INSTANCE = new $_codecName();',
      );
      indent.newln();
      indent.writeln('private $_codecName() {}');
      indent.newln();
      indent.writeln('@Override');
      indent.writeScoped(
        'protected Object readValueOfType(byte type, @NonNull ByteBuffer buffer) {',
        '}',
        () {
          indent.writeScoped('switch (type) {', '}', () {
            for (final customType in enumeratedTypes) {
              if (customType.enumeration < maximumCodecFieldKey) {
                writeDecodeLogic(customType);
              }
            }
            if (root.requiresOverflowClass) {
              writeDecodeLogic(overflowClass);
            }
            indent.writeln('default:');
            indent.nest(1, () {
              indent.writeln('return super.readValueOfType(type, buffer);');
            });
          });
        },
      );
      indent.newln();
      indent.writeln('@Override');
      indent.write(
        'protected void writeValue(@NonNull ByteArrayOutputStream stream, Object value) ',
      );
      indent.addScoped('{', '}', () {
        indent.write('');
        enumeratedTypes.forEach(writeEncodeLogic);
        indent.addScoped('{', '}', () {
          indent.writeln('super.writeValue(stream, value);');
        });
      });
    });
    indent.newln();
  }

  void _writeCodecOverflowUtilities(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    List<EnumeratedType> types, {
    required String dartPackageName,
  }) {
    if (types.length <= totalCustomCodecKeysAllowed) {
      return;
    }
    indent.newln();

    final overflowInteration = NamedType(
      name: 'type',
      type: const TypeDeclaration(baseName: 'int', isNullable: false),
    );
    final overflowObject = NamedType(
      name: 'wrapped',
      type: const TypeDeclaration(baseName: 'Object', isNullable: true),
    );
    final overflowFields = <NamedType>[overflowInteration, overflowObject];
    final overflowClass = Class(
      name: _overflowClassName,
      fields: overflowFields,
    );

    _writeDataClassSignature(generatorOptions, indent, overflowClass, () {
      writeClassEncode(
        generatorOptions,
        root,
        indent,
        overflowClass,
        dartPackageName: dartPackageName,
      );

      indent.format('''
static @Nullable Object fromList(@NonNull ArrayList<Object> ${varNamePrefix}list) {
  $_overflowClassName wrapper = new $_overflowClassName();
  wrapper.setType((Long) ${varNamePrefix}list.get(0));
  wrapper.setWrapped(${varNamePrefix}list.get(1));
  return wrapper.unwrap();
}
''');

      indent.writeScoped('@Nullable Object unwrap() {', '}', () {
        indent.format('''
if (wrapped == null) {
  return null;
}
''');
        indent.writeScoped('switch (type.intValue()) {', '}', () {
          for (int i = totalCustomCodecKeysAllowed; i < types.length; i++) {
            final int caseIndex = i - totalCustomCodecKeysAllowed;
            final EnumeratedType type = types[i];
            indent.writeScoped('case $caseIndex:', '', () {
              if (type.type == CustomTypes.customClass) {
                indent.writeln(
                  'return ${type.name}.fromList((ArrayList<Object>) wrapped);',
                );
              } else if (type.type == CustomTypes.customEnum) {
                indent.writeln(
                  'return ${_intToEnum('wrapped', type.name, false)};',
                );
              }
            });
          }
          indent.writeScoped('default:', '', () {
            indent.writeln('return null;');
          });
        });
      });
    }, private: true);
  }

  /// Writes the code for a flutter [Api], [api].
  /// Example:
  /// ```java
  /// public static final class Foo {
  ///   public Foo(BinaryMessenger argBinaryMessenger) {...}
  ///   public interface Result<T> {
  ///     void reply(T reply);
  ///   }
  ///   public int add(int x, int y, Result<int> result) {...}
  /// }
  /// ```
  @override
  void writeFlutterApi(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    /// Returns an argument name that can be used in a context where it is possible to collide.
    String getSafeArgumentExpression(int count, NamedType argument) {
      return '${_getArgumentName(count, argument)}Arg';
    }

    const generatedMessages = <String>[
      ' Generated class from Pigeon that represents Flutter messages that can be called from Java.',
    ];
    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
      generatorComments: generatedMessages,
    );

    indent.write('public static class ${api.name} ');
    indent.addScoped('{', '}', () {
      indent.writeln('private final @NonNull BinaryMessenger binaryMessenger;');
      indent.writeln('private final String messageChannelSuffix;');
      indent.newln();
      indent.write(
        'public ${api.name}(@NonNull BinaryMessenger argBinaryMessenger) ',
      );
      indent.addScoped('{', '}', () {
        indent.writeln('this(argBinaryMessenger, "");');
      });
      indent.write(
        'public ${api.name}(@NonNull BinaryMessenger argBinaryMessenger, @NonNull String messageChannelSuffix) ',
      );
      indent.addScoped('{', '}', () {
        indent.writeln('this.binaryMessenger = argBinaryMessenger;');
        indent.writeln(
          'this.messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;',
        );
      });
      indent.newln();
      addDocumentationComments(
        indent,
        <String>[],
        _docCommentSpec,
        generatorComments: <String>[
          'Public interface for sending reply.',
          'The codec used by ${api.name}.',
        ],
      );
      indent.write('static @NonNull MessageCodec<Object> getCodec() ');
      indent.addScoped('{', '}', () {
        indent.writeln('return $_codecName.INSTANCE;');
      });

      for (final Method func in api.methods) {
        final String returnType = func.returnType.isVoid
            ? 'Void'
            : _javaTypeForDartType(func.returnType);
        String sendArgument;
        addDocumentationComments(
          indent,
          func.documentationComments,
          _docCommentSpec,
        );
        if (func.parameters.isEmpty) {
          sendArgument = 'null';
        } else {
          final Iterable<String> enumSafeArgNames = indexMap(
            func.parameters,
            getSafeArgumentExpression,
          );
          if (func.parameters.length == 1) {
            sendArgument =
                'new ArrayList<>(Collections.singletonList(${enumSafeArgNames.first}))';
          } else {
            sendArgument =
                'new ArrayList<>(Arrays.asList(${enumSafeArgNames.join(', ')}))';
          }
        }
        indent.write('public ${_getMethodSignature(func, isHostApi: false)} ');
        indent.addScoped('{', '}', () {
          const channel = 'channel';
          indent.writeln(
            'final String channelName = "${makeChannelName(api, func, dartPackageName)}" + messageChannelSuffix;',
          );
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
              indent.writeScoped(
                'if (channelReply instanceof List) {',
                '} ',
                () {
                  indent.writeln(
                    'List<Object> listReply = (List<Object>) channelReply;',
                  );
                  indent.writeScoped('if (listReply.size() > 1) {', '} ', () {
                    indent.writeln(
                      'result.error(new FlutterError((String) listReply.get(0), (String) listReply.get(1), listReply.get(2)));',
                    );
                  }, addTrailingNewline: false);
                  if (!func.returnType.isNullable && !func.returnType.isVoid) {
                    indent.addScoped(
                      'else if (listReply.get(0) == null) {',
                      '} ',
                      () {
                        indent.writeln(
                          'result.error(new FlutterError("null-error", "Flutter api returned null value for non-null return value.", ""));',
                        );
                      },
                      addTrailingNewline: false,
                    );
                  }
                  indent.addScoped('else {', '}', () {
                    if (func.returnType.isVoid) {
                      indent.writeln('result.success();');
                    } else {
                      const output = 'output';
                      final String outputExpression;
                      indent.writeln('@SuppressWarnings("ConstantConditions")');
                      outputExpression =
                          '${_cast('listReply.get(0)', javaType: returnType)};';
                      indent.writeln('$returnType $output = $outputExpression');
                      indent.writeln('result.success($output);');
                    }
                  });
                },
                addTrailingNewline: false,
              );
              indent.addScoped(' else {', '} ', () {
                indent.writeln(
                  'result.error(createConnectionError(channelName));',
                );
              });
            });
          });
        });
      }
    });
  }

  @override
  void writeApis(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.apis.any(
      (Api api) =>
          api is AstHostApi &&
              api.methods.any((Method it) => it.isAsynchronous) ||
          api is AstFlutterApi,
    )) {
      indent.newln();
      _writeResultInterfaces(indent);
    }
    super.writeApis(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
  }

  /// Write the java code that represents a host [Api], [api].
  /// Example:
  /// public interface Foo {
  ///   int add(int x, int y);
  ///   static void setUp(BinaryMessenger binaryMessenger, Foo api) {...}
  /// }
  @override
  @override
  void writeHostApi(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    _generateInterface(generatorOptions, root, indent, api, () {
      _generateSetupMethod(
        generatorOptions,
        root,
        indent,
        api,
        dartPackageName: dartPackageName,
      );
    });
  }

  void _generateInterface(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api,
    void Function() body,
  ) {
    const generatedMessages = <String>[
      ' Generated interface from Pigeon that represents a handler of messages from Flutter.',
    ];
    addDocumentationComments(
      indent,
      api.documentationComments,
      _docCommentSpec,
      generatorComments: generatedMessages,
    );

    indent.write('public interface ${api.name} ');
    indent.addScoped('{', '}', () {
      for (final Method method in api.methods) {
        _writeInterfaceMethod(generatorOptions, root, indent, api, method);
      }
      body();
    });
  }

  void _generateSetupMethod(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('/** The codec used by ${api.name}. */');
    indent.write('static @NonNull MessageCodec<Object> getCodec() ');
    indent.addScoped('{', '}', () {
      indent.writeln('return $_codecName.INSTANCE;');
    });

    indent.writeln(
      '/** Sets up an instance of `${api.name}` to handle messages through the `binaryMessenger`. */',
    );
    indent.writeScoped(
      'static void setUp(@NonNull BinaryMessenger binaryMessenger, @Nullable ${api.name} api) {',
      '}',
      () {
        indent.writeln('setUp(binaryMessenger, "", api);');
      },
    );
    indent.write(
      'static void setUp(@NonNull BinaryMessenger binaryMessenger, @NonNull String messageChannelSuffix, @Nullable ${api.name} api) ',
    );
    indent.addScoped('{', '}', () {
      indent.writeln(
        'messageChannelSuffix = messageChannelSuffix.isEmpty() ? "" : "." + messageChannelSuffix;',
      );
      String? serialBackgroundQueue;
      if (api.methods.any(
        (Method m) => m.taskQueueType == TaskQueueType.serialBackgroundThread,
      )) {
        serialBackgroundQueue = 'taskQueue';
        indent.writeln(
          'BinaryMessenger.TaskQueue $serialBackgroundQueue = binaryMessenger.makeBackgroundTaskQueue();',
        );
      }
      for (final Method method in api.methods) {
        _writeHostMethodMessageHandler(
          generatorOptions,
          root,
          indent,
          api,
          method,
          dartPackageName: dartPackageName,
          serialBackgroundQueue:
              method.taskQueueType == TaskQueueType.serialBackgroundThread
              ? serialBackgroundQueue
              : null,
        );
      }
    });
  }

  /// Write a method in the interface.
  /// Example:
  ///   int add(int x, int y);
  void _writeInterfaceMethod(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    Api api,
    final Method method,
  ) {
    if (method.documentationComments.isNotEmpty) {
      addDocumentationComments(
        indent,
        method.documentationComments,
        _docCommentSpec,
      );
    } else {
      indent.newln();
    }
    indent.writeln('${_getMethodSignature(method, isHostApi: true)};');
  }

  /// Write a single method's handler for the setUp function.
  void _writeHostMethodMessageHandler(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent,
    Api api,
    final Method method, {
    required String dartPackageName,
    String? serialBackgroundQueue,
  }) {
    final String channelName = makeChannelName(api, method, dartPackageName);
    indent.write('');
    indent.addScoped('{', '}', () {
      final varChannelName = 'channel';
      _writeChannelAllocation(
        indent,
        varChannelName: varChannelName,
        channelName: channelName,
        serialBackgroundQueue: serialBackgroundQueue,
      );

      final String returnType = method.returnType.isVoid
          ? 'Void'
          : _javaTypeForDartType(method.returnType);
      _writeMessageHandlerRegistration(
        indent,
        varChannelName: varChannelName,
        setHandlerCondition: 'api != null',
        messageVarName: 'message',
        body: () {
          final methodArgument = <String>[];
          _writeArgumentUnpacking(
            indent,
            parameters: method.parameters,
            methodArgument: methodArgument,
          );

          final call = 'api.${method.name}(${methodArgument.join(', ')})';

          _writeApiInvocation(
            indent,
            isAsynchronous: method.isAsynchronous,
            call: call,
            method: method,
            returnType: returnType,
            methodArgument: methodArgument,
          );
        },
      );
    });
  }

  void _writeChannelAllocation(
    Indent indent, {
    required String varChannelName,
    required String channelName,
    required String? serialBackgroundQueue,
  }) {
    indent.writeln('BasicMessageChannel<Object> $varChannelName =');
    indent.nest(2, () {
      indent.writeln('new BasicMessageChannel<>(');
      indent.nest(2, () {
        indent.write(
          'binaryMessenger, "$channelName" + messageChannelSuffix, getCodec()',
        );
        if (serialBackgroundQueue != null) {
          indent.addln(', $serialBackgroundQueue);');
        } else {
          indent.addln(');');
        }
      });
    });
  }

  void _writeMessageHandlerRegistration(
    Indent indent, {
    required String varChannelName,
    required String setHandlerCondition,
    required String messageVarName,
    required void Function() body,
  }) {
    indent.write('if ($setHandlerCondition) ');
    indent.addScoped('{', '} else {', () {
      indent.writeln('$varChannelName.setMessageHandler(');
      indent.nest(2, () {
        indent.write('($messageVarName, reply) -> ');
        indent.addScoped('{', '});', () {
          body();
        });
      });
    });
    indent.addScoped(null, '}', () {
      indent.writeln('$varChannelName.setMessageHandler(null);');
    });
  }

  void _writeArgumentUnpacking(
    Indent indent, {
    required List<Parameter> parameters,
    required List<String> methodArgument,
  }) {
    if (parameters.isNotEmpty) {
      indent.writeln('ArrayList<Object> args = (ArrayList<Object>) message;');
      enumerate(parameters, (int index, NamedType arg) {
        final String argType = _javaTypeForDartType(arg.type);
        final String argName = _getSafeArgumentName(index, arg);
        final argExpression = argName;
        var accessor = 'args.get($index)';
        if (argType != 'Object') {
          accessor = _cast(accessor, javaType: argType);
        }
        indent.writeln('$argType $argName = $accessor;');
        methodArgument.add(argExpression);
      });
    }
  }

  void _writeApiInvocation(
    Indent indent, {
    required bool isAsynchronous,
    required String call,
    required Method method,
    required String returnType,
    required List<String> methodArgument,
  }) {
    if (isAsynchronous) {
      final resultValue = method.returnType.isVoid ? 'null' : 'result';
      final String resultType = _getResultType(method.returnType);
      final resultParam = method.returnType.isVoid ? '' : '$returnType result';
      final addResultArg = method.returnType.isVoid ? 'null' : resultValue;
      const resultName = 'resultCallback';

      indent.writeln('$resultType $resultName =');
      indent.nest(2, () {
        indent.writeln('new $resultType() {');
        indent.nest(2, () {
          indent.writeln('public void success($resultParam) {');
          indent.nest(2, () {
            _writeReplying(
              indent,
              response: _writeResultWrapping(
                indent,
                resultName: addResultArg,
                errorName: null,
              ),
            );
          });
          indent.writeln('}');
          indent.newln();
          indent.writeln('public void error(Throwable error) {');
          indent.nest(2, () {
            _writeReplying(
              indent,
              response: _writeResultWrapping(
                indent,
                resultName: null,
                errorName: 'error',
              ),
            );
          });
          indent.writeln('}');
        });
        indent.writeln('};');
      });

      methodArgument.add(resultName);
      indent.writeln('api.${method.name}(${methodArgument.join(', ')});');
    } else {
      indent.write('try ');
      indent.addScoped('{', '}', () {
        if (method.returnType.isVoid) {
          indent.writeln('$call;');
          _writeReplying(
            indent,
            response: _writeResultWrapping(
              indent,
              resultName: null,
              errorName: null,
            ),
          );
        } else {
          indent.writeln('$returnType output = $call;');
          _writeReplying(
            indent,
            response: _writeResultWrapping(
              indent,
              resultName: 'output',
              errorName: null,
            ),
          );
        }
      });
      indent.add(' catch (Throwable exception) ');
      indent.addScoped('{', '}', () {
        _writeReplying(
          indent,
          response: _writeResultWrapping(
            indent,
            resultName: null,
            errorName: 'exception',
          ),
        );
      });
    }
  }

  String _writeResultWrapping(
    Indent indent, {
    required String? resultName,
    required String? errorName,
  }) {
    return 'wrapResponse(${resultName ?? 'null'}, ${errorName ?? 'null'})';
  }

  void _writeReplying(Indent indent, {required String response}) {
    indent.writeln('reply.reply($response);');
  }

  void _writeResultInterfaces(Indent indent) {
    indent.writeln(
      '/** Asynchronous error handling return type for non-nullable API method returns. */',
    );
    indent.write('public interface Result<T> ');
    indent.addScoped('{', '}', () {
      indent.writeln(
        '/** Success case callback method for handling returns. */',
      );
      indent.writeln('void success(@NonNull T result);');
      indent.newln();
      indent.writeln(
        '/** Failure case callback method for handling errors. */',
      );
      indent.writeln('void error(@NonNull Throwable error);');
    });

    indent.writeln(
      '/** Asynchronous error handling return type for nullable API method returns. */',
    );
    indent.write('public interface NullableResult<T> ');
    indent.addScoped('{', '}', () {
      indent.writeln(
        '/** Success case callback method for handling returns. */',
      );
      indent.writeln('void success(@Nullable T result);');
      indent.newln();
      indent.writeln(
        '/** Failure case callback method for handling errors. */',
      );
      indent.writeln('void error(@NonNull Throwable error);');
    });

    indent.writeln(
      '/** Asynchronous error handling return type for void API method returns. */',
    );
    indent.write('public interface VoidResult ');
    indent.addScoped('{', '}', () {
      indent.writeln(
        '/** Success case callback method for handling returns. */',
      );
      indent.writeln('void success();');
      indent.newln();
      indent.writeln(
        '/** Failure case callback method for handling errors. */',
      );
      indent.writeln('void error(@NonNull Throwable error);');
    });
  }

  @override
  void writeWrapResponse(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.format('''
@NonNull
protected static ArrayList<Object> wrapResponse(@Nullable Object result, @Nullable Throwable error) {
\tArrayList<Object> response = new ArrayList<>();
\tif (error != null) {
\t\tif (error instanceof FlutterError) {
\t\t\tFlutterError flutterError = (FlutterError) error;
\t\t\tresponse.add(flutterError.code);
\t\t\tresponse.add(flutterError.getMessage());
\t\t\tresponse.add(flutterError.details);
\t\t} else {
\t\t\tresponse.add(error.toString());
\t\t\tresponse.add(error.getClass().getSimpleName());
\t\t\tresponse.add(
\t\t\t\t"Cause: " + error.getCause() + ", Stacktrace: " + Log.getStackTraceString(error));
\t\t}
\t} else {
\t\tresponse.add(result);
\t}
\treturn response;
}''');
  }

  void _writeCreateConnectionError(Indent indent) {
    indent.writeln('@NonNull');
    indent.writeScoped(
      'protected static FlutterError createConnectionError(@NonNull String channelName) {',
      '}',
      () {
        indent.writeln(
          'return new FlutterError("channel-error",  "Unable to establish connection on channel: " + channelName + ".", "");',
        );
      },
    );
  }

  // We are emitting our own definition of [@CanIgnoreReturnValue] to support
  // clients who use CheckReturnValue, without having to force Pigeon clients
  // to take a new dependency on error_prone_annotations.
  void _writeCanIgnoreReturnValueAnnotation(
    InternalJavaOptions opt,
    Root root,
    Indent indent,
  ) {
    indent.newln();
    indent.writeln('@Target(METHOD)');
    indent.writeln('@Retention(CLASS)');
    indent.writeln('@interface CanIgnoreReturnValue {}');
  }

  @override
  void writeGeneralUtilities(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.containsHostApi) {
      indent.newln();
      writeWrapResponse(
        generatorOptions,
        root,
        indent,
        dartPackageName: dartPackageName,
      );
    }
    if (root.containsFlutterApi) {
      indent.newln();
      _writeCreateConnectionError(indent);
    }
    if (root.classes.isNotEmpty) {
      _writeCanIgnoreReturnValueAnnotation(generatorOptions, root, indent);
    }
  }

  @override
  void writeErrorClass(
    InternalJavaOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln(
      '/** Error class for passing custom error details to Flutter via a thrown PlatformException. */',
    );
    indent.write('public static class FlutterError extends RuntimeException ');
    indent.addScoped('{', '}', () {
      indent.newln();
      indent.writeln('/** The error code. */');
      indent.writeln('public final String code;');
      indent.newln();
      indent.writeln(
        '/** The error details. Must be a datatype supported by the api codec. */',
      );
      indent.writeln('public final Object details;');
      indent.newln();
      indent.writeln(
        'public FlutterError(@NonNull String code, @Nullable String message, @Nullable Object details) ',
      );
      indent.writeScoped('{', '}', () {
        indent.writeln('super(message);');
        indent.writeln('this.code = code;');
        indent.writeln('this.details = details;');
      });
    });
  }

  @override
  void writeCloseNamespace(
    InternalJavaOptions generatorOptions,
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
String _intToEnum(String expression, String enumName, bool nullable) {
  final toEnum = '$enumName.values()[((Long) $expression).intValue()]';
  return nullable ? '$expression == null ? null : $toEnum' : toEnum;
}

/// Returns the method signature for [method].
String _getMethodSignature(Method method, {required bool isHostApi}) {
  final String resultType = _getResultType(method.returnType);
  final String nullableType =
      method.isAsynchronous || !isHostApi || method.returnType.isVoid
      ? ''
      : _nullabilityAnnotationFromType(method.returnType);
  final String returnType = method.isAsynchronous || !isHostApi
      ? 'void'
      : _javaTypeForDartType(method.returnType);

  final argSignature = <String>[];
  if (method.parameters.isNotEmpty) {
    final Iterable<String> argTypes = method.parameters.map(
      (NamedType e) => _nullsafeJavaTypeForDartType(e.type),
    );
    final Iterable<String> argNames = indexMap(
      method.parameters,
      (int index, Parameter e) => isHostApi
          ? _getArgumentName(index, e)
          : _getSafeArgumentName(index, e),
    );
    argSignature.addAll(
      map2(argTypes, argNames, (String argType, String argName) {
        return '$argType $argName';
      }),
    );
  }

  if (method.isAsynchronous || !isHostApi) {
    argSignature.add('@NonNull $resultType result');
  }

  final nullablePrefix = nullableType.isNotEmpty ? '$nullableType ' : '';
  return '$nullablePrefix$returnType ${method.name}(${argSignature.join(', ')})';
}

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

String? _javaTypeForBuiltinDartType(TypeDeclaration type) {
  const javaTypeForDartTypeMap = <String, String>{
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
    field,
    (TypeDeclaration x) => _javaTypeForBuiltinDartType(x),
  );
  return _cast(varName, javaType: hostDatatype.datatype);
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
