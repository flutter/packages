import 'package:ffigen/ffigen.dart' as fg;
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:swiftgen/swiftgen.dart';

Future<void> main() async {
  final List<String> classes = <String>[
    'JniHostIntegrationCoreApi',
    'JniHostIntegrationCoreApiSetup',
    'BasicClass',
    'JniTestsError'
  ];
  final List<String> enums = <String>[
    'JniAnEnum',
  ];
  await SwiftGen(
    target: Target(
      // triple: 'x86_64-apple-macosx14.0',
      triple: 'arm64-apple-ios',
      sdk: Uri.directory(
        '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk',
        // '/Applications/Xcode/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk',
      ),
    ),
    input: ObjCCompatibleSwiftFileInput(
      module: 'test_plugin',
      files: <Uri>[
        Uri.file(
            '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/test_plugin/ios/Classes/JniTests.gen.swift')
      ],
    ),
    tempDirectory: Uri.directory('temp'),
    outputModule: 'test_plugin',
    ffigen: FfiGenConfig(
      output: Uri.file(
          '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/shared_test_plugin_code/lib/src/generated/jni_tests.gen.ffi.dart'),
      outputObjC: Uri.file(
          '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/shared_test_plugin_code/lib/src/generated/jni_tests.gen.m'),
      externalVersions: fg.ExternalVersions(
        ios: fg.Versions(min: Version(12, 0, 0)),
        macos: fg.Versions(min: Version(10, 14, 0)),
      ),
      objcInterfaces: fg.DeclarationFilters(
        shouldInclude: (Declaration decl) =>
            classes.contains(decl.originalName),
      ),
      enumClassDecl: fg.DeclarationFilters(
        shouldInclude: (Declaration decl) => enums.contains(decl.originalName),
      ),
      preamble: '''
  // Copyright 2013 The Flutter Authors. All rights reserved.
  // Use of this source code is governed by a BSD-style license that can be
  // found in the LICENSE file.
  // 

  // ignore_for_file: always_specify_types, camel_case_types, non_constant_identifier_names, unnecessary_non_null_assertion, unused_element, unused_field
  // coverage:ignore-file
  ''',
    ),
  ).generate();
}
