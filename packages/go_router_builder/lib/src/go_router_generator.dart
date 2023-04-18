// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'route_config.dart';

const String _routeDataUrl = 'package:go_router/src/route_data.dart';

const Map<String, String> _annotations = <String, String>{
  'TypedGoRoute': 'GoRouteData',
  'TypedShellRoute': 'ShellRouteData',
};

/// A [Generator] for classes annotated with a typed go route annotation.
class GoRouterGenerator extends GeneratorForAnnotation<void> {
  /// Creates a new instance of [GoRouterGenerator].
  const GoRouterGenerator();

  @override
  TypeChecker get typeChecker => TypeChecker.any(
        _annotations.keys.map((String annotation) =>
            TypeChecker.fromUrl('$_routeDataUrl#$annotation')),
      );

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final Set<String> values = <String>{};
    final Set<String> getters = <String>{};

    for (final String annotation in _annotations.keys) {
      final TypeChecker typeChecker =
          TypeChecker.fromUrl('$_routeDataUrl#$annotation');
      _generateForAnnotation(library, typeChecker, buildStep, values, getters);
    }

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

  void _generateForAnnotation(
    LibraryReader library,
    TypeChecker typeChecker,
    BuildStep buildStep,
    Set<String> values,
    Set<String> getters,
  ) {
    for (final AnnotatedElement annotatedElement
        in library.annotatedWith(typeChecker)) {
      final InfoIterable generatedValue = generateForAnnotatedElement(
        annotatedElement.element,
        annotatedElement.annotation,
        buildStep,
      );
      getters.add(generatedValue.routeGetterName);
      for (final String value in generatedValue) {
        assert(value.length == value.trim().length);
        values.add(value);
      }
    }
  }

  @override
  InfoIterable generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final String typedAnnotation =
        annotation.objectValue.type!.getDisplayString(withNullability: false);
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

    return RouteConfig.fromAnnotation(annotation, element).generateMembers();
  }
}
