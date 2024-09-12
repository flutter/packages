// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:web_benchmarks/client.dart';

import 'automator.dart';
import 'common.dart';

/// A recorder that measures frame building durations for the test app.
class TestAppRecorder extends WidgetRecorder {
  TestAppRecorder({required this.benchmark})
      : super(name: benchmark.name, useCustomWarmUp: true);

  /// The name of the benchmark to be run.
  ///
  /// See `common.dart` for the list of the names of all benchmarks.
  final BenchmarkName benchmark;

  Automator? _automator;
  bool get _finished => _automator?.finished ?? false;

  /// Whether we should continue recording.
  @override
  bool shouldContinue() => !_finished || profile.shouldContinue();

  /// Creates the [Automator] widget.
  @override
  Widget createWidget() {
    _automator = Automator(
      benchmark: benchmark,
      stopWarmingUpCallback: profile.stopWarmingUp,
      profile: profile,
    );
    return _automator!.createWidget();
  }
}
