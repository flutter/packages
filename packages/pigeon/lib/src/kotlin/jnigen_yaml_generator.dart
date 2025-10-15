// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as path;

import '../ast.dart';
import '../dart/dart_generator.dart' show InternalDartOptions;
import '../generator.dart';
import '../generator_tools.dart';
import 'kotlin_generator.dart' show InternalKotlinOptions;

/// Options for [JnigenYamlGenerator].
class InternalJnigenYamlOptions extends InternalOptions {
  /// Creates a [InternalJnigenYamlOptions].
  InternalJnigenYamlOptions(
    this.dartOptions,
    this.kotlinOptions,
    this.basePath,
    this.dartOut,
    this.exampleAppDirectory,
  );

  /// Dart options.
  final InternalDartOptions dartOptions;

  /// Kotlin options.
  final InternalKotlinOptions kotlinOptions;

  /// A base path to be prepended to all provided output paths.
  final String? basePath;

  /// Dart output path.
  final String? dartOut;

  /// Android example app directory.
  final String? exampleAppDirectory;
}

/// Generator for jnigen yaml configuration file.
class JnigenYamlGenerator extends Generator<InternalJnigenYamlOptions> {
  @override
  void generate(
    InternalJnigenYamlOptions generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    final Indent indent = Indent(sink);

    indent.format('''
      android_sdk_config:
        add_gradle_deps: true
        android_example: '${generatorOptions.exampleAppDirectory ?? ''}'

      # source_path:
      #   - 'android/src/main/java'

      summarizer:
        backend: asm

      output:
        dart:
          path: ${path.posix.join(generatorOptions.basePath ?? '', path.withoutExtension(generatorOptions.dartOut ?? ''))}.jni.dart
          structure: single_file

      log_level: all
      ''');
    indent.writeScoped('classes:', '', () {
      for (final Api api in root.apis) {
        if (api is AstHostApi || api is AstFlutterApi) {
          indent.writeln("- '${api.name}'");
          indent.writeln("- '${api.name}Registrar'");
        }
      }
      for (final Class dataClass in root.classes) {
        indent.writeln("- '${dataClass.name}'");
      }
      for (final Enum enumType in root.enums) {
        indent.writeln("- '${enumType.name}'");
      }
    });
  }
}
