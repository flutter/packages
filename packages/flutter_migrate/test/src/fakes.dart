// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io show IOSink, Stdout, StdoutException;

import 'package:flutter_migrate/src/base/io.dart';
import 'package:flutter_migrate/src/base/logger.dart';
import 'package:test/fake.dart';

/// An IOSink that completes a future with the first line written to it.
class CompleterIOSink extends MemoryIOSink {
  CompleterIOSink({
    this.throwOnAdd = false,
  });

  final bool throwOnAdd;

  final Completer<List<int>> _completer = Completer<List<int>>();

  Future<List<int>> get future => _completer.future;

  @override
  void add(List<int> data) {
    if (!_completer.isCompleted) {
      // When throwOnAdd is true, complete with empty so any expected output
      // doesn't appear.
      _completer.complete(throwOnAdd ? <int>[] : data);
    }
    if (throwOnAdd) {
      throw Exception('CompleterIOSink Error');
    }
    super.add(data);
  }
}

/// An IOSink that collects whatever is written to it.
class MemoryIOSink implements IOSink {
  @override
  Encoding encoding = utf8;

  final List<List<int>> writes = <List<int>>[];

  @override
  void add(List<int> data) {
    writes.add(data);
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    final Completer<void> completer = Completer<void>();
    late StreamSubscription<List<int>> sub;
    sub = stream.listen(
      (List<int> data) {
        try {
          add(data);
          // Catches all exceptions to propagate them to the completer.
        } catch (err, stack) {
          // ignore: avoid_catches_without_on_clauses
          sub.cancel();
          completer.completeError(err, stack);
        }
      },
      onError: completer.completeError,
      onDone: completer.complete,
      cancelOnError: true,
    );
    return completer.future;
  }

  @override
  void writeCharCode(int charCode) {
    add(<int>[charCode]);
  }

  @override
  void write(Object? obj) {
    add(encoding.encode('$obj'));
  }

  @override
  void writeln([Object? obj = '']) {
    add(encoding.encode('$obj\n'));
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    bool addSeparator = false;
    for (final dynamic object in objects) {
      if (addSeparator) {
        write(separator);
      }
      write(object);
      addSeparator = true;
    }
  }

  @override
  void addError(dynamic error, [StackTrace? stackTrace]) {
    throw UnimplementedError();
  }

  @override
  Future<void> get done => close();

  @override
  Future<void> close() async {}

  @override
  Future<void> flush() async {}

  void clear() {
    writes.clear();
  }

  String getAndClear() {
    final String result =
        utf8.decode(writes.expand((List<int> l) => l).toList());
    clear();
    return result;
  }
}

class MemoryStdout extends MemoryIOSink implements io.Stdout {
  @override
  bool get hasTerminal => _hasTerminal;
  set hasTerminal(bool value) {
    _hasTerminal = value;
  }

  bool _hasTerminal = true;

  @override
  io.IOSink get nonBlocking => this;

  @override
  bool get supportsAnsiEscapes => _supportsAnsiEscapes;
  set supportsAnsiEscapes(bool value) {
    _supportsAnsiEscapes = value;
  }

  bool _supportsAnsiEscapes = true;

  @override
  int get terminalColumns {
    if (_terminalColumns != null) {
      return _terminalColumns!;
    }
    throw const io.StdoutException('unspecified mock value');
  }

  set terminalColumns(int value) => _terminalColumns = value;
  int? _terminalColumns;

  @override
  int get terminalLines {
    if (_terminalLines != null) {
      return _terminalLines!;
    }
    throw const io.StdoutException('unspecified mock value');
  }

  set terminalLines(int value) => _terminalLines = value;
  int? _terminalLines;
}

/// A Stdio that collects stdout and supports simulated stdin.
class FakeStdio extends Stdio {
  final MemoryStdout _stdout = MemoryStdout()..terminalColumns = 80;
  final MemoryIOSink _stderr = MemoryIOSink();
  final FakeStdin _stdin = FakeStdin();

  @override
  MemoryStdout get stdout => _stdout;

  @override
  MemoryIOSink get stderr => _stderr;

  @override
  Stream<List<int>> get stdin => _stdin;

  void simulateStdin(String line) {
    _stdin.controller.add(utf8.encode('$line\n'));
  }

  @override
  bool hasTerminal = true;

  List<String> get writtenToStdout =>
      _stdout.writes.map<String>(_stdout.encoding.decode).toList();
  List<String> get writtenToStderr =>
      _stderr.writes.map<String>(_stderr.encoding.decode).toList();
}

class FakeStdin extends Fake implements Stdin {
  final StreamController<List<int>> controller = StreamController<List<int>>();

  @override
  bool echoMode = true;

  @override
  bool hasTerminal = true;

  @override
  bool echoNewlineMode = true;

  @override
  bool lineMode = true;

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> transformer) {
    return controller.stream.transform(transformer);
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class FakeStopwatch implements Stopwatch {
  @override
  bool get isRunning => _isRunning;
  bool _isRunning = false;

  @override
  void start() => _isRunning = true;

  @override
  void stop() => _isRunning = false;

  @override
  Duration elapsed = Duration.zero;

  @override
  int get elapsedMicroseconds => elapsed.inMicroseconds;

  @override
  int get elapsedMilliseconds => elapsed.inMilliseconds;

  @override
  int get elapsedTicks => elapsed.inMilliseconds;

  @override
  int get frequency => 1000;

  @override
  void reset() {
    _isRunning = false;
    elapsed = Duration.zero;
  }

  @override
  String toString() => 'FakeStopwatch $elapsed $isRunning';
}

class FakeStopwatchFactory implements StopwatchFactory {
  FakeStopwatchFactory(
      {Stopwatch? stopwatch, Map<String, Stopwatch>? stopwatches})
      : stopwatches = <String, Stopwatch>{
          if (stopwatches != null) ...stopwatches,
          if (stopwatch != null) '': stopwatch,
        };

  Map<String, Stopwatch> stopwatches;

  @override
  Stopwatch createStopwatch([String name = '']) {
    return stopwatches[name] ?? FakeStopwatch();
  }
}
