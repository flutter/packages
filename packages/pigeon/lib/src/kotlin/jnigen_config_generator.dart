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
    this.appDirectory, {
    this.configDirectory,
  });

  /// Dart options.
  final InternalDartOptions dartOptions;

  /// Kotlin options.
  final InternalKotlinOptions kotlinOptions;

  /// A base path to be prepended to all provided output paths.
  final String? basePath;

  /// App directory.
  final String? appDirectory;

  /// The directory where generated configuration files for JNIgen will be written.
  final String? configDirectory;
}

/// Generator for JNIgen configuration file.
class JnigenConfigGenerator extends Generator<InternalJnigenConfigOptions> {
  @override
  void generate(
    InternalJnigenConfigOptions generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    final indent = Indent();
    if (generatorOptions.dartOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.dartOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln('// ignore_for_file: depend_on_referenced_packages');
    indent.newln();
    indent.writeln("import 'dart:io';");
    indent.writeln("import 'package:jnigen/jnigen.dart';");
    indent.writeln("import 'package:logging/logging.dart';");

    final String basePath = generatorOptions.basePath ?? '';
    final String configDirSetting =
        generatorOptions.kotlinOptions.configDirectory ?? generatorOptions.configDirectory ?? '';
    final String rawConfigDir =
        (basePath.isNotEmpty &&
            configDirSetting.isNotEmpty &&
            !configDirSetting.startsWith(basePath))
        ? path.posix.join(basePath, configDirSetting)
        : (configDirSetting.isNotEmpty ? configDirSetting : basePath);

    final String appDir =
        generatorOptions.kotlinOptions.appDirectory ?? generatorOptions.appDirectory ?? '';
    final String rawAppDir =
        (basePath.isNotEmpty && appDir.isNotEmpty && !appDir.startsWith(basePath))
        ? path.posix.join(basePath, appDir)
        : appDir;

    String androidExample = rawConfigDir.isNotEmpty && rawAppDir.isNotEmpty
        ? makeRelative(rawAppDir, rawConfigDir)
        : rawAppDir;
    if (androidExample.isEmpty) {
      androidExample = './';
    } else if (!androidExample.startsWith('.')) {
      androidExample = './$androidExample';
    }

    final String dartOutPath = generatorOptions.dartOptions.dartOut ?? '';
    final String rawDartOut =
        (basePath.isNotEmpty && dartOutPath.isNotEmpty && !dartOutPath.startsWith(basePath))
        ? path.posix.join(basePath, dartOutPath)
        : dartOutPath;
    final String fullDartOut = rawConfigDir.isNotEmpty
        ? makeRelative(rawDartOut, rawConfigDir)
        : rawDartOut;

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
      indent.writeln("  Directory.current = Platform.script.resolve('../..').toFilePath();");
      indent.writeScoped('await generateJniBindings(', ');', () {
        indent.writeScoped('Config(', '),', () {
          final hasCopyright = generatorOptions.kotlinOptions.copyrightHeader != null;
          final copyrightPreamble = hasCopyright
              ? '// ${generatorOptions.kotlinOptions.copyrightHeader!.join(r'\n// ')}\n'
              : '';
          indent.format('''
${hasCopyright ? '''
            preamble: \'\'\'
$copyrightPreamble\'\'\',
''' : ''}            androidSdkConfig: AndroidSdkConfig(
              addGradleDeps: true,
              androidExample: '$androidExample',
            ),
            summarizerOptions: SummarizerOptions(backend: SummarizerBackend.asm),
            outputConfig: OutputConfig(
              dartConfig: DartCodeOutputConfig(
                path: Uri.file('${path.withoutExtension(fullDartOut)}.jni.dart'),
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
