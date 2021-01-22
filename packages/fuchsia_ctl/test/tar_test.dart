// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// @dart = 2.4
import 'dart:async';
import 'dart:io';

import 'package:process/process.dart';
import 'package:test/test.dart';
import 'package:fuchsia_ctl/src/tar.dart';
import 'package:mockito/mockito.dart';

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
