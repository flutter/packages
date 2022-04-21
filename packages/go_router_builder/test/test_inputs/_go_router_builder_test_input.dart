// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow('The @TypedGoRoute annotation can only be applied to classes.')
@TypedGoRoute(path: 'bob') // ignore: invalid_annotation_target
const int theAnswer = 42;

@ShouldThrow('Missing `path` value on annotation.')
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
