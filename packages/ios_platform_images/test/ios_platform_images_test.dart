// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_platform_images/ios_platform_images.dart';
import 'package:ios_platform_images/src/messages.g.dart';

void main() {
  late FakePlatformImagesApi fakeApi;

  setUp(() {
    fakeApi = FakePlatformImagesApi();
    setPlatformImageHostApi(fakeApi);
  });

  test('resolveURL passes arguments', () async {
    const String name = 'a name';
    const String extension = '.extension';

    await IosPlatformImages.resolveURL(name, extension: extension);

    expect(fakeApi.passedName, name);
    expect(fakeApi.passedExtension, extension);
  });

  test('resolveURL returns null', () async {
    expect(await IosPlatformImages.resolveURL('foobar'), null);
  });

  test('resolveURL returns result', () async {
    const String result = 'a result';
    fakeApi.resolutionResult = result;

    expect(await IosPlatformImages.resolveURL('foobar'), result);
  });

  test('loadImage passes argument', () async {
    fakeApi.loadResult = PlatformImageData(data: Uint8List(1), scale: 1.0);
    const String name = 'a name';

    IosPlatformImages.load(name);

    expect(fakeApi.passedName, name);
  });
}

class FakePlatformImagesApi implements PlatformImagesApi {
  String? passedName;
  String? passedExtension;
  String? resolutionResult;
  PlatformImageData? loadResult;

  @override
  Future<PlatformImageData?> loadImage(String name) async {
    passedName = name;
    return loadResult;
  }

  @override
  Future<String?> resolveUrl(String name, String? extension) async {
    passedName = name;
    passedExtension = extension;
    return resolutionResult;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
