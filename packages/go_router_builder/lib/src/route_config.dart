// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

import 'duplicate_path_severity.dart';
import 'path_utils.dart';
import 'type_helpers.dart';

/// Custom [Iterable] implementation with extra info.
class InfoIterable extends IterableBase<String> {
  InfoIterable._({required this.members, required this.routeGetterName});

  /// Name of the getter associated with `this`.
  final String routeGetterName;

  /// The generated elements associated with `this`.
  final List<String> members;

  @override
  Iterator<String> get iterator => members.iterator;
}

/// The configuration to generate class declarations for a ShellRouteData.
class ShellRouteConfig extends RouteBaseConfig {
  ShellRouteConfig._({
    required this.navigatorKey,
    required this.parentNavigatorKey,
    required super.routeDataClass,
    required this.observers,
    required super.parent,
    required this.restorationScopeId,
  }) : super._();

  /// The command for calling the navigator key getter from the ShellRouteData.
  final String? navigatorKey;

  /// The parent navigator key.
  final String? parentNavigatorKey;

  /// The navigator observers.
  final String? observers;

  /// The restoration scope id.
  final String? restorationScopeId;

  @override
  Iterable<String> classDeclarations() {
    if (routeDataClass.unnamedConstructor == null) {
      throw InvalidGenerationSourceError(
        'The ShellRouteData "$_className" class must have an unnamed constructor.',
        element: routeDataClass,
      );
    }

    final bool isConst = routeDataClass.unnamedConstructor!.isConst;

    return <String>[
      '''
  extension $_extensionName on $_className {
  static $_className _fromState(GoRouterState state) =>${isConst ? ' const' : ''} $_className();
  }
  ''',
    ];
  }

  @override
  String get routeConstructorParameters =>
      '${navigatorKey == null ? '' : 'navigatorKey: $navigatorKey,'}'
      '${parentNavigatorKey == null ? '' : 'parentNavigatorKey: $parentNavigatorKey,'}'
      '${observers == null ? '' : 'observers: $observers,'}'
      '${restorationScopeId == null ? '' : 'restorationScopeId: $restorationScopeId,'}';

  @override
  String get factorConstructorParameters => 'factory: $_extensionName._fromState,';

  @override
  String get routeDataClassName => 'ShellRouteData';

  @override
  String get dataConvertionFunctionName => r'$route';
}

/// The configuration to generate class declarations for a StatefulShellRouteData.
class StatefulShellRouteConfig extends RouteBaseConfig {
  StatefulShellRouteConfig._({
    required this.parentNavigatorKey,
    required super.routeDataClass,
    required super.parent,
    required this.navigatorContainerBuilder,
    required this.restorationScopeId,
  }) : super._();

  /// The parent navigator key.
  final String? parentNavigatorKey;

  /// The navigator container builder.
  final String? navigatorContainerBuilder;

  /// The restoration scope id.
  final String? restorationScopeId;

  @override
  Iterable<String> classDeclarations() => <String>[
    '''
extension $_extensionName on $_className {
  static $_className _fromState(GoRouterState state) =>${routeDataClass.unnamedConstructor!.isConst ? ' const' : ''}   $_className();
}
''',
  ];

  @override
  String get routeConstructorParameters =>
      '${parentNavigatorKey == null ? '' : 'parentNavigatorKey: $parentNavigatorKey,'}'
      '${restorationScopeId == null ? '' : 'restorationScopeId: $restorationScopeId,'}'
      '${navigatorContainerBuilder == null ? '' : 'navigatorContainerBuilder: $navigatorContainerBuilder,'}';

  @override
  String get factorConstructorParameters => 'factory: $_extensionName._fromState,';

  @override
  String get routeDataClassName => 'StatefulShellRouteData';

  @override
  String get dataConvertionFunctionName => r'$route';
}

/// The configuration to generate class declarations for a StatefulShellBranchData.
class StatefulShellBranchConfig extends RouteBaseConfig {
  StatefulShellBranchConfig._({
    required this.navigatorKey,
    required super.routeDataClass,
    required super.parent,
    required this.observers,
    this.restorationScopeId,
    this.initialLocation,
    this.preload,
  }) : super._();

