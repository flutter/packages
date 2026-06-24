// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as path;

import '../ast.dart';
import '../dart/dart_generator.dart' show InternalDartOptions;
import '../generator.dart';
import '../generator_tools.dart';
import 'kotlin_generator.dart' show InternalKotlinOptions;

/// Options for [JnigenConfigGenerator].
class InternalJnigenConfigOptions extends InternalOptions {
  /// Creates a [InternalJnigenConfigOptions].
  InternalJnigenConfigOptions(
    this.dartOptions,
    this.kotlinOptions,
    this.basePath,
    this.appDirectory,
  );

  /// Dart options.
  final InternalDartOptions dartOptions;

  /// Kotlin options.
  final InternalKotlinOptions kotlinOptions;

  /// A base path to be prepended to all provided output paths.
  final String? basePath;

  /// App directory.
  final String? appDirectory;
}

/// Generator for jnigen yaml configuration file.
class JnigenConfigGenerator extends Generator<InternalJnigenConfigOptions> {
  @override
  void generate(
    InternalJnigenConfigOptions generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    final indent = Indent();
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln('// ignore_for_file: depend_on_referenced_packages');
    indent.newln();
    indent.writeln("import 'dart:io';");
    indent.writeln("import 'package:jnigen/jnigen.dart';");
    indent.writeln("import 'package:logging/logging.dart';");

    final String fullDartOut = generatorOptions.basePath != null
        ? path.posix.join(generatorOptions.basePath!, generatorOptions.dartOptions.dartOut ?? '')
        : (generatorOptions.dartOptions.dartOut ?? './lib/pigeons/');

    final List<String> jniClassPaths =
        generatorOptions.kotlinOptions.jniClassPaths ??
        <String>['build/app/tmp/kotlin-classes/release'];
    final String classPathContent = jniClassPaths
        .map((String path) {
          if (path.endsWith('.jar')) {
            return "Uri.file('$path')";
          }
          return "Uri.directory('$path')";
        })
        .join(', ');

    indent.writeln('');
    indent.writeScoped('void main() async {', '}', () {
      indent.writeln("  Directory.current = Platform.script.resolve('.').toFilePath();");
      indent.writeScoped('await generateJniBindings(', ');', () {
        indent.writeScoped('Config(', '),', () {
          indent.format('''
            androidSdkConfig: AndroidSdkConfig(
              addGradleDeps: true,
              androidExample: './',
            ),
            summarizerOptions: SummarizerOptions(backend: SummarizerBackend.asm),
            outputConfig: OutputConfig(
              dartConfig: DartCodeOutputConfig(
                // Path is relative to appDirectory.
                path: Uri.file('${path.relative(path.withoutExtension(fullDartOut), from: generatorOptions.appDirectory ?? './')}.jni.dart'),
              structure: OutputStructure.singleFile,
            ),
          ),
          logLevel: Level.ALL,
          classPath: [$classPathContent],
''');
          indent.writeScoped('classes: [', '],', () {
            final packagePrefix = generatorOptions.kotlinOptions.package != null
                ? '${generatorOptions.kotlinOptions.package}.'
                : '';
            indent.writeln(
              "'$packagePrefix${generatorOptions.kotlinOptions.errorClassName ?? 'FlutterError'}',",
            );
            for (final Api api in root.apis) {
              if (api is AstHostApi || api is AstFlutterApi) {
                indent.writeln("'$packagePrefix${api.name}',");
                indent.writeln("'$packagePrefix${api.name}Registrar',");
              }
            }
            for (final Class dataClass in root.classes) {
              indent.writeln("'$packagePrefix${dataClass.name}',");
            }
            for (final Enum enumType in root.enums) {
              indent.writeln("'$packagePrefix${enumType.name}',");
            }
          });
        });
      });
      indent.newln();
    });
    sink.write(indent.toString());
  }
}
