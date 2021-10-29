import 'dart:typed_data';
import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:cross_file/src/x_file_image.dart';
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
    final Uint8List bytes = Uint8List.fromList(kBlueSquarePng);
    final ResizeImage provider =
        ResizeImage(MemoryImage(bytes), width: 40, height: 40);
    final MultiFrameImageStreamCompleter completer = provider.load(
      await provider.obtainKey(ImageConfiguration.empty),
      _decoder,
    ) as MultiFrameImageStreamCompleter;

    expect(completer.debugLabel,
        'XFileImage(${describeIdentity(bytes)}) - Resized(40×40)');
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
