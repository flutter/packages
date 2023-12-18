// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_migrate/src/base/io.dart';
import 'package:flutter_migrate/src/base/logger.dart';
import 'package:flutter_migrate/src/base/terminal.dart';
import 'package:test/fake.dart';

import '../src/common.dart';
import '../src/fakes.dart';

void main() {
  testWithoutContext('correct logger instance is created', () {
    final LoggerFactory loggerFactory = LoggerFactory(
      terminal: Terminal.test(),
      stdio: FakeStdio(),
      outputPreferences: OutputPreferences.test(),
    );

    expect(
        loggerFactory.createLogger(
          windows: false,
        ),
        isA<StdoutLogger>());
    expect(
        loggerFactory.createLogger(
          windows: true,
        ),
        isA<WindowsStdoutLogger>());
  });

  testWithoutContext(
      'WindowsStdoutLogger rewrites emojis when terminal does not support emoji',
      () {
    final FakeStdio stdio = FakeStdio();
    final WindowsStdoutLogger logger = WindowsStdoutLogger(
      outputPreferences: OutputPreferences.test(),
      stdio: stdio,
      terminal: Terminal.test(),
    );

    logger.printStatus('🔥🖼️✗✓🔨💪✏️');

    expect(stdio.writtenToStdout, <String>['X√\n']);
  });

  testWithoutContext(
      'WindowsStdoutLogger does not rewrite emojis when terminal does support emoji',
      () {
    final FakeStdio stdio = FakeStdio();
    final WindowsStdoutLogger logger = WindowsStdoutLogger(
      outputPreferences: OutputPreferences.test(),
      stdio: stdio,
      terminal: Terminal.test(supportsColor: true, supportsEmoji: true),
    );

    logger.printStatus('🔥🖼️✗✓🔨💪✏️');

    expect(stdio.writtenToStdout, <String>['🔥🖼️✗✓🔨💪✏️\n']);
  });
  testWithoutContext(
      'Logger does not throw when stdio write throws synchronously', () async {
    final FakeStdout stdout = FakeStdout(syncError: true);
    final FakeStdout stderr = FakeStdout(syncError: true);
    final Stdio stdio = Stdio.test(stdout: stdout, stderr: stderr);
    final Logger logger = StdoutLogger(
      terminal: AnsiTerminal(
        stdio: stdio,
      ),
      stdio: stdio,
      outputPreferences: OutputPreferences.test(),
    );

    logger.printStatus('message');
    logger.printError('error message');
  });

  testWithoutContext(
      'Logger does not throw when stdio write throws asynchronously', () async {
    final FakeStdout stdout = FakeStdout(syncError: false);
    final FakeStdout stderr = FakeStdout(syncError: false);
    final Stdio stdio = Stdio.test(stdout: stdout, stderr: stderr);
    final Logger logger = StdoutLogger(
      terminal: AnsiTerminal(
        stdio: stdio,
      ),
      stdio: stdio,
      outputPreferences: OutputPreferences.test(),
    );
    logger.printStatus('message');
    logger.printError('error message');

    await stdout.done;
    await stderr.done;
  });

  testWithoutContext(
      'Logger does not throw when stdio completes done with an error',
      () async {
    final FakeStdout stdout =
        FakeStdout(syncError: false, completeWithError: true);
    final FakeStdout stderr =
        FakeStdout(syncError: false, completeWithError: true);
    final Stdio stdio = Stdio.test(stdout: stdout, stderr: stderr);
    final Logger logger = StdoutLogger(
      terminal: AnsiTerminal(
        stdio: stdio,
      ),
      stdio: stdio,
      outputPreferences: OutputPreferences.test(),
    );
    logger.printStatus('message');
    logger.printError('error message');

    expect(() async => stdout.done, throwsException);
    expect(() async => stderr.done, throwsException);
  });

  group('Output format', () {
    late FakeStdio fakeStdio;
    late SummaryStatus summaryStatus;
    late int called;

    setUp(() {
      fakeStdio = FakeStdio();
      called = 0;
      summaryStatus = SummaryStatus(
        message: 'Hello world',
        padding: 20,
        onFinish: () => called++,
        stdio: fakeStdio,
        stopwatch: FakeStopwatch(),
      );
    });

    List<String> outputStdout() => fakeStdio.writtenToStdout.join().split('\n');
    List<String> outputStderr() => fakeStdio.writtenToStderr.join().split('\n');

    testWithoutContext('Error logs are wrapped', () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(wrapText: true, wrapColumn: 40),
      );
      logger.printError('0123456789' * 15);
      final List<String> lines = outputStderr();

      expect(outputStdout().length, equals(1));
      expect(outputStdout().first, isEmpty);
      expect(lines[0], equals('0123456789' * 4));
      expect(lines[1], equals('0123456789' * 4));
      expect(lines[2], equals('0123456789' * 4));
      expect(lines[3], equals('0123456789' * 3));
    });

    testWithoutContext('Error logs are wrapped and can be indented.', () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(wrapText: true, wrapColumn: 40),
      );
      logger.printError('0123456789' * 15, indent: 5);
      final List<String> lines = outputStderr();

      expect(outputStdout().length, equals(1));
      expect(outputStdout().first, isEmpty);
      expect(lines.length, equals(6));
      expect(lines[0], equals('     01234567890123456789012345678901234'));
      expect(lines[1], equals('     56789012345678901234567890123456789'));
      expect(lines[2], equals('     01234567890123456789012345678901234'));
      expect(lines[3], equals('     56789012345678901234567890123456789'));
      expect(lines[4], equals('     0123456789'));
      expect(lines[5], isEmpty);
    });

    testWithoutContext('Error logs are wrapped and can have hanging indent.',
        () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(wrapText: true, wrapColumn: 40),
      );
      logger.printError('0123456789' * 15, hangingIndent: 5);
      final List<String> lines = outputStderr();

      expect(outputStdout().length, equals(1));
      expect(outputStdout().first, isEmpty);
      expect(lines.length, equals(6));
      expect(lines[0], equals('0123456789012345678901234567890123456789'));
      expect(lines[1], equals('     01234567890123456789012345678901234'));
      expect(lines[2], equals('     56789012345678901234567890123456789'));
      expect(lines[3], equals('     01234567890123456789012345678901234'));
      expect(lines[4], equals('     56789'));
      expect(lines[5], isEmpty);
    });

    testWithoutContext(
        'Error logs are wrapped, indented, and can have hanging indent.',
        () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(wrapText: true, wrapColumn: 40),
      );
      logger.printError('0123456789' * 15, indent: 4, hangingIndent: 5);
      final List<String> lines = outputStderr();

      expect(outputStdout().length, equals(1));
      expect(outputStdout().first, isEmpty);
      expect(lines.length, equals(6));
      expect(lines[0], equals('    012345678901234567890123456789012345'));
      expect(lines[1], equals('         6789012345678901234567890123456'));
      expect(lines[2], equals('         7890123456789012345678901234567'));
      expect(lines[3], equals('         8901234567890123456789012345678'));
      expect(lines[4], equals('         901234567890123456789'));
      expect(lines[5], isEmpty);
    });

    testWithoutContext('Stdout logs are wrapped', () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(wrapText: true, wrapColumn: 40),
      );
      logger.printStatus('0123456789' * 15);
      final List<String> lines = outputStdout();

      expect(outputStderr().length, equals(1));
      expect(outputStderr().first, isEmpty);
      expect(lines[0], equals('0123456789' * 4));
      expect(lines[1], equals('0123456789' * 4));
      expect(lines[2], equals('0123456789' * 4));
      expect(lines[3], equals('0123456789' * 3));
    });

    testWithoutContext('Stdout logs are wrapped and can be indented.',
        () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(wrapText: true, wrapColumn: 40),
      );
      logger.printStatus('0123456789' * 15, indent: 5);
      final List<String> lines = outputStdout();

      expect(outputStderr().length, equals(1));
      expect(outputStderr().first, isEmpty);
      expect(lines.length, equals(6));
      expect(lines[0], equals('     01234567890123456789012345678901234'));
      expect(lines[1], equals('     56789012345678901234567890123456789'));
      expect(lines[2], equals('     01234567890123456789012345678901234'));
      expect(lines[3], equals('     56789012345678901234567890123456789'));
      expect(lines[4], equals('     0123456789'));
      expect(lines[5], isEmpty);
    });

    testWithoutContext('Stdout logs are wrapped and can have hanging indent.',
        () async {
      final Logger logger = StdoutLogger(
          terminal: AnsiTerminal(
            stdio: fakeStdio,
          ),
          stdio: fakeStdio,
          outputPreferences:
              OutputPreferences.test(wrapText: true, wrapColumn: 40));
      logger.printStatus('0123456789' * 15, hangingIndent: 5);
      final List<String> lines = outputStdout();

      expect(outputStderr().length, equals(1));
      expect(outputStderr().first, isEmpty);
      expect(lines.length, equals(6));
      expect(lines[0], equals('0123456789012345678901234567890123456789'));
      expect(lines[1], equals('     01234567890123456789012345678901234'));
      expect(lines[2], equals('     56789012345678901234567890123456789'));
      expect(lines[3], equals('     01234567890123456789012345678901234'));
      expect(lines[4], equals('     56789'));
      expect(lines[5], isEmpty);
    });

    testWithoutContext(
        'Stdout logs are wrapped, indented, and can have hanging indent.',
        () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(wrapText: true, wrapColumn: 40),
      );
      logger.printStatus('0123456789' * 15, indent: 4, hangingIndent: 5);
      final List<String> lines = outputStdout();

      expect(outputStderr().length, equals(1));
      expect(outputStderr().first, isEmpty);
      expect(lines.length, equals(6));
      expect(lines[0], equals('    012345678901234567890123456789012345'));
      expect(lines[1], equals('         6789012345678901234567890123456'));
      expect(lines[2], equals('         7890123456789012345678901234567'));
      expect(lines[3], equals('         8901234567890123456789012345678'));
      expect(lines[4], equals('         901234567890123456789'));
      expect(lines[5], isEmpty);
    });

    testWithoutContext('Error logs are red', () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
          supportsColor: true,
        ),
        stdio: fakeStdio,
        outputPreferences: OutputPreferences.test(showColor: true),
      );
      logger.printError('Pants on fire!');
      final List<String> lines = outputStderr();

      expect(outputStdout().length, equals(1));
      expect(outputStdout().first, isEmpty);
      expect(
          lines[0],
          equals(
              '${AnsiTerminal.red}Pants on fire!${AnsiTerminal.resetColor}'));
    });

    testWithoutContext('Stdout logs are not colored', () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences: OutputPreferences.test(showColor: true),
      );
      logger.printStatus('All good.');

      final List<String> lines = outputStdout();
      expect(outputStderr().length, equals(1));
      expect(outputStderr().first, isEmpty);
      expect(lines[0], equals('All good.'));
    });

    testWithoutContext('Stdout printBox puts content inside a box', () {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences: OutputPreferences.test(showColor: true),
      );
      logger.printBox('Hello world', title: 'Test title');
      final String stdout = fakeStdio.writtenToStdout.join();
      expect(
        stdout,
        contains('\n'
            '┌─ Test title ┐\n'
            '│ Hello world │\n'
            '└─────────────┘\n'),
      );
    });

    testWithoutContext('Stdout printBox does not require title', () {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences: OutputPreferences.test(showColor: true),
      );
      logger.printBox('Hello world');
      final String stdout = fakeStdio.writtenToStdout.join();
      expect(
        stdout,
        contains('\n'
            '┌─────────────┐\n'
            '│ Hello world │\n'
            '└─────────────┘\n'),
      );
    });

    testWithoutContext('Stdout printBox handles new lines', () {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences: OutputPreferences.test(showColor: true),
      );
      logger.printBox('Hello world\nThis is a new line', title: 'Test title');
      final String stdout = fakeStdio.writtenToStdout.join();
      expect(
        stdout,
        contains('\n'
            '┌─ Test title ───────┐\n'
            '│ Hello world        │\n'
            '│ This is a new line │\n'
            '└────────────────────┘\n'),
      );
    });

    testWithoutContext(
        'Stdout printBox handles content with ANSI escape characters', () {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences: OutputPreferences.test(showColor: true),
      );
      const String bold = '\u001B[1m';
      const String clear = '\u001B[2J\u001B[H';
      logger.printBox('${bold}Hello world$clear', title: 'Test title');
      final String stdout = fakeStdio.writtenToStdout.join();
      expect(
        stdout,
        contains('\n'
            '┌─ Test title ┐\n'
            '│ ${bold}Hello world$clear │\n'
            '└─────────────┘\n'),
      );
    });

    testWithoutContext('Stdout printBox handles column limit', () {
      const int columnLimit = 14;
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(showColor: true, wrapColumn: columnLimit),
      );
      logger.printBox('This line is longer than $columnLimit characters',
          title: 'Test');
      final String stdout = fakeStdio.writtenToStdout.join();
      final List<String> stdoutLines = stdout.split('\n');

      expect(stdoutLines.length, greaterThan(1));
      expect(stdoutLines[1].length, equals(columnLimit));
      expect(
        stdout,
        contains('\n'
            '┌─ Test ─────┐\n'
            '│ This line  │\n'
            '│ is longer  │\n'
            '│ than 14    │\n'
            '│ characters │\n'
            '└────────────┘\n'),
      );
    });

    testWithoutContext(
        'Stdout printBox handles column limit and respects new lines', () {
      const int columnLimit = 14;
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(showColor: true, wrapColumn: columnLimit),
      );
      logger.printBox('This\nline is longer than\n\n$columnLimit characters',
          title: 'Test');
      final String stdout = fakeStdio.writtenToStdout.join();
      final List<String> stdoutLines = stdout.split('\n');

      expect(stdoutLines.length, greaterThan(1));
      expect(stdoutLines[1].length, equals(columnLimit));
      expect(
        stdout,
        contains('\n'
            '┌─ Test ─────┐\n'
            '│ This       │\n'
            '│ line is    │\n'
            '│ longer     │\n'
            '│ than       │\n'
            '│            │\n'
            '│ 14         │\n'
            '│ characters │\n'
            '└────────────┘\n'),
      );
    });

    testWithoutContext(
        'Stdout printBox breaks long words that exceed the column limit', () {
      const int columnLimit = 14;
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences:
            OutputPreferences.test(showColor: true, wrapColumn: columnLimit),
      );
      logger.printBox('Thiswordislongerthan${columnLimit}characters',
          title: 'Test');
      final String stdout = fakeStdio.writtenToStdout.join();
      final List<String> stdoutLines = stdout.split('\n');

      expect(stdoutLines.length, greaterThan(1));
      expect(stdoutLines[1].length, equals(columnLimit));
      expect(
        stdout,
        contains('\n'
            '┌─ Test ─────┐\n'
            '│ Thiswordis │\n'
            '│ longerthan │\n'
            '│ 14characte │\n'
            '│ rs         │\n'
            '└────────────┘\n'),
      );
    });

    testWithoutContext('Stdout startProgress on non-color terminal', () async {
      final FakeStopwatch fakeStopwatch = FakeStopwatch();
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences: OutputPreferences.test(),
        stopwatchFactory: FakeStopwatchFactory(stopwatch: fakeStopwatch),
      );
      final Status status = logger.startProgress(
        'Hello',
        progressIndicatorPadding:
            20, // this minus the "Hello" equals the 15 below.
      );
      expect(outputStderr().length, equals(1));
      expect(outputStderr().first, isEmpty);
      // the 5 below is the margin that is always included between the message and the time.
      expect(outputStdout().join('\n'), matches(r'^Hello {15} {5}$'));

      fakeStopwatch.elapsed = const Duration(seconds: 4, milliseconds: 123);
      status.stop();

      expect(outputStdout(), <String>['Hello                        4.1s', '']);
    });

    testWithoutContext('SummaryStatus works when canceled', () async {
      final SummaryStatus summaryStatus = SummaryStatus(
        message: 'Hello world',
        padding: 20,
        onFinish: () => called++,
        stdio: fakeStdio,
        stopwatch: FakeStopwatch(),
      );
      summaryStatus.start();
      final List<String> lines = outputStdout();
      expect(lines[0], startsWith('Hello world              '));
      expect(lines.length, equals(1));
      expect(lines[0].endsWith('\n'), isFalse);

      // Verify a cancel does _not_ print the time and prints a newline.
      summaryStatus.cancel();
      expect(outputStdout(), <String>[
        'Hello world              ',
        '',
      ]);

      // Verify that stopping or canceling multiple times throws.
      expect(summaryStatus.cancel, throwsAssertionError);
      expect(summaryStatus.stop, throwsAssertionError);
    });

    testWithoutContext('SummaryStatus works when stopped', () async {
      summaryStatus.start();
      final List<String> lines = outputStdout();
      expect(lines[0], startsWith('Hello world              '));
      expect(lines.length, equals(1));

      // Verify a stop prints the time.
      summaryStatus.stop();
      expect(outputStdout(), <String>[
        'Hello world                   0ms',
        '',
      ]);

      // Verify that stopping or canceling multiple times throws.
      expect(summaryStatus.stop, throwsAssertionError);
      expect(summaryStatus.cancel, throwsAssertionError);
    });

    testWithoutContext('sequential startProgress calls with StdoutLogger',
        () async {
      final Logger logger = StdoutLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        stdio: fakeStdio,
        outputPreferences: OutputPreferences.test(),
      );
      logger.startProgress('AAA').stop();
      logger.startProgress('BBB').stop();
      final List<String> output = outputStdout();

      expect(output.length, equals(3));

      // There's 61 spaces at the start: 59 (padding default) - 3 (length of AAA) + 5 (margin).
      // Then there's a left-padded "0ms" 8 characters wide, so 5 spaces then "0ms"
      // (except sometimes it's randomly slow so we handle up to "99,999ms").
      expect(output[0], matches(RegExp(r'AAA[ ]{61}[\d, ]{5}[\d]ms')));
      expect(output[1], matches(RegExp(r'BBB[ ]{61}[\d, ]{5}[\d]ms')));
    });

    testWithoutContext('sequential startProgress calls with BufferLogger',
        () async {
      final BufferLogger logger = BufferLogger(
        terminal: AnsiTerminal(
          stdio: fakeStdio,
        ),
        outputPreferences: OutputPreferences.test(),
      );
      logger.startProgress('AAA').stop();
      logger.startProgress('BBB').stop();

      expect(logger.statusText, 'AAA\nBBB\n');
    });
  });
}

class FakeStdout extends Fake implements Stdout {
  FakeStdout({required this.syncError, this.completeWithError = false});

  final bool syncError;
  final bool completeWithError;
  final Completer<void> _completer = Completer<void>();

  @override
  void write(Object? object) {
    if (syncError) {
      throw Exception('Error!');
    }
    Zone.current.runUnaryGuarded<void>((_) {
      if (completeWithError) {
        _completer.completeError(Exception('Some pipe error'));
      } else {
        _completer.complete();
        throw Exception('Error!');
      }
    }, null);
  }

  @override
  Future<void> get done => _completer.future;
}
