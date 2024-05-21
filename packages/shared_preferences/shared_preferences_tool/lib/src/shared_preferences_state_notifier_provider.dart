// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/service.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'shared_preferences_state_notifier.dart';
import 'shared_preferences_tool_eval.dart';

@internal
@visibleForTesting
class StateInheritedNotifier
    extends InheritedNotifier<SharedPreferencesStateNotifier> {
  const StateInheritedNotifier({
    super.key,
    required super.child,
    required super.notifier,
  });
}

@internal
class SharedPreferencesStateNotifierProvider extends StatefulWidget {
  const SharedPreferencesStateNotifierProvider({
    super.key,
    required this.child,
  });

  final Widget child;

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
