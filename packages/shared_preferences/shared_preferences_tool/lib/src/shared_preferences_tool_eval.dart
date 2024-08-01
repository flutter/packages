// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'package:devtools_app_shared/service.dart';
import 'package:vm_service/vm_service.dart';

import 'shared_preferences_state.dart';

/// A class that provides methods to interact with the shared preferences
/// of the target debug session.
///
/// It abstracts the calls to [EvalOnDartLibrary].
class SharedPreferencesToolEval {
  /// Default constructor for [SharedPreferencesToolEval].
  /// Do not call this constructor directly.
  /// Use [SharedPreferencesStateNotifierProvider] instead.
  SharedPreferencesToolEval(this._eval);

  final EvalOnDartLibrary _eval;

  Disposable? _allKeysDisposable;
  Disposable? _valueDisposable;
  Disposable? _changeValueDisposable;
  Disposable? _removeValueDisposable;

  /// Fetches all keys in the shared preferences of the target debug session.
  /// Returns a string list of all keys.
  Future<List<String>> fetchAllKeys() async {
    _allKeysDisposable?.dispose();
    _allKeysDisposable = Disposable();
    final Instance keysSetInstance = await _eval.prefsGetInstance(
      'getKeys()',
      _allKeysDisposable,
    );
    return Future.wait(<Future<String>>[
      for (final InstanceRef keyRef
          in keysSetInstance.elements!.cast<InstanceRef>())
        _eval.safeGetInstance(keyRef, _allKeysDisposable).then(
              (Instance keyInstance) => keyInstance.valueAsString!,
            ),
    ]);
  }

  /// Fetches the value of the shared preference with the given [key].
  /// Returns a [SharedPreferencesData] object that represents the value.
  /// The type of the value is determined by the type of the shared preference.
  Future<SharedPreferencesData> fetchValue(String key) async {
    _valueDisposable?.dispose();
    _valueDisposable = Disposable();
    final Instance setInstance = await _eval.prefsGetInstance(
      "getAll(allowList: {'$key'})",
      _valueDisposable,
    );

    final Instance valueInstance = await _eval.safeGetInstance(
      setInstance.associations!.first.value as InstanceRef,
      _valueDisposable,
    );

    return switch (valueInstance.kind) {
      InstanceKind.kInt => SharedPreferencesData.int(
          value: int.parse(valueInstance.valueAsString!),
        ),
      InstanceKind.kBool => SharedPreferencesData.bool(
          value: bool.parse(valueInstance.valueAsString!),
        ),
      InstanceKind.kDouble => SharedPreferencesData.double(
          value: double.parse(valueInstance.valueAsString!),
        ),
      InstanceKind.kString => SharedPreferencesData.string(
          value: valueInstance.valueAsString!,
        ),
      InstanceKind.kList => SharedPreferencesData.stringList(
          value: valueInstance.elements!
              .cast<InstanceRef>()
              .map(
                (InstanceRef ref) => ref.valueAsString!,
              )
              .toList(),
        ),
      _ => throw UnsupportedError(
          'Unsupported value type: ${valueInstance.kind}',
        ),
    };
  }

  /// Changes the value of the key in the shared preferences of the target debug
  /// session.
  Future<void> changeValue(String key, SharedPreferencesData value) async {
    _changeValueDisposable?.dispose();
    _changeValueDisposable = Disposable();
    final String method = switch (value) {
      final SharedPreferencesDataString data =>
        "setString('$key', '${data.value}')",
      final SharedPreferencesDataInt data => "setInt('$key', ${data.value})",
      final SharedPreferencesDataDouble data =>
        "setDouble('$key', ${data.value})",
      final SharedPreferencesDataBool data => "setBool('$key', ${data.value})",
      final SharedPreferencesDataStringList data =>
        "setStringList('$key', [${data.value.map((String str) => "'$str'").join(', ')}])",
    };
    await _eval.prefsEval(method, _changeValueDisposable);
  }

  /// Deletes the key from the shared preferences of the target debug session.
  Future<void> deleteKey(String key) async {
    _removeValueDisposable?.dispose();
    _removeValueDisposable = Disposable();
    await _eval.prefsEval("remove('$key')", _removeValueDisposable);
  }

  /// Disposes all the disposables used in this class.
  void dispose() {
    _allKeysDisposable?.dispose();
    _valueDisposable?.dispose();
    _changeValueDisposable?.dispose();
    _removeValueDisposable?.dispose();
    _eval.dispose();
  }
}

extension on EvalOnDartLibrary {
  /// Evaluates the given [method] on the shared preferences instance.
  ///
  /// Returns the [InstanceRef] of the result.
  /// The [isAlive] parameter is used to dispose the evaluation if the
  /// caller is disposed.
  ///
  /// This method is actually a workaround for the asyncEval method, which is
  /// not working for web targets, check this issue https://github.com/flutter/devtools/issues/7766.
  Future<InstanceRef?> prefsEval(String method, Disposable? isAlive) async {
    // Create a empty list in memory to hold the future value instance.
    // It could've been anything that can handle values passed by reference.
    final InstanceRef valueHolderRef = await safeEval(
      '[]',
      isAlive: isAlive,
    );

    final InstanceRef futureInstance = await safeEval(
      'SharedPreferencesAsync().$method',
      isAlive: isAlive,
    );

    // Add the future value instance to the list once the future completes
    await eval(
      'future.then(valueHolder.add);',
      scope: <String, String>{
        'valueHolder': valueHolderRef.id!,
        'future': futureInstance.id!,
      },
      isAlive: isAlive,
    );

    // The maximum number of retries to get the future value instance.
    // Means a max of 1 second of waiting.
    const int maxRetries = 20;
    int retryCount = 0;

    // Wait until the shared preferences instance is added to the list.
    while (true) {
      retryCount++;
      // A break condition to avoid infinite loop.
      if (retryCount > maxRetries) {
        throw StateError('Failed to get future value instance.');
      }
      final Instance holderInstance =
          await safeGetInstance(valueHolderRef, isAlive);

      // If the elements list is not empty it means the future has resolved.
      if (holderInstance.elements case final List<dynamic> elements
          when elements.isNotEmpty) {
        final Object? prefsInstance = elements.firstOrNull;
        // We return null if the future is a Future<void>
        return prefsInstance != null ? prefsInstance as InstanceRef : null;
      }

      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<Instance> prefsGetInstance(String method, Disposable? isAlive) async {
    return safeGetInstance(
      (await prefsEval(method, isAlive))!,
      isAlive,
    );
  }
}
