// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: diagnostic_describe_all_properties

// Unprefixed [CupertinoApp] is cupertino_ui's; the framework's is aliased.
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/cupertino.dart' as flutter_cupertino;

import '../misc/extensions.dart';

/// Checks for CupertinoApp in the widget tree.
///
/// During the Material/Cupertino decoupling (flutter/flutter#184093) an app may
/// use the framework's or cupertino_ui's [CupertinoApp] — distinct types, and
/// [findAncestorWidgetOfExactType] matches only one — so both are checked to
/// install the right HeroController for shell-route Hero flights
/// (flutter/flutter#192043). Drop the framework check once it is sunset.
bool isCupertinoApp(BuildContext context) =>
    context.findAncestorWidgetOfExactType<flutter_cupertino.CupertinoApp>() != null ||
    context.findAncestorWidgetOfExactType<CupertinoApp>() != null;

/// Creates a Cupertino HeroController.
HeroController createCupertinoHeroController() => CupertinoApp.createCupertinoHeroController();

/// Builds a Cupertino page.
CupertinoPage<void> pageBuilderForCupertinoApp({
  required LocalKey key,
  required String? name,
  required Object? arguments,
  required String restorationId,
  required Widget child,
}) => CupertinoPage<void>(
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
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: const CupertinoNavigationBar(middle: Text('Page Not Found')),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(error?.toString() ?? 'page not found'),
          CupertinoButton(onPressed: () => context.go('/'), child: const Text('Home')),
        ],
      ),
    ),
  );
}
