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

/// Generator for jnigen yaml configuration file.
class FfigenConfigGenerator extends Generator<InternalFfigenConfigOptions> {
  @override
  void generate(
      InternalFfigenConfigOptions generatorOptions, Root root, StringSink sink,
      {required String dartPackageName}) {
    final Indent indent = Indent(sink);

    indent.format('''
import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:swiftgen/swiftgen.dart';

Future<void> main() async {
  // TODO(https://github.com/dart-lang/native/issues/2371): Remove this.
  Logger.root.onRecord.listen((record) {
    stderr.writeln('\${record.level.name}: \${record.message}');
  });

  await SwiftGen(
    target: Target(
      triple: 'x86_64-apple-macosx14.0',
      sdk: Uri.directory(
        '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk',
      ),
    ),
    input: ObjCCompatibleSwiftFileInput(
      module: 'AVFAudio',
      files: [Uri.file('avf_audio_wrapper.swift')],
    ),
    tempDirectory: Uri.directory('temp'),
    outputModule: 'AVFAudioWrapper',
    ffigen: FfiGenConfig(
      output: Uri.file('avf_audio_bindings.dart'),
      outputObjC: Uri.file('avf_audio_wrapper.m'),
      externalVersions: fg.ExternalVersions(
        ios: fg.Versions(min: Version(12, 0, 0)),
        macos: fg.Versions(min: Version(10, 14, 0)),
      ),
      objcInterfaces: fg.DeclarationFilters(
        shouldInclude: (decl) => decl.originalName == 'AVAudioPlayerWrapper',
      ),
      preamble: \'''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// coverage:ignore-file
\''',
    ),
  ).generate();

  final result = Process.runSync('swiftc', [
    '-emit-library',
    '-o',
    'avf_audio_wrapper.dylib',
    '-module-name',
    'AVFAudioWrapper',
    'avf_audio_wrapper.swift',
    '-framework',
    'AVFAudio',
    '-framework',
    'Foundation',
  ]);
  if (result.exitCode != 0) {
    print('Failed to build the swift wrapper library');
    print(result.stdout);
    print(result.stderr);
  }
}
      // name: SwiftLibrary
      // language: swift
      // output: '${path.posix.join(generatorOptions.basePath ?? '', path.withoutExtension(generatorOptions.dartOut ?? ''))}.ffi.dart'
      // exclude-all-by-default: true
      // headers:
      //   entry-points:
      //     - '${generatorOptions.swiftOptions.swiftOut}'
      // preamble: |
      //   # Header input

      //   // ignore_for_file: camel_case_types, non_constant_identifier_names
      //   // ignore_for_file: unused_element, unused_field, return_of_invalid_type
      //   // ignore_for_file: void_checks, annotate_overrides
      //   // ignore_for_file: no_leading_underscores_for_local_identifiers
      //   // ignore_for_file: library_private_types_in_public_api

      ''');
    indent.writeScoped('// objc-interfaces:', '', () {
      indent.writeScoped('// include:', '', () {
        for (final Api api in root.apis) {
          if (api is AstHostApi || api is AstFlutterApi) {
            indent.writeln("// - '${api.name}'");
            indent.writeln("// - '${api.name}Registrar'");
          }
        }
        for (final Class dataClass in root.classes) {
          indent.writeln("// - '${dataClass.name}'");
        }
        for (final Enum enumType in root.enums) {
          indent.writeln("// - '${enumType.name}'");
        }
      });
      indent.writeScoped('// include:', '', () {
        for (final Class dataClass in root.classes) {
          indent.writeln("// '${dataClass.name}': '${dataClass.name}'");
        }
        for (final Enum enumType in root.enums) {
          indent.writeln("// '${enumType.name}': '${enumType.name}'");
        }
      });
    });
  }
}
