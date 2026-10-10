// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/style.dart';

void main() {
  test('a complete declaration before an EOF comment remains valid', () {
    expect(resolveInlineStyles({'style': 'filter:url(#f)/* unfinished'})['filter'], 'url(#f)');
  });
  test('filter URLs decode CSS escapes and reject malformed tokens', () {
    expect(normalizeFilterReference(r'url(#\66 ilter)'), 'url(#filter)');
    expect(normalizeFilterReference(r'''url("#a\"b")'''), 'url(#a"b)');
    expect(normalizeFilterReference(r'url(#a\)b)'), 'url(#a)b)');
    for (final value in [r'url(#a b)', 'url("#a"b")', r'url("#a\")', 'url(#a) extra']) {
      expect(normalizeFilterReference(value), isNull, reason: value);
    }
  });
  test('a stray closing parenthesis does not swallow the following declaration', () {
    final Map<String, String> attributes = resolveInlineStyles({
      'filter': 'none',
      'style': 'filter:); filter:url(#f)',
    }, validProperty: (name, value) => name != 'filter' || normalizeFilterReference(value) != null);
    expect(attributes['filter'], 'url(#f)');
  });
  test('declaration delimiters inside quotes and functions are preserved', () {
    final Map<String, String> attributes = resolveInlineStyles({
      'style': 'href:url("data:image/svg+xml;a:b"); font-family:"a;b:c"; filter: url(#f)',
    });
    expect(attributes['href'], 'url("data:image/svg+xml;a:b")');
    expect(attributes['font-family'], '"a;b:c"');
    expect(attributes['filter'], 'url(#f)');
  });
  test('comments, priority and malformed declarations follow the cascade', () {
    final Map<String, String> attributes = resolveInlineStyles({
      'filter': 'none',
      'style': 'invalid; :x; filter: /* first */ url(#f) ! IMPORTANT; filter:none; filter:;',
    });
    expect(attributes['filter'], 'url(#f)');
  });
  test('invalid declarations leave the presentation fallback available', () {
    final Map<String, String> attributes = resolveInlineStyles({
      'filter': 'url(#f)',
      'style': 'filter:garbage',
    }, validProperty: (name, value) => name != 'filter' || normalizeFilterReference(value) != null);
    expect(attributes['filter'], 'url(#f)');
  });
}
