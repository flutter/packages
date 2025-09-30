// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
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

/// The name of the generated, private getter for casting `this` (the mixin) to the class type.
const String selfFieldName = '_self';

/// Shared start of error message related to a likely code issue.
const String likelyIssueMessage = 'Should never get here! File an issue!';

/// The name of the generated, private helper for comparing iterables.
const String iterablesEqualHelperName = r'_$iterablesEqual';

const List<_TypeHelper> _helpers = <_TypeHelper>[
  _TypeHelperBigInt(),
  _TypeHelperBool(),
  _TypeHelperDateTime(),
  _TypeHelperDouble(),
  _TypeHelperEnum(),
  _TypeHelperExtensionType(),
  _TypeHelperInt(),
  _TypeHelperNum(),
  _TypeHelperString(),
  _TypeHelperUri(),
  _TypeHelperIterable(),
  _TypeHelperJson(),
];

/// Checks if has a function that converts string to string, such as encode and decode.
bool _isStringToStringFunction(
  ExecutableElement2? executableElement,
  String name,
) {
  if (executableElement == null) {
    return false;
  }
  final List<FormalParameterElement> parameters =
      executableElement.formalParameters;
  return parameters.length == 1 &&
      parameters.first.type.isDartCoreString &&
      executableElement.returnType.isDartCoreString;
}

/// Returns the custom codec for the annotation.
String? _getCustomCodec(ElementAnnotation annotation, String name) {
  final ExecutableElement2? executableElement =
      // ignore: experimental_member_use
      annotation.computeConstantValue()?.getField(name)?.toFunctionValue2();
  if (_isStringToStringFunction(executableElement, name)) {
    return executableElement!.displayName;
  }
  return null;
}

/// Returns the decoded [String] value for [element], if its type is supported.
///
/// Otherwise, throws an [InvalidGenerationSourceError].
String decodeParameter(
  FormalParameterElement element,
  Set<String> pathParameters,
  List<ElementAnnotation>? metadata,
) {
  if (element.isExtraField) {
    return 'state.${_stateValueAccess(element, pathParameters)}';
  }

  final DartType paramType = element.type;
  for (final _TypeHelper helper in _helpers) {
    if (helper._matchesType(paramType)) {
      String? decoder;

      final ElementAnnotation? annotation = metadata?.firstWhereOrNull((
        ElementAnnotation annotation,
      ) {
        return annotation.computeConstantValue()?.type?.getDisplayString() ==
            'CustomParameterCodec';
      });
      if (annotation != null) {
        final String? decode = _getCustomCodec(annotation, 'decode');
        final String? encode = _getCustomCodec(annotation, 'encode');
        if (decode != null && encode != null) {
          decoder = decode;
        } else {
          throw InvalidGenerationSourceError(
            'The parameter type '
            '`${paramType.getDisplayString(withNullability: false)}` not have a well defined CustomParameterCodec decorator.',
            element: element,
          );
        }
      }
      String decoded = helper._decode(element, pathParameters, decoder);
      if (element.isOptional && element.hasDefaultValue) {
        if (element.type.isNullableType) {
          throw NullableDefaultValueError(element);
        }
        decoded += ' ?? ${element.defaultValueCode!}';
      }
      if (helper is _TypeHelperString && decoder != null) {
        return _fieldWithEncoder(decoded, decoder);
      }
      return decoded;
    }
  }

  throw InvalidGenerationSourceError(
    'The parameter type '
    '`${withoutNullability(paramType.getDisplayString())}` is not supported.',
    element: element,
  );
}

