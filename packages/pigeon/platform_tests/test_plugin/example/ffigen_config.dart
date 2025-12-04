import 'package:ffigen/ffigen.dart' as fg;
import 'package:pub_semver/pub_semver.dart';
import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swiftgen/src/config.dart';
import 'package:swiftgen/swiftgen.dart';

Future<void> main() async {
  final List<String> classes = <String>[
    'PigeonInternalNull',
    'PigeonTypedData',
    'NumberWrapper',
    'NIHostIntegrationCoreApi',
    'NIHostIntegrationCoreApiSetup',
    'NIAllTypesBridge',
    'NIAllNullableTypesWithoutRecursionBridge',
    'NIAllClassesWrapperBridge',
    'NiTestsError',
  ];
  final List<String> enums = <String>['NIAnEnum', 'NIAnotherEnum'];
  await SwiftGenerator(
    target: Target(
      // triple: 'x86_64-apple-macosx14.0',
      triple: 'arm64-apple-ios',
      sdk: Uri.directory(
        '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk',
        // '/Applications/Xcode/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk',
      ),
    ),
    inputs: <SwiftGenInput>[
      ObjCCompatibleSwiftFileInput(
        files: <Uri>[
          Uri.file(
            '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/test_plugin/darwin/test_plugin/Sources/test_plugin/NiTests.gen.swift',
          ),
        ],
      ),
    ],
    include: (Declaration d) =>
        classes.contains(d.name) || enums.contains(d.name),
    output: Output(
      module: 'test_plugin',
      dartFile: Uri.file(
        '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/shared_test_plugin_code/lib/src/generated/ni_tests.gen.ffi.dart',
      ),
      objectiveCFile: Uri.file(
        '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/shared_test_plugin_code/lib/src/generated/ni_tests.gen.m',
      ),
      preamble: '''
  // Copyright 2013 The Flutter Authors
  // Use of this source code is governed by a BSD-style license that can be
  // found in the LICENSE file.
  // 

  // ignore_for_file: always_specify_types, camel_case_types, non_constant_identifier_names, unnecessary_non_null_assertion, unused_element, unused_field
  // coverage:ignore-file
  ''',
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
          },
        ),
      ),
    ),
  ).generate(logger: null, tempDirectory: Uri.directory('temp'));
}
