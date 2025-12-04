// Copyright 2013 The Flutter Authors. All rights reserved.
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
    final Indent indent = Indent(sink);

    indent.format('''
import 'package:ffigen/ffigen.dart' as fg;
import 'package:pub_semver/pub_semver.dart';
import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swiftgen/src/config.dart';
import 'package:swiftgen/swiftgen.dart';

  ''');
    indent.writeScoped('Future<void> main() async {', '}', () {
      indent.writeScoped('final List<String> classes = <String>[', '];', () {
        indent.inc();
        indent.writeln("'PigeonInternalNull',");
        indent.writeln("'PigeonTypedData',");
        indent.writeln("'NumberWrapper',");
        for (final Api api in root.apis) {
          if (api is AstHostApi || api is AstFlutterApi) {
            indent.writeln("'${api.name}',");
            indent.writeln("'${api.name}Setup',");
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
      indent.writeScoped('final List<String> enums = <String>[', '];', () {
        indent.inc();
        for (final Enum enumType in root.enums) {
          indent.writeln("'${enumType.name}',");
        }
        indent.dec();
      });

      indent.format('''
  await SwiftGenerator(
    target: Target(
      // triple: 'x86_64-apple-macosx14.0',
      triple: 'arm64-apple-ios',
      sdk: Uri.directory(
        '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk',
        // '/Applications/Xcode/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk',
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
      objectiveCFile:  Uri.file('${path.posix.join(generatorOptions.basePath ?? '', path.withoutExtension(generatorOptions.dartOut ?? ''))}.m'),
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
            return decl.originalName.startsWith('NS') ? null : 'test_plugin';
          }
        ),
      ),
    ),
  ).generate(
    logger: null,
    tempDirectory: Uri.directory('temp'),
  );
      ''');
    });
  }
}
