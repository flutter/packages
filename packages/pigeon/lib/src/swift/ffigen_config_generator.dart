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
    indent.format('''
import 'dart:io';
import 'package:ffigen/ffigen.dart' as fg;
import 'package:pub_semver/pub_semver.dart';
import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swiftgen/src/config.dart';
import 'package:swiftgen/swiftgen.dart';

  ''');
    final bool hasAsyncFlutterApi = root.apis.whereType<AstFlutterApi>().any(
      (AstFlutterApi api) =>
          api.methods.any((Method method) => method.isAsynchronous),
    );

    final String? configuredSdkPath =
        generatorOptions.swiftOptions.appleSdkPath;
    final String? configuredSdkTriple =
        generatorOptions.swiftOptions.appleSdkTriple;

    final String objcDir = path.posix.join(
      path.posix.dirname(
        path.posix.dirname(generatorOptions.swiftOptions.swiftOut),
      ),
      '${path.posix.basename(path.posix.dirname(generatorOptions.swiftOptions.swiftOut))}_objc',
    );

    indent.writeScoped('Future<void> main(List<String> args) async {', '}', () {
      if (configuredSdkPath != null) {
        indent.writeln("String sdkPath = '$configuredSdkPath';");
        indent.writeln('if (args.isNotEmpty) {');
        indent.writeln('  sdkPath = args[0];');
        indent.writeln('}');
      } else {
        indent.format('''
  var sdkPath = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk';
  if (args.isNotEmpty) {
    sdkPath = args[0];
  } else {
    var didFallback = true;
    try {
      final ProcessResult result = await Process.run('xcrun', <String>['--sdk', 'iphoneos', '--show-sdk-path']);
      if (result.exitCode == 0) {
        sdkPath = (result.stdout as String).trim();
        didFallback = false;
      }
    } catch (_) {}
    if (didFallback) {
      // ignore: avoid_print
      print('Failed to find iOS SDK path with xcrun. Falling back to default iOS SDK path.');
      // ignore: avoid_print
      print('If FFI generation fails, please provide a valid iOS SDK path in the Pigeon configuration for SwiftOptions(appleSdkPath: ...), or pass it as an argument when running ffigen.');
    }
  }
''');
      }
      final String prefix =
          generatorOptions.swiftOptions.fileSpecificClassNameComponent ?? '';
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
        indent.writeln(
          "'${generatorOptions.swiftOptions.errorClassName ?? 'PigeonError'}'",
        );
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
    targetTriple = sdkPath.toLowerCase().contains('macosx') ? 'x86_64-apple-macosx14.0' : 'arm64-apple-ios';
  }

  await SwiftGenerator(
    target: Target(
      triple: targetTriple,
      sdk: Uri.directory(
        sdkPath,
      ),
    ),
    inputs: <SwiftGenInput>[ObjCCompatibleSwiftFileInput(files: <Uri>[
        Uri.file('${generatorOptions.swiftOptions.swiftOut}')
      ])
    ],
    include: (Declaration d) =>
        classes.contains(d.name) || enums.contains(d.name),
    output: Output(
      module: '${generatorOptions.swiftOptions.ffiModuleName ?? ''}',
      dartFile: Uri.file('${path.posix.join(generatorOptions.basePath ?? '', path.withoutExtension(generatorOptions.dartOut ?? ''))}.ffi.dart'),
      objectiveCFile: Uri.file('${path.posix.join(objcDir, '${path.posix.basenameWithoutExtension(generatorOptions.swiftOptions.swiftOut)}.m')}'),
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
              return '${generatorOptions.swiftOptions.ffiModuleName ?? ''}';
            }
''' : ''}
            return decl.originalName.startsWith('NS') ? null : '${generatorOptions.swiftOptions.ffiModuleName ?? ''}';
          }
        ),
        protocols: fg.Protocols(
          include: (fg.Declaration decl) => classes.contains(decl.originalName),
          module: (fg.Declaration decl) {
${hasAsyncFlutterApi ? '''
            if (decl.originalName == 'NSURLCredential' ||
                decl.originalName == 'NSURLSessionAuthChallengeDisposition') {
              return '${generatorOptions.swiftOptions.ffiModuleName ?? ''}';
            }
''' : ''}
            return decl.originalName.startsWith('NS') ? null : '${generatorOptions.swiftOptions.ffiModuleName ?? ''}';
          },
        ),
      ),
    ),
  ).generate(
    logger: null,
    tempDirectory: Uri.directory('$objcDir'),
  );
      ''');
    });
    sink.write(indent.toString());
  }
}
