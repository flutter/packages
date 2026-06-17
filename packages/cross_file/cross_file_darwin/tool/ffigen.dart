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
      preamble:
          '// Copyright 2013 The Flutter Authors\n'
          '// Use of this source code is governed by a BSD-style license that can be\n'
          '// found in the LICENSE file.',
      objectiveCFile: packageRoot.resolve(
        'darwin/cross_file_darwin/Sources/cross_file_darwin_objc/ffi_bindings.g.m',
      ),
    ),
    headers: Headers(
      entryPoints: <Uri>[
        Uri.file('$macSdkPath/System/Library/Frameworks/Photos.framework/Headers/Photos.h'),
      ],
      compilerOptions: <String>['-include stdint.h'],
    ),
    objectiveC: ObjectiveC(
      interfaces: Interfaces(
        include: (Declaration declaration) {
          return <String>{
            'NSFileManager',
            'NSObject',
            'PHAsset',
            'PHAssetResource',
            'PHAssetResourceManager',
            'PHFetchResult',
            'PHImageManager',
            'PHImageRequestOptions',
            'UTType',
          }.contains(declaration.originalName);
        },
        includeMember: (Declaration declaration, String member) {
          final String interfaceName = declaration.originalName;
          final signature = member;
          return switch (interfaceName) {
            'NSFileManager' => <String>{
              'defaultManager',
              'isReadableFileAtPath:',
            }.contains(signature),
            'NSObject' => <String>{'valueForKey:'}.contains(signature),
            'PHAsset' => <String>{
              'fetchAssetsWithLocalIdentifiers:options:',
              'modificationDate',
            }.contains(signature),
            'PHAssetResource' => <String>{
              'assetResourcesForAsset:',
              'contentType',
              'originalFilename',
              'type',
            }.contains(signature),
            'PHAssetResourceManager' => <String>{
              'defaultManager',
              'requestDataForAssetResource:options:dataReceivedHandler:completionHandler:',
            }.contains(signature),
            'PHFetchResult' => <String>{'firstObject'}.contains(signature),
            'PHImageManager' => <String>{
              'defaultManager',
              'requestImageDataAndOrientationForAsset:options:resultHandler:',
            }.contains(signature),
            'PHImageRequestOptions' => <String>{
              'new',
              'setNetworkAccessAllowed:',
            }.contains(signature),
            'UTType' => <String>{'preferredMIMEType'}.contains(signature),
            _ => false,
          };
        },
      ),
    ),
  ).generate();
}