  /// The command for calling the navigator key getter from the ShellRouteData.
  final String? navigatorKey;

  /// The restoration scope id.
  final String? restorationScopeId;

  /// The initial route.
  final String? initialLocation;

  /// The navigator observers.
  final String? observers;

  /// The preload parameter.
  final String? preload;

  @override
  Iterable<String> classDeclarations() => <String>[];

  @override
  String get factorConstructorParameters => '';

  @override
  String get routeConstructorParameters =>
      '${navigatorKey == null ? '' : 'navigatorKey: $navigatorKey,'}'
      '${restorationScopeId == null ? '' : 'restorationScopeId: $restorationScopeId,'}'
      '${initialLocation == null ? '' : 'initialLocation: $initialLocation,'}'
      '${observers == null ? '' : 'observers: $observers,'}'
      '${preload == null ? '' : 'preload: $preload,'}';

  @override
  String get routeDataClassName => 'StatefulShellBranchData';

  @override
  String get dataConvertionFunctionName => r'$branch';
}

/// A mixin that provides common functionality for GoRoute-based configurations.
mixin _GoRouteMixin on RouteBaseConfig {
  String get _basePathForLocation;

  /// The path this route contributes to the URL, without any parent path.
  ///
  /// This is the path exactly as written in the annotation.
  String get path;

  /// Whether this route only matches a URL that matches its path's casing.
  bool get caseSensitive;

  /// The path this route matches, joined with the paths of its ancestors.
  ///
  /// Shell routes and branches contribute nothing, since they own no path, so
  /// this is the URL pattern the route resolves to at runtime. Two routes with
  /// the same pattern compete for the same URL no matter where they sit in the
  /// tree, which is what [reportDuplicateRoutePaths] compares.
  ///
  /// [_basePathForLocation] cannot serve here, because a relative route
  /// deliberately reports only its own path.
  String get _joinedPath {
    final pathSegments = <String>[];

    RouteBaseConfig? config = this;
    while (config != null) {
      if (config case _GoRouteMixin(:final String path)) {
        pathSegments.add(path);
      }
      config = config.parent;
    }

    return p.url.joinAll(pathSegments.reversed);
  }

  late final Set<String> _pathParams = pathParametersFromPattern(_basePathForLocation);

  // construct path bits using parent bits
  // if there are any queryParam objects, add in the `queryParam` bits
  String get _locationArgs {
    final pathParameters = Map<String, String>.fromEntries(
      _pathParams.map((String pathParameter) {
        // Enum types are encoded using a map, so we need a nullability check
        // here to ensure it matches Uri.encodeComponent nullability
        final DartType? type = _field(pathParameter)?.returnType;

        final valueBuffer = StringBuffer();

        valueBuffer.write(r'${Uri.encodeComponent(');
        valueBuffer.write(_encodeFor(pathParameter));

        if (type?.isEnum ?? false) {
          valueBuffer.write('!');
        } else if (type?.isNullableType ?? false) {
          valueBuffer.write("?? ''");
        }

        valueBuffer.write(')}');

        return MapEntry<String, String>(pathParameter, valueBuffer.toString());
      }),
    );
    final String location = patternToPath(_basePathForLocation, pathParameters);
    return "'$location'";
  }

  /// The definition of the mixin to be generated.
  String get _mixinDefinition;

  FormalParameterElement? get _extraParam => _ctor.formalParameters.singleWhereOrNull(
    (FormalParameterElement element) => element.isExtraField,
  );

  String get _fromStateConstructor {
    final buffer = StringBuffer('=>');
    if (_ctor.isConst && _ctorParams.isEmpty && _ctorQueryParams.isEmpty && _extraParam == null) {
      buffer.writeln('const ');
    }

    buffer.writeln('$_className(');
    for (final param in <FormalParameterElement>[
      ..._ctorParams,
      ..._ctorQueryParams,
      if (_extraParam != null) _extraParam!,
    ]) {
      buffer.write(_decodeFor(param));
    }
    buffer.writeln(');');

    return buffer.toString();
  }

  String get _castedSelf {
    if (_pathParams.isEmpty && _ctorQueryParams.isEmpty && _extraParam == null) {
      return '';
    }

    return '\n$_className get $selfFieldName => this as $_className;\n';
  }

  String _decodeFor(FormalParameterElement element) {
    if (element.isRequired) {
      if (element.type.nullabilitySuffix == NullabilitySuffix.question &&
          _pathParams.contains(element.displayName)) {
        throw InvalidGenerationSourceError(
          'Required parameters in the path cannot be nullable.',
          element: element,
        );
      }
    }
    final List<ElementAnnotation>? metadata = _fieldMetadata(element.displayName);
    final String fromStateExpression = decodeParameter(element, _pathParams, metadata);

    if (element.isPositional) {
      return '$fromStateExpression,';
    }

    if (element.isNamed) {
      return '${element.displayName}: $fromStateExpression,';
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
        element: routeDataClass,
      );
    }

    final List<ElementAnnotation>? metadata = _fieldMetadata(fieldName);
    return encodeField(field, metadata);
  }

  String get _locationQueryParams {
    if (_ctorQueryParams.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('queryParams: {\n');

    for (final FormalParameterElement param in _ctorQueryParams) {
      final String parameterName = param.displayName;
      final conditions = <String>[];
      if (param.hasDefaultValue) {
        if (param.type.isNullableType) {
          throw NullableDefaultValueError(param);
        }
        conditions.add(compareField(param));
      } else if (param.type.isNullableType) {
        conditions.add('$selfFieldName.$parameterName != null');
      }
      var line = '';
      if (conditions.isNotEmpty) {
        line = 'if (${conditions.join(' && ')}) ';
      }
      line +=
          '${param.uriName}: '
          '${_encodeFor(parameterName)},';

      buffer.writeln(line);
    }

    buffer.writeln('},');

    return buffer.toString();
  }

  late final List<FormalParameterElement> _ctorParams = _ctor.formalParameters.where((
    FormalParameterElement element,
  ) {
    if (_pathParams.contains(element.displayName)) {
      return true;
    }
    return false;
  }).toList();

  late final List<FormalParameterElement> _ctorQueryParams = _ctor.formalParameters
      .where(
        (FormalParameterElement element) =>
            !_pathParams.contains(element.displayName) && !element.isExtraField,
      )
      .toList();

  ConstructorElement get _ctor {
    final ConstructorElement? ctor = routeDataClass.unnamedConstructor;

    if (ctor == null) {
      throw InvalidGenerationSourceError('Missing default constructor', element: routeDataClass);
    }
    return ctor;
  }

  @override
  Iterable<String> classDeclarations() => <String>[_mixinDefinition, ..._enumDeclarations()];

  /// Returns code representing the constant maps that contain the `enum` to
  /// [String] mapping for each referenced enum.
  Iterable<String> _enumDeclarations() {
    final enumParamTypes = <InterfaceType>{};

    for (final ctorParam in <FormalParameterElement>[..._ctorParams, ..._ctorQueryParams]) {
      DartType potentialEnumType = ctorParam.type;
      if (potentialEnumType is ParameterizedType &&
          (ctorParam.type as ParameterizedType).typeArguments.isNotEmpty) {
        potentialEnumType = (ctorParam.type as ParameterizedType).typeArguments.first;
      }

      if (potentialEnumType.isEnum) {
        enumParamTypes.add(potentialEnumType as InterfaceType);
      }

      // Support for enum extension types
      final DartType representedType = potentialEnumType.extensionTypeErasure;
      if (potentialEnumType != representedType && representedType.isEnum) {
        enumParamTypes.add(representedType as InterfaceType);
      }
    }
    return enumParamTypes.map<String>(_enumMapConst);
  }

  @override
  String get factorConstructorParameters => 'factory: $_mixinName._fromState,';

  @override
  String get dataConvertionFunctionName => r'$route';
}

