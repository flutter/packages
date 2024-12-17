import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_test/flutter_svg_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('finds', () {
    group('with bytesLoader', () {
      // #docregion ByLoader
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
      // #enddocregion ByLoader

      testWidgets('network svg', (WidgetTester widgetTester) async {
        final http.Client fakeClient = _FakeHttpClient();
        final SvgPicture asset = SvgPicture.network(
          'svg.dart',
          httpClient: fakeClient,
        );
        await widgetTester.pumpWidget(asset);

        expect(find.svg(asset.bytesLoader), findsOneWidget);
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

    // #docregion ByPath
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
    // #enddocregion ByPath

    testWidgets('network svg with url', (WidgetTester widgetTester) async {
      const String svgUri = 'svg.dart';
      await widgetTester.pumpWidget(SvgPicture.network(svgUri));

      expect(find.svgNetworkWithUrl(svgUri), findsOneWidget);
    });

    testWidgets('file svg with path', (WidgetTester widgetTester) async {
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

class _FakeHttpClient extends Fake implements http.Client {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return http.Response(_svgStr, 200);
  }
}

// Ignore this because the minimum flutter sdk needs this cast.
// ignore: unnecessary_cast
final Uint8List _svgBytes = utf8.encode(_svgStr) as Uint8List;

const String _svgStr = '''
<svg height="100" width="100">
  <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />
</svg>
''';
