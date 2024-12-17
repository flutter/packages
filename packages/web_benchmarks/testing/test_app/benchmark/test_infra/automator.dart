// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/home_page.dart' show aboutPageKey, textKey;
import 'package:test_app/main.dart';
import 'package:web/web.dart';
import 'package:web_benchmarks/client.dart';

import 'common.dart';

/// A class that automates the test web app.
class Automator {
  Automator({
    required this.benchmark,
    required this.stopWarmingUpCallback,
    required this.profile,
  });

  /// The current benchmark.
  final BenchmarkName benchmark;

  /// A function to call when warm-up is finished.
  ///
  /// This function is intended to ask `Recorder` to mark the warm-up phase
  /// as over.
  final void Function() stopWarmingUpCallback;

  /// The profile collected for the running benchmark
  final Profile profile;

  /// Whether the automation has ended.
  bool finished = false;

  /// A widget controller for automation.
  late LiveWidgetController controller;

  Widget createWidget() {
    Future<void>.delayed(const Duration(milliseconds: 400), automate);
    return const MyApp();
  }

  Future<void> automate() async {
    await warmUp();

    switch (benchmark) {
      case BenchmarkName.appNavigate:
        await _handleAppNavigate();
      case BenchmarkName.appScroll:
        await _handleAppScroll();
      case BenchmarkName.appTap:
        await _handleAppTap();
      case BenchmarkName.simpleCompilationCheck:
        _handleSimpleCompilationCheck();
      case BenchmarkName.simpleBenchmarkPathCheck:
        _handleSimpleBenchmarkPathCheck();
    }

    // At the end of the test, mark as finished.
    finished = true;
  }

  /// Warm up the animation.
  Future<void> warmUp() async {
    // Let animation stop.
    await animationStops();

    // Set controller.
    controller = LiveWidgetController(WidgetsBinding.instance);

    await controller.pumpAndSettle();

    // When warm-up finishes, inform the recorder.
    stopWarmingUpCallback();
  }

  Future<void> _handleAppNavigate() async {
    for (int i = 0; i < 10; ++i) {
      print('Testing round $i...');
      await controller.tap(find.byKey(aboutPageKey));
      await animationStops();
      await controller.tap(find.byType(BackButton));
      await animationStops();
    }
  }

  Future<void> _handleAppScroll() async {
    final ScrollableState scrollable =
        Scrollable.of(find.byKey(textKey).evaluate().single);
    await scrollable.position.animateTo(
      30000,
      curve: Curves.linear,
      duration: const Duration(seconds: 20),
    );
  }

  Future<void> _handleAppTap() async {
    for (int i = 0; i < 10; ++i) {
      print('Testing round $i...');
      await controller.tap(find.byIcon(Icons.add));
      await animationStops();
    }
  }

  void _handleSimpleCompilationCheck() {
    // Record whether we are in wasm mode or not. Ideally, we'd have a more
    // first-class way to add metadata like this, but this will work for us to
    // pass information about the environment back to the server for the
    // purposes of our own tests.
    profile.extraData['isWasm'] = kIsWasm ? 1 : 0;
  }

  void _handleSimpleBenchmarkPathCheck() {
    // Record whether the URL contains the expected path so we can verify the
    // behavior of setting the `benchmarkPath` on the benchmark server.
    final bool containsExpectedPath =
        window.location.toString().contains(testBenchmarkPath);
    profile.extraData['expectedUrl'] = containsExpectedPath ? 1 : 0;
  }
}

const Duration _animationCheckingInterval = Duration(milliseconds: 50);

Future<void> animationStops() async {
  if (!WidgetsBinding.instance.hasScheduledFrame) {
    return;
  }

  final Completer<void> stopped = Completer<void>();

  Timer.periodic(_animationCheckingInterval, (Timer timer) {
    if (!WidgetsBinding.instance.hasScheduledFrame) {
      stopped.complete();
      timer.cancel();
    }
  });

  await stopped.future;
}
