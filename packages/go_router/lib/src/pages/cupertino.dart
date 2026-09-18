// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: diagnostic_describe_all_properties

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino_ui;
import 'package:flutter/cupertino.dart' as flutter_cupertino;
import 'package:flutter/widgets.dart';

import '../misc/extensions.dart';

/// Checks for CupertinoApp in the widget tree.
bool isCupertinoApp(BuildContext context) =>
    context.findAncestorWidgetOfExactType<flutter_cupertino.CupertinoApp>() != null ||
    context.findAncestorWidgetOfExactType<cupertino_ui.CupertinoApp>() != null;

/// Creates a Cupertino HeroController from cupertino_ui.
HeroController createCupertinoHeroController() =>
    cupertino_ui.CupertinoApp.createCupertinoHeroController();

/// Creates a Cupertino HeroController from the Flutter SDK.
HeroController createSdkCupertinoHeroController() =>
    flutter_cupertino.CupertinoApp.createCupertinoHeroController();

/// Builds a Cupertino page from cupertino_ui.
cupertino_ui.CupertinoPage<void> pageBuilderForCupertinoApp({
  required LocalKey key,
  required String? name,
  required Object? arguments,
  required String restorationId,
  required Widget child,
}) => cupertino_ui.CupertinoPage<void>(
  name: name,
  arguments: arguments,
  key: key,
  restorationId: restorationId,
  child: child,
);

/// Builds a Cupertino page from the Flutter SDK.
flutter_cupertino.CupertinoPage<void> pageBuilderForSdkCupertinoApp({
  required LocalKey key,
  required String? name,
  required Object? arguments,
  required String restorationId,
  required Widget child,
}) => flutter_cupertino.CupertinoPage<void>(
  name: name,
  arguments: arguments,
  key: key,
  restorationId: restorationId,
  child: child,
);

/// Default error page implementation for Cupertino.
class CupertinoErrorScreen extends StatelessWidget {
  /// Provide an exception to this page for it to be displayed.
  const CupertinoErrorScreen(this.error, {super.key});

  /// The exception to be displayed.
  final Exception? error;

  @override
  Widget build(BuildContext context) => cupertino_ui.CupertinoPageScaffold(
    navigationBar: const cupertino_ui.CupertinoNavigationBar(
      middle: Text('Page Not Found'),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(error?.toString() ?? 'page not found'),
          cupertino_ui.CupertinoButton(
            onPressed: () => context.go('/'),
            child: const Text('Home'),
          ),
        ],
      ),
    ),
  );
}

/// Default error page implementation for an SDK CupertinoApp.
class SdkCupertinoErrorScreen extends StatelessWidget {
  /// Provide an exception to this page for it to be displayed.
  const SdkCupertinoErrorScreen(this.error, {super.key});

  /// The exception to be displayed.
  final Exception? error;

  @override
  Widget build(BuildContext context) => flutter_cupertino.CupertinoPageScaffold(
    navigationBar: const flutter_cupertino.CupertinoNavigationBar(
      middle: Text('Page Not Found'),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(error?.toString() ?? 'page not found'),
          flutter_cupertino.CupertinoButton(
            onPressed: () => context.go('/'),
            child: const Text('Home'),
          ),
        ],
      ),
    ),
  );
}
