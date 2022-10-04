// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'route_config.dart';

/// A [Generator] for classes annotated with `TypedGoRoute`.
class GoRouterGenerator extends GeneratorForAnnotation<void> {
  /// Creates a new instance of [GoRouterGenerator].
  const GoRouterGenerator();

  @override
  TypeChecker get typeChecker => const TypeChecker.fromUrl(
        'package:go_router/src/route_data.dart#TypedGoRoute',
      );

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final Set<String> values = <String>{};

    final Set<String> getters = <String>{};

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

  @override
  InfoIterable generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'The @TypedGoRoute annotation can only be applied to classes.',
        element: element,
      );
    }

    if (!element.allSupertypes.any((InterfaceType element) =>
        _goRouteDataChecker.isExactlyType(element))) {
      throw InvalidGenerationSourceError(
        'The @TypedGoRoute annotation can only be applied to classes that '
        'extend or implement `GoRouteData`.',
        element: element,
      );
    }

    return RouteConfig.fromAnnotation(annotation, element).generateMembers();
  }
}

const TypeChecker _goRouteDataChecker = TypeChecker.fromUrl(
  'package:go_router/src/route_data.dart#GoRouteData',
);
