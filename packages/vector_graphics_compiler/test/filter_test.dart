// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// XML text adjacency is intentional in the filter regression fixtures.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_codec/src/filter.dart';
import 'package:vector_graphics_compiler/src/svg/filter.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  test('filter template href resolves percent-encoded fragment identifiers', () {
    final VectorFilter filter = readFilterDefinitions(
      '<svg><filter id="base"><feFlood/></filter><filter id="f" href="#%62ase"/></svg>',
    )['url(#f)']!;
    expect(filter.children.single.name, 'feFlood');
  });
  test('disconnected primitives are removed before resolving their lengths', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '<svg width="32" height="32"><defs><filter id="f">'
      '<feImage href="missing.svg" width="bogus"/>'
      '<feFlood flood-color="red"/></filter></defs>'
      '<rect width="32" height="32" filter="url(#f)"/></svg>',
    );
    expect(instructions.commands.first.filter!.children.single.name, 'feFlood');
  });
  for (final attributes in <String>[
    'style="filter:url(#f)" filter="none"',
    'filter="none" style="filter:url(#f)"',
    'style="filter:url(#f) !important"',
    'style="FILTER:URL(\'#f\') ! important; filter:none"',
    r'style="filter:url(#\66 )"',
    'filter="url(#%66)"',
    'filter="none" style="filter:url(#f)/* unfinished"',
    'filter="url(#f)" style="filter:broken"',
    'filter="url(#f)" style="filter:revert-layer"',
    'style="broken; filter:/* comment */url(#f)"',
  ]) {
    test('target inline filter cascade: $attributes', () {
      final VectorInstructions instructions = parseWithoutOptimizers(
        '<svg width="32" height="32"><defs><filter id="f"><feFlood/></filter></defs>'
        '<rect width="32" height="32" $attributes/></svg>',
      );
      expect(instructions.commands.where((c) => c.filter != null), hasLength(1));
    });
  }
  for (final keyword in ['initial', 'unset', 'revert']) {
    test('target filter $keyword overrides a presentation reference', () {
      final VectorInstructions instructions = parseWithoutOptimizers(
        '<svg width="32" height="32"><defs><filter id="f"><feFlood/></filter></defs>'
        '<rect width="32" height="32" filter="url(#f)" style="filter:$keyword"/></svg>',
      );
      expect(instructions.commands.where((c) => c.filter != null), isEmpty);
    });
  }
  test('explicit filter inheritance applies to the child separately', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '<svg width="32" height="32"><defs><filter id="f"><feOffset dx="1"/></filter></defs>'
      '<g filter="url(#f)"><rect width="32" height="32" style="filter:inherit"/></g></svg>',
    );
    expect(instructions.commands.where((c) => c.filter != null), hasLength(2));
  });
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
  const floodSvg =
      '<svg width="128" height="128"> '
      '<defs><filter id="f"><feFlood id="ink" flood-color="currentColor"/></filter></defs> '
      '<rect width="32" height="32" filter="url(#f)"/></svg>';
  test('flood currentColor uses the compiler theme', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      floodSvg,
      theme: const SvgTheme(currentColor: Color(0xff123456)),
    );
    expect(
      instructions.commands.first.filter!.children.single.attributes['flood-color-argb'],
      0xff123456.toString(),
    );
  });
  test('flood ColorMapper receives element, property, id, and resolved color', () {
    final mapper = _FilterColorMapper();
    final VectorInstructions instructions = parseWithoutOptimizers(floodSvg, colorMapper: mapper);
    expect(mapper.floodCall, ('ink', 'feFlood', 'flood-color', Color.opaqueBlack));
    expect(
      instructions.commands.first.filter!.children.single.attributes['flood-color-argb'],
      0x80402010.toString(),
    );
  });

  for (final (String attributes, int expected) in <(String, int)>[
    ('flood-color="bogus"', 0xff000000),
    ('flood-color="red" style="flood-color: bogus"', 0xffff0000),
    ('flood-color="red" style="flood-color: #gggggg"', 0xffff0000),
    ('flood-color="rgb(bogus)"', 0xff000000),
    ('flood-color="red" style="flood-color: hsl(bogus)"', 0xffff0000),
    ('flood-color="currentColor" color="bogus"', 0xff000000),
    ('flood-color="RED"', 0xffff0000),
    ('flood-color="blue" style="flood-color: red !important"', 0xffff0000),
    ('style="flood-color: red !important; flood-color: blue"', 0xffff0000),
    ('style="flood-color: red; flood-color: blue !important"', 0xff0000ff),
    ('style="flood-color: red ! important; flood-color: blue"', 0xffff0000),
    ('style="FLOOD-COLOR: red"', 0xffff0000),
    ('flood-color="red" style="flood-color: INITIAL"', 0xff000000),
    ('flood-color="InItIaL"', 0xff000000),
    ('flood-color="red" style="flood-color: ReVeRt"', 0xff000000),
    ('flood-color="red" style="flood-color: blue; flood-color: ReVeRt-LaYeR"', 0xffff0000),
    ('style="flood-color: blue; flood-color: revert-layer"', 0xff000000),
  ]) {
    test('invalid filter color is ignored: $attributes', () {
      final VectorInstructions instructions = parseWithoutOptimizers(
        '<svg width="32" height="32"><defs><filter id="f"><feFlood $attributes/></filter></defs> '
        '<rect width="32" height="32" filter="url(#f)"/></svg>',
      );
      expect(
        int.parse(
          instructions.commands.first.filter!.children.single.attributes['flood-color-argb']!,
        ),
        expected,
      );
    });
  }
  for (final (String attribute, String expected) in <(String, String)>[
    ('', 'sRGB'),
    ('inherit', 'sRGB'),
    ('unset', 'sRGB'),
    ('initial', 'linearRGB'),
    ('INITIAL', 'linearRGB'),
    ('linearRGB', 'linearRGB'),
    ('auto', 'auto'),
    ('bad', 'sRGB'),
    ('SRGB', 'sRGB'),
  ]) {
    test('filter color space inheritance: $attribute', () {
      final Map<String, VectorFilter> definitions = readFilterDefinitions(
        '<svg style="color-interpolation-filters:sRGB"><defs><filter id="f"> '
        '<feColorMatrix ${attribute.isEmpty ? '' : 'color-interpolation-filters="$attribute"'}/> '
        '</filter></defs></svg>',
      );
      expect(
        definitions.values.single.children.single.attributes['color-interpolation-filters'],
        expected,
      );
    });
  }
  test('invalid filter color space in style does not override its presentation attribute', () {
    final Map<String, VectorFilter> definitions = readFilterDefinitions(
      '<svg><filter id="f"><feColorMatrix color-interpolation-filters="sRGB" '
      'style="color-interpolation-filters:bad"/></filter></svg>',
    );
    expect(
      definitions.values.single.children.single.attributes['color-interpolation-filters'],
      'sRGB',
    );
  });
  for (final (String keyword, String? expected) in <(String, String?)>[
    ('ReVeRt', null),
    ('ReVeRt-LaYeR', 'sRGB'),
  ]) {
    test('CSS $keyword resolves filter color space across style origins', () {
      final Map<String, VectorFilter> definitions = readFilterDefinitions(
        '<svg><filter id="f"><feColorMatrix color-interpolation-filters="sRGB" '
        'style="color-interpolation-filters:$keyword"/></filter></svg>',
      );
      expect(
        definitions.values.single.children.single.attributes['color-interpolation-filters'],
        expected,
      );
    });
  }
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

class _FilterColorMapper extends ColorMapper {
  (String?, String, String, Color)? floodCall;

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    if (elementName == 'feFlood') {
      floodCall = (id, elementName, attributeName, color);
      return const Color(0x80402010);
    }
    return color;
  }
}
