// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// XML text adjacency is intentional in the layout regression fixtures.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:vector_graphics_compiler/src/svg/filter.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  setUpAll(() => expect(initializePathOpsFromFlutterCache(), isTrue));
  test('descriptive filter children are ignored at every nesting level', () {
    final VectorFilter filter = readFilterDefinitions(
      '<svg><filter id="f"><metadata><feUnknown/></metadata><title>T</title><desc>D</desc>'
      '<feOffset><metadata/><title>T</title><desc>D</desc></feOffset></filter></svg>',
    ).values.single;
    expect(filter.children.map((VectorFilter p) => p.name), <String>['feOffset']);
    expect(filter.children.single.children, isEmpty);
  });
  test('unknown operation is retained for the explicit runtime diagnostic', () {
    expect(
      readFilterDefinitions(
        '<svg><filter id="f"><feUnknown/></filter></svg>',
      ).values.single.children.single.name,
      'feUnknown',
    );
  });
  test('filter lengths use definition styles, inherited fonts and theme x-height', () {
    final VectorFilter filter = readFilterDefinitions(
      '<svg font-size="20"><defs font-size="150%"><filter id="f" width="2em" '
      'height="2ex" x="1rem" y="10%"><feOffset width="1in" style="font-size:50%;height:2em"/>'
      '</filter></defs></svg>',
      theme: const SvgTheme(fontSize: 10, xHeight: 4),
    ).values.single;
    expect(filter.attributes, containsPair('width', '60.0'));
    expect(filter.attributes, containsPair('height', '24.0'));
    expect(filter.attributes, containsPair('x', '20.0'));
    expect(filter.attributes, containsPair('y', '10%'));
    expect(filter.children.single.attributes, containsPair('width', '96.0'));
    expect(filter.children.single.attributes, containsPair('height', '30.0'));
  });
  test('filter font lengths accept text keywords and a zero-sized theme', () {
    final VectorFilter filter = readFilterDefinitions(
      '<svg font-size="medium"><filter id="f" width="2em" height="2ex"/></svg>',
      theme: const SvgTheme(fontSize: 0, xHeight: 0),
    ).values.single;
    expect(filter.attributes['width'], '36.0');
    expect(filter.attributes['height'], '18.0');
  });
  test('unused filter definitions do not disable clipping or overdraw optimization', () {
    const body =
        '<defs><clipPath id="c"><rect width="10" height="10"/></clipPath>FILTER</defs>'
        '<g clip-path="url(#c)"><rect width="20" height="20"/>'
        '<rect width="20" height="20"/></g>';
    VectorInstructions parse(String definition) => SvgParser(
      '<svg width="128" height="128">${body.replaceFirst('FILTER', definition)}</svg>',
      const SvgTheme(),
      null,
      true,
      null,
    ).parse();
    final VectorInstructions plain = parse('');
    final VectorInstructions unused = parse('<filter id="unused"><feOffset/></filter>');
    expect(unused.commands, plain.commands);
    expect(unused.paths, plain.paths);
    expect(unused.commands.where((DrawCommand c) => c.type == DrawCommandType.clip), isEmpty);
  });
  test('optimizers process sibling runs and preserve geometry inside filters', () {
    final VectorInstructions instructions = SvgParser(
      '<svg width="128" height="128"><defs><filter id="f"><feOffset/></filter>'
      '<clipPath id="c"><rect width="10" height="10"/></clipPath></defs>'
      '<g clip-path="url(#c)"><rect width="20" height="20"/></g>'
      '<g filter="url(#f)"><rect width="100" height="100" fill="none"/>'
      '<rect width="16" height="16"/></g>'
      '<g clip-path="url(#c)"><rect width="20" height="20"/></g></svg>',
      const SvgTheme(),
      null,
      true,
      null,
    ).parse();
    expect(instructions.commands.where((DrawCommand c) => c.type == DrawCommandType.clip), isEmpty);
    expect(
      instructions.commands.where((DrawCommand c) => c.type == DrawCommandType.pathGeometry),
      hasLength(1),
    );
    expect(
      instructions.commands.where((DrawCommand c) => c.type == DrawCommandType.beginFilter),
      hasLength(1),
    );
  });
}
