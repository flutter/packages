import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:logging/logging.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:swiftgen/swiftgen.dart';

Future<void> main() async {
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
      preamble: '''
// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: always_specify_types, camel_case_types, non_constant_identifier_names, unnecessary_non_null_assertion, unused_element, unused_field
// coverage:ignore-file
''',
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
// output: '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/shared_test_plugin_code/lib/src/generated/jni_tests.gen.ffi.dart'
// exclude-all-by-default: true
// headers:
//   entry-points:
//     - '/Users/tarrinneal/work/packages/packages/pigeon/platform_tests/test_plugin/ios/Classes/JniTests.gen.swift'
// preamble: |
//   # Header input

//   // ignore_for_file: camel_case_types, non_constant_identifier_names
//   // ignore_for_file: unused_element, unused_field, return_of_invalid_type
//   // ignore_for_file: void_checks, annotate_overrides
//   // ignore_for_file: no_leading_underscores_for_local_identifiers
//   // ignore_for_file: library_private_types_in_public_api

// objc-interfaces:
// include:
// - 'JniHostIntegrationCoreApi'
// - 'JniHostIntegrationCoreApiRegistrar'
// - 'JniHostTrivialApi'
// - 'JniHostTrivialApiRegistrar'
// - 'JniHostSmallApi'
// - 'JniHostSmallApiRegistrar'
// - 'JniFlutterIntegrationCoreApi'
// - 'JniFlutterIntegrationCoreApiRegistrar'
// - 'JniUnusedClass'
// - 'JniAllTypes'
// - 'JniAllNullableTypes'
// - 'JniAllNullableTypesWithoutRecursion'
// - 'JniAllClassesWrapper'
// - 'JniAnEnum'
// - 'JniAnotherEnum'
// include:
// 'JniUnusedClass': 'JniUnusedClass'
// 'JniAllTypes': 'JniAllTypes'
// 'JniAllNullableTypes': 'JniAllNullableTypes'
// 'JniAllNullableTypesWithoutRecursion': 'JniAllNullableTypesWithoutRecursion'
// 'JniAllClassesWrapper': 'JniAllClassesWrapper'
// 'JniAnEnum': 'JniAnEnum'
// 'JniAnotherEnum': 'JniAnotherEnum'
