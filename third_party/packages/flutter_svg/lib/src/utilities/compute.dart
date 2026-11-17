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

const foundation.ComputeImpl _defaultCompute = (foundation.kDebugMode || foundation.kIsWeb)
    ? _testCompute
    : foundation.compute;

/// Replaces [compute] in tests, for example with [foundation.compute] to
/// spawn a real isolate in a debug build.
@foundation.visibleForTesting
foundation.ComputeImpl? debugComputeOverride;

/// A compute implementation that does not spawn isolates in tests.
Future<R> compute<M, R>(
  foundation.ComputeCallback<M, R> callback,
  M message, {
  String? debugLabel,
}) => (debugComputeOverride ?? _defaultCompute)(callback, message, debugLabel: debugLabel);
