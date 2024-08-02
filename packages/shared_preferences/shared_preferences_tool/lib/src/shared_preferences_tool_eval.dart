// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/service.dart';
import 'package:vm_service/vm_service.dart';

import 'shared_preferences_state.dart';

/// A representation of the keys in the shared preferences of the target debug
/// session.
typedef KeysResult = ({
  List<String> asyncKeys,
  List<String> legacyKeys,
});

/// A class that provides methods to interact with the shared preferences
/// of the target debug session.
///
/// It abstracts the calls to [EvalOnDartLibrary].
class SharedPreferencesToolEval {
  /// Default constructor for [SharedPreferencesToolEval].
  /// Do not call this constructor directly.
  /// Use [SharedPreferencesStateNotifierProvider] instead.
  SharedPreferencesToolEval(
    this._asyncEval,
    this._legacyEval,
    this._isWeb,
  );

  final EvalOnDartLibrary _asyncEval;
  final EvalOnDartLibrary _legacyEval;
  final bool _isWeb;

  Disposable? _allKeysDisposable;
  Disposable? _valueDisposable;
  Disposable? _changeValueDisposable;
  Disposable? _removeValueDisposable;

  /// Fetches all keys in the shared preferences of the target debug session.
  /// Returns a string list of all keys.
  Future<KeysResult> fetchAllKeys() async {
    _allKeysDisposable?.dispose();
    _allKeysDisposable = Disposable();

    return (
      asyncKeys: await _fetchAsyncKeys(),
      legacyKeys: await _fetchLegacyKeys(),
    );
  }

  /// Fetches the value of the shared preference with the given [key].
  /// Returns a [SharedPreferencesData] object that represents the value.
  /// The type of the value is determined by the type of the shared preference.
  Future<SharedPreferencesData> fetchValue(String key, bool legacy) async {
    _valueDisposable?.dispose();
    _valueDisposable = Disposable();

    final Instance valueInstance =
        await (legacy ? _getLegacyValue(key) : _getAsyncValue(key));

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
          value: await _asyncEval.evalInstance(
            // Converting to set to avoid a bug on web targets.
            // If we don't do this the elements list is empty, even though the
            // length is greater than 0.
            'Set.from(instance)',
            isAlive: _valueDisposable,
            scope: <String, String>{
              'instance': valueInstance.id!,
            },
          ).then((Instance instance) => instance.elements!
              .cast<InstanceRef>()
              .map((InstanceRef ref) => ref.valueAsString!)
              .toList()),
        ),
      _ => throw UnsupportedError(
          'Unsupported value type: ${valueInstance.kind}',
        ),
    };
  }

  /// Changes the value of the key in the shared preferences of the target debug
  /// session.
  Future<void> changeValue(
    String key,
    SharedPreferencesData value,
    bool legacy,
  ) async {
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
    if (legacy) {
      await _legacyEval.legacyPrefsEval(method, _isWeb, _changeValueDisposable);
    } else {
      await _asyncEval.prefsEval(method, _isWeb, _changeValueDisposable);
    }
  }

  /// Deletes the key from the shared preferences of the target debug session.
  Future<void> deleteKey(String key, bool legacy) async {
    _removeValueDisposable?.dispose();
    _removeValueDisposable = Disposable();

    final String method = "remove('$key')";
    if (legacy) {
      await _legacyEval.legacyPrefsEval(method, _isWeb, _removeValueDisposable);
    } else {
      await _asyncEval.prefsEval(method, _isWeb, _removeValueDisposable);
    }
  }

  /// Disposes all the disposables used in this class.
  void dispose() {
    _allKeysDisposable?.dispose();
    _valueDisposable?.dispose();
    _changeValueDisposable?.dispose();
    _removeValueDisposable?.dispose();
    _asyncEval.dispose();
  }

  Future<List<String>> _fetchAsyncKeys() async {
    final Instance keysInstance = await _asyncEval.prefsGetInstance(
      'getKeys()',
      _isWeb,
      _allKeysDisposable,
    );
    return Future.wait(<Future<String>>[
      for (final InstanceRef keyRef
          in keysInstance.elements!.cast<InstanceRef>())
        _asyncEval.safeGetInstance(keyRef, _allKeysDisposable).then(
              (Instance keyInstance) => keyInstance.valueAsString!,
            ),
    ]);
  }

  Future<List<String>> _fetchLegacyKeys() async {
    final Instance keysSetInstance = await _legacyEval.legacyPrefsGetInstance(
      'getKeys()',
      _isWeb,
      _allKeysDisposable,
    );
    return Future.wait(<Future<String>>[
      for (final InstanceRef keyRef
          in keysSetInstance.elements!.cast<InstanceRef>())
        _legacyEval.safeGetInstance(keyRef, _allKeysDisposable).then(
              (Instance keyInstance) => keyInstance.valueAsString!,
            ),
    ]);
  }

  Future<Instance> _getAsyncValue(String key) async {
    return _asyncEval.prefsGetInstance(
      "getAll(allowList: {'$key'}).then((map) => map.values.firstOrNull)",
      _isWeb,
      _valueDisposable,
    );
  }

  Future<Instance> _getLegacyValue(String key) async {
    return _legacyEval.legacyPrefsGetInstance(
      "get('$key')",
      _isWeb,
      _valueDisposable,
    );
  }
}

extension on EvalOnDartLibrary {
  Future<InstanceRef?> prefsEval(
    String method,
    bool isWeb,
    Disposable? isAlive,
  ) async {
    return evalFuture(
      'SharedPreferencesAsync().$method',
      isWeb,
      isAlive,
    );
  }

  Future<Instance> prefsGetInstance(
    String method,
    bool isWeb,
    Disposable? isAlive,
  ) async {
    return safeGetInstance(
      (await prefsEval(method, isWeb, isAlive))!,
      isAlive,
    );
  }

  /// This only works on non-web platforms due to the `asyncEval` call.
  /// This is ok, this won't ever be called on web platforms.
  Future<InstanceRef?> legacyPrefsEval(
    String method,
    bool isWeb,
    Disposable? isAlive,
  ) {
    return evalFuture(
      'SharedPreferences.getInstance().then((prefs) => prefs.$method)',
      isWeb,
      isAlive,
    );
  }

  Future<Instance> legacyPrefsGetInstance(
    String method,
    bool isWeb,
    Disposable? isAlive,
  ) async {
    return safeGetInstance(
      (await legacyPrefsEval(method, isWeb, isAlive))!,
      isAlive,
    );
  }

  /// Evaluates the given [expression].
  ///
  /// Returns the [InstanceRef] of the result.
  /// The [isAlive] parameter is used to dispose the evaluation if the
  /// caller is disposed.
  ///
  /// This method is actually a workaround for the asyncEval method, which is
  /// not working for web targets, check this issue https://github.com/flutter/devtools/issues/7766.
  ///
  /// It does the normal asyncEval on platforms other than web.
  Future<InstanceRef?> evalFuture(
    String expression,
    bool isWeb,
    Disposable? isAlive,
  ) async {
    // If not running on a web target, returns the normal async eval.
    if (!isWeb) {
      return asyncEval(
        'await $expression',
        isAlive: isAlive,
      );
    }

    // Create a empty list in memory to hold the future value instance.
    // It could've been anything that can handle values passed by reference.
    final InstanceRef valueHolderRef = await safeEval(
      '[]',
      isAlive: isAlive,
    );

    // Add the future value instance to the list once the future completes
    await safeEval(
      '$expression.then(valueHolder.add);',
      isAlive: isAlive,
      scope: <String, String>{
        'valueHolder': valueHolderRef.id!,
      },
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
}
