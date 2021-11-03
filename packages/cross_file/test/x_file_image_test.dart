// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'image_data.dart';

void main() {
  test('XFileImage sets tag', () async {
    final Uint8List bytes = Uint8List.fromList(kBlueSquarePng);
    final XFile file = XFile('', bytes: bytes);
    final XFileImage provider = XFileImage(file);

    final MultiFrameImageStreamCompleter completer =
        provider.load(provider, _decoder) as MultiFrameImageStreamCompleter;

    expect(completer.debugLabel, 'XFileImage(${describeIdentity(file)})');
  });

  test('Resize image sets tag', () async {
    final XFile file = XFile('', bytes: Uint8List.fromList(kBlueSquarePng));
    final ResizeImage provider =
        ResizeImage(XFileImage(file), width: 40, height: 40);
    final MultiFrameImageStreamCompleter completer = provider.load(
      await provider.obtainKey(ImageConfiguration.empty),
      _decoder,
    ) as MultiFrameImageStreamCompleter;

    expect(completer.debugLabel,
        'XFileImage(${describeIdentity(file)}) - Resized(40×40)');
  });
}

Future<Codec> _decoder(Uint8List bytes,
    {int? cacheWidth, int? cacheHeight, bool? allowUpscaling}) async {
  return FakeCodec();
}

class FakeCodec implements Codec {
  @override
  void dispose() {}

  @override
  int get frameCount => throw UnimplementedError();

  @override
  Future<FrameInfo> getNextFrame() {
    throw UnimplementedError();
  }

  @override
  int get repetitionCount => throw UnimplementedError();
}
