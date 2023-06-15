// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import 'type_helpers.dart';

/// Custom [Iterable] implementation with extra info.
class InfoIterable extends IterableBase<String> {
  InfoIterable._({
    required this.members,
    required this.routeGetterName,
  });

  /// Name of the getter associated with `this`.
  final String routeGetterName;

  /// The generated elements associated with `this`.
  final List<String> members;

  @override
  Iterator<String> get iterator => members.iterator;
}

/// Represents a `TypedGoRoute` annotation to the builder.
class RouteConfig {
  RouteConfig._(
    this._path,
    this._name,
    this._routeDataClass,
    this._parent,
    this._key,
    this._isShellRoute,
  );

  /// Creates a new [RouteConfig] represented the annotation data in [reader].
  factory RouteConfig.fromAnnotation(
    ConstantReader reader,
    InterfaceElement element,
  ) {
    final RouteConfig definition =
        RouteConfig._fromAnnotation(reader, element, null);

    if (element != definition._routeDataClass) {
      throw InvalidGenerationSourceError(
        'The @TypedGoRoute annotation must have a type parameter that matches '
        'the annotated element.',
        element: element,
      );
    }

    return definition;
  }

  factory RouteConfig._fromAnnotation(
    ConstantReader reader,
    InterfaceElement element,
    RouteConfig? parent,
  ) {
    assert(!reader.isNull, 'reader should not be null');
    final InterfaceType type = reader.objectValue.type! as InterfaceType;
    // TODO(stuartmorgan): Remove this ignore once 'analyze' can be set to
    // 5.2+ (when Flutter 3.4+ is on stable).
    // ignore: deprecated_member_use
    final bool isShellRoute = type.element.name == 'TypedShellRoute';

    String? path;
    String? name;

    if (!isShellRoute) {
      final ConstantReader pathValue = reader.read('path');
      if (pathValue.isNull) {
        throw InvalidGenerationSourceError(
          'Missing `path` value on annotation.',
          element: element,
        );
      }
      path = pathValue.stringValue;

      final ConstantReader nameValue = reader.read('name');
      name = nameValue.isNull ? null : nameValue.stringValue;
    }

    final DartType typeParamType = type.typeArguments.single;
    if (typeParamType is! InterfaceType) {
      throw InvalidGenerationSourceError(
        'The type parameter on one of the @TypedGoRoute declarations could not '
        'be parsed.',
        element: element,
      );
    }

    // TODO(kevmoo): validate that this MUST be a subtype of `GoRouteData`
    // TODO(stuartmorgan): Remove this ignore once 'analyze' can be set to
    // 5.2+ (when Flutter 3.4+ is on stable).
    // ignore: deprecated_member_use
    final InterfaceElement classElement = typeParamType.element;

    final RouteConfig value = RouteConfig._(
      path ?? '',
      name,
      classElement,
      parent,
      _generateNavigatorKeyGetterCode(
        classElement,
        keyName: isShellRoute ? r'$navigatorKey' : r'$parentNavigatorKey',
      ),
      isShellRoute,
    );

    value._children.addAll(reader.read('routes').listValue.map((DartObject e) =>
        RouteConfig._fromAnnotation(ConstantReader(e), element, value)));

    return value;
  }

  final List<RouteConfig> _children = <RouteConfig>[];
  final String _path;
  final String? _name;
  final InterfaceElement _routeDataClass;
  final RouteConfig? _parent;
  final String? _key;
  final bool _isShellRoute;

  static String? _generateNavigatorKeyGetterCode(
    InterfaceElement classElement, {
    required String keyName,
  }) {
    final String? fieldDisplayName = classElement.fields
        .where((FieldElement element) {
          final DartType type = element.type;
          if (!element.isStatic ||
              element.name != keyName ||
              type is! ParameterizedType) {
            return false;
          }
          final List<DartType> typeArguments = type.typeArguments;
          if (typeArguments.length != 1) {
            return false;
          }
          final DartType typeArgument = typeArguments.single;
          if (typeArgument.getDisplayString(withNullability: false) ==
              'NavigatorState') {
            return true;
          }
          return false;
        })
        .map<String>((FieldElement e) => e.displayName)
        .firstOrNull;

    if (fieldDisplayName == null) {
      return null;
    }
    return '${classElement.name}.$fieldDisplayName';
  }

  /// Generates all of the members that correspond to `this`.
  InfoIterable generateMembers() => InfoIterable._(
        members: _generateMembers().toList(),
        routeGetterName: _routeGetterName,
      );

  Iterable<String> _generateMembers() sync* {
    final List<String> items = <String>[
      _rootDefinition(),
    ];

    for (final RouteConfig def in _flatten()) {
      items.add(def._extensionDefinition());
    }

    _enumDefinitions().forEach(items.add);

    yield* items;

    yield* items
        .expand(
          (String e) => helperNames.entries
              .where(
                  (MapEntry<String, String> element) => e.contains(element.key))
              .map((MapEntry<String, String> e) => e.value),
        )
        .toSet();
  }