/// The configuration to generate class declarations for a GoRouteData.
class GoRouteConfig extends RouteBaseConfig with _GoRouteMixin {
  GoRouteConfig._({
    required this.path,
    required this.name,
    required this.caseSensitive,
    required this.hasOverriddenOnExit,
    required this.parentNavigatorKey,
    required super.routeDataClass,
    required super.parent,
  }) : super._();

  /// The path of the GoRoute to be created by this configuration.
  @override
  final String path;

  /// The name of the GoRoute to be created by this configuration.
  final String? name;

  /// The case sensitivity of the GoRoute to be created by this configuration.
  @override
  final bool caseSensitive;

  /// Whether to enable the onExit callback for this route.
  ///
  /// When set to true, the route will include an onExit parameter in the
  /// generated GoRoute constructor, allowing you to implement custom logic
  /// when navigating away from this route.
  final bool hasOverriddenOnExit;

  /// The parent navigator key.
  final String? parentNavigatorKey;

  @override
  String get _basePathForLocation => _joinedPath;

  @override
  String get _mixinDefinition {
    final bool hasMixin =
        getNodeDeclaration<ClassDeclaration>(
          routeDataClass,
        )?.withClause?.mixinTypes.any((NamedType e) => e.name.toString() == _mixinName) ??
        false;

    if (!hasMixin) {
      throw InvalidGenerationSourceError(
        'Missing mixin clause `with $_mixinName`',
        element: routeDataClass,
      );
    }

    return '''
mixin $_mixinName on $routeDataClassName {
  static $_className _fromState(GoRouterState state) $_fromStateConstructor
  $_castedSelf
  @override
  String get location => GoRouteData.\$location($_locationArgs,$_locationQueryParams);

  @override
  void go(BuildContext context) =>
      context.go(location${_extraParam != null ? ', extra: $selfFieldName.$extraFieldName' : ''});

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location${_extraParam != null ? ', extra: $selfFieldName.$extraFieldName' : ''});

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location${_extraParam != null ? ', extra: $selfFieldName.$extraFieldName' : ''});

  @override
  void replace(BuildContext context) =>
      context.replace(location${_extraParam != null ? ', extra: $selfFieldName.$extraFieldName' : ''});
}
''';
  }

