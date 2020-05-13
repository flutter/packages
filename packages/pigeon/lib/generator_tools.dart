// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'ast.dart';

/// The current version of pigeon.
const String pigeonVersion = '0.1.0-experimental.11';

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

  /// String used to represent a tab.
  final String tab = '  ';

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
      result += tab;
    }
    return result;
  }

  /// Replaces the newlines and tabs of input and adds it to the stream.
  void format(String input) {
    for (String line in input.split('\n')) {
      writeln(line.replaceAll('\t', tab));
    }
  }

  /// Scoped increase of the ident level.  For the execution of [func] the
  /// indentation will be incremented.
  void scoped(String begin, String end, Function func) {
    if (begin != null) {
      _sink.write(begin + newline);
    }
    inc();
    func();
    dec();
    if (end != null) {
      _sink.write(str() + end + newline);
    }
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
  return 'dev.flutter.pigeon.${api.name}.${func.name}';
}

/// Represents the mapping of a Dart datatype to a Host datatype.
class HostDatatype {
  /// Parametric constructor for HostDatatype.
  HostDatatype({this.datatype, this.isBuiltin});

  /// The [String] that can be printed into host code to represent the type.
  final String datatype;

  /// `true` if the host datatype is something builtin.
  final bool isBuiltin;
}

/// Calculates the [HostDatatype] for the provided [Field].  It will check the
/// field against the `classes` to check if it is a builtin type.
/// `builtinResolver` will return the host datatype for the Dart datatype for
/// builtin types.  `customResolver` can modify the datatype of custom types.
HostDatatype getHostDatatype(
    Field field, List<Class> classes, String Function(String) builtinResolver,
    {String Function(String) customResolver}) {
  final String datatype = builtinResolver(field.dataType);
  if (datatype == null) {
    if (classes.map((Class x) => x.name).contains(field.dataType)) {
      final String customName = customResolver != null
          ? customResolver(field.dataType)
          : field.dataType;
      return HostDatatype(datatype: customName, isBuiltin: false);
    } else {
      return null;
    }
  } else {
    return HostDatatype(datatype: datatype, isBuiltin: true);
  }
}

/// Warning printed at the top of all generated code.
const String generatedCodeWarning =
    'Autogenerated from Pigeon (v$pigeonVersion), do not edit directly.';

/// String to be printed after `generatedCodeWarning`.
const String seeAlsoWarning = 'See also: https://pub.dev/packages/pigeon';

/// Collection of keys used in dictionaries across generators.
class Keys {
  /// The key in the result hash for the 'result' value.
  static const String result = 'result';

  /// The key in the result hash for the 'error' value.
  static const String error = 'error';

  /// The key in an error hash for the 'code' value.
  static const String errorCode = 'code';

  /// The key in an error hash for the 'message' value.
  static const String errorMessage = 'message';

  /// The key in an error hash for the 'details' value.
  static const String errorDetails = 'details';
}

/// Returns true if `type` represents 'void'.
bool isVoid(TypeMirror type) {
  return MirrorSystem.getName(type.simpleName) == 'void';
}
