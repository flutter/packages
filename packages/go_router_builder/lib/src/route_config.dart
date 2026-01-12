// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

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
    if (routeDataClass.unnamedConstructor2 == null) {
      throw InvalidGenerationSourceError(
        'The ShellRouteData "$_className" class must have an unnamed constructor.',
        element: routeDataClass,
      );
    }

    final bool isConst = routeDataClass.unnamedConstructor2!.isConst;

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
  String get factorConstructorParameters =>
      'factory: $_extensionName._fromState,';

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
  static $_className _fromState(GoRouterState state) =>${routeDataClass.unnamedConstructor2!.isConst ? ' const' : ''}   $_className();
}
''',
  ];

  @override
  String get routeConstructorParameters =>
      '${parentNavigatorKey == null ? '' : 'parentNavigatorKey: $parentNavigatorKey,'}'
      '${restorationScopeId == null ? '' : 'restorationScopeId: $restorationScopeId,'}'
      '${navigatorContainerBuilder == null ? '' : 'navigatorContainerBuilder: $navigatorContainerBuilder,'}';

  @override
  String get factorConstructorParameters =>
      'factory: $_extensionName._fromState,';

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

  late final Set<String> _pathParams = pathParametersFromPattern(
    _basePathForLocation,
  );

  // construct path bits using parent bits
  // if there are any queryParam objects, add in the `queryParam` bits
  String get _locationArgs {
    final Map<String, String> pathParameters = Map<String, String>.fromEntries(
      _pathParams.map((String pathParameter) {
        // Enum types are encoded using a map, so we need a nullability check
        // here to ensure it matches Uri.encodeComponent nullability
        final DartType? type = _field(pathParameter)?.returnType;

        final StringBuffer valueBuffer = StringBuffer();

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

  FormalParameterElement? get _extraParam =>
      _ctor.formalParameters.singleWhereOrNull(
        (FormalParameterElement element) => element.isExtraField,
      );

  String get _fromStateConstructor {
    final StringBuffer buffer = StringBuffer('=>');
    if (_ctor.isConst &&
        _ctorParams.isEmpty &&
        _ctorQueryParams.isEmpty &&
        _extraParam == null) {
      buffer.writeln('const ');
    }

    buffer.writeln('$_className(');
    for (final FormalParameterElement param in <FormalParameterElement>[
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
    if (_pathParams.isEmpty &&
        _ctorQueryParams.isEmpty &&
        _extraParam == null) {
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
    final List<ElementAnnotation>? metadata = _fieldMetadata(
      element.displayName,
    );
    final String fromStateExpression = decodeParameter(
      element,
      _pathParams,
      metadata,
    );

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
    final PropertyAccessorElement2? field = _field(fieldName);
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

    final StringBuffer buffer = StringBuffer('queryParams: {\n');

    for (final FormalParameterElement param in _ctorQueryParams) {
      final String parameterName = param.displayName;

      final List<String> conditions = <String>[];
      if (param.hasDefaultValue) {
        if (param.type.isNullableType) {
          throw NullableDefaultValueError(param);
        }
        conditions.add(
          compareField(param, parameterName, param.defaultValueCode!),
        );
      } else if (param.type.isNullableType) {
        conditions.add('$selfFieldName.$parameterName != null');
      }
      String line = '';
      if (conditions.isNotEmpty) {
        line = 'if (${conditions.join(' && ')}) ';
      }
      line +=
          '${escapeDartString(parameterName.kebab)}: '
          '${_encodeFor(parameterName)},';

      buffer.writeln(line);
    }

    buffer.writeln('},');

    return buffer.toString();
  }

  late final List<FormalParameterElement> _ctorParams =
      _ctor.formalParameters.where((FormalParameterElement element) {
        if (_pathParams.contains(element.displayName)) {
          return true;
        }
        return false;
      }).toList();

  late final List<FormalParameterElement> _ctorQueryParams =
      _ctor.formalParameters
          .where(
            (FormalParameterElement element) =>
                !_pathParams.contains(element.displayName) &&
                !element.isExtraField,
          )
          .toList();

  ConstructorElement2 get _ctor {
    final ConstructorElement2? ctor = routeDataClass.unnamedConstructor2;

    if (ctor == null) {
      throw InvalidGenerationSourceError(
        'Missing default constructor',
        element: routeDataClass,
      );
    }
    return ctor;
  }

  @override
  Iterable<String> classDeclarations() => <String>[
    _mixinDefinition,
    ..._enumDeclarations(),
  ];

  /// Returns code representing the constant maps that contain the `enum` to
  /// [String] mapping for each referenced enum.
  Iterable<String> _enumDeclarations() {
    final Set<InterfaceType> enumParamTypes = <InterfaceType>{};

    for (final FormalParameterElement ctorParam in <FormalParameterElement>[
      ..._ctorParams,
      ..._ctorQueryParams,
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
    required this.parentNavigatorKey,
    required super.routeDataClass,
    required super.parent,
  }) : super._();

  /// The path of the GoRoute to be created by this configuration.
  final String path;

  /// The name of the GoRoute to be created by this configuration.
  final String? name;

  /// The case sensitivity of the GoRoute to be created by this configuration.
  final bool caseSensitive;

  /// The parent navigator key.
  final String? parentNavigatorKey;

  String get _rawJoinedPath {
    final List<String> pathSegments = <String>[];

    RouteBaseConfig? config = this;
    while (config != null) {
      if (config
          case GoRouteConfig(:final String path) ||
              RelativeGoRouteConfig(:final String path)) {
        pathSegments.add(path);
      }
      config = config.parent;
    }

    return p.url.joinAll(pathSegments.reversed);
  }

  @override
  String get _basePathForLocation => _rawJoinedPath;

  @override
  String get _mixinDefinition {
    final bool hasMixin =
        getNodeDeclaration<ClassDeclaration>(routeDataClass)
            ?.withClause
            ?.mixinTypes
            .any((NamedType e) => e.name2.toString() == _mixinName) ??
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
      '${parentNavigatorKey == null ? '' : 'parentNavigatorKey: $parentNavigatorKey,'}';

  @override
  String get routeDataClassName => 'GoRouteData';
}

/// The configuration to generate class declarations for a RelativeGoRouteData.
class RelativeGoRouteConfig extends RouteBaseConfig with _GoRouteMixin {
  RelativeGoRouteConfig._({
    required this.path,
    required this.caseSensitive,
    required this.parentNavigatorKey,
    required super.routeDataClass,
    required super.parent,
  }) : super._();

  /// The path of the GoRoute to be created by this configuration.
  final String path;

  /// The case sensitivity of the GoRoute to be created by this configuration.
  final bool caseSensitive;

  /// The parent navigator key.
  final String? parentNavigatorKey;

  @override
  String get _basePathForLocation => path;

  @override
  String get _mixinDefinition {
    final bool hasMixin =
        getNodeDeclaration<ClassDeclaration>(routeDataClass)
            ?.withClause
            ?.mixinTypes
            .any((NamedType e) => e.name2.toString() == _mixinName) ??
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
      '${parentNavigatorKey == null ? '' : 'parentNavigatorKey: $parentNavigatorKey,'}';

  @override
  String get routeDataClassName => 'RelativeGoRouteData';
}

/// Represents a `TypedGoRoute` annotation to the builder.
abstract class RouteBaseConfig {
  RouteBaseConfig._({required this.routeDataClass, required this.parent});

  /// Creates a new [RouteBaseConfig] represented the annotation data in [reader].
  factory RouteBaseConfig.fromAnnotation(
    ConstantReader reader,
    InterfaceElement2 element,
  ) {
    final RouteBaseConfig definition = RouteBaseConfig._fromAnnotation(
      reader,
      element,
      null,
    );

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
    InterfaceElement2 element,
    RouteBaseConfig? parent, {
    bool isAncestorRelative = false,
  }) {
    assert(!reader.isNull, 'reader should not be null');
    final InterfaceType type = reader.objectValue.type! as InterfaceType;
    final String typeName = type.element.name;

    if (isAncestorRelative && typeName == 'TypedGoRoute') {
      throw InvalidGenerationSourceError(
        'TypedRelativeGoRoute cannot have a TypedGoRoute descendant.',
        element: element,
      );
    }

    final bool isRelative =
        isAncestorRelative || typeName == 'TypedRelativeGoRoute';

    final DartType typeParamType = type.typeArguments.single;
    if (typeParamType is! InterfaceType) {
      throw InvalidGenerationSourceError(
        'The type parameter on one of the @TypedGoRoute declarations could not '
        'be parsed.',
        element: element,
      );
    }

    // TODO(kevmoo): validate that this MUST be a subtype of `GoRouteData`
    // ignore: experimental_member_use
    final InterfaceElement2 classElement = typeParamType.element3;

    final RouteBaseConfig value;
    switch (typeName) {
      case 'TypedShellRoute':
        value = ShellRouteConfig._(
          routeDataClass: classElement,
          parent: parent,
          navigatorKey: _generateParameterGetterCode(
            classElement,
            parameterName: r'$navigatorKey',
          ),
          parentNavigatorKey: _generateParameterGetterCode(
            classElement,
            parameterName: r'$parentNavigatorKey',
          ),
          observers: _generateParameterGetterCode(
            classElement,
            parameterName: r'$observers',
          ),
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
          navigatorKey: _generateParameterGetterCode(
            classElement,
            parameterName: r'$navigatorKey',
          ),
          restorationScopeId: _generateParameterGetterCode(
            classElement,
            parameterName: r'$restorationScopeId',
          ),
          initialLocation: _generateParameterGetterCode(
            classElement,
            parameterName: r'$initialLocation',
          ),
          observers: _generateParameterGetterCode(
            classElement,
            parameterName: r'$observers',
          ),
          preload: _generateParameterGetterCode(
            classElement,
            parameterName: r'$preload',
          ),
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
        value = GoRouteConfig._(
          path: pathValue.stringValue,
          name: nameValue.isNull ? null : nameValue.stringValue,
          caseSensitive: caseSensitiveValue.boolValue,
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
        value = RelativeGoRouteConfig._(
          path: pathValue.stringValue,
          caseSensitive: caseSensitiveValue.boolValue,
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
  final InterfaceElement2 routeDataClass;

  /// The parent of this route config.
  final RouteBaseConfig? parent;

  static String _generateChildrenGetterName(String name) {
    return (name == 'TypedStatefulShellRoute' ||
            name == 'StatefulShellRouteData')
        ? 'branches'
        : 'routes';
  }

  static String? _generateParameterGetterCode(
    InterfaceElement2 classElement, {
    required String parameterName,
  }) {
    final String? fieldDisplayName =
        classElement.fields2
            .where((FieldElement2 element) {
              if (!element.isStatic || element.displayName != parameterName) {
                return false;
              }
              if (parameterName.toLowerCase().contains(
                RegExp('navigatorKey | observers'),
              )) {
                final DartType type = element.type;
                if (type is! ParameterizedType) {
                  return false;
                }
                final List<DartType> typeArguments = type.typeArguments;
                if (typeArguments.length != 1) {
                  return false;
                }
                final DartType typeArgument = typeArguments.single;
                if (withoutNullability(typeArgument.getDisplayString()) !=
                    'NavigatorState') {
                  return false;
                }
              }
              return true;
            })
            .map<String>((FieldElement2 e) => e.displayName)
            .firstOrNull;

    if (fieldDisplayName != null) {
      return '${classElement.displayName}.$fieldDisplayName';
    }
    final String? methodDisplayName =
        classElement.methods2
            .where((MethodElement2 element) {
              return element.isStatic && element.displayName == parameterName;
            })
            .map<String>((MethodElement2 e) => e.displayName)
            .firstOrNull;

    if (methodDisplayName != null) {
      return '${classElement.displayName}.$methodDisplayName';
    }
    return null;
  }

  /// Generates all of the members that correspond to `this`.
  InfoIterable generateMembers() => InfoIterable._(
    members: _generateMembers().toList(),
    routeGetterName: _routeGetterName,
  );

  Iterable<String> _generateMembers() sync* {
    final List<String> items = <String>[_rootDefinition()];

    for (final RouteBaseConfig def in _flatten()) {
      items.addAll(def.classDeclarations());
    }

    yield* items;

    yield* items
        .expand(
          (String e) => helperNames.entries
              .where(
                (MapEntry<String, String> element) => e.contains(element.key),
              )
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
  String _rootDefinition() => '''
