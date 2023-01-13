// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

/// An abstract base class of generators.
///
/// This provides the structure that is common across generators for different languages.
abstract class Generator<T> {
  /// Constructor.
  const Generator();

  /// Generates files for specified language with specified [generatorOptions]
  void generate(T generatorOptions, Root root, StringSink sink);
}

/// An abstract base class that enforces code generation across platforms.
abstract class StructuredGenerator<T> extends Generator<T> {
  /// Constructor.
  const StructuredGenerator();

  @override
  void generate(
    T generatorOptions,
    Root root,
    StringSink sink,
  ) {
    final Indent indent = Indent(sink);

    writeFilePrologue(generatorOptions, root, indent);

    writeFileImports(generatorOptions, root, indent);

    writeOpenNamespace(generatorOptions, root, indent);

    writeGeneralUtilities(generatorOptions, root, indent);

    writeEnums(generatorOptions, root, indent);

    writeDataClasses(generatorOptions, root, indent);

    writeApis(generatorOptions, root, indent);

    writeCloseNamespace(generatorOptions, root, indent);
  }

  /// Adds specified headers to [indent].
  void writeFilePrologue(T generatorOptions, Root root, Indent indent);

  /// Writes specified imports to [indent].
  void writeFileImports(T generatorOptions, Root root, Indent indent);

  /// Writes code to [indent] that opens file namespace if needed.
  ///
  /// This method is not required, and does not need to be overridden.
  void writeOpenNamespace(T generatorOptions, Root root, Indent indent) {}

  /// Writes code to [indent] that closes file namespace if needed.
  ///
  /// This method is not required, and does not need to be overridden.
  void writeCloseNamespace(T generatorOptions, Root root, Indent indent) {}

  /// Writes any necessary helper utilities to [indent] if needed.
  ///
  /// This method is not required, and does not need to be overridden.
  void writeGeneralUtilities(T generatorOptions, Root root, Indent indent) {}

  /// Writes all enums to [indent].
  ///
  /// Can be overridden to add extra code before/after enums.
  void writeEnums(T generatorOptions, Root root, Indent indent) {
    for (final Enum anEnum in root.enums) {
      writeEnum(generatorOptions, root, indent, anEnum);
    }
  }

  /// Writes a single Enum to [indent]. This is needed in most generators.
  void writeEnum(T generatorOptions, Root root, Indent indent, Enum anEnum) {}

  /// Writes all data classes to [indent].
  ///
  /// Can be overridden to add extra code before/after apis.
  void writeDataClasses(T generatorOptions, Root root, Indent indent) {
    for (final Class klass in root.classes) {
      writeDataClass(generatorOptions, root, indent, klass);
    }
  }

  /// Writes a single data class to [indent].
  void writeDataClass(
      T generatorOptions, Root root, Indent indent, Class klass);

  /// Writes a single class encode method to [indent].
  void writeClassEncode(T generatorOptions, Root root, Indent indent,
      Class klass, Set<String> customClassNames, Set<String> customEnumNames) {}

  /// Writes a single class decode method to [indent].
  void writeClassDecode(T generatorOptions, Root root, Indent indent,
      Class klass, Set<String> customClassNames, Set<String> customEnumNames) {}

  /// Writes all apis to [indent].
  ///
  /// Can be overridden to add extra code before/after classes.
  void writeApis(T generatorOptions, Root root, Indent indent) {
    for (final Api api in root.apis) {
      if (api.location == ApiLocation.host) {
        writeHostApi(generatorOptions, root, indent, api);
      } else if (api.location == ApiLocation.flutter) {
        writeFlutterApi(generatorOptions, root, indent, api);
      }
    }
  }

  /// Writes a single Flutter Api to [indent].
  void writeFlutterApi(T generatorOptions, Root root, Indent indent, Api api);

  /// Writes a single Host Api to [indent].
  void writeHostApi(T generatorOptions, Root root, Indent indent, Api api);
}
