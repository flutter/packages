import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    svg.cache.clear();
    svg.cache.maximumSize = 100;
  });

  test('ColorMapper updates the cache', () async {
    const TestLoader loaderA = TestLoader();
    const TestLoader loaderB = TestLoader(colorMapper: _TestColorMapper());
    final ByteData bytesA = await loaderA.loadBytes(null);
    final ByteData bytesB = await loaderB.loadBytes(null);
    expect(identical(bytesA, bytesB), false);
    expect(svg.cache.count, 2);
  });

  test('SvgTheme updates the cache', () async {
    const TestLoader loaderA =
        TestLoader(theme: SvgTheme(currentColor: Color(0xFFABCDEF)));
    const TestLoader loaderB =
        TestLoader(theme: SvgTheme(currentColor: Color(0xFFFEDCBA)));
    final ByteData bytesA = await loaderA.loadBytes(null);
    final ByteData bytesB = await loaderB.loadBytes(null);
    expect(identical(bytesA, bytesB), false);
    expect(svg.cache.count, 2);
  });

  test('Uses the cache', () async {
    const TestLoader loader = TestLoader();
    final ByteData bytes = await loader.loadBytes(null);
    final ByteData bytes2 = await loader.loadBytes(null);
    expect(identical(bytes, bytes2), true);
    expect(svg.cache.count, 1);
  });

  test('Empty cache', () async {
    svg.cache.maximumSize = 0;
    const TestLoader loader = TestLoader();
    final ByteData bytes = await loader.loadBytes(null);
    final ByteData bytes2 = await loader.loadBytes(null);
    expect(identical(bytes, bytes2), false);
    svg.cache.maximumSize = 100;
  });

  test('AssetLoader respects packages', () async {
    final TestBundle bundle = TestBundle(<String, ByteData>{
      'foo': Uint8List(0).buffer.asByteData(),
      'packages/packageName/foo': Uint8List(1).buffer.asByteData(),
    });
    final SvgAssetLoader loader = SvgAssetLoader('foo', assetBundle: bundle);
    final SvgAssetLoader packageLoader =
        SvgAssetLoader('foo', assetBundle: bundle, packageName: 'packageName');
    expect((await loader.prepareMessage(null))!.lengthInBytes, 0);
    expect((await packageLoader.prepareMessage(null))!.lengthInBytes, 1);
  });
}

class TestBundle extends Fake implements AssetBundle {
  TestBundle(this.map);

  final Map<String, ByteData> map;

  @override
  Future<ByteData> load(String key) async {
    return map[key]!;
  }
}

class TestLoader extends SvgLoader<void> {
  const TestLoader({this.keyName = 'A', super.theme, super.colorMapper});

  final String keyName;

  @override
  String provideSvg(void message) {
    return '<svg width="10" height="10"></svg>';
  }

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    return SvgCacheKey(
        theme: theme, colorMapper: colorMapper, keyData: keyName);
  }
}

class _TestColorMapper extends ColorMapper {
  const _TestColorMapper();

  @override
  Color substitute(
      String? id, String elementName, String attributeName, Color color) {
    return color;
  }
}
