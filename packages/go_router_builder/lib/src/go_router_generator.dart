// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'duplicate_path_severity.dart';
import 'route_config.dart';
import 'type_helpers.dart';

const String _routeDataUrl = 'package:go_router/src/route_data.dart';

const Map<String, String> _annotations = <String, String>{
  'TypedGoRoute': 'GoRouteData',
  'TypedRelativeGoRoute': 'RelativeGoRouteData',
  'TypedShellRoute': 'ShellRouteData',
  'TypedStatefulShellBranch': 'StatefulShellBranchData',
  'TypedStatefulShellRoute': 'StatefulShellRouteData',
};

/// A [Generator] for classes annotated with a typed go route annotation.
class GoRouterGenerator extends Generator {
  /// Creates a new instance of [GoRouterGenerator].
  const GoRouterGenerator({this.duplicatePathSeverity = DuplicatePathSeverity.warning});

  /// How sibling routes that resolve to the same URL pattern are reported.
  final DuplicatePathSeverity duplicatePathSeverity;

  TypeChecker get _typeChecker => TypeChecker.any(
    _annotations.keys.map((String annotation) => TypeChecker.fromUrl('$_routeDataUrl#$annotation')),
  );

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final values = <String>{};
    final getters = <String>{};

    generateForAnnotation(library, values, getters);

    if (values.isEmpty) {
      return '';
    }

    return <String>[
      '''
List<RouteBase> get \$appRoutes => [
${getters.map((String e) => "$e,").join('\n')}
    ];
''',
      ...values,
    ].join('\n\n');
  }

  /// Generates code for the `library` based on annotation.
  ///
  /// This public method is for testing purposes and should not be called
  /// directly.
  void generateForAnnotation(LibraryReader library, Set<String> values, Set<String> getters) {
    // Every annotation in the library contributes a top-level route to the
    // generated `$appRoutes`, so they all have to be built before their paths
    // can be compared against each other.
    final configs = <RouteBaseConfig>[];
    for (final AnnotatedElement annotatedElement in library.annotatedWith(_typeChecker)) {
      configs.add(
        _configForAnnotatedElement(annotatedElement.element, annotatedElement.annotation),
      );
    }

    reportDuplicateRoutePaths(configs, duplicatePathSeverity);

    for (final config in configs) {
      final InfoIterable generatedValue = config.generateMembers();
      getters.add(generatedValue.routeGetterName);
      values.addAll(generatedValue.members);
    }
  }

  RouteBaseConfig _configForAnnotatedElement(Element element, ConstantReader annotation) {
    final String typedAnnotation = withoutNullability(
      annotation.objectValue.type!.getDisplayString(),
    );
    final String type = typedAnnotation.substring(0, typedAnnotation.indexOf('<'));
    final String routeData = _annotations[type]!;
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'The @$type annotation can only be applied to classes.',
        element: element,
      );
    }

    final dataChecker = TypeChecker.fromUrl('$_routeDataUrl#$routeData');
    if (!element.allSupertypes.any((InterfaceType element) => dataChecker.isExactlyType(element))) {
      throw InvalidGenerationSourceError(
        'The @$type annotation can only be applied to classes that '
        'extend or implement `$routeData`.',
        element: element,
      );
    }

    return RouteBaseConfig.fromAnnotation(annotation, element);
  }
}