  /// Returns `extension` code.
  String _extensionDefinition() {
    if (_isShellRoute) {
      return '''
extension $_extensionName on $_className {
  static $_className _fromState(GoRouterState state) $_newFromState
}
''';
    }
    return '''
extension $_extensionName on $_className {
  static $_className _fromState(GoRouterState state) $_newFromState

  String get location => GoRouteData.\$location($_locationArgs,$_locationQueryParams);

  void go(BuildContext context) =>
      context.go(location${_extraParam != null ? ', extra: $extraFieldName' : ''});

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location${_extraParam != null ? ', extra: $extraFieldName' : ''});

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location${_extraParam != null ? ', extra: $extraFieldName' : ''});

  void replace(BuildContext context) =>
      context.replace(location${_extraParam != null ? ', extra: $extraFieldName' : ''});
}
''';
  }

  /// Returns this [RouteConfig] and all child [RouteConfig] instances.
  Iterable<RouteConfig> _flatten() sync* {
    yield this;
    for (final RouteConfig child in _children) {
      yield* child._flatten();
    }
  }

  late final String _routeGetterName =
      r'$' + _className.substring(0, 1).toLowerCase() + _className.substring(1);

  /// Returns the `GoRoute` code for the annotated class.
  String _rootDefinition() => '''
RouteBase get $_routeGetterName => ${_routeDefinition()};
''';

  /// Returns code representing the constant maps that contain the `enum` to
  /// [String] mapping for each referenced enum.
  Iterable<String> _enumDefinitions() sync* {
    final Set<InterfaceType> enumParamTypes = <InterfaceType>{};

    for (final RouteConfig routeDef in _flatten()) {
      for (final ParameterElement ctorParam in <ParameterElement>[
        ...routeDef._ctorParams,
        ...routeDef._ctorQueryParams,
      ]) {
        DartType potentialEnumType = ctorParam.type;
        if (potentialEnumType is ParameterizedType &&
            (ctorParam.type as ParameterizedType).typeArguments.isNotEmpty) {
          potentialEnumType =
              (ctorParam.type as ParameterizedType).typeArguments.first;
        }

        if (potentialEnumType.isEnum) {
          enumParamTypes.add(potentialEnumType as InterfaceType);
        }
      }
    }

    for (final InterfaceType enumParamType in enumParamTypes) {
      yield _enumMapConst(enumParamType);
    }
  }

  ParameterElement? get _extraParam => _ctor.parameters
      .singleWhereOrNull((ParameterElement element) => element.isExtraField);

  String get _newFromState {
    final StringBuffer buffer = StringBuffer('=>');
    if (_ctor.isConst &&
        _ctorParams.isEmpty &&
        _ctorQueryParams.isEmpty &&
        _extraParam == null) {
      buffer.writeln('const ');
    }

    final ParameterElement? extraParam = _extraParam;

    buffer.writeln('$_className(');
    for (final ParameterElement param in <ParameterElement>[
      ..._ctorParams,
      ..._ctorQueryParams,
      if (extraParam != null) extraParam,
    ]) {
      buffer.write(_decodeFor(param));
    }
    buffer.writeln(');');

    return buffer.toString();
  }

  // construct path bits using parent bits
  // if there are any queryParam objects, add in the `queryParam` bits
  String get _locationArgs {
    final Iterable<String> pathItems = _parsedPath.map((Token e) {
      if (e is ParameterToken) {
        // Enum types are encoded using a map, so we need a nullability check
        // here to ensure it matches Uri.encodeComponent nullability
        final DartType? type = _field(e.name)?.returnType;
        return '\${Uri.encodeComponent(${_encodeFor(e.name)}${type?.isEnum ?? false ? '!' : ''})}';
      }
      if (e is PathToken) {
        return e.value;
      }
      throw UnsupportedError(
        '$likelyIssueMessage '
        'Token ($e) of type ${e.runtimeType} is not supported.',
      );
    });
    return "'${pathItems.join()}'";
  }

  late final Set<String> _pathParams = Set<String>.unmodifiable(_parsedPath
      .whereType<ParameterToken>()
      .map((ParameterToken e) => e.name));

  late final List<Token> _parsedPath =
      List<Token>.unmodifiable(parse(_rawJoinedPath));

  String get _rawJoinedPath {
    final List<String> pathSegments = <String>[];

    RouteConfig? config = this;
    while (config != null) {
      pathSegments.add(config._path);
      config = config._parent;
    }

    return p.url.joinAll(pathSegments.reversed);
  }

  String get _className => _routeDataClass.name;

  String get _extensionName => '\$${_className}Extension';

