// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

/// The name of the generated, private helper for converting [String] to [bool].
const String boolConverterHelperName = r'_$boolConverter';

/// The name of the generated, private helper for handling nullable value
/// conversion.
const String convertMapValueHelperName = r'_$convertMapValue';

/// The name of the generated, private helper for converting [Duration] to
/// [bool].
const String durationDecoderHelperName = r'_$duractionConverter';

/// The name of the generated, private helper for converting [String] to [Enum].
const String enumExtensionHelperName = r'_$fromName';

/// The property/parameter name used to represent the `extra` data that may
/// be passed to a route.
const String extraFieldName = r'$extra';

/// Shared start of error message related to a likely code issue.
const String likelyIssueMessage = 'Should never get here! File an issue!';

const List<_TypeHelper> _helpers = <_TypeHelper>[
  _TypeHelperBigInt(),
  _TypeHelperBool(),
  _TypeHelperDateTime(),
  _TypeHelperDouble(),
  _TypeHelperEnum(),
  _TypeHelperInt(),
  _TypeHelperNum(),
  _TypeHelperString(),
  _TypeHelperUri(),
];

/// Returns the decoded [String] value for [element], if its type is supported.
///
/// Otherwise, throws an [InvalidGenerationSourceError].
String decodeParameter(ParameterElement element) {
  if (element.isExtraField) {
    return 'state.${_stateValueAccess(element)}';
  }

  final DartType paramType = element.type;
  for (final _TypeHelper helper in _helpers) {
    if (helper._matchesType(paramType)) {
      return helper._decode(element);
    }
  }

  throw InvalidGenerationSourceError(
    'The parameter type '
    '`${paramType.getDisplayString(withNullability: false)}` is not supported.',
    element: element,
  );
}

/// Returns the encoded [String] value for [element], if its type is supported.
///
/// Otherwise, throws an [InvalidGenerationSourceError].
String encodeField(PropertyAccessorElement element) {
  for (final _TypeHelper helper in _helpers) {
    if (helper._matchesType(element.returnType)) {
      return helper._encode(element.name, element.returnType);
    }
  }

  throw InvalidGenerationSourceError(
    'The return type `${element.returnType}` is not supported.',
    element: element,
  );
}

/// Gets the name of the `const` map generated to help encode [Enum] types.
// TODO(stuartmorgan): Remove this ignore once 'analyze' can be set to
// 5.2+ (when Flutter 3.4+ is on stable).
// ignore: deprecated_member_use
String enumMapName(InterfaceType type) => '_\$${type.element.name}EnumMap';

String _stateValueAccess(ParameterElement element) {
  if (element.isRequired) {
    return 'params[${escapeDartString(element.name)}]!';
  }

  if (element.isExtraField) {
    return 'extra as ${element.type.getDisplayString(withNullability: true)}';
  }

  if (element.isOptional) {
    return 'queryParams[${escapeDartString(element.name.kebab)}]';
  }

  throw InvalidGenerationSourceError(
    '$likelyIssueMessage (param not required or optional)',
    element: element,
  );
}

abstract class _TypeHelper {
  const _TypeHelper();

  String _decode(ParameterElement parameterElement);

  String _encode(String fieldName, DartType type);

  bool _matchesType(DartType type);
}

class _TypeHelperBigInt extends _TypeHelperWithHelper {
  const _TypeHelperBigInt();

  @override
  String helperName(DartType paramType) => 'BigInt.parse';

  @override
  String _encode(String fieldName, DartType type) =>
      '$fieldName${type.ensureNotNull}.toString()';

  @override
  bool _matchesType(DartType type) =>
      const TypeChecker.fromRuntime(BigInt).isAssignableFromType(type);
}

class _TypeHelperBool extends _TypeHelperWithHelper {
  const _TypeHelperBool();

  @override
  String helperName(DartType paramType) => boolConverterHelperName;

  @override
  String _encode(String fieldName, DartType type) =>
      '$fieldName${type.ensureNotNull}.toString()';

