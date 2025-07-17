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
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:swiftgen/swiftgen.dart';

Future<void> main() async {
  final List<String> classes = <String>[
    'JniAllTypes',
    'HostIntegrationCoreApi',
    'Host',
  ];
  await SwiftGen(
    target: Target(
      // triple: 'x86_64-apple-macosx14.0',
      triple: 'arm64-apple-ios',
      sdk: Uri.directory(
        '/Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk',
        // '/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk',
      ),
    ),
    input: ObjCCompatibleSwiftFileInput(
      module: 'JniTests',
      files: <Uri>[
        Uri.file(
            '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/test_plugin/ios/Classes/JniTests.gen.swift')
        // '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/test_plugin/macos/Classes/JniTests.gen.swift')
      ],
    ),
    tempDirectory: Uri.directory('temp'),
    outputModule: 'JniTests',
    ffigen: FfiGenConfig(
      output: Uri.file(
          '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/shared_test_plugin_code/lib/src/generated/jni_tests.gen.ffi.dart'),
      outputObjC: Uri.file(
          '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/test_plugin/ios/Classes/jni_tests.gen.m'),
      // '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/test_plugin/macos/Classes/jni_tests.gen.m'),
      externalVersions: fg.ExternalVersions(
        ios: fg.Versions(min: Version(12, 0, 0)),
        // macos: fg.Versions(min: Version(10, 14, 0)),
      ),
      objcInterfaces: fg.DeclarationFilters(
        shouldInclude: (Declaration decl) =>
            classes.contains(decl.originalName),
      ),
      preamble: \'''
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: always_specify_types, camel_case_types, non_constant_identifier_names, unnecessary_non_null_assertion, unused_element, unused_field
// coverage:ignore-file
        \''',
    ),
  ).generate();

}

''');
// import 'dart:io';

// import 'package:ffigen/ffigen.dart' as fg;
// import 'package:ffigen/src/config_provider/config_types.dart';
// import 'package:pub_semver/pub_semver.dart';
// import 'package:swiftgen/swiftgen.dart';

// Future<void> main() async {
//   final List<String> classes = <String>[
//   ''');
//     indent.inc(2);
//     for (final Api api in root.apis) {
//       if (api is AstHostApi || api is AstFlutterApi) {
//         indent.writeln("'${api.name}',");
//         // indent.writeln("'${api.name}Registrar',");
//       }
//     }
//     for (final Class dataClass in root.classes) {
//       indent.writeln("'${dataClass.name}',");
//     }
//     for (final Enum enumType in root.enums) {
//       indent.writeln("'${enumType.name}',");
//     }
//     indent.dec(2);

//     indent.format('''
//   ];
//   await SwiftGen(
//     target: Target(
//       // triple: 'x86_64-apple-macosx14.0',
//       triple: 'arm64-apple-ios',
//       sdk: Uri.directory(
//         '/Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk',
//         // '/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk',
//       ),
//     ),
//     input: ObjCCompatibleSwiftFileInput(
//       module: 'JniTests',
//       files: <Uri>[Uri.file('${generatorOptions.swiftOptions.swiftOut}')],
//     ),
//     tempDirectory: Uri.directory('temp'),
//     outputModule: 'JniTests',
//     ffigen: FfiGenConfig(
//       output: Uri.file('${path.posix.join(generatorOptions.basePath ?? '', path.withoutExtension(generatorOptions.dartOut ?? ''))}.ffi.dart'),
//       outputObjC: Uri.file('${path.posix.join(generatorOptions.basePath ?? '', path.withoutExtension(generatorOptions.dartOut ?? ''))}.m'),
//       externalVersions: fg.ExternalVersions(
//         ios: fg.Versions(min: Version(12, 0, 0)),
//         macos: fg.Versions(min: Version(10, 14, 0)),
//       ),
//       objcInterfaces: fg.DeclarationFilters(
//         shouldInclude: (Declaration decl) => classes.contains(decl.originalName),
//       ),
//       preamble: \'''
// // ${generatorOptions.swiftOptions.copyrightHeader?.join('\n// ') ?? ''}

// // ignore_for_file: always_specify_types, camel_case_types, non_constant_identifier_names, unnecessary_non_null_assertion, unused_element, unused_field
// // coverage:ignore-file
// \''',
//     ),
//   ).generate();

//   final result = Process.runSync('swiftc', <String>[
//     '-emit-library',
//     '-o',
//     'jni_tests.gen.dylib',
//     '-module-name',
//     'JniTests',
//     '-framework',
//     'Foundation',
//     '${generatorOptions.swiftOptions.swiftOut}',
//   ]);
//   if (result.exitCode != 0) {
//     print('Failed to build the swift wrapper library');
//     print(result.stdout);
//     print(result.stderr);
//   }
// }
//       ''');
//     // indent.writeScoped('// objc-interfaces:', '', () {
//     //   indent.writeScoped('// include:', '', () {
//     //     for (final Api api in root.apis) {
//     //       if (api is AstHostApi || api is AstFlutterApi) {
//     //         indent.writeln("// - '${api.name}'");
//     //         indent.writeln("// - '${api.name}Registrar'");
//     //       }
//     //     }
//     //     for (final Class dataClass in root.classes) {
//     //       indent.writeln("// - '${dataClass.name}'");
//     //     }
//     //     for (final Enum enumType in root.enums) {
//     //       indent.writeln("// - '${enumType.name}'");
//     //     }
//     //   });
//     //   indent.writeScoped('// include:', '', () {
//     //     for (final Class dataClass in root.classes) {
//     //       indent.writeln("// '${dataClass.name}': '${dataClass.name}'");
//     //     }
//     //     for (final Enum enumType in root.enums) {
//     //       indent.writeln("// '${enumType.name}': '${enumType.name}'");
//     //     }
//     //   });
//     // });
  }
}