  @override
  String get routeConstructorParameters =>
      'path: ${escapeDartString(path)},'
      '${name != null ? 'name: ${escapeDartString(name!)},' : ''}'
      '${caseSensitive ? '' : 'caseSensitive: $caseSensitive,'}'
      '${'hasOverriddenOnExit: $hasOverriddenOnExit,'}'
      '${parentNavigatorKey == null ? '' : 'parentNavigatorKey: $parentNavigatorKey,'}';

  @override
  String get routeDataClassName => 'GoRouteData';
}

/// The configuration to generate class declarations for a RelativeGoRouteData.
class RelativeGoRouteConfig extends RouteBaseConfig with _GoRouteMixin {
  RelativeGoRouteConfig._({
    required this.path,
    required this.caseSensitive,
    required this.hasOverriddenOnExit,
    required this.parentNavigatorKey,
    required super.routeDataClass,
    required super.parent,
  }) : super._();

  /// The path of the GoRoute to be created by this configuration.
  @override
  final String path;

  /// The case sensitivity of the GoRoute to be created by this configuration.
  @override
  final bool caseSensitive;

  /// Whether to enable the onExit callback for this route.
  ///
  /// When set to true, the route will include an onExit parameter in the
  /// generated GoRoute constructor, allowing you to implement custom logic
  /// when navigating away from this route.
  final bool hasOverriddenOnExit;

  /// The parent navigator key.
  final String? parentNavigatorKey;

  @override
  String get _basePathForLocation => path;

