// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow('The @TypedGoRoute annotation can only be applied to classes.')
@TypedGoRoute(path: 'bob') // ignore: invalid_annotation_target
const int theAnswer = 42;

// This test should be removed: dart enforces the `required` keyword.
@ShouldThrow('Missing `path` value on annotation.')
// ignore:missing_required_argument
@TypedGoRoute()
class MissingPathValue extends GoRouteData {}

@ShouldThrow(
  'The @TypedGoRoute annotation can only be applied to classes that extend or '
  'implement `GoRouteData`.',
)
@TypedGoRoute(path: 'bob')
class AppliedToWrongClassType {}

@ShouldThrow(
  'The @TypedGoRoute annotation must have a type parameter that matches the '
  'annotated element.',
)
@TypedGoRoute(path: 'bob')
class MissingTypeAnnotation extends GoRouteData {}

@ShouldThrow(
  'Could not find a field for the path parameter "id".',
)
@TypedGoRoute<BadPathParam>(path: 'bob/:id')
class BadPathParam extends GoRouteData {}

@ShouldThrow(
  'The parameter type `Stopwatch` is not supported.',
)
@TypedGoRoute<UnsupportedType>(path: 'bob/:id')
class UnsupportedType extends GoRouteData {
  UnsupportedType({required this.id});
  final Stopwatch id;
}

@ShouldThrow(
  'Required parameters in the path cannot be nullable.',
)
@TypedGoRoute<NullableRequiredParamInPath>(path: 'bob/:id')
class NullableRequiredParamInPath extends GoRouteData {
  NullableRequiredParamInPath({required this.id});
  final int? id;
}

@ShouldGenerate(r'''
RouteBase get $nullableRequiredParamNotInPath => GoRouteData.$route(
      path: 'bob',
      factory: $NullableRequiredParamNotInPathExtension._fromState,
    );

extension $NullableRequiredParamNotInPathExtension
    on NullableRequiredParamNotInPath {
  static NullableRequiredParamNotInPath _fromState(GoRouterState state) =>
      NullableRequiredParamNotInPath(
        id: _$convertMapValue('id', state.queryParameters, int.parse),
      );

  String get location => GoRouteData.$location(
        'bob',
        queryParams: {
          if (id != null) 'id': id!.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}
''')
@TypedGoRoute<NullableRequiredParamNotInPath>(path: 'bob')
class NullableRequiredParamNotInPath extends GoRouteData {
  NullableRequiredParamNotInPath({required this.id});
  final int? id;
}

@ShouldGenerate(r'''
RouteBase get $nonNullableRequiredParamNotInPath => GoRouteData.$route(
      path: 'bob',
      factory: $NonNullableRequiredParamNotInPathExtension._fromState,
    );

extension $NonNullableRequiredParamNotInPathExtension
    on NonNullableRequiredParamNotInPath {
  static NonNullableRequiredParamNotInPath _fromState(GoRouterState state) =>
      NonNullableRequiredParamNotInPath(
        id: int.parse(state.queryParameters['id']!),
      );

  String get location => GoRouteData.$location(
        'bob',
        queryParams: {
          'id': id.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
''')
@TypedGoRoute<NonNullableRequiredParamNotInPath>(path: 'bob')
class NonNullableRequiredParamNotInPath extends GoRouteData {
  NonNullableRequiredParamNotInPath({required this.id});
  final int id;
}

@ShouldGenerate(r'''
RouteBase get $enumParam => GoRouteData.$route(
      path: '/:y',
      factory: $EnumParamExtension._fromState,
    );

extension $EnumParamExtension on EnumParam {
  static EnumParam _fromState(GoRouterState state) => EnumParam(
        y: _$EnumTestEnumMap._$fromName(state.pathParameters['y']!),
      );

  String get location => GoRouteData.$location(
        '/${Uri.encodeComponent(_$EnumTestEnumMap[y]!)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

const _$EnumTestEnumMap = {
  EnumTest.a: 'a',
  EnumTest.b: 'b',
  EnumTest.c: 'c',
};

extension<T extends Enum> on Map<T, String> {
  T _$fromName(String value) =>
      entries.singleWhere((element) => element.value == value).key;
}
''')
@TypedGoRoute<EnumParam>(path: '/:y')
class EnumParam extends GoRouteData {
  EnumParam({required this.y});
  final EnumTest y;
}

enum EnumTest {
  a(1),
  b(3),
  c(5);

  const EnumTest(this.x);
  final int x;
}

@ShouldGenerate(r'''
RouteBase get $defaultValueRoute => GoRouteData.$route(
      path: '/default-value-route',
      factory: $DefaultValueRouteExtension._fromState,
    );

extension $DefaultValueRouteExtension on DefaultValueRoute {
  static DefaultValueRoute _fromState(GoRouterState state) => DefaultValueRoute(
        param:
            _$convertMapValue('param', state.queryParameters, int.parse) ?? 0,
      );

  String get location => GoRouteData.$location(
        '/default-value-route',
        queryParams: {
          if (param != 0) 'param': param.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}
''')
@TypedGoRoute<DefaultValueRoute>(path: '/default-value-route')
class DefaultValueRoute extends GoRouteData {
  DefaultValueRoute({this.param = 0});
  final int param;
}

