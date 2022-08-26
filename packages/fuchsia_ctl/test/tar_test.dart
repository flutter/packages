// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Pin to 2.9 until tests are migrated away from non-null safe mockito:
// https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md
// @dart=2.9
import 'dart:async';
import 'dart:io';

import 'package:fuchsia_ctl/src/tar.dart';
import 'package:mockito/mockito.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

void main() {
  group('Tar', () {
    test('Untar file times out', () async {
      final MockProcessManager processManager = MockProcessManager();

      when(processManager.run(any)).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 3));
        return ProcessResult(0, 0, 'Good job', '');
      });

      final Tar tar = SystemTar(processManager: processManager);
      try {
        await tar.untar(
          'source.tar',
          '/destination',
          timeoutMs: const Duration(milliseconds: 1),
        );
      } catch (e) {
        expect(e, isA<TimeoutException>());
      }
    });
  });
}

class MockProcessManager extends Mock implements ProcessManager {}
