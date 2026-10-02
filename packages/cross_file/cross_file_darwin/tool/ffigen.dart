// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final Uri packageRoot = Platform.script.resolve('../');
  FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve('lib/src/ffi_bindings.g.dart')),
      preamble:
          '// Copyright 2013 The Flutter Authors\n'
          '// Use of this source code is governed by a BSD-style license that can be\n'
          '// found in the LICENSE file.',
      objectiveCFile: packageRoot.resolve(
        'darwin/cross_file_darwin/Sources/cross_file_darwin_objc/ffi_bindings.g.m',
      ),
    ),
    input: Input(
      entryPoints: <Uri>[
        Uri.file('$macSdkPath/System/Library/Frameworks/Photos.framework/Headers/Photos.h'),
      ],
    ),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (ObjCInterface declaration) {
          declaration.isIncluded = <String>{
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
        objCProtocol: (ObjCProtocol declaration) {
          declaration.isIncluded = <String>{'NSKeyValueCoding'}.contains(declaration.originalName);
        },
        objCMethod: (ObjCMethod declaration) {
          final String interfaceName = declaration.parent.originalName;
          final String signature = declaration.originalName;
          declaration.isIncluded = switch (interfaceName) {
            'NSFileManager' => <String>{
              'defaultManager',
              'isReadableFileAtPath:',
              'isWritableFileAtPath:',
            }.contains(signature),
            'NSKeyValueCoding' => <String>{'valueForKey:'}.contains(signature),
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
    ],
  ).generate();
}