/// Returns the encoded [String] value for [element], if its type is supported.
///
/// Otherwise, throws an [InvalidGenerationSourceError].
String encodeField(
  PropertyAccessorElement2 element,
  List<ElementAnnotation>? metadata,
) {
  for (final _TypeHelper helper in _helpers) {
    if (helper._matchesType(element.returnType)) {
      String? encoder;
      final ElementAnnotation? annotation = metadata?.firstWhereOrNull((
        ElementAnnotation annotation,
      ) {
        final DartObject? constant = annotation.computeConstantValue();
        return constant?.type?.getDisplayString() == 'CustomParameterCodec';
      });
      if (annotation != null) {
        final String? decode = _getCustomCodec(annotation, 'decode');
        final String? encode = _getCustomCodec(annotation, 'encode');
        if (decode != null && encode != null) {
          encoder = encode;
        } else {
          throw InvalidGenerationSourceError(
            'The parameter type '
            '`${element.type.getDisplayString(withNullability: false)}` not have a well defined CustomParameterCodec decorator.',
            element: element,
          );
        }
      }
      final String encoded = helper._encode(
        '$selfFieldName.${element.displayName}',
        element.returnType,
        encoder,
      );
      return encoded;
    }
  }

  throw InvalidGenerationSourceError(
    'The return type `${element.returnType}` is not supported.',
    element: element,
  );
}

/// Returns an AstNode type from a InterfaceElement2.
T? getNodeDeclaration<T extends AstNode>(InterfaceElement2 element) {
  final AnalysisSession? session = element.session;
  if (session == null) {
    return null;
  }

  final ParsedLibraryResult parsedLibrary =
      // ignore: experimental_member_use
      session.getParsedLibraryByElement2(element.library2)
          as ParsedLibraryResult;
  final FragmentDeclarationResult? declaration = parsedLibrary
  // ignore: experimental_member_use
  .getFragmentDeclaration(element.firstFragment);
  final AstNode? node = declaration?.node;

  return node is T ? node : null;
}

/// Returns the comparison of a parameter with its default value.
///
/// Otherwise, throws an [InvalidGenerationSourceError].
String compareField(
  FormalParameterElement param,
  String value1,
  String value2,
) {
  for (final _TypeHelper helper in _helpers) {
    if (helper._matchesType(param.type)) {
      return helper._compare(
        '$selfFieldName.${param.displayName}',
        param.defaultValueCode!,
      );
    }
  }

  throw InvalidGenerationSourceError(
    'The type `${param.type}` is not supported.',
    element: param,
  );
}

/// Gets the name of the `const` map generated to help encode [Enum] types.
String enumMapName(InterfaceType type) => '_\$${type.element.name}EnumMap';

/// Gets the name of the `const` map generated to help encode [Json] types.
String jsonMapName(InterfaceType type) => type.element.name;

String _stateValueAccess(
  FormalParameterElement element,
  Set<String> pathParameters,
) {
  if (element.isExtraField) {
    // ignore: avoid_redundant_argument_values
    return 'extra as ${element.type.getDisplayString()}';
  }

  late String access;
  final String suffix =
      !element.type.isNullableType && !element.hasDefaultValue ? '!' : '';
  if (pathParameters.contains(element.displayName)) {
    access = 'pathParameters[${escapeDartString(element.displayName)}]$suffix';
  } else {
    access =
        'uri.queryParameters[${escapeDartString(element.displayName.kebab)}]$suffix';
  }

  return access;
}

/// Returns `true` if the type string ends with a nullability marker (`?` or `*`)
bool _isNullableType(String type) {
  return type.endsWith('?') || type.endsWith('*');
}

/// Returns the type string without a trailing nullability marker
String withoutNullability(String type) {
  return _isNullableType(type) ? type.substring(0, type.length - 1) : type;
}

String _fieldWithEncoder(String field, String? customEncoder) {
  return customEncoder != null ? '$customEncoder($field)' : field;
}

abstract class _TypeHelper {
  const _TypeHelper();

  /// Decodes the value from its string representation in the URL.
  String _decode(
    FormalParameterElement parameterElement,
    Set<String> pathParameters,
    String? customDecoder,
  );

  /// Encodes the value from its string representation in the URL.
  String _encode(String fieldName, DartType type, String? customEncoder);

  bool _matchesType(DartType type);

  String _compare(String value1, String value2) => '$value1 != $value2';
}

class _TypeHelperBigInt extends _TypeHelperWithHelper {
  const _TypeHelperBigInt();

