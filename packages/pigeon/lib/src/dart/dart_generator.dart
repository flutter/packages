// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:code_builder/code_builder.dart' as cb;
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import '../ast.dart';
import '../functional.dart';
import '../generator.dart';
import '../generator_tools.dart';
import 'proxy_api_generator_helper.dart' as proxy_api_helper;
import 'templates.dart';

/// Documentation comment open symbol.
const String _docCommentPrefix = '///';

/// Name of the variable that contains the message channel suffix for APIs.
const String _suffixVarName = '${varNamePrefix}messageChannelSuffix';

/// Name of the `InstanceManager` variable for the Dart proxy class of a ProxyAPI.
const String instanceManagerVarName = '${classMemberNamePrefix}instanceManager';

/// Name of field used for host API codec.
const String pigeonChannelCodec = 'pigeonChannelCodec';

/// Documentation comment spec.
const DocumentCommentSpecification docCommentSpec =
    DocumentCommentSpecification(_docCommentPrefix);

/// The custom codec used for all pigeon APIs.
const String _pigeonMessageCodec = '_PigeonCodec';

/// Name of field used for host API codec.
const String _pigeonMethodChannelCodec = 'pigeonMethodCodec';

const String _overflowClassName = '_PigeonCodecOverflow';

/// Name of the overrides class for overriding constructors and static members
/// of Dart proxy classes.
const String proxyApiOverridesClassName = '${proxyApiClassNamePrefix}Overrides';

/// Options that control how Dart code will be generated.
class DartOptions {
  /// Constructor for DartOptions.
  const DartOptions({
    this.copyrightHeader,
    this.sourceOutPath,
    this.testOutPath,
    this.dartOut,
  });

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Path to output generated Dart file.
  final String? sourceOutPath;

  /// Path to output generated Test file for tests.
  final String? testOutPath;

  /// Path to output generated Dart file.
  final String? dartOut;

  /// Creates a [DartOptions] from a Map representation where:
  /// `x = DartOptions.fromMap(x.toMap())`.
  static DartOptions fromMap(Map<String, Object> map) {
    final Iterable<dynamic>? copyrightHeader =
        map['copyrightHeader'] as Iterable<dynamic>?;
    return DartOptions(
      copyrightHeader: copyrightHeader?.cast<String>(),
      sourceOutPath: map['sourceOutPath'] as String?,
      testOutPath: map['testOutPath'] as String?,
      dartOut: map['dartOut'] as String?,
    );
  }

  /// Converts a [DartOptions] to a Map representation where:
  /// `x = DartOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (sourceOutPath != null) 'sourceOutPath': sourceOutPath!,
      if (testOutPath != null) 'testOutPath': testOutPath!,
      if (dartOut != null) 'dartOut': dartOut!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [DartOptions].
  DartOptions merge(DartOptions options) {
    return DartOptions.fromMap(mergePigeonMaps(toMap(), options.toMap()));
  }
}

class _JniType {
  _JniType({required this.type, this.subTypeOne, this.subTypeTwo});

  final TypeDeclaration type;
  final _JniType? subTypeOne;
  final _JniType? subTypeTwo;

  static _JniType fromTypeDeclaration(TypeDeclaration? type) {
    if (type == null) {
      return _JniType(
        type: const TypeDeclaration(
          baseName: 'type was null',
          isNullable: false,
        ),
      );
    }
    if (type.baseName == 'List') {
      final _JniType? subType =
          type.typeArguments.firstOrNull != null
              ? _JniType.fromTypeDeclaration(type.typeArguments.firstOrNull)
              : null;
      final _JniType jniType = _JniType(type: type, subTypeOne: subType);
      return jniType;
    } else if (type.baseName == 'Map') {
      final _JniType? subTypeOne =
          type.typeArguments.firstOrNull != null
              ? _JniType.fromTypeDeclaration(type.typeArguments.firstOrNull)
              : null;
      final _JniType? subTypeTwo =
          type.typeArguments.lastOrNull != null
              ? _JniType.fromTypeDeclaration(type.typeArguments.lastOrNull)
              : null;
      final _JniType jniType = _JniType(
        type: type,
        subTypeOne: subTypeOne,
        subTypeTwo: subTypeTwo,
      );
      return jniType;
    }

    return _JniType(type: type);
  }

  static _JniType fromClass(Class classDefinition) {
    final TypeDeclaration fakeType = TypeDeclaration(
      baseName: classDefinition.name,
      isNullable: true,
      associatedClass: classDefinition,
    );
    return _JniType(type: fakeType);
  }

  static _JniType fromEnum(Enum enumDefinition) {
    final TypeDeclaration fakeType = TypeDeclaration(
      baseName: enumDefinition.name,
      isNullable: true,
      associatedEnum: enumDefinition,
    );
    return _JniType(type: fakeType);
  }

  String get jniName {
    switch (type.baseName) {
      case 'String':
        return 'JString';
      case 'void':
        return 'JVoid';
      case 'bool':
        return 'JBoolean';
      case 'int':
        return 'JLong';
      case 'double':
        return 'JDouble';
      case 'Uint8List':
        return 'JByteArray';
      case 'Int32List':
        return 'JIntArray';
      case 'Int64List':
        return 'JLongArray';
      case 'Float64List':
        return 'JDoubleArray';
      case 'Object':
        return 'JObject';
      case 'List':
        return 'JList';
      case 'Map':
        return 'JMap';
      default:
        {
          if (type.isClass || type.isEnum) {
            return 'jni_bridge.${type.baseName}';
          }
          return 'There is something wrong, a type is not classified';
        }
    }
  }

  String get jniTypeGetter {
    return type.isNullable ? 'nullableType' : 'type';
  }

  String get fullJniName {
    if (type.baseName == 'List' || type.baseName == 'Map') {
      return jniName + jniCollectionTypeAnnotations;
    }
    return jniName;
  }

  String get fullJniType {
    if (type.baseName == 'List' || type.baseName == 'Map') {
      return '$jniName.$jniTypeGetter($getJniCollectionTypeTypes)';
    }
    return '$jniName.$jniTypeGetter';
  }

  String get getJniCollectionTypeTypes {
    if (type.baseName == 'List') {
      return subTypeOne?.fullJniType ?? 'JObject.nullableType';
    }
    if (type.baseName == 'Map') {
      return '${subTypeOne?.fullJniType ?? 'JObject.type'}, ${subTypeTwo?.fullJniType ?? 'JObject.nullableType'}';
    }

    return '$jniName.$jniTypeGetter';
  }

  bool get nonNullableNeedsUnwrapping {
    if (type.isClass ||
        type.isEnum ||
        type.baseName == 'String' ||
        type.baseName == 'Object' ||
        type.baseName == 'List' ||
        type.baseName == 'Map' ||
        type.baseName == 'Uint8List' ||
        type.baseName == 'Int32List' ||
        type.baseName == 'Int64List' ||
        type.baseName == 'Float64List') {
      return true;
    }
    return false;
  }

  String getJniGetterMethodName(String field) {
    return 'get${toUpperCamelCase(field)}()';
  }

  String get primitiveToDartMethodName {
    switch (type.baseName) {
      case 'String':
        return 'toDartString';
      case 'int':
        return 'longValue';
      case 'double':
        return 'doubleValue';
      case 'bool':
        return 'booleanValue';
      default:
        return '';
    }
  }

  String getToDartCall(
    TypeDeclaration type, {
    String varName = '',
    bool forceConversion = false,
  }) {
    if (type.isClass || type.isEnum) {
      return '${type.baseName}.fromJni($varName)${_getForceNonNullSymbol(!type.isNullable)}';
    }
    String asType = ' as ${getDartReturnType(true)}';
    String castCall = '';
    final String codecCall =
        '_PigeonJniCodec.readValue($varName)${_getForceNonNullSymbol(!type.isNullable)}';
    String primitiveGetter(String converter, bool unwrap) {
      return unwrap
          ? '$varName${_getNullableSymbol(type.isNullable)}.$converter${'(releaseOriginal: true)'}'
          : varName;
    }

    switch (type.baseName) {
      case 'String':
      case 'int':
      case 'double':
      case 'bool':
        return primitiveGetter(
          primitiveToDartMethodName,
          type.baseName == 'String' || type.isNullable || forceConversion,
        );
      case 'Object':
        asType = '';
      case 'List':
        asType = ' as List<Object?>${_getNullableSymbol(type.isNullable)}';
        castCall =
            '${_getNullableSymbol(type.isNullable)}.cast$dartCollectionTypeAnnotations()';
      case 'Map':
        asType =
            ' as Map<Object?, Object?>${_getNullableSymbol(type.isNullable)}';
        castCall =
            '${_getNullableSymbol(type.isNullable)}.cast$dartCollectionTypeAnnotations()';
    }
    return '${wrapConditionally('$codecCall$asType', '(', ')', type.baseName != 'Object')}$castCall';
  }

  String getToJniCall(
    TypeDeclaration type,
    String name,
    _JniType jniType, {
    bool forceNonNull = false,
  }) {
    if (type.isClass || type.isEnum) {
      return _wrapInNullCheckIfNullable(
        nullable: type.isNullable,
        varName: name,
        code:
            '$name${_getForceNonNullSymbol(type.isNullable && forceNonNull)}.toJni()',
      );
    } else if (!type.isNullable &&
        (type.baseName == 'int' ||
            type.baseName == 'double' ||
            type.baseName == 'bool')) {
      return name;
    }
    return '_PigeonJniCodec.writeValue<${getJniCallReturnType(true)}>($name)';
  }

  String getJniCallReturnType(bool forceUnwrap) {
    if (forceUnwrap || type.isNullable || nonNullableNeedsUnwrapping) {
      return '$jniName$jniCollectionTypeAnnotations${_getNullableSymbol(type.isNullable)}';
    }
    return type.baseName;
  }

  String getDartReturnType(bool forceUnwrap) {
    if (forceUnwrap || type.isNullable || nonNullableNeedsUnwrapping) {
      return '${type.baseName}$dartCollectionTypeAnnotations${_getNullableSymbol(type.isNullable)}';
    }
    return type.baseName;
  }