  @override
  String get _mixinDefinition {
    final bool hasMixin =
        getNodeDeclaration<ClassDeclaration>(
          routeDataClass,
        )?.withClause?.mixinTypes.any((NamedType e) => e.name.toString() == _mixinName) ??
        false;

    if (!hasMixin) {
      throw InvalidGenerationSourceError(
        'Missing mixin clause `with $_mixinName`',
        element: routeDataClass,
      );
    }

    return '''
mixin $_mixinName on $routeDataClassName {
  static $_className _fromState(GoRouterState state) $_fromStateConstructor
  $_castedSelf
  @override
  String get subLocation => RelativeGoRouteData.\$location($_locationArgs,$_locationQueryParams);

  @override
  String get relativeLocation => './\$subLocation';

  @override
  void goRelative(BuildContext context) =>
      context.go(relativeLocation${_extraParam != null ? ', extra: $selfFieldName.$extraFieldName' : ''});

  @override
  Future<T?> pushRelative<T>(BuildContext context) =>
      context.push<T>(relativeLocation${_extraParam != null ? ', extra: $selfFieldName.$extraFieldName' : ''});

  @override
  void pushReplacementRelative(BuildContext context) =>
      context.pushReplacement(relativeLocation${_extraParam != null ? ', extra: $selfFieldName.$extraFieldName' : ''});

  @override
  void replaceRelative(BuildContext context) =>
      context.replace(relativeLocation${_extraParam != null ? ', extra: $selfFieldName.$extraFieldName' : ''});
}
''';
  }

  @override
  String get routeConstructorParameters =>
      'path: ${escapeDartString(path)},'
      '${caseSensitive ? '' : 'caseSensitive: $caseSensitive,'}'
      '${'hasOverriddenOnExit: $hasOverriddenOnExit,'}'
      '${parentNavigatorKey == null ? '' : 'parentNavigatorKey: $parentNavigatorKey,'}';

  @override
  String get routeDataClassName => 'RelativeGoRouteData';
}

/// Represents a `TypedGoRoute` annotation to the builder.
abstract class RouteBaseConfig {
  RouteBaseConfig._({required this.routeDataClass, required this.parent});

  /// Creates a new [RouteBaseConfig] represented the annotation data in [reader].
  factory RouteBaseConfig.fromAnnotation(ConstantReader reader, InterfaceElement element) {
    final definition = RouteBaseConfig._fromAnnotation(reader, element, null);

    if (element != definition.routeDataClass) {
      throw InvalidGenerationSourceError(
        'The @TypedGoRoute annotation must have a type parameter that matches '
        'the annotated element.',
        element: element,
      );
    }

    return definition;
  }

