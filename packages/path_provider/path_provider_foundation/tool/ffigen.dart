// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final Uri packageRoot = Platform.script.resolve('../');
  FfiGenerator(
    output: Output(
      dartFile: packageRoot.resolve('lib/src/ffi_bindings.g.dart'),
      style: const DynamicLibraryBindings(
        wrapperName: 'FoundationFFI',
        wrapperDocComment: 'Bindings for NSFileManager.',
      ),
    ),
    headers: Headers(
      entryPoints: <Uri>[
        Uri.file(
          '$macSdkPath/System/Library/Frameworks/AVFAudio.framework/Headers/AVAudioPlayer.h',
        ),
      ],
    ),
    objectiveC: ObjectiveC(
      interfaces: Interfaces(
        include: (Declaration declaration) {
          return <String>{
            'NSFileManager',
            'NSURL',
          }.contains(declaration.originalName);
        },
        includeMember: (Declaration declaration, String member) {
          final String interfaceName = declaration.originalName;
          final signature = member;
          return switch (interfaceName) {
            'NSFileManager' => <String>{
              'containerURLForSecurityApplicationGroupIdentifier:',
              'defaultManager',
            }.contains(signature),
            'NSURL' => <String>{
              'fileURLWithPath:',
              'URLByAppendingPathComponent:',
            }.contains(signature),
            _ => false,
          };
        },
      ),
      categories: Categories(
        include: (Declaration declaration) => <String>{
          // For URLByAppendingPathComponent:
          'NSURLPathUtilities',
        }.contains(declaration.originalName),
        includeTransitive: false,
      ),
    ),
    functions: Functions.includeSet(<String>{
      'NSSearchPathForDirectoriesInDomains',
    }),
  ).generate();
}
