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
  void generate(
    T generatorOptions,
    Root root,
    StringSink sink,
  );
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

    prePrologue(generatorOptions, root, sink, indent);
    writeFilePrologue(generatorOptions, root, sink, indent);
    writeFileImports(generatorOptions, root, sink, indent);

    preEnums(generatorOptions, root, sink, indent);
    for (final Enum anEnum in root.enums) {
      writeEnum(generatorOptions, root, sink, indent, anEnum);
    }

    preDataClasses(generatorOptions, root, sink, indent);
    for (final Class klass in root.classes) {
      writeDataClass(generatorOptions, root, sink, indent, klass);
    }

    preApis(generatorOptions, root, sink, indent);
    for (final Api api in root.apis) {
      if (api.location == ApiLocation.host) {
        writeHostApi(generatorOptions, root, sink, indent, api);
      } else if (api.location == ApiLocation.flutter) {
        writeFlutterApi(generatorOptions, root, sink, indent, api);
      }
    }
    finalWriteFile(generatorOptions, root, sink, indent);
  }

  /// Pre-process or write before [writeFilePrologue].
  ///
  /// This method is not a reqiured method, and does not need to be overriden if not needed.
  void prePrologue(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
  ) {}

  /// Adds specified headers to file.
  void writeFilePrologue(
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

  /// Pre-process for enums or writes before any [writeEnum] calls.
  ///
  /// This method is not a reqiured method, and does not need to be overriden if not needed.
  void preEnums(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
  ) {}

  /// Writes a single Enum to file.
  void writeEnum(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Enum anEnum,
  );

  /// Pre-process for data classes or writes before any [writeDataClass] calls.
  ///
  /// This method is not a reqiured method, and does not need to be overriden if not needed.
  void preDataClasses(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
  ) {}

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

  /// Pre-process for apis and/or writes before any [writeFlutterApi] or [writeHostApi] calls.
  ///
  /// This method is not a reqiured method, and does not need to be overriden if not needed.
  void preApis(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
  ) {}

  /// Writes a single Flutter Api to file.
  void writeFlutterApi(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Api api,
  );

  /// Writes a single Host Api to file.
  void writeHostApi(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
    Api api,
  );

  /// Post-process for generate and/or writes after all other methods.
  ///
  /// This method is not a reqiured method, and does not need to be overriden if not needed.
  void finalWriteFile(
    T generatorOptions,
    Root root,
    StringSink sink,
    Indent indent,
  ) {}
}
