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
  void generate(T generatorOptions, Root root, StringSink sink);
}

/// A Superclass that enforces code generation across platforms.
abstract class StructuredGenerator<T> extends Generator<T> {
  @override
  void generate(
    T generatorOptions,
    Root root,
    StringSink sink,
  ) {
    final Indent indent = Indent(sink);

    writeFilePrologue(generatorOptions, root, sink, indent);

    writeFileImports(generatorOptions, root, sink, indent);

    writeEnums(generatorOptions, root, sink, indent);

    writeDataClasses(generatorOptions, root, sink, indent);

    writeApis(generatorOptions, root, sink, indent);

    writeGeneralUtilities(generatorOptions, root, sink, indent);
  }

  /// Adds specified headers to file.
  void writeFilePrologue(
      T generatorOptions, Root root, StringSink sink, Indent indent);

  /// Writes specified imports to file.
  void writeFileImports(
      T generatorOptions, Root root, StringSink sink, Indent indent);

  /// Writes all enums to file. Can be overridden to add extra code before/after enums.
  void writeEnums(
      T generatorOptions, Root root, StringSink sink, Indent indent) {
    for (final Enum anEnum in root.enums) {
      writeEnum(generatorOptions, root, sink, indent, anEnum);
    }
  }

  /// Writes a single Enum to file.
  void writeEnum(T generatorOptions, Root root, StringSink sink, Indent indent,
      Enum anEnum);

  /// Writes all apis to file. Can be overridden to add extra code before/after apis.
  void writeDataClasses(
      T generatorOptions, Root root, StringSink sink, Indent indent) {
    for (final Class klass in root.classes) {
      writeDataClass(generatorOptions, root, sink, indent, klass);
    }
  }

  /// Writes a single data class to file.
  void writeDataClass(T generatorOptions, Root root, StringSink sink,
      Indent indent, Class klass);

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

  /// Writes all data classes to file. Can be overridden to add extra code before/after classes.
  void writeApis(
      T generatorOptions, Root root, StringSink sink, Indent indent) {
    for (final Api api in root.apis) {
      if (api.location == ApiLocation.host) {
        writeHostApi(generatorOptions, root, sink, indent, api);
      } else if (api.location == ApiLocation.flutter) {
        writeFlutterApi(generatorOptions, root, sink, indent, api);
      }
    }
  }

  /// Writes a single Flutter Api to file.
  void writeFlutterApi(
      T generatorOptions, Root root, StringSink sink, Indent indent, Api api);

  /// Writes a single Host Api to file.
  void writeHostApi(
      T generatorOptions, Root root, StringSink sink, Indent indent, Api api);

  /// Writes any necessary helper utilities to file if needed.
  ///
  /// This method is not reqiured, and does not need to be overridden.
  void writeGeneralUtilities(
      T generatorOptions, Root root, StringSink sink, Indent indent) {}
}