  String get dartCollectionTypeAnnotations {
    if (type.baseName == 'List') {
      return '<$dartCollectionTypes>';
    } else if (type.baseName == 'Map') {
      return '<$dartCollectionTypes>';
    }
    return '';
  }

  String get jniCollectionTypeAnnotations {
    if (type.baseName == 'List') {
      return '<$jniCollectionTypes>';
    } else if (type.baseName == 'Map') {
      return '<$jniCollectionTypes>';
    }
    return '';
  }

  String get dartCollectionTypes {
    if (type.baseName == 'List') {
      return subTypeOne?.getDartReturnType(true) ?? 'Object?';
    } else if (type.baseName == 'Map') {
      return '${subTypeOne?.getDartReturnType(true) ?? 'Object?'}, ${subTypeTwo?.getDartReturnType(true) ?? 'Object?'}';
    }
    return '';
  }

  String get jniCollectionTypes {
    if (type.baseName == 'List') {
      return subTypeOne?.getJniCallReturnType(true) ?? 'JObject?';
    } else if (type.baseName == 'Map') {
      return '${subTypeOne?.getJniCallReturnType(true) ?? 'JObject'}, ${subTypeTwo?.getJniCallReturnType(true) ?? 'JObject?'}';
    }
    return '';
  }
}

String _jniArgumentsToDartArguments(
  List<Parameter> parameters, {
  bool isAsynchronous = false,
}) {
  final List<String> argumentSignature = <String>[];
  for (final Parameter parameter in parameters) {
    final _JniType jniType = _JniType.fromTypeDeclaration(parameter.type);
    argumentSignature.add(
      jniType.getToDartCall(
        parameter.type,
        varName: parameter.name,
        forceConversion: isAsynchronous,
      ),
    );
  }
  return argumentSignature.join(', ');
}

String _getNullableSymbol(bool nullable) => nullable ? '?' : '';

String _getForceNonNullSymbol(bool force) => force ? '!' : '';

String _wrapInNullCheckIfNullable({
  required bool nullable,
  required String varName,
  required String code,
  String ifNull = 'null',
}) => nullable ? '$varName == null ? $ifNull : $code' : code;

/// Options that control how Dart code will be generated.
class InternalDartOptions extends InternalOptions {
  /// Constructor for InternalDartOptions.
  const InternalDartOptions({
    this.copyrightHeader,
    this.dartOut,
    this.testOut,
    this.useJni = false,
  });

  /// Creates InternalDartOptions from DartOptions.
  InternalDartOptions.fromDartOptions(
    DartOptions options, {
    Iterable<String>? copyrightHeader,
    String? dartOut,
    String? testOut,
    required this.useJni,
  }) : copyrightHeader = copyrightHeader ?? options.copyrightHeader,
       dartOut = (dartOut ?? options.sourceOutPath)!,
       testOut = testOut ?? options.testOutPath;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Path to output generated Dart file.
  final String? dartOut;

  /// Path to output generated Test file for tests.
  final String? testOut;

  /// Whether to use Jni for generating kotlin interop code.
  final bool useJni;
}

/// Class that manages all Dart code generation.
class DartGenerator extends StructuredGenerator<InternalDartOptions> {
  /// Instantiates a Dart Generator.
  const DartGenerator();

  // Formatter used to format code from `code_builder`.
  DartFormatter get _formatter {
    return DartFormatter(languageVersion: Version(3, 6, 0));
  }

  @override
  void writeFilePrologue(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln(
      '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import, no_leading_underscores_for_local_identifiers',
    );
    indent.newln();
  }

  @override
  void writeFileImports(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln("import 'dart:async';");
    if (generatorOptions.useJni || root.containsProxyApi) {
      indent.writeln("import 'dart:io' show Platform;");
    }
    indent.writeln(
      "import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;",
    );
    indent.newln();

    indent.writeln(
      "import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer${root.containsProxyApi ? ', immutable, protected, visibleForTesting' : ''};",
    );
    indent.writeln("import 'package:flutter/services.dart';");
    if (root.containsProxyApi) {
      indent.writeln(
        "import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;",
      );
    }
    if (generatorOptions.useJni) {
      indent.writeln("import 'package:jni/jni.dart';");
    }
    if (generatorOptions.useJni) {
      final String jniFileImportName = path.basename(generatorOptions.dartOut!);
      indent.writeln(
        "import './${path.withoutExtension(jniFileImportName)}.jni.dart' as jni_bridge;",
      );
    }
  }