  @override
  bool _matchesType(DartType type) => type.isDartCoreBool;
}

class _TypeHelperDateTime extends _TypeHelperWithHelper {
  const _TypeHelperDateTime();

  @override
  String helperName(DartType paramType) => 'DateTime.parse';

  @override
  String _encode(String fieldName, DartType type) =>
      '$fieldName${type.ensureNotNull}.toString()';

  @override
  bool _matchesType(DartType type) =>
      const TypeChecker.fromRuntime(DateTime).isAssignableFromType(type);
}

class _TypeHelperDouble extends _TypeHelperWithHelper {
  const _TypeHelperDouble();

  @override
  String helperName(DartType paramType) => 'double.parse';

  @override
  String _encode(String fieldName, DartType type) =>
      '$fieldName${type.ensureNotNull}.toString()';

  @override
  bool _matchesType(DartType type) => type.isDartCoreDouble;
}

class _TypeHelperEnum extends _TypeHelperWithHelper {
  const _TypeHelperEnum();

  @override
  String helperName(DartType paramType) =>
      '${enumMapName(paramType as InterfaceType)}.$enumExtensionHelperName';

  @override
  String _encode(String fieldName, DartType type) =>
      '${enumMapName(type as InterfaceType)}[$fieldName${type.ensureNotNull}]!';

  @override
  bool _matchesType(DartType type) => type.isEnum;
}

class _TypeHelperInt extends _TypeHelperWithHelper {
  const _TypeHelperInt();

  @override
  String helperName(DartType paramType) => 'int.parse';

  @override
  String _encode(String fieldName, DartType type) =>
      '$fieldName${type.ensureNotNull}.toString()';

  @override
  bool _matchesType(DartType type) => type.isDartCoreInt;
}

class _TypeHelperNum extends _TypeHelperWithHelper {
  const _TypeHelperNum();

  @override
  String helperName(DartType paramType) => 'num.parse';

  @override
  String _encode(String fieldName, DartType type) =>
      '$fieldName${type.ensureNotNull}.toString()';

  @override
  bool _matchesType(DartType type) => type.isDartCoreNum;
}

class _TypeHelperString extends _TypeHelper {
  const _TypeHelperString();

  @override
  String _decode(ParameterElement parameterElement) =>
      'state.${_stateValueAccess(parameterElement)}';

  @override
  String _encode(String fieldName, DartType type) =>
      '$fieldName${type.ensureNotNull}';

  @override
  bool _matchesType(DartType type) => type.isDartCoreString;
}

class _TypeHelperUri extends _TypeHelperWithHelper {
  const _TypeHelperUri();

  @override
  String helperName(DartType paramType) => 'Uri.parse';

  @override
  String _encode(String fieldName, DartType type) =>
      '$fieldName${type.ensureNotNull}.toString()';

  @override
  bool _matchesType(DartType type) =>
      const TypeChecker.fromRuntime(Uri).isAssignableFromType(type);
}

abstract class _TypeHelperWithHelper extends _TypeHelper {
  const _TypeHelperWithHelper();

  String helperName(DartType paramType);

  @override
  String _decode(ParameterElement parameterElement) {
    final DartType paramType = parameterElement.type;

    if (paramType.isNullableType) {
      return '$convertMapValueHelperName('
          '${escapeDartString(parameterElement.name.kebab)}, '
          'state.queryParams, '
          '${helperName(paramType)})';
    }

    return '${helperName(paramType)}'
        '(state.${_stateValueAccess(parameterElement)})';
  }
}

extension on DartType {
  String get ensureNotNull => isNullableType ? '!' : '';
}

/// Extension helpers on [ParameterElement].
extension ParameterElementExtension on ParameterElement {
  /// Convenient helper on top of [isRequiredPositional] and [isRequiredNamed].
  bool get isRequired => isRequiredPositional || isRequiredNamed;

  /// Returns `true` if `this` has a name that matches [extraFieldName];
  bool get isExtraField => name == extraFieldName;
}
