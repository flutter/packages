// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../bin/util/isolate_processor.dart';
import '../bin/vector_graphics_compiler.dart' as cli;

void main() {
  final File output = File('test_data/example.vec');
  final File outputDebug = File('test_data/example.vec.debug');

  test('currentColor/font-size works', () async {
    try {
      await cli.main(<String>[
        '-i',
        'test_data/example.svg',
        '-o',
        output.path,
        '--current-color',
        'red',
        '--font-size',
        '12',
        '--dump-debug',
      ]);
      expect(output.existsSync(), true);
      expect(outputDebug.existsSync(), true);
    } finally {
      if (output.existsSync()) {
        output.deleteSync();
      }
      if (outputDebug.existsSync()) {
        outputDebug.deleteSync();
      }
    }
  });

  test('Can run with isolate processor', () async {
    try {
      final IsolateProcessor processor = IsolateProcessor(null, null, 4);
      final bool result = await processor.process(
        <Pair>[
          Pair('test_data/example.svg', output.path),
        ],
        maskingOptimizerEnabled: false,
        clippingOptimizerEnabled: false,
        overdrawOptimizerEnabled: false,
        tessellate: false,
        dumpDebug: false,
        useHalfPrecisionControlPoints: false,
      );
      expect(result, isTrue);
      expect(output.existsSync(), isTrue);
    } finally {
      if (output.existsSync()) {
        output.deleteSync();
      }
    }
  });

  test('Can dump debug format with isolate processor', () async {
    try {
      final IsolateProcessor processor = IsolateProcessor(null, null, 4);
      final bool result = await processor.process(
        <Pair>[
          Pair('test_data/example.svg', output.path),
        ],
        maskingOptimizerEnabled: false,
        clippingOptimizerEnabled: false,
        overdrawOptimizerEnabled: false,
        tessellate: false,
        dumpDebug: true,
        useHalfPrecisionControlPoints: false,
      );
      expect(result, isTrue);
      expect(output.existsSync(), isTrue);
      expect(outputDebug.existsSync(), isTrue);
    } finally {
      if (output.existsSync()) {
        output.deleteSync();
      }
      if (outputDebug.existsSync()) {
        outputDebug.deleteSync();
      }
    }
  });

  test('out-dir option works', () async {
    const String inputTestDir = 'test_data';

    const String outTestDir = 'output_vec';

    try {
      await cli.main(<String>[
        '--input-dir',
        inputTestDir,
        '--out-dir',
        outTestDir,
      ]);

      bool passed = false;

      final Directory inputDir = Directory(inputTestDir);
      final Directory outDir = Directory(outTestDir);

      if (inputDir.existsSync() && outDir.existsSync()) {
        final List<String> inputTestFiles = inputDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((File element) => element.path.endsWith('svg'))
            .map((File e) => p.basenameWithoutExtension(e.path))
            .toList();

        final List<String> outTestFiles = outDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((File element) => element.path.endsWith('vec'))
            .map((File e) =>
                p.withoutExtension(p.basenameWithoutExtension(e.path)))
            .toList();

        if (listEquals(inputTestFiles, outTestFiles)) {
          passed = true;
        }
      }

      expect(passed, true);
    } finally {
      if (Directory(outTestDir).existsSync()) {
        Directory(outTestDir).deleteSync(recursive: true);
      }
    }
  });
}
