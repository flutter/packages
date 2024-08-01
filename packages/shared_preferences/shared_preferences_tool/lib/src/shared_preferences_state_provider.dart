// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/service.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/widgets.dart';

import 'async_state.dart';
import 'shared_preferences_state.dart';
import 'shared_preferences_state_notifier.dart';
import 'shared_preferences_tool_eval.dart';

/// A class that provides a [SharedPreferencesStateNotifier] to its descendants
/// without listening to state changes.
///
/// Check [SharedPreferencesStateProviderExtension] for more info.
class _StateInheritedWidget extends InheritedWidget {
  /// Default constructor for [_StateInheritedWidget].
  const _StateInheritedWidget({
    required super.child,
    required this.notifier,
  });

  final SharedPreferencesStateNotifier notifier;

  @override
  bool updateShouldNotify(covariant _StateInheritedWidget oldWidget) {
    return oldWidget.notifier != notifier;
  }
}

enum _StateInheritedModelAspect {
  keysList,
  selectedKey,
  selectedKeyData,
  editing,
}

/// An inherited model that provides a [SharedPreferencesState] to its descendants.
///
/// Notifies the descendants depending on the aspect of the state that changed.
/// This is meant to prevent unnecessary rebuilds.
/// For more info check [InheritedModel] and [MediaQuery].
class _SharedPreferencesStateInheritedModel
    extends InheritedModel<_StateInheritedModelAspect> {
  const _SharedPreferencesStateInheritedModel({
    required super.child,
    required this.state,
  });

  final AsyncState<SharedPreferencesState> state;

  @override
  bool updateShouldNotify(
    covariant _SharedPreferencesStateInheritedModel oldWidget,
  ) {
    return oldWidget.state != state;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant _SharedPreferencesStateInheritedModel oldWidget,
    Set<_StateInheritedModelAspect> dependencies,
  ) {
    return dependencies.any(
      (_StateInheritedModelAspect aspect) => switch (aspect) {
        _StateInheritedModelAspect.keysList =>
          state.keysListState != oldWidget.state.keysListState,
        _StateInheritedModelAspect.selectedKey =>
          state.selectedKeyState != oldWidget.state.selectedKeyState,
        _StateInheritedModelAspect.selectedKeyData =>
          state.selectedKeyDataState != oldWidget.state.selectedKeyDataState,
        _StateInheritedModelAspect.editing =>
          state.editingState != oldWidget.state.editingState,
      },
    );
  }
}

extension on AsyncState<SharedPreferencesState> {
  AsyncState<List<String>> get keysListState => mapWhenData(
        (SharedPreferencesState data) => data.allKeys,
      );

  String? get selectedKeyState => dataOrNull?.selectedKey?.key;

  AsyncState<SharedPreferencesData?> get selectedKeyDataState =>
      flatMapWhenData(
        (SharedPreferencesState data) {
          if (data.selectedKey
              case final SelectedSharedPreferencesKey selectedKey?) {
            return selectedKey.value;
          }

          return const AsyncState<SharedPreferencesData?>.data(null);
        },
      );

  bool get editingState => dataOrNull?.editing ?? false;
}

@visibleForTesting

/// A class that provides a [SharedPreferencesStateNotifier] to its descendants.
///
/// Only used for testing. You can override the notifier with a mock when testing.
class InnerSharedPreferencesStateProvider extends StatelessWidget {
  /// Default constructor for [InnerSharedPreferencesStateProvider].
  const InnerSharedPreferencesStateProvider({
    super.key,
    required this.notifier,
    required this.child,
  });

  /// The [SharedPreferencesStateNotifier] to provide.
  final SharedPreferencesStateNotifier notifier;

  /// The required child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _StateInheritedWidget(
      notifier: notifier,
      child: ValueListenableBuilder<AsyncState<SharedPreferencesState>>(
        valueListenable: notifier,
        builder: (
          BuildContext context,
          AsyncState<SharedPreferencesState> value,
          _,
        ) {
          return _SharedPreferencesStateInheritedModel(
            state: value,
            child: child,
          );
        },
      ),
    );
  }
}

