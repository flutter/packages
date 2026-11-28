// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:go_router_builder/src/go_router_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  for (final routeType in <String>['GoRoute', 'RelativeGoRoute']) {
    for (final hasOnExit in <bool>[false, true]) {
      test('Preserves $routeType output with legacy helper and onExit: $hasOnExit', () async {
        final input = AssetId('test_package', 'lib/routes.dart');
        final LibraryElement library = await resolveSources<LibraryElement>(
          <String, String>{
            'go_router|lib/src/route_data.dart': _legacyRouteData,
            input.toString():
                '''
import 'package:go_router/src/route_data.dart';

mixin \$RedirectRoute {}

@Typed$routeType<RedirectRoute>(path: '${routeType == 'GoRoute' ? '/' : ''}redirect')
class RedirectRoute extends ${routeType}Data with \$RedirectRoute {
  String? redirect(dynamic context, dynamic state) => '/destination';
  ${hasOnExit ? 'bool onExit(dynamic context, dynamic state) => true;' : ''}
}
''',
          },
          (Resolver resolver) => resolver.libraryFor(input),
          readAllSourcesFromFilesystem: true,
        );
        final generated = <String>{};
        const GoRouterGenerator().generateForAnnotation(
          LibraryReader(library),
          generated,
          <String>{},
        );
        final String output = generated.join('\n');
        expect(output, contains('${routeType}Data.\$route('));
        expect(output, contains('hasOverriddenOnExit: $hasOnExit,'));
        expect(output, isNot(contains('redirectOnly:')));
      });
    }
  }
}

// The legacy generated-helper contract has no redirectOnly parameter.
const String _legacyRouteData = r'''
abstract class GoRouteData {
  const GoRouteData();
  static void $route({
    required String path,
    required dynamic Function(dynamic) factory,
    bool? hasOverriddenOnExit,
  }) {}
}

abstract class RelativeGoRouteData {
  const RelativeGoRouteData();
  static void $route({
    required String path,
    required dynamic Function(dynamic) factory,
    bool? hasOverriddenOnExit,
  }) {}
}

class TypedGoRoute<T extends GoRouteData> {
  const TypedGoRoute({required this.path, this.name, this.caseSensitive = true, this.routes = const []});
  final String path;
  final String? name;
  final bool caseSensitive;
  final List<dynamic> routes;
}

class TypedRelativeGoRoute<T extends RelativeGoRouteData> {
  const TypedRelativeGoRoute({required this.path, this.caseSensitive = true, this.routes = const []});
  final String path;
  final bool caseSensitive;
  final List<dynamic> routes;
}
''';
