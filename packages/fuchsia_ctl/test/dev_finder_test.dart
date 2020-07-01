// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:fuchsia_ctl/fuchsia_ctl.dart';
import 'package:mockito/mockito.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

void main() {
  const String devFinderPath = 'device-finder';
  const String targetIp = 'target_ip';
  const String localIp = 'local_ip';

  test('finds local address with no device name', () async {
    final MockProcessManager mockProcessManager = MockProcessManager();
    when(mockProcessManager.run(<String>[
      devFinderPath,
      'list',
      '-device-limit',
      '1',
      '-local',
    ])).thenAnswer((_) async => ProcessResult(123, 0, localIp, ''));

    final DevFinder devFinder = DevFinder(
      devFinderPath,
      processManager: mockProcessManager,
    );

    expect(await devFinder.getLocalAddress(null), localIp);
  });

  test('finds local address with device name', () async {
    final MockProcessManager mockProcessManager = MockProcessManager();
    when(mockProcessManager.run(<String>[
      devFinderPath,
      'resolve',
      '-device-limit',
      '1',
      '-local',
      'devicename',
    ])).thenAnswer((_) async => ProcessResult(123, 0, localIp, ''));

    final DevFinder devFinder = DevFinder(
      devFinderPath,
      processManager: mockProcessManager,
    );

    expect(await devFinder.getLocalAddress('devicename'), localIp);
  });

  test('finds target address with no device name', () async {
    final MockProcessManager mockProcessManager = MockProcessManager();
    when(mockProcessManager.run(<String>[
      devFinderPath,
      'list',
      '-device-limit',
      '1',
    ])).thenAnswer((_) async => ProcessResult(123, 0, targetIp, ''));

    final DevFinder devFinder = DevFinder(
      devFinderPath,
      processManager: mockProcessManager,
    );

    expect(await devFinder.getTargetAddress(null), targetIp);
  });

  test('finds target address with device name', () async {
    final MockProcessManager mockProcessManager = MockProcessManager();
    when(mockProcessManager.run(<String>[
      devFinderPath,
      'resolve',
      '-device-limit',
      '1',
      'devicename',
    ])).thenAnswer((_) async => ProcessResult(123, 0, targetIp, ''));

    final DevFinder devFinder = DevFinder(
      devFinderPath,
      processManager: mockProcessManager,
    );

    expect(await devFinder.getTargetAddress('devicename'), targetIp);
  });

  test('retries', () async {
    final MockProcessManager mockProcessManager = MockProcessManager();

    int tries = 0;
    when(mockProcessManager.run(<String>[
      devFinderPath,
      'resolve',
      '-device-limit',
      '1',
      'devicename',
    ])).thenAnswer((_) async {
      tries++;
      if (tries < 4) {
        return ProcessResult(123, 1, '', 'Simulating device not ready yet...');
      }
      return ProcessResult(123, 0, targetIp, '');
    });

    final DevFinder devFinder = DevFinder(
      devFinderPath,
      processManager: mockProcessManager,
    );

    expect(
      await devFinder.getTargetAddress('devicename', sleepDelay: 0),
      targetIp,
    );
    expect(tries, 4);
  });
}

class MockProcessManager extends Mock implements ProcessManager {}
