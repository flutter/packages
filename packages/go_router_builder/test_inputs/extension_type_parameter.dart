// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$ExtenstionTypeParam {}
mixin _$ExtenstionTypeStringParam {}
mixin _$ExtenstionTypeStringDefaultParam {}
mixin _$ExtenstionTypeIntParam {}
mixin _$ExtenstionTypeIntDefaultParam {}
mixin _$ExtenstionTypeDoubleParam {}
mixin _$ExtenstionTypeNumParam {}
mixin _$ExtenstionTypeBoolParam {}
mixin _$ExtenstionTypeBigIntParam {}
mixin _$ExtenstionTypeDateTimeParam {}

@TypedGoRoute<ExtenstionTypeParam>(path: '/', routes: <TypedRoute<RouteData>>[
  TypedGoRoute<ExtenstionTypeStringParam>(path: 'string/:s'),
  TypedGoRoute<ExtenstionTypeStringDefaultParam>(path: 'string_default/:s'),
  TypedGoRoute<ExtenstionTypeIntParam>(path: 'int/:x'),
  TypedGoRoute<ExtenstionTypeIntDefaultParam>(path: 'int_default/:x'),
  TypedGoRoute<ExtenstionTypeDoubleParam>(path: 'double/:d'),
  TypedGoRoute<ExtenstionTypeNumParam>(path: 'num/:n'),
  TypedGoRoute<ExtenstionTypeBoolParam>(path: 'bool/:b'),
  TypedGoRoute<ExtenstionTypeBigIntParam>(path: 'bigint/:bi'),
  TypedGoRoute<ExtenstionTypeDateTimeParam>(path: 'datetime/:dt'),
])
class ExtenstionTypeParam extends GoRouteData with _$ExtenstionTypeParam {
  ExtenstionTypeParam();
}

class ExtenstionTypeStringParam extends GoRouteData
    with _$ExtenstionTypeStringParam {
  ExtenstionTypeStringParam({
    required this.s,
    required this.requiredValue,
    this.optionalNullableValue,
    this.optionalDefaultValue = const StringExtensionType('default'),
  });
  final StringExtensionType s;
  final StringExtensionType requiredValue;
  final StringExtensionType? optionalNullableValue;
  final StringExtensionType optionalDefaultValue;
}

class ExtenstionTypeStringDefaultParam extends GoRouteData
    with _$ExtenstionTypeStringDefaultParam {
  ExtenstionTypeStringDefaultParam({
    this.s = const StringExtensionType('default'),
  });
  final StringExtensionType s;
}

class ExtenstionTypeIntParam extends GoRouteData with _$ExtenstionTypeIntParam {
  ExtenstionTypeIntParam({
    required this.x,
    required this.requiredValue,
    this.optionalNullableValue,
    this.optionalDefaultValue = const IntExtensionType(42),
  });
  final IntExtensionType x;
  final IntExtensionType requiredValue;
  final IntExtensionType? optionalNullableValue;
  final IntExtensionType optionalDefaultValue;
}

class ExtenstionTypeIntDefaultParam extends GoRouteData
    with _$ExtenstionTypeIntDefaultParam {
  ExtenstionTypeIntDefaultParam({
    this.x = const IntExtensionType(42),
  });
  final IntExtensionType x;
}

class ExtenstionTypeDoubleParam extends GoRouteData
    with _$ExtenstionTypeDoubleParam {
  ExtenstionTypeDoubleParam({
    required this.d,
    required this.requiredValue,
    this.optionalNullableValue,
    this.optionalDefaultValue = const DoubleExtensionType(3.14),
  });
  final DoubleExtensionType d;
  final DoubleExtensionType requiredValue;
  final DoubleExtensionType? optionalNullableValue;
  final DoubleExtensionType optionalDefaultValue;
}

class ExtenstionTypeNumParam extends GoRouteData with _$ExtenstionTypeNumParam {
  ExtenstionTypeNumParam({
    required this.n,
    required this.requiredValue,
    this.optionalNullableValue,
    this.optionalDefaultValue = const NumExtensionType(3.14),
  });
  final NumExtensionType n;
  final NumExtensionType requiredValue;
  final NumExtensionType? optionalNullableValue;
  final NumExtensionType optionalDefaultValue;
}

class ExtenstionTypeBoolParam extends GoRouteData
    with _$ExtenstionTypeBoolParam {
  ExtenstionTypeBoolParam({
    required this.b,
    required this.requiredValue,
    this.optionalNullableValue,
    this.optionalDefaultValue = const BoolExtensionType(true),
  });
  final BoolExtensionType b;
  final BoolExtensionType requiredValue;
  final BoolExtensionType? optionalNullableValue;
  final BoolExtensionType optionalDefaultValue;
}

class ExtenstionTypeBigIntParam extends GoRouteData
    with _$ExtenstionTypeBigIntParam {
  ExtenstionTypeBigIntParam({
    required this.bi,
    required this.requiredValue,
    this.optionalValue,
    this.optionalNullableValue,
  });
  final BigIntExtensionType bi;
  final BigIntExtensionType requiredValue;
  final BigIntExtensionType? optionalValue;
  final BigIntExtensionType? optionalNullableValue;
}

class ExtenstionTypeDateTimeParam extends GoRouteData
    with _$ExtenstionTypeDateTimeParam {
  ExtenstionTypeDateTimeParam({
    required this.dt,
    required this.optionalValue,
    this.optionalNullableValue,
  });
  final DateTimeExtensionType dt;
  final DateTimeExtensionType optionalValue;
  final DateTimeExtensionType? optionalNullableValue;
}

extension type const StringExtensionType(String value) {}
extension type const IntExtensionType(int value) {}
extension type const DoubleExtensionType(double value) {}
extension type const NumExtensionType(num value) {}
extension type const BoolExtensionType(bool value) {}
extension type const BigIntExtensionType(BigInt value) {}
extension type const DateTimeExtensionType(DateTime value) {}
