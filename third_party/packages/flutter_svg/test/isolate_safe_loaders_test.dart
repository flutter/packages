import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/src/utilities/compute.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const String _svg = '<svg width="12" height="12"><rect width="12" height="12"/></svg>';
const String _invalidSvg = 'not SVG';

// Each isolate has its own copy, so this only counts calls on the test isolate.
int _provideSvgCalls = 0;

void main() {
  setUp(() {
    svg.cache.clear();
    _provideSvgCalls = 0;
    debugRunComputeInline = false;
  });
  tearDown(() => debugRunComputeInline = true);

  test('loaders provide the SVG in the compute isolate by default', () async {
    const loader = _CountingStringLoader(_svg);
    final ByteData bytes = await loader.loadBytes(null);

    expect(bytes.lengthInBytes, greaterThan(0));
    expect(_provideSvgCalls, 0);
  });

  test('the asset loader provides the SVG on the calling isolate', () async {
    final loader = _CountingAssetLoader(_FutureHoldingBundle(_svg));
    final ByteData bytes = await loader.loadBytes(null);

    expect(bytes.lengthInBytes, greaterThan(0));
    expect(_provideSvgCalls, 1);
  });

  test('the network loader works with a client holding a Future', () async {
    final loader = SvgNetworkLoader(
      'https://example.com/icon.svg',
      httpClient: _FutureHoldingClient(_svg),
    );
    final ByteData bytes = await loader.loadBytes(null);

    expect(bytes.lengthInBytes, greaterThan(0));
  });

  test('an invalid SVG from the asset loader reports an error', () async {
    final loader = _CountingAssetLoader(_FutureHoldingBundle(_invalidSvg));

    await expectLater(loader.loadBytes(null), throwsA(anything));
    expect(_provideSvgCalls, 1);
  });
}

class _CountingStringLoader extends SvgStringLoader {
  const _CountingStringLoader(super.svg);

  @override
  String provideSvg(void message) {
    _provideSvgCalls++;
    return super.provideSvg(message);
  }
}

class _CountingAssetLoader extends SvgAssetLoader {
  const _CountingAssetLoader(AssetBundle bundle) : super('icon.svg', assetBundle: bundle);

  @override
  String provideSvg(ByteData? message) {
    _provideSvgCalls++;
    return super.provideSvg(message);
  }
}

class _FutureHoldingBundle extends Fake implements AssetBundle {
  _FutureHoldingBundle(this.content);

  final String content;
  final Completer<void> _unsendableState = Completer<void>();

  @override
  Future<ByteData> load(String key) async {
    assert(!_unsendableState.isCompleted);
    return Uint8List.fromList(utf8.encode(content)).buffer.asByteData();
  }
}

class _FutureHoldingClient extends Fake implements http.Client {
  _FutureHoldingClient(this.content);

  final String content;
  final Completer<void> _unsendableState = Completer<void>();

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    assert(!_unsendableState.isCompleted);
    return http.Response(content, 200);
  }
}
