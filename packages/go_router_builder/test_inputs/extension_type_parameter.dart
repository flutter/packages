// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin _$ExtensionTypeParam {}
mixin _$ExtensionTypeStringParam {}
mixin _$ExtensionTypeStringDefaultParam {}
mixin _$ExtensionTypeIntParam {}
mixin _$ExtensionTypeIntDefaultParam {}
mixin _$ExtensionTypeDoubleParam {}
mixin _$ExtensionTypeNumParam {}
mixin _$ExtensionTypeBoolParam {}
mixin _$ExtensionTypeEnumType {}
mixin _$ExtensionTypeBigIntParam {}
mixin _$ExtensionTypeDateTimeParam {}
mixin _$ExtensionTypeUriType {}

@TypedGoRoute<ExtensionTypeParam>(
  path: '/',
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<ExtensionTypeStringParam>(path: 'string/:s'),
    TypedGoRoute<ExtensionTypeStringDefaultParam>(path: 'string_default/:s'),
    TypedGoRoute<ExtensionTypeIntParam>(path: 'int/:x'),
    TypedGoRoute<ExtensionTypeIntDefaultParam>(path: 'int_default/:x'),
    TypedGoRoute<ExtensionTypeDoubleParam>(path: 'double/:d'),
    TypedGoRoute<ExtensionTypeNumParam>(path: 'num/:n'),
    TypedGoRoute<ExtensionTypeBoolParam>(path: 'bool/:b'),
    TypedGoRoute<ExtensionTypeEnumType>(path: 'enum/:value'),
    TypedGoRoute<ExtensionTypeBigIntParam>(path: 'bigint/:bi'),
    TypedGoRoute<ExtensionTypeDateTimeParam>(path: 'datetime/:dt'),
    TypedGoRoute<ExtensionTypeUriType>(path: 'uri/:uri'),
  ],
)
class ExtensionTypeParam extends GoRouteData with _$ExtensionTypeParam {
  ExtensionTypeParam();
}

class ExtensionTypeStringParam extends GoRouteData
    with _$ExtensionTypeStringParam {
  ExtensionTypeStringParam({
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

class ExtensionTypeStringDefaultParam extends GoRouteData
    with _$ExtensionTypeStringDefaultParam {
  ExtensionTypeStringDefaultParam({
    this.s = const StringExtensionType('default'),
  });
  final StringExtensionType s;
}

class ExtensionTypeIntParam extends GoRouteData with _$ExtensionTypeIntParam {
  ExtensionTypeIntParam({
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

class ExtensionTypeIntDefaultParam extends GoRouteData
    with _$ExtensionTypeIntDefaultParam {
  ExtensionTypeIntDefaultParam({this.x = const IntExtensionType(42)});
  final IntExtensionType x;
}

class ExtensionTypeDoubleParam extends GoRouteData
    with _$ExtensionTypeDoubleParam {
  ExtensionTypeDoubleParam({
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

class ExtensionTypeNumParam extends GoRouteData with _$ExtensionTypeNumParam {
  ExtensionTypeNumParam({
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

class ExtensionTypeBoolParam extends GoRouteData with _$ExtensionTypeBoolParam {
  ExtensionTypeBoolParam({
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

enum MyEnum { value1, value2, value3 }

class ExtensionTypeEnumType extends GoRouteData with _$ExtensionTypeEnumType {
  ExtensionTypeEnumType({
    required this.value,
    required this.requiredValue,
    this.optionalNullableValue,
    this.optionalDefaultValue = const EnumExtensionType(MyEnum.value1),
  });
  final EnumExtensionType value;
  final EnumExtensionType requiredValue;
  final EnumExtensionType? optionalNullableValue;
  final EnumExtensionType optionalDefaultValue;
}

class ExtensionTypeBigIntParam extends GoRouteData
    with _$ExtensionTypeBigIntParam {
  ExtensionTypeBigIntParam({
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

class ExtensionTypeDateTimeParam extends GoRouteData
    with _$ExtensionTypeDateTimeParam {
  ExtensionTypeDateTimeParam({
    required this.dt,
    required this.optionalValue,
    this.optionalNullableValue,
  });
  final DateTimeExtensionType dt;
  final DateTimeExtensionType optionalValue;
  final DateTimeExtensionType? optionalNullableValue;
}

class ExtensionTypeUriType extends GoRouteData with _$ExtensionTypeUriType {
  ExtensionTypeUriType({
    required this.uri,
    required this.requiredValue,
    this.optionalNullableValue,
  });
  final UriExtensionType uri;
  final UriExtensionType requiredValue;
  final UriExtensionType? optionalNullableValue;
}

extension type const StringExtensionType(String value) {}
extension type const IntExtensionType(int value) {}
extension type const DoubleExtensionType(double value) {}
extension type const NumExtensionType(num value) {}
extension type const BoolExtensionType(bool value) {}
extension type const EnumExtensionType(MyEnum value) {}
extension type const BigIntExtensionType(BigInt value) {}
extension type const DateTimeExtensionType(DateTime value) {}
extension type const UriExtensionType(Uri value) {}
