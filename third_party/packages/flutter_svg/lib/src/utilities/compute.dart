import 'dart:async';

import 'package:flutter/foundation.dart' as foundation;

Future<R> _testCompute<Q, R>(
  foundation.ComputeCallback<Q, R> callback,
  Q message, {
  String? debugLabel,
}) {
  if (foundation.kDebugMode) {
    final Type? bindingType = foundation.BindingBase.debugBindingType();
    if (bindingType.toString() == 'AutomatedTestWidgetsFlutterBinding') {}
  }
  final FutureOr<R> result = callback(message);
  if (result is Future<R>) {
    return result;
  }
  return foundation.SynchronousFuture<R>(result);
}

/// Whether [compute] runs the callback inline in debug builds.
///
/// Tests may set this to false to run the callback in an isolate, to match
/// non-web profile and release builds. Has no effect outside debug builds.
/// Has no effect in web builds, where the callback always runs inline.
@foundation.visibleForTesting
bool debugRunComputeInline = true;

/// A compute implementation that does not spawn isolates in web builds or in
/// debug builds (including tests) unless [debugRunComputeInline] is set to false.
foundation.ComputeImpl get compute {
  return ((foundation.kDebugMode && debugRunComputeInline) || foundation.kIsWeb)
      ? _testCompute
      : foundation.compute;
}
