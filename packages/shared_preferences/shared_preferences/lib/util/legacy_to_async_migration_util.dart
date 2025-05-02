// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../shared_preferences.dart';

/// Migrates preferences from the legacy [SharedPreferences] system to
/// [SharedPreferencesAsync].
///
/// This method can be run multiple times without worry of overwriting transferred data,
/// as long as [migrationCompletedKey] is the same each time, and the value stored
/// under [migrationCompletedKey] in the target preferences system is not modified.
///
/// [legacySharedPreferencesInstance] should be an instance of [SharedPreferences]
/// that has been instantiated the same way it has been used throughout your app.
/// If you have called [SharedPreferences.setPrefix] that must be done before
/// calling this method.
///
/// [sharedPreferencesAsyncOptions] should be an instance of [SharedPreferencesOptions]
/// that is set up the way you intend to use the new system going forward.
/// This tool will allow for future use of [SharedPreferencesAsync] and [SharedPreferencesWithCache].
///
/// The [migrationCompletedKey] is a key that is stored in the target preferences
/// which is used to check if the migration has run before, to avoid overwriting
/// new data going forward. Make sure that there will not be any collisions with
/// preferences you are or will be setting going forward, or there may be data loss.
Future<void> migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary({
  required SharedPreferences legacySharedPreferencesInstance,
  required SharedPreferencesOptions sharedPreferencesAsyncOptions,
  required String migrationCompletedKey,
}) async {
  final SharedPreferencesAsync sharedPreferencesAsyncInstance =
      SharedPreferencesAsync(options: sharedPreferencesAsyncOptions);

  if (await sharedPreferencesAsyncInstance.containsKey(migrationCompletedKey)) {
    return;
  }

  await legacySharedPreferencesInstance.reload();
  final Set<String> keys = legacySharedPreferencesInstance.getKeys();

  for (final String key in keys) {
    final Object? value = legacySharedPreferencesInstance.get(key);
    switch (value.runtimeType) {
      case const (bool):
        await sharedPreferencesAsyncInstance.setBool(key, value! as bool);
      case const (int):
        await sharedPreferencesAsyncInstance.setInt(key, value! as int);
      case const (double):
        await sharedPreferencesAsyncInstance.setDouble(key, value! as double);
      case const (String):
        await sharedPreferencesAsyncInstance.setString(key, value! as String);
      case const (List<String>):
      case const (List<String?>):
      case const (List<Object?>):
      case const (List<dynamic>):
        try {
          await sharedPreferencesAsyncInstance.setStringList(
              key, (value! as List<Object?>).cast<String>());
        } on TypeError catch (_) {} // Pass over Lists containing non-String values.
    }
  }

  await sharedPreferencesAsyncInstance.setBool(migrationCompletedKey, true);

  return;
}
