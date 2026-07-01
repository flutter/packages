// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as path;

import '../ast.dart';
import '../dart/dart_generator.dart' show InternalDartOptions;
import '../generator.dart';
import '../generator_tools.dart';
import 'swift_generator.dart' show InternalSwiftOptions;

/// Options for [FfigenConfigGenerator].
class InternalFfigenConfigOptions extends InternalOptions {
  /// Creates a [InternalFfigenConfigOptions].
  InternalFfigenConfigOptions(
    this.dartOptions,
    this.swiftOptions,
    this.basePath,
    this.dartOut,
    this.exampleAppDirectory,
  );

  /// Dart options.
  final InternalDartOptions dartOptions;

  /// Swift options.
  final InternalSwiftOptions swiftOptions;

  /// A base path to be prepended to all provided output paths.
  final String? basePath;

  /// Dart output path.
  final String? dartOut;

  /// Android example app directory.
  final String? exampleAppDirectory;
}

/// Generator for ffigen configuration file.
class FfigenConfigGenerator extends Generator<InternalFfigenConfigOptions> {
  @override
  void generate(
    InternalFfigenConfigOptions generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    final indent = Indent();
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
    indent.writeln('// ignore_for_file: avoid_print, depend_on_referenced_packages');
    indent.newln();
    indent.format('''
import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:pub_semver/pub_semver.dart';
import 'package:swift2objc/swift2objc.dart';
import 'package:swiftgen/src/config.dart';
import 'package:swiftgen/swiftgen.dart';

  ''');
    final bool hasAsyncFlutterApi = root.apis.whereType<AstFlutterApi>().any(
      (AstFlutterApi api) => api.methods.any((Method method) => method.isAsynchronous),
    );

    final String? configuredSdkPath = generatorOptions.swiftOptions.appleSdkPath;
    final String? configuredSdkTriple = generatorOptions.swiftOptions.appleSdkTriple;

    final String fullSwiftOut = generatorOptions.basePath != null
        ? path.posix.join(generatorOptions.basePath!, generatorOptions.swiftOptions.swiftOut)
        : generatorOptions.swiftOptions.swiftOut;
    final String fullDartOut = generatorOptions.basePath != null
        ? path.posix.join(generatorOptions.basePath!, generatorOptions.dartOut ?? '')
        : (generatorOptions.dartOut ?? '');

    final String objcDir = path.posix.join(
      path.posix.dirname(path.posix.dirname(fullSwiftOut)),
      '${path.posix.basename(path.posix.dirname(fullSwiftOut))}_objc_gen',
    );

    final String moduleName = generatorOptions.swiftOptions.ffiModuleName?.isNotEmpty ?? false
        ? generatorOptions.swiftOptions.ffiModuleName!
        : 'Runner';

    indent.writeScoped('Future<void> main(List<String> args) async {', '}', () {
      indent.writeln("  Directory.current = Platform.script.resolve('.').toFilePath();");
      indent.format('''
  final Uri sdk;
  if (args.isNotEmpty) {
    sdk = Uri.directory(args[0]);
  } else {
    sdk = ${configuredSdkPath != null ? "Uri.directory('$configuredSdkPath')" : "await iOSSdk"};
  }
''');
      final String prefix = generatorOptions.swiftOptions.fileSpecificClassNameComponent ?? '';
      indent.writeScoped('final classes = <String>[', '];', () {
        indent.inc();
        indent.writeln("'${prefix}PigeonInternalNull',");
        indent.writeln("'${prefix}PigeonTypedData',");
        indent.writeln("'${prefix}NumberWrapper',");
        if (hasAsyncFlutterApi) {
          indent.writeln("'NSURLCredential',");
        }
        for (final Api api in root.apis) {
          if (api is AstHostApi) {
            indent.writeln("'${api.name}',");
            indent.writeln("'${api.name}Setup',");
          }
          if (api is AstFlutterApi) {
            indent.writeln("'${api.name}Bridge',");
            indent.writeln("'${api.name}Registrar',");
          }
        }
        for (final Class dataClass in root.classes) {
          indent.writeln("'${dataClass.name}Bridge',");
        }
        indent.writeln("'${generatorOptions.swiftOptions.errorClassName ?? 'PigeonError'}'");
        indent.dec();
      });
      indent.writeScoped('final enums = <String>[', '];', () {
        indent.inc();
        for (final Enum enumType in root.enums) {
          indent.writeln("'${enumType.name}',");
        }
        if (hasAsyncFlutterApi) {
          indent.writeln("'NSURLSessionAuthChallengeDisposition',");
        }
        indent.writeln("'${prefix}PigeonInternalNumberType',");
        indent.dec();
      });

      indent.format('''
  var targetTriple = '${configuredSdkTriple ?? ''}';
  if (targetTriple.isEmpty) {
    targetTriple = sdk.path.toLowerCase().contains('macosx')
        ? await macOSX64TargetTripleLatest
        : await iOSArm64TargetTripleLatest;
  }

  await SwiftGenerator(
    target: Target(
      triple: targetTriple,
      sdk: sdk,
    ),
    inputs: <SwiftGenInput>[ObjCCompatibleSwiftFileInput(files: <Uri>[
        Uri.file('${path.relative(fullSwiftOut, from: generatorOptions.exampleAppDirectory ?? './')}')
      ])
    ],
    include: (Declaration d) =>
        classes.contains(d.name) || enums.contains(d.name),
    output: Output(
      module: '$moduleName',
      // Path is relative to appDirectory.
      dartFile: Uri.file('${path.relative(path.withoutExtension(fullDartOut), from: generatorOptions.exampleAppDirectory ?? './')}.ffi.dart'),
      objectiveCFile: Uri.file('${path.relative(path.posix.join(objcDir, '${path.posix.basenameWithoutExtension(fullSwiftOut)}.m'), from: generatorOptions.exampleAppDirectory ?? './')}'),
      preamble: \'''
// ${generatorOptions.swiftOptions.copyrightHeader?.join('\n// ') ?? ''}

// ignore_for_file: always_specify_types, camel_case_types, non_constant_identifier_names, unnecessary_non_null_assertion, unused_element, unused_field
// coverage:ignore-file
\''',
      ),
    ffigen: FfiGeneratorOptions(
      objectiveC: fg.ObjectiveC(
        externalVersions: fg.ExternalVersions(
          ios: fg.Versions(min: Version(12, 0, 0)),
          macos: fg.Versions(min: Version(10, 14, 0)),
        ),
        interfaces: fg.Interfaces(
          include: (fg.Declaration decl) =>
              classes.contains(decl.originalName) ||
              enums.contains(decl.originalName),
          module: (fg.Declaration decl) {
${hasAsyncFlutterApi ? '''
            if (decl.originalName == 'NSURLCredential' ||
                decl.originalName == 'NSURLSessionAuthChallengeDisposition') {
              return '$moduleName';
            }
''' : ''}
            return decl.originalName.startsWith('NS') ? null : '$moduleName';
          }
        ),
        protocols: fg.Protocols(
          include: (fg.Declaration decl) => classes.contains(decl.originalName),
          module: (fg.Declaration decl) {
${hasAsyncFlutterApi ? '''
            if (decl.originalName == 'NSURLCredential' ||
                decl.originalName == 'NSURLSessionAuthChallengeDisposition') {
              return '$moduleName';
            }
''' : ''}
            return decl.originalName.startsWith('NS') ? null : '$moduleName';
          },
        ),
      ),
    ),
  ).generate(
    logger: null,
    tempDirectory: Uri.directory('${path.relative(objcDir, from: generatorOptions.exampleAppDirectory ?? './')}'),
  );
      ''');
    });
    sink.write(indent.toString());
  }
}
