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
  'Required parameters cannot be nullable.',
)
@TypedGoRoute<NullableRequiredParam>(path: 'bob/:id')
class NullableRequiredParam extends GoRouteData {
  NullableRequiredParam({required this.id});
  final int? id;
}

@ShouldThrow(
  r'Parameters named `$extra` cannot be required.',
)
@TypedGoRoute<ExtraMustBeOptional>(path: r'bob/:$extra')
class ExtraMustBeOptional extends GoRouteData {
  ExtraMustBeOptional({required this.$extra});
  final int $extra;
}

@ShouldThrow(
  'Missing param `id` in path.',
)
@TypedGoRoute<MissingPathParam>(path: 'bob/')
class MissingPathParam extends GoRouteData {
  MissingPathParam({required this.id});
  final String id;
}

@ShouldGenerate(r'''
GoRoute get $enumParam => GoRouteData.$route(
      path: '/:y',
      factory: $EnumParamExtension._fromState,
    );

extension $EnumParamExtension on EnumParam {
  static EnumParam _fromState(GoRouterState state) => EnumParam(
        y: _$EnumTestEnumMap._$fromName(state.params['y']!),
      );

  String get location => GoRouteData.$location(
        '/${Uri.encodeComponent(_$EnumTestEnumMap[y]!)}',
      );

  void go(BuildContext context) => context.go(location, extra: this);

  void push(BuildContext context) => context.push(location, extra: this);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: this);
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