@ShouldGenerate(r'''
RouteBase get $extraValueRoute => GoRouteData.$route(
      path: '/default-value-route',
      factory: $ExtraValueRouteExtension._fromState,
    );

extension $ExtraValueRouteExtension on ExtraValueRoute {
  static ExtraValueRoute _fromState(GoRouterState state) => ExtraValueRoute(
        param:
            _$convertMapValue('param', state.queryParameters, int.parse) ?? 0,
        $extra: state.extra as int?,
      );

  String get location => GoRouteData.$location(
        '/default-value-route',
        queryParams: {
          if (param != 0) 'param': param.toString(),
        },
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}
''')
@TypedGoRoute<ExtraValueRoute>(path: '/default-value-route')
class ExtraValueRoute extends GoRouteData {
  ExtraValueRoute({this.param = 0, this.$extra});
  final int param;
  final int? $extra;
}

@ShouldGenerate(r'''
RouteBase get $requiredExtraValueRoute => GoRouteData.$route(
      path: '/default-value-route',
      factory: $RequiredExtraValueRouteExtension._fromState,
    );

extension $RequiredExtraValueRouteExtension on RequiredExtraValueRoute {
  static RequiredExtraValueRoute _fromState(GoRouterState state) =>
      RequiredExtraValueRoute(
        $extra: state.extra as int,
      );

  String get location => GoRouteData.$location(
        '/default-value-route',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}
''')
@TypedGoRoute<RequiredExtraValueRoute>(path: '/default-value-route')
class RequiredExtraValueRoute extends GoRouteData {
  RequiredExtraValueRoute({required this.$extra});
  final int $extra;
}

@ShouldThrow(
  'Default value used with a nullable type. Only non-nullable type can have a default value.',
  todo: 'Remove the default value or make the type non-nullable.',
)
@TypedGoRoute<NullableDefaultValueRoute>(path: '/nullable-default-value-route')
class NullableDefaultValueRoute extends GoRouteData {
  NullableDefaultValueRoute({this.param = 0});
  final int? param;
}

@ShouldGenerate(r'''
RouteBase get $iterableWithEnumRoute => GoRouteData.$route(
      path: '/iterable-with-enum',
      factory: $IterableWithEnumRouteExtension._fromState,
    );

extension $IterableWithEnumRouteExtension on IterableWithEnumRoute {
  static IterableWithEnumRoute _fromState(GoRouterState state) =>
      IterableWithEnumRoute(
        param: state.queryParametersAll['param']
            ?.map(_$EnumOnlyUsedInIterableEnumMap._$fromName),
      );

  String get location => GoRouteData.$location(
        '/iterable-with-enum',
        queryParams: {
          if (param != null)
            'param':
                param?.map((e) => _$EnumOnlyUsedInIterableEnumMap[e]).toList(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

const _$EnumOnlyUsedInIterableEnumMap = {
  EnumOnlyUsedInIterable.a: 'a',
  EnumOnlyUsedInIterable.b: 'b',
  EnumOnlyUsedInIterable.c: 'c',
};

extension<T extends Enum> on Map<T, String> {
  T _$fromName(String value) =>
      entries.singleWhere((element) => element.value == value).key;
}
''')
@TypedGoRoute<IterableWithEnumRoute>(path: '/iterable-with-enum')
class IterableWithEnumRoute extends GoRouteData {
  IterableWithEnumRoute({this.param});

  final Iterable<EnumOnlyUsedInIterable>? param;
}

enum EnumOnlyUsedInIterable {
  a,
  b,
  c,
}

@ShouldGenerate(r'''
RouteBase get $iterableDefaultValueRoute => GoRouteData.$route(
      path: '/iterable-default-value-route',
      factory: $IterableDefaultValueRouteExtension._fromState,
    );

extension $IterableDefaultValueRouteExtension on IterableDefaultValueRoute {
  static IterableDefaultValueRoute _fromState(GoRouterState state) =>
      IterableDefaultValueRoute(
        param:
            state.queryParametersAll['param']?.map(int.parse) ?? const <int>[0],
      );

  String get location => GoRouteData.$location(
        '/iterable-default-value-route',
        queryParams: {
          if (param != const <int>[0])
            'param': param.map((e) => e.toString()).toList(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
''')
@TypedGoRoute<IterableDefaultValueRoute>(path: '/iterable-default-value-route')
class IterableDefaultValueRoute extends GoRouteData {
  IterableDefaultValueRoute({this.param = const <int>[0]});
  final Iterable<int> param;
}

@ShouldGenerate(r'''
RouteBase get $namedRoute => GoRouteData.$route(
      path: '/named-route',
      name: 'namedRoute',
      factory: $NamedRouteExtension._fromState,
    );

extension $NamedRouteExtension on NamedRoute {
  static NamedRoute _fromState(GoRouterState state) => NamedRoute();

  String get location => GoRouteData.$location(
        '/named-route',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
''')
@TypedGoRoute<NamedRoute>(path: '/named-route', name: 'namedRoute')
class NamedRoute extends GoRouteData {}

@ShouldGenerate(r'''
RouteBase get $namedEscapedRoute => GoRouteData.$route(
      path: '/named-route',
      name: r'named$Route',
      factory: $NamedEscapedRouteExtension._fromState,
    );

extension $NamedEscapedRouteExtension on NamedEscapedRoute {
  static NamedEscapedRoute _fromState(GoRouterState state) =>
      NamedEscapedRoute();

  String get location => GoRouteData.$location(
        '/named-route',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
''')
@TypedGoRoute<NamedEscapedRoute>(path: '/named-route', name: r'named$Route')
class NamedEscapedRoute extends GoRouteData {}
