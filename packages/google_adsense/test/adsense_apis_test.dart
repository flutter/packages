@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/adsense.dart';

void main() {
  group('AdSense exports', () {
    test('AdUnitParams is exported', () {
      expect(AdUnitParams, isNotNull);
    });

    test('AdSense is exported', () {
      expect(Adsense, isNotNull);
    });
  });
}
