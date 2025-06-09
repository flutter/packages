// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'route_config.dart';
import 'type_helpers.dart';

const String _routeDataUrl = 'package:go_router/src/route_data.dart';

const Map<String, String> _annotations = <String, String>{
  'TypedGoRoute': 'GoRouteData',
  'TypedShellRoute': 'ShellRouteData',
  'TypedStatefulShellBranch': 'StatefulShellBranchData',
  'TypedStatefulShellRoute': 'StatefulShellRouteData',
};

/// A [Generator] for classes annotated with a typed go route annotation.
class GoRouterGenerator extends Generator {
  /// Creates a new instance of [GoRouterGenerator].
  const GoRouterGenerator();

  TypeChecker get _typeChecker => TypeChecker.any(
        _annotations.keys.map((String annotation) =>
            TypeChecker.fromUrl('$_routeDataUrl#$annotation')),
      );

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final Set<String> values = <String>{};
    final Set<String> getters = <String>{};

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
  void generateForAnnotation(
    LibraryReader library,
    Set<String> values,
    Set<String> getters,
  ) {
    for (final AnnotatedElement annotatedElement
        in library.annotatedWith(_typeChecker)) {
      final InfoIterable generatedValue = _generateForAnnotatedElement(
        annotatedElement.element,
        annotatedElement.annotation,
      );
      getters.add(generatedValue.routeGetterName);
      for (final String value in generatedValue) {
        assert(value.length == value.trim().length);
        values.add(value);
      }
    }
  }

  InfoIterable _generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
  ) {
    final String typedAnnotation =
        withoutNullability(annotation.objectValue.type!.getDisplayString());
    final String type =
        typedAnnotation.substring(0, typedAnnotation.indexOf('<'));
    final String routeData = _annotations[type]!;
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'The @$type annotation can only be applied to classes.',
        element: element,
      );
    }

    final TypeChecker dataChecker =
        TypeChecker.fromUrl('$_routeDataUrl#$routeData');
    if (!element.allSupertypes
        .any((InterfaceType element) => dataChecker.isExactlyType(element))) {
      throw InvalidGenerationSourceError(
        'The @$type annotation can only be applied to classes that '
        'extend or implement `$routeData`.',
        element: element,
      );
    }

    return RouteBaseConfig.fromAnnotation(annotation, element)
        .generateMembers();
  }
}