/// A provider that creates a [SharedPreferencesStateNotifier] and provides it to its descendants.
class SharedPreferencesStateProvider extends StatefulWidget {
  /// Default constructor for [SharedPreferencesStateProvider].
  const SharedPreferencesStateProvider({
    super.key,
    required this.child,
  });

  /// Returns the async state of the list of keys from the closest
  /// [_SharedPreferencesStateInheritedModel] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild whenever the
  /// list of keys changes, including loading and error states.
  /// This will not cause a rebuild when any other part of the state changes.
  static AsyncState<List<String>> keysListStateOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
            _SharedPreferencesStateInheritedModel>(
          aspect: _StateInheritedModelAspect.keysList,
        )!
        .state
        .keysListState;
  }

  /// Returns the selected key from the closest
  /// [_SharedPreferencesStateInheritedModel] ancestor.
  ///
  /// Use of this method will cause the given [context] to rebuild whenever the
  /// selected key changes, including loading and error states.
  /// This will not cause a rebuild when any other part of the state changes.
  static String? selectedKeyOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
            _SharedPreferencesStateInheritedModel>(
          aspect: _StateInheritedModelAspect.selectedKey,
        )!
        .state
        .selectedKeyState;
  }

  /// Returns the selected key from the closest
  /// [_SharedPreferencesStateInheritedModel] ancestor.
  ///
  /// Throws an error if the selected key is null.
  static String requireSelectedKeyOf(BuildContext context) {
    return selectedKeyOf(context)!;
  }

  /// Returns the async state of the selected key data from the closest
  /// [_SharedPreferencesStateInheritedModel] ancestor.
  /// Use of this method will cause the given [context] to rebuild whenever the
  /// selected key data changes, including loading and error states.
  /// This will not cause a rebuild when any other part of the state changes.
  static AsyncState<SharedPreferencesData?> selectedKeyDataOf(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<
            _SharedPreferencesStateInheritedModel>(
          aspect: _StateInheritedModelAspect.selectedKeyData,
        )!
        .state
        .selectedKeyDataState;
  }

  /// Returns whether the selected key is being edited from the closest
  /// _SharedPreferencesStateInheritedModel ancestor.
  /// Use of this method will cause the given [context] to rebuild whenever the
  /// editing state changes, including loading and error states.
  /// This will not cause a rebuild when any other part of the state changes.
  static bool editingOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
            _SharedPreferencesStateInheritedModel>(
          aspect: _StateInheritedModelAspect.editing,
        )!
        .state
        .editingState;
  }

  /// The required child widget.
  final Widget child;

  @override
  State<SharedPreferencesStateProvider> createState() =>
      _SharedPreferencesStateProviderState();
}

class _SharedPreferencesStateProviderState
    extends State<SharedPreferencesStateProvider> {
  late final SharedPreferencesStateNotifier _notifier;

  @override
  void initState() {
    super.initState();
    final EvalOnDartLibrary eval = EvalOnDartLibrary(
      'package:shared_preferences/src/shared_preferences_async.dart',
      serviceManager.service!,
      serviceManager: serviceManager,
    );
    final SharedPreferencesToolEval toolEval = SharedPreferencesToolEval(eval);
    _notifier = SharedPreferencesStateNotifier(toolEval);
    _notifier.fetchAllKeys();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InnerSharedPreferencesStateProvider(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

/// An extension that provides a [SharedPreferencesStateNotifier] to its
/// descendants.
extension SharedPreferencesStateProviderExtension on BuildContext {
  /// Returns the [SharedPreferencesStateNotifier] from the closest
  /// [StateInheritedNotifier] ancestor.
  ///
  /// This will not introduce a dependency. So changes to the notifier's value
  /// will not trigger a rebuild.
  ///
  /// This is useful for calling methods on the notifier whenever there is a
  /// user interaction, this way we can depend on specific parts of the state,
  /// without the need to rebuild the whole widget tree whenever there is a
  /// change.
  ///
  /// Example:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return DevToolsButton(
  ///     onPressed: () => context.sharedPreferencesStateNotifier.stopEditing(),
  ///       label: 'Cancel',
  ///     );
  /// }
  /// ````
  SharedPreferencesStateNotifier get sharedPreferencesStateNotifier {
    return getInheritedWidgetOfExactType<_StateInheritedWidget>()!.notifier;
  }
}
