// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'ast.dart';

/// Read all the content from [stdin] to a String.
String readStdin() {
  final List<int> bytes = <int>[];
  int byte = stdin.readByteSync();
  while (byte >= 0) {
    bytes.add(byte);
    byte = stdin.readByteSync();
  }
  return utf8.decode(bytes);
}

/// A helper class for managing indentation, wrapping a [StringSink].
class Indent {
  /// Constructor which takes a [StringSink] [Ident] will wrap.
  Indent(this._sink);

  int _count = 0;
  final StringSink _sink;

  /// String used for newlines (ex "\n").
  final String newline = '\n';

  /// Increase the indentation level.
  void inc() {
    _count += 1;
  }

  /// Decrement the indentation level.
  void dec() {
    _count -= 1;
  }

  /// Returns the String represneting the current indentation.
  String str() {
    String result = '';
    for (int i = 0; i < _count; i++) {
      result += '  ';
    }
    return result;
  }

  /// Scoped increase of the ident level.  For the execution of [func] the
  /// indentation will be incremented.
  void scoped(String begin, String end, Function func) {
    _sink.write(begin + newline);
    inc();
    func();
    dec();
    _sink.write(str() + end + newline);
  }

  /// Add [str] with indentation and a newline.
  void writeln(String str) {
    _sink.write(this.str() + str + newline);
  }

  /// Add [str] with indentation.
  void write(String str) {
    _sink.write(this.str() + str);
  }

  /// Add [str] with a newline.
  void addln(String str) {
    _sink.write(str + newline);
  }

  /// Just adds [str].
  void add(String str) {
    _sink.write(str);
  }
}

/// Create the generated channel name for a [func] on a [api].
String makeChannelName(Api api, Method func) {
  return 'dev.flutter.dartle.${api.name}.${func.name}';
}
