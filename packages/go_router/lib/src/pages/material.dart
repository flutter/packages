// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: diagnostic_describe_all_properties

import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as material_ui;

import '../misc/extensions.dart';

/// Checks for MaterialApp in the widget tree.
bool isMaterialApp(BuildContext context) =>
    context.findAncestorWidgetOfExactType<flutter_material.MaterialApp>() != null ||
    context.findAncestorWidgetOfExactType<material_ui.MaterialApp>() != null;

/// Creates a Material HeroController from material_ui.
HeroController createMaterialHeroController() =>
    material_ui.MaterialApp.createMaterialHeroController();

/// Creates a Material HeroController from the Flutter SDK.
HeroController createSdkMaterialHeroController() =>
    flutter_material.MaterialApp.createMaterialHeroController();

/// Builds a Material page from material_ui.
material_ui.MaterialPage<void> pageBuilderForMaterialApp({
  required LocalKey key,
  required String? name,
  required Object? arguments,
  required String restorationId,
  required Widget child,
}) => material_ui.MaterialPage<void>(
  name: name,
  arguments: arguments,
  key: key,
  restorationId: restorationId,
  child: child,
);

/// Builds a Material page from the Flutter SDK.
flutter_material.MaterialPage<void> pageBuilderForSdkMaterialApp({
  required LocalKey key,
  required String? name,
  required Object? arguments,
  required String restorationId,
  required Widget child,
}) => flutter_material.MaterialPage<void>(
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
  Widget build(BuildContext context) => material_ui.Scaffold(
    appBar: material_ui.AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          material_ui.SelectableText(error?.toString() ?? 'page not found'),
          material_ui.TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Home'),
          ),
        ],
      ),
    ),
  );
}

/// Default error page implementation for an SDK MaterialApp.
class SdkMaterialErrorScreen extends StatelessWidget {
  /// Provide an exception to this page for it to be displayed.
  const SdkMaterialErrorScreen(this.error, {super.key});

  /// The exception to be displayed.
  final Exception? error;

  @override
  Widget build(BuildContext context) => flutter_material.Scaffold(
    appBar: flutter_material.AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          flutter_material.SelectableText(error?.toString() ?? 'page not found'),
          flutter_material.TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Home'),
          ),
        ],
      ),
    ),
  );
}
