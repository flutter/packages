// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'typed_query_parameter_example.g.dart';

void main() => runApp(App());

class CustomParameter {
  const CustomParameter({required this.valueString, required this.valueInt});

  final String valueString;
  final int valueInt;

  static String? encode(CustomParameter? parameter) {
    if (parameter == null) {
      return null;
    }
    return '${parameter.valueString},${parameter.valueInt}';
  }

  static CustomParameter? decode(String? value) {
    if (value == null) {
      return null;
    }
    final List<String> parts = value.split(',');
    return CustomParameter(
      valueString: parts[0],
      valueInt: int.parse(parts[1]),
    );
  }

  static bool compare(CustomParameter a, CustomParameter b) {
    return a.valueString != b.valueString || a.valueInt != b.valueInt;
  }
}

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router);

  final GoRouter _router = GoRouter(
    initialLocation: '/int-route',
    routes: $appRoutes,
  );
}

@TypedGoRoute<IntRoute>(path: '/int-route')
class IntRoute extends GoRouteData with $IntRoute {
  IntRoute({
    @TypedQueryParameter<int>(name: 'intField') this.intField,
    @TypedQueryParameter<int>(name: 'int_field_with_default_value')
    this.intFieldWithDefaultValue = 1,
    @TypedQueryParameter<int>(name: 'int field') this.intFieldWithSpace,
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

  final int? intField;
  final int intFieldWithDefaultValue;
  final int? intFieldWithSpace;
  final CustomParameter? customField;
  final CustomParameter customFieldWithDefaultValue;
  @override
  Widget build(BuildContext context, GoRouterState state) => Screen(
    intField: intField,
    intFieldWithDefaultValue: intFieldWithDefaultValue,
    intFieldWithSpace: intFieldWithSpace,
    customField: customField,
    customFieldWithDefaultValue: customFieldWithDefaultValue,
  );
}

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.intField,
    required this.intFieldWithDefaultValue,
    this.intFieldWithSpace,
    this.customField,
    required this.customFieldWithDefaultValue,
  });

  final int? intField;
  final int intFieldWithDefaultValue;
  final int? intFieldWithSpace;
  final CustomParameter? customField;
  final CustomParameter customFieldWithDefaultValue;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Go router with custom URI parameter names'),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('intField:'),
            subtitle: Text('$intField'),
            trailing: const Icon(Icons.add),
            onTap: () {
              final int newValue = (intField ?? 0) + 1;
              IntRoute(
                intField: newValue,
                intFieldWithDefaultValue: intFieldWithDefaultValue,
                intFieldWithSpace: intFieldWithSpace,
                customField: customField,
                customFieldWithDefaultValue: customFieldWithDefaultValue,
              ).go(context);
            },
          ),
          ListTile(
            title: const Text('intFieldWithDefaultValue:'),
            subtitle: Text('$intFieldWithDefaultValue'),
            trailing: const Icon(Icons.add),
            onTap: () {
              final int newValue = intFieldWithDefaultValue + 1;
              IntRoute(
                intField: intField,
                intFieldWithDefaultValue: newValue,
                intFieldWithSpace: intFieldWithSpace,
                customField: customField,
                customFieldWithDefaultValue: customFieldWithDefaultValue,
              ).go(context);
            },
          ),
          ListTile(
            title: const Text('intFieldWithSpace:'),
            subtitle: Text('$intFieldWithSpace'),
            trailing: const Icon(Icons.add),
            onTap: () {
              final int newValue = (intFieldWithSpace ?? 0) + 1;
              IntRoute(
                intField: intField,
                intFieldWithDefaultValue: intFieldWithDefaultValue,
                intFieldWithSpace: newValue,
                customField: customField,
                customFieldWithDefaultValue: customFieldWithDefaultValue,
              ).go(context);
            },
          ),
          ListTile(
            title: const Text('customField:'),
            subtitle: Text(CustomParameter.encode(customField) ?? ''),
            trailing: const Icon(Icons.add),
            onTap: () {
              final newValue = CustomParameter(
                valueString: '${customField?.valueString ?? ''}-',
                valueInt: (customField?.valueInt ?? 0) + 1,
              );
              IntRoute(
                intField: intField,
                intFieldWithDefaultValue: intFieldWithDefaultValue,
                intFieldWithSpace: intFieldWithSpace,
                customField: newValue,
                customFieldWithDefaultValue: customFieldWithDefaultValue,
              ).go(context);
            },
          ),
          ListTile(
            title: const Text('customFieldWithDefaultValue:'),
            subtitle: Text(
              CustomParameter.encode(customFieldWithDefaultValue)!,
            ),
            trailing: const Icon(Icons.add),
            onTap: () {
              final newValue = CustomParameter(
                valueString: '${customFieldWithDefaultValue.valueString}-',
                valueInt: customFieldWithDefaultValue.valueInt + 1,
              );
              IntRoute(
                intField: intField,
                intFieldWithDefaultValue: intFieldWithDefaultValue,
                intFieldWithSpace: intFieldWithSpace,
                customField: customField,
                customFieldWithDefaultValue: newValue,
              ).go(context);
            },
          ),
        ],
      ),
    ),
  );
}
