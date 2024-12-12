import 'dart:async';

import 'package:flutter/foundation.dart' as foundation;

Future<R> _testCompute<Q, R>(
    foundation.ComputeCallback<Q, R> callback, Q message,
    {String? debugLabel}) {
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

/// A compute implementation that does not spawn isolates in tests.
const foundation.ComputeImpl compute =
    (foundation.kDebugMode || foundation.kIsWeb)
        ? _testCompute
        : foundation.compute;
