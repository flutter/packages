// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'process_utils.dart';

Future<int> runPigeon({
  required String input,
  String? kotlinOut,
  String? kotlinPackage,
  String? iosSwiftOut,
  String? cppHeaderOut,
  String? cppSourceOut,
  String? cppNamespace,
  String? dartOut,
  String? dartTestOut,
  bool streamOutput = true,
}) async {
  const bool hasDart = false;
  final List<String> args = <String>[
    'run',
    'pigeon',
    '--input',
    input,
    '--copyright_header',
    './copyright_header.txt',
  ];
  if (kotlinOut != null) {
    args.addAll(<String>['--experimental_kotlin_out', kotlinOut]);
  }
  if (kotlinPackage != null) {
    args.addAll(<String>['--experimental_kotlin_package', kotlinPackage]);
  }
  if (iosSwiftOut != null) {
    args.addAll(<String>['--experimental_swift_out', iosSwiftOut]);
  }
  if (cppHeaderOut != null) {
    args.addAll(<String>[
      '--experimental_cpp_header_out',
      cppHeaderOut,
    ]);
  }
  if (cppSourceOut != null) {
    args.addAll(<String>[
      '--experimental_cpp_source_out',
      cppSourceOut,
    ]);
  }
  if (cppNamespace != null) {
    args.addAll(<String>[
      '--cpp_namespace',
      cppNamespace,
    ]);
  }
  if (dartOut != null) {
    args.addAll(<String>['--dart_out', dartOut]);
  }
  if (dartTestOut != null) {
    args.addAll(<String>['--dart_test_out', dartTestOut]);
  }
  if (!hasDart) {
    args.add('--one_language');
  }
  return runProcess('dart', args,
      streamOutput: streamOutput, logFailure: !streamOutput);
}