  String _routeDefinition() {
    final String routesBit = _children.isEmpty
        ? ''
        : '''
routes: [${_children.map((RouteConfig e) => '${e._routeDefinition()},').join()}],
''';
    final String navigatorKeyParameterName =
        _isShellRoute ? 'navigatorKey' : 'parentNavigatorKey';
    final String navigatorKey = _key == null || _key!.isEmpty
        ? ''
        : '$navigatorKeyParameterName: $_key,';
    if (_isShellRoute) {
      return '''
  ShellRouteData.\$route(
    factory: $_extensionName._fromState,
    $navigatorKey
    $routesBit
  )
''';
    }
    return '''
GoRouteData.\$route(
      path: ${escapeDartString(_path)},
      ${_name != null ? 'name: ${escapeDartString(_name!)},' : ''}
      factory: $_extensionName._fromState,
      $navigatorKey
      $routesBit
)
''';
  }

  String _decodeFor(ParameterElement element) {
    if (element.isRequired) {
      if (element.type.nullabilitySuffix == NullabilitySuffix.question &&
          _pathParams.contains(element.name)) {
        throw InvalidGenerationSourceError(
          'Required parameters in the path cannot be nullable.',
          element: element,
        );
      }
    }
    final String fromStateExpression = decodeParameter(element, _pathParams);

    if (element.isPositional) {
      return '$fromStateExpression,';
    }

    if (element.isNamed) {
      return '${element.name}: $fromStateExpression,';
    }

    throw InvalidGenerationSourceError(
      '$likelyIssueMessage (param not named or positional)',
      element: element,
    );
  }

  String _encodeFor(String fieldName) {
    final PropertyAccessorElement? field = _field(fieldName);
    if (field == null) {
      throw InvalidGenerationSourceError(
        'Could not find a field for the path parameter "$fieldName".',
        element: _routeDataClass,
      );
    }

    return encodeField(field);
  }

  String get _locationQueryParams {
    if (_ctorQueryParams.isEmpty) {
      return '';
    }

    final StringBuffer buffer = StringBuffer('queryParams: {\n');

    for (final ParameterElement param in _ctorQueryParams) {
      final String parameterName = param.name;

      final List<String> conditions = <String>[];
      if (param.hasDefaultValue) {
        if (param.type.isNullableType) {
          throw NullableDefaultValueError(param);
        }
        conditions.add('$parameterName != ${param.defaultValueCode!}');
      } else if (param.type.isNullableType) {
        conditions.add('$parameterName != null');
      }
      String line = '';
      if (conditions.isNotEmpty) {
        line = 'if (${conditions.join(' && ')}) ';
      }
      line += '${escapeDartString(parameterName.kebab)}: '
          '${_encodeFor(parameterName)},';

      buffer.writeln(line);
    }

    buffer.writeln('},');

    return buffer.toString();
  }

  late final List<ParameterElement> _ctorParams =
      _ctor.parameters.where((ParameterElement element) {
    if (_pathParams.contains(element.name)) {
      return true;
    }
    return false;
  }).toList();

  late final List<ParameterElement> _ctorQueryParams = _ctor.parameters
      .where((ParameterElement element) =>
          !_pathParams.contains(element.name) && !element.isExtraField)
      .toList();

  ConstructorElement get _ctor {
    final ConstructorElement? ctor = _routeDataClass.unnamedConstructor;

    if (ctor == null) {
      throw InvalidGenerationSourceError(
        'Missing default constructor',
        element: _routeDataClass,
      );
    }
    return ctor;
  }

  PropertyAccessorElement? _field(String name) =>
      _routeDataClass.getGetter(name);
}

String _enumMapConst(InterfaceType type) {
  assert(type.isEnum);

  // TODO(stuartmorgan): Remove this ignore once 'analyze' can be set to
  // 5.2+ (when Flutter 3.4+ is on stable).
  // ignore: deprecated_member_use
  final String enumName = type.element.name;

  final StringBuffer buffer = StringBuffer('const ${enumMapName(type)} = {');

  // TODO(stuartmorgan): Remove this ignore once 'analyze' can be set to
  // 5.2+ (when Flutter 3.4+ is on stable).
  // ignore: deprecated_member_use
  for (final FieldElement enumField in type.element.fields
      .where((FieldElement element) => element.isEnumConstant)) {
    buffer.writeln(
      '$enumName.${enumField.name}: ${escapeDartString(enumField.name.kebab)},',
    );
  }

  buffer.writeln('};');

  return buffer.toString();
}

/// [Map] from the name of a generated helper to its definition.
const Map<String, String> helperNames = <String, String>{
  convertMapValueHelperName: _convertMapValueHelper,
  boolConverterHelperName: _boolConverterHelper,
  enumExtensionHelperName: _enumConverterHelper,
};

const String _convertMapValueHelper = '''
T? $convertMapValueHelperName<T>(
  String key,
  Map<String, String> map,
  T Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}
''';

const String _boolConverterHelper = '''
bool $boolConverterHelperName(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "\$value" into a bool.');
  }
}
''';

const String _enumConverterHelper = '''
extension<T extends Enum> on Map<T, String> {
  T $enumExtensionHelperName(String value) =>
      entries.singleWhere((element) => element.value == value).key;
}''';
