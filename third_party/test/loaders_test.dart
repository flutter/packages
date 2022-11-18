import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Uses the cache', () async {
    const TestLoader loader = TestLoader();
    final ByteData bytes = await loader.loadBytes(null);
    final ByteData bytes2 = await loader.loadBytes(null);
    expect(identical(bytes, bytes2), true);
  });

  test('Empty cache', () async {
    svg.cache.maximumSize = 0;
    const TestLoader loader = TestLoader();
    final ByteData bytes = await loader.loadBytes(null);
    final ByteData bytes2 = await loader.loadBytes(null);
    expect(identical(bytes, bytes2), false);
    svg.cache.maximumSize = 100;
  });
}

class TestLoader extends SvgLoader<void> {
  const TestLoader({super.theme, super.colorMapper});

  @override
  String provideSvg(void message) {
    return '<svg width="10" height="10"></svg>';
  }
}
