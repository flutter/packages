// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/service.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/widgets.dart';

import 'shared_preferences_state_notifier.dart';
import 'shared_preferences_tool_eval.dart';

@visibleForTesting

/// A class that provides a [SharedPreferencesStateNotifier] to its descendants.
/// Only used for testing. You can override the notifier with a mock when testing.
class StateInheritedNotifier
    extends InheritedNotifier<SharedPreferencesStateNotifier> {
  /// Default constructor for [StateInheritedNotifier].
  const StateInheritedNotifier({
    super.key,
    required super.child,
    required super.notifier,
  });
}

/// A provider that creates a [SharedPreferencesStateNotifier] and provides it to its descendants.
class SharedPreferencesStateNotifierProvider extends StatefulWidget {
  /// Default constructor for [SharedPreferencesStateNotifierProvider].
  const SharedPreferencesStateNotifierProvider({
    super.key,
    required this.child,
  });

  /// The required child widget.
  final Widget child;

  /// Returns the [SharedPreferencesStateNotifier] from the closest [StateInheritedNotifier] ancestor.
  /// It will also listen to changes and rebuild dependents when the [SharedPreferencesStateNotifier.value] changes.
  static SharedPreferencesStateNotifier of(BuildContext context) {
    final StateInheritedNotifier? result =
        context.dependOnInheritedWidgetOfExactType<StateInheritedNotifier>();
    return result!.notifier!;
  }

  @override
  State<SharedPreferencesStateNotifierProvider> createState() =>
      _SharedPreferencesStateNotifierProviderState();
}

class _SharedPreferencesStateNotifierProviderState
    extends State<SharedPreferencesStateNotifierProvider> {
  late final SharedPreferencesStateNotifier _notifier;

  @override
  void initState() {
    final EvalOnDartLibrary eval = EvalOnDartLibrary(
      'package:shared_preferences/shared_preferences.dart',
      serviceManager.service!,
      serviceManager: serviceManager,
    );
    final SharedPreferencesToolEval toolsEval = SharedPreferencesToolEval(eval);
    _notifier = SharedPreferencesStateNotifier(toolsEval);
    _notifier.fetchAllKeys();
    super.initState();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateInheritedNotifier(
      notifier: _notifier,
      child: widget.child,
    );
  }
}
