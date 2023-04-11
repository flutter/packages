import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_test/flutter_svg_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('finds', () {
    group('with bytesLoader', () {
      testWidgets('asset svg', (WidgetTester widgetTester) async {
        final SvgPicture asset = SvgPicture.asset('test/flutter_logo.svg');
        await widgetTester.pumpWidget(
          DefaultAssetBundle(
            bundle: _FakeAssetBundle(),
            child: asset,
          ),
        );

        expect(find.svg(asset.bytesLoader), findsOneWidget);
      });

      testWidgets('network svg', (WidgetTester widgetTester) async {
        await HttpOverrides.runZoned(() async {
          final SvgPicture asset = SvgPicture.network('svg.dart');
          await widgetTester.pumpWidget(asset);

          expect(find.svg(asset.bytesLoader), findsOneWidget);
        }, createHttpClient: (SecurityContext? c) => _setupFakeClient);
      });

      testWidgets('string svg', (WidgetTester widgetTester) async {
        final SvgPicture asset = SvgPicture.string(_svgStr);
        await widgetTester.pumpWidget(asset);

        expect(find.svg(asset.bytesLoader), findsOneWidget);
      });

      testWidgets('file svg', (WidgetTester widgetTester) async {
        final File file = File('test/flutter_logo.svg');
        final SvgPicture asset = SvgPicture.file(file);
        await widgetTester.pumpWidget(asset);

        expect(find.svg(asset.bytesLoader), findsOneWidget);
      });

      testWidgets('memory svg', (WidgetTester widgetTester) async {
        final SvgPicture asset = SvgPicture.memory(_svgBytes);
        await widgetTester.pumpWidget(asset);

        expect(find.svg(asset.bytesLoader), findsOneWidget);
      });
    });

    testWidgets('asset svg with path', (WidgetTester widgetTester) async {
      const String svgPath = 'test/flutter_logo.svg';
      await widgetTester.pumpWidget(
        DefaultAssetBundle(
          bundle: _FakeAssetBundle(),
          child: SvgPicture.asset(svgPath),
        ),
      );

      expect(find.svgAssetWithPath(svgPath), findsOneWidget);
    });

    testWidgets('network svg with url', (WidgetTester widgetTester) async {
      await HttpOverrides.runZoned(() async {
        const String svgUri = 'svg.dart';
        await widgetTester.pumpWidget(SvgPicture.network(svgUri));

        expect(find.svgNetworkWithUrl(svgUri), findsOneWidget);
      }, createHttpClient: (SecurityContext? c) => _setupFakeClient);
    });

    testWidgets('file svg wit path', (WidgetTester widgetTester) async {
      const String svgPath = 'test/flutter_logo.svg';

      await widgetTester.pumpWidget(SvgPicture.file(File(svgPath)));

      expect(find.svgFileWithPath(svgPath), findsOneWidget);
    });

    testWidgets('memory svg with bytes', (WidgetTester widgetTester) async {
      final Uint8List svgBytes = _svgBytes;
      await widgetTester.pumpWidget(SvgPicture.memory(svgBytes));

      expect(find.svgMemoryWithBytes(svgBytes), findsOneWidget);
    });
  });
}

HttpClient get _setupFakeClient {
  final _FakeHttpClientResponse fakeResponse = _FakeHttpClientResponse();
  final _FakeHttpClientRequest fakeRequest =
      _FakeHttpClientRequest(fakeResponse);
  return _FakeHttpClient(fakeRequest);
}

class _FakeAssetBundle extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _svgStr;
  }

  @override
  Future<ByteData> load(String key) async {
    return Uint8List.fromList(utf8.encode(_svgStr)).buffer.asByteData();
  }
}

class _FakeHttpClient extends Fake implements HttpClient {
  _FakeHttpClient(this.request);

  _FakeHttpClientRequest request;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => request;
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  final Map<String, String?> values = <String, String?>{};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name] = value.toString();
  }

  @override
  List<String>? operator [](String key) {
    return <String>[values[key]!];
  }
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  _FakeHttpClientRequest(this.response);

  _FakeHttpClientResponse response;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => response;
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int statusCode = 200;

  @override
  int contentLength = _svgStr.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<Uint8List>.fromIterable(<Uint8List>[_svgBytes]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }
}

final Uint8List _svgBytes = utf8.encode(_svgStr) as Uint8List;

const String _svgStr = '''
<svg height="100" width="100">
  <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />
</svg> 
''';