  factory RouteBaseConfig._fromAnnotation(
    ConstantReader reader,
    InterfaceElement element,
    RouteBaseConfig? parent, {
    bool isAncestorRelative = false,
  }) {
    assert(!reader.isNull, 'reader should not be null');
    final type = reader.objectValue.type! as InterfaceType;
    final String typeName = type.element.displayName;

    if (isAncestorRelative && typeName == 'TypedGoRoute') {
      throw InvalidGenerationSourceError(
        'TypedRelativeGoRoute cannot have a TypedGoRoute descendant.',
        element: element,
      );
    }

    final bool isRelative = isAncestorRelative || typeName == 'TypedRelativeGoRoute';

    final DartType typeParamType = type.typeArguments.single;
    if (typeParamType is! InterfaceType) {
      throw InvalidGenerationSourceError(
        'The type parameter on one of the @TypedGoRoute declarations could not '
        'be parsed.',
        element: element,
      );
    }

    // TODO(kevmoo): validate that this MUST be a subtype of `GoRouteData`
    final InterfaceElement classElement = typeParamType.element;

    final RouteBaseConfig value;
    switch (typeName) {
      case 'TypedShellRoute':
        value = ShellRouteConfig._(
          routeDataClass: classElement,
          parent: parent,
          navigatorKey: _generateParameterGetterCode(classElement, parameterName: r'$navigatorKey'),
          parentNavigatorKey: _generateParameterGetterCode(
            classElement,
            parameterName: r'$parentNavigatorKey',
          ),
          observers: _generateParameterGetterCode(classElement, parameterName: r'$observers'),
          restorationScopeId: _generateParameterGetterCode(
            classElement,
            parameterName: r'$restorationScopeId',
          ),
        );
      case 'TypedStatefulShellRoute':
        value = StatefulShellRouteConfig._(
          routeDataClass: classElement,
          parent: parent,
          parentNavigatorKey: _generateParameterGetterCode(
            classElement,
            parameterName: r'$parentNavigatorKey',
          ),
          restorationScopeId: _generateParameterGetterCode(
            classElement,
            parameterName: r'$restorationScopeId',
          ),
          navigatorContainerBuilder: _generateParameterGetterCode(
            classElement,
            parameterName: r'$navigatorContainerBuilder',
          ),
        );
      case 'TypedStatefulShellBranch':
        value = StatefulShellBranchConfig._(
          routeDataClass: classElement,
          parent: parent,
          navigatorKey: _generateParameterGetterCode(classElement, parameterName: r'$navigatorKey'),
          restorationScopeId: _generateParameterGetterCode(
            classElement,
            parameterName: r'$restorationScopeId',
          ),
          initialLocation: _generateParameterGetterCode(
            classElement,
            parameterName: r'$initialLocation',
          ),
          observers: _generateParameterGetterCode(classElement, parameterName: r'$observers'),
          preload: _generateParameterGetterCode(classElement, parameterName: r'$preload'),
        );
      case 'TypedGoRoute':
        final ConstantReader pathValue = reader.read('path');
        if (pathValue.isNull) {
          throw InvalidGenerationSourceError(
            'Missing `path` value on annotation.',
            element: element,
          );
        }
        final ConstantReader nameValue = reader.read('name');
        final ConstantReader caseSensitiveValue = reader.read('caseSensitive');
        final bool hasOverriddenOnExit = classElement.methods.any(
          (method) => method.name == 'onExit',
        );
        value = GoRouteConfig._(
          path: pathValue.stringValue,
          name: nameValue.isNull ? null : nameValue.stringValue,
          caseSensitive: caseSensitiveValue.boolValue,
          hasOverriddenOnExit: hasOverriddenOnExit,
          routeDataClass: classElement,
          parent: parent,
          parentNavigatorKey: _generateParameterGetterCode(
            classElement,
            parameterName: r'$parentNavigatorKey',
          ),
        );
      case 'TypedRelativeGoRoute':
        final ConstantReader pathValue = reader.read('path');
        if (pathValue.isNull) {
          throw InvalidGenerationSourceError(
            'Missing `path` value on annotation.',
            element: element,
          );
        }
        final String pathString = pathValue.stringValue;
        if (pathString.startsWith('/')) {
          throw InvalidGenerationSourceError(
            'The path for a TypedRelativeGoRoute cannot start with "/".',
            element: element,
          );
        }
        final ConstantReader caseSensitiveValue = reader.read('caseSensitive');
        final bool hasOverriddenOnExit = classElement.methods.any(
          (method) => method.name == 'onExit',
        );
        value = RelativeGoRouteConfig._(
          path: pathValue.stringValue,
          caseSensitive: caseSensitiveValue.boolValue,
          hasOverriddenOnExit: hasOverriddenOnExit,
          routeDataClass: classElement,
          parent: parent,
          parentNavigatorKey: _generateParameterGetterCode(
            classElement,
            parameterName: r'$parentNavigatorKey',
          ),
        );
      default:
        throw UnsupportedError('Unrecognized type $typeName');
    }

    value._children.addAll(
      reader
          .read(_generateChildrenGetterName(typeName))
          .listValue
          .map<RouteBaseConfig>(
            (DartObject e) => RouteBaseConfig._fromAnnotation(
              ConstantReader(e),
              element,
              value,
              isAncestorRelative: isRelative,
            ),
          ),
    );

    return value;
  }

  final List<RouteBaseConfig> _children = <RouteBaseConfig>[];

  /// The `RouteData` class this class represents.
  final InterfaceElement routeDataClass;

  /// The parent of this route config.
  final RouteBaseConfig? parent;

  static String _generateChildrenGetterName(String name) {
    return (name == 'TypedStatefulShellRoute' || name == 'StatefulShellRouteData')
        ? 'branches'
        : 'routes';
  }

