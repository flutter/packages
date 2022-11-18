import 'dart:async';

import 'package:flutter/foundation.dart' as foundation;

import '_compute_io.dart' if (dart.library.html) '_compute_none.dart';

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
  } else {
    return foundation.SynchronousFuture<R>(result);
  }
}

/// A compute implementation that does not spawn isolates in tests.
final foundation.ComputeImpl compute =
    isTest ? _testCompute : foundation.compute;
