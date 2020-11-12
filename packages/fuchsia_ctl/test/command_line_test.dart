// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// @dart = 2.4
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import 'package:fuchsia_ctl/src/command_line.dart';

import 'fakes.dart';

void main() {
  CommandLine cli;
  MockProcessManager mockProcessManager;
  MockStdout mockStdout;
  MockStdout mockStderr;

  group('CommandLine', () {
    setUp(() {
      mockStdout = MockStdout();
      mockStderr = MockStdout();
      mockProcessManager = MockProcessManager();
      cli = CommandLine(
          processManager: mockProcessManager,
          stderrValue: mockStderr,
          stdoutValue: mockStdout);
    });

    test('run writes to stdout', () async {
      when(mockProcessManager.run(any))
          .thenAnswer((_) async => ProcessResult(123, 0, 'stdout123', ''));

      await cli.run(<String>['test']);

      verify(mockStdout.writeln('stdout123')).called(1);
    });

    test('run writes to stderr', () async {
      when(mockProcessManager.run(any))
          .thenAnswer((_) async => ProcessResult(123, 0, '', 'stderrABC'));

      await cli.run(<String>['test']);

      verify(mockStderr.writeln('stderrABC')).called(1);
    });

    test('run throws on non-0 exit code', () async {
      when(mockProcessManager.run(any))
          .thenAnswer((_) async => ProcessResult(123, 1, '', 'stderrABC'));

      expect(cli.run(<String>['test']), throwsA(isA<CommandLineException>()));
    });

    test('start adds streams', () async {
      when(mockProcessManager.start(any))
          .thenAnswer((_) async => FakeProcess(0, <String>[''], <String>['']));

      await cli.start(<String>['test']);

      verify(mockStdout.addStream(any)).called(1);
      verify(mockStderr.addStream(any)).called(1);
    });

    test('start throws on non-0 exit code', () async {
      when(mockProcessManager.start(any))
          .thenAnswer((_) async => FakeProcess(1, <String>[''], <String>['']));

      expect(cli.start(<String>['test']), throwsA(isA<CommandLineException>()));
    });
  });
}

class MockProcessManager extends Mock implements ProcessManager {}

class MockStdout extends Mock implements Stdout {}
