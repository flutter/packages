// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

/// A superclass of generator classes.
///
/// This provides the structure that is common across generators for different languages.
abstract class Generator<T> {
  /// Generates files for the specified language with specified [languageOptions]
  ///
  /// This method, when overridden, should follow a generic structure that is currently:
  /// 1. Create Indent
  /// 2. Write File Headers
  /// 3. Write Imports
  /// 4. Write Enums
  /// 5. Write Data Classes
  /// 6. Write Apis
  void generate(
    T languageOptions,
    Root root,
    StringSink sink,
    FileType fileType,
  );

  /// Adds specified headers to file.
  void writeHeaders(
    T languageOptions,
    Root root,
    StringSink sink,
    Indent indent,
    FileType fileType,
  );

  /// Adds specified imports to file.
  void writeImports(
    T languageOptions,
    Root root,
    StringSink sink,
    Indent indent,
    FileType fileType,
  );

  /// Writes a single Enum to file.
  void writeEnum(
    T languageOptions,
    Root root,
    StringSink sink,
    Indent indent,
    FileType fileType,
    Enum anEnum,
  );

  /// Writes a single data class to file.
  void writeDataClass(
    T languageOptions,
    Root root,
    StringSink sink,
    Indent indent,
    FileType fileType,
    Class klass,
  );

  /// Writes a single class encode method to file.
  void writeEncode(
    T languageOptions,
    Root root,
    StringSink sink,
    Indent indent,
    FileType fileType,
    Class klass,
    List<String> customClassNames,
    List<String> customEnumNames,
  );

  /// Writes a single class decode method to file.
  void writeDecode(
    T languageOptions,
    Root root,
    StringSink sink,
    Indent indent,
    FileType fileType,
    Class klass,
    List<String> customClassNames,
    List<String> customEnumNames,
  );

  // /// Writes a single Flutter Api to file.
  // void writeFlutterApi(T languageOptions, Root root, StringSink sink,
  //     Indent indent, FileType fileType, Api api,);

  // /// Writes a single Host Api to file.
  // void writeHostApi(T languageOptions, Root root, StringSink sink,
  //     Indent indent, FileType fileType, Api api,);
}
