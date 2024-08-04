@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/adsense.dart';

void main() {
  group('Adsense', () {
    test('Singleton instance', () {
      final Adsense instance1 = Adsense();
      final Adsense instance2 = Adsense();
      expect(instance1, same(instance2));
    });
  });
}
