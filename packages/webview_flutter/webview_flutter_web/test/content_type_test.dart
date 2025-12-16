// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_web/src/content_type.dart';

void main() {
  group('ContentType.parse', () {
    test('basic content-type (lowers case)', () {
      final contentType = ContentType.parse('text/pLaIn');

      expect(contentType.mimeType, 'text/plain');
      expect(contentType.boundary, isNull);
      expect(contentType.charset, isNull);
    });

    test('with charset', () {
      final contentType = ContentType.parse('text/pLaIn; charset=utf-8');

      expect(contentType.mimeType, 'text/plain');
      expect(contentType.boundary, isNull);
      expect(contentType.charset, 'utf-8');
    });

    test('with boundary', () {
      final contentType = ContentType.parse('text/pLaIn; boundary=---xyz');

      expect(contentType.mimeType, 'text/plain');
      expect(contentType.boundary, '---xyz');
      expect(contentType.charset, isNull);
    });

    test('with charset and boundary', () {
      final contentType = ContentType.parse(
        'text/pLaIn; charset=utf-8; boundary=---xyz',
      );

      expect(contentType.mimeType, 'text/plain');
      expect(contentType.boundary, '---xyz');
      expect(contentType.charset, 'utf-8');
    });

    test('with boundary and charset', () {
      final contentType = ContentType.parse(
        'text/pLaIn; boundary=---xyz; charset=utf-8',
      );

      expect(contentType.mimeType, 'text/plain');
      expect(contentType.boundary, '---xyz');
      expect(contentType.charset, 'utf-8');
    });

    test('with a bunch of whitespace, boundary and charset', () {
      final contentType = ContentType.parse(
        '     text/pLaIn   ; boundary=---xyz;    charset=utf-8    ',
      );

      expect(contentType.mimeType, 'text/plain');
      expect(contentType.boundary, '---xyz');
      expect(contentType.charset, 'utf-8');
    });

    test('empty string', () {
      final contentType = ContentType.parse('');

      expect(contentType.mimeType, '');
      expect(contentType.boundary, isNull);
      expect(contentType.charset, isNull);
    });

    test('unknown parameter (throws)', () {
      expect(() {
        ContentType.parse('text/pLaIn; wrong=utf-8');
      }, throwsStateError);
    });
  });
}
