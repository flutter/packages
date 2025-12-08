// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/src/fife.dart';

void main() {
  group('addSizeDirectiveToUrl', () {
    const double size = 20;

    group('Old style URLs', () {
      const base =
          'https://lh3.googleusercontent.com/-ukEAtRyRhw8/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rfhID9XACtdb9q_xK43VSXQvBV11Q.CMID';
      const expected = '$base/s20-c/photo.jpg';

      test('with directives, sets size', () {
        const url = '$base/s64-c/photo.jpg';
        expect(addSizeDirectiveToUrl(url, size), expected);
      });

      test('no directives, sets size and crop', () {
        const url = '$base/photo.jpg';
        expect(addSizeDirectiveToUrl(url, size), expected);
      });

      test('no crop, sets size and crop', () {
        const url = '$base/s64/photo.jpg';
        expect(addSizeDirectiveToUrl(url, size), expected);
      });
    });

    group('New style URLs', () {
      const base =
          'https://lh3.googleusercontent.com/a-/AAuE7mC0Lh4F4uDtEaY7hpe-GIsbDpqfMZ3_2UhBQ8Qk';
      const expected = '$base=c-s20';

      test('with directives, sets size', () {
        const url = '$base=s120-c';
        expect(addSizeDirectiveToUrl(url, size), expected);
      });

      test('no directives, sets size and crop', () {
        const url = base;
        expect(addSizeDirectiveToUrl(url, size), expected);
      });

      test('no directives, but with an equals sign, sets size and crop', () {
        const url = '$base=';
        expect(addSizeDirectiveToUrl(url, size), expected);
      });

      test('no crop, adds crop', () {
        const url = '$base=s120';
        expect(addSizeDirectiveToUrl(url, size), expected);
      });

      test(
        'many directives, sets size and crop, preserves other directives',
        () {
          const url = '$base=s120-c-fSoften=1,50,0';
          const expected = '$base=c-fSoften=1,50,0-s20';
          expect(addSizeDirectiveToUrl(url, size), expected);
        },
      );
    });
  });
}
