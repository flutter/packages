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
  void generate(
    T generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  });
}

/// An abstract base class that enforces code generation across platforms.
abstract class StructuredGenerator<T> extends Generator<T> {
  /// Constructor.
  const StructuredGenerator();

  @override
  void generate(
    T generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    final Indent indent = Indent(sink);

    writeFilePrologue(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );

    writeFileImports(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );

    writeOpenNamespace(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );

    writeGeneralUtilities(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );

    writeEnums(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );

    writeDataClasses(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );

    writeApis(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );

    writeCloseNamespace(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
  }

  /// Adds specified headers to [indent].
  void writeFilePrologue(
    T generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  });

  /// Writes specified imports to [indent].
  void writeFileImports(
    T generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  });

  /// Writes code to [indent] that opens file namespace if needed.
  ///
  /// This method is not required, and does not need to be overridden.
  void writeOpenNamespace(
    T generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {}

  /// Writes code to [indent] that closes file namespace if needed.
  ///
  /// This method is not required, and does not need to be overridden.
  void writeCloseNamespace(
    T generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {}

  /// Writes any necessary helper utilities to [indent] if needed.
  ///
  /// This method is not required, and does not need to be overridden.
  void writeGeneralUtilities(
    T generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {}

  /// Writes all enums to [indent].
  ///
  /// Can be overridden to add extra code before/after enums.
  void writeEnums(
    T generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    for (final Enum anEnum in root.enums) {
      writeEnum(
        generatorOptions,
        root,
        indent,
        anEnum,
        dartPackageName: dartPackageName,
      );
    }
  }

  /// Writes a single Enum to [indent]. This is needed in most generators.
  void writeEnum(
    T generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {}

  /// Writes all data classes to [indent].
  ///
  /// Can be overridden to add extra code before/after apis.
  void writeDataClasses(
    T generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    for (final Class classDefinition in root.classes) {
      writeDataClass(
        generatorOptions,
        root,
        indent,
        classDefinition,
        dartPackageName: dartPackageName,
      );
    }
  }

  /// Writes a single data class to [indent].
  void writeDataClass(
    T generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  });

  /// Writes a single class encode method to [indent].
  void writeClassEncode(
    T generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {}

  /// Writes a single class decode method to [indent].
  void writeClassDecode(
    T generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {}

  /// Writes all apis to [indent].
  ///
  /// Can be overridden to add extra code before/after classes.
  void writeApis(
    T generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    for (final Api api in root.apis) {
      if (api.location == ApiLocation.host) {
        writeHostApi(
          generatorOptions,
          root,
          indent,
          api,
          dartPackageName: dartPackageName,
        );
      } else if (api.location == ApiLocation.flutter) {
        writeFlutterApi(
          generatorOptions,
          root,
          indent,
          api,
          dartPackageName: dartPackageName,
        );
      }
    }
  }

  /// Writes a single Flutter Api to [indent].
  void writeFlutterApi(
    T generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  });

  /// Writes a single Host Api to [indent].
  void writeHostApi(
    T generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  });
}
