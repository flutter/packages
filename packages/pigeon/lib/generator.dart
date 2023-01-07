// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

/// A superclass of generator classes.
///
/// This provides the structure that is common across generators for different languages.
abstract class Generator<T> {
  /// Generates files for specified language with specified [generatorOptions]
  ///
  /// This method, when overridden, should follow a generic structure that is currently:
  /// 1. Create Indent
  /// 2. Write File Headers
  /// 3. Write Imports
  /// 4. Write Enums
  /// 5. Write Data Classes
  /// 6. Write Apis
  void generate(
    T generatorOptions,
    Root root,
    StringSink sink,
  );

  /// Adds specified headers to file.
  void writeFileHeaders(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
  );

  /// Adds specified imports to file.
  void writeFileImports(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
  );

  /// Writes a single Enum to file.
  void writeEnum(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Enum anEnum,
  );

  /// Writes a single data class to file.
  void writeDataClass(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Class klass,
  );

  /// Writes a single class encode method to file.
  void writeClassEncode(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  );

  /// Writes a single class decode method to file.
  void writeClassDecode(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  );

  // /// Writes a single Flutter Api to file.
  // void writeFlutterApi(T generatorOptions, Root root, StringSink sink,
  //     Indent indent, FileType fileType, Api api,);

  // /// Writes a single Host Api to file.
  // void writeHostApi(T generatorOptions, Root root, StringSink sink,
  //     Indent indent, FileType fileType, Api api,);
}
