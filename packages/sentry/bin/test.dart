// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:sentry/sentry.dart';

/// Sends a test exception report to Sentry.io using this Dart client.
Future<Null> main(List<String> rawArgs) async {
  if (rawArgs.length != 1) {
    stderr.writeln(
        'Expected exactly one argument, which is the DSN issued by Sentry.io to your project.');
    exit(1);
  }

  final String dsn = rawArgs.single;
  final SentryClient client = new SentryClient(dsn: dsn);

  try {
    await foo();
  } catch (error, stackTrace) {
    print('Reporting the following stack trace: ');
    print(stackTrace);
    final SentryResponse response = await client.captureException(
      exception: error,
      stackTrace: stackTrace,
    );

    if (response.isSuccessful) {
      print('SUCCESS\nid: ${response.eventId}');
    } else {
      print('FAILURE: ${response.error}');
    }
  } finally {
    await client.close();
  }
}

Future<Null> foo() async {
  await bar();
}

Future<Null> bar() async {
  await baz();
}

Future<Null> baz() async {
  throw new StateError('This is a test error');
}
