// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file/memory.dart';
import 'package:fuchsia_ctl/src/logger.dart';
import 'package:test/test.dart';

void main() {
  test('PrintLogger with file logs data correctly', () async {
    final MemoryFileSystem fs = MemoryFileSystem();
    fs.file('log.txt').createSync();
    final IOSink data = fs.file('log.txt').openWrite();
    final PrintLogger logger = PrintLogger(out: data, level: LogLevel.debug);
    logger.debug('abc');
    logger.info('cdf');
    logger.warning('gh');
    logger.error('jk');
    await data.flush();
    final String content = fs.file('log.txt').readAsStringSync();
    expect(content, contains('ERROR jk'));
    expect(content, contains('INFO cdf'));
    expect(content, contains('WARN gh'));
    expect(content, contains('DEBUG abc'));
  });
  test('PrintLogger with no file logs data correctly', () async {
    final PrintLogger logger = PrintLogger();
    logger.debug('abc');
    logger.info('cdf');
    logger.warning('gh');
    logger.error('jk');
    final String outContent = logger.outputLog();
    final String errContent = logger.errorLog();
    expect(errContent, contains('jk\n'));
    expect(outContent, contains('cdf\n'));
    expect(outContent, contains('gh\n'));
    expect(outContent, contains('abc\n'));
  });

  test('PrintLogger with file logs logs only data above level', () async {
    final MemoryFileSystem fs = MemoryFileSystem();
    fs.file('log.txt').createSync();
    final IOSink data = fs.file('log.txt').openWrite();
    final PrintLogger logger = PrintLogger(out: data, level: LogLevel.info);
    logger.debug('abc');
    logger.info('cdf');
    logger.warning('gh');
    logger.error('jk');
    await data.flush();
    final String content = fs.file('log.txt').readAsStringSync();
    expect(content, contains('ERROR jk'));
    expect(content, contains('INFO cdf'));
    expect(content, contains('WARN gh'));
    expect(content, isNot(contains('DEBUG abc')));
  });
}
