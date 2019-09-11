import 'dart:async';
import 'dart:convert';
import 'dart:io';

class FakeProcess implements Process {
  FakeProcess(this._exitCode, this._stdout, this._stderr);

  final int _exitCode;
  @override
  Future<int> get exitCode async => _exitCode;

  bool _killed = false;
  bool get killed => _killed;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    _killed = true;
    return true;
  }

  @override
  int get pid => 1234;

  Stream<List<int>> _streamFromString(List<String> source) =>
      Stream<List<int>>.fromIterable(
          source.map((String line) => utf8.encode('$line\n')));

  final List<String> _stderr;
  @override
  Stream<List<int>> get stderr => _streamFromString(_stderr);

  @override
  IOSink get stdin => FakeIOSink();

  final List<String> _stdout;
  @override
  Stream<List<int>> get stdout => _streamFromString(_stdout);
}

class FakeIOSink implements IOSink {
  final Completer<void> _doneCompleter = Completer<void>.sync();

  @override
  Encoding encoding = utf8;

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace stackTrace]) {}

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> flush() async {}

  @override
  void write(Object obj) {}

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object obj = '']) {}
}
