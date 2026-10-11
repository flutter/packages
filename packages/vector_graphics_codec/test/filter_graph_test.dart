// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

void main() {
  VectorFilter graph(List<VectorFilter> primitives) => VectorFilter('filter', const {}, primitives);
  VectorFilter node(
    String name, [
    Map<String, String> attributes = const {},
    List<VectorFilter> children = const [],
  ]) => VectorFilter(name, attributes, children);

  test('independent generators prune preceding branches', () {
    for (final generator in ['feFlood', 'feImage', 'feTurbulence']) {
      final VectorFilter filter = graph([node('feGaussianBlur'), node(generator)]);
      expect(filter.activePrimitives, [filter.children.last]);
      expect(filter.children, hasLength(2));
    }
  });
  test('implicit, unknown, empty and forward inputs preserve the original predecessor', () {
    for (final reference in <String?>[null, '', 'unknown', 'future']) {
      final VectorFilter filter = graph([
        node('feFlood', {'result': 'first'}),
        node('feOffset', {if (reference != null) 'in': reference, 'result': 'future'}),
      ]);
      expect(filter.activePrimitives, filter.children);
    }
  });
  test('a named branch skips unrelated intermediates without changing inputs', () {
    final VectorFilter filter = graph([
      node('feFlood', {'result': 'color'}),
      node('feTurbulence'),
      node('feOffset', {'in': 'color'}),
    ]);
    expect(filter.activePrimitives, [filter.children[0], filter.children[2]]);
  });
  test('duplicate names resolve to the closest preceding result', () {
    final VectorFilter filter = graph([
      node('feFlood', {'result': 'color'}),
      node('feImage', {'result': 'color'}),
      node('feOffset', {'in': 'color', 'result': 'color'}),
    ]);
    expect(filter.activePrimitives, filter.children.skip(1).toList());
  });
  test('built-in inputs take precedence over names', () {
    for (final name in [
      'SourceGraphic',
      'SourceAlpha',
      'FillPaint',
      'StrokePaint',
      'BackgroundImage',
      'BackgroundAlpha',
    ]) {
      final VectorFilter filter = graph([
        node('feFlood', {'result': name}),
        node('feOffset', {'in': name}),
      ]);
      expect(filter.activePrimitives, [filter.children.last]);
    }
  });
  test('binary inputs and merge nodes retain every contributing branch', () {
    for (final name in ['feBlend', 'feComposite', 'feDisplacementMap', 'feMerge']) {
      final VectorFilter filter = graph([
        node('feFlood', {'result': 'color'}),
        node('feImage', {'result': 'image'}),
        node('feTurbulence'),
        node(
          name,
          name == 'feMerge' ? {} : {'in': 'color', 'in2': 'image'},
          name == 'feMerge'
              ? [
                  node('feMergeNode', {'in': 'color'}),
                  node('feMergeNode', {'in': 'image'}),
                ]
              : [],
        ),
      ]);
      expect(filter.activePrimitives, [filter.children[0], filter.children[1], filter.children[3]]);
    }
  });
  test('empty merge does not consume its predecessor', () {
    final VectorFilter filter = graph([node('feFlood'), node('feMerge')]);
    expect(filter.activePrimitives, [filter.children.last]);
  });
  test('long implicit chains are analyzed without recursive traversal', () {
    final VectorFilter filter = graph(List.generate(20000, (_) => node('feOffset')));
    expect(filter.activePrimitives, hasLength(20000));
  });
}
