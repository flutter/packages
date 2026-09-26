// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_codec/src/filter.dart';
import 'package:vector_graphics_compiler/src/svg/filter.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('missing filter is removed before all optimizers, including root and use', () {
    expect(initializePathOpsFromFlutterCache(), isTrue);
    for (final body in <String>[
      '<g opacity=".5" filter="url(#missing)"><rect width="20" height="30"/></g>',
      '<defs><g id="shape" filter="url(#missing)"><rect width="20" height="30"/></g></defs><use href="#shape"/>',
      '<rect width="20" height="30"/>',
    ]) {
      for (final root in <String>['', 'filter="url(#missing)"']) {
        final Uint8List bytes = encodeSvg(
          xml: '<svg width="100" height="100" $root>$body</svg>',
          debugName: 'unresolved filter',
        );
        expect(bytes[4], 1);
      }
    }
  });
  const shape = '<rect x="10" y="20" width="30" height="40" filter="url(#f)"/>';
  const definition =
      '<defs><filter id="f"><feFuture in="SourceGraphic" result="x"/></filter></defs>';
  for (final forward in <bool>[false, true]) {
    test('filter references resolve in either order: $forward', () {
      final VectorInstructions instructions = parseWithoutOptimizers(
        '<svg width="100" height="100">${forward ? shape + definition : definition + shape}</svg>',
      );
      expect(instructions.commands.map((DrawCommand c) => c.type), <DrawCommandType>[
        DrawCommandType.beginFilter,
        DrawCommandType.path,
        DrawCommandType.endFilter,
      ]);
      expect(instructions.commands.first.filter!.children.single.name, 'feFuture');
    });
  }
  test('inline style overrides presentation attributes', () {
    final Map<String, VectorFilter> definitions = readFilterDefinitions(
      '<svg><filter id="f"><feFuture dx="2" style="dx: 3; dy: -4"/></filter></svg>',
    );
    expect(definitions['url(#f)']!.children.single.attributes['dx'], '3');
    expect(definitions['url(#f)']!.children.single.attributes['dy'], '-4');
  });
  test('nested parameter elements and their order survive compilation', () {
    final Map<String, VectorFilter> definitions = readFilterDefinitions(
      '<svg><filter id="f"><title>name</title><feFuture><feParameter v="1"/><feParameter v="2"/></feFuture></filter></svg>',
    );
    expect(
      definitions.values.single.children.single.children.map((c) => c.attributes['v']),
      <String>['1', '2'],
    );
  });
  test('two references produce two isolated boundaries', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '<svg width="100" height="100">$definition$shape$shape</svg>',
    );
    expect(
      instructions.commands.where((DrawCommand c) => c.type == DrawCommandType.beginFilter),
      hasLength(2),
    );
  });
  test('filter is not inherited by group children', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '<svg width="100" height="100">$definition<g filter="url(#f)"><rect width="10" height="10"/><rect x="20" width="10" height="10"/></g></svg>',
    );
    expect(
      instructions.commands.where((DrawCommand c) => c.type == DrawCommandType.beginFilter),
      hasLength(1),
    );
  });
  test('missing filter leaves source commands intact', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '<svg width="100" height="100">$shape</svg>',
    );
    expect(instructions.commands.single.type, DrawCommandType.path);
  });
  test('unknown operations are retained for a renderer diagnostic', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '<svg width="100" height="100">$definition$shape</svg>',
    );
    expect(instructions.commands.first.filter!.children.single.attributes['in'], 'SourceGraphic');
  });
  test('filter commands select version 2; ordinary assets remain version 1', () {
    Uint8List compile(String body) => encodeSvg(
      xml: '<svg width="100" height="100">$body</svg>',
      debugName: 'test',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    expect(compile('<rect width="10" height="10"/>')[4], 1);
    expect(compile('$definition$shape')[4], 2);
  });
}
