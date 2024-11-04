import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('SvgPicture.string - use placeHolder or errorWidget if an error causes', () {
    setUp(() {});
    tearDown(() {});
    testWidgets('load an empty string', (WidgetTester tester) async {
      await tester.pumpWidget(SvgPicture.string(''));
      await tester.pumpAndSettle();
      expectOneSvgPicture(tester);
    });
    testWidgets('show placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(SvgPicture.string(
        'an invalid svg format string',
        placeholderBuilder: buildPlaceHolderWidget,
      ));
      await tester.pumpAndSettle();
      expectOneSvgPicture(tester);
      await tester.pumpAndSettle();
      expect(find.text('placeholder'), findsOneWidget);
    });
    testWidgets('show errorWidget', (WidgetTester tester) async {
      await tester.pumpWidget(SvgPicture.string(
        'an invalid svg format string',
        placeholderBuilder: buildPlaceHolderWidget,
        errorBuilder: buildErrorWidget,
      ));
      await tester.pumpAndSettle();
      expectOneSvgPicture(tester);
      await tester.pumpAndSettle();
      expectOneErrorWidget(tester);
    });
  });

  group('SvgPicture.asset - use placeHolder or errorWidget if an error causes', () {
    late FakeAssetBundle assetBundle;
    setUp(() {
      assetBundle = FakeAssetBundle();
    });
    tearDown(() {});
    testWidgets('load an empty asset', (WidgetTester tester) async {
      await tester.pumpWidget(DefaultAssetBundle(
          bundle: assetBundle,
          child: SvgPicture.asset(
            'empty',
          )));
      await tester.pumpAndSettle();
      expectOneSvgPicture(tester);
    });
    testWidgets('show placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(DefaultAssetBundle(
          bundle: assetBundle,
          child: SvgPicture.asset(
            'an invalid asset',
            placeholderBuilder: buildPlaceHolderWidget,
          )));
      await tester.pumpAndSettle();
      expectOneSvgPicture(tester);
      await tester.pumpAndSettle();
      expect(find.text('placeholder'), findsOneWidget);
    });
    testWidgets('show errorWidget', (WidgetTester tester) async {
      await tester.pumpWidget(DefaultAssetBundle(
          bundle: assetBundle,
          child: SvgPicture.asset(
            'an invalid asset',
            placeholderBuilder: buildPlaceHolderWidget,
            errorBuilder: buildErrorWidget,
          )));
      await tester.pumpAndSettle();
      expectOneSvgPicture(tester);
      await tester.pumpAndSettle();
      expectOneErrorWidget(tester);
    });
  });

  group('SvgPicture.network - use placeHolder or errorWidget if an error causes', () {
    late FakeHttpClient httpClient = FakeHttpClient();
    setUp(() {
      httpClient = FakeHttpClient();
    });
    tearDown(() {});
    testWidgets('http exception', (WidgetTester tester) async {
      await tester.pumpWidget(SvgPicture.network('/404', httpClient: httpClient));
      await tester.pumpAndSettle();
      expectOneSvgPicture(tester);
    });
    testWidgets('wrong svg format - show placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(SvgPicture.network(
        '/200',
        placeholderBuilder: buildPlaceHolderWidget,
        httpClient: httpClient,
      ));
      await tester.pumpAndSettle();
      expectOneSvgPicture(tester);
      await tester.pumpAndSettle();
      expect(find.text('placeholder'), findsOneWidget);
    });
    testWidgets('show placeholder - show errorWidget', (WidgetTester tester) async {
      await tester.pumpWidget(SvgPicture.network(
        '/200',
        placeholderBuilder: buildPlaceHolderWidget,
        errorBuilder: buildErrorWidget,
        httpClient: httpClient,
      ));
      await tester.pumpAndSettle();
      expectOneSvgPicture(tester);
      await tester.pumpAndSettle();
      expectOneErrorWidget(tester);
    });
  });
}

void expectOneSvgPicture(WidgetTester tester) => expect(find.byType(SvgPicture), findsOneWidget);
void expectOneErrorWidget(WidgetTester tester) => expect(find.text('error'), findsOneWidget);

Widget buildPlaceHolderWidget(BuildContext context) => const Text('placeholder', textDirection: TextDirection.ltr);
Widget buildErrorWidget(BuildContext context, Object error, StackTrace stackTrace) =>
    const Text('error', textDirection: TextDirection.ltr);

class FakeAssetBundle extends Fake implements AssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'empty') {
      return Future<ByteData>.value(ByteData(0));
    }
    throw Exception('error');
  }
}

class FakeHttpClient extends Fake implements http.Client {
  FakeHttpClient();

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    debugPrint('FakeHttpClient.get: ${url.path}');
    if (url.path == '/404') {
      return Future<http.Response>.value(http.Response('', HttpStatus.notFound));
    } else if (url.path == '/200') {
      return Future<http.Response>.value(http.Response('''invalid svg format''', HttpStatus.ok));
    } else {
      throw Exception('$url is invalid');
    }
  }
}