  static String? _generateParameterGetterCode(
    InterfaceElement classElement, {
    required String parameterName,
  }) {
    final String? fieldDisplayName = classElement.fields
        .where((FieldElement element) {
          if (!element.isStatic || element.displayName != parameterName) {
            return false;
          }
          if (parameterName.toLowerCase().contains(RegExp('navigatorKey | observers'))) {
            final DartType type = element.type;
            if (type is! ParameterizedType) {
              return false;
            }
            final List<DartType> typeArguments = type.typeArguments;
            if (typeArguments.length != 1) {
              return false;
            }
            final DartType typeArgument = typeArguments.single;
            if (withoutNullability(typeArgument.getDisplayString()) != 'NavigatorState') {
              return false;
            }
          }
          return true;
        })
        .map<String>((FieldElement e) => e.displayName)
        .firstOrNull;

    if (fieldDisplayName != null) {
      return '${classElement.displayName}.$fieldDisplayName';
    }
    final String? methodDisplayName = classElement.methods
        .where((MethodElement element) {
          return element.isStatic && element.displayName == parameterName;
        })
        .map<String>((MethodElement e) => e.displayName)
        .firstOrNull;

    if (methodDisplayName != null) {
      return '${classElement.displayName}.$methodDisplayName';
    }
    return null;
  }

  /// Generates all of the members that correspond to `this`.
  InfoIterable generateMembers() =>
      InfoIterable._(members: _generateMembers().toList(), routeGetterName: _routeGetterName);

  Iterable<String> _generateMembers() sync* {
    final items = <String>[_rootDefinition()];

    for (final RouteBaseConfig def in _flatten()) {
      items.addAll(def.classDeclarations());
    }

    yield* items;

    yield* items
        .expand(
          (String e) => helperNames.entries
              .where((MapEntry<String, String> element) => e.contains(element.key))
              .map((MapEntry<String, String> e) => e.value),
        )
        .toSet();
  }

  /// Returns this [GoRouteConfig] and all child [GoRouteConfig] instances.
  Iterable<RouteBaseConfig> _flatten() sync* {
    yield this;
    for (final RouteBaseConfig child in _children) {
      yield* child._flatten();
    }
  }

  late final String _routeGetterName =
      r'$' + _className.substring(0, 1).toLowerCase() + _className.substring(1);

  /// Returns the `GoRoute` code for the annotated class.
  String _rootDefinition() =>
      '''
RouteBase get $_routeGetterName => ${_invokesRouteConstructor()};
''';

  String get _className => routeDataClass.displayName;

  String get _mixinName => '\$$_className';

  String get _extensionName => '\$${_className}Extension';

  String _invokesRouteConstructor() {
    final routesBit = _children.isEmpty
        ? ''
        : '''
${_generateChildrenGetterName(routeDataClassName)}: [${_children.map((RouteBaseConfig e) => '${e._invokesRouteConstructor()},').join()}],
''';

    return '''
$routeDataClassName.$dataConvertionFunctionName(
    $routeConstructorParameters $factorConstructorParameters $routesBit)
''';
  }

  PropertyAccessorElement? _field(String name) => routeDataClass.getGetter(name);

  List<ElementAnnotation>? _fieldMetadata(String name) => routeDataClass.fields
      .firstWhereOrNull((FieldElement element) => element.displayName == name)
      ?.metadata
      .annotations;

  /// The name of `RouteData` subclass this configuration represents.
  @protected
  String get routeDataClassName;

  /// The function name of `RouteData` to get Routes or branches.
  @protected
  String get dataConvertionFunctionName;

  /// Additional factory constructor.
  @protected
  String get factorConstructorParameters;

  /// Additional constructor parameter for invoking route constructor.
  @protected
  String get routeConstructorParameters;

  /// Returns all class declarations code.
  @protected
  Iterable<String> classDeclarations();
}

