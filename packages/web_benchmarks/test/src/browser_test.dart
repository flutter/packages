// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:web_benchmarks/src/browser.dart';

import 'browser_test_json_samples.dart';

void main() {
  group('BlinkTraceEvent works with Chrome 89+', () {
    // Used to test 'false' results
    final BlinkTraceEvent unrelatedPhX =
        BlinkTraceEvent.fromJson(unrelatedPhXJson);
    final BlinkTraceEvent anotherUnrelated =
        BlinkTraceEvent.fromJson(anotherUnrelatedJson);

    test('isBeginFrame', () {
      final BlinkTraceEvent event =
          BlinkTraceEvent.fromJson(beginMainFrameJson);

      expect(event.isBeginFrame, isTrue);
      expect(unrelatedPhX.isBeginFrame, isFalse);
      expect(anotherUnrelated.isBeginFrame, isFalse);
    });

    test('isUpdateAllLifecyclePhases', () {
      final BlinkTraceEvent event =
          BlinkTraceEvent.fromJson(updateLifecycleJson);

      expect(event.isUpdateAllLifecyclePhases, isTrue);
      expect(unrelatedPhX.isUpdateAllLifecyclePhases, isFalse);
      expect(anotherUnrelated.isUpdateAllLifecyclePhases, isFalse);
    });

    test('isBeginMeasuredFrame', () {
      final BlinkTraceEvent event =
          BlinkTraceEvent.fromJson(beginMeasuredFrameJson);

      expect(event.isBeginMeasuredFrame, isTrue);
      expect(unrelatedPhX.isBeginMeasuredFrame, isFalse);
      expect(anotherUnrelated.isBeginMeasuredFrame, isFalse);
    });

    test('isEndMeasuredFrame', () {
      final BlinkTraceEvent event =
          BlinkTraceEvent.fromJson(endMeasuredFrameJson);

      expect(event.isEndMeasuredFrame, isTrue);
      expect(unrelatedPhX.isEndMeasuredFrame, isFalse);
      expect(anotherUnrelated.isEndMeasuredFrame, isFalse);
    });
  });
}
