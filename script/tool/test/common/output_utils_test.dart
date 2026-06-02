// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter_plugin_tools/src/common/output_utils.dart';
import 'package:test/test.dart';

void main() {
  group('with color support', () {
    setUp(() {
      useColorForOutput = true;
    });

    tearDown(() {
      useColorForOutput = stdout.supportsAnsiEscapes;
    });

    test('colorize works', () async {
      const message = 'a message';

      expect(
        colorizeString(message, Styles.MAGENTA),
        '\x1B[35m$message\x1B[0m',
      );
    });

    test('printSuccess is green', () async {
      const message = 'a message';

      expect(
        await _capturePrint(() => printSuccess(message)),
        '\x1B[32m$message\x1B[0m',
      );
    });

    test('printWarning is yellow', () async {
      const message = 'a message';

      expect(
        await _capturePrint(() => printWarning(message)),
        '\x1B[33m$message\x1B[0m',
      );
    });

    test('printError is red', () async {
      const message = 'a message';

      expect(
        await _capturePrint(() => printError(message)),
        '\x1B[31m$message\x1B[0m',
      );
    });
  });

  group('without color support', () {
    setUp(() {
      useColorForOutput = false;
    });

    tearDown(() {
      useColorForOutput = stdout.supportsAnsiEscapes;
    });

    test('colorize no-ops', () async {
      const message = 'a message';

      expect(colorizeString(message, Styles.MAGENTA), message);
    });

    test('printSuccess just prints', () async {
      const message = 'a message';

      expect(await _capturePrint(() => printSuccess(message)), message);
    });

    test('printWarning just prints', () async {
      const message = 'a message';

      expect(await _capturePrint(() => printWarning(message)), message);
    });

    test('printError just prints', () async {
      const message = 'a message';

      expect(await _capturePrint(() => printError(message)), message);
    });
  });
}

/// Run the command [runner] with the given [args] and return
/// what was printed.
/// A custom [errorHandler] can be used to handle the runner error as desired without throwing.
Future<String> _capturePrint(void Function() printFunction) async {
  final output = StringBuffer();
  final spec = ZoneSpecification(
    print: (_, __, ___, String message) {
      output.write(message);
    },
  );
  await Zone.current
      .fork(specification: spec)
      .run<Future<void>>(() async => printFunction());

  return output.toString();
}