String _enumMapConst(InterfaceType type) {
  assert(type.isEnum);

  final String enumName = type.element.displayName;

  final buffer = StringBuffer('const ${enumMapName(type)} = {');

  for (final FieldElement enumField in type.element.fields.where(
    (FieldElement element) => element.isEnumConstant,
  )) {
    buffer.writeln(
      '$enumName.${enumField.displayName}: ${escapeDartString(enumField.displayName.kebab)},',
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
  iterablesEqualHelperName: _iterableEqualsHelper,
};

const String _convertMapValueHelper =
    '''
T? $convertMapValueHelperName<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}
''';

const String _boolConverterHelper =
    '''
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

const String _enumConverterHelper =
    '''
extension<T extends Enum> on Map<T, String> {
  T? $enumExtensionHelperName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}''';

const String _iterableEqualsHelper =
    '''
bool $iterablesEqualHelperName<T>(Iterable<T>? iterable1, Iterable<T>? iterable2) {
  if (identical(iterable1, iterable2)) return true;
  if (iterable1 == null || iterable2 == null) return false;
  final iterator1 = iterable1.iterator;
  final iterator2 = iterable2.iterator;
  while (true) {
    final hasNext1 = iterator1.moveNext();
    final hasNext2 = iterator2.moveNext();
    if (hasNext1 != hasNext2) return false;
    if (!hasNext1) return true;
    if (iterator1.current != iterator2.current) return false;
  }
}''';

/// Reports routes that resolve to the same URL pattern, with the severity
/// selected by the `duplicate_route_paths` builder option.
///
/// [roots] holds every top-level route config in a library, which is the widest
/// scope the builder can see, since it generates one library at a time.
///
/// Routes are compared by the whole URL pattern they resolve to, their
/// [_GoRouteMixin._joinedPath], rather than by the path each one declares. Two
/// routes at different depths can still land on one URL: a route nested as `a`
/// then `b` resolves to the same place as a route declared at `a/b`. Comparing
/// declared paths level by level misses that, and misses a collision between the
/// children of two declarations that themselves share a path.
///
/// `go_router` tries routes in declaration order and takes the first whose
/// pattern matches the whole URL, so of two routes sharing a pattern the later
/// can never be the match for it.
///
/// Parameter names are normalized, since `:id` and `:userId` match the same URL
/// segments. A route that is not case sensitive also shadows a later route whose
/// pattern differs from it only in casing.
void reportDuplicateRoutePaths(List<RouteBaseConfig> roots, DuplicatePathSeverity severity) {
  if (severity == DuplicatePathSeverity.ignore) {
    return;
  }

  final routes = <_GoRouteMixin>[];
  _collectRoutes(roots, routes);

  // Keyed by exact pattern, then again by folded pattern for the routes that
  // match any casing. Both keep their first entry, which is the route
  // `go_router` matches, because the walk above is in declaration order.
  final seen = <String, _GoRouteMixin>{};
  final seenIgnoringCase = <String, _GoRouteMixin>{};
  for (final route in routes) {
    final String pattern = normalizePathParameters(route._joinedPath);
    final String folded = pattern.toLowerCase();

    final _GoRouteMixin? existing = seen[pattern] ?? seenIgnoringCase[folded];
    if (existing != null) {
      final String message = _duplicatePathMessage(existing, route);
      if (severity == DuplicatePathSeverity.error) {
        throw InvalidGenerationSourceError(message, element: route.routeDataClass);
      }
      log.warning(message);
    }

    seen.putIfAbsent(pattern, () => route);
    if (!route.caseSensitive) {
      seenIgnoringCase.putIfAbsent(folded, () => route);
    }
  }
}

/// Describes the conflict between two routes that resolve to the same URL.
///
/// One route class declared twice at one URL gets its own wording, since naming
/// that class on both sides of an "and" reads as though two classes were
/// involved. Any other pair names both sides, which stays clear even when the
/// class repeats, because the two patterns differ.
String _duplicatePathMessage(_GoRouteMixin existing, _GoRouteMixin route) {
  final String existingPattern = existing._joinedPath;
  final String pattern = route._joinedPath;
  if (existing.routeDataClass == route.routeDataClass && existingPattern == pattern) {
    return 'Duplicate route path detected: ${route._className} is declared more '
        'than once at "$pattern".';
  }
  return 'Duplicate route path detected: '
      '"$existingPattern" from ${existing._className} and '
      '"$pattern" from ${route._className} '
      'both match the same URL pattern.';
}

/// Collects every route in the tree that resolves to a URL of its own, in
/// declaration order.
///
/// Shell routes and branches own no path, so they contribute nothing themselves,
/// but the routes inside them do and are collected all the same.
void _collectRoutes(List<RouteBaseConfig> children, List<_GoRouteMixin> result) {
  for (final child in children) {
    if (child is _GoRouteMixin) {
      result.add(child);
    }
    _collectRoutes(child._children, result);
  }
}
