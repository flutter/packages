// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $OverriddenParameterNameRoute {}

class CustomParameter {
  const CustomParameter({required this.valueString, required this.valueInt});

  final String valueString;
  final int valueInt;

  static String? encode(CustomParameter? parameter) {
    return '';
  }

  static CustomParameter? decode(String? value) {
    return const CustomParameter(valueString: '', valueInt: 0);
  }

  static bool compare(CustomParameter a, CustomParameter b) {
    return true;
  }
}

@TypedGoRoute<OverriddenParameterNameRoute>(path: '/typed-go-route-parameter')
class OverriddenParameterNameRoute extends GoRouteData
    with $OverriddenParameterNameRoute {
  OverriddenParameterNameRoute({
    @TypedQueryParameter<int>(name: 'parameterNameOverride')
    this.withAnnotation,
    @TypedQueryParameter<String>(name: 'name with space') this.withSpace,
    @TypedQueryParameter<CustomParameter>(
      encoder: CustomParameter.encode,
      decoder: CustomParameter.decode,
    )
    this.customField,
    @TypedQueryParameter<CustomParameter>(
      encoder: CustomParameter.encode,
      decoder: CustomParameter.decode,
      compare: CustomParameter.compare,
    )
    this.customFieldWithDefaultValue = const CustomParameter(
      valueString: 'default',
      valueInt: 0,
    ),
  });
  final int? withAnnotation;
  final String? withSpace;
  final CustomParameter? customField;
  final CustomParameter customFieldWithDefaultValue;
}
