// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: diagnostic_describe_all_properties

import 'package:flutter/material.dart';

import '../misc/extensions.dart';

/// Checks for MaterialApp in the widget tree.
bool isMaterialApp(BuildContext context) =>
    context.findAncestorWidgetOfExactType<MaterialApp>() != null;

/// Creates a Material HeroController.
HeroController createMaterialHeroController() =>
    MaterialApp.createMaterialHeroController();

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
class MaterialErrorScreen extends StatelessWidget {
  /// Provide an exception to this page for it to be displayed.
  const MaterialErrorScreen(this.error, {super.key});

  /// The exception to be displayed.
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
