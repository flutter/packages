// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// @dart = 2.4
import 'dart:io';

import 'package:fuchsia_ctl/fuchsia_ctl.dart';
import 'package:mockito/mockito.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

void main() {
  const String ffxPath = 'ffx';
  const String multipleDevicesIPs = 'target-ip\nsome-other-device-ip';
  const String targetIp = 'target-ip';

  test('finds target address with no device name', () async {
    final MockProcessManager mockProcessManager = MockProcessManager();
    when(mockProcessManager.run(<String>[
      ffxPath,
      'target',
      'list',
      '--format',
      'a',
    ])).thenAnswer((_) async => ProcessResult(123, 0, multipleDevicesIPs, ''));

    final FFX ffx = FFX(
      ffxPath,
      processManager: mockProcessManager,
    );

    expect(await ffx.getTargetAddress(null), targetIp);
  });

  test('finds target address with device name', () async {
    final MockProcessManager mockProcessManager = MockProcessManager();
    when(mockProcessManager.run(<String>[
      ffxPath,
      'target',
      'list',
      '--format',
      'a',
      'devicename',
    ])).thenAnswer((_) async => ProcessResult(123, 0, targetIp, ''));

    final FFX ffx = FFX(
      ffxPath,
      processManager: mockProcessManager,
    );

    expect(await ffx.getTargetAddress('devicename'), targetIp);
  });

  test('retries', () async {
    final MockProcessManager mockProcessManager = MockProcessManager();

    int tries = 0;
    when(mockProcessManager.run(<String>[
      ffxPath,
      'target',
      'list',
      '--format',
      'a',
      'devicename',
    ])).thenAnswer((_) async {
      tries++;
      if (tries < 4) {
        return ProcessResult(123, 1, '', 'Simulating device not ready yet...');
      }
      return ProcessResult(123, 0, targetIp, '');
    });

    final FFX ffx = FFX(
      ffxPath,
      processManager: mockProcessManager,
    );

    expect(
      await ffx.getTargetAddress('devicename', sleepDelay: 0),
      targetIp,
    );
    expect(tries, 4);
  });
}

class MockProcessManager extends Mock implements ProcessManager {}
