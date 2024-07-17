// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// Detects if we're running the tests on the main channel.
//
// This is useful for _tests_ that depend on _Flutter_ features that have not
// yet rolled to stable. Avoid using this to skip tests of _RFW_ features that
// aren't compatible with stable. Those should wait until the stable release
// channel is updated so that RFW can be compatible with it.
bool get isMainChannel {
  assert(!kIsWeb, 'isMainChannel is not available on web');
  return !Platform.environment.containsKey('CHANNEL') ||
      Platform.environment['CHANNEL'] == 'main' ||
      Platform.environment['CHANNEL'] == 'master';
}

// See Contributing section of README.md file.
final bool runGoldens = !kIsWeb && Platform.isLinux && isMainChannel;

/// Sets [_TolerantGoldenFileComparator] as the default golden file comparator
/// in tests.
void setUpTolerantComparator(
    {required String testPath, required double precisionTolerance}) {
  if (!kIsWeb) {
    final GoldenFileComparator oldComparator = goldenFileComparator;
    final _TolerantGoldenFileComparator newComparator =
        _TolerantGoldenFileComparator(Uri.parse(testPath),
            precisionTolerance: precisionTolerance);

    goldenFileComparator = newComparator;

    addTearDown(() => goldenFileComparator = oldComparator);
  }
}

class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(
    super.testFile, {
    required double precisionTolerance,
  })  : assert(
          0 <= precisionTolerance && precisionTolerance <= 1,
          'precisionTolerance must be between 0 and 1',
        ),
        _precisionTolerance = precisionTolerance;

  /// How much the golden image can differ from the test image.
  ///
  /// It is expected to be between 0 and 1. Where 0 is no difference (the same image)
  /// and 1 is the maximum difference (completely different images).
  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    final bool passed =
        result.passed || result.diffPercent <= _precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final String error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