RouteBase get $_routeGetterName => ${_invokesRouteConstructor()};
''';

  String get _className => routeDataClass.displayName;

  String get _mixinName => '\$$_className';

  String get _extensionName => '\$${_className}Extension';

  String _invokesRouteConstructor() {
    final String routesBit =
        _children.isEmpty
            ? ''
            : '''
${_generateChildrenGetterName(routeDataClassName)}: [${_children.map((RouteBaseConfig e) => '${e._invokesRouteConstructor()},').join()}],
''';

    return '''
$routeDataClassName.$dataConvertionFunctionName(
    $routeConstructorParameters $factorConstructorParameters $routesBit)
''';
  }

  PropertyAccessorElement2? _field(String name) =>
      routeDataClass.getGetter2(name);

  List<ElementAnnotation>? _fieldMetadata(String name) =>
      routeDataClass.fields2
          .firstWhereOrNull(
            (FieldElement2 element) => element.displayName == name,
          )
          ?.metadata2
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

  final String enumName = type.element.name;

  final StringBuffer buffer = StringBuffer('const ${enumMapName(type)} = {');

  // ignore: experimental_member_use
  for (final FieldElement2 enumField in type.element3.fields2.where(
    (FieldElement2 element) => element.isEnumConstant,
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

const String _convertMapValueHelper = '''
T? $convertMapValueHelperName<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
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
  T? $enumExtensionHelperName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}''';

const String _iterableEqualsHelper = '''
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