  @override
  String helperName(DartType paramType) {
    if (paramType.isNullableType) {
      return 'BigInt.tryParse';
    }
    return 'BigInt.parse';
  }

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) =>
      _fieldWithEncoder(
        '$fieldName${type.ensureNotNull}.toString()',
        customEncoder,
      );

  @override
  bool _matchesType(DartType type) =>
      const TypeChecker.fromRuntime(BigInt).isAssignableFromType(type);
}

class _TypeHelperBool extends _TypeHelperWithHelper {
  const _TypeHelperBool();

  @override
  String helperName(DartType paramType) => boolConverterHelperName;

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) =>
      _fieldWithEncoder(
        '$fieldName${type.ensureNotNull}.toString()',
        customEncoder,
      );

  @override
  bool _matchesType(DartType type) => type.isDartCoreBool;
}

class _TypeHelperDateTime extends _TypeHelperWithHelper {
  const _TypeHelperDateTime();

  @override
  String helperName(DartType paramType) {
    if (paramType.isNullableType) {
      return 'DateTime.tryParse';
    }
    return 'DateTime.parse';
  }

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) =>
      _fieldWithEncoder(
        '$fieldName${type.ensureNotNull}.toString()',
        customEncoder,
      );

  @override
  bool _matchesType(DartType type) =>
      const TypeChecker.fromRuntime(DateTime).isAssignableFromType(type);
}

class _TypeHelperDouble extends _TypeHelperWithHelper {
  const _TypeHelperDouble();

  @override
  String helperName(DartType paramType) {
    if (paramType.isNullableType) {
      return 'double.tryParse';
    }
    return 'double.parse';
  }

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) =>
      _fieldWithEncoder(
        '$fieldName${type.ensureNotNull}.toString()',
        customEncoder,
      );

  @override
  bool _matchesType(DartType type) => type.isDartCoreDouble;
}

class _TypeHelperEnum extends _TypeHelperWithHelper {
  const _TypeHelperEnum();

  @override
  String helperName(DartType paramType) =>
      '${enumMapName(paramType as InterfaceType)}.$enumExtensionHelperName';

  @override
  String _encode(
    String fieldName,
    DartType type,
    String? customEncoder,
  ) => _fieldWithEncoder(
    '${enumMapName(type as InterfaceType)}[$fieldName${type.ensureNotNull}]',
    customEncoder,
  );

  @override
  bool _matchesType(DartType type) => type.isEnum;
}

/// A type helper for extension types.
/// Supported extension types are:
/// - [String]
/// - [int]
/// - [double]
/// - [num]
/// - [bool]
/// - [Enum]
/// - [BigInt]
/// - [DateTime]
/// - [Uri]
class _TypeHelperExtensionType extends _TypeHelper {
  const _TypeHelperExtensionType();

  @override
  String _decode(
    FormalParameterElement parameterElement,
    Set<String> pathParameters,
    String? customDecoder,
  ) {
    final DartType paramType = parameterElement.type;
    if (paramType.isNullableType && parameterElement.hasDefaultValue) {
      throw NullableDefaultValueError(parameterElement);
    }

    final String stateValue =
        'state.${_stateValueAccess(parameterElement, pathParameters)}';
    final String castType;
    if (paramType.isNullableType || parameterElement.hasDefaultValue) {
      castType = '$paramType${paramType.isNullableType ? '' : '?'}';
    } else {
      castType = '$paramType';
    }

    final DartType representationType = paramType.extensionTypeErasure;
    if (representationType.isDartCoreString) {
      return '$stateValue as $castType';
    }

    if (representationType.isEnum) {
      return '${enumMapName(representationType as InterfaceType)}'
          '.$enumExtensionHelperName($stateValue) as $castType';
    }

    final String representationTypeName = withoutNullability(
      representationType.getDisplayString(),
    );
    if (paramType.isNullableType || parameterElement.hasDefaultValue) {
      return "$representationTypeName.tryParse($stateValue ?? '') as $castType";
    } else {
      return '$representationTypeName.parse($stateValue) as $castType';
    }
  }

