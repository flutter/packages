import 'dart:io';
import 'package:ffigen/ffigen.dart' as fg;
import 'package:pub_semver/pub_semver.dart';
import 'package:swift2objc/src/ast/_core/interfaces/declaration.dart';
import 'package:swiftgen/src/config.dart';
import 'package:swiftgen/swiftgen.dart';

Future<void> main(List<String> args) async {
  var sdkPath =
      '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk';
  if (args.isNotEmpty) {
    sdkPath = args[0];
  } else {
    var didFallback = true;
    try {
      final ProcessResult result = await Process.run('xcrun', <String>[
        '--sdk',
        'iphoneos',
        '--show-sdk-path',
      ]);
      if (result.exitCode == 0) {
        sdkPath = (result.stdout as String).trim();
        didFallback = false;
      }
    } catch (_) {}
    if (didFallback) {
      // ignore: avoid_print
      print(
        'Failed to find iOS SDK path with xcrun. Falling back to default iOS SDK path.',
      );
      // ignore: avoid_print
      print(
        'If FFI generation fails, please provide a valid iOS SDK path in the Pigeon configuration for SwiftOptions(appleSdkPath: ...), or pass it as an argument when running ffigen.',
      );
    }
  }

  final classes = <String>[
    'NiTestsPigeonInternalNull',
    'NiTestsPigeonTypedData',
    'NiTestsNumberWrapper',
    'NSURLCredential',
    'NIHostIntegrationCoreApi',
    'NIHostIntegrationCoreApiSetup',
    'NIFlutterIntegrationCoreApiBridge',
    'NIFlutterIntegrationCoreApiRegistrar',
    'NIUnusedClassBridge',
    'NIAllTypesBridge',
    'NIAllNullableTypesBridge',
    'NIAllNullableTypesWithoutRecursionBridge',
    'NIAllClassesWrapperBridge',
    'NiTestsError',
  ];
  final enums = <String>[
    'NIAnEnum',
    'NIAnotherEnum',
    'NSURLSessionAuthChallengeDisposition',
    'NiTestsMyDataType',
  ];
  var targetTriple = '';
  if (targetTriple.isEmpty) {
    targetTriple = sdkPath.toLowerCase().contains('macosx')
        ? 'x86_64-apple-macosx14.0'
        : 'arm64-apple-ios';
  }

  await SwiftGenerator(
    target: Target(triple: targetTriple, sdk: Uri.directory(sdkPath)),
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
        '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/test_plugin/darwin/test_plugin/Sources/test_plugin_objc/NiTests.gen.m',
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
            if (decl.originalName == 'NSURLCredential' ||
                decl.originalName == 'NSURLSessionAuthChallengeDisposition') {
              return 'test_plugin';
            }

            return decl.originalName.startsWith('NS') ? null : 'test_plugin';
          },
        ),
        protocols: fg.Protocols(
          include: (fg.Declaration decl) => classes.contains(decl.originalName),
          module: (fg.Declaration decl) {
            if (decl.originalName == 'NSURLCredential' ||
                decl.originalName == 'NSURLSessionAuthChallengeDisposition') {
              return 'test_plugin';
            }

            return decl.originalName.startsWith('NS') ? null : 'test_plugin';
          },
        ),
      ),
    ),
  ).generate(
    logger: null,
    tempDirectory: Uri.directory(
      '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/test_plugin/darwin/test_plugin/Sources/test_plugin_objc',
    ),
  );
}
