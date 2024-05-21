// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    final Instance valueInstance = await _eval.prefsGetInstance(
      "get('$key')",
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
  Future<InstanceRef> prefsEval(String method, Disposable? isAlive) async {
    return (await asyncEval(
      '(await SharedPreferences.getInstance()).$method',
      isAlive: isAlive,
    ))!;
  }

  Future<Instance> prefsGetInstance(String method, Disposable? isAlive) async {
    return safeGetInstance(
      prefsEval(method, isAlive),
      isAlive,
    );
  }
}