  @override
  String _encode(String fieldName, DartType type, String? customDecoder) {
    final DartType representationType = type.extensionTypeErasure;
    if (representationType.isDartCoreString) {
      return '$fieldName${type.ensureNotNull} as String';
    }

    if (representationType.isEnum) {
      return '${enumMapName(representationType as InterfaceType)}'
          '[$fieldName${type.ensureNotNull} as ${withoutNullability(representationType.getDisplayString())}]!';
    }

    return '$fieldName${representationType.ensureNotNull}.toString()';
  }

  @override
  bool _matchesType(DartType type) {
    final DartType representationType = type.extensionTypeErasure;
    if (type == representationType) {
      // `type` is not an extension type.
      return false;
    }

    return representationType.isDartCoreString ||
        representationType.isDartCoreInt ||
        representationType.isDartCoreDouble ||
        representationType.isDartCoreNum ||
        representationType.isDartCoreBool ||
        representationType.isEnum ||
        const TypeChecker.fromRuntime(
          BigInt,
        ).isAssignableFromType(representationType) ||
        const TypeChecker.fromRuntime(
          DateTime,
        ).isAssignableFromType(representationType) ||
        const TypeChecker.fromRuntime(
          Uri,
        ).isAssignableFromType(representationType);
  }
}

class _TypeHelperInt extends _TypeHelperWithHelper {
  const _TypeHelperInt();

  @override
  String helperName(DartType paramType) {
    if (paramType.isNullableType) {
      return 'int.tryParse';
    }
    return 'int.parse';
  }

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) =>
      _fieldWithEncoder(
        '$fieldName${type.ensureNotNull}.toString()',
        customEncoder,
      );

  @override
  bool _matchesType(DartType type) => type.isDartCoreInt;
}

class _TypeHelperNum extends _TypeHelperWithHelper {
  const _TypeHelperNum();

  @override
  String helperName(DartType paramType) {
    if (paramType.isNullableType) {
      return 'num.tryParse';
    }
    return 'num.parse';
  }

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) =>
      _fieldWithEncoder(
        '$fieldName${type.ensureNotNull}.toString()',
        customEncoder,
      );

  @override
  bool _matchesType(DartType type) => type.isDartCoreNum;
}

class _TypeHelperString extends _TypeHelper {
  const _TypeHelperString();

  @override
  String _decode(
    FormalParameterElement parameterElement,
    Set<String> pathParameters,
    String? customDecoder,
  ) => 'state.${_stateValueAccess(parameterElement, pathParameters)}';

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) =>
      _fieldWithEncoder(fieldName, customEncoder);

  @override
  bool _matchesType(DartType type) => type.isDartCoreString;
}

class _TypeHelperUri extends _TypeHelperWithHelper {
  const _TypeHelperUri();

  @override
  String helperName(DartType paramType) {
    if (paramType.isNullableType) {
      return 'Uri.tryParse';
    }
    return 'Uri.parse';
  }

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) =>
      _fieldWithEncoder(
        '$fieldName${type.ensureNotNull}.toString()',
        customEncoder,
      );

  @override
  bool _matchesType(DartType type) =>
      const TypeChecker.fromRuntime(Uri).isAssignableFromType(type);
}

class _TypeHelperIterable extends _TypeHelperWithHelper {
  const _TypeHelperIterable();

  @override
  String helperName(DartType paramType) => iterablesEqualHelperName;

