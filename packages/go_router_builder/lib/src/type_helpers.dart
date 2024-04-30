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
const String durationDecoderHelperName = r'_$durationConverter';

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
  _TypeHelperIterable(),
];

/// Returns the decoded [String] value for [element], if its type is supported.
///
/// Otherwise, throws an [InvalidGenerationSourceError].
String decodeParameter(ParameterElement element, Set<String> pathParameters) {
  if (element.isExtraField) {
    return 'state.${_stateValueAccess(element, pathParameters)}';
  }

  final DartType paramType = element.type;
  for (final _TypeHelper helper in _helpers) {
    if (helper._matchesType(paramType)) {
      String decoded = helper._decode(element, pathParameters);
      if (element.isOptional && element.hasDefaultValue) {
        if (element.type.isNullableType) {
          throw NullableDefaultValueError(element);
        }
        decoded += ' ?? ${element.defaultValueCode!}';
      }
      return decoded;
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
String enumMapName(InterfaceType type) => '_\$${type.element.name}EnumMap';

String _stateValueAccess(ParameterElement element, Set<String> pathParameters) {
  if (element.isExtraField) {
    // ignore: avoid_redundant_argument_values
    return 'extra as ${element.type.getDisplayString(withNullability: true)}';
  }

  late String access;
  if (pathParameters.contains(element.name)) {
    access = 'pathParameters[${escapeDartString(element.name)}]';
  } else {
    access = 'uri.queryParameters[${escapeDartString(element.name.kebab)}]';
  }
  if (pathParameters.contains(element.name) ||
      (!element.type.isNullableType && !element.hasDefaultValue)) {
    access += '!';
  }

  return access;
}

abstract class _TypeHelper {
  const _TypeHelper();

  /// Decodes the value from its string representation in the URL.
  String _decode(ParameterElement parameterElement, Set<String> pathParameters);

  /// Encodes the value from its string representation in the URL.
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
      '${enumMapName(type as InterfaceType)}[$fieldName${type.ensureNotNull}]';

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
  String _decode(
          ParameterElement parameterElement, Set<String> pathParameters) =>
      'state.${_stateValueAccess(parameterElement, pathParameters)}';

  @override
  String _encode(String fieldName, DartType type) => fieldName;

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

class _TypeHelperIterable extends _TypeHelper {
  const _TypeHelperIterable();

  @override
  String _decode(
      ParameterElement parameterElement, Set<String> pathParameters) {
    if (parameterElement.type is ParameterizedType) {
      final DartType iterableType =
          (parameterElement.type as ParameterizedType).typeArguments.first;

      // get a type converter for values in iterable
      String entriesTypeDecoder = '(e) => e';
      for (final _TypeHelper helper in _helpers) {
        if (helper._matchesType(iterableType) &&
            helper is _TypeHelperWithHelper) {
          entriesTypeDecoder = helper.helperName(iterableType);
        }
      }

      // get correct type for iterable
      String iterableCaster = '';
      if (const TypeChecker.fromRuntime(List)
          .isAssignableFromType(parameterElement.type)) {
        iterableCaster = '.toList()';
      } else if (const TypeChecker.fromRuntime(Set)
          .isAssignableFromType(parameterElement.type)) {
        iterableCaster = '.toSet()';
      }

      return '''
state.uri.queryParametersAll[
        ${escapeDartString(parameterElement.name.kebab)}]
        ?.map($entriesTypeDecoder)$iterableCaster''';
    }
    return '''
state.uri.queryParametersAll[${escapeDartString(parameterElement.name.kebab)}]''';
  }

  @override
  String _encode(String fieldName, DartType type) {
    final String nullAwareAccess = type.isNullableType ? '?' : '';
    if (type is ParameterizedType) {
      final DartType iterableType = type.typeArguments.first;

      // get a type encoder for values in iterable
      String entriesTypeEncoder = '';
      for (final _TypeHelper helper in _helpers) {
        if (helper._matchesType(iterableType)) {
          entriesTypeEncoder = '''
$nullAwareAccess.map((e) => ${helper._encode('e', iterableType)}).toList()''';
        }
      }
      return '''
$fieldName$entriesTypeEncoder''';
    }

    return '''
$fieldName$nullAwareAccess.map((e) => e.toString()).toList()''';
  }

  @override
  bool _matchesType(DartType type) =>
      const TypeChecker.fromRuntime(Iterable).isAssignableFromType(type);
}

abstract class _TypeHelperWithHelper extends _TypeHelper {
  const _TypeHelperWithHelper();

  String helperName(DartType paramType);

  @override
  String _decode(
      ParameterElement parameterElement, Set<String> pathParameters) {
    final DartType paramType = parameterElement.type;
    final String parameterName = parameterElement.name;

    if (!pathParameters.contains(parameterName) &&
        (paramType.isNullableType || parameterElement.hasDefaultValue)) {
      return '$convertMapValueHelperName('
          '${escapeDartString(parameterName.kebab)}, '
          'state.uri.queryParameters, '
          '${helperName(paramType)})';
    }
    return '${helperName(paramType)}'
        '(state.${_stateValueAccess(parameterElement, pathParameters)})';
  }
}

/// Extension helpers on [DartType].
extension DartTypeExtension on DartType {
  /// Convenient helper for nullability checks.
  String get ensureNotNull => isNullableType ? '!' : '';
}

/// Extension helpers on [ParameterElement].
extension ParameterElementExtension on ParameterElement {
  /// Convenient helper on top of [isRequiredPositional] and [isRequiredNamed].
  bool get isRequired => isRequiredPositional || isRequiredNamed;

  /// Returns `true` if `this` has a name that matches [extraFieldName];
  bool get isExtraField => name == extraFieldName;
}

/// An error thrown when a default value is used with a nullable type.
class NullableDefaultValueError extends InvalidGenerationSourceError {
  /// An error thrown when a default value is used with a nullable type.
  NullableDefaultValueError(
    Element element,
  ) : super(
          'Default value used with a nullable type. Only non-nullable type can have a default value.',
          todo: 'Remove the default value or make the type non-nullable.',
          element: element,
        );
}
