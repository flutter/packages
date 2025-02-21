// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

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
    this._service,
    this._eval,
  );

  final VmService _service;
  final EvalOnDartLibrary _eval;

  Disposable? _allKeysDisposable;
  Disposable? _valueDisposable;
  Disposable? _changeValueDisposable;
  Disposable? _removeValueDisposable;

  /// Fetches all keys in the shared preferences of the target debug session.
  /// Returns a string list of all keys.
  Future<KeysResult> fetchAllKeys() async {
    _allKeysDisposable?.dispose();
    _allKeysDisposable = Disposable();
    final Map<String, Object?> data = await _evalMethod(
      method: 'requestAllKeys()',
      eventKind: 'all_keys',
      isAlive: _allKeysDisposable,
    );

    List<String> castList(String key) {
      return (data[key]! as List<Object?>).cast();
    }

    return (
      asyncKeys: castList('asyncKeys'),
      legacyKeys: castList('legacyKeys'),
    );
  }

  Future<Map<String, Object?>> _evalMethod({
    required String method,
    required String eventKind,
    Disposable? isAlive,
  }) async {
    final Completer<Map<String, Object?>> completer =
        Completer<Map<String, Object?>>();

    late final StreamSubscription<Event> streamSubscription;
    streamSubscription = _service.onExtensionEvent.listen((Event event) {
      // The event prefix and event kind are defined in `shared_preferences_devtools_extension_data.dart`
      // from the `shared_preferences` package.
      if (event.extensionKind == 'shared_preferences.$eventKind') {
        streamSubscription.cancel();
        completer.complete(event.extensionData!.data);
      }
    });

    await _eval.eval(
      'SharedPreferencesDevToolsExtensionData().$method',
      isAlive: isAlive,
    );

    return completer.future;
  }

  /// Fetches the value of the shared preference with the given [key].
  /// Returns a [SharedPreferencesData] object that represents the value.
  /// The type of the value is determined by the type of the shared preference.
  Future<SharedPreferencesData> fetchValue(String key, bool legacy) async {
    _valueDisposable?.dispose();
    _valueDisposable = Disposable();

    final Map<String, Object?> data = await _evalMethod(
      method: "requestValue('$key', $legacy)",
      eventKind: 'value',
      isAlive: _valueDisposable,
    );

    final Object value = data['value']!;
    final Object? kind = data['kind'];

    // we need to check the kind because sometimes a double
    // gets interpreted as an int. If this was not and issue
    // we'd only need to do a simple pattern matching on value.
    return switch (kind) {
      'int' => SharedPreferencesData.int(
          value: value as int,
        ),
      'bool' => SharedPreferencesData.bool(
          value: value as bool,
        ),
      'double' => SharedPreferencesData.double(
          value: value as double,
        ),
      'String' => SharedPreferencesData.string(
          value: value as String,
        ),
      String() when kind.contains('List') => SharedPreferencesData.stringList(
          value: (value as List<Object?>).cast(),
        ),
      _ => throw UnsupportedError(
          'Unsupported value type: $kind',
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

    final String serializedValue = jsonEncode(value.value);
    final String kind = value.kind;
    await _evalMethod(
      method:
          "requestValueChange('$key', '$serializedValue', '$kind', $legacy)",
      eventKind: 'change_value',
      isAlive: _changeValueDisposable,
    );
  }

  /// Deletes the key from the shared preferences of the target debug session.
  Future<void> deleteKey(String key, bool legacy) async {
    _removeValueDisposable?.dispose();
    _removeValueDisposable = Disposable();

    await _evalMethod(
      method: "requestRemoveKey('$key', $legacy)",
      eventKind: 'remove',
      isAlive: _removeValueDisposable,
    );
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
