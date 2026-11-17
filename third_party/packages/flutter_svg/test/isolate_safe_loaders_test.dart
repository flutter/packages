import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/src/utilities/compute.dart';
import 'package:flutter_test/flutter_test.dart';

const String _svg = '<svg width="12" height="12"><rect width="12" height="12"/></svg>';

// Each isolate has its own copy, so this only counts calls on the test isolate.
int _provideSvgCalls = 0;

void main() {
  setUp(() {
    svg.cache.clear();
    _provideSvgCalls = 0;
    debugRunComputeInline = false;
  });
  tearDown(() => debugRunComputeInline = true);

  test('a sendable loader provides the SVG in the compute isolate', () async {
    final loader = _CountingAssetLoader(_SendableBundle());
    final ByteData bytes = await loader.loadBytes(null);

    expect(bytes.lengthInBytes, greaterThan(0));
    expect(_provideSvgCalls, 0);
  });

  test('an unsendable loader provides the SVG on the calling isolate', () async {
    final loader = _CountingAssetLoader(_FutureHoldingBundle());
    final ByteData bytes = await loader.loadBytes(null);

    expect(bytes.lengthInBytes, greaterThan(0));
    expect(_provideSvgCalls, 1);
  });

  test('an invalid SVG from an unsendable loader still reports an error', () async {
    final loader = _CountingAssetLoader(_FutureHoldingBundle('not SVG'));

    await expectLater(loader.loadBytes(null), throwsA(anything));
  });
}

class _CountingAssetLoader extends SvgAssetLoader {
  const _CountingAssetLoader(AssetBundle bundle) : super('icon.svg', assetBundle: bundle);

  @override
  String provideSvg(ByteData? message) {
    _provideSvgCalls++;
    return super.provideSvg(message);
  }
}

class _SendableBundle extends Fake implements AssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      Uint8List.fromList(utf8.encode(_svg)).buffer.asByteData();
}

class _FutureHoldingBundle extends Fake implements AssetBundle {
  _FutureHoldingBundle([this.content = _svg]);

  final String content;
  final Completer<void> _unsendableState = Completer<void>();

  @override
  Future<ByteData> load(String key) async {
    assert(!_unsendableState.isCompleted);
    return Uint8List.fromList(utf8.encode(content)).buffer.asByteData();
  }
}