  @override
  String _decode(
    FormalParameterElement parameterElement,
    Set<String> pathParameters,
    String? customDecoder,
  ) {
    if (parameterElement.type is ParameterizedType) {
      final DartType iterableType =
          (parameterElement.type as ParameterizedType).typeArguments.first;

      // get a type converter for values in iterable
      String entriesTypeDecoder = '(e) => e';
      String convertToNotNull = '';

      for (final _TypeHelper helper in _helpers) {
        if (helper._matchesType(iterableType) &&
            helper is _TypeHelperWithHelper) {
          if (!iterableType.isNullableType) {
            convertToNotNull = '.cast<$iterableType>()';
          }
          entriesTypeDecoder = helper.helperName(iterableType);
          if (customDecoder != null) {
            entriesTypeDecoder =
                '(e) => $entriesTypeDecoder($customDecoder(e))';
          }
        }
      }

      // get correct type for iterable
      String iterableCaster = '';
      String fallBack = '';
      if (const TypeChecker.fromRuntime(
        List,
      ).isAssignableFromType(parameterElement.type)) {
        iterableCaster += '.toList()';
        if (!parameterElement.type.isNullableType &&
            !parameterElement.hasDefaultValue) {
          fallBack = '?? const []';
        }
      } else if (const TypeChecker.fromRuntime(
        Set,
      ).isAssignableFromType(parameterElement.type)) {
        iterableCaster += '.toSet()';
        if (!parameterElement.type.isNullableType &&
            !parameterElement.hasDefaultValue) {
          fallBack = '?? const {}';
        }
      }

      return '''
state.uri.queryParametersAll[
        ${escapeDartString(parameterElement.displayName.kebab)}]
        ?.map($entriesTypeDecoder)$convertToNotNull$iterableCaster$fallBack''';
    }
    return '''
state.uri.queryParametersAll[${escapeDartString(parameterElement.displayName.kebab)}]''';
  }

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) {
    final String nullAwareAccess = type.isNullableType ? '?' : '';
    if (type is ParameterizedType) {
      final DartType iterableType = type.typeArguments.first;

      // get a type encoder for values in iterable
      String entriesTypeEncoder = '';
      for (final _TypeHelper helper in _helpers) {
        if (helper._matchesType(iterableType)) {
          entriesTypeEncoder = '''
$nullAwareAccess.map((e) => ${helper._encode('e', iterableType, customEncoder)}).toList()''';
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

  @override
  String _compare(String value1, String value2) =>
      '!$iterablesEqualHelperName($value1, $value2)';
}

class _TypeHelperJson extends _TypeHelperWithHelper {
  const _TypeHelperJson();

  @override
  String helperName(DartType paramType) {
    return _helperNameN(paramType, 0);
  }

  @override
  String _encode(String fieldName, DartType type, String? customEncoder) =>
      _fieldWithEncoder(
        'jsonEncode($fieldName${type.ensureNotNull}.toJson())',
        customEncoder,
      );

  @override
  bool _matchesType(DartType type) {
    if (type is! InterfaceType) {
      return false;
    }

    final MethodElement2? toJsonMethod = type.lookUpMethod3(
      'toJson',
      // ignore: experimental_member_use
      type.element3.library2,
    );
    if (toJsonMethod == null ||
        !toJsonMethod.isPublic ||
        toJsonMethod.formalParameters.isNotEmpty) {
      return false;
    }

    // test for template
    if (_isNestedTemplate(type)) {
      // check for deep compatibility
      return _matchesType(type.typeArguments.first);
    }

    // ignore: experimental_member_use
    final ConstructorElement2? fromJsonMethod = type.element3
        .getNamedConstructor2('fromJson');

    if (fromJsonMethod == null ||
        !fromJsonMethod.isPublic ||
        fromJsonMethod.formalParameters.length != 1 ||
        fromJsonMethod.formalParameters.first.type.getDisplayString(
              withNullability: false,
            ) !=
            'Map<String, dynamic>') {
      throw InvalidGenerationSourceError(
        'The parameter type '
        '`${type.getDisplayString(withNullability: false)}` not have a supported fromJson definition.',
        // ignore: experimental_member_use
        element: type.element3,
      );
    }

    return true;
  }

  String _helperNameN(DartType paramType, int index) {
    final String mainType = index == 0 ? 'String' : 'Object?';
    final String mainDecoder =
        index == 0
            ? 'jsonDecode(json$index) as Map<String, dynamic>'
            : 'json$index as Map<String, dynamic>';
    if (_isNestedTemplate(paramType as InterfaceType)) {
      return '''
($mainType json$index) {
  return ${jsonMapName(paramType)}.fromJson(
    $mainDecoder,
    ${_helperNameN(paramType.typeArguments.first, index + 1)},
  );
}''';
    }
    return '''
($mainType json$index) {
  return ${jsonMapName(paramType)}.fromJson($mainDecoder);
}''';
  }

  bool _isNestedTemplate(InterfaceType type) {
    // check if has fromJson constructor
    // ignore: experimental_member_use
    final ConstructorElement2? fromJsonMethod = type.element3
        .getNamedConstructor2('fromJson');
    if (fromJsonMethod == null || !fromJsonMethod.isPublic) {
      return false;
    }

    if (type.typeArguments.length != 1) {
      return false;
    }

    // check if fromJson method receive two parameters
    final List<FormalParameterElement> parameters =
        fromJsonMethod.formalParameters;
    if (parameters.length != 2) {
      return false;
    }

    final FormalParameterElement firstParam = parameters[0];
    if (firstParam.type.getDisplayString(withNullability: false) !=
        'Map<String, dynamic>') {
      throw InvalidGenerationSourceError(
        'The parameter type '
        '`${type.getDisplayString(withNullability: false)}` not have a supported fromJson definition.',
        // ignore: experimental_member_use
        element: type.element3,
      );
    }

    // Test for (T Function(Object? json)).
    final FormalParameterElement secondParam = parameters[1];
    if (secondParam.type is! FunctionType) {
      return false;
    }

    final FunctionType functionType = secondParam.type as FunctionType;
    if (functionType.parameters.length != 1 ||
        functionType.returnType.getDisplayString() !=
            type.element.typeParameters.first.getDisplayString() ||
        functionType.parameters[0].type.getDisplayString() != 'Object?') {
      throw InvalidGenerationSourceError(
        'The parameter type '
        '`${type.getDisplayString(withNullability: false)}` not have a supported fromJson definition.',
        // ignore: experimental_member_use
        element: type.element3,
      );
    }

    return true;
  }
}

abstract class _TypeHelperWithHelper extends _TypeHelper {
  const _TypeHelperWithHelper();

  String helperName(DartType paramType);

  @override
  String _decode(
    FormalParameterElement parameterElement,
    Set<String> pathParameters,
    String? customDecoder,
  ) {
    final DartType paramType = parameterElement.type;
    final String parameterName = parameterElement.displayName;

    if (!pathParameters.contains(parameterName) &&
        (paramType.isNullableType || parameterElement.hasDefaultValue)) {
      return '$convertMapValueHelperName('
          '${escapeDartString(parameterName.kebab)}, '
          'state.uri.queryParameters, '
          '${helperName(paramType)})';
    }
    final String nullableSuffix =
        paramType.isNullableType ||
                (paramType.isEnum && !paramType.isNullableType)
            ? '!'
            : '';

    final String decode = _fieldWithEncoder(
      'state.${_stateValueAccess(parameterElement, pathParameters)} ${!parameterElement.isRequired ? " ?? '' " : ''}',
      customDecoder,
    );
    return '${helperName(paramType)}($decode)$nullableSuffix';
  }
}

/// Extension helpers on [DartType].
extension DartTypeExtension on DartType {
  /// Convenient helper for nullability checks.parameterElement.isRequired
  String get ensureNotNull => isNullableType ? '!' : '';
}

/// Extension helpers on [FormalParameterElement].
extension FormalParameterElementExtension on FormalParameterElement {
  /// Convenient helper on top of [isRequiredPositional] and [isRequiredNamed].
  bool get isRequired => isRequiredPositional || isRequiredNamed;

  /// Returns `true` if `this` has a name that matches [extraFieldName];
  bool get isExtraField => displayName == extraFieldName;
}

/// An error thrown when a default value is used with a nullable type.
class NullableDefaultValueError extends InvalidGenerationSourceError {
  /// An error thrown when a default value is used with a nullable type.
  NullableDefaultValueError(Element2 element)
    : super(
        'Default value used with a nullable type. Only non-nullable type can have a default value.',
        todo: 'Remove the default value or make the type non-nullable.',
        element: element,
      );
}
