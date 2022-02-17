// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: diagnostic_describe_all_properties

import 'package:flutter/material.dart';
import '../go_router.dart';

/// Checks for MaterialApp in the widget tree.
bool isMaterialApp(Element elem) =>
    elem.findAncestorWidgetOfExactType<MaterialApp>() != null;

/// Builds a Material page.
MaterialPage<void> pageBuilderForMaterialApp({
  required LocalKey key,
  required String? name,
  required Object? arguments,
  required String restorationId,
  required Widget child,
}) =>
    MaterialPage<void>(
      name: name,
      arguments: arguments,
      key: key,
      restorationId: restorationId,
      child: child,
    );

/// Default error page implementation for Material.
class GoRouterMaterialErrorScreen extends StatelessWidget {
  /// Provide an exception to this page for it to be displayed.
  const GoRouterMaterialErrorScreen(this.error, {Key? key}) : super(key: key);

  /// The exception to be displayed.
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableText(error?.toString() ?? 'page not found'),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      );
}