  @override
  void writeEnum(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
      indent,
      anEnum.documentationComments,
      docCommentSpec,
    );
    indent.addScoped('enum ${anEnum.name} {', '}', () {
      for (final EnumMember member in anEnum.members) {
        final String separatorSymbol =
            member == anEnum.members.last ? ';' : ',';
        addDocumentationComments(
          indent,
          member.documentationComments,
          docCommentSpec,
        );
        indent.writeln('${member.name}$separatorSymbol');
      }

      if (generatorOptions.useJni) {
        final _JniType jniType = _JniType.fromEnum(anEnum);
        indent.newln();
        indent.writeScoped('${jniType.jniName} toJni() {', '}', () {
          indent.writeln('return ${jniType.jniName}.Companion.ofRaw(index)!;');
        });

        indent.newln();
        indent.writeScoped(
          'static ${anEnum.name}? fromJni(${jniType.jniName}? jniEnum) {',
          '}',
          () {
            indent.writeln(
              'return jniEnum == null ? null : ${anEnum.name}.values[jniEnum.getRaw()];',
            );
          },
        );
      }
    });
  }

  @override
  void writeDataClass(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
      indent,
      classDefinition.documentationComments,
      docCommentSpec,
    );
    final String sealed = classDefinition.isSealed ? 'sealed ' : '';
    final String implements =
        classDefinition.superClassName != null
            ? 'extends ${classDefinition.superClassName} '
            : '';

    indent.write('${sealed}class ${classDefinition.name} $implements');
    indent.addScoped('{', '}', () {
      if (classDefinition.fields.isEmpty) {
        return;
      }
      _writeConstructor(indent, classDefinition);
      indent.newln();
      for (final NamedType field in getFieldsInSerializationOrder(
        classDefinition,
      )) {
        addDocumentationComments(
          indent,
          field.documentationComments,
          docCommentSpec,
        );

        final String datatype = addGenericTypesNullable(field.type);
        indent.writeln('$datatype ${field.name};');
        indent.newln();
      }
      _writeToList(indent, classDefinition);
      indent.newln();
      writeClassEncode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
      indent.newln();
      writeClassDecode(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
      indent.newln();
      writeClassEquality(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
    });
  }

  void _writeConstructor(Indent indent, Class classDefinition) {
    indent.write(classDefinition.name);
    indent.addScoped('({', '});', () {
      for (final NamedType field in getFieldsInSerializationOrder(
        classDefinition,
      )) {
        final String required =
            !field.type.isNullable && field.defaultValue == null
                ? 'required '
                : '';
        final String defaultValueString =
            field.defaultValue == null ? '' : ' = ${field.defaultValue}';
        indent.writeln('${required}this.${field.name}$defaultValueString,');
      }
    });
  }

  @override
  void writeClassEncode(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    if (generatorOptions.useJni) {
      _writeToJni(indent, classDefinition);
      indent.newln();
    }
    indent.write('Object encode() ');
    indent.addScoped('{', '}', () {
      indent.write('return _toList();');
    });
  }

  void _writeToList(Indent indent, Class classDefinition) {
    indent.writeScoped('List<Object?> _toList() {', '}', () {
      indent.writeScoped('return <Object?>[', '];', () {
        for (final NamedType field in getFieldsInSerializationOrder(
          classDefinition,
        )) {
          indent.writeln('${field.name},');
        }
      });
    });
  }

  void _writeToJni(Indent indent, Class classDefinition) {
    indent.writeScoped('jni_bridge.${classDefinition.name} toJni() {', '}', () {
      indent.writeScoped('return jni_bridge.${classDefinition.name} (', ');', () {
        for (final NamedType field in getFieldsInSerializationOrder(
          classDefinition,
        )) {
          final _JniType jniType = _JniType.fromTypeDeclaration(field.type);
          indent.writeln(
            '${jniType.getToJniCall(field.type, field.name, jniType, forceNonNull: true)},',
          );
        }
      });
    });
  }

  void _writeFromJni(Indent indent, Class classDefinition) {
    final _JniType jniClass = _JniType.fromClass(classDefinition);
    indent.writeScoped(
      'static ${jniClass.type.baseName}? fromJni(${jniClass.jniName}? jniClass) {',
      '}',
      () {
        indent.writeScoped(
          'return jniClass == null ? null : ${jniClass.type.baseName}(',
          ');',
          () {
            for (final NamedType field in getFieldsInSerializationOrder(
              classDefinition,
            )) {
              final _JniType jniType = _JniType.fromTypeDeclaration(field.type);
              indent.writeln(
                '${field.name}: ${jniType.getToDartCall(field.type, varName: 'jniClass.${jniType.getJniGetterMethodName(field.name)}')},',
              );
            }
          },
        );
      },
    );
  }

  @override
  void writeClassDecode(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    if (generatorOptions.useJni) {
      _writeFromJni(indent, classDefinition);
      indent.newln();
    }
    void writeValueDecode(NamedType field, int index) {
      final String resultAt = 'result[$index]';
      final String castCallPrefix = field.type.isNullable ? '?' : '!';
      final String genericType = _makeGenericTypeArguments(field.type);
      final String castCall = _makeGenericCastCall(field.type);
      if (field.type.typeArguments.isNotEmpty) {
        indent.add('($resultAt as $genericType?)$castCallPrefix$castCall');
      } else {
        final String castCallForcePrefix = field.type.isNullable ? '' : '!';
        final String castString =
            field.type.baseName == 'Object'
                ? ''
                : ' as $genericType${_getNullableSymbol(field.type.isNullable)}';

        indent.add('$resultAt$castCallForcePrefix$castString');
      }
    }

    indent.writeScoped(
      'static ${classDefinition.name} decode(Object result) {',
      '}',
      () {
        indent.writeln('result as List<Object?>;');
        indent.write('return ${classDefinition.name}');
        indent.addScoped('(', ');', () {
          enumerate(getFieldsInSerializationOrder(classDefinition), (
            int index,
            final NamedType field,
          ) {
            indent.write('${field.name}: ');
            writeValueDecode(field, index);
            indent.addln(',');
          });
        });
      },
    );
  }

  @override
  void writeClassEquality(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.writeln('@override');
    indent.writeln('// ignore: avoid_equals_and_hash_code_on_mutable_classes');
    indent.writeScoped('bool operator ==(Object other) {', '}', () {
      indent.writeScoped(
        'if (other is! ${classDefinition.name} || other.runtimeType != runtimeType) {',
        '}',
        () {
          indent.writeln('return false;');
        },
      );
      indent.writeScoped('if (identical(this, other)) {', '}', () {
        indent.writeln('return true;');
      });
      indent.writeln('return _deepEquals(encode(), other.encode());');
    });
    indent.newln();
    indent.writeln('@override');
    indent.writeln('// ignore: avoid_equals_and_hash_code_on_mutable_classes');
    indent.writeln('int get hashCode => Object.hashAll(_toList())');
    indent.addln(';');
  }

  @override
  void writeGeneralCodec(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    void writeEncodeLogic(
      EnumeratedType customType,
      int nonSerializedClassCount,
    ) {
      indent.writeScoped('else if (value is ${customType.name}) {', '}', () {
        if (customType.offset(nonSerializedClassCount) < maximumCodecFieldKey) {
          indent.writeln(
            'buffer.putUint8(${customType.offset(nonSerializedClassCount)});',
          );
          if (customType.type == CustomTypes.customClass) {
            indent.writeln('writeValue(buffer, value.encode());');
          } else if (customType.type == CustomTypes.customEnum) {
            indent.writeln('writeValue(buffer, value.index);');
          }
        } else {
          final String encodeString =
              customType.type == CustomTypes.customClass
                  ? '.encode()'
                  : '.index';
          indent.writeln(
            'final $_overflowClassName wrap = $_overflowClassName(type: ${customType.offset(nonSerializedClassCount) - maximumCodecFieldKey}, wrapped: value$encodeString);',
          );
          indent.writeln('buffer.putUint8($maximumCodecFieldKey);');
          indent.writeln('writeValue(buffer, wrap.encode());');
        }
      }, addTrailingNewline: false);
    }

    void writeDecodeLogic(
      EnumeratedType customType,
      int nonSerializedClassCount,
    ) {
      indent.writeln('case ${customType.offset(nonSerializedClassCount)}: ');
      indent.nest(1, () {
        if (customType.type == CustomTypes.customClass) {
          if (customType.offset(nonSerializedClassCount) ==
              maximumCodecFieldKey) {
            indent.writeln(
              'final ${customType.name} wrapper = ${customType.name}.decode(readValue(buffer)!);',
            );
            indent.writeln('return wrapper.unwrap();');
          } else {
            indent.writeln(
              'return ${customType.name}.decode(readValue(buffer)!);',
            );
          }
        } else if (customType.type == CustomTypes.customEnum) {
          indent.writeln('final int? value = readValue(buffer) as int?;');
          indent.writeln(
            'return value == null ? null : ${customType.name}.values[value];',
          );
        }
      });
    }

    final EnumeratedType overflowClass = EnumeratedType(
      _overflowClassName,
      maximumCodecFieldKey,
      CustomTypes.customClass,
    );

    indent.newln();
    final List<EnumeratedType> enumeratedTypes =
        getEnumeratedTypes(root, excludeSealedClasses: true).toList();
    if (root.requiresOverflowClass) {
      _writeCodecOverflowUtilities(indent, enumeratedTypes);
    }
    indent.newln();
    indent.write('class $_pigeonMessageCodec extends StandardMessageCodec');
    indent.addScoped(' {', '}', () {
      indent.writeln('const $_pigeonMessageCodec();');
      indent.writeln('@override');
      indent.write('void writeValue(WriteBuffer buffer, Object? value) ');
      indent.addScoped('{', '}', () {
        indent.writeScoped('if (value is int) {', '}', () {
          indent.writeln('buffer.putUint8(4);');
          indent.writeln('buffer.putInt64(value);');
        }, addTrailingNewline: false);
        int nonSerializedClassCount = 0;
        enumerate(enumeratedTypes, (
          int index,
          final EnumeratedType customType,
        ) {
          if (customType.associatedClass?.isSealed ?? false) {
            nonSerializedClassCount += 1;
            return;
          }
          writeEncodeLogic(customType, nonSerializedClassCount);
        });
        indent.addScoped(' else {', '}', () {
          indent.writeln('super.writeValue(buffer, value);');
        });
      });
      indent.newln();
      indent.writeln('@override');
      indent.write('Object? readValueOfType(int type, ReadBuffer buffer) ');
      indent.addScoped('{', '}', () {
        indent.write('switch (type) ');
        indent.addScoped('{', '}', () {
          int nonSerializedClassCount = 0;
          for (final EnumeratedType customType in enumeratedTypes) {
            if (customType.associatedClass?.isSealed ?? false) {
              nonSerializedClassCount++;
            } else if (customType.offset(nonSerializedClassCount) <
                maximumCodecFieldKey) {
              writeDecodeLogic(customType, nonSerializedClassCount);
            }
          }
          if (root.requiresOverflowClass) {
            writeDecodeLogic(overflowClass, 0);
          }
          indent.writeln('default:');
          indent.nest(1, () {
            indent.writeln('return super.readValueOfType(type, buffer);');
          });
        });
      });
    });
    if (root.containsEventChannel) {
      indent.newln();
      indent.writeln(
        'const StandardMethodCodec $_pigeonMethodChannelCodec = StandardMethodCodec($_pigeonMessageCodec());',
      );
    }
  }

  void _writeJniFlutterApi(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    indent.writeScoped(
      'final class ${api.name}Registrar with jni_bridge.\$${api.name} {',
      '}',
      () {
        indent.writeln('${api.name}? dartApi;');
        indent.newln();
        indent.writeScoped('${api.name} register(', ') ', () {
          indent.writeScoped('${api.name} api, {', '}', () {
            indent.writeln('String name = defaultInstanceName,');
          }, nestCount: 0);
        }, addTrailingNewline: false);
        indent.addScoped('{', '}', () {
          indent.format('''
    dartApi = api;
    final jni_bridge.${api.name} impl =
        jni_bridge.${api.name}.implement(this);
    jni_bridge.${api.name}Registrar()
        .registerInstance(impl, JString.fromString(name));
    return api;
  ''');
        });

        for (final Method method in api.methods) {
          final _JniType jniReturnType = _JniType.fromTypeDeclaration(
            method.returnType,
          );
          indent.newln();
          indent.writeln('@override');
          String signature =
              method.isAsynchronous
                  ? 'JObject'
                  : jniReturnType.getJniCallReturnType(false);
          signature += ' ${method.name}(';
          signature += _getMethodParameterSignature(
            method.parameters,
            useJni: true,
          );
          signature +=
              method.isAsynchronous
                  ? '${method.parameters.isNotEmpty ? ', ' : ''}JObject continuation'
                  : '';
          signature += ')';
          indent.writeScoped('$signature {', '}', () {
            indent.writeScoped('if (dartApi != null) {', '} ', () {
              final String methodCall =
                  'dartApi!.${method.name}(${_jniArgumentsToDartArguments(method.parameters, isAsynchronous: method.isAsynchronous)})';
              if (method.returnType.isVoid) {
                if (method.isAsynchronous) {
                  indent.writeln('$methodCall;');
                  indent.writeln('return continuation;');
                } else {
                  indent.writeln('return $methodCall;');
                }
              } else {
                final _JniType returnType = _JniType.fromTypeDeclaration(
                  method.returnType,
                );
                indent.writeln(
                  'final ${jniReturnType.type.getFullName()} response = $methodCall;',
                );
                indent.writeln(
                  'return ${returnType.getToJniCall(method.returnType, 'response', returnType)};',
                );
              }
            });
            indent.writeScoped('else {', '}', () {
              indent.writeln(
                "throw ArgumentError('${api.name} was not registered.');",
              );
            });
          });
          if (method.isAsynchronous && method.returnType.isVoid) {}
        }
      },
    );
  }

  /// Writes the code for host [Api], [api].
  /// Example:
  /// class FooCodec extends StandardMessageCodec {...}
  ///
  /// abstract class Foo {
  ///   static const MessageCodec<Object?> codec = FooCodec();
  ///   int add(int x, int y);
  ///   static void setUp(Foo api, {BinaryMessenger? binaryMessenger}) {...}
  /// }
  @override
  void writeFlutterApi(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    String Function(Method)? channelNameFunc,
    bool isMockHandler = false,
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(indent, api.documentationComments, docCommentSpec);
    if (generatorOptions.useJni) {
      _writeJniFlutterApi(
        generatorOptions,
        root,
        indent,
        api,
        dartPackageName: dartPackageName,
      );
    }

    indent.write('abstract class ${api.name} ');
    indent.addScoped('{', '}', () {
      if (isMockHandler) {
        indent.writeln(
          'static TestDefaultBinaryMessengerBinding? get _testBinaryMessengerBinding => TestDefaultBinaryMessengerBinding.instance;',
        );
      }
      indent.writeln(
        'static const MessageCodec<Object?> $pigeonChannelCodec = $_pigeonMessageCodec();',
      );
      indent.newln();
      for (final Method func in api.methods) {
        addDocumentationComments(
          indent,
          func.documentationComments,
          docCommentSpec,
        );

        final bool isAsync = func.isAsynchronous;
        final String returnType =
            isAsync
                ? 'Future<${addGenericTypesNullable(func.returnType)}>'
                : addGenericTypesNullable(func.returnType);
        final String argSignature = _getMethodParameterSignature(
          func.parameters,
        );
        indent.writeln('$returnType ${func.name}($argSignature);');
        indent.newln();
      }
      indent.format('''
            static void setUp(${api.name}? api, {
              BinaryMessenger? binaryMessenger, 
              String messageChannelSuffix = '',
            }) ''');

      indent.addScoped('{', '}', () {
        if (generatorOptions.useJni) {
          indent.format('''
            if (Platform.isAndroid && api != null) {
              ${api.name}Registrar().register(api, name: messageChannelSuffix.isEmpty
                  ? defaultInstanceName
                  : messageChannelSuffix);
            }
            ''');
        }
        indent.writeln(
          r"messageChannelSuffix = messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';",
        );

        for (final Method func in api.methods) {
          writeFlutterMethodMessageHandler(
            indent,
            name: func.name,
            parameters: func.parameters,
            returnType: func.returnType,
            addSuffixVariable: true,
            channelName:
                channelNameFunc == null
                    ? makeChannelName(api, func, dartPackageName)
                    : channelNameFunc(func),
            isMockHandler: isMockHandler,
            isAsynchronous: func.isAsynchronous,
          );
        }
      });
    });
  }

  @override
  void writeApis(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.useJni) {
      indent.writeln(
        "const String defaultInstanceName = 'PigeonDefaultClassName32uh4ui3lh445uh4h3l2l455g4y34u';",
      );
    }
    super.writeApis(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
  }

  void _writeNativeInteropHostApi(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    final String dartApiName = '${api.name}ForNativeInterop';
    final String jniApiRegistrarName = 'jni_bridge.${api.name}Registrar';
    indent.newln();
    indent.writeScoped('class $dartApiName {', '}', () {
      indent.format('''
  $dartApiName._withRegistrar({$jniApiRegistrarName? jniApi}) : _jniApi = jniApi;

  /// Returns instance of $dartApiName with specified [channelName] if one has been registered.
  static $dartApiName? getInstance({String channelName = defaultInstanceName}) {
  late $dartApiName res;
    if (Platform.isAndroid) {
      final $jniApiRegistrarName? link =
          $jniApiRegistrarName().getInstance(JString.fromString(channelName));
      if (link == null) {
        _throwNoInstanceError(channelName);
      }
      res = $dartApiName._withRegistrar(jniApi: link);
    } 
    return res;
  }

  late final $jniApiRegistrarName? _jniApi;
''');
      for (final Method method in api.methods) {
        indent.writeScoped(
          '${method.isAsynchronous ? 'Future<' : ''}${addGenericTypesNullable(method.returnType)}${method.isAsynchronous ? '>' : ''} ${method.name}(${_getMethodParameterSignature(method.parameters)}) ${method.isAsynchronous ? 'async ' : ''}{',
          '}',
          () {
            indent.writeScoped('try {', '}', () {
              indent.writeScoped('if (_jniApi != null) {', '}', () {
                final _JniType returnType = _JniType.fromTypeDeclaration(
                  method.returnType,
                );
                final String methodCallReturnString =
                    returnType.type.baseName == 'void' && method.isAsynchronous
                        ? ''
                        : (!returnType.nonNullableNeedsUnwrapping &&
                            !method.returnType.isNullable &&
                            !method.isAsynchronous)
                        ? 'return '
                        : 'final ${returnType.getJniCallReturnType(method.isAsynchronous)} res = ';
                indent.writeln(
                  '$methodCallReturnString${method.isAsynchronous ? 'await ' : ''}_jniApi.${method.name}(${_getJniMethodCallArguments(method.parameters)});',
                );
                if ((method.returnType.isNullable ||
                        method.isAsynchronous ||
                        returnType.nonNullableNeedsUnwrapping) &&
                    returnType.type.baseName != 'void') {
                  indent.writeln(
                    'final ${returnType.getDartReturnType(method.isAsynchronous)} dartTypeRes = ${returnType.getToDartCall(method.returnType, varName: 'res', forceConversion: method.isAsynchronous)};',
                  );
                  indent.writeln('return dartTypeRes;');
                }
              }, addTrailingNewline: false);
            }, addTrailingNewline: false);
            indent.addScoped(' on JniException catch (e) {', '}', () {
              indent.writeln(
                "throw PlatformException(code: 'PlatformException', message: e.message, stacktrace: e.stackTrace,);",
              );
            }, addTrailingNewline: false);
            indent.addScoped(' catch (e) {', '}', () {
              indent.writeln('rethrow;');
            });
            indent.writeln('throw Exception("this shouldn\'t be possible");');
          },
        );
        indent.newln();
      }
    });
  }

  String _getJniMethodCallArguments(Iterable<Parameter> parameters) {
    return parameters
        .map((Parameter parameter) {
          final _JniType jniType = _JniType.fromTypeDeclaration(parameter.type);
          return jniType.getToJniCall(parameter.type, parameter.name, jniType);
        })
        .join(', ');
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
  ///
  /// Messages will be sent and received in a list.
  ///
  /// If the message received was successful,
  /// the result will be contained at the 0'th index.
  ///
  /// If the message was a failure, the list will contain 3 items:
  /// a code, a message, and details in that order.
  @override
  void writeHostApi(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    if (generatorOptions.useJni) {
      _writeNativeInteropHostApi(
        generatorOptions,
        root,
        indent,
        api,
        dartPackageName: dartPackageName,
      );
    }
    indent.newln();
    addDocumentationComments(indent, api.documentationComments, docCommentSpec);
    indent.write('class ${api.name} ');
    indent.addScoped('{', '}', () {
      indent.format('''
/// Constructor for [${api.name}]. The [binaryMessenger] named argument is
/// available for dependency injection. If it is left null, the default
/// BinaryMessenger will be used which routes to the host platform.
${api.name}({
    BinaryMessenger? binaryMessenger, 
    String messageChannelSuffix = '', 
    ${_usesNativeInterop(generatorOptions) ? '${api.name}ForNativeInterop? nativeInteropApi,\n' : ''}})
    : ${varNamePrefix}binaryMessenger = binaryMessenger,
      ${varNamePrefix}messageChannelSuffix = messageChannelSuffix.isNotEmpty ? '.\$messageChannelSuffix' : ''${_usesNativeInterop(generatorOptions) ? ',\n_nativeInteropApi = nativeInteropApi;\n' : ';'}
''');

      if (generatorOptions.useJni) {
        indent.format('''
  /// Creates an instance of [${api.name}] that requests an instance of
  /// [${api.name}ForNativeInterop] from the host platform with a matching instance name
  /// to [messageChannelSuffix] or the default instance.
  ///
  /// Throws [ArgumentError] if no matching instance can be found.
  factory ${api.name}.createWithNativeInteropApi({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    ${api.name}ForNativeInterop? nativeInteropApi;
    String nativeInteropApiInstanceName = '';
    if (Platform.isAndroid) {
      if (messageChannelSuffix.isEmpty) {
        nativeInteropApi = ${api.name}ForNativeInterop.getInstance();
      } else {
        nativeInteropApiInstanceName = messageChannelSuffix;
        nativeInteropApi = ${api.name}ForNativeInterop.getInstance(
            channelName: messageChannelSuffix);
      }
    }
    if (nativeInteropApi == null) {
      throw ArgumentError(
          'No ${api.name} instance with \${nativeInteropApiInstanceName.isEmpty ? 'no ' : ''} instance name \${nativeInteropApiInstanceName.isNotEmpty ? '"\$nativeInteropApiInstanceName"' : ''} "\$nativeInteropApiInstanceName "}found.');
    }
    return ${api.name}(
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
      nativeInteropApi: nativeInteropApi,
    );
  }
  ''');
      }

      indent.writeln('final BinaryMessenger? ${varNamePrefix}binaryMessenger;');
      indent.writeln(
        'static const MessageCodec<Object?> $pigeonChannelCodec = $_pigeonMessageCodec();',
      );
      indent.newln();
      indent.writeln('final String $_suffixVarName;');
      indent.newln();
      if (_usesNativeInterop(generatorOptions)) {
        indent.writeln('final ${api.name}ForNativeInterop? _nativeInteropApi;');
      }
      for (final Method func in api.methods) {
        indent.newln();

        _writeHostMethod(
          indent,
          name: func.name,
          parameters: func.parameters,
          returnType: func.returnType,
          documentationComments: func.documentationComments,
          channelName: makeChannelName(api, func, dartPackageName),
          addSuffixVariable: true,
          useJni: generatorOptions.useJni,
        );
      }
    });
  }

  @override
  void writeEventChannelApi(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    AstEventChannelApi api, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(indent, api.documentationComments, docCommentSpec);
    for (final Method func in api.methods) {
      indent.format('''
      Stream<${func.returnType.baseName}> ${func.name}(${_getMethodParameterSignature(func.parameters, addTrailingComma: true)} {String instanceName = ''}) {
        if (instanceName.isNotEmpty) {
          instanceName = '.\$instanceName';
        }
        final EventChannel ${func.name}Channel =
            EventChannel('${makeChannelName(api, func, dartPackageName)}\$instanceName', $_pigeonMethodChannelCodec);
        return ${func.name}Channel.receiveBroadcastStream().map((dynamic event) {
          return event as ${func.returnType.baseName};
        });
      }
    ''');
    }
  }

  @override
  void writeInstanceManager(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.format(proxyApiBaseClass);

    indent.format(
      instanceManagerTemplate(
        allProxyApiNames: root.apis.whereType<AstProxyApi>().map(
          (AstProxyApi api) => api.name,
        ),
      ),
    );
  }

  @override
  void writeInstanceManagerApi(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final cb.Parameter binaryMessengerParameter = cb.Parameter(
      (cb.ParameterBuilder builder) =>
          builder
            ..name = 'binaryMessenger'
            ..type = cb.refer('BinaryMessenger?')
            ..named = true,
    );

    final cb.Field binaryMessengerField = cb.Field(
      (cb.FieldBuilder builder) =>
          builder
            ..name = '${varNamePrefix}binaryMessenger'
            ..type = cb.refer('BinaryMessenger?')
            ..modifier = cb.FieldModifier.final$,
    );

    final cb.Class instanceManagerApi = cb.Class(
      (cb.ClassBuilder builder) =>
          builder
            ..name = dartInstanceManagerApiClassName
            ..docs.add(
              '/// Generated API for managing the Dart and native `$dartInstanceManagerClassName`s.',
            )
            ..constructors.add(
              cb.Constructor((cb.ConstructorBuilder builder) {
                builder
                  ..docs.add(
                    '/// Constructor for [$dartInstanceManagerApiClassName].',
                  )
                  ..optionalParameters.add(binaryMessengerParameter)
                  ..initializers.add(
                    cb.Code(
                      '${binaryMessengerField.name} = ${binaryMessengerParameter.name}',
                    ),
                  );
              }),
            )
            ..fields.addAll(<cb.Field>[
              binaryMessengerField,
              cb.Field((cb.FieldBuilder builder) {
                builder
                  ..name = pigeonChannelCodec
                  ..type = cb.refer('MessageCodec<Object?>')
                  ..static = true
                  ..modifier = cb.FieldModifier.constant
                  ..assignment = const cb.Code('$_pigeonMessageCodec()');
              }),
            ])
            ..methods.add(
              cb.Method((cb.MethodBuilder builder) {
                builder
                  ..name = 'setUpMessageHandlers'
                  ..static = true
                  ..returns = cb.refer('void')
                  ..optionalParameters.addAll(<cb.Parameter>[
                    cb.Parameter(
                      (cb.ParameterBuilder builder) =>
                          builder
                            ..name = '${classMemberNamePrefix}clearHandlers'
                            ..type = cb.refer('bool')
                            ..named = true
                            ..defaultTo = const cb.Code('false'),
                    ),
                    binaryMessengerParameter,
                    cb.Parameter(
                      (cb.ParameterBuilder builder) =>
                          builder
                            ..name = 'instanceManager'
                            ..named = true
                            ..type = cb.refer('$dartInstanceManagerClassName?'),
                    ),
                  ])
                  ..body = cb.Block.of(
                    cb.Block((cb.BlockBuilder builder) {
                      final StringBuffer messageHandlerSink = StringBuffer();
                      writeFlutterMethodMessageHandler(
                        Indent(messageHandlerSink),
                        name: 'removeStrongReferenceName',
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
                        channelName: makeRemoveStrongReferenceChannelName(
                          dartPackageName,
                        ),
                        isMockHandler: false,
                        isAsynchronous: false,
                        nullHandlerExpression:
                            '${classMemberNamePrefix}clearHandlers',
                        onCreateApiCall: (
                          String methodName,
                          Iterable<Parameter> parameters,
                          Iterable<String> safeArgumentNames,
                        ) {
                          return '(instanceManager ?? $dartInstanceManagerClassName.instance).remove(${safeArgumentNames.single})';
                        },
                      );
                      builder.statements.add(
                        cb.Code(messageHandlerSink.toString()),
                      );
                    }).statements,
                  );
              }),
            )
            ..methods.addAll(<cb.Method>[
              cb.Method((cb.MethodBuilder builder) {
                builder
                  ..name = 'removeStrongReference'
                  ..returns = cb.refer('Future<void>')
                  ..modifier = cb.MethodModifier.async
                  ..requiredParameters.add(
                    cb.Parameter(
                      (cb.ParameterBuilder builder) =>
                          builder
                            ..name = 'identifier'
                            ..type = cb.refer('int'),
                    ),
                  )
                  ..body = cb.Block((cb.BlockBuilder builder) {
                    final StringBuffer messageCallSink = StringBuffer();
                    writeHostMethodMessageCall(
                      Indent(messageCallSink),
                      addSuffixVariable: false,
                      channelName: makeRemoveStrongReferenceChannelName(
                        dartPackageName,
                      ),
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
                    );
                    builder.statements.addAll(<cb.Code>[
                      cb.Code(messageCallSink.toString()),
                    ]);
                  });
              }),
              cb.Method((cb.MethodBuilder builder) {
                builder
                  ..name = 'clear'
                  ..returns = cb.refer('Future<void>')
                  ..modifier = cb.MethodModifier.async
                  ..docs.addAll(<String>[
                    '/// Clear the native `$dartInstanceManagerClassName`.',
                    '///',
                    '/// This is typically called after a hot restart.',
                  ])
                  ..body = cb.Block((cb.BlockBuilder builder) {
                    final StringBuffer messageCallSink = StringBuffer();
                    writeHostMethodMessageCall(
                      Indent(messageCallSink),
                      addSuffixVariable: false,
                      channelName: makeClearChannelName(dartPackageName),
                      parameters: <Parameter>[],
                      returnType: const TypeDeclaration.voidDeclaration(),
                    );
                    builder.statements.addAll(<cb.Code>[
                      cb.Code(messageCallSink.toString()),
                    ]);
                  });
              }),
            ]),
    );

    final cb.DartEmitter emitter = cb.DartEmitter(useNullSafetySyntax: true);
    indent.format(
      DartFormatter(
        languageVersion: Version(3, 6, 0),
      ).format('${instanceManagerApi.accept(emitter)}'),
    );
  }

  @override
  void writeProxyApiBaseCodec(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
  ) {
    indent.format(proxyApiBaseCodec);
  }

  @override
  void writeProxyApi(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent,
    AstProxyApi api, {
    required String dartPackageName,
  }) {
    const String codecName = '_${classNamePrefix}ProxyApiBaseCodec';

    // Each API has a private codec instance used by every host method,
    // constructor, or non-static field.
    final String codecInstanceName = '_${varNamePrefix}codec${api.name}';

    // AST class used by code_builder to generate the code.
    final cb.Class proxyApi = cb.Class(
      (cb.ClassBuilder builder) =>
          builder
            ..name = api.name
            ..extend =
                api.superClass != null
                    ? cb.refer(api.superClass!.baseName)
                    : cb.refer(proxyApiBaseClassName)
            ..implements.addAll(
              api.interfaces.map(
                (TypeDeclaration type) => cb.refer(type.baseName),
              ),
            )
            ..docs.addAll(
              asDocumentationComments(
                api.documentationComments,
                docCommentSpec,
              ),
            )
            ..constructors.addAll(
              proxy_api_helper.constructors(
                api.constructors,
                apiName: api.name,
                dartPackageName: dartPackageName,
                codecName: codecName,
                codecInstanceName: codecInstanceName,
                superClassApi: api.superClass?.associatedProxyApi,
                unattachedFields: api.unattachedFields,
                flutterMethodsFromSuperClasses:
                    api.flutterMethodsFromSuperClassesWithApis(),
                flutterMethodsFromInterfaces:
                    api.flutterMethodsFromInterfacesWithApis(),
                declaredFlutterMethods: api.flutterMethods,
              ),
            )
            ..constructors.add(
              proxy_api_helper.detachedConstructor(
                apiName: api.name,
                superClassApi: api.superClass?.associatedProxyApi,
                unattachedFields: api.unattachedFields,
                flutterMethodsFromSuperClasses:
                    api.flutterMethodsFromSuperClassesWithApis(),
                flutterMethodsFromInterfaces:
                    api.flutterMethodsFromInterfacesWithApis(),
                declaredFlutterMethods: api.flutterMethods,
              ),
            )
            ..fields.addAll(<cb.Field>[
              if (api.constructors.isNotEmpty ||
                  api.attachedFields.any((ApiField field) => !field.isStatic) ||
                  api.hostMethods.isNotEmpty)
                proxy_api_helper.codecInstanceField(
                  codecInstanceName: codecInstanceName,
                  codecName: codecName,
                ),
            ])
            ..fields.addAll(
              proxy_api_helper.unattachedFields(api.unattachedFields),
            )
            ..fields.addAll(
              proxy_api_helper.flutterMethodFields(
                api.flutterMethods,
                apiName: api.name,
              ),
            )
            ..fields.addAll(
              proxy_api_helper.interfaceApiFields(api.apisOfInterfaces()),
            )
            ..fields.addAll(proxy_api_helper.attachedFields(api.attachedFields))
            ..methods.addAll(
              proxy_api_helper.staticAttachedFieldsGetters(
                api.attachedFields.where((ApiField field) => field.isStatic),
                apiName: api.name,
              ),
            )
            ..methods.add(
              proxy_api_helper.setUpMessageHandlerMethod(
                flutterMethods: api.flutterMethods,
                apiName: api.name,
                dartPackageName: dartPackageName,
                codecName: codecName,
                unattachedFields: api.unattachedFields,
                hasCallbackConstructor: api.hasCallbackConstructor(),
              ),
            )
            ..methods.addAll(
              proxy_api_helper.attachedFieldMethods(
                api.attachedFields,
                apiName: api.name,
                dartPackageName: dartPackageName,
                codecInstanceName: codecInstanceName,
                codecName: codecName,
              ),
            )
            ..methods.addAll(
              proxy_api_helper.hostMethods(
                api.hostMethods,
                apiName: api.name,
                dartPackageName: dartPackageName,
                codecInstanceName: codecInstanceName,
                codecName: codecName,
              ),
            )
            ..methods.add(
              proxy_api_helper.copyMethod(
                apiName: api.name,
                unattachedFields: api.unattachedFields,
                flutterMethodsFromSuperClasses:
                    api.flutterMethodsFromSuperClassesWithApis(),
                flutterMethodsFromInterfaces:
                    api.flutterMethodsFromInterfacesWithApis(),
                declaredFlutterMethods: api.flutterMethods,
              ),
            ),
    );

    final cb.DartEmitter emitter = cb.DartEmitter(useNullSafetySyntax: true);
    indent.format(_formatter.format('${proxyApi.accept(emitter)}'));
  }

  /// Generates Dart source code for test support libraries based on the given AST
  /// represented by [root], outputting the code to [sink]. [sourceOutPath] is the
  /// path of the generated Dart code to be tested. [testOutPath] is where the
  /// test code will be generated.
  void generateTest(
    InternalDartOptions generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
    required String dartOutputPackageName,
  }) {
    final Indent indent = Indent(sink);
    final String sourceOutPath = generatorOptions.dartOut ?? '';
    final String testOutPath = generatorOptions.testOut ?? '';
    _writeTestPrologue(generatorOptions, root, indent);
    _writeTestImports(generatorOptions, root, indent);
    final String relativeDartPath = path.Context(
      style: path.Style.posix,
    ).relative(
      _posixify(sourceOutPath),
      from: _posixify(path.dirname(testOutPath)),
    );
    if (!relativeDartPath.contains('/lib/')) {
      // If we can't figure out the package name or the relative path doesn't
      // include a 'lib' directory, try relative path import which only works in
      // certain (older) versions of Dart.
      // TODO(gaaclarke): We should add a command-line parameter to override this import.
      indent.writeln(
        "import '${_escapeForDartSingleQuotedString(relativeDartPath)}';",
      );
    } else {
      final String path = relativeDartPath.replaceFirst(
        RegExp(r'^.*/lib/'),
        '',
      );
      indent.writeln("import 'package:$dartOutputPackageName/$path';");
    }
    writeGeneralCodec(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
    for (final AstHostApi api in root.apis.whereType<AstHostApi>()) {
      if (api.dartHostTestHandler != null) {
        final AstFlutterApi mockApi = AstFlutterApi(
          name: api.dartHostTestHandler!,
          methods: api.methods,
          documentationComments: api.documentationComments,
        );
        writeFlutterApi(
          generatorOptions,
          root,
          indent,
          mockApi,
          channelNameFunc:
              (Method func) => makeChannelName(api, func, dartPackageName),
          isMockHandler: true,
          dartPackageName: dartPackageName,
        );
      }
    }
  }

  /// Writes file header to sink.
  void _writeTestPrologue(InternalDartOptions opt, Root root, Indent indent) {
    if (opt.copyrightHeader != null) {
      addLines(indent, opt.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln(
      '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, unnecessary_import, no_leading_underscores_for_local_identifiers',
    );
    indent.writeln('// ignore_for_file: avoid_relative_lib_imports');
  }

  /// Writes file imports to sink.
  void _writeTestImports(InternalDartOptions opt, Root root, Indent indent) {
    indent.writeln("import 'dart:async';");
    indent.writeln(
      "import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;",
    );
    indent.writeln(
      "import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;",
    );
    indent.writeln("import 'package:flutter/services.dart';");
    indent.writeln("import 'package:flutter_test/flutter_test.dart';");
    indent.newln();
  }

  @override
  void writeGeneralUtilities(
    InternalDartOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (root.containsHostApi || root.containsProxyApi) {
      _writeCreateConnectionError(indent);
    }
    if (root.containsFlutterApi ||
        root.containsProxyApi ||
        generatorOptions.testOut != null) {
      _writeWrapResponse(generatorOptions, root, indent);
    }
    if (root.classes.isNotEmpty) {
      _writeDeepEquals(indent);
    }
    if (root.containsProxyApi) {
      proxy_api_helper.writeProxyApiPigeonOverrides(
        indent,
        formatter: _formatter,
        proxyApis: root.apis.whereType(),
      );
    }
    if (generatorOptions.useJni) {
      if (generatorOptions.useJni) {
        _writeJniCodec(indent, root);
      }

      indent.writeln('bool isType<T>(Type t) => T == t;');

      indent.writeln(
        'bool isTypeOrNullableType<T>(Type t) => isType<T>(t) || isType<T?>(t);',
      );

      indent.format(r'''
  void _throwNoInstanceError(String channelName) {
    String nameString = 'named $channelName';
    if (channelName == defaultInstanceName) {
      nameString = 'with no name';
    }
    final String error = 'No instance $nameString has been registered.';
    throw ArgumentError(error);
  }
  ''');
    }
  }

  void _writeJniCodec(Indent indent, Root root) {
    indent.newln();
    indent.format('''
class _PigeonJniCodec {
  static Object? readValue(JObject? value) {
    if (value == null) {
      return null;
    } else if (value.isA<JLong>(JLong.type)) {
      return (value.as(JLong.type)).longValue();
    } else if (value.isA<JDouble>(JDouble.type)) {
      return (value.as(JDouble.type)).doubleValue();
    } else if (value.isA<JString>(JString.type)) {
      return (value.as(JString.type)).toDartString();
    } else if (value.isA<JBoolean>(JBoolean.type)) {
      return (value.as(JBoolean.type)).booleanValue();
    } else if (value.isA<JByteArray>(JByteArray.type)) {
      final Uint8List list = Uint8List(value.as(JByteArray.type).length);
      for (int i = 0; i < value.as(JByteArray.type).length; i++) {
        list[i] = value.as(JByteArray.type)[i];
      }
      return list;
    } else if (value.isA<JIntArray>(JIntArray.type)) {
      final Int32List list = Int32List(value.as(JIntArray.type).length);
      for (int i = 0; i < value.as(JIntArray.type).length; i++) {
        list[i] = value.as(JIntArray.type)[i];
      }
      return list;
    } else if (value.isA<JLongArray>(JLongArray.type)) {
      final Int64List list = Int64List(value.as(JLongArray.type).length);
      for (int i = 0; i < value.as(JLongArray.type).length; i++) {
        list[i] = value.as(JLongArray.type)[i];
      }
      return list;
    } else if (value.isA<JDoubleArray>(JDoubleArray.type)) {
      final Float64List list = Float64List(value.as(JDoubleArray.type).length);
      for (int i = 0; i < value.as(JDoubleArray.type).length; i++) {
        list[i] = value.as(JDoubleArray.type)[i];
      }
      return list;
    } else if (value.isA<JList<JObject>>(JList.type<JObject>(JObject.type))) {
      final JList<JObject?> list = (value.as(JList.type<JObject?>(JObject.nullableType)));
      final List<Object?> res = <Object?>[];
      for (int i = 0; i < list.length; i++) {
        res.add(readValue(list[i]));
      }
      return res;
    } else if (value.isA<JMap<JObject, JObject>>(
        JMap.type<JObject, JObject>(JObject.type, JObject.type))) {
      final JMap<JObject?, JObject?> map =
          (value.as(JMap.type<JObject?, JObject?>(JObject.nullableType, JObject.nullableType)));
      final Map<Object?, Object?> res = <Object?, Object?>{};
      for (final MapEntry<JObject?, JObject?> entry in map.entries) {
        res[readValue(entry.key)] = readValue(entry.value);
      }
      return res;
    ${root.classes.map((Class dataClass) {
      final _JniType jniType = _JniType.fromClass(dataClass);
      return '''
      } else if (value.isA<${jniType.jniName}>(
          ${jniType.jniName}.type)) {
        return ${jniType.type.baseName}.fromJni(value.as(${jniType.jniName}.type));
        ''';
    }).join()}
    ${root.enums.map((Enum enumDefinition) {
      final _JniType jniType = _JniType.fromEnum(enumDefinition);
      return '''
      } else if (value.isA<${jniType.jniName}>(
          ${jniType.jniName}.type)) {
        return ${jniType.type.baseName}.fromJni(value.as(${jniType.jniName}.type));
        ''';
    }).join()}
    } else {
      throw ArgumentError.value(value);
    }
  }

  static T writeValue<T extends JObject?>(Object? value) {
    if (value == null) {
      return null as T;
    } else if (value is bool) {
      return JBoolean(value) as T;
    } else if (value is double) {
      return JDouble(value) as T;
      // ignore: avoid_double_and_int_checks
    } else if (value is int) {
      return JLong(value) as T;
    } else if (value is String) {
      return JString.fromString(value) as T;
    } else if (isTypeOrNullableType<JByteArray>(T)) {
      value as List<int>;
      final JByteArray array = JByteArray(value.length);
      for (int i = 0; i < value.length; i++) {
        array[i] = value[i];
      }
      return array as T;
    } else if (isTypeOrNullableType<JIntArray>(T)) {
      value as List<int>;
      final JIntArray array = JIntArray(value.length);
      for (int i = 0; i < value.length; i++) {
        array[i] = value[i];
      }
      return array as T;
    } else if (isTypeOrNullableType<JLongArray>(T)) {
      value as List<int>;
      final JLongArray array = JLongArray(value.length);
      for (int i = 0; i < value.length; i++) {
        array[i] = value[i];
      }
      return array as T;
    } else if (isTypeOrNullableType<JDoubleArray>(T)) {
      value as List<double>;
      final JDoubleArray array = JDoubleArray(value.length);
      for (int i = 0; i < value.length; i++) {
        array[i] = value[i];
      }
      return array as T;
    ${root.lists.values.sorted(sortByObjectCount).map((TypeDeclaration list) {
      if (list.typeArguments.isEmpty || list.typeArguments.first.baseName == 'Object') {
        return '';
      }
      final _JniType jniType = _JniType.fromTypeDeclaration(list);
      return '''
    } else if (value is ${jniType.type.getFullName(withNullable: false)} && isTypeOrNullableType<${jniType.fullJniName}>(T)) {
      final ${jniType.fullJniName} res =
          ${jniType.fullJniName}.array(${jniType.subTypeOne?.fullJniType ?? 'JObject.nullableType'});
      for (final ${jniType.dartCollectionTypes} entry in value) {
        res.add(writeValue(entry));
      }
      return res as T;
        ''';
    }).join()}
    } else if (value is List<Object>) {
      final JList<JObject> res = JList<JObject>.array(JObject.type);
      for (int i = 0; i < value.length; i++) {
        res.add(writeValue(value[i]));
      }
      return res as T;
    } else if (value is List) {
      final JList<JObject?> res = JList<JObject?>.array(JObject.nullableType);
      for (int i = 0; i < value.length; i++) {
        res.add(writeValue(value[i]));
      }
      return res as T;
    ${root.maps.entries.sorted((MapEntry<String, TypeDeclaration> a, MapEntry<String, TypeDeclaration> b) => sortByObjectCount(a.value, b.value)).map((MapEntry<String, TypeDeclaration> mapType) {
      if (mapType.value.typeArguments.isEmpty || (mapType.value.typeArguments.first.baseName == 'Object' && mapType.value.typeArguments.last.baseName == 'Object')) {
        return '';
      }
      final _JniType jniType = _JniType.fromTypeDeclaration(mapType.value);
      return '''
    } else if (value is ${jniType.type.getFullName(withNullable: false)} && isTypeOrNullableType<${jniType.fullJniName}>(T)) {
      final ${jniType.fullJniName} res =
          ${jniType.fullJniName}.hash(${jniType.subTypeOne?.fullJniType ?? 'JObject.nullableType'}, ${jniType.subTypeTwo?.fullJniType ?? 'JObject.nullableType'});
      for (final MapEntry${jniType.dartCollectionTypeAnnotations} entry in value.entries) {
        res[writeValue(entry.key)] = 
            writeValue(entry.value);
      }
      return res as T;
        ''';
    }).join()}
    } else if (value is Map<Object, Object>) {
      final JMap<JObject, JObject> res =
          JMap<JObject, JObject>.hash(JObject.type, JObject.type);
      for (final MapEntry<Object, Object> entry in value.entries) {
        res[writeValue(entry.key)] = 
            writeValue(entry.value);
      }
      return res as T;
    } else if (value is Map<Object, Object?>) {
      final JMap<JObject, JObject?> res =
          JMap<JObject, JObject?>.hash(JObject.type, JObject.nullableType);
      for (final MapEntry<Object, Object?> entry in value.entries) {
        res[writeValue(entry.key)] = 
            writeValue(entry.value);
      }
      return res as T;
    } else if (value is Map) {
      final JMap<JObject, JObject?> res =
          JMap<JObject, JObject?>.hash(JObject.type, JObject.nullableType);
      for (final MapEntry<Object?, Object?> entry in value.entries) {
        res[writeValue(entry.key)] = 
            writeValue(entry.value);
      }
      return res as T;
    ${root.classes.map((Class dataClass) {
      final _JniType jniType = _JniType.fromClass(dataClass);
      return '''
      } else if (value is ${jniType.type.baseName}) {
        return value.toJni() as T;
        ''';
    }).join()}
    ${root.enums.map((Enum enumDefinition) {
      final _JniType jniType = _JniType.fromEnum(enumDefinition);
      return '''
      } else if (value is ${jniType.type.baseName}) {
        return value.toJni() as T;
        ''';
    }).join()}
    } else {
      throw ArgumentError.value(value);
    }
  }
}
    ''');
  }

  /// Writes [wrapResponse] method.
  void _writeWrapResponse(InternalDartOptions opt, Root root, Indent indent) {
    indent.newln();
    indent.writeScoped(
      'List<Object?> wrapResponse({Object? result, PlatformException? error, bool empty = false}) {',
      '}',
      () {
        indent.writeScoped('if (empty) {', '}', () {
          indent.writeln('return <Object?>[];');
        });
        indent.writeScoped('if (error == null) {', '}', () {
          indent.writeln('return <Object?>[result];');
        });
        indent.writeln(
          'return <Object?>[error.code, error.message, error.details];',
        );
      },
    );
  }

  void _writeDeepEquals(Indent indent) {
    indent.format(r'''
bool _deepEquals(Object? a, Object? b) {
  if (a is List && b is List) {
    return a.length == b.length &&
        a.indexed
        .every(((int, dynamic) item) => _deepEquals(item.$2, b[item.$1]));
  }
  if (a is Map && b is Map) {
    return a.length == b.length && a.entries.every((MapEntry<Object?, Object?> entry) =>
        (b as Map<Object?, Object?>).containsKey(entry.key) &&
        _deepEquals(entry.value, b[entry.key]));
  }
  return a == b;
}
''');
  }

  void _writeCreateConnectionError(Indent indent) {
    indent.newln();
    indent.format('''
PlatformException _createConnectionError(String channelName) {
\treturn PlatformException(
\t\tcode: 'channel-error',
\t\tmessage: 'Unable to establish connection on channel: "\$channelName".',
\t);
}''');
  }

  void _writeCodecOverflowUtilities(Indent indent, List<EnumeratedType> types) {
    indent.newln();
    indent.writeln('// ignore: camel_case_types');
    indent.writeScoped('class $_overflowClassName {', '}', () {
      indent.format('''
$_overflowClassName({required this.type, required this.wrapped});

int type;
Object? wrapped;

Object encode() {
  return <Object?>[type, wrapped];
}

static $_overflowClassName decode(Object result) {
  result as List<Object?>;
  return $_overflowClassName(
    type: result[0]! as int,
    wrapped: result[1],
  );
}
''');
      indent.writeScoped('Object? unwrap() {', '}', () {
        indent.format('''
if (wrapped == null) {
  return null;
}
''');
        indent.writeScoped('switch (type) {', '}', () {
          int nonSerializedClassCount = 0;
          for (int i = totalCustomCodecKeysAllowed; i < types.length; i++) {
            if (types[i].associatedClass?.isSealed ?? false) {
              nonSerializedClassCount++;
            } else {
              indent.writeScoped(
                'case ${i - nonSerializedClassCount - totalCustomCodecKeysAllowed}:',
                '',
                () {
                  if (types[i].type == CustomTypes.customClass) {
                    indent.writeln('return ${types[i].name}.decode(wrapped!);');
                  } else if (types[i].type == CustomTypes.customEnum) {
                    indent.writeln(
                      'return ${types[i].name}.values[wrapped! as int];',
                    );
                  }
                },
              );
            }
          }
        });
        indent.writeln('return null;');
      });
    });
  }

  void _writeHostMethod(
    Indent indent, {
    required String name,
    required Iterable<Parameter> parameters,
    required TypeDeclaration returnType,
    required List<String> documentationComments,
    required String channelName,
    required bool addSuffixVariable,
    bool useJni = false,
  }) {
    addDocumentationComments(indent, documentationComments, docCommentSpec);
    final String argSignature = _getMethodParameterSignature(parameters);
    indent.write(
      'Future<${addGenericTypesNullable(returnType)}> $name($argSignature) async ',
    );
    indent.addScoped('{', '}', () {
      if (useJni) {
        indent.writeScoped(
          'if (Platform.isAndroid && _nativeInteropApi != null) {',
          '}',
          () {
            indent.writeln(
              'return _nativeInteropApi.$name(${parameters.map((Parameter e) => '${e.isNamed ? '${e.name}: ' : ''}${e.name}').join(', ')});',
            );
          },
        );
      }
      writeHostMethodMessageCall(
        indent,
        channelName: channelName,
        parameters: parameters,
        returnType: returnType,
        addSuffixVariable: addSuffixVariable,
      );
    });
  }

  /// Writes the message call to a host method to [indent].
  static void writeHostMethodMessageCall(
    Indent indent, {
    required String channelName,
    required Iterable<Parameter> parameters,
    required TypeDeclaration returnType,
    required bool addSuffixVariable,
    bool insideAsyncMethod = true,
  }) {
    final String? arguments = _getArgumentsForMethodCall(parameters);
    final String sendArgument =
        arguments == null ? 'null' : '<Object?>[$arguments]';

    final String channelSuffix = addSuffixVariable ? '\$$_suffixVarName' : '';
    final String constOrFinal = addSuffixVariable ? 'final' : 'const';
    indent.writeln(
      "$constOrFinal String ${varNamePrefix}channelName = '$channelName$channelSuffix';",
    );
    indent.writeScoped(
      'final BasicMessageChannel<Object?> ${varNamePrefix}channel = BasicMessageChannel<Object?>(',
      ');',
      () {
        indent.writeln('${varNamePrefix}channelName,');
        indent.writeln('$pigeonChannelCodec,');
        indent.writeln('binaryMessenger: ${varNamePrefix}binaryMessenger,');
      },
    );
    final String returnTypeName = _makeGenericTypeArguments(returnType);
    final String genericCastCall = _makeGenericCastCall(returnType);
    const String accessor = '${varNamePrefix}replyList[0]';
    // Avoid warnings from pointlessly casting to `Object?`.
    final String nullablyTypedAccessor =
        returnTypeName == 'Object'
            ? accessor
            : '($accessor as $returnTypeName?)';
    final String nullHandler =
        returnType.isNullable ? (genericCastCall.isEmpty ? '' : '?') : '!';
    String returnStatement = 'return';
    if (!returnType.isVoid) {
      returnStatement =
          '$returnStatement $nullablyTypedAccessor$nullHandler$genericCastCall';
    }
    returnStatement = '$returnStatement;';

    const String sendFutureVar = '${varNamePrefix}sendFuture';
    indent.writeln(
      'final Future<Object?> $sendFutureVar = ${varNamePrefix}channel.send($sendArgument);',
    );

    // If the message call is not made inside of an async method, this creates
    // an anonymous function to handle the send future.
    if (!insideAsyncMethod) {
      indent.writeln('() async {');
      indent.inc();
    }

    indent.format('''
final List<Object?>? ${varNamePrefix}replyList =
\t\tawait $sendFutureVar as List<Object?>?;
if (${varNamePrefix}replyList == null) {
\tthrow _createConnectionError(${varNamePrefix}channelName);
} else if (${varNamePrefix}replyList.length > 1) {
\tthrow PlatformException(
\t\tcode: ${varNamePrefix}replyList[0]! as String,
\t\tmessage: ${varNamePrefix}replyList[1] as String?,
\t\tdetails: ${varNamePrefix}replyList[2],
\t);''');
    // On iOS we can return nil from functions to accommodate error
    // handling.  Returning a nil value and not returning an error is an
    // exception.
    if (!returnType.isNullable && !returnType.isVoid) {
      indent.format('''
} else if (${varNamePrefix}replyList[0] == null) {
\tthrow PlatformException(
\t\tcode: 'null-error',
\t\tmessage: 'Host platform returned null value for non-null return value.',
\t);''');
    }
    indent.format('''
} else {
\t$returnStatement
}''');

    if (!insideAsyncMethod) {
      indent.dec();
      indent.writeln('}();');
    }
  }

  /// Writes the message call handler for a Flutter method to [indent].
  static void writeFlutterMethodMessageHandler(
    Indent indent, {
    required String name,
    required Iterable<Parameter> parameters,
    required TypeDeclaration returnType,
    required String channelName,
    required bool isMockHandler,
    required bool isAsynchronous,
    bool addSuffixVariable = false,
    String nullHandlerExpression = 'api == null',
    String Function(
          String methodName,
          Iterable<Parameter> parameters,
          Iterable<String> safeArgumentNames,
        )
        onCreateApiCall =
        _createFlutterApiMethodCall,
  }) {
    indent.write('');
    indent.addScoped('{', '}', () {
      indent.writeln(
        'final BasicMessageChannel<Object?> ${varNamePrefix}channel = BasicMessageChannel<Object?>(',
      );
      indent.nest(2, () {
        final String channelSuffix =
            addSuffixVariable ? r'$messageChannelSuffix' : '';
        indent.writeln("'$channelName$channelSuffix', $pigeonChannelCodec,");
        indent.writeln('binaryMessenger: binaryMessenger);');
      });
      final String messageHandlerSetterWithOpeningParentheses =
          isMockHandler
              ? '_testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(${varNamePrefix}channel, '
              : '${varNamePrefix}channel.setMessageHandler(';
      indent.write('if ($nullHandlerExpression) ');
      indent.addScoped('{', '}', () {
        indent.writeln('${messageHandlerSetterWithOpeningParentheses}null);');
      }, addTrailingNewline: false);
      indent.add(' else ');
      indent.addScoped('{', '}', () {
        indent.write(
          '$messageHandlerSetterWithOpeningParentheses(Object? message) async ',
        );
        indent.addScoped('{', '});', () {
          final String returnTypeString = addGenericTypesNullable(returnType);
          final bool isAsync = isAsynchronous;
          const String emptyReturnStatement =
              'return wrapResponse(empty: true);';
          String call;
          if (parameters.isEmpty) {
            call = 'api.$name()';
          } else {
            indent.writeln('assert(message != null,');
            indent.writeln("'Argument for $channelName was null.');");
            const String argsArray = 'args';
            indent.writeln(
              'final List<Object?> $argsArray = (message as List<Object?>?)!;',
            );
            String argNameFunc(int index, NamedType type) =>
                _getSafeArgumentName(index, type);
            enumerate(parameters, (int count, NamedType arg) {
              final String argType = _addGenericTypes(arg.type);
              final String argName = argNameFunc(count, arg);
              final String genericArgType = _makeGenericTypeArguments(arg.type);
              final String castCall = _makeGenericCastCall(arg.type);

              final String leftHandSide = 'final $argType? $argName';

              indent.writeln(
                '$leftHandSide = ($argsArray[$count] as $genericArgType?)${castCall.isEmpty ? '' : '?$castCall'};',
              );

              if (!arg.type.isNullable) {
                indent.writeln('assert($argName != null,');
                indent.writeln(
                  "    'Argument for $channelName was null, expected non-null $argType.');",
                );
              }
            });
            final Iterable<String> argNames = indexMap(parameters, (
              int index,
              Parameter field,
            ) {
              final String name = _getSafeArgumentName(index, field);
              return '${field.isNamed ? '${field.name}: ' : ''}$name${field.type.isNullable ? '' : '!'}';
            });
            call = onCreateApiCall(name, parameters, argNames);
          }
          indent.writeScoped('try {', '} ', () {
            if (returnType.isVoid) {
              if (isAsync) {
                indent.writeln('await $call;');
              } else {
                indent.writeln('$call;');
              }
              indent.writeln(emptyReturnStatement);
            } else {
              if (isAsync) {
                indent.writeln('final $returnTypeString output = await $call;');
              } else {
                indent.writeln('final $returnTypeString output = $call;');
              }

              const String returnExpression = 'output';
              final String returnStatement =
                  isMockHandler
                      ? 'return <Object?>[$returnExpression];'
                      : 'return wrapResponse(result: $returnExpression);';
              indent.writeln(returnStatement);
            }
          }, addTrailingNewline: false);
          indent.addScoped('on PlatformException catch (e) {', '}', () {
            indent.writeln('return wrapResponse(error: e);');
          }, addTrailingNewline: false);

          indent.writeScoped('catch (e) {', '}', () {
            indent.writeln(
              "return wrapResponse(error: PlatformException(code: 'error', message: e.toString()));",
            );
          });
        });
      });
    });
  }

  static String _createFlutterApiMethodCall(
    String methodName,
    Iterable<Parameter> parameters,
    Iterable<String> safeArgumentNames,
  ) {
    return 'api.$methodName(${safeArgumentNames.join(', ')})';
  }
}

/// Converts a [TypeDeclaration] to a `code_builder` Reference.
cb.Reference refer(TypeDeclaration type, {bool asFuture = false}) {
  final String symbol = addGenericTypesNullable(type);
  return cb.refer(asFuture ? 'Future<$symbol>' : symbol);
}

String _escapeForDartSingleQuotedString(String raw) {
  return raw
      .replaceAll(r'\', r'\\')
      .replaceAll(r'$', r'\$')
      .replaceAll(r"'", r"\'");
}

/// Creates a Dart type where all type arguments are [Objects].
String _makeGenericTypeArguments(TypeDeclaration type) {
  return type.typeArguments.isNotEmpty
      ? '${type.baseName}<${type.typeArguments.map<String>((TypeDeclaration e) => 'Object?').join(', ')}>'
      : _addGenericTypes(type);
}

/// Creates a `.cast<>` call for an type. Returns an empty string if the
/// type has no type arguments.
String _makeGenericCastCall(TypeDeclaration type) {
  return type.typeArguments.isNotEmpty
      ? '.cast<${_flattenTypeArguments(type.typeArguments)}>()'
      : '';
}

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType field) =>
    field.name.isEmpty ? 'arg$count' : 'arg_${field.name}';

/// Generates a parameter name if one isn't defined.
String getParameterName(int count, NamedType field) =>
    field.name.isEmpty ? 'arg$count' : field.name;

String _getJniMethodParameterSignature(
  Iterable<Parameter> parameters, {
  bool addTrailingComma = false,
  bool isAsynchronous = false,
}) {
  String signature = '';
  if (parameters.isEmpty) {
    return signature;
  }
  for (final Parameter parameter in parameters) {
    final _JniType jniType = _JniType.fromTypeDeclaration(parameter.type);
    signature +=
        '${jniType.getJniCallReturnType(isAsynchronous)} ${parameter.name}${addTrailingComma || parameters.length > 1 ? ',' : ''}';
  }
  return signature;
}

/// Generates the parameters code for [func]
/// Example: (func, getParameterName) -> 'String? foo, int bar'
String _getMethodParameterSignature(
  Iterable<Parameter> parameters, {
  bool addTrailingComma = false,
  bool useJni = false,
  bool isAsynchronous = false,
}) {
  String signature = '';
  if (parameters.isEmpty) {
    return signature;
  }
  if (useJni) {
    return _getJniMethodParameterSignature(
      parameters,
      addTrailingComma: addTrailingComma,
      isAsynchronous: isAsynchronous,
    );
  }

  final List<Parameter> requiredPositionalParams =
      parameters
          .where((Parameter p) => p.isPositional && !p.isOptional)
          .toList();
  final List<Parameter> optionalPositionalParams =
      parameters
          .where((Parameter p) => p.isPositional && p.isOptional)
          .toList();
  final List<Parameter> namedParams =
      parameters.where((Parameter p) => !p.isPositional).toList();

  String getParameterString(Parameter p) {
    final String required = p.isRequired && !p.isPositional ? 'required ' : '';

    final String type = addGenericTypesNullable(p.type);

    final String defaultValue =
        p.defaultValue == null ? '' : ' = ${p.defaultValue}';
    return '$required$type ${p.name}$defaultValue';
  }

  final String baseParameterString = requiredPositionalParams
      .map((Parameter p) => getParameterString(p))
      .join(', ');
  final String optionalParameterString = optionalPositionalParams
      .map((Parameter p) => getParameterString(p))
      .join(', ');
  final String namedParameterString = namedParams
      .map((Parameter p) => getParameterString(p))
      .join(', ');

  // Parameter lists can end with either named or optional positional parameters, but not both.
  if (requiredPositionalParams.isNotEmpty) {
    signature = baseParameterString;
  }
  final String trailingComma =
      optionalPositionalParams.isNotEmpty || namedParams.isNotEmpty ? ',' : '';
  final String baseParams =
      signature.isNotEmpty ? '$signature$trailingComma ' : '';
  if (optionalPositionalParams.isNotEmpty) {
    final String trailingComma =
        requiredPositionalParams.length + optionalPositionalParams.length > 2
            ? ','
            : '';
    return '$baseParams[$optionalParameterString$trailingComma]';
  }
  if (namedParams.isNotEmpty) {
    final String trailingComma =
        addTrailingComma ||
                requiredPositionalParams.length + namedParams.length > 2
            ? ', '
            : '';
    return '$baseParams{$namedParameterString$trailingComma}';
  }
  return signature;
}

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in Dart code.
String _flattenTypeArguments(List<TypeDeclaration> args) {
  return args
      .map<String>(
        (TypeDeclaration arg) =>
            arg.typeArguments.isEmpty
                ? '${arg.baseName}${arg.isNullable ? '?' : ''}'
                : '${arg.baseName}<${_flattenTypeArguments(arg.typeArguments)}>${arg.isNullable ? '?' : ''}',
      )
      .join(', ');
}

/// Creates the type declaration for use in Dart code from a [NamedType] making sure
/// that type arguments are used for primitive generic types.
String _addGenericTypes(TypeDeclaration type, {bool useJni = false}) {
  final List<TypeDeclaration> typeArguments = type.typeArguments;
  switch (type.baseName) {
    case 'List':
      return typeArguments.isEmpty
          ? 'List<Object?>'
          : 'List<${_flattenTypeArguments(typeArguments)}>';
    case 'Map':
      return typeArguments.isEmpty
          ? 'Map<Object?, Object?>'
          : 'Map<${_flattenTypeArguments(typeArguments)}>';
    default:
      if (useJni) {
        return _JniType.fromTypeDeclaration(type).jniName;
      } else {
        return type.baseName;
      }
  }
}

/// Converts the type signature of a [TypeDeclaration] that include generic
/// types.
String addGenericTypesNullable(TypeDeclaration type, {bool useJni = false}) {
  final String genericType = _addGenericTypes(type, useJni: useJni);
  return '$genericType${_getNullableSymbol(type.isNullable)}';
}

/// Converts [inputPath] to a posix absolute path.
String _posixify(String inputPath) {
  final path.Context context = path.Context(style: path.Style.posix);
  return context.fromUri(path.toUri(path.absolute(inputPath)));
}

String? _getArgumentsForMethodCall(Iterable<Parameter> parameters) {
  if (parameters.isNotEmpty) {
    return indexMap(parameters, (int index, NamedType type) {
      final String name = getParameterName(index, type);
      return name;
    }).join(', ');
  }
  return null;
}

bool _usesNativeInterop(InternalDartOptions options) {
  return options.useJni;
}
