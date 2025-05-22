// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/numbers.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'test_svg_strings.dart';

class _TestOpacityColorMapper implements ColorMapper {
  const _TestOpacityColorMapper();

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color.value == 0xff000000) {
      return const Color(0x7fff0000);
    } else {
      return color;
    }
  }
}

void main() {
  test('Reuse ID self-referentially', () {
    final VectorInstructions instructions = parseWithoutOptimizers('''
<?xml version="1.0" encoding="UTF-8"?>
<svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <defs>
    <rect x="2" y="2" width="20" height="20" id="path-1"/>
  </defs>
  <use id="path-1" fill="#FFFFFF" xlink:href="#path-1"/>
</svg>
''');

    expect(instructions.paths.length, 1);
  });

  test('Self-referentially ID', () {
    final VectorInstructions instructions = parseWithoutOptimizers('''
<?xml version="1.0" encoding="UTF-8"?>
<svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <use id="path-1" fill="#FFFFFF" xlink:href="#path-1"/>
</svg>
''');

    expect(instructions.paths.length, 0);
  });

  test('Text transform but no xy', () {
    final VectorInstructions instructions = parseWithoutOptimizers('''
<svg viewBox="0 0 450 150" xmlns="http://www.w3.org/2000/svg">
  <g fill="red" font-family="Arimo,Liberation Sans,HammersmithOne,Helvetica,Arial,sans-serif"
    font-weight="600">
    <text font-size="40" transform="translate(60 45)">東急電鉄路線図</text>
    <text font-size="22" transform="translate(60 75)">Tōkyū Railways route map</text>
  </g>
</svg>
''');

    expect(instructions.text, const <TextConfig>[
      TextConfig(
        '東急電鉄路線図',
        0.0,
        'Arimo,Liberation Sans,HammersmithOne,Helvetica,Arial,sans-serif',
        FontWeight.w600,
        40.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
      TextConfig(
        'Tōkyū Railways route map',
        0.0,
        'Arimo,Liberation Sans,HammersmithOne,Helvetica,Arial,sans-serif',
        FontWeight.w600,
        22.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
    ]);
    expect(instructions.textPositions, <TextPosition>[
      TextPosition(
          reset: true, transform: AffineMatrix.identity.translated(60, 45)),
      TextPosition(
          reset: true, transform: AffineMatrix.identity.translated(60, 75)),
    ]);
  });

  test('Fill rule inheritence', () {
    final VectorInstructions instructions =
        parseWithoutOptimizers(inheritFillRule);

    expect(instructions.paints, const <Paint>[
      Paint(
        blendMode: BlendMode.srcOver,
        stroke: Stroke(color: Color(0xffff0000)),
        fill: Fill(color: Color.opaqueBlack),
      ),
    ]);
    expect(instructions.paths, <Path>[
      Path(
        commands: const <PathCommand>[
          MoveToCommand(60.0, 10.0),
          LineToCommand(31.0, 100.0),
          LineToCommand(108.0, 45.0),
          LineToCommand(12.0, 45.0),
          LineToCommand(89.0, 100.0),
          CloseCommand()
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(160.0, 10.0),
          LineToCommand(131.0, 100.0),
          LineToCommand(208.0, 45.0),
          LineToCommand(112.0, 45.0),
          LineToCommand(189.0, 100.0),
          CloseCommand()
        ],
        fillType: PathFillType.evenOdd,
      )
    ]);
    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 0),
    ]);
  });

  test('Text whitespace handling (number bubbles)', () {
    final VectorInstructions instructions =
        parseWithoutOptimizers(numberBubbles);

    expect(
      instructions.textPositions,
      const <TextPosition>[
        TextPosition(reset: true),
        TextPosition(x: 28.727, y: 12.0),
        TextPosition(x: 52.727, y: 12.0),
        TextPosition(x: 4.728, y: 12.0),
      ],
    );

    expect(instructions.text, const <TextConfig>[
      TextConfig(
        '2',
        0.0,
        'AvenirNext-Medium, Avenir Next',
        FontWeight.w400,
        11.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
      TextConfig(
        '3',
        0.0,
        'AvenirNext-Medium, Avenir Next',
        FontWeight.w400,
        11.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
      TextConfig(
        '1',
        0.0,
        'AvenirNext-Medium, Avenir Next',
        FontWeight.w400,
        11.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
    ]);
  });

  test('None on fill', () {
    const String svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="384" height="384" fill="none"
  style="-webkit-print-color-adjust:exact">
  <defs>
    <clipPath id="a" class="frame-clip">
      <rect width="384" height="384" rx="40" ry="40" style="opacity:1" />
    </clipPath>
  </defs>
  <g clip-path="url(#a)">
    <rect width="384" height="384" class="frame-background" rx="40" ry="40" style="opacity:1" />
    <g class="frame-children">
      <rect width="290" height="70" x="31" y="32" rx="30" ry="30"
        style="fill:#22c55e;fill-opacity:1" />
      <rect width="290" height="70" x="31" y="282" rx="30" ry="30"
        style="fill:#22c55e;fill-opacity:1" />
      <rect width="290" height="70" x="95" y="157" rx="30" ry="30"
        style="fill:#f59e0b;fill-opacity:1" />
    </g>
  </g>
</svg>
''';

    final VectorInstructions instructions = parseWithoutOptimizers(svg);
    // Should _not_ contain a paint with an opaque black fill for the rect with class "frame-background".
    expect(instructions.paints, const <Paint>[
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xff22c55e))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xfff59e0b))),
    ]);
  });

  test('text spacing', () {
    const String svg = '''
<svg width="185" height="43" viewBox="0 0 185 43" xmlns="http://www.w3.org/2000/svg">
    <g fill="none" fill-rule="evenodd">
        <text x="35.081" y="15" font-family="OpenSans-Italic, Open Sans" font-size="14" font-style="italic" fill="#333">
            π( D² - d² )( N - N
            <tspan y="15" font-size="10">u</tspan>
            )
        </text>
    </g>
</svg>
''';

    final VectorInstructions instructions = parseWithoutOptimizers(svg);

    expect(instructions.textPositions, const <TextPosition>[
      TextPosition(reset: true, x: 35.081, y: 15.0),
      TextPosition(y: 15.0),
    ]);

    expect(instructions.text, const <TextConfig>[
      TextConfig(
        'π( D² - d² )( N - N',
        0.0,
        'OpenSans-Italic, Open Sans',
        FontWeight.w400,
        14.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
      TextConfig(
        ' u',
        0.0,
        'OpenSans-Italic, Open Sans',
        FontWeight.w400,
        10.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
      TextConfig(
        ' )',
        0.0,
        'OpenSans-Italic, Open Sans',
        FontWeight.w400,
        14.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
    ]);
  });

  test('stroke-opacity', () {
    const String strokeOpacitySvg = '''
<svg viewBox="0 0 10 10" fill="none">
  <rect x="0" y="0" width="5" height="5" stroke="red" stroke-opacity=".5" />
</svg>
''';

    final VectorInstructions instructions =
        parseWithoutOptimizers(strokeOpacitySvg);

    expect(
      instructions.paints.single,
      const Paint(stroke: Stroke(color: Color(0x7fff0000))),
    );
  });

  test('preserve opacity from color mapper for strokes', () {
    const String strokeOpacitySvg = '''
<svg viewBox="0 0 10 10" fill="none">
  <rect x="0" y="0" width="5" height="5" stroke="#000000" />
</svg>
''';

    final VectorInstructions instructions = parseWithoutOptimizers(
      strokeOpacitySvg,
      colorMapper: const _TestOpacityColorMapper(),
    );

    expect(
      instructions.paints.single,
      const Paint(stroke: Stroke(color: Color(0x7fff0000))),
    );
  });

  test('text attributes are preserved', () {
    final VectorInstructions instructions = parseWithoutOptimizers(textTspan);
    expect(
      instructions.text,
      const <TextConfig>[
        TextConfig(
          'Some text',
          0.0,
          'Roboto-Regular, Roboto',
          FontWeight.w400,
          16.0,
          TextDecoration.none,
          TextDecorationStyle.solid,
          Color.opaqueBlack,
        ),
        TextConfig(
          'more text.',
          0.0,
          'Roboto-Regular, Roboto',
          FontWeight.w400,
          16.0,
          TextDecoration.none,
          TextDecorationStyle.solid,
          Color.opaqueBlack,
        ),
        TextConfig(
          'Even more text',
          0.0,
          'Roboto-Regular, Roboto',
          FontWeight.w400,
          16.0,
          TextDecoration.none,
          TextDecorationStyle.solid,
          Color.opaqueBlack,
        ),
        TextConfig(
          'text everywhere',
          0.0,
          'Roboto-Regular, Roboto',
          FontWeight.w400,
          16.0,
          TextDecoration.none,
          TextDecorationStyle.solid,
          Color.opaqueBlack,
        ),
        TextConfig(
          'so many lines',
          0.0,
          'Roboto-Regular, Roboto',
          FontWeight.w400,
          16.0,
          TextDecoration.none,
          TextDecorationStyle.solid,
          Color.opaqueBlack,
        ),
      ],
    );
  });

  test('currentColor', () {
    const String currentColorSvg = '''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="5" height="5" fill="currentColor" />
</svg>
''';

    final VectorInstructions blueInstructions = parseWithoutOptimizers(
      currentColorSvg,
      theme: const SvgTheme(currentColor: Color(0xFF0000FF)),
    );
    final VectorInstructions redInstructions = parseWithoutOptimizers(
      currentColorSvg,
      theme: const SvgTheme(currentColor: Color(0xFFFF0000)),
    );

    expect(
      blueInstructions.paints.single,
      const Paint(fill: Fill(color: Color(0xFF0000FF))),
    );

    expect(
      redInstructions.paints.single,
      const Paint(fill: Fill(color: Color(0xFFFF0000))),
    );
  });

  test('currentColor stoke opacity', () {
    const String currentColorSvg = '''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="5" height="5" fill="currentColor" stroke="currentColor" />
</svg>
''';

    final VectorInstructions blueInstructions = parseWithoutOptimizers(
      currentColorSvg,
      theme: const SvgTheme(currentColor: Color(0x7F0000FF)),
    );
    final VectorInstructions redInstructions = parseWithoutOptimizers(
      currentColorSvg,
      theme: const SvgTheme(currentColor: Color(0x7FFF0000)),
    );

    expect(
      blueInstructions.paints.single,
      const Paint(
        fill: Fill(color: Color(0x7F0000FF)),
        stroke: Stroke(color: Color(0x7F0000FF)),
      ),
    );

    expect(
      redInstructions.paints.single,
      const Paint(
        fill: Fill(color: Color(0x7FFF0000)),
        stroke: Stroke(color: Color(0x7FFF0000)),
      ),
    );
  });

  test('Opacity with a save layer does not continue to inherit', () {
    final VectorInstructions instructions = parseWithoutOptimizers('''
<svg width="283" height="180" viewBox="0 0 283 180" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path opacity=".3" d="M61.72 181.636L187.521 0H0v181.636h61.72z" fill="#202124" fill-opacity=".08"/>
  <g opacity=".04">
    <path d="M0 0l283.728 90.818V0H0z" fill="black"/>
  </g>
</svg>
''');

    expect(instructions.paints, const <Paint>[
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x06202124))),
      // The paint for the saveLayer.
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x0a000000))),
      // The paint for the path drawn in the saveLayer - must not be the same as
      // the saveLayer otherwise the path will be drawn almost completely transparent.
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color.opaqueBlack)),
    ]);
    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.saveLayer, paintId: 1),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 2),
      DrawCommand(DrawCommandType.restore),
    ]);
  });

  test('Opacity on a default fill', () {
    final VectorInstructions instructions = parseWithoutOptimizers('''
<svg viewBox="0 0 10 10">
  <path d="M10 10 L20 20" opacity=".4" />
</svg>
''');

    expect(instructions.paints.single.fill!.color, const Color(0x66000000));
  });

  test('Stroke width with scaling', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      signWithScaledStroke,
    );

    expect(instructions.paints, const <Paint>[
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(
              color: Color(0xffffee44), join: StrokeJoin.round, width: 3.0)),
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(
              color: Color(0xff333333), join: StrokeJoin.round, width: 3.0),
          fill: Fill(color: Color(0xffffee44))),
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(color: Color(0xffccaa00), join: StrokeJoin.round),
          fill: Fill(color: Color(0xffccaa00))),
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(color: Color(0xff333333), join: StrokeJoin.round),
          fill: Fill(color: Color(0xff555555))),
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(
              color: Color(0xff446699), join: StrokeJoin.round, width: 0.5)),
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(
              color: Color(0xffbbaa55),
              join: StrokeJoin.round,
              width: 0.49999999999999994)),
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(
              color: Color(0xff6688cc),
              join: StrokeJoin.round,
              width: 0.49999999999999994)),
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(
              color: Color(0xff333311), join: StrokeJoin.round, width: 0.5)),
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(
              color: Color(0xffffee44), join: StrokeJoin.round, width: 0.5),
          fill: Fill(color: Color(0xff80a3cf))),
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(
              color: Color(0xffffee44), join: StrokeJoin.round, width: 0.5),
          fill: Fill(color: Color(0xff668899)))
    ]);
  });

  test('Use handles stroke and fill correctly', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      useStar,
    );

    // These kinds of paths are verified elsewhere, and the FP math can vary
    // by platform.
    expect(instructions.paths.length, 4);

    expect(
      instructions.paints,
      const <Paint>[
        Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(color: Color.opaqueBlack, width: 12.0),
        ),
        Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(color: Color(0xff008000)),
          fill: Fill(color: Color(0xffffbb44)),
        ),
      ],
    );

    expect(
      instructions.commands,
      const <DrawCommand>[
        DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
        DrawCommand(DrawCommandType.path, objectId: 1, paintId: 0),
        DrawCommand(DrawCommandType.path, objectId: 2, paintId: 0),
        DrawCommand(DrawCommandType.path, objectId: 3, paintId: 0),
        DrawCommand(DrawCommandType.path, objectId: 0, paintId: 1),
        DrawCommand(DrawCommandType.path, objectId: 1, paintId: 1),
        DrawCommand(DrawCommandType.path, objectId: 2, paintId: 1),
        DrawCommand(DrawCommandType.path, objectId: 3, paintId: 1),
      ],
    );
  });

  test('Use preserves fill from shape', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      useColor,
    );

    expect(
      instructions.paths,
      <Path>[
        Path(
          commands: const <PathCommand>[
            MoveToCommand(60.0, 10.0),
            LineToCommand(72.5, 27.5),
            LineToCommand(47.5, 27.5),
            CloseCommand()
          ],
        ),
        Path(
          commands: const <PathCommand>[
            MoveToCommand(120.0, 10.0),
            LineToCommand(132.5, 27.5),
            LineToCommand(107.5, 27.5),
            CloseCommand()
          ],
        )
      ],
    );
    expect(
      instructions.paints.single,
      const Paint(
        blendMode: BlendMode.srcOver,
        fill: Fill(color: Color(0xffff0000)),
      ),
    );
  });

  test('Image in defs', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      imageInDefs,
    );
    expect(instructions.images.single.format, 0);
    expect(instructions.images.single.data.length, 331);
    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.clip, objectId: 0),
      DrawCommand(DrawCommandType.image, objectId: 0),
      DrawCommand(DrawCommandType.restore)
    ]);
  });

  test('Transformed clip', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      transformedClip,
    );

    expect(instructions.paths, <Path>[
      Path(
        commands: const <PathCommand>[
          MoveToCommand(0.0, 0.0),
          LineToCommand(375.0, 0.0),
          LineToCommand(375.0, 407.0),
          LineToCommand(0.0, 407.0),
          CloseCommand()
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(360.0, 395.5),
          LineToCommand(16.0, 395.5),
          LineToCommand(188.0, 1.0),
          LineToCommand(360.0, 395.5),
          CloseCommand()
        ],
      )
    ]);
  });

  test('Zero width stroke', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="main-svg" width="100" height="100" viewBox="0 0 100 100">
    <rect style="stroke: rgb(68, 68, 68); stroke-opacity: 1; fill: rgb(255, 255, 255); fill-opacity: 1; stroke-width: 0;" width="90" height="90" x="5" y="5" />
</svg>''',
    );

    expect(instructions.paints.single.stroke, null);
    expect(
        instructions.paints.single.fill, const Fill(color: Color(0xFFFFFFFF)));
  });

  test('text anchor', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      textAnchors,
    );

    expect(instructions.text, const <TextConfig>[
      TextConfig(
        'Text anchor start',
        0.0,
        'Roboto',
        FontWeight.w400,
        10.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
      TextConfig(
        'Text anchor middle',
        0.5,
        'Roboto',
        FontWeight.w400,
        10.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
      TextConfig(
        'Text anchor end',
        1.0,
        'Roboto',
        FontWeight.w400,
        10.0,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      )
    ]);
  });

  test('text decorations', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      textDecorations,
    );

    expect(instructions.text, const <TextConfig>[
      TextConfig(
        'Overline text',
        0,
        'Roboto',
        FontWeight.w400,
        55.0,
        TextDecoration.overline,
        TextDecorationStyle.solid,
        Color(0xffff0000),
      ),
      TextConfig(
        'Strike text',
        0,
        'Roboto',
        FontWeight.w400,
        55.0,
        TextDecoration.lineThrough,
        TextDecorationStyle.solid,
        Color(0xff008000),
      ),
      TextConfig(
        'Underline text',
        0,
        'Roboto',
        FontWeight.w400,
        55.0,
        TextDecoration.underline,
        TextDecorationStyle.double,
        Color(0xff008000),
      )
    ]);
  });

  test('Stroke property set but does not draw stroke', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      strokePropertyButNoStroke,
    );
    expect(instructions.paths.single.commands, const <PathCommand>[
      MoveToCommand(10.0, 20.0),
      LineToCommand(110.0, 20.0),
      LineToCommand(110.0, 120.0),
      LineToCommand(10.0, 120.0),
      CloseCommand(),
    ]);
    expect(
      instructions.paints.single,
      const Paint(fill: Fill(color: Color(0xFFFF0000))),
    );
  });

  test('Clip with use', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      basicClip,
    );
    final VectorInstructions instructions2 = parseWithoutOptimizers(
      useClip,
    );
    expect(instructions, instructions2);
  });

  test('stroke-dasharray="none"', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M1 20L20 20L20 39L30 30L1 26z" stroke="black" fill="red" stroke-width="2" stroke-dasharray="none"/>
</svg>
''',
    );

    expect(instructions.paints, const <Paint>[
      Paint(fill: Fill(color: Color(0xffff0000))),
      Paint(stroke: Stroke(color: Color.opaqueBlack, width: 2.0)),
    ]);

    expect(instructions.paths, <Path>[
      Path(
        commands: const <PathCommand>[
          MoveToCommand(1.0, 20.0),
          LineToCommand(20.0, 20.0),
          LineToCommand(20.0, 39.0),
          LineToCommand(30.0, 30.0),
          LineToCommand(1.0, 26.0),
          CloseCommand(),
        ],
      ),
    ]);
  });

  test('stroke-width with invalid value', () {
    const String svg =
        '<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path d="M100 10 H180 V90 H100 Z" fill="#ff0000" stroke="#0000ff" stroke-width="invalid"/></svg>';

    final VectorInstructions instructions = parseWithoutOptimizers(svg);

    expect(instructions.paints, const <Paint>[
      Paint(
          stroke: Stroke(color: Color(0xff0000ff)),
          fill: Fill(color: Color(0xffff0000))),
    ]);

    expect(instructions.paths, <Path>[
      Path(
        commands: const <PathCommand>[
          MoveToCommand(100.0, 10.0),
          LineToCommand(180.0, 10.0),
          LineToCommand(180.0, 90.0),
          LineToCommand(100.0, 90.0),
          CloseCommand(),
        ],
      ),
    ]);
  });

  test('stroke-width with unit value', () {
    const SvgTheme theme = SvgTheme();
    const double ptConversionFactor = 96 / 72;

    const String svg_px =
        '<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path d="M100 10 H180 V90 H100 Z" fill="#ff0000" stroke="#0000ff" stroke-width="1px"/></svg>';
    const String svg_pt =
        '<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path d="M100 10 H180 V90 H100 Z" fill="#ff0000" stroke="#0000ff" stroke-width="1pt"/></svg>';
    const String svg_ex =
        '<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path d="M100 10 H180 V90 H100 Z" fill="#ff0000" stroke="#0000ff" stroke-width="1ex"/></svg>';
    const String svg_em =
        '<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path d="M100 10 H180 V90 H100 Z" fill="#ff0000" stroke="#0000ff" stroke-width="1em"/></svg>';
    const String svg_rem =
        '<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><path d="M100 10 H180 V90 H100 Z" fill="#ff0000" stroke="#0000ff" stroke-width="1rem"/></svg>';

    final VectorInstructions instructionsPx = parseWithoutOptimizers(svg_px);
    final VectorInstructions instructionsPt = parseWithoutOptimizers(svg_pt);
    final VectorInstructions instructionsEx = parseWithoutOptimizers(svg_ex);
    final VectorInstructions instructionsEm = parseWithoutOptimizers(svg_em);
    final VectorInstructions instructionsRem = parseWithoutOptimizers(svg_rem);

    expect(instructionsPx.paints, <Paint>[
      const Paint(
          stroke: Stroke(color: Color(0xff0000ff), width: 1.0),
          fill: Fill(color: Color(0xffff0000))),
    ]);

    expect(instructionsPt.paints, <Paint>[
      const Paint(
          stroke:
              Stroke(color: Color(0xff0000ff), width: 1 * ptConversionFactor),
          fill: Fill(color: Color(0xffff0000))),
    ]);

    expect(instructionsEx.paints, <Paint>[
      Paint(
          stroke: Stroke(
              color: const Color(0xff0000ff), width: 1.0 * theme.xHeight),
          fill: const Fill(color: Color(0xffff0000))),
    ]);

    expect(instructionsEm.paints, <Paint>[
      Paint(
          stroke: Stroke(
              color: const Color(0xff0000ff), width: 1.0 * theme.fontSize),
          fill: const Fill(color: Color(0xffff0000))),
    ]);

    expect(instructionsRem.paints, <Paint>[
      Paint(
          stroke: Stroke(
              color: const Color(0xff0000ff), width: 1.0 * theme.fontSize),
          fill: const Fill(color: Color(0xffff0000))),
    ]);
  });

  test('Dashed path', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M1 20L20 20L20 39L30 30L1 26z" stroke="black" fill="red" stroke-width="2" stroke-dasharray="5 3 5 5"/>
</svg>''',
    );

    expect(instructions.paints, const <Paint>[
      Paint(fill: Fill(color: Color(0xffff0000))),
      Paint(stroke: Stroke(color: Color.opaqueBlack, width: 2.0)),
    ]);

    expect(instructions.paths, <Path>[
      Path(
        commands: const <PathCommand>[
          MoveToCommand(1.0, 20.0),
          LineToCommand(20.0, 20.0),
          LineToCommand(20.0, 39.0),
          LineToCommand(30.0, 30.0),
          LineToCommand(1.0, 26.0),
          CloseCommand()
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(1.0, 20.0),
          LineToCommand(6.0, 20.0),
          MoveToCommand(9.0, 20.0),
          LineToCommand(13.999999999999998, 20.0),
          MoveToCommand(18.999999999999996, 20.0),
          LineToCommand(20.0, 20.0),
          LineToCommand(20.0, 24.0),
          MoveToCommand(20.0, 27.000000000000004),
          LineToCommand(20.0, 32.0),
          MoveToCommand(20.0, 37.0),
          LineToCommand(20.0, 39.0),
          LineToCommand(22.229882438741498, 36.99310580513265),
          MoveToCommand(24.459764877482996, 34.9862116102653),
          LineToCommand(28.17623560871883, 31.641387952153053),
          MoveToCommand(27.47750617803373, 29.65206981765983),
          LineToCommand(22.524400531816358, 28.96888283197467),
          MoveToCommand(19.55253714408593, 28.55897064056358),
          LineToCommand(14.599431497868558, 27.875783654878425),
          MoveToCommand(9.646325851651186, 27.19259666919327),
          LineToCommand(4.693220205433812, 26.509409683508114),
          MoveToCommand(1.7213568177033882, 26.09949749209702),
          LineToCommand(1.0, 26.0),
          LineToCommand(1.0, 21.72818638368261)
        ],
      ),
    ]);

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 1),
    ]);
  });

  test('text with transform', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 160"><text transform="rotate(10 -100 50)">a</text></svg>',
    );
    expect(instructions.paints.single, const Paint(fill: Fill()));
    expect(
      instructions.textPositions.single,
      TextPosition(
        reset: true,
        transform: AffineMatrix.identity
            .translated(-100, 50)
            .rotated(radians(10))
            .translated(100, -50),
      ),
    );
    expect(
      instructions.text.single,
      const TextConfig(
        'a',
        0,
        null,
        normalFontWeight,
        16,
        TextDecoration.none,
        TextDecorationStyle.solid,
        Color.opaqueBlack,
      ),
    );
  });

  test('Missing references', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      missingRefs,
    );
    expect(
      instructions.paints.single,
      const Paint(fill: Fill(color: Color(0xFFFF0000))),
    );
    expect(
      instructions.paths.single,
      PathBuilder().addRect(const Rect.fromLTWH(5, 5, 100, 100)).toPath(),
    );
    expect(
      instructions.commands.single,
      const DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
    );
  });

  test('focal radial', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      focalRadial,
    );

    expect(
      instructions.paints.single,
      const Paint(
        stroke: Stroke(color: Color.opaqueBlack),
        fill: Fill(
          color: Color(0xffffffff),
          shader: RadialGradient(
            id: 'url(#radial)',
            center: Point(0.5, 0.5),
            radius: 0.5,
            colors: <Color>[
              Color(0xffff0000),
              Color(0xff008000),
              Color(0xff0000ff)
            ],
            offsets: <double>[0.0, 0.5, 1.0],
            tileMode: TileMode.clamp,
            transform: AffineMatrix(
              120.0,
              0.0,
              0.0,
              120.0,
              10.0,
              10.0,
              120.0,
            ),
            focalPoint: Point(0.5, 0.15),
            unitMode: GradientUnitMode.transformed,
          ),
        ),
      ),
    );
    expect(
      instructions.paths.single,
      PathBuilder().addRect(const Rect.fromLTWH(10, 10, 120, 120)).toPath(),
    );
  });

  test('Transformed userSpaceOnUse radial', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      xformUsosRadial,
    );
    expect(
      instructions.paints.single,
      const Paint(
        fill: Fill(
          color: Color(0xffffffff),
          shader: RadialGradient(
            id: 'url(#paint0_radial)',
            center: Point.zero,
            radius: 1.0,
            colors: <Color>[Color(0xcc47e9ff), Color(0x00414cbe)],
            offsets: <double>[0.0, 1.0],
            tileMode: TileMode.clamp,
            transform: AffineMatrix(
              -433.0004488023628,
              -350.99987486173313,
              350.99987486173313,
              -433.0004488023628,
              432.9999999999999,
              547.0000000000001,
              557.396,
            ),
            unitMode: GradientUnitMode.transformed,
          ),
        ),
      ),
    );
    expect(
      instructions.paths.single,
      PathBuilder()
          .addRect(const Rect.fromLTWH(667, 667, 667, 667))
          .toPath()
          .transformed(
            AffineMatrix.identity
                .translated(667, 667)
                .rotated(radians(180))
                .translated(-667, -667),
          ),
    );
  });

  test('Transformed objectBoundingBox gradient onto transformed path', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      xformObbGradient,
    );
    expect(
      instructions.paints.single,
      const Paint(
        fill: Fill(
          color: Color(0xffffffff),
          shader: LinearGradient(
            id: 'url(#paint1_linear)',
            from: Point(405.5634918610405, 547.9898987322333),
            to: Point(440.9188309203679, 866.1879502661797),
            colors: <Color>[Color(0x7f0000ff), Color(0x19ff0000)],
            offsets: <double>[0.0, 1.0],
            tileMode: TileMode.clamp,
            unitMode: GradientUnitMode.transformed,
          ),
        ),
      ),
    );
    expect(
      instructions.paths.single,
      PathBuilder()
          .addRect(const Rect.fromLTWH(300, 0, 500, 400))
          .toPath()
          .transformed(
            AffineMatrix.identity
                .translated(0, 100)
                .translated(250, 250)
                .rotated(radians(45))
                .translated(-250, -250),
          ),
    );
  },
      // Currently skipped because the double values in Point are tested for
      // exact equality, which makes this test fragile to host platform.
      skip: Platform.isWindows);

  test('Opaque blend mode gets a save layer', () {
    const String svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect x="0" y="0" width="100" height="100" fill="red" />
  <g style="mix-blend-mode:screen">
    <rect x="20" y="20" width="20" height="20" fill="green" />
  </g>
</svg>
''';
    final VectorInstructions instructions = parseWithoutOptimizers(
      svg,
    );
    expect(instructions.paints, const <Paint>[
      Paint(fill: Fill(color: Color(0xffff0000))),
      Paint(blendMode: BlendMode.screen, fill: Fill(color: Color.opaqueBlack)),
      Paint(blendMode: BlendMode.screen, fill: Fill(color: Color(0xff008000))),
    ]);
    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.saveLayer, paintId: 1),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 2),
      DrawCommand(DrawCommandType.restore),
    ]);
  });

  test('Stroke properties respected in toStroke', () {
    const String svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 112 102">
  <path fill="none" stroke="red" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.7" d="M70.822 65.557l5.376 5.296 8.389-8.676" />
</svg>
''';
    final VectorInstructions instructions = parseWithoutOptimizers(
      svg,
    );
    expect(
      instructions.paints.single,
      const Paint(
        stroke: Stroke(
          color: Color(0xffff0000),
          cap: StrokeCap.round,
          join: StrokeJoin.round,
          width: 2.7,
        ),
      ),
    );
  });

  test('gradients can handle inheriting unit mode', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      linearGradientThatInheritsUnitMode,
    );
    expect(instructions.paints, const <Paint>[
      Paint(
        fill: Fill(
          color: Color(0xffffffff),
          shader: LinearGradient(
            id: 'url(#a)',
            from: Point(236.702, 9.99),
            to: Point(337.966, 241.771),
            colors: <Color>[
              Color(0xffffffff),
              Color(0xb9c2c3c3),
              Color(0x6a7d7e80),
              Color(0x314b4c4e),
              Color(0x0d2c2d30),
              Color(0x00202124)
            ],
            offsets: <double>[0.0, 0.229, 0.508, 0.739, 0.909, 1.0],
            tileMode: TileMode.clamp,
            unitMode: GradientUnitMode.transformed,
          ),
        ),
      ),
      Paint(
        fill: Fill(
          color: Color(0xffffffff),
          shader: LinearGradient(
            id: 'url(#d)',
            from: Point(0.0, 50.243),
            to: Point(0.0, 330.779),
            colors: <Color>[
              Color(0xffffffff),
              Color(0xb9c2c3c3),
              Color(0x6a7d7e80),
              Color(0x314b4c4e),
              Color(0x0d2c2d30),
              Color(0x00202124)
            ],
            offsets: <double>[0.0, 0.229, 0.508, 0.739, 0.909, 1.0],
            tileMode: TileMode.clamp,
            unitMode: GradientUnitMode.transformed,
          ),
        ),
      )
    ]);
  });

  test('group opacity results in save layer', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      groupOpacity,
    );
    expect(instructions.paths, <Path>[
      PathBuilder().addOval(const Rect.fromCircle(80, 100, 50)).toPath(),
      PathBuilder().addOval(const Rect.fromCircle(120, 100, 50)).toPath(),
    ]);
    expect(instructions.paints, const <Paint>[
      Paint(fill: Fill(color: Color(0x7f000000))),
      Paint(fill: Fill(color: Color(0x7fff0000))),
      Paint(fill: Fill(color: Color(0x7f008000))),
    ]);
    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.saveLayer, paintId: 0),
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 1),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 2),
      DrawCommand(DrawCommandType.restore),
    ]);
  });

  test('xlink gradient Out of order', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      xlinkGradient,
    );
    final VectorInstructions instructions2 = parseWithoutOptimizers(
      xlinkGradientOoO,
    );

    expect(instructions.paints, instructions2.paints);
    expect(instructions.paths, instructions2.paths);
    expect(instructions.commands, instructions2.commands);
  });

  test('xlink use Out of order', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      simpleUseCircles,
    );
    final VectorInstructions instructions2 = parseWithoutOptimizers(
      simpleUseCirclesOoO,
    );

    // Use toSet to ignore ordering differences.
    expect(instructions.paints.toSet(), instructions2.paints.toSet());
    expect(instructions.paths.toSet(), instructions2.paths.toSet());
    expect(instructions.commands.toSet(), instructions2.commands.toSet());
  });

  test('xlink gradient with transform', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      xlinkGradient,
    );
    expect(instructions.paths, <Path>[
      PathBuilder()
          .addOval(const Rect.fromCircle(-83.533, 122.753, 74.461))
          .toPath()
          .transformed(
              const AffineMatrix(.63388, 0, 0, .63388, 100.15, -30.611)),
    ]);

    expect(instructions.paints, const <Paint>[
      Paint(
        fill: Fill(
          color: Color(0xffffffff),
          shader: LinearGradient(
            id: 'url(#b)',
            from: Point(0.000763280000001032, 47.19967163999999),
            to: Point(94.40007452, 47.19967163999999),
            colors: <Color>[Color(0xff0f12cb), Color(0xfffded3a)],
            offsets: <double>[0.0, 1.0],
            tileMode: TileMode.clamp,
            unitMode: GradientUnitMode.transformed,
          ),
        ),
      )
    ]);

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
    ]);
  });

  test('Out of order def', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      outOfOrderGradientDef,
    );
    expect(instructions.paths, <Path>[
      parseSvgPathData(
          'M10 20c5.523 0 10-4.477 10-10S15.523 0 10 0 0 4.477 0 10s4.477 10 10 10z'),
    ]);
    expect(instructions.paints, const <Paint>[
      Paint(
        fill: Fill(
          color: Color(0xffffffff),
          shader: LinearGradient(
            id: 'url(#paint0_linear)',
            from: Point(10.0, 0.0),
            to: Point(10.0, 19.852),
            colors: <Color>[Color(0xff0000ff), Color(0xffffff00)],
            offsets: <double>[0.0, 1.0],
            tileMode: TileMode.clamp,
            unitMode: GradientUnitMode.transformed,
          ),
        ),
      )
    ]);

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
    ]);
  });

  test('Handles masks correctly', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      basicMask,
    );
    expect(
      instructions.paths,
      <Path>[
        parseSvgPathData('M-10,110 110,110 110,-10z'),
        PathBuilder().addOval(const Rect.fromCircle(50, 50, 50)).toPath(),
        PathBuilder().addRect(const Rect.fromLTWH(0, 0, 100, 100)).toPath(),
        parseSvgPathData(
            'M10,35 A20,20,0,0,1,50,35 A20,20,0,0,1,90,35 Q90,65,50,95 Q10,65,10,35 Z'),
      ].map((Path path) =>
          path.transformed(AffineMatrix.identity.translated(10, 10))),
    );

    expect(instructions.paints, const <Paint>[
      Paint(fill: Fill(color: Color(0xffffa500))),
      Paint(fill: Fill()),
      Paint(fill: Fill(color: Color(0xffffffff))),
    ]);

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.saveLayer, paintId: 1),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 1),
      DrawCommand(DrawCommandType.mask),
      DrawCommand(DrawCommandType.path, objectId: 2, paintId: 2),
      DrawCommand(DrawCommandType.path, objectId: 3, paintId: 1),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.restore),
    ]);
  });

  test('Handles viewBox transformations correctly', () {
    const String svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="-10 -12 120 120">
  <rect x="11" y="36" width="31" height="20" fill="red" />
</svg>
''';
    final VectorInstructions instructions = parseWithoutOptimizers(
      svg,
    );
    expect(instructions.paths, <Path>[
      PathBuilder()
          .addRect(const Rect.fromLTWH(11, 36, 31, 20))
          .toPath()
          .transformed(AffineMatrix.identity.translated(10, 12)),
    ]);
  });

  test('Parses rrects correctly', () {
    const String svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120">
  <rect x="11" y="36" width="31" height="20" rx="2.5" fill="red" />
</svg>
''';
    final VectorInstructions instructions = parseWithoutOptimizers(
      svg,
    );
    expect(instructions.paths, <Path>[
      PathBuilder()
          .addRRect(const Rect.fromLTWH(11, 36, 31, 20), 2.5, 2.5)
          .toPath()
    ]);
  });

  test('Path with empty paint does not draw anything', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      '''
<svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 192 192" width="24">
  <path fill="none" d="M0 0h192v192H0z" />
</svg>''',
      key: 'emptyPath',
      warningsAsErrors: true,
    );
    expect(instructions.commands.isEmpty, true);
  });

  test('Use circles test', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      simpleUseCircles,
      key: 'useCircles',
      warningsAsErrors: true,
    );

    expect(
      instructions.paints,
      const <Paint>[
        Paint(fill: Fill()),
        Paint(fill: Fill(color: Color(0xff0000ff))),
        Paint(
          stroke: Stroke(color: Color(0xff0000ff)),
          fill: Fill(color: Color(0xffffffff)),
        ),
      ],
    );

    expect(instructions.paths, <Path>[
      Path(
        commands: const <PathCommand>[
          MoveToCommand(5.0, 1.0),
          CubicToCommand(
              7.2076600979759995, 1.0, 9.0, 2.792339902024, 9.0, 5.0),
          CubicToCommand(
              9.0, 7.2076600979759995, 7.2076600979759995, 9.0, 5.0, 9.0),
          CubicToCommand(
              2.792339902024, 9.0, 1.0, 7.2076600979759995, 1.0, 5.0),
          CubicToCommand(1.0, 2.792339902024, 2.792339902024, 1.0, 5.0, 1.0),
          CloseCommand()
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(15.0, 1.0),
          CubicToCommand(17.207660097976, 1.0, 19.0, 2.792339902024, 19.0, 5.0),
          CubicToCommand(
              19.0, 7.2076600979759995, 17.207660097976, 9.0, 15.0, 9.0),
          CubicToCommand(
              12.792339902024, 9.0, 11.0, 7.2076600979759995, 11.0, 5.0),
          CubicToCommand(11.0, 2.792339902024, 12.792339902024, 1.0, 15.0, 1.0),
          CloseCommand()
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(25.0, 1.0),
          CubicToCommand(27.207660097976, 1.0, 29.0, 2.792339902024, 29.0, 5.0),
          CubicToCommand(
              29.0, 7.2076600979759995, 27.207660097976, 9.0, 25.0, 9.0),
          CubicToCommand(
              22.792339902024, 9.0, 21.0, 7.2076600979759995, 21.0, 5.0),
          CubicToCommand(21.0, 2.792339902024, 22.792339902024, 1.0, 25.0, 1.0),
          CloseCommand()
        ],
      ),
    ]);

    expect(
      instructions.commands,
      const <DrawCommand>[
        DrawCommand(DrawCommandType.path,
            objectId: 0, paintId: 0, debugString: 'myCircle'),
        DrawCommand(DrawCommandType.path,
            objectId: 1, paintId: 1, debugString: 'myCircle'),
        DrawCommand(DrawCommandType.path,
            objectId: 2, paintId: 2, debugString: 'myCircle')
      ],
    );
  });

  test('Use circles test without href', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      simpleUseCirclesWithoutHref,
      key: 'useCirclesWithoutHref',
      warningsAsErrors: true,
    );

    expect(instructions.paints, const <Paint>[
      Paint(
        fill: Fill(color: Color.opaqueBlack),
      ),
    ]);

    expect(instructions.paths, <Path>[
      Path(
        commands: const <PathCommand>[
          MoveToCommand(5.0, 1.0),
          CubicToCommand(
              7.2076600979759995, 1.0, 9.0, 2.792339902024, 9.0, 5.0),
          CubicToCommand(
              9.0, 7.2076600979759995, 7.2076600979759995, 9.0, 5.0, 9.0),
          CubicToCommand(
              2.792339902024, 9.0, 1.0, 7.2076600979759995, 1.0, 5.0),
          CubicToCommand(1.0, 2.792339902024, 2.792339902024, 1.0, 5.0, 1.0),
          CloseCommand()
        ],
      ),
    ]);

    expect(
      instructions.commands,
      const <DrawCommand>[
        DrawCommand(DrawCommandType.path,
            objectId: 0, paintId: 0, debugString: 'myCircle'),
      ],
    );
  });

  test('Parses pattern used as fill and stroke', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      starPatternCircles,
      warningsAsErrors: true,
    );

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.pattern, objectId: 0, patternDataId: 0),
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 1, patternId: 0),
      DrawCommand(DrawCommandType.pattern, objectId: 0, patternDataId: 0),
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.path, objectId: 2, paintId: 2, patternId: 0)
    ]);
  });

  test('Alternating pattern usage', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      alternatingPattern,
      warningsAsErrors: true,
    );

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.pattern, objectId: 0, patternDataId: 0),
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 1, patternId: 0),
      DrawCommand(DrawCommandType.pattern, objectId: 1, patternDataId: 0),
      DrawCommand(DrawCommandType.path, objectId: 2, paintId: 2),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.path, objectId: 3, paintId: 1, patternId: 1),
      DrawCommand(DrawCommandType.pattern, objectId: 0, patternDataId: 0),
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.path, objectId: 4, paintId: 1, patternId: 0),
      DrawCommand(DrawCommandType.pattern, objectId: 1, patternDataId: 0),
      DrawCommand(DrawCommandType.path, objectId: 2, paintId: 2),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.path, objectId: 5, paintId: 1, patternId: 1)
    ]);
  });

  test('Parses text with pattern as fill', () {
    const String textWithPattern = '''
<svg width="600" height="400">
    <defs>
          <pattern id="textPattern" x="7" y="7" width="10" height="10" patternUnits="userSpaceOnUse">
                  <rect x="5" y="5" width="5" height="5" fill= "#876fc1" />
          </pattern>
    </defs>
    <text x="0" y="50%" font-size="200" fill="url(#textPattern)">Text</text>
</svg>''';

    final VectorInstructions instructions = parseWithoutOptimizers(
      textWithPattern,
      warningsAsErrors: true,
    );

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.pattern, objectId: 0),
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.textPosition, objectId: 0),
      DrawCommand(DrawCommandType.text, objectId: 0, paintId: 1, patternId: 0)
    ]);

    expect(
      instructions.text,
      const <TextConfig>[
        TextConfig(
          'Text',
          0.0,
          null,
          FontWeight.w400,
          200.0,
          TextDecoration.none,
          TextDecorationStyle.solid,
          Color.opaqueBlack,
        )
      ],
    );
  });

  test('Defaults image height/width when not specified', () {
    // 1x1 PNG image from png-pixel.com.
    const String svgStr = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
    <image href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==" />
</svg>''';

    final VectorInstructions instructions = parseWithoutOptimizers(
      svgStr,
      key: 'image',
      warningsAsErrors: true,
    );

    expect(instructions.drawImages.first.rect, const Rect.fromLTWH(0, 0, 1, 1));
  });

  test('Other image formats', () {
    // 1x1 PNG image from png-pixel.com. Claiming that it's JPEG and using "img"
    // instead of "image" to make sure parser doesn't barf. Chrome is ok with
    // this kind of nonsense. How far we have strayed.
    const String svgStr = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
    <image href="data:img/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==" />
</svg>''';

    final VectorInstructions instructions = parseWithoutOptimizers(
      svgStr,
      key: 'image',
      warningsAsErrors: true,
    );

    expect(instructions.images.first.format, 1);
  });

  test('Ghostscript Tiger - dedupes paints', () {
    final VectorInstructions instructions = parseWithoutOptimizers(
      ghostscriptTiger,
      key: 'ghostscriptTiger',
      warningsAsErrors: true,
    );

    expect(instructions.paints.toSet(), ghostScriptTigerPaints.toSet());
    expect(instructions.paths, ghostScriptTigerPaths);
    expect(
      instructions.commands,
      const <DrawCommand>[
        DrawCommand(DrawCommandType.path,
            objectId: 0, paintId: 0, debugString: 'path8'),
        DrawCommand(DrawCommandType.path,
            objectId: 1, paintId: 0, debugString: 'path12'),
        DrawCommand(DrawCommandType.path,
            objectId: 2, paintId: 0, debugString: 'path16'),
        DrawCommand(DrawCommandType.path,
            objectId: 3, paintId: 0, debugString: 'path20'),
        DrawCommand(DrawCommandType.path,
            objectId: 4, paintId: 0, debugString: 'path24'),
        DrawCommand(DrawCommandType.path,
            objectId: 5, paintId: 0, debugString: 'path28'),
        DrawCommand(DrawCommandType.path,
            objectId: 6, paintId: 0, debugString: 'path32'),
        DrawCommand(DrawCommandType.path,
            objectId: 7, paintId: 0, debugString: 'path36'),
        DrawCommand(DrawCommandType.path,
            objectId: 8, paintId: 0, debugString: 'path40'),
        DrawCommand(DrawCommandType.path,
            objectId: 9, paintId: 0, debugString: 'path44'),
        DrawCommand(DrawCommandType.path,
            objectId: 10, paintId: 0, debugString: 'path48'),
        DrawCommand(DrawCommandType.path,
            objectId: 11, paintId: 0, debugString: 'path52'),
        DrawCommand(DrawCommandType.path,
            objectId: 12, paintId: 1, debugString: 'path56'),
        DrawCommand(DrawCommandType.path,
            objectId: 13, paintId: 2, debugString: 'path60'),
        DrawCommand(DrawCommandType.path,
            objectId: 14, paintId: 3, debugString: 'path64'),
        DrawCommand(DrawCommandType.path,
            objectId: 15, paintId: 4, debugString: 'path68'),
        DrawCommand(DrawCommandType.path,
            objectId: 16, paintId: 5, debugString: 'path72'),
        DrawCommand(DrawCommandType.path,
            objectId: 17, paintId: 6, debugString: 'path76'),
        DrawCommand(DrawCommandType.path,
            objectId: 18, paintId: 7, debugString: 'path80'),
        DrawCommand(DrawCommandType.path,
            objectId: 19, paintId: 8, debugString: 'path84'),
        DrawCommand(DrawCommandType.path,
            objectId: 20, paintId: 9, debugString: 'path88'),
        DrawCommand(DrawCommandType.path,
            objectId: 21, paintId: 10, debugString: 'path92'),
        DrawCommand(DrawCommandType.path,
            objectId: 22, paintId: 11, debugString: 'path96'),
        DrawCommand(DrawCommandType.path,
            objectId: 23, paintId: 12, debugString: 'path100'),
        DrawCommand(DrawCommandType.path,
            objectId: 24, paintId: 13, debugString: 'path104'),
        DrawCommand(DrawCommandType.path,
            objectId: 25, paintId: 14, debugString: 'path108'),
        DrawCommand(DrawCommandType.path,
            objectId: 26, paintId: 15, debugString: 'path112'),
        DrawCommand(DrawCommandType.path,
            objectId: 27, paintId: 16, debugString: 'path116'),
        DrawCommand(DrawCommandType.path,
            objectId: 28, paintId: 15, debugString: 'path120'),
        DrawCommand(DrawCommandType.path,
            objectId: 29, paintId: 16, debugString: 'path124'),
        DrawCommand(DrawCommandType.path,
            objectId: 30, paintId: 16, debugString: 'path128'),
        DrawCommand(DrawCommandType.path,
            objectId: 31, paintId: 16, debugString: 'path132'),
        DrawCommand(DrawCommandType.path,
            objectId: 32, paintId: 16, debugString: 'path136'),
        DrawCommand(DrawCommandType.path,
            objectId: 33, paintId: 16, debugString: 'path140'),
        DrawCommand(DrawCommandType.path,
            objectId: 34, paintId: 16, debugString: 'path144'),
        DrawCommand(DrawCommandType.path,
            objectId: 35, paintId: 15, debugString: 'path148'),
        DrawCommand(DrawCommandType.path,
            objectId: 36, paintId: 17, debugString: 'path152'),
        DrawCommand(DrawCommandType.path,
            objectId: 37, paintId: 18, debugString: 'path156'),
        DrawCommand(DrawCommandType.path,
            objectId: 38, paintId: 19, debugString: 'path160'),
        DrawCommand(DrawCommandType.path,
            objectId: 39, paintId: 20, debugString: 'path164'),
        DrawCommand(DrawCommandType.path,
            objectId: 40, paintId: 21, debugString: 'path168'),
        DrawCommand(DrawCommandType.path,
            objectId: 41, paintId: 22, debugString: 'path172'),
        DrawCommand(DrawCommandType.path,
            objectId: 42, paintId: 23, debugString: 'path176'),
        DrawCommand(DrawCommandType.path,
            objectId: 43, paintId: 21, debugString: 'path180'),
        DrawCommand(DrawCommandType.path,
            objectId: 44, paintId: 21, debugString: 'path184'),
        DrawCommand(DrawCommandType.path,
            objectId: 45, paintId: 21, debugString: 'path188'),
        DrawCommand(DrawCommandType.path,
            objectId: 46, paintId: 21, debugString: 'path192'),
        DrawCommand(DrawCommandType.path,
            objectId: 47, paintId: 21, debugString: 'path196'),
        DrawCommand(DrawCommandType.path,
            objectId: 48, paintId: 21, debugString: 'path200'),
        DrawCommand(DrawCommandType.path,
            objectId: 49, paintId: 24, debugString: 'path204'),
        DrawCommand(DrawCommandType.path,
            objectId: 50, paintId: 24, debugString: 'path208'),
        DrawCommand(DrawCommandType.path,
            objectId: 51, paintId: 21, debugString: 'path212'),
        DrawCommand(DrawCommandType.path,
            objectId: 52, paintId: 24, debugString: 'path216'),
        DrawCommand(DrawCommandType.path,
            objectId: 53, paintId: 24, debugString: 'path220'),
        DrawCommand(DrawCommandType.path,
            objectId: 54, paintId: 25, debugString: 'path224'),
        DrawCommand(DrawCommandType.path,
            objectId: 55, paintId: 21, debugString: 'path228'),
        DrawCommand(DrawCommandType.path,
            objectId: 56, paintId: 21, debugString: 'path232'),
        DrawCommand(DrawCommandType.path,
            objectId: 57, paintId: 21, debugString: 'path236'),
        DrawCommand(DrawCommandType.path,
            objectId: 58, paintId: 15, debugString: 'path240'),
        DrawCommand(DrawCommandType.path,
            objectId: 59, paintId: 21, debugString: 'path244'),
        DrawCommand(DrawCommandType.path,
            objectId: 60, paintId: 21, debugString: 'path248'),
        DrawCommand(DrawCommandType.path,
            objectId: 61, paintId: 21, debugString: 'path252'),
        DrawCommand(DrawCommandType.path,
            objectId: 62, paintId: 21, debugString: 'path256'),
        DrawCommand(DrawCommandType.path,
            objectId: 63, paintId: 21, debugString: 'path260'),
        DrawCommand(DrawCommandType.path,
            objectId: 64, paintId: 26, debugString: 'path264'),
        DrawCommand(DrawCommandType.path,
            objectId: 65, paintId: 26, debugString: 'path268'),
        DrawCommand(DrawCommandType.path,
            objectId: 66, paintId: 3, debugString: 'path272'),
        DrawCommand(DrawCommandType.path,
            objectId: 67, paintId: 27, debugString: 'path276'),
        DrawCommand(DrawCommandType.path,
            objectId: 68, paintId: 28, debugString: 'path280'),
        DrawCommand(DrawCommandType.path,
            objectId: 69, paintId: 29, debugString: 'path284'),
        DrawCommand(DrawCommandType.path,
            objectId: 70, paintId: 30, debugString: 'path288'),
        DrawCommand(DrawCommandType.path,
            objectId: 71, paintId: 14, debugString: 'path292'),
        DrawCommand(DrawCommandType.path,
            objectId: 72, paintId: 16, debugString: 'path296'),
        DrawCommand(DrawCommandType.path,
            objectId: 73, paintId: 15, debugString: 'path300'),
        DrawCommand(DrawCommandType.path,
            objectId: 74, paintId: 31, debugString: 'path304'),
        DrawCommand(DrawCommandType.path,
            objectId: 75, paintId: 32, debugString: 'path308'),
        DrawCommand(DrawCommandType.path,
            objectId: 76, paintId: 14, debugString: 'path312'),
        DrawCommand(DrawCommandType.path,
            objectId: 77, paintId: 15, debugString: 'path316'),
        DrawCommand(DrawCommandType.path,
            objectId: 78, paintId: 3, debugString: 'path320'),
        DrawCommand(DrawCommandType.path,
            objectId: 79, paintId: 14, debugString: 'path324'),
        DrawCommand(DrawCommandType.path,
            objectId: 80, paintId: 33, debugString: 'path328'),
        DrawCommand(DrawCommandType.path,
            objectId: 81, paintId: 34, debugString: 'path332'),
        DrawCommand(DrawCommandType.path,
            objectId: 82, paintId: 35, debugString: 'path336'),
        DrawCommand(DrawCommandType.path,
            objectId: 83, paintId: 14, debugString: 'path340'),
        DrawCommand(DrawCommandType.path,
            objectId: 84, paintId: 16, debugString: 'path344'),
        DrawCommand(DrawCommandType.path,
            objectId: 85, paintId: 15, debugString: 'path348'),
        DrawCommand(DrawCommandType.path,
            objectId: 86, paintId: 31, debugString: 'path352'),
        DrawCommand(DrawCommandType.path,
            objectId: 87, paintId: 15, debugString: 'path356'),
        DrawCommand(DrawCommandType.path,
            objectId: 88, paintId: 15, debugString: 'path360'),
        DrawCommand(DrawCommandType.path,
            objectId: 89, paintId: 15, debugString: 'path364'),
        DrawCommand(DrawCommandType.path,
            objectId: 90, paintId: 36, debugString: 'path368'),
        DrawCommand(DrawCommandType.path,
            objectId: 91, paintId: 37, debugString: 'path372'),
        DrawCommand(DrawCommandType.path,
            objectId: 92, paintId: 38, debugString: 'path376'),
        DrawCommand(DrawCommandType.path,
            objectId: 93, paintId: 16, debugString: 'path380'),
        DrawCommand(DrawCommandType.path,
            objectId: 94, paintId: 14, debugString: 'path384'),
        DrawCommand(DrawCommandType.path,
            objectId: 95, paintId: 39, debugString: 'path388'),
        DrawCommand(DrawCommandType.path,
            objectId: 96, paintId: 16, debugString: 'path392'),
        DrawCommand(DrawCommandType.path,
            objectId: 97, paintId: 16, debugString: 'path396'),
        DrawCommand(DrawCommandType.path,
            objectId: 98, paintId: 16, debugString: 'path400'),
        DrawCommand(DrawCommandType.path,
            objectId: 99, paintId: 16, debugString: 'path404'),
        DrawCommand(DrawCommandType.path,
            objectId: 100, paintId: 16, debugString: 'path408'),
        DrawCommand(DrawCommandType.path,
            objectId: 101, paintId: 15, debugString: 'path412'),
        DrawCommand(DrawCommandType.path,
            objectId: 102, paintId: 15, debugString: 'path416'),
        DrawCommand(DrawCommandType.path,
            objectId: 103, paintId: 3, debugString: 'path420'),
        DrawCommand(DrawCommandType.path,
            objectId: 104, paintId: 3, debugString: 'path424'),
        DrawCommand(DrawCommandType.path,
            objectId: 105, paintId: 3, debugString: 'path428'),
        DrawCommand(DrawCommandType.path,
            objectId: 106, paintId: 3, debugString: 'path432'),
        DrawCommand(DrawCommandType.path,
            objectId: 107, paintId: 3, debugString: 'path436'),
        DrawCommand(DrawCommandType.path,
            objectId: 108, paintId: 3, debugString: 'path440'),
        DrawCommand(DrawCommandType.path,
            objectId: 109, paintId: 15, debugString: 'path444'),
        DrawCommand(DrawCommandType.path,
            objectId: 110, paintId: 40, debugString: 'path448'),
        DrawCommand(DrawCommandType.path,
            objectId: 111, paintId: 40, debugString: 'path452'),
        DrawCommand(DrawCommandType.path,
            objectId: 112, paintId: 40, debugString: 'path456'),
        DrawCommand(DrawCommandType.path,
            objectId: 113, paintId: 40, debugString: 'path460'),
        DrawCommand(DrawCommandType.path,
            objectId: 114, paintId: 15, debugString: 'path464'),
        DrawCommand(DrawCommandType.path,
            objectId: 115, paintId: 41, debugString: 'path468'),
        DrawCommand(DrawCommandType.path,
            objectId: 116, paintId: 31, debugString: 'path472'),
        DrawCommand(DrawCommandType.path,
            objectId: 117, paintId: 32, debugString: 'path476'),
        DrawCommand(DrawCommandType.path,
            objectId: 118, paintId: 15, debugString: 'path480'),
        DrawCommand(DrawCommandType.path,
            objectId: 119, paintId: 15, debugString: 'path484'),
        DrawCommand(DrawCommandType.path,
            objectId: 120, paintId: 15, debugString: 'path488'),
        DrawCommand(DrawCommandType.path,
            objectId: 121, paintId: 42, debugString: 'path492'),
        DrawCommand(DrawCommandType.path,
            objectId: 122, paintId: 43, debugString: 'path496'),
        DrawCommand(DrawCommandType.path,
            objectId: 123, paintId: 39, debugString: 'path500'),
        DrawCommand(DrawCommandType.path,
            objectId: 124, paintId: 14, debugString: 'path504'),
        DrawCommand(DrawCommandType.path,
            objectId: 125, paintId: 39, debugString: 'path508'),
        DrawCommand(DrawCommandType.path,
            objectId: 126, paintId: 15, debugString: 'path512'),
        DrawCommand(DrawCommandType.path,
            objectId: 127, paintId: 15, debugString: 'path516'),
        DrawCommand(DrawCommandType.path,
            objectId: 128, paintId: 15, debugString: 'path520'),
        DrawCommand(DrawCommandType.path,
            objectId: 129, paintId: 15, debugString: 'path524'),
        DrawCommand(DrawCommandType.path,
            objectId: 130, paintId: 15, debugString: 'path528'),
        DrawCommand(DrawCommandType.path,
            objectId: 131, paintId: 15, debugString: 'path532'),
        DrawCommand(DrawCommandType.path,
            objectId: 132, paintId: 15, debugString: 'path536'),
        DrawCommand(DrawCommandType.path,
            objectId: 133, paintId: 15, debugString: 'path540'),
        DrawCommand(DrawCommandType.path,
            objectId: 134, paintId: 15, debugString: 'path544'),
        DrawCommand(DrawCommandType.path,
            objectId: 135, paintId: 14, debugString: 'path548'),
        DrawCommand(DrawCommandType.path,
            objectId: 136, paintId: 14, debugString: 'path552'),
        DrawCommand(DrawCommandType.path,
            objectId: 137, paintId: 16, debugString: 'path556'),
        DrawCommand(DrawCommandType.path,
            objectId: 138, paintId: 15, debugString: 'path560'),
        DrawCommand(DrawCommandType.path,
            objectId: 139, paintId: 16, debugString: 'path564'),
        DrawCommand(DrawCommandType.path,
            objectId: 140, paintId: 15, debugString: 'path568'),
        DrawCommand(DrawCommandType.path,
            objectId: 141, paintId: 15, debugString: 'path572'),
        DrawCommand(DrawCommandType.path,
            objectId: 142, paintId: 15, debugString: 'path576'),
        DrawCommand(DrawCommandType.path,
            objectId: 143, paintId: 15, debugString: 'path580'),
        DrawCommand(DrawCommandType.path,
            objectId: 144, paintId: 15, debugString: 'path584'),
        DrawCommand(DrawCommandType.path,
            objectId: 145, paintId: 15, debugString: 'path588'),
        DrawCommand(DrawCommandType.path,
            objectId: 146, paintId: 15, debugString: 'path592'),
        DrawCommand(DrawCommandType.path,
            objectId: 147, paintId: 15, debugString: 'path596'),
        DrawCommand(DrawCommandType.path,
            objectId: 148, paintId: 15, debugString: 'path600'),
        DrawCommand(DrawCommandType.path,
            objectId: 149, paintId: 15, debugString: 'path604'),
        DrawCommand(DrawCommandType.path,
            objectId: 150, paintId: 15, debugString: 'path608'),
        DrawCommand(DrawCommandType.path,
            objectId: 151, paintId: 15, debugString: 'path612'),
        DrawCommand(DrawCommandType.path,
            objectId: 152, paintId: 15, debugString: 'path616'),
        DrawCommand(DrawCommandType.path,
            objectId: 153, paintId: 15, debugString: 'path620'),
        DrawCommand(DrawCommandType.path,
            objectId: 154, paintId: 15, debugString: 'path624'),
        DrawCommand(DrawCommandType.path,
            objectId: 155, paintId: 15, debugString: 'path628'),
        DrawCommand(DrawCommandType.path,
            objectId: 156, paintId: 15, debugString: 'path632'),
        DrawCommand(DrawCommandType.path,
            objectId: 157, paintId: 39, debugString: 'path636'),
        DrawCommand(DrawCommandType.path,
            objectId: 158, paintId: 39, debugString: 'path640'),
        DrawCommand(DrawCommandType.path,
            objectId: 159, paintId: 16, debugString: 'path644'),
        DrawCommand(DrawCommandType.path,
            objectId: 160, paintId: 15, debugString: 'path648'),
        DrawCommand(DrawCommandType.path,
            objectId: 161, paintId: 15, debugString: 'path652'),
        DrawCommand(DrawCommandType.path,
            objectId: 162, paintId: 44, debugString: 'path656'),
        DrawCommand(DrawCommandType.path,
            objectId: 163, paintId: 44, debugString: 'path660'),
        DrawCommand(DrawCommandType.path,
            objectId: 164, paintId: 44, debugString: 'path664'),
        DrawCommand(DrawCommandType.path,
            objectId: 165, paintId: 44, debugString: 'path668'),
        DrawCommand(DrawCommandType.path,
            objectId: 166, paintId: 44, debugString: 'path672'),
        DrawCommand(DrawCommandType.path,
            objectId: 167, paintId: 44, debugString: 'path676'),
        DrawCommand(DrawCommandType.path,
            objectId: 168, paintId: 44, debugString: 'path680'),
        DrawCommand(DrawCommandType.path,
            objectId: 169, paintId: 44, debugString: 'path684'),
        DrawCommand(DrawCommandType.path,
            objectId: 170, paintId: 16, debugString: 'path688'),
        DrawCommand(DrawCommandType.path,
            objectId: 171, paintId: 15, debugString: 'path692'),
        DrawCommand(DrawCommandType.path,
            objectId: 172, paintId: 15, debugString: 'path696'),
        DrawCommand(DrawCommandType.path,
            objectId: 173, paintId: 15, debugString: 'path700'),
        DrawCommand(DrawCommandType.path,
            objectId: 174, paintId: 15, debugString: 'path704'),
        DrawCommand(DrawCommandType.path,
            objectId: 175, paintId: 15, debugString: 'path708'),
        DrawCommand(DrawCommandType.path,
            objectId: 176, paintId: 15, debugString: 'path712'),
        DrawCommand(DrawCommandType.path,
            objectId: 177, paintId: 15, debugString: 'path716'),
        DrawCommand(DrawCommandType.path,
            objectId: 178, paintId: 15, debugString: 'path720'),
        DrawCommand(DrawCommandType.path,
            objectId: 179, paintId: 15, debugString: 'path724'),
        DrawCommand(DrawCommandType.path,
            objectId: 180, paintId: 15, debugString: 'path728'),
        DrawCommand(DrawCommandType.path,
            objectId: 181, paintId: 44, debugString: 'path732'),
        DrawCommand(DrawCommandType.path,
            objectId: 182, paintId: 15, debugString: 'path736'),
        DrawCommand(DrawCommandType.path,
            objectId: 183, paintId: 44, debugString: 'path740'),
        DrawCommand(DrawCommandType.path,
            objectId: 184, paintId: 44, debugString: 'path744'),
        DrawCommand(DrawCommandType.path,
            objectId: 185, paintId: 44, debugString: 'path748'),
        DrawCommand(DrawCommandType.path,
            objectId: 186, paintId: 44, debugString: 'path752'),
        DrawCommand(DrawCommandType.path,
            objectId: 187, paintId: 44, debugString: 'path756'),
        DrawCommand(DrawCommandType.path,
            objectId: 188, paintId: 44, debugString: 'path760'),
        DrawCommand(DrawCommandType.path,
            objectId: 189, paintId: 44, debugString: 'path764'),
        DrawCommand(DrawCommandType.path,
            objectId: 190, paintId: 44, debugString: 'path768'),
        DrawCommand(DrawCommandType.path,
            objectId: 191, paintId: 44, debugString: 'path772'),
        DrawCommand(DrawCommandType.path,
            objectId: 192, paintId: 44, debugString: 'path776'),
        DrawCommand(DrawCommandType.path,
            objectId: 193, paintId: 44, debugString: 'path780'),
        DrawCommand(DrawCommandType.path,
            objectId: 194, paintId: 44, debugString: 'path784'),
        DrawCommand(DrawCommandType.path,
            objectId: 195, paintId: 44, debugString: 'path788'),
        DrawCommand(DrawCommandType.path,
            objectId: 196, paintId: 44, debugString: 'path792'),
        DrawCommand(DrawCommandType.path,
            objectId: 197, paintId: 44, debugString: 'path796'),
        DrawCommand(DrawCommandType.path,
            objectId: 198, paintId: 44, debugString: 'path800'),
        DrawCommand(DrawCommandType.path,
            objectId: 199, paintId: 44, debugString: 'path804'),
        DrawCommand(DrawCommandType.path,
            objectId: 200, paintId: 44, debugString: 'path808'),
        DrawCommand(DrawCommandType.path,
            objectId: 201, paintId: 44, debugString: 'path812'),
        DrawCommand(DrawCommandType.path,
            objectId: 202, paintId: 44, debugString: 'path816'),
        DrawCommand(DrawCommandType.path,
            objectId: 203, paintId: 44, debugString: 'path820'),
        DrawCommand(DrawCommandType.path,
            objectId: 204, paintId: 44, debugString: 'path824'),
        DrawCommand(DrawCommandType.path,
            objectId: 205, paintId: 44, debugString: 'path828'),
        DrawCommand(DrawCommandType.path,
            objectId: 206, paintId: 44, debugString: 'path832'),
        DrawCommand(DrawCommandType.path,
            objectId: 207, paintId: 44, debugString: 'path836'),
        DrawCommand(DrawCommandType.path,
            objectId: 208, paintId: 15, debugString: 'path840'),
        DrawCommand(DrawCommandType.path,
            objectId: 209, paintId: 15, debugString: 'path844'),
        DrawCommand(DrawCommandType.path,
            objectId: 210, paintId: 15, debugString: 'path848'),
        DrawCommand(DrawCommandType.path,
            objectId: 211, paintId: 15, debugString: 'path852'),
        DrawCommand(DrawCommandType.path,
            objectId: 212, paintId: 15, debugString: 'path856'),
        DrawCommand(DrawCommandType.path,
            objectId: 213, paintId: 15, debugString: 'path860'),
        DrawCommand(DrawCommandType.path,
            objectId: 214, paintId: 16, debugString: 'path864'),
        DrawCommand(DrawCommandType.path,
            objectId: 215, paintId: 16, debugString: 'path868'),
        DrawCommand(DrawCommandType.path,
            objectId: 216, paintId: 16, debugString: 'path872'),
        DrawCommand(DrawCommandType.path,
            objectId: 217, paintId: 16, debugString: 'path876'),
        DrawCommand(DrawCommandType.path,
            objectId: 218, paintId: 16, debugString: 'path880'),
        DrawCommand(DrawCommandType.path,
            objectId: 219, paintId: 16, debugString: 'path884'),
        DrawCommand(DrawCommandType.path,
            objectId: 220, paintId: 16, debugString: 'path888'),
        DrawCommand(DrawCommandType.path,
            objectId: 221, paintId: 16, debugString: 'path892'),
        DrawCommand(DrawCommandType.path,
            objectId: 222, paintId: 16, debugString: 'path896'),
        DrawCommand(DrawCommandType.path,
            objectId: 223, paintId: 16, debugString: 'path900'),
        DrawCommand(DrawCommandType.path,
            objectId: 224, paintId: 16, debugString: 'path904'),
        DrawCommand(DrawCommandType.path,
            objectId: 225, paintId: 16, debugString: 'path908'),
        DrawCommand(DrawCommandType.path,
            objectId: 226, paintId: 16, debugString: 'path912'),
        DrawCommand(DrawCommandType.path,
            objectId: 227, paintId: 16, debugString: 'path916'),
        DrawCommand(DrawCommandType.path,
            objectId: 228, paintId: 16, debugString: 'path920'),
        DrawCommand(DrawCommandType.path,
            objectId: 229, paintId: 16, debugString: 'path924'),
        DrawCommand(DrawCommandType.path,
            objectId: 230, paintId: 16, debugString: 'path928'),
        DrawCommand(DrawCommandType.path,
            objectId: 231, paintId: 16, debugString: 'path932'),
        DrawCommand(DrawCommandType.path,
            objectId: 232, paintId: 16, debugString: 'path936'),
        DrawCommand(DrawCommandType.path,
            objectId: 233, paintId: 16, debugString: 'path940'),
        DrawCommand(DrawCommandType.path,
            objectId: 234, paintId: 16, debugString: 'path944'),
        DrawCommand(DrawCommandType.path,
            objectId: 235, paintId: 16, debugString: 'path948'),
        DrawCommand(DrawCommandType.path,
            objectId: 236, paintId: 45, debugString: 'path952'),
        DrawCommand(DrawCommandType.path,
            objectId: 237, paintId: 45, debugString: 'path956'),
        DrawCommand(DrawCommandType.path,
            objectId: 238, paintId: 45, debugString: 'path960'),
        DrawCommand(DrawCommandType.path,
            objectId: 239, paintId: 45, debugString: 'path964'),
      ],
    );
  });

  test('Parse empty tag', () {
    const String svgStr = '''
     <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200">
        <polygon
            fill="#0a287d"
            points=""
            id="triangle"/>
     </svg>
    ''';

    expect(parseWithoutOptimizers(svgStr), isA<VectorInstructions>());
  });
}

const List<Paint> ghostScriptTigerPaints = <Paint>[
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.303691181256463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack),
      fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill(color: Color(0xffe87f3a))),
  Paint(fill: Fill(color: Color(0xffea8c4d))),
  Paint(fill: Fill(color: Color(0xffec9961))),
  Paint(fill: Fill(color: Color(0xffeea575))),
  Paint(fill: Fill(color: Color(0xfff1b288))),
  Paint(fill: Fill(color: Color(0xfff3bf9c))),
  Paint(fill: Fill(color: Color(0xfff5ccb0))),
  Paint(fill: Fill(color: Color(0xfff8d8c4))),
  Paint(fill: Fill(color: Color(0xfffae5d7))),
  Paint(fill: Fill(color: Color(0xfffcf2eb))),
  Paint(fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xffe5668c))),
  Paint(fill: Fill(color: Color(0xffb23259))),
  Paint(fill: Fill(color: Color(0xffa5264c))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack),
      fill: Fill(color: Color(0xffff727f))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(fill: Fill(color: Color(0xffcc3f4c))),
  Paint(stroke: Stroke(color: Color(0xffa51926), width: 3.5312926)),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(stroke: Stroke(color: Color(0xffa5264c), width: 3.5312926)),
  Paint(stroke: Stroke(color: Color(0xffa5264c), width: 3.5312926)),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(stroke: Stroke(color: Color(0xffa5264c), width: 3.5312926)),
  Paint(stroke: Stroke(color: Color(0xffa5264c), width: 3.5312926)),
  Paint(fill: Fill(color: Color(0xffb2b2b2))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(fill: Fill()),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.88282315),
      fill: Fill(color: Color(0xffffffcc))),
  Paint(fill: Fill(color: Color(0xffe5e5b2))),
  Paint(fill: Fill(color: Color(0xffe5e5b2))),
  Paint(fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill(color: Color(0xffea8e51))),
  Paint(fill: Fill(color: Color(0xffefaa7c))),
  Paint(fill: Fill(color: Color(0xfff4c6a8))),
  Paint(fill: Fill(color: Color(0xfff9e2d3))),
  Paint(fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xff99cc32))),
  Paint(fill: Fill(color: Color(0xff659900))),
  Paint(fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill(color: Color(0xffeb955c))),
  Paint(fill: Fill(color: Color(0xfff2b892))),
  Paint(fill: Fill(color: Color(0xfff8dcc8))),
  Paint(fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xff99cc32))),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xff323232))),
  Paint(fill: Fill(color: Color(0xff666666))),
  Paint(fill: Fill(color: Color(0xff999999))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill(color: Color(0xff992600))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill(color: Color(0xffcc7226))),
  Paint(fill: Fill()),
  Paint(stroke: Stroke(color: Color(0xff4c0000), width: 3.5312926)),
  Paint(stroke: Stroke(color: Color(0xff4c0000), width: 3.5312926)),
  Paint(stroke: Stroke(color: Color(0xff4c0000), width: 3.5312926)),
  Paint(stroke: Stroke(color: Color(0xff4c0000), width: 3.5312926)),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xff4c0000))),
  Paint(fill: Fill(color: Color(0xff99cc32))),
  Paint(fill: Fill(color: Color(0xff659900))),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xffe59999))),
  Paint(fill: Fill(color: Color(0xffb26565))),
  Paint(fill: Fill(color: Color(0xff992600))),
  Paint(fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill(color: Color(0xff992600))),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xff992600))),
  Paint(fill: Fill(color: Color(0xff992600))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill()),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(
      stroke: Stroke(color: Color.opaqueBlack, width: 0.17656463),
      fill: Fill(color: Color(0xffffffff))),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill()),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(fill: Fill(color: Color(0xffcccccc))),
  Paint(stroke: Stroke(color: Color.opaqueBlack)),
  Paint(stroke: Stroke(color: Color.opaqueBlack)),
  Paint(stroke: Stroke(color: Color.opaqueBlack)),
  Paint(stroke: Stroke(color: Color.opaqueBlack))
];

final List<Path> ghostScriptTigerPaths = <Path>[
  Path(
    commands: const <PathCommand>[
      MoveToCommand(108.96861750999997, 403.8269183955),
      CubicToCommand(108.96861750999997, 403.8269183955, 109.14518213999997,
          407.17105248769997, 107.67969571099997, 407.137505208),
      CubicToCommand(106.231865745, 407.1039579283, 77.18698410999997,
          322.2205120558, 40.93826557099999, 326.1808567067),
      CubicToCommand(40.93826557099999, 326.1808567067, 72.331456785,
          313.1980594628, 108.96861751, 403.8269183955),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(115.20134894899999, 398.4893696306),
      CubicToCommand(115.20134894899999, 398.4893696306, 114.230243484,
          401.6957833114, 112.87069583299998, 401.1678550677),
      CubicToCommand(111.511148182, 400.6416924703, 113.064916926,
          310.9362665525, 77.646052148, 302.3305064863),
      CubicToCommand(77.646052148, 302.3305064863, 111.58177403399998,
          300.8049880831, 115.20134894899999, 398.4893696306),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(163.73190315079998, 473.225646217),
      CubicToCommand(163.73190315079998, 473.225646217, 166.62050049759995,
          474.920666665, 165.79064673659997, 476.121306149),
      CubicToCommand(164.95902732929994, 477.30428917, 78.14043311199995,
          454.70401653, 61.437419113999965, 487.121282598),
      CubicToCommand(61.437419113999965, 487.121282598, 67.93499749799997,
          453.768223991, 163.73190315079998, 473.225646217),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(158.77220269409997, 491.25289494000003),
      CubicToCommand(158.77220269409997, 491.25289494000003, 162.04924222689996,
          491.95915346000004, 161.63608099269996, 493.354014037),
      CubicToCommand(161.22468540479997, 494.748874614, 71.69582411699997,
          500.646133256, 66.06341241999996, 536.665317776),
      CubicToCommand(66.06341241999996, 536.665317776, 61.71992252199999,
          502.976786372, 158.7722026941, 491.25289494000003),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(151.33706612479997, 481.506527364),
      CubicToCommand(151.33706612479997, 481.506527364, 154.47638524619998,
          482.67185392199997, 153.86547162639997, 483.99608864699997),
      CubicToCommand(153.25455800659998, 485.32032337199996, 63.82104161899997,
          478.09883000499997, 52.99762979999997, 512.899718578),
      CubicToCommand(52.99762979999997, 512.899718578, 53.61560600499996,
          478.928683766, 151.33706612479997, 481.506527364),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(132.43405683699996, 449.354108241),
      CubicToCommand(132.43405683699996, 449.354108241, 134.74705348999998,
          451.79070013499995, 133.61703985799997, 452.708836211),
      CubicToCommand(132.48702622599995, 453.62697228700006, 55.257657064,
          407.97442155420003, 30.27376191899998, 434.54033578400004),
      CubicToCommand(30.27376191899998, 434.54033578400004, 45.705510581,
          404.26479867790005, 132.43405683699996, 449.354108241),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(119.12108373499998, 456.752166238),
      CubicToCommand(119.12108373499998, 456.752166238, 121.68127086999999,
          458.906254724, 120.67485247899998, 459.94798604100004),
      CubicToCommand(119.65077762499999, 460.989717358, 37.74244576799998,
          424.3737443886, 15.936713962999931, 453.59165936100004),
      CubicToCommand(15.936713962999931, 453.59165936100004, 27.837170024999978,
          421.76941609610003, 119.12108373499996, 456.75216623800003),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(114.53040335499998, 463.956003142),
      CubicToCommand(114.53040335499998, 463.956003142, 117.35543743499994,
          465.721649442, 116.49027074799997, 466.904632463),
      CubicToCommand(115.62510406099997, 468.06995902100005, 29.496877546999997,
          442.96246863500005, 11.875727472999927, 474.86769727600006),
      CubicToCommand(11.875727472999927, 474.86769727600006, 19.326754858999948,
          441.72651622500007, 114.53040335499995, 463.956003142),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(133.47578815399999, 465.03304738500003),
      CubicToCommand(133.47578815399999, 465.03304738500003, 135.45331201,
          467.734486224, 134.21735959999998, 468.511370596),
      CubicToCommand(132.98140718999997, 469.270598505, 62.231959948999986,
          414.09768292260003, 34.05224500100002, 437.241774623),
      CubicToCommand(34.05224500100002, 437.241774623, 53.24482028199998,
          409.1962487938, 133.47578815399999, 465.03304738500003),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(98.55130434, 413.917587),
      CubicToCommand(98.55130434, 413.917587, 99.61069211999998, 417.09575034,
          98.19817508000003, 417.4488796),
      CubicToCommand(96.78565804000004, 417.80200886, 46.28817386000003,
          343.64486426, 12.387764900000036, 357.06377614),
      CubicToCommand(12.387764900000036, 357.06377614, 39.22558866000003,
          336.2291498, 98.55130434, 413.917587),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(99.78725674999998, 426.2400325277),
      CubicToCommand(99.78725674999998, 426.2400325277, 101.49993366099997,
          429.1162703504, 100.19335539899998, 429.7642625425),
      CubicToCommand(98.886777137, 430.41402038089996, 33.59317696299996,
          368.8918407037, 3.382968769999991, 389.30624322430003),
      CubicToCommand(3.382968769999991, 389.30624322430003, 25.100418260000026,
          363.1746779843, 99.78725674999998, 426.2400325277),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(99.57537919399996, 433.957672505),
      CubicToCommand(99.57537919399996, 433.957672505, 101.55290304999997,
          436.659111344, 100.31695063999996, 437.435995716),
      CubicToCommand(99.08099822999998, 438.19522362500004, 28.331550988999993,
          383.0223080426, 0.15183604099996728, 406.1611028041),
      CubicToCommand(0.15183604099996728, 406.1611028041, 19.344411321999985,
          378.1208739138, 99.57537919399996, 433.957672505),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(95.67330087099995, 436.97692767800004),
      CubicToCommand(96.55612402099996, 447.659087793, 98.30411385799997,
          459.259383984, 101.37633841999997, 464.76820044),
      CubicToCommand(101.37633841999997, 464.76820044, 95.02001173999994,
          486.66221456, 110.55769917999996, 509.96874572),
      CubicToCommand(110.55769917999996, 509.96874572, 109.85144065999995,
          522.68139908, 112.67647473999997, 528.33146724),
      CubicToCommand(112.67647473999997, 528.33146724, 119.73905993999998,
          543.1628961600001, 128.21416217999996, 544.5754132),
      CubicToCommand(135.06486982399997, 545.723083295, 150.47366508409996,
          551.143617436, 167.88470324839997, 553.615522256),
      CubicToCommand(167.88470324839997, 553.615522256, 198.13375565999996,
          578.47582216, 192.48368749999997, 601.0760948),
      CubicToCommand(192.48368749999997, 601.0760948, 191.77742897999997,
          630.03269412, 185.42110229999997, 632.8577282),
      CubicToCommand(185.42110229999997, 632.8577282, 205.90259937999997,
          613.0824896400001, 188.95239489999997, 642.74534748),
      LineToCommand(181.18355117999997, 675.93949792),
      CubicToCommand(181.18355117999997, 675.93949792, 226.38409645999997,
          637.80153784, 198.84001417999997, 670.2894297600001),
      LineToCommand(181.18355117999997, 716.1962335600001),
      CubicToCommand(181.18355117999997, 716.1962335600001, 215.79021865999997,
          683.7083416400001, 203.07756529999997, 698.5397705600001),
      LineToCommand(197.42749713999996, 714.0774580000001),
      CubicToCommand(197.42749713999996, 714.0774580000001, 273.70341729999996,
          666.0518786400002, 219.32151125999997, 718.31500912),
      CubicToCommand(219.32151125999997, 718.31500912, 233.44668165999997,
          711.9586824400001, 241.21552537999997, 716.90249208),
      CubicToCommand(241.21552537999997, 716.90249208, 253.22192021999996,
          714.7837165200001, 251.80940317999995, 717.6087506),
      CubicToCommand(251.80940317999995, 717.6087506, 215.08396014,
          735.9714721199999, 208.72763345999994, 768.45936404),
      CubicToCommand(208.72763345999994, 768.45936404, 223.55906237999994,
          750.80290104, 217.90899421999995, 769.87188108),
      LineToCommand(218.61525273999996, 790.35337816),
      CubicToCommand(218.61525273999996, 790.35337816, 225.67783793999996,
          752.2154180800001, 224.97157941999996, 818.60371896),
      CubicToCommand(224.97157941999996, 818.60371896, 258.87198837999995,
          786.82208556, 238.39049129999995, 823.5475286000001),
      LineToCommand(238.39049129999995, 853.2103864400001),
      CubicToCommand(238.39049129999995, 853.2103864400001, 265.22831505999994,
          824.2537871200001, 253.92817873999996, 846.85405976),
      CubicToCommand(253.92817873999996, 846.85405976, 271.58464174,
          831.31637232, 264.52205654, 858.15419608),
      CubicToCommand(264.52205654, 858.15419608, 263.1095395, 876.5169175999999,
          270.87838322, 856.74167904),
      CubicToCommand(270.87838322, 856.74167904, 299.12872402, 802.71290226,
          288.53484621999996, 848.9728353200001),
      CubicToCommand(288.53484621999996, 848.9728353200001, 287.12232917999995,
          882.87324428, 295.59743141999996, 856.74167904),
      CubicToCommand(295.59743141999996, 856.74167904, 296.30368993999997,
          875.1044005599999, 312.5476359, 887.81705392),
      CubicToCommand(312.5476359, 887.81705392, 310.42886033999997,
          798.12222188, 333.02913298, 861.68548868),
      LineToCommand(340.09171818, 890.642088),
      CubicToCommand(340.09171818, 890.642088, 345.03552781999997, 874.39814204,
          344.32926929999996, 865.21678128),
      LineToCommand(358.45443969999997, 879.34195168),
      CubicToCommand(358.45443969999997, 879.34195168, 385.29226345999996,
          839.08521604, 379.64219529999997, 862.3917471999999),
      CubicToCommand(379.64219529999997, 862.3917471999999, 366.22328342,
          890.642088, 369.0483175, 899.11719024),
      CubicToCommand(369.0483175, 899.11719024, 398.71117533999995, 837.672699,
          400.8299509, 834.84766492),
      CubicToCommand(400.8299509, 834.84766492, 397.29865829999994,
          909.71106804, 416.36763834, 846.14780124),
      CubicToCommand(416.36763834, 846.14780124, 426.25525761999995,
          867.33555684, 421.31144797999997, 875.1044005599999),
      CubicToCommand(421.31144797999997, 875.1044005599999, 435.43661837999997,
          860.9792301599999, 434.02410133999996, 855.329162),
      CubicToCommand(434.02410133999996, 855.329162, 442.14607431999997,
          840.85086234, 447.08988395999995, 864.8636520199999),
      CubicToCommand(447.08988395999995, 864.8636520199999, 450.2680473,
          881.4607272399999, 453.09308138, 875.8106590799999),
      CubicToCommand(453.09308138, 875.8106590799999, 460.15566658,
          918.1861702799999, 462.27444214, 877.92943464),
      CubicToCommand(462.27444214, 877.92943464, 465.09947622,
          853.9166449599999, 452.38682286, 833.4351478799999),
      CubicToCommand(452.38682286, 833.4351478799999, 453.7993399,
          827.7850797199999, 448.85553026, 820.7224945199999),
      CubicToCommand(448.85553026, 820.7224945199999, 472.86831994, 858.8604546,
          460.15566658, 808.00984116),
      CubicToCommand(460.15566658, 808.00984116, 479.93267078630004,
          822.13501156, 482.0514463463, 822.13501156),
      CubicToCommand(482.0514463463, 822.13501156, 458.03689102, 781.1720174,
          473.57457846, 789.64711964),
      CubicToCommand(473.57457846, 789.64711964, 464.39321770000004,
          771.28439812, 496.1766167463, 792.47215372),
      CubicToCommand(496.1766167463, 792.47215372, 467.9245103, 764.22181292,
          499.00165082629997, 781.1720174000001),
      CubicToCommand(499.00165082629997, 781.1720174000001, 513.12505558,
          792.47215372, 499.70790934629997, 774.81569072),
      CubicToCommand(499.70790934629997, 774.81569072, 474.28083698,
          746.56534992, 513.12505558, 778.34698332),
      CubicToCommand(513.12505558, 778.34698332, 533.60655266, 807.30358264,
          535.0190697, 812.24739228),
      CubicToCommand(535.0190697, 812.24739228, 517.3626067, 760.69052032,
          509.59376298, 755.7467106800001),
      CubicToCommand(509.59376298, 755.7467106800001, 524.4251919000001,
          691.47718536, 597.16981946, 719.02126764),
      CubicToCommand(597.16981946, 719.02126764, 609.1762143000001, 749.390384,
          616.94505802, 716.90249208),
      CubicToCommand(616.94505802, 716.90249208, 639.54533066, 705.60235576,
          659.3205692199999, 754.3341936400001),
      CubicToCommand(659.3205692199999, 754.3341936400001, 666.38315442,
          730.32140396, 664.97063738, 725.3775943200001),
      CubicToCommand(664.97063738, 725.3775943200001, 676.97703222,
          727.4963698800001, 675.56451518, 725.3775943200001),
      CubicToCommand(675.56451518, 725.3775943200001, 698.87104634,
          733.14643804, 700.9898218999999, 731.7339210000001),
      CubicToCommand(700.9898218999999, 731.7339210000001, 712.99621674,
          743.7403158400001, 713.70247526, 737.38398916),
      CubicToCommand(713.70247526, 737.38398916, 729.9464212199999,
          742.3277988000001, 726.4151286199999, 735.97147212),
      CubicToCommand(726.4151286199999, 735.97147212, 741.95281606,
          763.5155544000002, 742.6590745799999, 769.87188108),
      LineToCommand(746.8966257, 745.15283288),
      LineToCommand(750.4279182999999, 750.09664252),
      CubicToCommand(750.4279182999999, 750.09664252, 753.2529523799999,
          736.67773064, 751.8404353399999, 734.55895508),
      CubicToCommand(750.4279183, 732.44017952, 787.15336134, 746.56534992,
          795.6284635799999, 783.2907929600001),
      LineToCommand(799.1597561799999, 798.12222188),
      CubicToCommand(799.1597561799999, 798.12222188, 809.7536339799999,
          771.99065664, 806.9285998999999, 764.92807144),
      CubicToCommand(806.9285998999999, 764.92807144, 816.1099606599998,
          766.3405884800001, 816.81621918, 774.1094322),
      CubicToCommand(816.81621918, 774.1094322, 823.8788043799999, 733.14643804,
          815.40370214, 722.55256024),
      CubicToCommand(815.40370214, 722.55256024, 823.1725458599999, 721.1400432,
          825.2913214199999, 727.4963698800001),
      LineToCommand(825.2913214199999, 714.7837165200001),
      CubicToCommand(825.2913214199999, 714.7837165200001, 838.0039747799999,
          716.1962335600001, 838.0039747799999, 711.9586824400001),
      CubicToCommand(838.0039747799999, 711.9586824400001, 845.7728184999999,
          704.89609724, 849.3041110999999, 713.3711994800001),
      CubicToCommand(849.3041110999999, 713.3711994800001, 827.4100969799999,
          651.22044972, 859.8979888999999, 685.1208586800001),
      CubicToCommand(859.8979888999999, 685.1208586800001, 872.6106422599998,
          704.18983872, 866.2543155799999, 670.9956882800001),
      CubicToCommand(859.8979889, 637.80153784, 852.8354036999999, 634.97650376,
          861.3105059399999, 634.27024524),
      CubicToCommand(861.3105059399999, 634.27024524, 862.7230229799999,
          627.9139185600001, 859.19173038, 625.08888448),
      CubicToCommand(855.6604377799999, 622.2638504, 861.3105059399999,
          625.08888448, 861.3105059399999, 625.08888448),
      CubicToCommand(861.3105059399999, 625.08888448, 869.7856081799999,
          632.15146968, 860.60424742, 593.30725108),
      CubicToCommand(860.60424742, 593.30725108, 871.9043837399998,
          596.13228516, 850.7166281399999, 544.5754132000001),
      CubicToCommand(850.7166281399999, 544.5754132000001, 855.6604377799999,
          540.33786208, 848.5978525799999, 525.50643316),
      CubicToCommand(848.5978525799999, 525.50643316, 862.7230229799999,
          533.2752768800001, 867.6668326199999, 530.4502428000001),
      CubicToCommand(867.6668326199999, 530.4502428000001, 866.9605741,
          527.62520872, 861.3105059399999, 520.5626235200001),
      CubicToCommand(861.3105059399999, 520.5626235200001, 823.1725458599999,
          423.8052062800001, 859.19173038, 462.6494248800001),
      CubicToCommand(859.19173038, 462.6494248800001, 880.114639035,
          486.57393224500004, 868.8145027149999, 446.31719660500005),
      CubicToCommand(868.8145027149999, 446.31719660500005, 852.7294649219999,
          403.92579458830005, 854.106669036, 396.3405780835001),
      LineToCommand(95.6733008709999, 436.9769276780001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(854.106669036, 396.6937073435),
      CubicToCommand(855.201369742, 397.0132893238, 859.103448065,
          398.997875765, 861.31050594, 401.91119216000004),
      CubicToCommand(861.31050594, 401.91119216000004, 873.31690078,
          420.98017219999997, 864.13554002, 388.49228028000005),
      CubicToCommand(864.13554002, 388.49228028000005, 847.8915940600001,
          337.64166684, 863.4292815000001, 357.4169054),
      CubicToCommand(863.4292815000001, 357.4169054, 874.0231593000001,
          370.12955876, 868.37309114, 346.11676908000004),
      CubicToCommand(861.557696422, 317.11249730990005, 857.0729548200002,
          305.86003344, 857.0729548200002, 305.86003344),
      CubicToCommand(857.0729548200002, 305.86003344, 877.5544519000002,
          314.33513568, 830.2351310600002, 244.41554220000003),
      LineToCommand(845.7728185000002, 250.77186888000003),
      CubicToCommand(845.7728185000002, 250.77186888000003, 811.1661510200001,
          180.85227540000002, 773.0281909400002, 171.67091464000003),
      LineToCommand(758.9030205400002, 161.07703684),
      CubicToCommand(758.9030205400002, 161.07703684, 826.7038384600002,
          93.98247744000003, 804.1035658200003, 29.006693600000034),
      CubicToCommand(804.1035658200003, 29.006693600000034, 792.0971709800002,
          19.825332840000016, 775.1469665000002, 36.069278800000035),
      CubicToCommand(775.1469665000002, 36.069278800000035, 763.8468301800002,
          44.54438104000002, 753.2529523800002, 41.719346960000024),
      CubicToCommand(753.2529523800002, 41.719346960000024, 698.8710463400002,
          43.83812252000004, 695.3397537400002, 43.83812252000004),
      CubicToCommand(691.8084611400002, 43.83812252000004, 630.3639699000003,
          -21.843919839999984, 514.5375726200002, 9.231455040000014),
      CubicToCommand(514.5375726200002, 9.231455040000014, 505.35621186000014,
          12.762747640000015, 497.5891337863002, 10.643972080000054),
      CubicToCommand(497.5891337863002, 10.643972080000054, 465.09947622000016,
          -17.60636871999995, 378.9359367800002, 22.650366920000067),
      CubicToCommand(378.9359367800002, 22.650366920000067, 361.2794737800002,
          26.181659520000068, 358.4544397000002, 26.181659520000068),
      CubicToCommand(355.62940562000017, 26.181659520000068, 350.6855959800002,
          26.181659520000068, 336.5604255800002, 37.481795840000075),
      CubicToCommand(322.4352551800002, 48.78193216000008, 321.7289966600002,
          50.19444920000009, 318.1977040600002, 53.01948328000006),
      CubicToCommand(318.1977040600002, 53.01948328000006, 289.2411047400002,
          72.79472184000008, 280.7660025000002, 74.20723888000006),
      CubicToCommand(280.7660025000002, 74.20723888000006, 260.2845054200002,
          85.50737520000007, 252.51566170000018, 103.16383820000004),
      LineToCommand(246.15933502000019, 105.28261376000006),
      CubicToCommand(246.15933502000019, 105.28261376000006, 243.3343009400002,
          117.99526712000008, 242.62804242000018, 120.11404268000007),
      CubicToCommand(242.62804242000018, 120.11404268000007, 234.1529401800002,
          126.47036936000006, 232.7404231400002, 136.3579886400001),
      CubicToCommand(232.7404231400002, 136.3579886400001, 217.20273570000018,
          146.95186644000006, 217.90899422000018, 154.72071016000007),
      CubicToCommand(217.90899422000018, 154.72071016000007, 215.0839601400002,
          163.90207092000009, 213.6714431000002, 172.37717316000007),
      CubicToCommand(213.6714431000002, 172.37717316000007, 200.9587897400002,
          180.85227540000005, 202.3713067800002, 185.7960850400001),
      CubicToCommand(202.3713067800002, 185.7960850400001, 188.9523949000002,
          210.51513324000007, 191.0711704600002, 222.52152808000008),
      CubicToCommand(191.0711704600002, 222.52152808000008, 179.77103414000018,
          221.81526956000008, 174.82722450000017, 226.05282068000008),
      CubicToCommand(174.82722450000017, 226.05282068000008, 173.4147074600002,
          234.5279229200001, 170.58967338000016, 235.23418144000007),
      CubicToCommand(170.58967338000016, 235.23418144000007, 165.64586374000018,
          237.35295700000006, 169.88341486000016, 244.41554220000006),
      CubicToCommand(169.88341486000016, 244.41554220000006, 167.05838078000016,
          249.35935184000007, 166.35212226000016, 252.18438592000007),
      CubicToCommand(166.35212226000016, 252.18438592000007, 167.76463930000014,
          257.12819556000005, 159.99579558000016, 267.0158148400001),
      CubicToCommand(159.99579558000016, 267.0158148400001, 148.69565926000016,
          300.20996528000006, 152.22695186000016, 309.3913260400001),
      CubicToCommand(152.22695186000016, 309.3913260400001, 152.93321038000016,
          317.8664282800001, 147.98940074000015, 320.69146236000006),
      CubicToCommand(147.98940074000015, 320.69146236000006, 141.63307406000015,
          319.98520384000005, 156.46450298000013, 341.17295944000006),
      CubicToCommand(156.46450298000013, 341.17295944000006, 157.87702002000015,
          343.2917350000001, 152.22695186000013, 347.52928612000005),
      CubicToCommand(152.22695186000013, 347.52928612000005, 121.85783550000014,
          353.8856128000001, 117.62028438000013, 382.84221212000006),
      CubicToCommand(117.62028438000013, 382.84221212000006, 93.60749470000013,
          408.9737773600001, 93.60749470000013, 418.15513812000006),
      CubicToCommand(93.60749470000013, 422.2249528415001, 94.08421920100014,
          427.78144174760007, 95.32017161100012, 435.9175398980001),
      CubicToCommand(95.32017161100012, 435.9175398980001, 94.31375322000014,
          450.6430300400001, 143.04559110000014, 452.0555470800001),
      CubicToCommand(191.7774289800001, 453.46806412000007, 854.1066690360002,
          396.6937073435, 854.1066690360002, 396.6937073435),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(120.79844771999998, 436.16473038000004),
      CubicToCommand(76.65729022, 366.59826616, 102.08259694, 466.18071748,
          102.08259694, 466.18071748),
      CubicToCommand(117.62028437999999, 526.9189502, 346.44804486,
          460.53064931999995, 346.44804486, 460.53064931999995),
      CubicToCommand(346.44804486, 460.53064931999995, 644.4891403,
          406.85500179999997, 664.2643788600001, 399.7924166),
      CubicToCommand(684.03961742, 392.72983139999997, 852.12914518,
          404.02996772, 852.12914518, 404.02996772),
      LineToCommand(842.2415258999999, 374.36710988000004),
      CubicToCommand(727.8276456599999, 292.44112156, 693.9272367,
          333.40411572000005, 669.91444702, 326.34153052),
      CubicToCommand(645.9016573399999, 319.27894532000005, 650.13920846,
          336.2291498, 644.4891402999999, 337.64166684),
      CubicToCommand(638.8390721399999, 339.05418388, 569.62573718,
          295.26615564, 558.3256008599999, 296.67867268000003),
      CubicToCommand(547.0254645399999, 298.09118972, 502.28398729799994,
          256.1553244487, 528.66274302, 312.21636012),
      CubicToCommand(556.9130838199999, 372.24833432, 425.54899909999995,
          381.42969508, 395.88614125999993, 361.65445652),
      CubicToCommand(366.22328342, 341.87921796, 408.59879462,
          394.14234844000003, 408.59879462, 394.14234844000003),
      CubicToCommand(441.08668653999996, 429.45527444000004, 380.34845382,
          399.7924166, 380.34845382, 399.7924166),
      CubicToCommand(319.6102211, 377.19214396000007, 277.2347099,
          422.39268924000004, 271.58464173999994, 423.80520628),
      CubicToCommand(265.93457357999995, 425.21772332, 257.45947133999994,
          430.86779148000005, 256.0469542999999, 419.56765516),
      CubicToCommand(254.63443725999994, 408.26751884, 241.37443354699997,
          378.7794599837, 185.42110229999994, 425.21772332),
      CubicToCommand(150.10817629999994, 454.5274519, 125.74225735999997,
          415.6832333, 125.74225735999997, 415.6832333),
      LineToCommand(120.79844771999996, 436.16473038000004),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(560.6385975129999, 299.7614911198),
      CubicToCommand(549.338461193, 301.1740081598, 504.544014562,
          259.25933064410003, 530.9757396729999, 315.2991785598),
      CubicToCommand(560.285468253, 377.4499283198, 427.861995753,
          384.5125135198, 398.19913791299996, 364.7372749598),
      CubicToCommand(368.53451442669996, 344.9620363998, 410.91179127299995,
          397.2251668798, 410.91179127299995, 397.2251668798),
      CubicToCommand(443.39968319299993, 432.545155465, 382.65968482669996,
          402.87523503980003, 382.65968482669996, 402.87523503980003),
      CubicToCommand(321.9214521067, 380.2749623998, 279.54594090669997,
          425.4755076798, 273.8958727467, 426.8880247198),
      CubicToCommand(268.24580458669993, 428.3005417598, 259.7707023467,
          433.957672505, 258.35818530669997, 422.65047359979997),
      CubicToCommand(256.94566826669995, 411.3503372798, 243.91696421899994,
          382.15714135559995, 187.73233330669996, 428.3005417598),
      CubicToCommand(150.23706847989993, 458.92391118699993, 126.41320295399996,
          421.0455011131, 126.41320295399996, 421.0455011131),
      LineToCommand(120.76313479399994, 438.901482145),
      CubicToCommand(76.62197729399998, 368.6216968198, 103.23026703499997,
          471.583595158, 103.23026703499997, 471.583595158),
      CubicToCommand(118.78561093799996, 532.321827878, 348.76104151299995,
          463.620530345, 348.76104151299995, 463.620530345),
      CubicToCommand(348.76104151299995, 463.620530345, 646.802136953,
          409.9378202398, 666.5773755129999, 402.8752350398),
      CubicToCommand(686.3526140729999, 395.8126498398, 852.906029552,
          406.98389397989996, 852.906029552, 406.98389397989996),
      LineToCommand(843.142005513, 376.4223221732),
      CubicToCommand(728.7281252729999, 294.4963338532, 696.240233353,
          336.4869341598, 672.2274436729999, 329.4243489598),
      CubicToCommand(648.214653993, 322.3617637598, 652.452205113,
          339.31196823979997, 646.802136953, 340.7244852798),
      CubicToCommand(641.1520687929999, 342.1370023198, 571.9387338329999,
          298.3489740798, 560.6385975129999, 299.7614911198),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(562.951594166, 302.8425439133),
      CubicToCommand(551.651457846, 304.2550609533, 507.96936838399995,
          261.8283460106, 533.2887363259999, 318.3802313533),
      CubicToCommand(561.892206386, 382.2983930596, 430.17322675969996,
          387.5953319596, 400.5103689197, 367.8200933996),
      CubicToCommand(370.8475110797, 348.0448548396, 413.2230222797,
          400.3079853196, 413.2230222797, 400.3079853196),
      CubicToCommand(445.7109141997, 435.617380027, 384.9726814797,
          405.95805347960004, 384.9726814797, 405.95805347960004),
      CubicToCommand(324.2344487597, 383.3577808396, 281.85717191339995,
          428.5583261196, 276.20710375339996, 429.9708431596),
      CubicToCommand(270.5570355934, 431.3833601996, 262.0819333534,
          437.029897067, 260.6694163134, 425.7332920396),
      CubicToCommand(259.2568992734, 414.4331557196, 246.459494891,
          385.5348227275, 190.0435643134, 431.3833601996),
      CubicToCommand(150.3641950135, 463.320370474, 127.084148548,
          426.4077689262, 127.084148548, 426.4077689262),
      LineToCommand(120.727821868, 441.62057744699996),
      CubicToCommand(78.70543992799998, 372.7639030396, 104.395593593,
          476.968816373, 104.395593593, 476.968816373),
      CubicToCommand(119.93328103299999, 537.707049093, 351.07403816600004,
          466.692754907, 351.07403816600004, 466.692754907),
      CubicToCommand(351.07403816600004, 466.692754907, 649.115133606,
          413.0206386796, 668.890372166, 405.9580534796),
      CubicToCommand(688.6656107260001, 398.8954682796, 853.665257461,
          409.9378202398, 853.665257461, 409.9378202398),
      LineToCommand(844.0424851260001, 378.4775344664),
      CubicToCommand(729.628604886, 296.5515461464, 698.553230006,
          339.5679869533, 674.5404403260001, 332.5054017533),
      CubicToCommand(650.527650646, 325.4428165533, 654.765201766,
          342.3930210333, 649.115133606, 343.8073037196),
      CubicToCommand(643.465065446, 345.2198207596, 574.251730486,
          301.4300268733, 562.9515941660001, 302.8425439133),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(565.264590819, 305.9253623531),
      CubicToCommand(553.964454499, 307.3378793931, 510.30002149999996,
          264.9058675115, 535.601732979, 321.4630497931),
      CubicToCommand(565.264590819, 387.7736622359, 431.54160264219996,
          390.0495803166, 402.8215999264, 370.9011461931),
      CubicToCommand(373.15874208639997, 351.1259076331, 415.5342532864,
          403.3890381131, 415.5342532864, 403.3890381131),
      CubicToCommand(448.0221452064, 438.70726105200004, 387.28391248639997,
          409.03910627310006, 387.28391248639997, 409.03910627310006),
      CubicToCommand(326.5456797664, 386.4388336331, 284.1701685664,
          431.644675852, 278.5201004064, 433.057192892),
      CubicToCommand(272.8700322464, 434.469709932, 264.3949300064,
          440.11977809200005, 262.9824129664, 428.8143448331),
      CubicToCommand(261.56989592639997, 417.5142085131, 249.00379120929995,
          388.91426974570004, 192.35479532009995, 434.469709932),
      CubicToCommand(150.49308719339996, 467.716829761, 127.75509414199996,
          431.768271093, 127.75509414199996, 431.768271093),
      LineToCommand(120.69250894199996, 444.35732921199997),
      CubicToCommand(82.20141960199996, 379.3762484331, 105.54326368799997,
          482.354037588, 105.54326368799997, 482.354037588),
      CubicToCommand(121.08095112799995, 543.092270308, 353.38703481899995,
          469.78263593199995, 353.38703481899995, 469.78263593199995),
      CubicToCommand(353.38703481899995, 469.78263593199995, 651.428130259,
          416.1016914731, 671.2033688189999, 409.0391062731),
      CubicToCommand(690.9786073789999, 401.9765210731, 854.4421418329999,
          412.8917464997, 854.4421418329999, 412.8917464997),
      LineToCommand(844.9429647389999, 380.5327467596),
      CubicToCommand(730.529084499, 298.60499279329997, 700.866226659,
          342.6508053931, 676.853436979, 335.5882201931),
      CubicToCommand(652.840647299, 328.5256349931, 657.078198419,
          345.4758394731, 651.428130259, 346.8883565131),
      CubicToCommand(645.778062099, 348.3008735531, 576.564727139,
          304.5128453131, 565.264590819, 305.9253623531),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(567.577587472, 309.0081807929),
      CubicToCommand(556.2774511519999, 310.42069783290003, 513.495841303,
          267.5967124727, 537.914729632, 324.5458682329),
      CubicToCommand(567.577587472, 393.75920319290003, 434.7956887731,
          393.75920319290003, 405.13283093309997, 373.9839646329),
      CubicToCommand(375.46997309309995, 354.2087260729, 417.84548429309996,
          406.4718565529, 417.84548429309996, 406.4718565529),
      CubicToCommand(450.3333762131, 441.779485614, 389.59514349309995,
          412.12192471289995, 389.59514349309995, 412.12192471289995),
      CubicToCommand(328.85691077309997, 389.5216520729, 286.48139957309996,
          434.71690041399995, 280.8313314131, 436.12941745399996),
      CubicToCommand(275.1812632531, 437.541934494, 266.7061610131,
          443.19200265399996, 265.29364397309996, 431.89186633399993),
      CubicToCommand(263.88112693309995, 420.59702695289997, 251.5480875276,
          392.2919511176, 194.66779197309998, 437.541934494),
      CubicToCommand(150.62197937329998, 472.11328904799996, 128.44369619899996,
          437.135835845, 128.44369619899996, 437.135835845),
      LineToCommand(120.67485247899995, 447.076424514),
      CubicToCommand(85.71505573899992, 385.6354645665999, 106.70859024599994,
          487.75691526599996, 106.70859024599994, 487.75691526599996),
      CubicToCommand(122.24627768599996, 548.495147986, 355.700031472,
          472.8548604939999, 355.700031472, 472.8548604939999),
      CubicToCommand(355.700031472, 472.8548604939999, 653.741126912,
          419.18450991289995, 673.516365472, 412.12192471289995),
      CubicToCommand(693.2916040319999, 405.05933951289995, 855.219026205,
          415.84567275959995, 855.219026205, 415.84567275959995),
      LineToCommand(845.843444352, 382.58619340649994),
      CubicToCommand(731.429564112, 300.66020508649996, 703.179223312,
          345.7336238329, 679.166433632, 338.6710386328999),
      CubicToCommand(655.153643952, 331.6084534329, 659.3911950720001,
          348.55865791289995, 653.741126912, 349.97117495289996),
      CubicToCommand(648.091058752, 351.3836919928999, 578.877723792,
          307.59566375289995, 567.577587472, 309.00818079289996),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(569.890584125, 312.08923358640004),
      CubicToCommand(558.5904478049999, 313.5017506264, 512.736613394,
          272.0955792451, 540.227726285, 327.6269210264),
      CubicToCommand(574.128135245, 396.1339974664, 437.10691977979997,
          396.84025598640005, 407.4440619398, 377.0650174264),
      CubicToCommand(377.7812040998, 357.2897788664, 420.1567152998,
          409.5529093464, 420.1567152998, 409.5529093464),
      CubicToCommand(452.6446072198, 444.86936663899996, 391.9063744998,
          415.2029775064, 391.9063744998, 415.2029775064),
      CubicToCommand(331.1681417798, 392.6027048664, 288.7926305798,
          437.806781439, 283.1425624198, 439.21929847900003),
      CubicToCommand(277.49249425979997, 440.631815519, 269.0173920198,
          446.281883679, 267.6048749798, 434.981747359),
      CubicToCommand(266.1923579398, 423.6780797464, 254.0906181996,
          395.66963248950003, 196.9790229798, 440.631815519),
      CubicToCommand(150.75087155319997, 476.527404798, 129.114641793,
          442.485744134, 129.114641793, 442.485744134),
      LineToCommand(120.63953955299999, 449.813176279),
      CubicToCommand(88.85790615299999, 391.1901878264, 107.85626034100002,
          493.142136481, 107.85626034100002, 493.142136481),
      CubicToCommand(123.39394778100001, 553.880369201, 358.013028125,
          475.944741519, 358.013028125, 475.944741519),
      CubicToCommand(358.013028125, 475.944741519, 656.054123565,
          422.26556270640003, 675.829362125, 415.20297750640003),
      CubicToCommand(695.6046006849999, 408.14039230640003, 855.978254114,
          418.79783337320004, 855.978254114, 418.79783337320004),
      LineToCommand(846.743923965, 384.64140569970004),
      CubicToCommand(732.330043725, 302.71541737970006, 705.492219965,
          348.8146766264, 681.479430285, 341.75209142640006),
      CubicToCommand(657.4666406050001, 334.6895062264, 661.7041917250001,
          351.6397107064, 656.054123565, 353.05222774640004),
      CubicToCommand(650.404055405, 354.46474478640005, 581.190720445,
          310.67671654640003, 569.890584125, 312.08923358640004),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(572.203580778, 315.1702863799),
      CubicToCommand(560.903444458, 316.5828034199, 514.3786644529999,
          275.5138704819, 542.540722938, 330.7079738199),
      CubicToCommand(578.559907458, 401.33559146619996, 439.41815078649995,
          399.92307442620006, 409.7552929465, 380.1478358662),
      CubicToCommand(380.0924351065, 360.3725973062, 422.4679463065,
          412.63572778620005, 422.4679463065, 412.63572778620005),
      CubicToCommand(454.95583822649996, 447.941591201, 394.2176055065,
          418.2857959462, 394.2176055065, 418.2857959462),
      CubicToCommand(333.4793727865, 395.6855233062, 291.1038615865,
          440.879006001, 285.4537934265, 442.291523041),
      CubicToCommand(279.8037252665, 443.704040081, 271.3286230265,
          449.354108241, 269.9161059865, 438.05397192099997),
      CubicToCommand(268.5035889465, 426.7608981862, 256.6331488716,
          399.04731386139997, 199.29025398649998, 443.704040081),
      CubicToCommand(150.87799808679998, 480.923864085, 129.785587387,
          447.85330888600004, 129.785587387, 447.85330888600004),
      LineToCommand(120.60422662699997, 452.53227158100003),
      CubicToCommand(92.353885827, 399.21681590620005, 109.02158689899997,
          498.545014159, 109.02158689899997, 498.545014159),
      CubicToCommand(124.55927433899998, 559.283246879, 360.308368315,
          479.016966081, 360.308368315, 479.016966081),
      CubicToCommand(360.308368315, 479.016966081, 658.349463755,
          425.34838114620004, 678.1247023149999, 418.2857959462),
      CubicToCommand(697.899940875, 411.22321074620004, 856.7374820230001,
          421.7517596331, 856.7374820230001, 421.7517596331),
      LineToCommand(847.626747115, 386.6966179929),
      CubicToCommand(733.2128668749999, 304.7706296729, 707.7875601549999,
          351.8974950662, 683.774770475, 344.8349098662),
      CubicToCommand(659.761980795, 337.7705590199, 663.999531915,
          354.72252914620003, 658.349463755, 356.1350461862),
      CubicToCommand(652.6993955949999, 357.5475632262, 583.486060635,
          313.7577693399, 572.185924315, 315.1702863799),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(574.498920968, 318.2531048197),
      CubicToCommand(563.198784648, 319.6656218597, 514.749450176,
          279.6295920072, 544.836063128, 333.7907922597),
      CubicToCommand(583.680281728, 403.7103857397, 441.7293817932,
          403.0041272197, 412.0665239532, 383.22888865970003),
      CubicToCommand(382.4036661132, 363.4536500997, 424.7791773132,
          415.7167805797, 424.7791773132, 415.7167805797),
      CubicToCommand(457.2670692332, 451.031472226, 396.5288365132,
          421.3668487397, 396.5288365132, 421.3668487397),
      CubicToCommand(335.79060379320003, 398.76657609970005, 293.41509259320003,
          443.96888702600006, 287.7650244332, 445.381404066),
      CubicToCommand(282.1149562732, 446.793921106, 273.6398540332,
          452.443989266, 272.2273369932, 441.14385294600004),
      CubicToCommand(270.8148199532, 429.8419509797, 259.1774451899,
          402.4267608796, 201.60148499320002, 446.793921106),
      CubicToCommand(151.0068902667, 485.32032337199996, 130.456532981,
          453.22087363800006, 130.456532981, 453.22087363800006),
      LineToCommand(120.56891370100001, 455.26902334600004),
      CubicToCommand(95.14360698100003, 405.1229027797, 110.16925699400002,
          503.93023537399995, 110.16925699400002, 503.93023537399995),
      CubicToCommand(125.70694443400001, 564.668468094, 362.621364968,
          482.10684710600003, 362.621364968, 482.10684710600003),
      CubicToCommand(362.621364968, 482.10684710600003, 660.662460408,
          428.42943393970006, 680.437698968, 421.3668487397),
      CubicToCommand(700.212937528, 414.30426353969995, 857.532022858,
          424.705685893, 857.532022858, 424.705685893),
      LineToCommand(848.527226728, 388.75006463980003),
      CubicToCommand(734.1133464879999, 306.8240763198, 710.100556808,
          354.97854785970003, 686.087767128, 347.91596265969997),
      CubicToCommand(662.074977448, 340.8533774597, 666.3125285680001,
          357.8035819397, 660.662460408, 359.2160989797),
      CubicToCommand(655.012392248, 360.6286160197, 585.799057288,
          316.8405877797, 574.498920968, 318.2531048197),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(576.811917621, 321.3359232595),
      CubicToCommand(565.5117813009999, 322.7484402995, 517.062446829,
          282.7106448007, 547.149059781, 336.8736106995),
      CubicToCommand(585.993278381, 406.7932041795, 444.04237844619996,
          406.0869456595, 414.37952060619995, 386.3117070995),
      CubicToCommand(384.7166627662, 366.5364685395, 427.0921739662,
          418.79959901949996, 427.0921739662, 418.79959901949996),
      CubicToCommand(459.5800658862, 454.103696788, 398.8418331662,
          424.4496671795, 398.8418331662, 424.4496671795),
      CubicToCommand(338.10183479989996, 401.8493945395, 295.72632359989996,
          447.041111588, 290.07625543989997, 448.453628628),
      CubicToCommand(284.4261872799, 449.86614566799994, 275.95108503989997,
          455.516213828, 274.53856799989995, 444.216077508),
      CubicToCommand(273.12605095989994, 432.915941188, 261.72174150819995,
          405.80444225149995, 203.91271599989997, 449.86614566799994),
      CubicToCommand(151.13578244659996, 489.71678265899993, 131.14513503799995,
          458.570781927, 131.14513503799995, 458.570781927),
      LineToCommand(120.55125723799995, 457.98811864799995),
      CubicToCommand(96.52081109499994, 411.3821189132, 111.33458355199997,
          509.333113052, 111.33458355199997, 509.333113052),
      CubicToCommand(126.87227099199995, 570.071345772, 364.93436162099994,
          485.179071668, 364.93436162099994, 485.179071668),
      CubicToCommand(364.93436162099994, 485.179071668, 662.975457061,
          431.51225237949996, 682.750695621, 424.44966717949995),
      CubicToCommand(702.5259341809999, 417.38708197949995, 858.291250767,
          427.65961215289997, 858.291250767, 427.65961215289997),
      LineToCommand(849.445362804, 390.80527693299996),
      CubicToCommand(735.013826101, 308.87928861299997, 712.413553461,
          358.0613662994999, 688.400763781, 350.9987810995),
      CubicToCommand(664.387974101, 343.9361958994999, 668.6255252210001,
          360.88640037949995, 662.975457061, 362.29891741949996),
      CubicToCommand(657.325388901, 363.71143445949997, 588.1120539409999,
          319.92340621949995, 576.811917621, 321.33592325949996),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(579.1249142739999, 324.416976053),
      CubicToCommand(567.824777954, 325.829493093, 520.064045539,
          285.41914622490003, 549.462056434, 339.954663493),
      CubicToCommand(588.306275034, 411.993032533, 446.35360945289995,
          409.167998453, 416.69075161289993, 389.392759893),
      CubicToCommand(387.0278937729, 369.617521333, 429.4034049729,
          421.880651813, 429.4034049729, 421.880651813),
      CubicToCommand(461.89129689289996, 457.193577813, 401.1530641729,
          427.53071997300003, 401.1530641729, 427.53071997300003),
      CubicToCommand(340.4148314529, 404.93044733299996, 298.0393202529,
          450.130992613, 292.38925209289994, 451.543509653),
      CubicToCommand(286.73741828659996, 452.956026693, 278.26231604659995,
          458.60609485299995, 276.84979900659994, 447.30595853299997),
      CubicToCommand(275.4372819665999, 436.005822213, 264.26427218019995,
          409.1821236234, 206.22394700659993, 452.956026693),
      CubicToCommand(151.26467462649995, 494.113241946, 131.81608063199994,
          463.938346679, 131.81608063199994, 463.938346679),
      LineToCommand(120.51594431199993, 460.72487041299996),
      CubicToCommand(97.56254241199994, 418.34935921299996, 112.48225364699994,
          514.7183342669999, 112.48225364699994, 514.7183342669999),
      CubicToCommand(128.01994108699995, 575.456566987, 367.2473582739999,
          488.26895269299996, 367.2473582739999, 488.26895269299996),
      CubicToCommand(367.2473582739999, 488.26895269299996, 665.288453714,
          434.593305173, 685.0636922739999, 427.530719973),
      CubicToCommand(704.8389308339999, 420.468134773, 859.0681351389999,
          430.6135384127999, 859.0681351389999, 430.6135384127999),
      LineToCommand(850.328185954, 392.86048922619995),
      CubicToCommand(735.914305714, 310.93273525989997, 714.7265501139999,
          361.14241909299994, 690.7137604339999, 354.07983389299994),
      CubicToCommand(666.700970754, 347.01724869299994, 670.9385218739999,
          363.96745317299997, 665.288453714, 365.379970213),
      CubicToCommand(659.6383855539999, 366.79248725299993, 590.4250505939999,
          323.004459013, 579.1249142739999, 324.416976053),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(581.437910927, 327.4980288465),
      CubicToCommand(570.137774607, 328.9105458865, 524.283940196,
          287.5167340293, 551.775053087, 343.0357162865),
      CubicToCommand(589.2067546469999, 418.60714357280006, 448.66484045959993,
          412.2508168928, 419.00198261959997, 392.4755783328),
      CubicToCommand(389.33912477959996, 372.7003397728, 431.71463597959996,
          424.9634702528, 431.71463597959996, 424.9634702528),
      CubicToCommand(464.2025278996, 460.283458838, 403.46429517959996,
          430.61353841280004, 403.46429517959996, 430.61353841280004),
      CubicToCommand(342.7260624596, 408.0132657728, 300.35055125959997,
          453.22087363800006, 294.7004830996, 454.633390678),
      CubicToCommand(289.05041493959993, 456.04590771799997, 280.5753126996,
          461.695975878, 279.16279565959996, 450.39583955800003),
      CubicToCommand(277.75027861959995, 439.095703238, 266.80856849849994,
          412.56157064160004, 208.53694365959996, 456.04590771799997),
      CubicToCommand(151.39180116009993, 498.509701233, 132.48702622599995,
          469.28825496800005, 132.48702622599995, 469.28825496800005),
      LineToCommand(120.48063138599994, 463.46162217799997),
      CubicToCommand(97.88035874599996, 422.49156543280003, 113.64758020499994,
          520.121211945, 113.64758020499994, 520.121211945),
      CubicToCommand(129.18526764499993, 580.8594446650001, 369.56035492699993,
          491.358833718, 369.56035492699993, 491.358833718),
      CubicToCommand(369.56035492699993, 491.358833718, 667.6014503669999,
          437.68318619800004, 687.3766889269999, 430.61353841280004),
      CubicToCommand(707.151927487, 423.55095321280004, 859.8273630479999,
          433.56923031900004, 859.8273630479999, 433.56923031900004),
      LineToCommand(851.2286655669999, 394.91393587310006),
      CubicToCommand(736.814785327, 312.98794755310007, 717.0395467669999,
          364.22523753280007, 693.026757087, 357.16265233280006),
      CubicToCommand(669.0139674069999, 350.0983014865001, 673.2515185269999,
          367.05027161280003, 667.6014503669999, 368.46278865280004),
      CubicToCommand(661.9513822069998, 369.8753056928001, 592.7380472469999,
          326.08551180650005, 581.4379109269998, 327.49802884650006),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(120.44531845999998, 466.18071748),
      CubicToCommand(97.84504582, 427.33649888, 114.79525029999996,
          525.50643316, 114.79525029999996, 525.50643316),
      CubicToCommand(130.33293773999998, 586.24466588, 371.87335157999996,
          494.43105828, 371.87335157999996, 494.43105828),
      CubicToCommand(371.87335157999996, 494.43105828, 669.91444702,
          440.75541076, 689.68968558, 433.69282555999996),
      CubicToCommand(709.46492414, 426.63024036, 860.60424742, 436.51785964,
          860.60424742, 436.51785964),
      LineToCommand(852.1291451799999, 396.96738252),
      CubicToCommand(737.7152649399999, 315.04139419999996, 719.35254342,
          367.30452468, 695.3397537399999, 360.24193948),
      CubicToCommand(671.3269640599999, 353.17935428, 675.56451518,
          370.12955875999995, 669.9144470199999, 371.54207579999996),
      CubicToCommand(664.2643788599999, 372.95459284000003, 595.0510438999999,
          329.1665646, 583.7509075799999, 330.57908163999997),
      CubicToCommand(572.45077126, 331.99159868, 527.9211715739999,
          289.95685721589996, 554.0880497399999, 346.11676908),
      CubicToCommand(593.338366989, 430.3504571141, 446.8091461982999,
          412.5527424101, 421.3114479799999, 395.55486548),
      CubicToCommand(391.6485901399999, 375.77962691999994, 434.0241013399999,
          428.0427573999999, 434.0241013399999, 428.0427573999999),
      CubicToCommand(466.51199325999994, 463.3556834, 405.7737605399999,
          433.69282555999996, 405.7737605399999, 433.69282555999996),
      CubicToCommand(345.0355278199999, 411.09255292, 302.6600166199999,
          456.2930981999999, 297.0099484599999, 457.70561523999993),
      CubicToCommand(291.3598802999999, 459.11813227999994, 282.8847780599999,
          464.76820044, 281.4722610199999, 453.46806411999995),
      CubicToCommand(280.0597439799999, 442.1679277999999, 269.3510991704999,
          415.93748636719994, 210.8464090199999, 459.11813227999994),
      CubicToCommand(151.5206933399999, 502.90616051999996, 133.1579718199999,
          474.65581971999995, 133.1579718199999, 474.65581971999995),
      LineToCommand(120.44531845999987, 466.18071747999994),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(193.89620453999999, 519.15010648),
      CubicToCommand(193.89620453999999, 519.15010648, 181.18355117999997,
          539.63160356, 217.90899421999995, 562.93813472),
      CubicToCommand(217.90899421999995, 562.93813472, 220.38089903999997,
          565.4100395400001, 188.59926563999997, 557.99432508),
      CubicToCommand(188.59926563999997, 557.99432508, 177.65225857999997,
          554.46303248, 174.82722449999997, 536.10031096),
      CubicToCommand(174.82722449999997, 536.10031096, 166.35212226,
          528.3314672399999, 157.87702001999997, 518.44384796),
      CubicToCommand(149.40191778, 508.55622868, 193.89620453999999,
          519.15010648, 193.89620453999999, 519.15010648),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(441.08668653999996, 435.1053426),
      CubicToCommand(441.08668653999996, 435.1053426, 472.33509475739993,
          482.459976366, 471.27923826999995, 490.89976568),
      CubicToCommand(468.98389808, 509.2624872, 468.63076881999996,
          526.21269168, 474.28083698, 533.27527688),
      CubicToCommand(479.9326707863, 540.33786208, 495.4703582263,
          598.9573192400001, 495.4703582263, 598.9573192400001),
      CubicToCommand(495.4703582263, 598.9573192400001, 494.7640997063,
          601.0760948, 516.65634818, 533.9815354),
      CubicToCommand(516.65634818, 533.9815354, 537.13784526, 505.7311946,
          501.82491926, 473.24330268),
      CubicToCommand(501.82491926, 473.24330268, 439.67416949999995,
          422.39268924, 441.08668654, 435.1053426),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(229.20913054, 566.46942732),
      CubicToCommand(229.20913054, 566.46942732, 248.98436909999998,
          579.18208068, 223.55906237999997, 634.27024524),
      LineToCommand(234.85919869999998, 630.03269412),
      CubicToCommand(234.85919869999998, 630.03269412, 233.44668165999997,
          649.80793268, 227.79661349999998, 654.0454838),
      LineToCommand(240.50926685999997, 648.39541564),
      CubicToCommand(240.50926685999997, 648.39541564, 248.98436909999998,
          662.52058604, 241.92178389999998, 670.9956882800001),
      CubicToCommand(241.92178389999998, 670.9956882800001, 271.58464173999994,
          685.1208586800001, 270.1721247, 696.4209950000001),
      CubicToCommand(270.1721247, 696.4209950000001, 281.47226101999996,
          682.2958246000001, 274.40967581999996, 670.9956882800001),
      CubicToCommand(267.34709061999996, 659.69555196, 254.63443725999997,
          666.75813716, 256.0469543, 634.27024524),
      LineToCommand(240.50926685999997, 639.9203134),
      CubicToCommand(240.50926685999997, 639.9203134, 250.39688613999996,
          624.38262596, 250.39688613999996, 613.0824896400001),
      LineToCommand(236.27171573999996, 617.32004076),
      CubicToCommand(236.27171573999996, 617.32004076, 263.5844983547,
          570.389162106, 244.74681797999995, 567.88194436),
      CubicToCommand(234.15294017999997, 566.46942732, 229.20913053999993,
          566.46942732, 229.20913053999993, 566.46942732),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(286.41607065999995, 596.13228516),
      CubicToCommand(286.41607065999995, 596.13228516, 291.3598803,
          588.36344144, 286.41607065999995, 589.77595848),
      CubicToCommand(281.47226101999996, 591.18847552, 226.38409645999997,
          617.32004076, 215.79021866, 634.27024524),
      CubicToCommand(215.79021866, 634.27024524, 276.52845138, 591.18847552,
          286.41607066, 596.13228516),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(304.77879218, 610.25745556),
      CubicToCommand(304.77879218, 610.25745556, 309.72260181999997,
          602.48861184, 304.77879218, 603.90112888),
      CubicToCommand(299.83498254, 605.31364592, 244.74681797999997,
          631.44521116, 234.15294017999997, 648.39541564),
      CubicToCommand(234.15294017999997, 648.39541564, 294.89117289999996,
          605.31364592, 304.77879218, 610.25745556),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(328.08532334, 583.4196318),
      CubicToCommand(328.08532334, 583.4196318, 333.02913298, 575.65078808,
          328.08532334, 577.06330512),
      CubicToCommand(323.14151369999996, 578.47582216, 268.05334913999997,
          604.6073874, 257.45947133999994, 621.55759188),
      CubicToCommand(257.45947133999994, 621.55759188, 318.19770406,
          578.47582216, 328.08532333999995, 583.4196318),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(287.12232917999995, 660.40181048),
      CubicToCommand(287.12232917999995, 660.40181048, 287.12232917999995,
          649.80793268, 282.17851953999997, 651.22044972),
      CubicToCommand(277.2347099, 652.63296676, 213.67144309999998,
          683.7083416400001, 203.07756529999997, 700.65854612),
      CubicToCommand(203.07756529999997, 700.65854612, 277.2347099,
          655.4580008400001, 287.12232917999995, 660.40181048),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(289.24110473999997, 641.3328304400001),
      CubicToCommand(289.24110473999997, 641.3328304400001, 291.3598803,
          632.8577282, 286.41607065999995, 634.27024524),
      CubicToCommand(282.88477806, 634.27024524, 236.27171574,
          654.7517423200001, 225.67783793999996, 671.7019468),
      CubicToCommand(225.67783793999996, 671.7019468, 277.94096842,
          633.56398672, 289.24110473999997, 641.3328304400001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(263.81579802, 725.37759432),
      LineToCommand(246.15933501999996, 738.7965062),
      CubicToCommand(246.15933501999996, 738.7965062, 264.52205654,
          725.37759432, 270.87838322, 727.4963698800001),
      CubicToCommand(270.87838322, 727.4963698800001, 258.87198837999995,
          747.27160844, 257.45947133999994, 756.4529692),
      CubicToCommand(257.45947133999994, 756.4529692, 275.82219286,
          733.85269656, 285.70981213999994, 734.55895508),
      CubicToCommand(285.70981213999994, 734.55895508, 299.12872402,
          735.2652136, 299.12872402, 754.3341936400001),
      CubicToCommand(299.12872402, 754.3341936400001, 309.01634329999996,
          735.97147212, 314.66641145999995, 736.67773064),
      CubicToCommand(314.66641145999995, 736.67773064, 316.78518701999997,
          747.97786696, 314.66641145999995, 759.9842618),
      CubicToCommand(314.66641145999995, 759.9842618, 321.72899665999995,
          746.56534992, 328.79158185999995, 749.390384),
      CubicToCommand(328.79158185999995, 749.390384, 340.09171818, 745.8590914,
          338.67920114, 766.3405884800001),
      CubicToCommand(338.67920114, 766.3405884800001, 338.67920114, 784.70331,
          337.26668409999996, 789.64711964),
      CubicToCommand(337.26668409999996, 789.64711964, 347.15430338,
          743.0340573200001, 351.39185449999997, 742.3277988),
      CubicToCommand(351.39185449999997, 742.3277988, 365.51702489999997,
          740.2090232400001, 373.99212714, 755.7467106800001),
      CubicToCommand(373.99212714, 755.7467106800001, 366.92954194, 742.3277988,
          375.40464418, 745.8590914),
      CubicToCommand(375.40464418, 745.8590914, 394.47362422, 748.68412548,
          400.12369237999997, 760.69052032),
      CubicToCommand(400.12369237999997, 760.69052032, 388.11729754,
          739.50276472, 398.00491681999995, 745.1528328799999),
      LineToCommand(412.13008721999995, 756.4529691999999),
      CubicToCommand(412.13008721999995, 756.4529691999999, 426.96151613999996,
          793.8846707599998, 430.49280874, 796.7097048399999),
      CubicToCommand(430.49280874, 796.7097048399999, 417.07389686,
          758.5717447599999, 419.89893093999996, 758.5717447599999),
      CubicToCommand(419.89893093999996, 758.5717447599999, 416.36763834,
          737.3839891599999, 425.54899909999995, 763.5155543999999),
      CubicToCommand(425.54899909999995, 763.5155543999999, 419.89893093999996,
          738.7965062, 429.78655022, 740.20902324),
      CubicToCommand(439.67416949999995, 741.62154028, 447.44301321999995,
          759.2780032799999, 462.2744421399999, 755.0404521599999),
      CubicToCommand(462.2744421399999, 755.0404521599999, 479.2264122662999,
          764.9280714399999, 482.75770486629995, 642.7453474799999),
      LineToCommand(263.8175636663, 725.3775943199998),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(272.29090025999994, 561.52561768),
      CubicToCommand(272.29090025999994, 561.52561768, 298.4224655,
          550.93173988, 369.04831749999994, 561.52561768),
      CubicToCommand(369.04831749999994, 561.52561768, 381.76097086,
          562.2318762, 393.76736569999997, 546.69418876),
      CubicToCommand(405.77376054, 531.15650132, 453.09308137999994,
          518.44384796, 464.3932177, 521.97514056),
      LineToCommand(481.34518782629993, 533.27527688),
      LineToCommand(482.75770486629995, 535.39405244),
      CubicToCommand(482.75770486629995, 535.39405244, 504.64995333999997,
          553.75677396, 505.3562118599999, 567.17568584),
      CubicToCommand(506.0624703799999, 580.5945977199999, 479.9326707862999,
          665.3456201199999, 462.98070065999997, 693.5959609199999),
      CubicToCommand(446.03049618, 721.8463017199999, 429.0802917,
          743.7403158399999, 395.1798827399999, 739.50276472),
      CubicToCommand(395.1798827399999, 739.50276472, 358.45443969999997,
          732.44017952, 313.25389441999994, 739.50276472),
      CubicToCommand(313.25389441999994, 739.50276472, 261.69702245999997,
          736.6777306399999, 256.75321281999993, 722.5525602399999),
      CubicToCommand(251.80940317999995, 708.4273898399999, 276.52845138,
          681.5895660799999, 276.52845138, 681.5895660799999),
      CubicToCommand(276.52845138, 681.5895660799999, 284.2972951,
          666.7581371599999, 282.17851953999997, 641.33283044),
      CubicToCommand(280.05974397999995, 615.90752372, 280.76600249999996,
          566.4694273199999, 272.29090025999994, 561.52561768),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(311.13511886, 565.05691028),
      CubicToCommand(325.96654778, 597.5448022, 273.70341729999996,
          712.66494096, 273.70341729999996, 712.66494096),
      CubicToCommand(270.1721247, 715.48997504, 296.05649945799996,
          726.172135155, 313.96015294, 721.8463017199999),
      CubicToCommand(333.28691733979997, 717.184995488, 404.3612435,
          724.6713358, 404.3612435, 724.6713358),
      CubicToCommand(446.03049618, 697.1272535200001, 468.63076881999996,
          618.7325578, 468.63076881999996, 618.7325578),
      CubicToCommand(468.63076881999996, 618.7325578, 486.9952559863,
          576.3570466, 455.91811545999997, 570.7069784400001),
      CubicToCommand(424.84274058, 565.05691028, 311.13511886, 565.05691028,
          311.13511886, 565.05691028),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(307.54909122469996, 619.61538095),
      CubicToCommand(313.4216308185, 597.032764773, 316.2184145577,
          576.198138433, 311.13511886, 565.05691028),
      CubicToCommand(311.13511886, 565.05691028, 421.31144797999997,
          576.3570466, 441.08668653999996, 539.63160356),
      CubicToCommand(448.5747924983, 525.735967179, 474.6357318863, 579.8883392,
          473.92770771999994, 596.83854368),
      CubicToCommand(473.92770771999994, 596.83854368, 362.69199082,
          622.2638504, 336.56042558, 602.48861184),
      LineToCommand(307.54909122469996, 619.6153809499999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(315.37266997999996, 648.39541564),
      CubicToCommand(315.37266997999996, 648.39541564, 318.90396258, 661.108069,
          314.66641145999995, 668.1706542000001),
      CubicToCommand(314.66641145999995, 668.1706542000001, 311.84137738,
          669.5831712400001, 309.72260181999997, 670.28942976),
      CubicToCommand(309.72260181999997, 670.28942976, 311.84137738,
          676.64575644, 322.43525517999996, 679.4707905199999),
      CubicToCommand(322.43525517999996, 679.4707905199999, 325.96654778,
          687.23963424, 330.20409889999996, 687.94589276),
      CubicToCommand(334.44165002, 688.65215128, 342.91675225999995,
          698.53977056, 349.97933745999995, 696.4209950000001),
      CubicToCommand(357.04192265999995, 694.30221944, 376.81716122,
          687.23963424, 376.81716122, 687.23963424),
      CubicToCommand(376.81716122, 687.23963424, 386.70478049999997,
          681.58956608, 402.24246794, 687.94589276),
      CubicToCommand(402.24246794, 687.94589276, 406.43587790249995,
          686.53337572, 407.18627757999997, 679.47079052),
      CubicToCommand(408.06910072999995, 671.17225291, 413.54260425999996,
          664.6393616, 417.07389686, 661.108069),
      CubicToCommand(420.60518945999996, 657.5767764, 437.55539394,
          634.97650376, 435.43661837999997, 634.27024524),
      CubicToCommand(433.31784281999995, 633.5639867200001, 315.37266997999996,
          648.39541564, 315.37266997999996, 648.39541564),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(307.60382625999995, 562.93813472),
      CubicToCommand(307.60382625999995, 562.93813472, 302.66001661999996,
          602.48861184, 308.31008477999995, 617.32004076),
      CubicToCommand(313.96015294, 632.15146968, 312.5476359, 635.68276228,
          311.13511886, 642.7453474800001),
      CubicToCommand(309.72260181999997, 649.80793268, 317.49144554,
          667.46439568, 327.37906482, 678.05827348),
      LineToCommand(348.56682042, 680.88330756),
      CubicToCommand(348.56682042, 680.88330756, 375.40464418, 674.52698088,
          391.64859013999995, 679.47079052),
      CubicToCommand(391.64859013999995, 679.47079052, 407.52881296219994,
          681.836756562, 413.54260425999996, 655.4580008400001),
      CubicToCommand(413.54260425999996, 655.4580008400001, 422.0177065,
          644.15786452, 434.73035985999996, 639.21405488),
      CubicToCommand(447.44301322, 634.2702452400001, 460.15566658,
          560.8193591600001, 453.09308137999994, 546.6941887600001),
      CubicToCommand(446.03049618, 532.5690183600001, 420.60518945999996,
          524.80017464, 392.35484865999996, 552.34425692),
      CubicToCommand(364.10450785999996, 579.8883392, 360.57321526,
          550.22548136, 307.60382625999995, 562.93813472),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(310.42886033999997, 695.0084779599999),
      CubicToCommand(310.42886033999997, 695.0084779599999, 309.01634329999996,
          691.47718536, 301.24749957999995, 690.77092684),
      CubicToCommand(301.24749957999995, 690.77092684, 261.69702245999997,
          684.41460016, 246.86559353999996, 662.52058604),
      CubicToCommand(246.86559353999996, 662.52058604, 234.85919869999998,
          652.6329667599999, 242.62804241999999, 673.11446384),
      CubicToCommand(242.62804241999999, 673.11446384, 260.99076393999997,
          709.1336483599999, 272.99715877999995, 714.077458),
      CubicToCommand(272.99715877999995, 714.077458, 301.95375809999996,
          721.1400432, 310.42886033999997, 695.0084779599999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(451.57815685459997, 582.060084149),
      CubicToCommand(452.7417177663, 568.093821916, 456.19002499019996,
          552.891607273, 453.09308138, 546.69418876),
      CubicToCommand(441.7117253302, 523.935007953, 411.74341068030003,
          533.45184151, 392.35484866, 552.34425692),
      CubicToCommand(364.10450786, 579.8883391999999, 360.57321526,
          550.22548136, 307.60382626, 562.93813472),
      CubicToCommand(307.60382626, 562.93813472, 304.5227734665,
          587.5865570679999, 306.0059163585, 605.2783329939999),
      CubicToCommand(306.0059163585, 605.2783329939999, 371.87335157999996,
          584.83214884, 373.28586862, 594.7197681199999),
      CubicToCommand(373.28586862, 594.7197681199999, 376.1109027, 589.06969996,
          392.35484866, 589.06969996),
      CubicToCommand(408.59879462, 589.06969996, 448.7531227746, 587.003893789,
          451.57815685459997, 582.060084149),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(375.40464418, 564.35065176),
      CubicToCommand(375.40464418, 564.35065176, 383.87974641999995, 572.825754,
          377.52341974, 589.77595848),
      CubicToCommand(377.52341974, 589.77595848, 352.09811301999997,
          618.02629928, 355.62940562, 642.74534748)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(290.65362178, 714.077458),
      CubicToCommand(290.65362178, 714.077458, 282.88477806, 691.47718536,
          298.4224655, 703.4835802),
      LineToCommand(304.77879218, 709.8399068800001),
      CubicToCommand(302.66001661999996, 712.6649409600001, 292.77239734,
          719.7275261600001, 290.65362178, 714.077458),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(299.552479132, 716.19623356),
      CubicToCommand(299.552479132, 716.19623356, 293.337404156, 698.116015448,
          305.76755410799996, 707.7211313199999),
      LineToCommand(310.85261545199995, 712.8061926639999),
      CubicToCommand(302.801268324, 715.0662199279999, 310.85261545199995,
          719.586274456, 299.552479132, 716.19623356),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(308.027581372, 716.19623356),
      CubicToCommand(308.027581372, 716.19623356, 301.812506396, 698.116015448,
          314.24265634799997, 707.7211313199999),
      LineToCommand(319.32771769199996, 712.8061926639999),
      CubicToCommand(313.39514612399995, 715.0662199279999, 319.32771769199996,
          719.586274456, 308.027581372, 716.19623356),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(319.68084695199997, 716.5493628199999),
      CubicToCommand(319.68084695199997, 716.5493628199999, 313.465771976,
          698.4691447079999, 325.89592192799995, 708.07426058),
      CubicToCommand(325.89592192799995, 708.07426058, 333.63474966089996,
          712.1882164589999, 330.9827489183, 713.159321924),
      CubicToCommand(325.754670224, 715.0662199279999, 330.9827489183,
          719.9394037159999, 319.68084695199997, 716.5493628199999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(331.12223497599996, 716.408111116),
      CubicToCommand(331.12223497599996, 716.408111116, 324.90716,
          698.327893004, 337.3390755983, 707.933008876),
      LineToCommand(342.4241369423, 713.0180702199999),
      CubicToCommand(340.7291164943, 715.2780974839999, 342.4241369423,
          719.798152012, 331.12223497599996, 716.408111116),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(342.91675225999995, 717.6087506),
      CubicToCommand(342.91675225999995, 717.6087506, 334.44165002,
          695.7147364799999, 350.68559597999996, 707.0148728),
      LineToCommand(357.04192265999995, 713.3711994800001),
      CubicToCommand(354.9231471, 716.1962335600001, 357.04192265999995,
          721.84630172, 342.91675225999995, 717.6087506),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(292.77239734, 687.23963424),
      CubicToCommand(292.77239734, 687.23963424, 316.07892849999996,
          682.2958246000001, 326.6728063, 687.94589276),
      CubicToCommand(326.6728063, 687.94589276, 337.26668409999996,
          690.06466832, 339.38545966, 689.3584098),
      CubicToCommand(341.50423522, 688.6521512800001, 347.15430338,
          687.94589276, 347.15430338, 687.94589276)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(352.80437154, 702.77732168),
      CubicToCommand(352.80437154, 702.77732168, 373.99212714, 678.764532,
          395.17988274, 686.53337572),
      CubicToCommand(407.5676571808, 691.071086711, 405.77376053999996,
          685.12085868, 407.18627757999997, 680.17704904),
      CubicToCommand(408.59879462, 675.2332394, 408.95192388, 667.81752494,
          417.78015538, 662.52058604)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(383.1734879, 674.52698088),
      CubicToCommand(383.1734879, 674.52698088, 376.1109027, 655.45800084,
          371.16709305999996, 678.05827348),
      CubicToCommand(366.22328342, 700.65854612, 360.57321526, 707.0148728,
          357.74818117999996, 711.9586824400001),
      CubicToCommand(357.74818117999996, 711.9586824400001, 357.74818117999996,
          721.1400432, 372.57961009999997, 720.43378468),
      CubicToCommand(372.57961009999997, 720.43378468, 391.64859013999995,
          719.7275261600001, 392.35484866, 714.7837165200001),
      CubicToCommand(393.06110718, 709.8399068800001, 390.2360731, 689.3584098,
          383.1734879, 674.52698088),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(407.8925361, 687.23963424),
      CubicToCommand(407.8925361, 687.23963424, 414.24886277999997,
          683.0020831200001, 418.4864139, 685.1208586800001)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(419.36923705, 658.28303492),
      CubicToCommand(419.36923705, 658.28303492, 424.48961132, 649.63136805,
          432.96471355999995, 648.21885101)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(279.35348546, 723.2588187599999),
      CubicToCommand(279.35348546, 723.2588187599999, 311.13511886,
          728.90888692, 318.90396258, 726.0838528400001),
      LineToCommand(319.6102211, 729.61514544),
      LineToCommand(282.88477806, 727.4963698800001),
      CubicToCommand(282.88477806, 727.4963698800001, 262.40328098, 717.6087506,
          279.35348545999994, 723.25881876),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(304.07253366, 558.7005836),
      LineToCommand(338.67920114, 560.11310064),
      CubicToCommand(338.67920114, 560.11310064, 351.39185449999997,
          614.4950066800001, 345.03552781999997, 627.9139185600001),
      CubicToCommand(345.03552781999997, 627.9139185600001, 342.91675225999995,
          632.8577282000001, 337.97294261999997, 622.97010892),
      CubicToCommand(337.97294261999997, 622.97010892, 305.4850507,
          565.05691028, 299.83498254, 561.5256176800001),
      CubicToCommand(294.18491437999995, 557.9943250800001, 301.95375809999996,
          558.7005836000001, 304.07253366, 558.7005836000001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(167.94120392999997, 553.9333385900001),
      CubicToCommand(167.94120392999997, 553.9333385900001, 183.655456,
          556.9349373, 205.90259937999997, 561.5256176800001),
      CubicToCommand(205.90259937999997, 561.5256176800001, 214.37770161999998,
          601.0760948000001, 220.02776977999997, 609.55119704),
      CubicToCommand(225.67783793999996, 618.02629928, 219.32151125999997,
          618.0262992800001, 212.96518457999997, 613.0824896400001),
      CubicToCommand(206.60885789999998, 608.13868, 180.47729265999996,
          583.4196318, 176.94600005999996, 575.6507880800001),
      CubicToCommand(173.41470745999996, 567.88194436, 167.94120392999997,
          553.9333385900001, 167.94120392999997, 553.9333385900001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(206.53999769429998, 561.914059866),
      CubicToCommand(206.53999769429998, 561.914059866, 216.78074623429995,
          564.650811631, 218.56228335099996, 568.552889954),
      CubicToCommand(220.34205482139998, 572.47262474, 216.43997649839997,
          578.281601067, 216.43997649839997, 578.281601067),
      CubicToCommand(216.43997649839997, 578.281601067, 214.67433019839996,
          584.1258903199999, 212.55202334579997, 580.312094312),
      CubicToCommand(210.42971649319998, 576.480641841, 205.3587803196,
          562.955791183, 206.53999769429998, 561.914059866),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(206.60885789999998, 561.52561768),
      CubicToCommand(206.60885789999998, 561.52561768, 212.96518457999997,
          570.70697844, 219.32151125999997, 570.70697844),
      CubicToCommand(225.67783794, 570.70697844, 226.35231482659998,
          569.983063457, 231.32790609999998, 571.0601077),
      CubicToCommand(239.44987907999996, 572.825754, 238.74362055999998,
          569.2944613999999, 250.39688614, 571.41323696),
      CubicToCommand(255.05819237199995, 572.2607471839999, 259.57824689999995,
          570.70697844, 264.52205654, 572.825754),
      CubicToCommand(269.46586618, 574.94452956, 275.11593433999997,
          573.53201252, 277.2347099, 570.0007199199999),
      CubicToCommand(279.35348545999994, 566.46942732, 287.82858769999996,
          559.05371286, 287.82858769999996, 559.05371286),
      CubicToCommand(287.82858769999996, 559.05371286, 265.22831506,
          562.2318762, 260.28450541999996, 563.64439324),
      CubicToCommand(260.28450541999996, 563.64439324, 220.73402829999998,
          565.7631687999999, 206.60885789999998, 561.52561768),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(285.35668288, 561.87874694),
      CubicToCommand(285.35668288, 561.87874694, 273.968264245,
          568.0585089900001, 273.262005725, 572.29606011),
      CubicToCommand(272.555747205, 576.53361123, 282.53164879999997,
          583.06650254, 282.53164879999997, 583.06650254),
      CubicToCommand(282.53164879999997, 583.06650254, 287.387176125,
          591.18847552, 288.44656390499995, 586.9509244),
      CubicToCommand(289.50595168499996, 582.71337328, 286.76919992,
          562.5850054599999, 285.35668288, 561.87874694),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(219.17143132449996, 571.519175738),
      CubicToCommand(219.17143132449996, 571.519175738, 231.54331494859997,
          591.276757835, 231.92646019569997, 571.483862812),
      CubicToCommand(231.92646019569997, 571.483862812, 232.9099251848,
          569.259148474, 229.80238769679997, 569.223835548),
      CubicToCommand(219.07608642429994, 569.100240307, 221.76163444659997,
          561.843434014, 219.17143132449996, 571.519175738),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(231.84524046589996, 571.960587313),
      CubicToCommand(231.84524046589996, 571.960587313, 245.83092480819997,
          591.71816941, 244.70797376139998, 571.801679146),
      CubicToCommand(244.70797376139998, 571.801679146, 244.72033328549998,
          571.2190158669999, 241.62515532159998, 570.954168922),
      CubicToCommand(233.24363233549997, 570.212597476, 233.85278030899997,
          562.2318762, 231.84524046589996, 571.960587313),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(244.58084722779998, 571.978243776),
      CubicToCommand(244.58084722779998, 571.978243776, 258.6353917758,
          590.747063945, 257.4541744011, 573.673264224),
      CubicToCommand(257.4541744011, 573.673264224, 257.6642863108,
          571.5015192750001, 254.7439073306, 570.971825385),
      CubicToCommand(247.87201193099997, 569.718216512, 247.49946056169998,
          563.9975225000001, 244.58084722779998, 571.978243776),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(256.72143118659994, 572.11949548),
      CubicToCommand(256.72143118659994, 572.11949548, 270.6700369566,
          592.530366708, 271.284481869, 575.262345894),
      CubicToCommand(271.284481869, 575.262345894, 274.18720438619994,
          572.825754, 271.1043859464, 572.437311814),
      CubicToCommand(260.831855773, 571.130733552, 262.24084152039995,
          563.273607517, 256.72143118659994, 572.11949548),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(192.85094193039998, 578.352226919),
      LineToCommand(179.32962256499997, 575.65078808),
      CubicToCommand(174.73894218499998, 566.82255658, 171.03108495499995,
          555.963831835, 171.03108495499995, 555.963831835),
      CubicToCommand(171.03108495499995, 555.963831835, 182.24293895999995,
          557.729478135, 204.31351770999996, 562.6732877750001),
      CubicToCommand(204.31351770999996, 562.6732877750001, 205.86022386879995,
          568.535233491, 208.45925522239997, 578.758325568),
      LineToCommand(192.85094193039996, 578.352226919),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(307.73801537879996, 570.124315161),
      CubicToCommand(304.79644864299996, 565.692542948, 302.47109246589997,
          562.602661923, 301.32342237089995, 561.87874694),
      CubicToCommand(296.00353006899996, 558.559331896, 303.3186026899,
          559.2126210270001, 305.3120173626, 559.2126210270001),
      LineToCommand(337.8952541828, 560.554512215),
      CubicToCommand(337.8952541828, 560.554512215, 338.820452844,
          564.509559927, 340.02815491319996, 570.4951008840001),
      CubicToCommand(340.02815491319996, 570.4951008840001, 322.21631503879996,
          566.9461518210001, 307.73801537879996, 570.124315161),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(402.383719644, 326.2020444623),
      CubicToCommand(451.3292007263, 333.1940038103, 496.3884943023,
          270.2663696783, 499.4960317903, 253.173147848),
      CubicToCommand(502.601803632, 236.081691664, 484.7352287223, 215.10581362,
          484.7352287223, 215.10581362),
      CubicToCommand(487.06588183829996, 209.667623016, 478.5201537463,
          184.807323112, 469.1975412823, 168.4927513),
      CubicToCommand(459.87492881829996, 152.178179488, 431.799387002,
          153.8979189842, 400.8299509, 152.178179488),
      CubicToCommand(372.862113508, 150.624410744, 340.232969884, 191.79928246,
          337.902316768, 194.906819948),
      CubicToCommand(335.571663652, 198.01435743599998, 346.44804486,
          265.6050634463, 348.778697976, 275.7045602823),
      CubicToCommand(351.109351092, 285.8040571183, 346.44804486,
          332.4171194383, 346.44804486, 332.4171194383),
      CubicToCommand(406.903774172, 316.3497381083, 353.440004208,
          319.2100851143, 402.38371964399994, 326.2020444623),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(339.1877072744, 196.0509587504),
      CubicToCommand(336.89942966959995, 199.1019955568, 347.57805849199997,
          265.4638117423, 349.86633609679996, 275.3796813631),
      CubicToCommand(352.1546137016, 285.2955509839, 347.57805849199997,
          331.0611030799, 347.57805849199997, 331.0611030799),
      CubicToCommand(405.2652544056, 315.3821639359, 354.4428913064,
          318.0941966527, 402.4967210072, 324.9590294671),
      CubicToCommand(450.5523163543, 331.8238622815, 494.7923500471,
          270.0403669519, 497.84338685349996, 253.2578988704),
      CubicToCommand(500.8944236599, 236.4771964352, 483.35096202309995,
          215.882697992, 483.35096202309995, 215.882697992),
      CubicToCommand(485.6392396279, 210.5433835808, 477.24888841029997,
          186.1350891296, 468.09577799109996, 170.117145896),
      CubicToCommand(458.94266757189996, 154.0992026624, 431.3791631826,
          155.7889261715, 400.9712026039999, 154.0992026624),
      CubicToCommand(373.51187134639997, 152.5736842592, 341.4759848792,
          192.999921944, 339.18770727439994, 196.0509587504),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(340.4730977808, 197.1950975528),
      CubicToCommand(338.2271956872, 200.1896336776, 348.70807212399995,
          265.3225600383, 350.9539742176, 275.05480244390003),
      CubicToCommand(353.1998763112, 284.78704484950003, 348.70807212399995,
          329.70508672150004, 348.70807212399995, 329.70508672150004),
      CubicToCommand(404.15642852919996, 313.53176661350005, 355.44577840479997,
          316.97830819110004, 402.60972237039994, 323.7160144719),
      CubicToCommand(449.7754319823, 330.4537207527, 493.19620579189996,
          269.8143642255, 496.19074191669995, 253.3426498928),
      CubicToCommand(499.18527804149994, 236.87270120640002, 481.96669532389996,
          216.65958236400002, 481.96669532389996, 216.65958236400002),
      CubicToCommand(484.2125974175, 211.4191441456, 475.97762307429997,
          187.4628551472, 466.99401469989994, 171.741540492),
      CubicToCommand(458.01040632549996, 156.02022583680002, 430.95717371689994,
          157.6781677125, 401.11245430799994, 156.02022583680002),
      CubicToCommand(374.16162918479995, 154.52295777440003, 342.71899987439997,
          194.20056142800001, 340.47309778079995, 197.1950975528),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(341.75848828719995, 198.3392363552),
      CubicToCommand(339.5549617048, 201.27727179840002, 349.838085756,
          265.1813083343, 352.0416123384, 274.7299235247),
      CubicToCommand(354.24513892079995, 284.2785387151, 349.838085756,
          328.3490703631, 349.838085756, 328.3490703631),
      CubicToCommand(401.81165024279994, 312.3876278111, 356.4486655032,
          315.8624197295, 402.7227237336, 322.4729994767),
      CubicToCommand(448.99854761029997, 329.0835792239, 491.60006153669997,
          269.5883614991, 494.5380969799, 253.4291665615),
      CubicToCommand(497.4761324231, 237.26820597760002, 480.5824286247,
          217.436466736, 480.5824286247, 217.436466736),
      CubicToCommand(482.7859552071, 212.2949047104, 474.70635773829997,
          188.79062116480003, 465.8922514087, 173.36593508800001),
      CubicToCommand(457.0781450791, 157.9412490112, 430.5351842512,
          159.56740925350002, 401.253706012, 157.9412490112),
      CubicToCommand(374.8113870232, 156.47223128960002, 343.9620148696,
          195.401200912, 341.7584882872, 198.3392363552),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(343.04387879359996, 199.4833751576),
      CubicToCommand(340.8827277224, 202.36490991920002, 350.968099388,
          265.0400566303, 353.12925045919997, 274.4050446055),
      CubicToCommand(355.29040153039995, 283.7700325807, 350.968099388,
          326.9930540047, 350.968099388, 326.9930540047),
      CubicToCommand(400.1731304764, 311.2434890087, 357.4515526016,
          314.7465312679, 402.8357250968, 321.22998448149997),
      CubicToCommand(448.2216632383, 327.71343769509997, 490.0039172815,
          269.3623587727, 492.8854520431, 253.51215193759998),
      CubicToCommand(495.76698680469997, 237.66371074879999, 479.1981619255,
          218.21335110799998, 479.1981619255, 218.21335110799998),
      CubicToCommand(481.3593129967, 213.1706652752, 473.43509240230003,
          190.1183871824, 464.7904881175, 174.990329684),
      CubicToCommand(456.14588383269995, 159.86227218559998, 430.1131947855,
          161.45665079449998, 401.394957716, 159.86227218559998),
      CubicToCommand(375.46114486159996, 158.4215048048, 345.2050298648,
          196.601840396, 343.0438787936, 199.4833751576),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(402.94872646, 319.98520384),
      CubicToCommand(447.44301322, 326.34153052, 488.4077730263, 269.1345904,
          491.23280710629996, 253.59690296),
      CubicToCommand(494.0578411862999, 238.05921552, 477.81389522629996,
          218.99023548, 477.81389522629996, 218.99023548),
      CubicToCommand(479.9326707863, 214.04642583999998, 472.16206142,
          191.4461532, 463.68695918, 176.61472428),
      CubicToCommand(455.21185693999996, 161.78329536, 429.69120531979996,
          163.34765798179998, 401.53620942, 161.78329536),
      CubicToCommand(376.11090269999994, 160.37077832, 346.44804486,
          197.80247988, 344.32926929999996, 200.62751396),
      CubicToCommand(342.21049373999995, 203.45254804, 352.09811301999997,
          264.89703928, 354.21688858, 274.07840004),
      CubicToCommand(356.33566413999995, 283.2597608, 352.09811301999997,
          325.635272, 352.09811301999997, 325.635272),
      CubicToCommand(397.12209366999997, 310.45071382000003, 358.45443969999997,
          313.62887716, 402.94872646, 319.98520384),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(484.87648042629996, 259.95322964),
      CubicToCommand(484.87648042629996, 259.95322964, 435.78974764,
          273.37214152, 415.30825056, 270.54710744),
      CubicToCommand(415.30825056, 270.54710744, 387.41103902, 258.89384186,
          371.87335157999996, 297.3849312),
      CubicToCommand(371.87335157999996, 297.3849312, 365.51702489999997,
          310.09758456, 361.9857323, 313.62887716),
      CubicToCommand(358.45443969999997, 317.16016976000003, 484.87648042629996,
          259.95322964, 484.87648042629996, 259.95322964),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(491.58593636629996, 256.06880778),
      CubicToCommand(491.58593636629996, 256.06880778, 440.38042801999995,
          277.60969264, 422.72396502, 276.90343412),
      CubicToCommand(422.72396502, 276.90343412, 393.76736569999997,
          268.78146114000003, 378.93593677999996, 294.55989712),
      CubicToCommand(378.93593677999996, 294.55989712, 364.10450785999996,
          310.80384308, 358.45443969999997, 313.62887716),
      CubicToCommand(358.45443969999997, 313.62887716, 357.74818117999996,
          316.45391124, 369.0483175, 309.39132604),
      LineToCommand(387.41103902, 318.57268680000004),
      CubicToCommand(387.41103902, 318.57268680000004, 413.54260425999996,
          335.52289128, 430.49280874, 307.27255048),
      CubicToCommand(430.49280874, 307.27255048, 437.55539394, 287.49731192,
          437.55539394, 283.96601932000004),
      CubicToCommand(437.55539394, 280.43472672, 474.9870955,
          270.54710744000005, 477.81389522629996, 269.84084892000004),
      CubicToCommand(480.63892930629993, 269.13459040000004, 492.29219488629997,
          261.71887594000003, 491.58593636629996, 256.06880778000004),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(407.8925361, 319.4802289982),
      CubicToCommand(395.7590147264, 319.4802289982, 380.97525825649996,
          312.6560060487, 380.97525825649996, 301.62248232),
      CubicToCommand(380.97525825649996, 290.5907242376, 395.7590147264,
          279.5289501681, 407.8925361, 279.5289501681),
      CubicToCommand(420.0295887662, 279.5289501681, 429.8677699498,
          288.47194867760004, 429.8677699498, 299.50370676),
      CubicToCommand(429.8677699498, 310.5372304887, 420.02958876619994,
          319.4802289982, 407.8925361, 319.4802289982),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(401.4955995551, 290.02218612900003),
      CubicToCommand(392.9392775853, 291.2969827576, 383.95390356459995,
          293.9507491465, 384.08103009819996, 293.5693695457),
      CubicToCommand(386.8001254002, 285.413849286, 398.0314015145,
          279.5289501681, 407.8925361, 279.5289501681),
      CubicToCommand(415.4777526048, 279.5289501681, 422.1660207892,
          283.0213985495, 426.114005916, 288.3359939125),
      CubicToCommand(426.114005916, 288.3359939125, 416.7278301852,
          287.7533306335, 401.4955995551, 290.02218612900003),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(422.72396502, 289.61608748000003),
      CubicToCommand(422.72396502, 289.61608748000003, 414.9551213,
          283.96601932, 414.9551213, 287.85044118),
      CubicToCommand(414.9551213, 287.85044118, 421.31144797999997, 295.6192849,
          422.72396502, 289.61608748000003),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(405.06750202, 303.9637293138),
      CubicToCommand(400.6551519163, 303.9637293138, 397.07795251249996,
          300.38652991000004, 397.07795251249996, 295.97241416),
      CubicToCommand(397.07795251249996, 291.5600640563, 400.6551519163,
          287.9828646525, 405.06750202, 287.9828646525),
      CubicToCommand(409.48161776999996, 287.9828646525, 413.0588171738,
          291.5600640563, 413.0588171738, 295.97241415999997),
      CubicToCommand(413.0588171738, 300.38652991, 409.48161776999996,
          303.9637293138, 405.06750202, 303.9637293138),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(221.44028681999998, 280.43472672),
      CubicToCommand(221.44028681999998, 280.43472672, 215.79021865999997,
          243.00302516, 220.02776977999997, 235.23418144000001),
      CubicToCommand(220.02776977999997, 235.23418144000001, 239.09674981999999,
          217.57771844, 238.39049129999998, 211.22139176000002),
      CubicToCommand(238.39049129999998, 211.22139176000002, 237.68423277999997,
          179.43975836, 235.56545721999998, 178.02724132),
      CubicToCommand(233.44668165999997, 176.61472428, 220.02776977999997,
          166.02084648, 209.43389197999997, 177.32098280000002),
      CubicToCommand(209.43389197999997, 177.32098280000002, 191.07117045999996,
          209.1026162, 192.48368749999997, 220.40275252),
      LineToCommand(192.48368749999997, 223.93404512),
      CubicToCommand(192.48368749999997, 223.93404512, 179.06477561999998,
          223.2277866, 176.23974153999998, 226.7590792),
      CubicToCommand(176.23974153999998, 226.7590792, 174.12096597999997,
          235.94043996, 172.00219041999995, 236.64669848),
      CubicToCommand(172.00219041999995, 236.64669848, 167.05838077999996,
          240.8842496, 170.58967337999997, 245.82805924000002),
      CubicToCommand(170.58967337999997, 245.82805924000002, 167.05838077999996,
          250.06561036, 167.76463929999997, 257.12819556),
      LineToCommand(181.18355117999997, 264.19078076),
      CubicToCommand(181.18355117999997, 264.19078076, 184.71484377999997,
          289.61608748000003, 203.78382381999995, 298.79744824),
      CubicToCommand(212.32248932679994, 302.9096384727, 217.90899421999995,
          291.02860452, 221.44028681999995, 280.43472672),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(219.67464051999997, 277.185937528),
      CubicToCommand(219.67464051999997, 277.185937528, 214.58957917599997,
          243.497406124, 218.40337518399997, 236.505446776),
      CubicToCommand(218.40337518399997, 236.505446776, 235.56545721999998,
          220.61463007600003, 234.92982455199996, 214.893936064),
      CubicToCommand(234.92982455199996, 214.893936064, 234.29419188399999,
          186.290466004, 232.38729387999996, 185.019200668),
      CubicToCommand(230.480395876, 183.747935332, 218.40337518399997,
          174.213445312, 208.86888516399998, 184.38356800000003),
      CubicToCommand(208.86888516399998, 184.38356800000003, 192.342435796,
          212.98703806, 193.613701132, 223.157160748),
      LineToCommand(193.613701132, 226.335324088),
      CubicToCommand(193.613701132, 226.335324088, 181.53668043999997,
          225.69969142000002, 178.99414976799997, 228.87785476000002),
      CubicToCommand(178.99414976799997, 228.87785476000002, 177.08725176399997,
          237.141079444, 175.18035375999997, 237.776712112),
      CubicToCommand(175.18035375999997, 237.776712112, 170.73092508399998,
          241.59050812, 173.90908842399998, 246.039936796),
      CubicToCommand(173.90908842399998, 246.039936796, 170.73092508399998,
          249.853732804, 171.36655775199998, 256.210059484),
      LineToCommand(183.443578444, 262.566386164),
      CubicToCommand(183.443578444, 262.566386164, 186.621741784,
          285.44916221200003, 203.78382381999998, 293.712386896),
      CubicToCommand(211.46791651759997, 297.4114158945, 216.49647718,
          286.72042754800003, 219.67464051999997, 277.185937528),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(234.77091638499996, 179.775231157),
      CubicToCommand(232.84636191799996, 178.256775339, 219.62167113099997,
          168.068996188, 209.292640276, 179.0866291),
      CubicToCommand(209.292640276, 179.0866291, 191.388986794, 210.073721665,
          192.766190908, 221.091354577),
      LineToCommand(192.766190908, 224.53436486200002),
      CubicToCommand(192.766190908, 224.53436486200002, 179.682751825,
          223.845762805, 176.928343597, 227.28877309),
      CubicToCommand(176.928343597, 227.28877309, 174.862537426, 236.240599831,
          172.796731255, 236.929201888),
      CubicToCommand(172.796731255, 236.929201888, 167.976516856, 241.06081423,
          171.419527141, 245.881028629),
      CubicToCommand(171.419527141, 245.881028629, 167.976516856, 250.012640971,
          168.665118913, 256.898661541),
      LineToCommand(181.748557996, 263.784682111),
      CubicToCommand(181.748557996, 263.784682111, 185.19156828099997,
          288.574356163, 203.78382381999998, 297.526182904),
      CubicToCommand(212.10708047819998, 301.534200005, 217.55586495999998,
          289.951560277, 220.99887524499997, 279.622529422),
      CubicToCommand(220.99887524499997, 279.622529422, 215.490058789,
          243.126620401, 219.62167113099997, 235.551997774),
      CubicToCommand(219.62167113099997, 235.551997774, 238.21392666999998,
          218.33694634900002, 237.52532461299998, 212.139527836),
      CubicToCommand(237.52532461299998, 212.139527836, 236.83672255599998,
          181.152435271, 234.77091638499996, 179.775231157),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(233.97637554999997, 181.523220994),
      CubicToCommand(232.24604217599997, 179.898826398, 219.21557248199997,
          170.117145896, 209.15138857199997, 180.8522754),
      CubicToCommand(209.15138857199997, 180.8522754, 191.706803128,
          211.04482713000002, 193.04869431599997, 221.779956634),
      LineToCommand(193.04869431599997, 225.134684604),
      CubicToCommand(193.04869431599997, 225.134684604, 180.30072802999996,
          224.46373901, 177.61694565399998, 227.81846698),
      CubicToCommand(177.61694565399998, 227.81846698, 175.60410887199998,
          236.540759702, 173.59127208999996, 237.211705296),
      CubicToCommand(173.59127208999996, 237.211705296, 168.89465293199999,
          241.23737886, 172.24938090199996, 245.933998018),
      CubicToCommand(172.24938090199996, 245.933998018, 168.89465293199996,
          249.959671582, 169.56559852599997, 256.669127522),
      LineToCommand(182.31356481199995, 263.378583462),
      CubicToCommand(182.31356481199995, 263.378583462, 185.66829278199998,
          287.532624846, 203.78382381999995, 296.254917568),
      CubicToCommand(211.89520292219996, 300.1605271836, 217.20273569999995,
          288.874516034, 220.55746366999995, 278.810332124),
      CubicToCommand(220.55746366999995, 278.810332124, 215.18989891799998,
          243.250215642, 219.21557248199997, 235.869814108),
      CubicToCommand(219.21557248199997, 235.869814108, 237.33110351999994,
          219.096174258, 236.66015792599995, 213.057663912),
      CubicToCommand(236.66015792599995, 213.057663912, 235.98921233199997,
          182.86511218200002, 233.97637554999994, 181.52322099399998),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(233.18183471499998, 183.27121083100002),
      CubicToCommand(231.645722434, 181.54087745700002, 218.80947383299997,
          172.165295604, 209.01013686799996, 182.6179217),
      CubicToCommand(209.01013686799996, 182.6179217, 192.02461946199998,
          212.015932595, 193.331197724, 222.468558691),
      LineToCommand(193.331197724, 225.735004346),
      CubicToCommand(193.331197724, 225.735004346, 180.91870423499998,
          225.081715215, 178.30554771099997, 228.34816087000002),
      CubicToCommand(178.30554771099997, 228.34816087000002, 176.34568031799998,
          236.840919573, 174.38581292499998, 237.49420870400002),
      CubicToCommand(174.38581292499998, 237.49420870400002, 169.81278900799998,
          241.41394349, 173.079234663, 245.986967407),
      CubicToCommand(173.079234663, 245.986967407, 169.81278900799998,
          249.906702193, 170.466078139, 256.439593503),
      LineToCommand(182.87857162799997, 262.972484813),
      CubicToCommand(182.87857162799997, 262.972484813, 186.14501728299996,
          286.490893529, 203.78382381999998, 294.983652232),
      CubicToCommand(211.68155971989998, 298.7868543622, 216.84960644,
          287.797471791, 220.116052095, 277.998134826),
      CubicToCommand(220.116052095, 277.998134826, 214.88973904699998,
          243.373810883, 218.80947383299997, 236.187630442),
      CubicToCommand(218.80947383299997, 236.187630442, 236.44828037,
          219.85540216700002, 235.79499123899998, 213.975799988),
      CubicToCommand(235.79499123899998, 213.975799988, 235.14170210799998,
          184.577789093, 233.18183471499998, 183.27121083100002),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(219.67464051999997, 277.009372898),
      CubicToCommand(219.67464051999997, 277.009372898, 214.58957917599997,
          243.497406124, 218.40337518399997, 236.505446776),
      CubicToCommand(218.40337518399997, 236.505446776, 235.56545721999998,
          220.614630076, 234.92982455199996, 214.893936064),
      CubicToCommand(234.92982455199996, 214.893936064, 234.29419188399999,
          186.290466004, 232.38729387999996, 185.019200668),
      CubicToCommand(231.04540269199998, 183.182928516, 218.40337518399997,
          174.213445312, 208.86888516399998, 184.38356800000003),
      CubicToCommand(208.86888516399998, 184.38356800000003, 192.342435796,
          212.98703806, 193.613701132, 223.157160748),
      LineToCommand(193.613701132, 226.335324088),
      CubicToCommand(193.613701132, 226.335324088, 181.53668043999997,
          225.69969142000002, 178.99414976799997, 228.87785476000002),
      CubicToCommand(178.99414976799997, 228.87785476000002, 177.08725176399997,
          237.141079444, 175.18035375999997, 237.776712112),
      CubicToCommand(175.18035375999997, 237.776712112, 170.73092508399998,
          241.59050812, 173.90908842399998, 246.039936796),
      CubicToCommand(173.90908842399998, 246.039936796, 170.73092508399998,
          249.853732804, 171.36655775199998, 256.210059484),
      LineToCommand(183.443578444, 262.566386164),
      CubicToCommand(183.443578444, 262.566386164, 186.621741784,
          285.44916221200003, 203.78382381999998, 293.712386896),
      CubicToCommand(211.46791651759997, 297.4114158945, 216.49647718,
          286.543862918, 219.67464051999997, 277.009372898),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(214.20113698999995, 265.95642706),
      CubicToCommand(214.20113698999995, 265.95642706, 176.06317690999995,
          247.9468348, 174.47409523999997, 246.53431776),
      CubicToCommand(174.47409523999997, 246.53431776, 190.54147656999996,
          261.01261742, 191.95399360999997, 261.01261742),
      CubicToCommand(193.36651065, 261.01261742, 214.20113698999998,
          265.95642706, 214.20113698999998, 265.95642706),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(184.00858526, 255.00942),
      CubicToCommand(184.00858526, 255.00942, 216.49647718, 261.36574668000003,
          216.49647718, 269.1345904),
      CubicToCommand(216.49647718, 274.2761524256, 216.06742512909997,
          297.9693601253, 206.60885789999998, 295.26615564),
      CubicToCommand(191.77742897999997, 291.02860452, 198.13375565999996,
          265.6032978, 184.00858526, 255.00942),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(198.84001417999997, 261.71887594000003),
      CubicToCommand(198.84001417999997, 261.71887594000003, 214.69198666139997,
          264.32143858620003, 216.49647717999997, 269.1345904),
      CubicToCommand(217.55586495999995, 271.95962448, 218.72648845689997,
          286.6286139404, 209.08076271999997, 288.5566997),
      CubicToCommand(201.04354076239994, 290.16520347930003, 197.10614951339997,
          272.118532647, 198.84001417999997, 261.71887594000003),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(350.67676774849997, 336.8453603587),
      CubicToCommand(349.7992415374, 333.7696045041, 352.11400383669996,
          334.0009041694, 355.27627636, 333.05098646),
      CubicToCommand(358.80756895999997, 331.99159868, 380.34845382,
          325.28214274, 381.76097086, 320.69146236),
      CubicToCommand(383.1734879, 316.10078197999997, 406.48001905999996,
          323.86962570000003, 406.48001905999996, 323.86962570000003),
      CubicToCommand(409.6581824, 325.28214274, 417.42702612, 329.87282312,
          417.42702612, 329.87282312),
      CubicToCommand(425.90212836, 331.99159868, 437.55539394, 332.6978572,
          437.55539394, 332.6978572),
      CubicToCommand(441.79294505999997, 334.4635035, 447.79614247999996,
          339.40731314, 447.79614247999996, 339.40731314),
      CubicToCommand(473.57457846, 357.41690539999996, 495.4703582263,
          344.70425204, 495.4703582263, 344.70425204),
      CubicToCommand(530.78151858, 333.05098646, 520.18764078,
          302.68187009999997, 520.18764078, 302.68187009999997),
      CubicToCommand(514.89070188, 286.7910534, 520.54077004,
          280.78785597999996, 520.54077004, 280.78785597999996),
      CubicToCommand(520.8938993, 274.07840003999996, 533.60655266,
          285.37853636, 533.60655266, 285.37853636),
      CubicToCommand(538.19723304, 292.79425082, 539.60975008,
          301.62248231999996, 539.60975008, 301.62248231999996),
      CubicToCommand(553.73492048, 321.39772087999995, 547.73172306,
          289.96921674, 547.73172306, 289.96921674),
      CubicToCommand(548.08485232, 288.20357043999996, 543.14104268,
          281.84724375999997, 543.14104268, 279.7284682),
      CubicToCommand(543.14104268, 277.60969264, 539.96287934, 271.60649522,
          539.96287934, 271.60649522),
      CubicToCommand(534.66594044, 265.6032978, 538.90349156, 253.2437737,
          538.90349156, 253.2437737),
      CubicToCommand(542.0816549, 228.87785476, 538.19723304, 232.0560181,
          538.19723304, 232.0560181),
      CubicToCommand(536.07845748, 228.87785476, 519.83451152, 246.53431776,
          519.83451152, 246.53431776),
      CubicToCommand(515.95008966, 252.53751517999999, 505.35621186000003,
          255.36254925999998, 505.35621186000003, 255.36254925999998),
      CubicToCommand(500.4141678663, 258.5407126, 494.4109704463, 256.06880778,
          494.4109704463, 256.06880778),
      CubicToCommand(489.8202900663, 255.36254925999998, 479.93267078630004,
          267.72207335999997, 479.93267078630004, 267.72207335999997),
      CubicToCommand(484.87648042629996, 267.36894409999996, 489.1140315463,
          275.13778781999997, 493.35158266630003, 275.49091708),
      CubicToCommand(497.58913378629995, 275.84404634, 500.76729712630004,
          271.25336596, 503.59056556, 270.19397818),
      CubicToCommand(506.41559964, 269.1345904, 511.35940928, 279.37533894,
          511.35940928, 279.37533894),
      CubicToCommand(512.0656678, 283.96601932, 502.17804852, 292.44112156,
          502.17804852, 292.44112156),
      CubicToCommand(501.47179, 300.56309454, 498.6485215663, 297.73806046,
          498.6485215663, 297.73806046),
      CubicToCommand(493.35158266630003, 296.67867268, 491.2328071063,
          303.38812862, 489.4671608063, 311.5101016),
      CubicToCommand(487.7015145063, 319.63207458, 480.2858000463, 320.3383331,
          480.2858000463, 320.3383331),
      CubicToCommand(477.4607659663, 333.40411572, 475.34022476,
          328.10717681999995, 475.34022476, 328.10717681999995),
      CubicToCommand(474.9870955, 318.21955754, 464.39321770000004,
          328.46030608, 464.39321770000004, 328.46030608),
      CubicToCommand(462.27444214, 331.99159868, 454.15246916,
          328.10717681999995, 454.15246916, 328.10717681999995),
      CubicToCommand(442.14607432, 324.57588422, 446.38362544, 321.04459162,
          446.38362544, 321.04459162),
      CubicToCommand(449.56178878, 317.16016976, 469.33702733999996,
          321.04459162, 469.33702733999996, 321.04459162),
      CubicToCommand(473.2214492, 318.21955754, 459.0962788, 311.15697234,
          459.0962788, 311.15697234),
      CubicToCommand(458.03689102, 307.97880899999996, 459.80253732,
          300.20996528, 459.80253732, 300.20996528),
      CubicToCommand(461.92131288, 294.55989711999996, 473.92770772,
          284.67227784, 473.92770772, 284.67227784),
      CubicToCommand(490.5265485863, 282.55350228, 485.58273894629997,
          279.72846819999995, 485.58273894629997, 279.72846819999995),
      CubicToCommand(474.6357318863, 270.54710744, 464.39321770000004,
          283.96601932, 464.39321770000004, 283.96601932),
      CubicToCommand(460.50879584, 294.91302637999996, 429.78655022,
          321.39772087999995, 429.78655022, 321.39772087999995),
      CubicToCommand(421.31144798, 327.40091829999994, 425.90212836,
          315.39452345999996, 418.83954316, 321.39772087999995),
      CubicToCommand(411.77695796, 327.40091829999994, 375.40464418,
          311.5101016, 375.40464418, 311.5101016),
      CubicToCommand(354.9902416594, 309.4036855641, 350.16649596779996,
          337.19848961869997, 343.9355301751, 331.6896731627),
      CubicToCommand(343.9355301751, 331.6896731627, 353.5018018285,
          346.7329796387, 350.67676774849997, 336.84536035869996),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(694.63349522, 43.13186400000001),
      CubicToCommand(694.63349522, 43.13186400000001, 649.4329499400001,
          57.25703440000001, 644.4891402999999, 90.45118484),
      CubicToCommand(644.4891402999999, 90.45118484, 640.2515891799999,
          130.70792047999998, 676.2707737, 161.78329536),
      CubicToCommand(676.2707737, 161.78329536, 676.97703222, 173.08343168,
          680.50832482, 178.73349984),
      CubicToCommand(680.50832482, 178.73349984, 677.6832907400001,
          187.20860208, 710.87744118, 173.7896902),
      LineToCommand(758.9030205399999, 158.95826128),
      CubicToCommand(758.9030205399999, 158.95826128, 770.20315686,
          154.72071016, 779.38451762, 139.18302272),
      CubicToCommand(788.56587838, 123.64533528000001, 815.40370214,
          90.45118484000002, 809.04737546, 45.95689808000003),
      CubicToCommand(809.04737546, 45.95689808000003, 811.1661510199999,
          26.18165952000001, 800.5722732199999, 25.475401000000005),
      CubicToCommand(800.5722732199999, 25.475401000000005, 785.7408442999999,
          22.65036692000001, 773.02819094, 36.069278800000006),
      CubicToCommand(773.02819094, 36.069278800000006, 761.0217960999998,
          41.719346960000024, 756.78424498, 41.01308843999999),
      LineToCommand(694.63349522, 43.13186400000001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(791.0730961259999, 41.383874163),
      CubicToCommand(791.0730961259999, 41.383874163, 794.780953356,
          25.616652704000018, 786.235225264, 34.16238079600001),
      CubicToCommand(786.235225264, 34.16238079600001, 773.8050753119999,
          44.261877631999994, 760.5980409879999, 44.261877631999994),
      CubicToCommand(760.5980409879999, 44.261877631999994, 734.9608567119999,
          48.146299492000026, 727.192012992, 71.45283065200002),
      CubicToCommand(727.192012992, 71.45283065200002, 720.2000536439999,
          118.84277734400001, 734.18397234, 128.94227418000003),
      CubicToCommand(734.18397234, 128.94227418000003, 742.729700432,
          142.14930850400003, 755.1598503839999, 130.496042924),
      CubicToCommand(767.590000336, 118.84277734399998, 794.9575179859999,
          65.467289695, 791.0730961259999, 41.383874163),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(790.4198069949999, 42.019506831),
      CubicToCommand(790.4198069949999, 42.019506831, 794.1100077619999,
          26.570101706000003, 785.7231878369998, 34.97457809400001),
      CubicToCommand(785.7231878369998, 34.97457809400001, 773.5049154409999,
          44.87985383700001, 760.5450715989999, 44.87985383700001),
      CubicToCommand(760.5450715989999, 44.87985383700001, 735.366955361,
          48.69364984500001, 727.7393633449999, 71.57642589300002),
      CubicToCommand(727.7393633449999, 71.57642589300002, 720.870999238,
          118.10826848320002, 734.6077274519998, 128.02413810400003),
      CubicToCommand(734.6077274519998, 128.02413810400003, 742.9945473769999,
          140.99104453120003, 755.1951633099999, 129.54965650720004),
      CubicToCommand(767.4134357059999, 118.10826848320002, 794.2336030029999,
          65.66151078800004, 790.4198069949999, 42.01950683100003),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(789.7488614009999, 42.655139499),
      CubicToCommand(789.7488614009999, 42.655139499, 793.4214057049999,
          27.541207171000025, 785.193493947, 35.769118929),
      CubicToCommand(785.193493947, 35.769118929, 773.222412033,
          45.497830042000004, 760.49210221, 45.497830042000004),
      CubicToCommand(760.49210221, 45.497830042000004, 735.7730540099999,
          49.24100019800002, 728.2867136979999, 71.70002113400002),
      CubicToCommand(728.2867136979999, 71.70002113400002, 721.559601295,
          117.3737596224, 735.0314825639999, 127.106002028),
      CubicToCommand(735.0314825639999, 127.106002028, 743.2593943219999,
          139.8327805584, 755.2481326989998, 128.6032700904),
      CubicToCommand(767.2192146129998, 117.3737596224, 793.492031557,
          65.85573188100003, 789.7488614009999, 42.655139499),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(789.0955722699999, 43.27311570399999),
      CubicToCommand(789.0955722699999, 43.27311570399999, 792.7504601109999,
          28.49465617300001, 784.6638000569999, 36.581316227),
      CubicToCommand(784.6638000569999, 36.581316227, 772.922252162,
          46.133462709999975, 760.421476358, 46.133462709999975),
      CubicToCommand(760.421476358, 46.133462709999975, 736.196809122,
          49.80600701399999, 728.8517205139999, 71.84127283799998),
      CubicToCommand(728.8517205139999, 71.84127283799998, 722.2305468889999,
          116.63925076159998, 735.455237676, 126.18786595199998),
      CubicToCommand(735.455237676, 126.18786595199998, 743.5418977300001,
          138.6745165856, 755.283445625, 127.65688367359998),
      CubicToCommand(767.042649983, 116.63925076159998, 792.768116574,
          66.04995297399998, 789.0955722699999, 43.27311570399999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(788.442283139, 43.90874837199999),
      CubicToCommand(788.442283139, 43.90874837199999, 792.079514517,
          29.465761638000004, 784.1517626299999, 37.375857061999994),
      CubicToCommand(784.1517626299999, 37.375857061999994, 772.622092291,
          46.751438914999994, 760.3685069689999, 46.751438914999994),
      CubicToCommand(760.3685069689999, 46.751438914999994, 736.6029077709999,
          50.353357367, 729.3990708669999, 71.96486807900001),
      CubicToCommand(729.3990708669999, 71.96486807900001, 722.919148946,
          115.90474190079999, 735.8789927879999, 125.26972987599999),
      CubicToCommand(735.8789927879999, 125.26972987599999, 743.8067446749999,
          137.51625261279997, 755.336415014, 126.71049725680001),
      CubicToCommand(766.8484288899999, 115.90474190079999, 792.044201591,
          66.24417406700002, 788.442283139, 43.90874837199999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(787.7713375449999, 44.54438103999999),
      CubicToCommand(787.7713375449999, 44.54438103999999, 791.39091246,
          30.41921063999999, 783.6220687399999, 38.188054360000024),
      CubicToCommand(783.6220687399999, 38.188054360000024, 772.3219324199999,
          47.36941512000001, 760.31553758, 47.36941512000001),
      CubicToCommand(760.31553758, 47.36941512000001, 737.0090064199999,
          50.900707720000014, 729.9464212199999, 72.08846332000002),
      CubicToCommand(729.9464212199999, 72.08846332000002, 723.5900945399999,
          115.17023304000003, 736.3027479, 124.35159380000002),
      CubicToCommand(736.3027479, 124.35159380000002, 744.0715916199999,
          136.35798864, 755.37172794, 125.76411084),
      CubicToCommand(766.6718642599999, 115.17023304, 791.302630145,
          66.43839516, 787.7713375449999, 44.54438103999999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(414.24886277999997, 403.3237092),
      CubicToCommand(414.24886277999997, 403.3237092, 378.22967825999996,
          369.42330024, 364.10450786, 368.0107832),
      CubicToCommand(364.10450786, 368.0107832, 303.36627513999997, 360.948198,
          277.2347099, 392.72983139999997),
      CubicToCommand(277.2347099, 392.72983139999997, 308.31008477999995,
          356.71064688, 357.04192265999995, 366.59826616),
      CubicToCommand(357.04192265999995, 366.59826616, 318.90396258,
          358.82942244000003, 297.00994846, 364.4794906),
      LineToCommand(250.39688614, 389.1985388),
      LineToCommand(245.4530765, 397.67364104),
      CubicToCommand(245.4530765, 397.67364104, 252.5156617, 371.5420758,
          285.00355362, 360.948198),
      CubicToCommand(285.00355362, 360.948198, 325.26028926, 352.47309576,
          344.32926929999996, 360.948198),
      CubicToCommand(344.32926929999996, 360.948198, 306.19130922, 348.94180316,
          288.53484621999996, 352.47309576),
      CubicToCommand(288.53484621999996, 352.47309576, 234.85919869999998,
          348.23554464, 212.25892605999996, 394.84860696),
      CubicToCommand(212.25892605999996, 394.84860696, 219.32151125999997,
          369.42330024, 245.45307649999998, 356.71064688),
      CubicToCommand(245.45307649999998, 356.71064688, 269.46586618,
          341.17295944, 305.4850507, 346.11676908000004),
      CubicToCommand(305.4850507, 346.11676908000004, 330.91035741999997,
          351.76683724000003, 340.09171818, 356.00438836),
      CubicToCommand(349.27307894, 360.24193948000004, 347.15430338,
          355.29812984, 332.32287446, 346.8230276),
      CubicToCommand(332.32287446, 346.8230276, 322.43525517999996, 329.1665646,
          297.71620698, 329.87282312),
      CubicToCommand(297.71620698, 329.87282312, 222.14654534, 336.2291498,
          203.78382381999995, 357.4169054),
      CubicToCommand(203.78382381999995, 357.4169054, 227.79661349999998,
          337.64166683999997, 246.15933501999996, 332.6978572),
      CubicToCommand(246.15933501999996, 332.6978572, 285.70981213999994,
          318.5726868, 300.54124105999995, 319.98520384),
      CubicToCommand(300.54124105999995, 319.98520384, 344.32926929999996,
          321.75085014, 357.74818117999996, 314.68826494),
      CubicToCommand(357.74818117999996, 314.68826494, 337.97294261999997,
          323.51649643999997, 343.62301077999996, 329.1665646),
      CubicToCommand(349.27307893999995, 334.81663276, 361.27947378,
          348.23554464, 361.27947378, 350.3543202),
      CubicToCommand(361.27947378, 352.47309576, 404.00811423999994,
          391.49387899, 410.36444092, 399.26272271000005),
      LineToCommand(414.24886277999997, 403.3237092),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(658.6143107, 745.8590914),
      CubicToCommand(658.6143107, 745.8590914, 631.24679305, 681.41300145,
          609.1762143, 664.6393616),
      CubicToCommand(609.1762143, 664.6393616, 655.0830181, 692.8897024,
          661.26278015, 724.6713358),
      CubicToCommand(661.26278015, 724.6713358, 661.26278015, 742.3277988,
          658.6143107, 745.8590914),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(741.5996868, 759.10143865),
      CubicToCommand(741.5996868, 759.10143865, 694.81005985, 661.99089215,
          662.1456033, 619.61538095),
      CubicToCommand(662.1456033, 619.61538095, 738.95121735, 685.8271172,
          747.77944885, 732.61674415),
      LineToCommand(748.662272, 742.3277988),
      LineToCommand(743.3653331, 737.91368305),
      CubicToCommand(743.3653331, 737.91368305, 742.4825099499999, 753.80449975,
          741.5996868, 759.10143865),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(841.35870275, 673.4675931),
      CubicToCommand(841.35870275, 673.4675931, 731.005809, 568.41163825,
          728.35733955, 563.9975225000001),
      CubicToCommand(728.35733955, 563.9975225000001, 835.1789407, 680.5301783,
          840.4758796, 693.77252555),
      CubicToCommand(840.4758796, 693.77252555, 836.944587, 677.88170885,
          841.35870275, 673.4675931),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(508.5343752, 750.27320715),
      CubicToCommand(508.5343752, 750.27320715, 542.96447805, 658.45959955,
          576.51175775, 698.1866413),
      CubicToCommand(576.51175775, 698.1866413, 602.99645225, 715.8431043,
          602.1136291, 721.1400432),
      CubicToCommand(602.1136291, 721.1400432, 595.0510439, 709.66334225,
          563.2694104999999, 710.5461654),
      CubicToCommand(563.2694104999999, 710.5461654, 529.7221308, 705.2492265,
          508.5343752, 750.27320715),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(844.8899953499999, 525.1533039),
      CubicToCommand(844.8899953499999, 525.1533039, 765.4359118499999,
          474.83238435, 752.1935646, 472.1839149),
      CubicToCommand(731.341281797, 468.016989632, 839.59305645, 523.3876576,
          848.42128795, 541.92694375),
      CubicToCommand(848.42128795, 541.92694375, 851.95258055, 537.512828,
          844.8899953499999, 525.1533039),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(578.80709794, 713.3711994800001),
      CubicToCommand(578.80709794, 713.3711994800001, 614.82628246,
          709.8399068800001, 626.8326773, 697.8335120400001),
      LineToCommand(634.6015210200001, 704.18983872),
      LineToCommand(665.6768959, 636.3890208),
      LineToCommand(672.03322258, 645.57038156),
      CubicToCommand(672.03322258, 645.57038156, 697.4585293, 619.43881632,
          696.04601226, 605.31364592),
      CubicToCommand(694.63349522, 591.18847552, 718.6462849, 615.90752372,
          718.6462849, 615.90752372),
      CubicToCommand(718.6462849, 615.90752372, 717.23376786, 595.42602664,
          729.94642122, 607.4324214799999),
      CubicToCommand(729.94642122, 607.4324214799999, 725.7088701,
          579.8883391999999, 740.54029902, 594.0135095999999),
      CubicToCommand(740.54029902, 594.0135095999999, 721.9303870179999,
          540.761617192, 761.72805462, 586.24466588),
      CubicToCommand(771.6156739, 597.5448021999999, 763.84683018, 585.53840736,
          763.84683018, 585.53840736),
      CubicToCommand(763.84683018, 585.53840736, 717.94002638,
          500.78738495999994, 756.0779864599999, 526.2126916799999),
      CubicToCommand(756.0779864599999, 526.2126916799999, 759.60927906,
          485.95595603999993, 757.4905034999999, 478.18711232),
      CubicToCommand(755.37172794, 470.4182685999999, 751.84043534,
          430.86779147999994, 743.3653331, 421.68643072),
      CubicToCommand(734.89023086, 412.5050699599999, 744.0715916199999,
          409.68003587999993, 753.9592109, 418.86139663999995),
      CubicToCommand(753.9592109, 418.86139663999995, 734.18397234,
          376.48588543999995, 757.4905034999999, 397.67364103999995),
      CubicToCommand(757.4905034999999, 397.67364103999995, 751.13417682,
          370.83581727999996, 743.3653331, 365.89200764),
      CubicToCommand(743.3653331, 365.89200764, 733.47771382,
          335.52289127999995, 760.31553758, 354.59187131999994),
      CubicToCommand(760.31553758, 354.59187131999994, 752.54669386,
          332.69785719999993, 746.8966257, 327.04778903999994),
      CubicToCommand(746.8966257, 327.04778903999994, 726.4151286199999,
          278.31595115999994, 739.12778198, 286.79105339999995),
      LineToCommand(746.8966257, 293.14738007999995),
      CubicToCommand(746.8966257, 293.14738007999995, 734.89023086,
          268.42833188, 746.19036718, 276.1971755999999),
      CubicToCommand(757.4905034999999, 283.96601931999993, 757.4905034999999,
          283.2597608, 757.4905034999999, 283.2597608),
      CubicToCommand(757.4905034999999, 283.2597608, 720.05880194,
          224.64030363999996, 756.0779864599999, 255.71567851999995),
      CubicToCommand(756.0779864599999, 255.71567851999995, 741.6703126519999,
          231.14141331659997, 735.59648938, 218.99023547999997),
      CubicToCommand(735.59648938, 218.99023547999997, 702.4023389399999,
          182.97105095999996, 727.8276456599999, 194.27118727999994),
      LineToCommand(736.3027479, 197.09622135999996),
      CubicToCommand(736.3027479, 197.09622135999996, 720.76506046,
          179.43975835999993, 706.63989006, 176.61472427999996),
      CubicToCommand(692.51471966, 173.78969019999994, 710.87744118,
          162.48955387999996, 722.1775775, 166.02084647999993),
      CubicToCommand(733.47771382, 169.55213907999996, 761.0217961,
          182.97105095999996, 761.0217961, 182.97105095999996),
      CubicToCommand(761.0217961, 182.97105095999996, 783.62206874,
          216.16520139999994, 790.68465394, 216.87145991999995),
      CubicToCommand(790.68465394, 216.87145991999995, 755.37172794,
          203.45254803999995, 765.96560574, 217.57771843999996),
      CubicToCommand(765.96560574, 217.57771843999996, 791.39091246,
          242.29676663999993, 778.6782591, 241.59050811999995),
      CubicToCommand(778.6782591, 241.59050811999995, 768.0843812999999,
          254.30316147999994, 776.55948354, 269.8408489199999),
      CubicToCommand(776.55948354, 269.8408489199999, 743.965652842,
          237.36884781669994, 770.20315686, 282.55350228),
      LineToCommand(782.2095517, 311.5101015999999),
      CubicToCommand(782.2095517, 311.5101015999999, 739.12778198,
          267.72207335999997, 758.9030205399999, 306.56629195999994),
      CubicToCommand(758.9030205399999, 306.56629195999994, 789.2721369,
          348.23554463999994, 792.8034295, 348.94180315999995),
      CubicToCommand(796.3347220999999, 349.64806167999996, 804.1035658199999,
          365.18574911999997, 804.1035658199999, 365.18574911999997),
      LineToCommand(796.3347220999999, 361.65445651999994),
      LineToCommand(805.51608286, 377.19214395999995),
      CubicToCommand(805.51608286, 377.19214395999995, 785.7408442999999,
          356.00438835999995, 796.3347220999999, 379.31091951999997),
      LineToCommand(806.22234138, 404.73622623999995),
      CubicToCommand(806.22234138, 404.73622623999995, 770.20315686,
          365.89200764, 794.21594654, 418.15513811999995),
      CubicToCommand(794.21594654, 418.15513811999995, 765.25934722,
          408.97377735999993, 780.79703466, 439.34289371999995),
      CubicToCommand(780.79703466, 439.34289371999995, 777.97200058,
          467.59323451999995, 778.6782591, 476.77459527999997),
      CubicToCommand(779.38451762, 485.95595603999993, 781.50329318,
          536.1003109599999, 773.73444946, 550.2254813599999),
      CubicToCommand(765.9656057399999, 564.3506517599999, 784.3283272599999,
          598.2510607199999, 787.85961986, 605.3136459199999),
      CubicToCommand(791.39091246, 612.3762311199999, 797.7472391399999,
          631.44521116, 782.2095517, 615.2012651999999),
      CubicToCommand(766.6718642599999, 598.9573192399998, 774.44070798,
          608.8449385199999, 777.97200058, 624.3826259599999),
      CubicToCommand(781.50329318, 639.9203133999998, 792.0971709800001,
          667.4643956799999, 790.68465394, 677.3520149599999),
      CubicToCommand(790.68465394, 677.3520149599999, 788.56587838,
          679.4707905199998, 782.91581022, 673.1144638399999),
      CubicToCommand(782.91581022, 673.1144638399999, 756.78424498,
          632.8577281999999, 759.6092790600001, 658.2830349199999),
      CubicToCommand(759.6092790600001, 658.2830349199999, 757.4905035000002,
          672.4082053199999, 751.8404353400001, 687.9458927599999),
      CubicToCommand(751.8404353400001, 687.9458927599999, 746.1903671800001,
          707.0148727999999, 746.1903671800001, 691.4771853599999),
      CubicToCommand(746.1903671800001, 691.4771853599999, 740.54029902,
          661.8143275199999, 735.5964893800001, 675.2332393999999),
      CubicToCommand(730.65267974, 688.65215128, 724.29635306,
          699.2460290799999, 719.3525434200001, 703.4835801999999),
      CubicToCommand(714.4087337800001, 707.7211313199999, 705.2273730200001,
          667.4643956799999, 703.10859746, 685.8271171999999),
      CubicToCommand(703.10859746, 685.8271171999999, 681.9208418600001,
          663.9331030799999, 673.44573962, 692.8897023999999),
      LineToCommand(652.9642425400001, 721.8463017199998),
      CubicToCommand(652.9642425400001, 721.8463017199998, 652.2579840200001,
          699.9522875999999, 650.1392084600002, 710.5461654),
      CubicToCommand(650.1392084600002, 710.5461654, 597.1698194600001,
          721.1400431999999, 578.8070979400001, 713.37119948),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(518.06886522, 83.38859964),
      CubicToCommand(518.06886522, 83.38859964, 497.58913378629995, 69.26342924,
          490.5265485863, 69.96968776),
      CubicToCommand(483.46396338629995, 70.67594628000003, 539.25662082,
          54.432000320000014, 612.00124838, 103.16383820000001),
      CubicToCommand(612.00124838, 103.16383820000001, 620.4763506200001,
          108.10764784, 626.8326773, 107.40138932000002),
      CubicToCommand(626.8326773, 107.40138932000002, 632.4827454599999,
          111.63894044000003, 627.53893582, 117.99526712000002),
      CubicToCommand(627.53893582, 117.99526712000002, 612.00124838,
          134.94547160000002, 631.77648694, 154.72071016),
      CubicToCommand(631.77648694, 154.72071016, 664.2643788600001, 166.727105,
          654.37675958, 151.18941756),
      CubicToCommand(654.37675958, 151.18941756, 673.44573962, 158.25200276,
          677.6832907400001, 165.31458796),
      CubicToCommand(681.92084186, 172.37717316, 679.8020663, 165.31458796,
          679.8020663, 165.31458796),
      LineToCommand(657.90805218, 143.42057384000003),
      CubicToCommand(657.90805218, 143.42057384000003, 648.72669142,
          139.88928124000003, 643.78288178, 125.05785232000002),
      CubicToCommand(638.83907214, 110.22642340000002, 634.6015210200001,
          92.56996040000001, 642.37036474, 86.91989224000002),
      CubicToCommand(642.37036474, 86.91989224000002, 635.30777954,
          94.68873596000003, 636.72029658, 87.62615076000003),
      CubicToCommand(638.13281362, 80.56356556000003, 644.4891403,
          74.20723888000003, 647.3141743799999, 73.50098036000003),
      CubicToCommand(650.13920846, 72.79472184000002, 679.0958077800001,
          44.89751030000002, 691.1022026200001, 44.191251780000044),
      CubicToCommand(691.1022026200001, 44.191251780000044, 674.85825666,
          46.663156600000065, 669.5613177600001, 44.89751030000005),
      CubicToCommand(664.2643788600001, 43.131864000000064, 617.2981872800001,
          23.00349618000004, 606.7043094800001, 20.884720620000053),
      CubicToCommand(606.7043094800001, 20.884720620000053, 577.0414516400001,
          9.231455040000071, 598.22920724, 12.762747640000072),
      CubicToCommand(598.22920724, 12.762747640000072, 661.43934478,
          19.472203580000098, 693.57410744, 42.77873474000009),
      CubicToCommand(693.57410744, 42.77873474000009, 680.86145408,
          27.947305820000054, 648.3735621600001, 15.587781720000066),
      CubicToCommand(648.3735621600001, 15.587781720000066, 609.1762143000001,
          -6.659361659999917, 547.02546454, 2.1688698400000703),
      CubicToCommand(547.02546454, 2.1688698400000703, 515.5969604000001,
          7.81893800000006, 501.82491926000006, 10.997101340000086),
      CubicToCommand(501.82491926000006, 10.997101340000086, 497.2360045263,
          9.937713560000077, 496.17661674630006, 9.231455040000071),
      CubicToCommand(495.1172289663001, 8.525196520000065, 474.28083698000006,
          -7.365620179999922, 425.54899910000006, 4.993903920000065),
      CubicToCommand(425.54899910000006, 4.993903920000065, 395.5330120000001,
          13.115876900000046, 380.34845382000003, 21.590979140000087),
      CubicToCommand(380.34845382000003, 21.590979140000087, 353.51063006000004,
          23.709754700000047, 347.15430338000004, 29.359822860000094),
      CubicToCommand(347.15430338000004, 29.359822860000094, 314.31328220000006,
          55.13825884000008, 310.78198960000003, 56.55077588000009),
      CubicToCommand(307.25069700000006, 57.96329292000013, 287.12232918000007,
          71.3822048000001, 285.70981214000005, 72.0884633200001),
      CubicToCommand(285.70981214000005, 72.0884633200001, 329.14471112000007,
          60.43519774000009, 333.38226224000005, 56.197646620000086),
      CubicToCommand(337.6198133600001, 51.96009550000008, 368.34205898000005,
          47.3694151200001, 372.5796101000001, 49.84131994000009),
      CubicToCommand(376.81716122000006, 52.31322476000011, 391.64859014000007,
          51.2538369800001, 374.69838566000004, 52.31322476000011),
      CubicToCommand(374.69838566000004, 52.31322476000011, 508.18124594000005,
          78.4447900000001, 509.59376298000006, 81.9760826000001),
      CubicToCommand(511.0062800200001, 85.5073752000001, 518.06886522,
          83.38859964000011, 518.06886522, 83.38859964000011),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(644.13601104, 67.14465368),
      CubicToCommand(644.13601104, 67.14465368, 626.12641878, 54.07887105999998,
          622.5951261800001, 54.07887105999998),
      CubicToCommand(619.0638335799999, 54.07887105999998, 597.16981946,
          36.06927879999998, 589.754105, 36.775537319999984),
      CubicToCommand(582.3383905400001, 37.48179583999999, 560.7975056800001,
          19.825332839999987, 512.4187970600001, 34.30363249999999),
      CubicToCommand(512.4187970600001, 34.30363249999999, 511.35940928,
          30.77233989999999, 517.7157359600001, 29.35982285999998),
      CubicToCommand(517.7157359600001, 29.35982285999998, 529.01587228,
          25.475401000000005, 529.7221308000001, 24.416013219999968),
      CubicToCommand(529.7221308000001, 24.416013219999968, 565.38818606,
          17.000298759999993, 578.10083942, 23.356625439999988),
      CubicToCommand(578.10083942, 23.356625439999988, 594.3447853800001,
          27.94730581999997, 605.2917924400001, 38.89431287999997),
      CubicToCommand(605.2917924400001, 38.89431287999997, 625.067031,
          44.54438103999996, 630.7170991600001, 42.778734739999976),
      CubicToCommand(630.7170991600001, 42.778734739999976, 646.2547866000001,
          46.66315659999998, 646.9610451200001, 49.84131993999998),
      CubicToCommand(646.9610451200001, 49.84131993999998, 657.20179366,
          55.13825883999996, 654.02363032, 59.72893921999997),
      CubicToCommand(654.02363032, 59.72893921999997, 654.7298888400001,
          62.55397329999997, 644.1360110400001, 67.14465367999998),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(622.118401679, 63.419139986999994),
      CubicToCommand(623.5485751819999, 64.531497156, 625.349534408,
          64.708061786, 626.408922188, 66.138235289),
      CubicToCommand(626.8326773, 66.685585642, 626.320639873,
          67.26824892100001, 625.7556330570001, 67.44481355100001),
      CubicToCommand(623.9193609050001, 67.992163904, 622.047775827,
          66.98574551299998, 620.034939045, 68.02747682999998),
      CubicToCommand(619.328680525, 68.398262553, 618.198666893,
          68.08044621900001, 617.2099049650001, 67.815599274),
      CubicToCommand(614.331901496, 67.03871490199998, 611.100768767,
          66.98574551299998, 608.1168265199999, 68.20404145999998),
      CubicToCommand(604.620846846, 66.208861141, 600.4539215780001,
          67.25059245799997, 596.7813772740001, 65.46728969499998),
      CubicToCommand(596.675438496, 65.43197676899999, 596.28699631,
          66.03229651099997, 596.145744606, 65.99698358499998),
      CubicToCommand(590.778179854, 63.96649033999998, 584.157006229,
          64.46087130399997, 579.86648572, 60.43519773999998),
      CubicToCommand(575.575965211, 59.71128275699999, 571.426696406,
          58.89908545899996, 567.1361758969999, 57.69844597499997),
      CubicToCommand(563.922699631, 56.79796636199998, 561.433138348,
          55.04997652499998, 558.572791342, 53.584490095999996),
      CubicToCommand(556.136199448, 52.330881223000006, 553.576012313,
          51.41274514699998, 550.856917011, 50.74179955299999),
      CubicToCommand(547.572814893, 49.94725871799997, 544.341682164,
          50.14147981099998, 541.004610657, 49.223343734999986),
      CubicToCommand(540.828046027, 49.188030809, 540.49257323,
          49.78835055099998, 540.351321526, 49.75303762499999),
      CubicToCommand(539.7863147099999, 49.55881653199998, 539.25662082,
          48.53474167799999, 538.956460949, 48.623023992999975),
      CubicToCommand(535.990175165, 49.54116006899997, 533.359362178,
          47.82848315799998, 530.42838932, 48.428802899999994),
      CubicToCommand(528.344926686, 46.27471441399999, 525.30801505,
          46.69846952599997, 522.571263285, 45.921585153999985),
      CubicToCommand(517.3272937739999, 44.42078579899999, 511.7655079289999,
          46.66315659999998, 506.41559964, 44.89751029999999),
      CubicToCommand(513.6724059329999, 41.64872110799996, 521.9532870799999,
          43.820466056999976, 529.1218110579999, 40.16557821599997),
      CubicToCommand(533.2357669369999, 38.08211558199994, 537.932386095,
          40.02432651199996, 542.4700970859999, 38.682435323999954),
      CubicToCommand(543.335263773, 38.417588378999966, 544.55355972,
          38.06445911899996, 545.25981824, 39.24744213999995),
      CubicToCommand(545.5070087219999, 39.00025165799994, 545.8248250559999,
          38.59415300899994, 545.9307638339999, 38.629465934999956),
      CubicToCommand(550.238940806, 40.67761564299997, 554.3352402219999,
          42.91998644399996, 558.7140430459999, 44.80922798499995),
      CubicToCommand(559.3143627879999, 45.074074929999966, 560.26781179,
          44.65031981799996, 560.709223365, 45.02110554099997),
      CubicToCommand(563.393005741, 47.157537563999966, 566.818359563,
          46.980972933999965, 569.2726079199999, 49.13506141999997),
      CubicToCommand(572.27420663, 48.252238269999964, 575.434713507,
          48.92318386399995, 578.489281606, 47.810826694999975),
      CubicToCommand(578.6305333099999, 47.775513768999986, 579.0366319589999,
          48.37583351099994, 579.089601348, 48.34052058499995),
      CubicToCommand(581.1024381299999, 47.016285859999954, 583.132931375,
          47.49301036099996, 584.704356582, 48.02270425099994),
      CubicToCommand(585.304676324, 48.234581806999955, 586.470002882,
          48.675993381999945, 587.017353235, 48.79958862299995),
      CubicToCommand(588.994877091, 49.27631312399993, 590.5133329089999,
          50.123823347999945, 592.5967955429999, 50.45929614499994),
      CubicToCommand(592.791016636, 50.49460907099993, 593.126489433,
          49.894289328999946, 593.2500846739999, 49.929602254999935),
      CubicToCommand(595.22760853, 50.70648662699995, 597.063880682,
          50.61820431199996, 598.2292072399999, 52.66635401999994),
      CubicToCommand(598.476397722, 52.419163537999935, 598.7589011299999,
          52.013064888999935, 598.900152834, 52.04837781499995),
      CubicToCommand(600.7187685229999, 52.64869755699996, 601.866438618,
          53.99058874499994, 603.808649548, 54.41434385699995),
      CubicToCommand(604.6561597719999, 54.59090848699995, 605.7508604779999,
          55.70326565599996, 606.757278869, 56.02108198999994),
      CubicToCommand(610.9771735259999, 57.31000378899995, 614.243619181,
          60.01144262799997, 618.1103845779999, 61.58286783499997),
      CubicToCommand(619.452275766, 62.13021818799996, 621.0060445099999,
          62.55397329999997, 622.1184016789999, 63.419139986999966),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(486.80986312479996, 38.29399313800002),
      CubicToCommand(482.36396574139997, 35.257081502000005, 478.18291530299996,
          33.29721410900001, 473.8712070384, 30.13670723200002),
      CubicToCommand(473.55162505809994, 29.90717321300002, 472.9159923901,
          30.207333084000027, 472.55933183749994, 29.995455528000008),
      CubicToCommand(470.78132601339996, 28.91841128499999, 469.213432099,
          27.894336431000028, 467.4795674324, 26.658384021000046),
      CubicToCommand(466.5278840767, 25.98743842700003, 465.0782884644,
          26.005094890000038, 464.181340144, 25.54602685200004),
      CubicToCommand(459.6895359568, 23.268343125000058, 455.04765183409995,
          22.279581197000056, 450.62117656, 20.178462100000047),
      CubicToCommand(451.8253473366, 19.04844846800009, 453.8064024852,
          19.48986004300008, 454.85872768, 18.059686540000087),
      CubicToCommand(455.2030287085, 18.554067504000074, 455.62325252790004,
          19.04844846800009, 456.2465256718, 18.712975671000095),
      CubicToCommand(459.2092801632, 17.12389400100008, 462.47572581820003,
          16.859047056000065, 465.434949017, 17.017955223000058),
      CubicToCommand(468.4436103122, 17.17686339000008, 471.4805219482,
          17.706557280000055, 474.6145441307, 18.200938244000042),
      CubicToCommand(475.1565975448, 18.27156409600002, 475.5079611585,
          19.189700172000045, 476.0782649134, 19.366264802000046),
      CubicToCommand(480.0121248698, 20.53159136000002, 484.23025388049996,
          19.613455284000025, 487.9716583902, 21.096598176000015),
      CubicToCommand(490.7808016535, 22.20895534500002, 493.5528663445,
          23.656785310999993, 495.7405021102, 25.899156112000014),
      CubicToCommand(496.1854449778, 26.358224150000012, 495.6116099303,
          26.905574502999997, 495.1172289663, 27.24104730000002),
      CubicToCommand(495.80229973070004, 27.04682620699998, 496.28432117060004,
          27.417611929999993, 496.48030790990003, 27.964962283000006),
      CubicToCommand(496.62862219910005, 28.388717395000015, 496.62862219910005,
          28.91841128499999, 496.48030790990003, 29.342166397),
      CubicToCommand(496.28255552430005, 29.889516750000013, 495.7899402066,
          30.066081379999986, 495.1295884904, 30.154363695),
      CubicToCommand(492.6453241463, 30.489836491999995, 495.77404938990003,
          28.053244597999964, 494.53809697990005, 28.847785433000013),
      CubicToCommand(492.29042924000004, 30.295615398999985, 493.60760137980003,
          32.767520219000005, 492.2921948863, 35.00989102),
      CubicToCommand(491.79781392230007, 34.674418223, 491.3917152733,
          34.28597603699998, 491.5859363663, 33.597373979999986),
      CubicToCommand(491.9990976005, 34.51551005599998, 490.93617852790004,
          35.027547483000006, 490.6395499495, 35.592554299),
      CubicToCommand(489.959776124, 36.863819635, 488.37246010030003,
          39.37103738099998, 486.8098631248, 38.29399313799999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(429.42988966739995, 51.271493443),
      CubicToCommand(423.86104123719997, 49.876632865999994, 418.47582002219997,
          50.070853959000004, 413.15063078139997, 47.810826695),
      CubicToCommand(413.03233247929995, 47.775513769000014, 412.6385933544,
          48.375833510999996, 412.5255919912, 48.34052058500001),
      CubicToCommand(410.11371914539995, 47.28113280500003, 408.492855842,
          45.58611235700002, 406.59302042319996, 43.73218374200002),
      CubicToCommand(404.9809853513, 42.160758535000014, 402.0535437859,
          42.84936059200001, 399.8041103997, 41.98419390500001),
      CubicToCommand(399.2320409985, 41.77231634900002, 398.8736147996,
          40.871836736000034, 398.34215526329996, 40.80121088400003),
      CubicToCommand(396.18983242359997, 40.51870747600003, 394.5530783035,
          38.84134349100003, 392.70797791999996, 37.83492509999999),
      CubicToCommand(396.83252767679994, 36.42240806000001, 401.08950090609994,
          36.49303391199999, 405.43652209669995, 35.80443185499999),
      CubicToCommand(405.6360401286, 35.769118929, 405.89205884209997,
          36.351782208, 406.12688979999996, 36.351782208),
      CubicToCommand(406.36701769679996, 36.351782208, 406.59655171579993,
          35.945683559, 406.83314831999996, 35.71614954),
      CubicToCommand(407.1774493485, 36.21053050399999, 407.7106745310999,
          36.79319378299999, 408.16444563019996, 36.334125744999994),
      CubicToCommand(409.1320198026, 35.38067674299998, 410.11371914539995,
          35.71614954, 411.06716814739997, 35.78677539199998),
      CubicToCommand(411.3214212145999, 35.80443185499999, 411.54212700209996,
          36.351782207999975, 411.77695795999995, 36.351782207999975),
      CubicToCommand(412.01708585679995, 36.351782207999975, 412.24838552209997,
          35.78677539199998, 412.48321647999995, 35.78677539199998),
      CubicToCommand(412.72334437679996, 35.78677539199998, 412.95464404209997,
          36.351782207999975, 413.18947499999996, 36.351782207999975),
      CubicToCommand(413.42960289679996, 36.351782207999975, 413.65913691579993,
          35.945683558999974, 413.89573351999996, 35.716149539999975),
      CubicToCommand(415.11756075959994, 37.09335365399997, 416.68015773509995,
          36.122248188999976, 418.13151899369996, 36.44006452299996),
      CubicToCommand(419.9642598531, 36.82850670899998, 420.43568741519994,
          38.858999953999984, 422.33199154139993, 39.38869384399996),
      CubicToCommand(430.65701384589994, 41.68403403399998, 437.96149258899993,
          45.48017357899997, 445.6650073958999, 49.17037434599999),
      CubicToCommand(446.20706081, 49.417564827999996, 446.57784653299996,
          49.858976402999986, 446.38362543999995, 50.54757845999998),
      CubicToCommand(446.8550530020999, 50.54757845999998, 447.40770029399994,
          50.38867029299999, 447.74317309099996, 50.61820431199999),
      CubicToCommand(449.61122687639994, 51.92478257399998, 451.4492646747,
          52.87823157599999, 452.67992014579994, 54.82044250599998),
      CubicToCommand(453.06129974659996, 55.42076224799999, 452.48040211389997,
          56.144677230999974, 452.06900652599995, 56.05639491599999),
      CubicToCommand(444.24895906329994, 54.290748616, 437.17577998549996,
          53.213704372999985, 429.42988966739995, 51.271493443),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(404.9580319494, 129.3324820123),
      CubicToCommand(402.14712303979996, 127.18015917260001, 401.11598560059997,
          123.5941315373, 399.12433657419996, 120.43009336770001),
      CubicToCommand(398.746488266, 119.8297736257, 399.2302753522,
          119.27536068750001, 399.7899852293, 119.1182181668),
      CubicToCommand(400.7787471573, 118.8374804051, 401.7374930982,
          119.68145933650001, 402.4596424349, 120.03811988910002),
      CubicToCommand(405.54069522839995, 121.5601069997, 408.2509622989,
          123.75303970430002, 411.77695796, 123.99846454000001),
      CubicToCommand(415.290594097, 127.94291837419999, 422.812247335,
          128.6226921997, 422.82460685909996, 134.59234234000002),
      CubicToCommand(422.82637250539995, 136.10903251169998, 420.30502958899996,
          134.4881692083, 419.54580167999995, 136.00485938),
      CubicToCommand(415.2182025987, 134.2339161411, 411.00007358799996,
          134.41577771, 406.797835394, 131.8255745879),
      CubicToCommand(405.7084316269, 131.15286334759998, 406.29109490589997,
          130.3530255737, 404.9580319494, 129.33248201229998),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(356.33566413999995, 36.49303391199999),
      CubicToCommand(356.57402639049997, 36.49303391199999, 368.9882855258,
          36.916789023999996, 368.9582695387, 37.11101011699998),
      CubicToCommand(368.87881545519997, 37.65836046999999, 355.2303695562,
          39.51228908499999, 354.587674303, 39.21212921399999),
      CubicToCommand(354.2981083098, 39.070877509999974, 341.03457330419997,
          43.36139801899998, 340.7979767, 43.13186399999998),
      CubicToCommand(341.2711699084, 42.88467351799997, 355.8660022242,
          36.49303391199996, 356.33566414, 36.49303391199996),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(383.52661716, 53.72574180000001),
      CubicToCommand(383.52661716, 53.72574180000001, 357.39505191999996,
          56.903905140000006, 349.6262082, 59.022680699999995),
      CubicToCommand(341.85736448, 61.14145626000001, 309.01634329999996,
          74.56036814000001, 303.7194044, 78.09166074000001),
      CubicToCommand(303.7194044, 78.09166074000001, 280.05974398, 87.62615076,
          250.04375688, 122.93907675999998),
      CubicToCommand(250.04375688, 122.93907675999998, 263.46266876,
          116.93587933999999, 267.34709062, 111.99206969999997),
      CubicToCommand(267.34709062, 111.99206969999997, 291.3598803,
          89.74492631999999, 291.00675104, 94.33560669999997),
      CubicToCommand(291.00675104, 94.33560669999997, 312.5476359,
          79.15104851999999, 311.48824812, 83.03547037999996),
      CubicToCommand(311.48824812, 83.03547037999996, 354.57001784,
          63.26023181999997, 351.03872523999996, 68.91029997999996),
      CubicToCommand(351.03872523999996, 68.91029997999996, 389.17668532,
          60.78832699999998, 387.41103902, 64.31961959999998),
      CubicToCommand(387.41103902, 64.31961959999998, 420.60518945999996,
          72.08846331999999, 415.66137982, 72.44159257999996),
      CubicToCommand(415.66137982, 72.44159257999996, 405.42063128,
          74.56036813999998, 416.7207676, 80.91669481999998),
      CubicToCommand(416.7207676, 80.91669481999998, 410.71757018,
          88.68553853999998, 401.18308016, 81.62295333999998),
      CubicToCommand(391.64859013999995, 74.56036813999998, 396.94552904,
          78.44478999999998, 388.11729754, 80.21043629999997),
      CubicToCommand(388.11729754, 80.21043629999997, 383.52661716,
          81.62295333999998, 375.40464418, 74.56036813999998),
      CubicToCommand(375.40464418, 74.56036813999998, 365.51702489999997,
          66.43839516, 349.97933746, 72.79472183999997),
      CubicToCommand(349.97933746, 72.79472183999997, 295.95056067999997,
          95.04186521999998, 292.41926808, 96.10125299999999),
      CubicToCommand(292.41926808, 96.10125299999999, 286.0629414,
          101.04506263999997, 281.82539027999997, 107.40138931999999),
      CubicToCommand(281.82539027999997, 107.40138931999999, 271.58464174,
          115.17023304, 266.28770283999995, 117.64213785999999),
      CubicToCommand(266.28770283999995, 117.64213785999999, 243.6874302,
          138.12363494, 241.56865463999998, 140.59553975999998),
      CubicToCommand(241.56865463999998, 140.59553975999998, 235.56545721999998,
          149.77690051999997, 234.15294017999997, 150.48315903999998),
      CubicToCommand(234.15294017999997, 150.48315903999998, 245.45307649999995,
          143.77370309999998, 248.98436909999998, 140.24241049999998),
      CubicToCommand(248.98436909999998, 140.24241049999998, 273.70341729999996,
          122.58594749999997, 283.23790732, 121.17343045999999),
      CubicToCommand(283.23790732, 121.17343045999999, 291.00675104,
          115.87649155999998, 292.41926807999994, 113.40458673999998),
      CubicToCommand(292.41926807999994, 113.40458673999998, 317.8445748,
          97.16064077999997, 325.26028926, 97.16064077999997),
      CubicToCommand(325.26028926, 97.16064077999997, 341.50423521999994,
          106.34200153999998, 345.74178634, 93.98247743999997),
      CubicToCommand(345.74178634, 93.98247743999997, 355.98253487999995,
          90.80431409999997, 365.87015415999997, 92.92308965999999),
      CubicToCommand(365.87015415999997, 92.92308965999999, 371.52022231999996,
          88.33240928000001, 370.10770527999995, 84.44798742),
      CubicToCommand(370.10770527999995, 84.44798742, 372.93273935999997,
          81.26982408, 374.69838566, 87.97928002),
      CubicToCommand(374.69838566, 87.97928002, 380.70158308, 94.33560669999997,
          389.17668531999993, 90.80431409999997),
      CubicToCommand(389.17668531999993, 90.80431409999997, 396.23927052,
          90.45118483999997, 392.70797791999996, 94.68873595999997),
      CubicToCommand(392.70797791999996, 94.68873595999997, 384.93913419999996,
          101.39819189999997, 364.10450785999996, 101.75132115999997),
      CubicToCommand(364.10450785999996, 101.75132115999997, 342.21049373999995,
          102.81070893999998, 313.25389441999994, 116.22962081999998),
      CubicToCommand(313.25389441999994, 116.22962081999998, 260.63763467999996,
          134.59234234000002, 244.39368871999994, 152.95506386),
      CubicToCommand(244.39368871999994, 152.95506386, 233.09355239999996,
          168.49275129999998, 223.55906237999997, 170.61152685999997),
      CubicToCommand(223.55906237999997, 170.61152685999997, 213.31831383999997,
          172.02404389999998, 202.72443603999997, 185.08982651999997),
      CubicToCommand(202.72443603999997, 185.08982651999997, 220.02776977999997,
          174.84907798, 235.91858647999996, 174.84907798),
      CubicToCommand(235.91858647999996, 174.84907798, 242.98117167999996,
          170.61152686, 236.27171574, 176.96785354000002),
      CubicToCommand(236.27171574, 176.96785354000002, 229.91538905999997,
          190.38676542000002, 232.74042313999996, 199.92125544),
      CubicToCommand(232.74042313999996, 199.92125544, 231.68103535999995,
          209.1026162, 230.26851831999997, 211.92765028),
      CubicToCommand(230.26851831999997, 211.92765028, 216.49647718,
          234.52792292, 216.49647718, 238.76547404000002),
      CubicToCommand(216.49647718, 243.00302516, 218.61525274, 260.3063589,
          219.32151125999997, 261.36574668000003),
      CubicToCommand(220.02776977999997, 262.42513446, 217.55586495999998,
          258.5407126, 224.26532089999998, 262.77826372),
      CubicToCommand(230.97477683999998, 267.01581484, 235.91858648,
          269.84084892, 237.33110351999997, 274.78465856),
      CubicToCommand(238.74362055999995, 279.7284682, 233.79981091999997,
          265.25016854, 233.44668165999997, 262.0720052),
      CubicToCommand(233.09355239999996, 258.89384186, 225.67783793999996,
          246.1811885, 227.09035497999997, 241.94363738),
      CubicToCommand(227.09035497999997, 241.94363738, 228.85600128,
          243.70928368, 230.26851831999994, 246.1811885),
      CubicToCommand(230.26851831999994, 246.1811885, 229.20913053999996,
          245.12180072, 230.26851831999994, 238.76547404000002),
      CubicToCommand(230.26851831999994, 238.76547404000002, 231.68103535999995,
          229.58411328, 234.15294017999997, 223.93404512),
      CubicToCommand(236.624845, 218.28397696000002, 240.15613759999997,
          211.57452102000002, 240.86239611999997, 210.16200398),
      CubicToCommand(241.56865463999998, 208.74948694, 241.56865463999998,
          198.5087384, 244.04055945999994, 203.09941878),
      LineToCommand(250.04375687999993, 207.69009916),
      CubicToCommand(250.04375687999993, 207.69009916, 245.09994723999995,
          203.09941878, 248.98436909999995, 199.21499692),
      CubicToCommand(248.98436909999995, 199.21499692, 247.21872279999997,
          189.32737764, 250.39688613999994, 184.73669726000003),
      CubicToCommand(250.39688613999994, 184.73669726000003, 262.7564102399999,
          169.90526834000002, 265.58144431999995, 168.13962204),
      CubicToCommand(268.40647839999997, 166.37397574000002, 265.93457357999995,
          167.08023426, 265.93457357999995, 167.08023426),
      CubicToCommand(265.93457357999995, 167.08023426, 276.52845138,
          159.6645198, 266.28770283999995, 162.48955388000002),
      CubicToCommand(266.28770283999995, 162.48955388000002, 259.22511763999995,
          165.31458796, 253.92817873999996, 165.31458796),
      CubicToCommand(253.92817873999996, 165.31458796, 240.50926685999997,
          168.84588056, 247.57185205999997, 161.4301661),
      CubicToCommand(254.63443725999997, 154.01445164, 272.29090025999994,
          144.47996161999998, 279.00035619999994, 144.83309088000001),
      LineToCommand(280.41287323999995, 147.65812496),
      LineToCommand(300.18811179999994, 143.42057384000003),
      LineToCommand(298.06933624, 144.83309088000001),
      CubicToCommand(298.06933624, 144.83309088000001, 297.71620698,
          144.47996161999998, 305.13192144, 143.7737031),
      CubicToCommand(312.54763589999993, 143.06744458000003, 322.78838443999996,
          145.5393494, 325.26028926, 142.36118606000002),
      CubicToCommand(327.73219407999994, 139.18302272, 333.73539149999993,
          137.41737642, 333.02913298, 139.88928124),
      CubicToCommand(332.32287446, 142.36118605999997, 331.9697452,
          145.89247866, 331.9697452, 145.89247866),
      CubicToCommand(331.9697452, 145.89247866, 340.79797669999994,
          135.65173012, 339.73858892, 139.53615198),
      CubicToCommand(338.67920114, 143.42057384, 324.20090147999997,
          152.6019346, 321.72899665999995, 163.54894166),
      LineToCommand(340.09171818, 149.07064200000002),
      LineToCommand(346.44804486, 143.7737031),
      CubicToCommand(346.44804486, 143.7737031, 352.80437154, 147.65812496,
          353.1575008, 144.83309088000001),
      CubicToCommand(353.51063006, 142.00805680000002, 361.63260303999994,
          131.76730826, 363.75137859999995, 132.12043752),
      CubicToCommand(365.87015415999997, 132.47356678000003, 369.40144675999994,
          127.52975714000003, 369.04831749999994, 132.12043752),
      CubicToCommand(368.69518824, 136.7111179, 382.11410012, 146.24560792,
          382.11410012, 146.24560792),
      CubicToCommand(382.11410012, 146.24560792, 387.76416828,
          143.06744458000003, 390.2360731, 145.53934940000002),
      CubicToCommand(392.70797791999996, 148.01125422, 400.12369237999997,
          110.57955266000002, 400.12369237999997, 110.57955266000002),
      LineToCommand(444.26484988, 91.86370188000001),
      LineToCommand(521.24702856, 85.86050446000002),
      LineToCommand(491.23280710629996, 73.85410962),
      LineToCommand(383.52661716, 53.72574180000001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(415.66137982, 405.0893555),
      CubicToCommand(415.66137982, 405.0893555, 389.17668532, 375.42649766,
          374.3452564, 370.83581728),
      CubicToCommand(374.3452564, 370.83581728, 350.68559597999996,
          358.82942244000003, 307.250697, 372.60146358)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(368.69518824, 368.36391246),
      CubicToCommand(368.69518824, 368.36391246, 324.20090147999997,
          354.23874206, 297.00994846, 361.65445652),
      CubicToCommand(297.00994846, 361.65445652, 264.52205654, 365.18574912,
          249.69062762, 389.55166806)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(362.33886156, 366.24513690000003),
      CubicToCommand(362.33886156, 366.24513690000003, 332.32287446,
          353.53248354, 306.19130922, 349.64806168),
      CubicToCommand(306.19130922, 349.64806168, 276.88158064, 345.0573813,
          247.57185205999997, 357.77003466),
      CubicToCommand(247.57185205999997, 357.77003466, 226.03096719999996,
          368.36391246, 216.49647717999997, 386.37350472)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(364.10450785999996, 366.95139542),
      CubicToCommand(364.10450785999996, 366.95139542, 336.91355483999996,
          347.52928612, 335.14790854, 345.0573813),
      CubicToCommand(335.14790854, 345.0573813, 322.78838443999996, 325.635272,
          299.83498254, 324.92901348),
      CubicToCommand(299.83498254, 324.92901348, 262.05015172, 326.34153052,
          231.68103535999998, 340.46670092)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(361.8003394385, 351.0729382441),
      CubicToCommand(364.5229660331, 353.656078781, 412.13008721999995,
          404.73622624, 412.13008721999995, 404.73622624),
      CubicToCommand(474.28083698, 469.35888082, 424.84274058, 408.97377736,
          424.84274058, 408.97377736),
      CubicToCommand(411.42382869999994, 400.49867512000003, 395.17988274,
          367.30452468, 395.17988274, 367.30452468),
      CubicToCommand(393.06110717999996, 362.36071504, 419.89893093999996,
          380.01717804, 419.89893093999996, 380.01717804),
      CubicToCommand(426.96151613999996, 381.42969508, 450.97430582,
          415.33010404000004, 450.97430582, 415.33010404000004),
      CubicToCommand(438.96791098, 411.09255292, 447.44301322, 423.80520628,
          447.44301322, 423.80520628),
      CubicToCommand(452.38682286, 427.33649888, 488.4077730263, 454.88058116,
          488.4077730263, 454.88058116),
      CubicToCommand(494.76409970629993, 461.94316635999996, 501.82491926,
          464.76820044, 501.82491926, 464.76820044),
      CubicToCommand(526.54396746, 455.58683967999997, 515.24383114,
          478.89337084, 515.24383114, 478.89337084),
      CubicToCommand(519.4813822599999, 490.89976568, 529.36900154, 470.4182686,
          529.36900154, 470.4182686),
      CubicToCommand(549.1442400999999, 440.75541076, 520.1876407799999,
          444.99296187999994, 520.1876407799999, 444.99296187999994),
      CubicToCommand(467.21825177999995, 449.93677152, 455.21185693999996,
          421.68643072, 455.21185693999996, 421.68643072),
      CubicToCommand(450.9743058199999, 417.44887959999994, 466.51199325999994,
          421.68643072, 466.51199325999994, 421.68643072),
      CubicToCommand(481.34518782629993, 425.21772332, 453.79933989999995,
          399.79241659999997, 453.79933989999995, 399.79241659999997),
      CubicToCommand(458.03689102, 399.79241659999997, 474.28083698,
          411.79881143999995, 474.28083698, 411.79881143999995),
      CubicToCommand(492.64532414629997, 428.0427573999999, 496.17661674629994,
          424.51146479999994, 496.17661674629994, 424.51146479999994),
      CubicToCommand(527.9564845, 408.97377736, 546.3192060199999, 422.39268924,
          546.3192060199999, 422.39268924),
      CubicToCommand(549.8504986199999, 425.21772331999995, 539.96287934,
          437.22411816, 542.78791342, 446.40547891999995),
      CubicToCommand(545.6129475, 455.5868396799999, 554.08804974, 477.4808538,
          554.08804974, 477.4808538),
      CubicToCommand(549.8504986199999, 480.30588787999994, 550.55675714,
          499.37486791999993, 550.55675714, 499.37486791999993),
      CubicToCommand(580.21961498, 540.3378620799999, 563.2694104999999,
          536.8065694799999, 563.2694104999999, 536.8065694799999),
      CubicToCommand(535.7253282199999, 536.1003109599999, 561.8568934599999,
          549.5192228399999, 561.8568934599999, 549.5192228399999),
      CubicToCommand(567.5069616199999, 553.0505154399999, 583.04464906,
          565.7631687999999, 583.04464906, 565.7631687999999),
      CubicToCommand(578.1008394199998, 563.6443932399999, 575.2758053399999,
          572.825754, 575.2758053399999, 572.825754),
      CubicToCommand(583.7509075799999, 579.8883391999999, 578.80709794,
          588.36344144, 578.80709794, 588.36344144),
      CubicToCommand(568.2132201399999, 590.4822169999999, 566.09444458,
          597.5448021999999, 566.09444458, 597.5448021999999),
      CubicToCommand(578.1008394199999, 611.6699725999999, 560.4443764199999,
          612.3762311199999, 560.4443764199999, 612.3762311199999),
      CubicToCommand(566.8007031, 620.1450748399999, 558.3256008599999,
          641.33283044, 558.3256008599999, 641.33283044),
      CubicToCommand(549.8504986199999, 641.33283044, 538.5503623,
          651.2204497199999, 538.5503623, 651.2204497199999),
      CubicToCommand(542.78791342, 659.69555196, 524.4251919, 669.58317124,
          524.4251919, 669.58317124),
      CubicToCommand(509.59376297999995, 672.4082053199999, 514.53757262,
          684.41460016, 514.53757262, 684.41460016),
      CubicToCommand(500.4141678663, 695.0084779599999, 496.17661674629994,
          723.2588187599999, 496.17661674629994, 723.2588187599999),
      CubicToCommand(494.76409970629993, 741.6215402799999, 490.52654858629995,
          747.2716084399999, 499.70790934629997, 743.7403158399999),
      CubicToCommand(508.88750445999995, 740.20902324, 507.47498741999993,
          718.31500912, 507.47498741999993, 718.31500912),
      CubicToCommand(499.00165082629997, 690.77092684, 574.5695468199999,
          662.52058604, 574.5695468199999, 662.52058604),
      CubicToCommand(581.63213202, 659.69555196, 583.04464906,
          650.5141911999999, 583.04464906, 650.5141911999999),
      CubicToCommand(586.5759416599999, 651.2204497199999, 602.1136291,
          664.6393615999999, 602.1136291, 664.6393615999999),
      CubicToCommand(615.53254098, 684.41460016, 616.2387994999999, 668.1706542,
          616.2387994999999, 668.1706542),
      CubicToCommand(618.3575750599999, 661.81432752, 615.53254098,
          651.2204497199999, 615.53254098, 651.2204497199999),
      CubicToCommand(626.12641878, 613.08248964, 601.4073705799999,
          601.78235332, 601.4073705799999, 601.78235332),
      CubicToCommand(583.75090758, 542.4566376399999, 608.46995578,
          557.28806656, 608.46995578, 557.28806656),
      CubicToCommand(613.41376542, 567.17568584, 632.4827454599999, 576.3570466,
          632.4827454599999, 576.3570466),
      LineToCommand(638.8390721399999, 572.11949548),
      CubicToCommand(636.01403806, 563.64439324, 650.84546698, 553.05051544,
          650.84546698, 553.05051544),
      CubicToCommand(655.78927662, 564.35065176, 666.38315442, 550.22548136,
          666.38315442, 550.22548136),
      CubicToCommand(672.7394810999999, 507.14371164, 694.63349522,
          532.56901836, 694.63349522, 532.56901836),
      CubicToCommand(701.69608042, 534.68779392, 703.81485598, 522.68139908,
          703.81485598, 522.68139908),
      CubicToCommand(710.1711826599999, 504.31867755999997, 703.81485598,
          480.30588788, 703.81485598, 480.30588788),
      CubicToCommand(710.1711826599999, 479.59962936, 727.12138714,
          490.19350715999997, 727.12138714, 490.19350715999997),
      CubicToCommand(732.06519678, 483.83718048000003, 715.8212508199999,
          454.17432264, 722.88383602, 458.41187376),
      CubicToCommand(729.9464212199999, 462.64942487999997, 737.71526494,
          465.47445896, 737.71526494, 465.47445896),
      CubicToCommand(739.12778198, 461.94316635999996, 721.47131898,
          440.04915224, 721.47131898, 440.04915224),
      CubicToCommand(713.70247526, 435.1053426, 704.5211145, 399.08615807999996,
          704.5211145, 399.08615807999996),
      CubicToCommand(717.23376786, 405.44248475999996, 699.5773048599999,
          378.60466099999996, 699.5773048599999, 378.60466099999996),
      CubicToCommand(699.5773048599999, 372.95459284, 710.1711826599999,
          353.17935428, 710.1711826599999, 353.17935428),
      CubicToCommand(708.7586656199999, 341.17295944, 710.1711826599999,
          341.87921796, 710.1711826599999, 341.87921796),
      CubicToCommand(715.1149923, 343.99799352, 729.2401626999999, 346.8230276,
          717.23376786, 335.52289127999995),
      CubicToCommand(705.22737302, 324.22275496, 718.6462849, 315.74765272,
          718.6462849, 315.74765272),
      CubicToCommand(726.4151286199999, 310.80384308, 702.4023389399999,
          311.5101016, 702.4023389399999, 311.5101016),
      CubicToCommand(693.22097818, 303.74125788, 693.9272367, 296.67867268,
          693.9272367, 296.67867268),
      CubicToCommand(708.0524071, 300.20996528, 682.62710038,
          274.78465855999997, 678.38954926, 268.42833188),
      CubicToCommand(674.1519981399999, 262.0720052, 691.10220262, 252.89064444,
          691.10220262, 252.89064444),
      CubicToCommand(714.4087337799999, 246.53431776, 693.9272366999999,
          240.8842496, 693.9272366999999, 240.8842496),
      CubicToCommand(659.3205692199999, 241.59050811999998, 678.38954926,
          222.52152808, 678.38954926, 222.52152808),
      CubicToCommand(688.9834270599999, 223.2277866, 686.1583929799999,
          218.99023548, 686.1583929799999, 218.99023548),
      CubicToCommand(676.97703222, 216.87145992, 660.0268277399998, 205.5713236,
          660.0268277399998, 205.5713236),
      CubicToCommand(652.9642425399999, 199.21499691999998, 659.3205692199999,
          200.62751396, 659.3205692199999, 200.62751396),
      CubicToCommand(688.9834270599999, 202.74628952, 638.1328136199999,
          182.97105095999999, 638.1328136199999, 182.97105095999999),
      CubicToCommand(652.2579840199999, 182.97105095999999, 620.47635062,
          164.60832943999998, 620.47635062, 164.60832943999998),
      CubicToCommand(616.9450580199998, 161.78329535999998, 611.29498986,
          148.36438348000001, 611.29498986, 148.36438348000001),
      CubicToCommand(600.7011120599999, 139.18302272, 592.22600982,
          127.17662788, 592.22600982, 127.17662788),
      CubicToCommand(591.5197512999998, 119.40778415999998, 583.04464906,
          110.93268192, 583.04464906, 110.93268192),
      CubicToCommand(562.5631519799999, 86.91989224, 552.6755327,
          87.62615075999997, 552.6755327, 87.62615075999997),
      CubicToCommand(526.54396746, 81.26982408, 517.3626066999999,
          82.68234111999999, 517.3626066999999, 82.68234111999999),
      LineToCommand(424.13648205999993, 90.45118484),
      CubicToCommand(377.52341973999995, 113.05145747999998, 391.29546087999995,
          150.13002978, 391.29546087999995, 150.13002978),
      CubicToCommand(402.59559719999993, 164.96145869999998, 418.83954315999995,
          158.25200275999998, 418.83954315999995, 158.25200275999998),
      CubicToCommand(426.96151613999996, 147.3049957, 447.44301321999995,
          151.18941755999998, 447.44301321999995, 151.18941755999998),
      CubicToCommand(483.46396338629995, 156.83948572, 478.87328300629997,
          150.48315904, 478.87328300629997, 150.48315904),
      CubicToCommand(474.63573188629994, 142.36118606, 446.03049617999994,
          131.414179, 445.67736691999994, 130.35479121999998),
      CubicToCommand(445.32423765999994, 129.29540343999997, 429.7865502199999,
          123.29220601999998, 429.7865502199999, 123.29220601999998),
      CubicToCommand(424.48961131999994, 121.17343045999999, 416.72076759999993,
          104.92948449999997, 416.72076759999993, 104.92948449999997),
      CubicToCommand(411.07069943999994, 98.92628707999998, 438.96791097999994,
          109.16703561999998, 438.96791097999994, 109.16703561999998),
      CubicToCommand(436.8491354199999, 110.93268192, 449.91491804,
          117.99526712, 449.91491804, 117.99526712),
      CubicToCommand(480.63892930629993, 116.22962081999998, 499.35478008629997,
          135.29860085999996, 499.35478008629997, 135.29860085999996),
      CubicToCommand(518.42199448, 164.60832943999998, 518.7751237399999,
          150.13002977999997, 518.7751237399999, 150.13002977999997),
      CubicToCommand(523.71893338, 133.53295455999998, 502.88430703999995,
          96.10125299999999, 502.88430703999995, 96.10125299999999),
      CubicToCommand(503.59056555999996, 92.56996039999999, 518.0688652199999,
          104.22322597999997, 518.0688652199999, 104.22322597999997),
      CubicToCommand(520.54077004, 100.69193337999997, 521.9532870799999,
          110.93268191999996, 521.9532870799999, 110.93268191999996),
      CubicToCommand(522.3064163399999, 115.17023303999997, 529.0158722799999,
          129.29540343999997, 529.0158722799999, 129.29540343999997),
      CubicToCommand(533.9596819199999, 152.24880534, 540.3160085999999,
          139.18302271999997, 540.3160085999999, 139.18302271999997),
      LineToCommand(548.4379815799999, 155.78009793999996),
      CubicToCommand(550.9098864, 160.37077831999997, 540.3160085999999,
          173.78969019999994, 540.3160085999999, 173.78969019999994),
      CubicToCommand(539.96287934, 178.73349983999995, 541.37539638,
          178.38037057999998, 531.4877770999999, 191.79928245999997),
      CubicToCommand(521.6001578199999, 205.21819433999997, 527.6033552399999,
          212.98703805999997, 527.6033552399999, 212.98703805999997),
      CubicToCommand(525.13145042, 224.64030363999996, 540.66913786,
          223.93404511999995, 540.66913786, 223.93404511999995),
      CubicToCommand(545.25981824, 227.81846697999995, 551.26301566,
          227.81846697999995, 551.26301566, 227.81846697999995),
      CubicToCommand(554.4411789999999, 231.34975957999995, 558.67873012,
          230.29037179999995, 558.67873012, 230.29037179999995),
      CubicToCommand(561.5037642, 223.58091585999995, 572.45077126,
          227.11220845999995, 572.45077126, 227.11220845999995),
      CubicToCommand(574.92267608, 222.87465733999994, 589.4009757399999,
          222.16839881999996, 589.4009757399999, 222.16839881999996),
      CubicToCommand(591.16662204, 217.57771843999996, 591.8728805599999,
          214.75268435999996, 597.87607798, 213.69329657999995),
      CubicToCommand(603.8792754, 212.63390879999997, 560.44437642,
          136.71111789999998, 560.44437642, 136.71111789999998),
      CubicToCommand(571.74451274, 135.29860085999996, 557.2662130799999,
          113.40458673999996, 557.2662130799999, 113.40458673999996),
      CubicToCommand(553.38179122, 101.75132115999995, 573.51015904,
          127.52975713999994, 577.3945808999999, 130.00166195999998),
      CubicToCommand(581.27900276, 132.47356677999997, 583.04464906,
          136.35798863999995, 580.21961498, 136.00485937999997),
      CubicToCommand(577.3945808999999, 135.65173012, 574.21641756,
          139.53615197999997, 576.6883223799999, 139.88928123999997),
      CubicToCommand(579.1602272, 140.24241049999998, 602.1136291, 166.727105,
          608.1168265199999, 184.73669725999997),
      CubicToCommand(614.12002394, 202.74628951999995, 624.71390174,
          209.80887471999998, 635.6609088, 220.40275251999998),
      CubicToCommand(646.6079158599999, 230.99663031999998, 645.19539882,
          273.72527077999996, 645.19539882, 273.72527077999996),
      CubicToCommand(644.4891402999999, 289.26295822, 655.0830181,
          307.97880899999996, 655.0830181, 307.97880899999996),
      CubicToCommand(658.6143107, 314.68826493999995, 651.1985962399999,
          346.8230276, 651.1985962399999, 346.8230276),
      CubicToCommand(647.66730364, 350.70744945999996, 650.13920846,
          352.1199665, 650.13920846, 352.1199665),
      CubicToCommand(651.90485476, 354.23874206, 663.9112496,
          377.54527321999996, 663.9112496, 377.54527321999996),
      CubicToCommand(660.7330862599999, 377.19214395999995, 667.0894129400001,
          383.54847064, 667.0894129400001, 383.54847064),
      CubicToCommand(676.2707737000001, 394.14234844, 664.9706373800001,
          388.84540954, 664.9706373800001, 388.84540954),
      CubicToCommand(654.37675958, 386.02037545999997, 666.73628368,
          403.32370919999994, 666.73628368, 403.32370919999994),
      CubicToCommand(668.8550592400001, 406.50187253999997, 652.96424254,
          398.37989956, 652.96424254, 398.37989956),
      CubicToCommand(636.7202965800001, 397.32051178, 657.20179366,
          410.03316513999994, 657.20179366, 410.03316513999994),
      CubicToCommand(672.3863518400001, 422.7458185, 652.2579840200001,
          414.97697478, 652.2579840200001, 414.97697478),
      CubicToCommand(644.1360110400001, 411.79881144, 649.7860792, 423.80520628,
          649.7860792, 423.80520628),
      CubicToCommand(655.43614736, 426.63024035999996, 685.8052637200001,
          438.98976445999995, 685.8052637200001, 438.98976445999995),
      CubicToCommand(686.51152224, 445.69922039999994, 681.21458334,
          454.52745189999996, 681.21458334, 454.52745189999996),
      CubicToCommand(681.9208418600001, 461.59003709999996, 678.03642,
          467.59323451999995, 678.03642, 467.59323451999995),
      CubicToCommand(675.91764444, 482.07153417999996, 674.85825666,
          483.48405121999997, 674.85825666, 483.48405121999997),
      CubicToCommand(667.4425422, 483.8371804799999, 654.37675958,
          508.20309941999994, 654.37675958, 508.20309941999994),
      CubicToCommand(651.1985962399999, 512.7937797999999, 633.18900398,
          533.9815354, 633.18900398, 533.9815354),
      CubicToCommand(629.65771138, 546.3410594999999, 597.87607798,
          533.6284061399999, 597.87607798, 533.6284061399999),
      CubicToCommand(586.2228124000001, 539.63160356, 589.754105,
          533.6284061399999, 589.754105, 533.6284061399999),
      CubicToCommand(589.0478464800001, 529.74398428, 597.52294872,
          519.15010648, 597.52294872, 519.15010648),
      CubicToCommand(609.88247282, 514.5594261, 605.2917924400001,
          495.49044605999995, 605.2917924400001, 495.49044605999995),
      CubicToCommand(612.35437764, 493.01854124, 592.57913908, 488.0747316,
          592.9322683400001, 485.95595604),
      CubicToCommand(593.2853976, 483.8371804799999, 603.52614614,
          481.36527565999995, 603.52614614, 481.36527565999995),
      CubicToCommand(617.65131654, 477.83398306, 609.88247282, 473.59643194,
          609.88247282, 473.59643194),
      CubicToCommand(608.82308504, 466.53384673999994, 614.12002394,
          456.64622746, 614.12002394, 456.64622746),
      CubicToCommand(634.6015210200001, 455.23371041999997, 614.12002394,
          426.63024036, 614.12002394, 426.63024036),
      CubicToCommand(595.0510439, 413.21132848, 593.2853976, 402.97057994,
          593.2853976, 402.97057994),
      CubicToCommand(615.53254098, 388.49228027999993, 601.0542413200001,
          366.59826616, 601.40737058, 360.24193948),
      CubicToCommand(601.76049984, 353.8856128, 603.8792754000001,
          315.74765271999996, 603.8792754000001, 315.74765271999996),
      CubicToCommand(600.3479828, 304.80064566, 595.0510439, 280.78785597999996,
          595.0510439, 280.78785597999996),
      CubicToCommand(598.9354657599999, 271.60649521999994, 612.00124838,
          249.35935183999996, 612.00124838, 249.35935183999996),
      CubicToCommand(616.94505802, 241.94363737999996, 632.4827454599999,
          233.46853513999997, 628.5983236, 228.17159623999996),
      CubicToCommand(624.71390174, 222.87465733999997, 610.9418606,
          226.05282067999997, 610.9418606, 226.05282067999997),
      CubicToCommand(597.16981946, 223.58091585999998, 598.22920724,
          232.76227661999997, 598.22920724, 232.76227661999997),
      CubicToCommand(595.40417316, 234.52792291999998, 593.99165612,
          243.35615441999997, 593.99165612, 243.35615441999997),
      CubicToCommand(592.7203907840001, 257.3630265179, 577.0414516400001,
          268.42833188, 577.0414516400001, 268.42833188),
      CubicToCommand(557.26621308, 279.37533893999995, 573.5101590400001,
          286.43792413999995, 573.5101590400001, 286.43792413999995),
      CubicToCommand(584.10403684, 298.09118972, 566.8007031,
          298.44431897999993, 566.8007031, 298.44431897999993),
      CubicToCommand(547.3785938000001, 295.26615563999997, 561.85689346,
          313.27574789999994, 561.85689346, 313.27574789999994),
      CubicToCommand(580.9258735000001, 335.87602053999996, 575.6289346000001,
          340.81983017999994, 575.6289346000001, 340.81983017999994),
      CubicToCommand(557.61934234, 342.58547647999995, 579.86648572,
          358.82942244, 579.86648572, 358.82942244),
      CubicToCommand(579.86648572, 358.82942244, 578.45396868, 355.29812984,
          578.8070979400001, 358.47629317999997),
      CubicToCommand(579.1602272, 361.65445651999994, 584.4571661,
          369.07017097999994, 585.86968314, 372.60146358),
      CubicToCommand(587.28220018, 376.13275618, 580.2196149800001,
          376.48588543999995, 580.2196149800001, 376.48588543999995),
      CubicToCommand(581.2790027600001, 393.43608992, 554.0880497400001,
          386.02037545999997, 554.0880497400001, 386.02037545999997),
      LineToCommand(551.2630156600001, 386.37350472),
      CubicToCommand(548.43798158, 386.72663398, 528.6627430200001,
          385.31411693999996, 518.4219944800001, 381.42969508),
      CubicToCommand(508.18124594000005, 377.54527322, 496.17661674630006,
          377.54527322, 496.17661674630006, 377.54527322),
      CubicToCommand(496.17661674630006, 377.54527322, 489.11403154630005,
          380.72343656, 475.6933540200001, 380.3703073),
      CubicToCommand(462.2744421400001, 380.01717804, 448.1492717400001,
          384.96098767999996, 448.1492717400001, 384.96098767999996),
      CubicToCommand(440.38042802000007, 384.25472915999995, 455.5649862000001,
          376.48588543999995, 455.9181154600001, 376.8390147),
      CubicToCommand(456.2712447200001, 377.19214395999995, 466.1588640000001,
          367.30452468, 452.0336936000001, 368.36391246),
      CubicToCommand(413.5479011989001, 371.2507441605, 394.4736242200001,
          353.17935428, 394.4736242200001, 353.17935428),
      CubicToCommand(390.94233162000006, 350.70744946, 386.3516512400001,
          345.76363982, 386.3516512400001, 345.76363982),
      CubicToCommand(368.69518824000005, 342.23234721999995, 388.8235560600001,
          367.65765394, 388.8235560600001, 367.65765394),
      CubicToCommand(390.94233162000006, 370.12955876, 388.47042680000004,
          371.89520505999997, 388.47042680000004, 371.89520505999997),
      CubicToCommand(387.0579097600001, 369.07017098, 373.2858686200001,
          359.53568096, 373.2858686200001, 359.53568096),
      CubicToCommand(368.3226368707001, 357.8177071101, 365.9160609638001,
          355.4623349459, 361.80033943850003, 351.0729382441),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(319.6102211, 330.57908164),
      CubicToCommand(319.6102211, 330.57908164, 340.09171818, 340.46670092,
          344.68239855999997, 345.41051056),
      CubicToCommand(349.27307893999995, 350.35432019999996, 373.99212714,
          370.48268802, 373.99212714, 370.48268802),
      CubicToCommand(373.99212714, 370.48268802, 364.45763711999996,
          366.95139542, 359.86695674, 363.77323208),
      CubicToCommand(355.27627636, 360.59506874, 336.20729631999995,
          346.11676908, 336.20729631999995, 346.11676908),
      CubicToCommand(336.20729631999995, 346.11676908, 329.49784037999996,
          335.52289128, 319.6102211, 330.57908164),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(217.18684488329995, 275.4962140189),
      CubicToCommand(217.78186768639998, 275.23489836650003, 216.85666902519998,
          270.4464656009, 216.49647718, 269.48771966),
      CubicToCommand(214.6919866614, 264.6745678462, 198.84001417999997,
          262.0720052, 198.84001417999997, 262.0720052),
      CubicToCommand(198.43921246989996, 264.4821123995, 198.34210192339998,
          267.30008389430003, 198.52926043119996, 270.1922125337),
      CubicToCommand(198.52926043119996, 270.1922125337, 207.12442661959994,
          279.9368144634, 217.18684488329995, 275.4962140189),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(217.18684488329995, 275.1430847589),
      CubicToCommand(216.39406969459998, 275.4220568743, 217.16036018879998,
          270.31580777470003, 216.84960643999997, 269.48771966),
      CubicToCommand(215.04511592139997, 264.67456784620003, 198.84001417999997,
          261.89544057, 198.84001417999997, 261.89544057),
      CubicToCommand(198.43921246989996, 264.3055477695, 198.34210192339998,
          267.1235192643, 198.52926043119996, 270.0156479037),
      CubicToCommand(198.52926043119996, 270.0156479037, 206.06503883959996,
          279.0539913134, 217.18684488329995, 275.1430847589),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(209.43389197999997, 275.3955721798),
      CubicToCommand(208.33036304249998, 275.3955721798, 207.43694601469997,
          273.3827353978, 207.43694601469997, 270.9002367),
      CubicToCommand(207.43694601469997, 268.4195036485, 208.33036304249998,
          266.4066668665, 209.43389197999997, 266.4066668665),
      CubicToCommand(210.53742091749996, 266.4066668665, 211.43260359159996,
          268.4195036485, 211.43260359159996, 270.9002367),
      CubicToCommand(211.43260359159996, 273.3827353978, 210.53742091749996,
          275.3955721798, 209.43389197999997, 275.3955721798),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(209.43389197999997, 270.9002367),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(128.92042069999997, 448.52425447999997),
      CubicToCommand(128.92042069999997, 448.52425447999997, 119.03280142,
          466.18071748, 162.82082966, 455.58683968),
      CubicToCommand(162.82082966, 455.58683968, 187.53987786, 453.46806412,
          191.77742897999997, 449.230513),
      CubicToCommand(193.89620453999999, 450.64303004, 208.6676014858,
          455.816373699, 213.67144309999998, 456.99935672000004),
      CubicToCommand(225.67783793999996, 459.8243908, 240.50926685999997,
          442.16792780000003, 240.50926685999997, 442.16792780000003),
      CubicToCommand(240.50926685999997, 442.16792780000003, 248.63123983999998,
          423.62864165, 253.57504947999996, 423.62864165),
      CubicToCommand(258.51885911999995, 423.62864165, 252.86879095999996,
          426.45367573, 252.86879095999996, 426.45367573),
      CubicToCommand(252.86879095999996, 426.45367573, 241.21552537999997,
          444.28670336, 241.92178389999995, 447.11173744),
      CubicToCommand(241.92178389999995, 447.11173744, 232.74042313999996,
          482.42466344, 204.49008233999996, 483.83718048000003),
      CubicToCommand(204.49008233999996, 483.83718048000003, 175.97489459499994,
          485.514544465, 178.35851709999994, 495.84357532),
      CubicToCommand(178.35851709999994, 495.84357532, 193.89620453999996,
          491.6060242, 198.13375565999996, 495.84357532),
      CubicToCommand(198.13375565999996, 495.84357532, 217.20273569999995,
          495.1373168, 203.07756529999995, 506.43745312),
      LineToCommand(191.07117045999996, 526.9189502),
      CubicToCommand(191.07117045999996, 526.9189502, 191.31836094199997,
          533.840283696, 173.41470745999996, 527.62520872),
      CubicToCommand(156.11137371999996, 521.6220113, 137.92521682999995,
          498.84517403, 137.92521682999995, 498.84517403),
      CubicToCommand(137.92521682999995, 498.84517403, 109.76315834499997,
          473.15502036500004, 128.92042069999997, 448.52425447999997),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(126.80164513999998, 455.58683968),
      CubicToCommand(126.80164513999998, 455.58683968, 123.27035253999998,
          472.53704416, 188.24613637999997, 454.17432264),
      LineToCommand(200.25253121999998, 455.58683968),
      CubicToCommand(204.49008233999996, 456.99935672, 225.67783793999996,
          461.94316635999996, 229.20913053999996, 459.8243908),
      CubicToCommand(229.20913053999996, 459.8243908, 216.49647717999994,
          483.83718048000003, 196.01498009999995, 481.0121464),
      CubicToCommand(196.01498009999995, 481.0121464, 172.70844893999995,
          483.83718048000003, 173.41470745999996, 492.31228272),
      CubicToCommand(173.41470745999996, 492.31228272, 180.47729265999996,
          505.02493608, 188.95239489999994, 509.2624872),
      CubicToCommand(188.95239489999994, 509.2624872, 193.89620453999996,
          513.50003832, 193.18994601999995, 519.15010648),
      CubicToCommand(192.48368749999997, 524.80017464, 187.53987785999996,
          527.62520872, 184.00858525999996, 529.03772576),
      CubicToCommand(180.47729265999996, 530.4502428, 174.82722449999994,
          524.80017464, 172.00219041999995, 524.80017464),
      CubicToCommand(169.17715633999998, 524.80017464, 154.34572741999997,
          513.5000383199999, 146.57688369999994, 505.02493608),
      CubicToCommand(138.80803997999993, 496.54983384, 123.97661105999995,
          475.36207823999996, 124.68286957999993, 470.41826860000003),
      CubicToCommand(125.38912809999994, 465.47445896, 126.80164513999995,
          455.58683968, 126.80164513999995, 455.58683968),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(132.45171329999997, 486.397367615),
      CubicToCommand(137.04239367999998, 493.3716705, 142.69246183999996,
          500.78738496000005, 146.57688369999997, 505.0249360800001),
      CubicToCommand(154.34572741999997, 513.50003832, 169.17715633999998,
          524.80017464, 172.00219041999998, 524.80017464),
      CubicToCommand(174.8272245, 524.80017464, 180.47729266, 530.4502428,
          184.00858526, 529.0377257600001),
      CubicToCommand(187.53987786, 527.62520872, 192.48368749999997,
          524.80017464, 193.18994601999998, 519.1501064800001),
      CubicToCommand(193.89620453999999, 513.50003832, 188.95239489999997,
          509.26248720000007, 188.95239489999997, 509.26248720000007),
      CubicToCommand(183.53892334419996, 506.5610483610001, 178.70105248219997,
          500.39894277400003, 175.91309697449998, 496.2849868950001),
      CubicToCommand(175.91309697449998, 496.2849868950001, 176.23974153999998,
          500.78738496000005, 167.05838077999996, 499.37486792000004),
      CubicToCommand(157.87702001999997, 497.96235088000003, 148.69565925999996,
          493.0185412400001, 145.87062517999996, 487.36847308000006),
      CubicToCommand(143.04559109999997, 481.71840492, 138.80803997999996,
          477.4808538000001, 141.63307405999996, 483.83718048000003),
      CubicToCommand(144.45810813999995, 490.19350716, 148.69565925999996,
          496.54983384, 151.52069333999995, 497.25609236),
      CubicToCommand(154.34572741999995, 497.96235088000003, 153.63946889999994,
          500.08112644000005, 149.40191777999993, 499.37486792000004),
      CubicToCommand(145.16436665999993, 498.66860940000004, 140.22055701999994,
          497.96235088000003, 132.45171329999994, 488.78099012),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(127.86103291999999, 449.230513),
      CubicToCommand(127.86103291999999, 449.230513, 131.03919625999998,
          425.21772332, 133.15797182, 418.15513812),
      CubicToCommand(133.15797182, 418.15513812, 131.74545478, 406.14874328,
          135.98300589999997, 398.73302882),
      CubicToCommand(140.22055701999997, 391.31731436, 143.75184961999997,
          380.37030730000004, 149.04878852, 370.83581728),
      CubicToCommand(154.34572741999997, 361.30132726000005, 154.69885667999998,
          354.23874206000005, 161.76144187999998, 351.41370798),
      CubicToCommand(168.82402707999998, 348.5886739, 179.41790487999998,
          333.40411572000005, 184.36171452, 331.63846942000004),
      CubicToCommand(189.30552415999998, 329.87282312, 188.95239489999997,
          331.28534016000003, 188.95239489999997, 331.28534016000003),
      CubicToCommand(188.95239489999997, 331.28534016000003, 200.95878974,
          305.15377492, 224.97157941999996, 312.21636012),
      CubicToCommand(224.97157941999996, 312.21636012, 196.36810935999998,
          307.27255048, 224.26532089999998, 290.67547526000004),
      CubicToCommand(224.26532089999998, 290.67547526000004, 215.79021866,
          292.61768619000003, 221.61685144999996, 280.25816209000004),
      CubicToCommand(225.50303895629997, 272.01612516160003, 224.61845015999998,
          283.96601932, 205.19634085999996, 304.80064566),
      CubicToCommand(205.19634085999996, 304.80064566, 196.36810935999998,
          319.98520384, 187.1867486, 325.28214274000004),
      CubicToCommand(178.00538783999997, 330.57908164, 156.81763223999997,
          342.93860574, 154.69885667999998, 349.64806168),
      CubicToCommand(152.58008111999996, 356.35751762, 146.93001295999994,
          366.59826616000004, 143.39872035999994, 369.42330024),
      CubicToCommand(139.86742775999997, 372.24833432, 134.92361811999996,
          379.66404878000003, 134.21735959999995, 385.6672462),
      CubicToCommand(134.21735959999995, 385.6672462, 132.09858403999993,
          392.7298314, 129.62667921999997, 394.84860696000004),
      CubicToCommand(127.15477439999998, 396.96738252, 126.80164513999998,
          402.61745068000005, 126.80164513999998, 406.1487432800001),
      CubicToCommand(126.80164513999998, 409.68003588000005, 123.27035253999998,
          414.62384552000003, 123.62348179999998, 418.86139664000007),
      CubicToCommand(123.62348179999998, 418.86139664000007, 125.03599883999996,
          452.40867634000006, 124.32974031999998, 455.9399689400001),
      LineToCommand(127.86103291999999, 449.2305130000001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(112.67647473999997, 457.35248598),
      CubicToCommand(112.67647473999997, 457.35248598, 109.14518213999997,
          454.88058116, 101.37633841999997, 465.47445896),
      CubicToCommand(101.37633841999997, 465.47445896, 114.26555640999996,
          523.74078686, 114.26555640999996, 526.21269168),
      CubicToCommand(114.26555640999996, 526.21269168, 116.20776733999995,
          522.50483445, 113.91242714999996, 509.79218109),
      CubicToCommand(111.61708695999997, 497.07952772999994, 110.02800528999995,
          474.65581971999995, 110.02800528999995, 474.65581971999995),
      LineToCommand(112.67647473999995, 457.35248598),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(150.81443481999997, 350.3543202),
      CubicToCommand(150.81443481999997, 350.3543202, 119.73905994,
          356.00438836, 120.44531845999998, 407.56126032),
      LineToCommand(119.03280142, 451.34928856),
      CubicToCommand(119.03280142, 451.34928856, 116.91402585999998,
          406.14874327999996, 114.79525029999996, 403.3237092),
      CubicToCommand(112.67647473999997, 400.49867512000003, 119.73905993999998,
          380.72343656, 114.08899177999996, 391.31731436),
      CubicToCommand(114.08899177999996, 391.31731436, 89.36994357999995,
          416.03636256000004, 103.49511397999996, 453.46806412),
      CubicToCommand(103.49511397999996, 453.46806412, 106.14358342999998,
          459.29469690999997, 100.84664452999996, 451.17272393),
      CubicToCommand(100.84664452999996, 451.17272393, 92.72467154999998,
          428.92558055000006, 94.66688247999997, 417.62544423),
      CubicToCommand(94.66688247999997, 417.62544423, 95.02001173999994,
          413.74102237, 98.37473970999994, 408.79721273),
      CubicToCommand(98.37473970999994, 408.79721273, 113.55929788999995,
          388.13915102, 118.32654289999996, 384.07816453),
      CubicToCommand(118.32654289999996, 384.07816453, 121.50470623999993,
          358.65285781, 148.69565925999996, 349.47149705000004),
      CubicToCommand(148.69565925999996, 349.47149705000004, 158.75984316999995,
          345.41051056000003, 150.81443481999997, 350.3543202),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(396.94552904, 233.46853514),
      CubicToCommand(398.11085559799994, 232.8434963498, 398.09496478129995,
          231.13081943880002, 399.11903963529994, 230.8253626289),
      CubicToCommand(401.14776723399996, 230.2179803017, 401.4373332272,
          228.3340356996, 402.35193801059995, 226.9497690004),
      CubicToCommand(403.89334723049996, 224.62088153070002, 404.2341169664,
          221.9141457528, 405.261723113, 219.2815671195),
      CubicToCommand(405.74197890659997, 218.0456147095, 405.7896513567,
          216.359422493, 405.2370040648, 215.194095935),
      CubicToCommand(403.16413530859995, 210.8135274647, 401.924651606,
          206.489459676, 399.37858964139997, 202.2060017522),
      CubicToCommand(398.90539643299996, 201.4114609172, 398.4427971024,
          200.009537755, 398.0879021961, 198.95368126760002),
      CubicToCommand(397.2704079592, 196.5100267884, 395.0509905601,
          194.76027130510002, 393.5325347421, 192.4296181891),
      CubicToCommand(393.02402860769996, 191.6509681708, 393.9509929152,
          190.01774534330002, 392.6867901644, 189.8694310541),
      CubicToCommand(391.1030054333, 189.6840381926, 388.5445839446,
          188.6599633386, 388.1331883567, 190.4715164424),
      CubicToCommand(387.0949883323, 195.03924342050001, 388.8800567416,
          199.4939690354, 390.58920236, 203.8056773),
      CubicToCommand(389.2084669534, 205.02750453960002, 389.7981928176,
          206.6536647819, 390.0665710552, 208.007915494),
      CubicToCommand(391.3201799282, 214.3748360518, 389.2049356608,
          220.2932824494, 387.8612788265, 226.4271376956),
      CubicToCommand(387.82066896159995, 226.61076491080001, 388.4245199962,
          226.9603628782, 388.37508189979997, 227.0698329488),
      CubicToCommand(386.21746212119996, 231.8123589106, 383.65374369359995,
          236.1293641141, 380.44203307389995, 240.3333679544),
      CubicToCommand(379.10367317849995, 242.084889084, 377.5640296049,
          243.7022210948, 376.68650339379997, 245.5791031117),
      CubicToCommand(376.0367455554, 246.9686667498, 375.316361865,
          248.6742810756, 375.75777344, 250.41873962),
      CubicToCommand(369.69277839949996, 255.327236334, 365.72007422449997,
          262.1161463575, 361.10997173519996, 268.9068220273),
      CubicToCommand(360.2942431446, 270.1074615113, 360.80804621789997,
          272.242127888, 361.78091732919995, 272.7170867427),
      CubicToCommand(363.21638777109996, 273.4198139701, 364.9043456339,
          271.6117921589, 365.7341993949, 270.1180553891),
      CubicToCommand(366.42103580559996, 268.8856342717, 367.04430894949996,
          267.7379641767, 367.91124128279995, 266.6026536058),
      CubicToCommand(368.1460722407, 266.2936655033, 367.830021553,
          265.5538597036, 368.06838380349996, 265.3402165013),
      CubicToCommand(372.71733051139995, 261.1962446352, 375.66419418609996,
          256.0123070984, 379.99532456, 251.83125666),
      CubicToCommand(383.438334845, 251.2503590273, 386.1521332081,
          249.4882440199, 389.2384829405, 247.699644318),
      CubicToCommand(389.78230200089996, 247.3835936303, 390.70750066209996,
          247.823239559, 391.21953808909996, 247.47893853050002),
      CubicToCommand(394.314716053, 245.4007728354, 394.31118476039995,
          241.8059169686, 394.49834326819996, 238.4335325356),
      CubicToCommand(394.5866255832, 236.8727012064, 394.932692258,
          234.5473450293, 396.94552904, 233.46853514),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(381.33545010169996, 225.5831587642),
      CubicToCommand(381.55439024289996, 225.4472039991, 381.2807150664,
          224.70033561420001, 381.47317051309994, 224.3189560134),
      CubicToCommand(381.75920521369994, 223.7468866122, 382.47076067259997,
          223.4149451078, 382.75679537319996, 222.8428757066),
      CubicToCommand(382.9492508199, 222.4614961058, 382.66145047299995,
          221.7905505118, 382.90157836979995, 221.5398287372),
      CubicToCommand(387.02083118769997, 217.2192922411, 387.47460228679995,
          211.8799778299, 385.64539271999996, 206.63071138),
      CubicToCommand(387.4534145312, 205.536010674, 387.5611189555,
          203.3077650434, 386.81071927799997, 201.81226262730002),
      CubicToCommand(385.3046229841, 198.81066391730002, 384.9638532482,
          195.41002914350003, 383.2423481057, 192.6856369026),
      CubicToCommand(381.8262997731, 190.4450317479, 379.0401099117,
          188.2485677507, 376.61940883439996, 190.54920487959998),
      CubicToCommand(375.87607174209995, 191.2554633996, 375.3092992798,
          192.6450270377, 375.80014895119996, 193.9021672033),
      CubicToCommand(375.91315031439996, 194.18996755019998, 376.41635950989996,
          194.44775191, 376.3686870598, 194.5925349066),
      CubicToCommand(376.1797629057, 195.1646043078, 375.2157200259,
          195.560109079, 375.20512614809996, 196.0403648726),
      CubicToCommand(375.15215675909997, 198.6817717374, 373.46773018889996,
          201.3496632967, 374.58008735789997, 203.6962072294),
      CubicToCommand(375.94316630149996, 206.5724450521, 377.3892306212,
          209.8512502312, 378.58280751999996, 212.98703806),
      CubicToCommand(376.4039999858, 216.7231456308, 378.22791261369997,
          221.0472134195, 375.1327346498, 224.3613315246),
      CubicToCommand(374.892606753, 224.6191158844, 374.9084975697,
          225.3006553562, 375.12390641829995, 225.6573159088),
      CubicToCommand(375.6394751379, 226.5154200106, 376.35632753569996,
          227.2322724084, 377.21443163749996, 227.747841128),
      CubicToCommand(377.5710921901, 227.9614843303, 378.1855371025,
          227.9650156229, 378.53866636249995, 227.7460754817),
      CubicToCommand(379.55920992389997, 227.10691152110002, 380.2619371513,
          226.247041773, 381.33545010169996, 225.5831587642),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(492.23922549729997, 207.37757976490002),
      CubicToCommand(494.69170820799997, 210.5416179345, 495.203745635,
          215.476599343, 491.58593636629996, 217.93084770000002),
      CubicToCommand(492.55704183129995, 223.7733713067, 498.4737225826,
          220.279157279, 502.17804851999995, 219.34336474),
      CubicToCommand(501.98382742699994, 218.6582939756, 502.38992607599994,
          218.05091164840002, 502.88430703999995, 218.04208341690003),
      CubicToCommand(504.75589211799996, 218.0155987224, 505.9565316019999,
          216.19345174080001, 507.82811668, 216.51833066),
      CubicToCommand(508.6050010519999, 213.7692193709, 511.48300452099994,
          212.52973566830002, 512.630674616, 210.09314377430002),
      CubicToCommand(515.667586252, 203.5690806958, 514.625854935,
          196.02447405590001, 510.070487481, 190.2931861661),
      CubicToCommand(509.7173582209999, 189.84471200590002, 510.08814394399997,
          188.9318728688, 509.876266388, 188.29270890819998),
      CubicToCommand(508.53437519999994, 184.38886493889999, 504.897143822,
          183.8326863544, 501.47178999999994, 182.6179217),
      CubicToCommand(499.39538995119995, 175.7760422875, 498.22829774689995,
          168.6587220522, 495.11722896629993, 162.13642462),
      CubicToCommand(492.2674758380999, 161.695013045, 491.0350547206999,
          158.6245541293, 488.6743856175999, 157.3532887933),
      CubicToCommand(486.32077909969996, 156.0837891036, 485.3178920012999,
          158.87174461130002, 485.39028349959995, 160.71861064109999),
      CubicToCommand(485.40264302369997, 161.08056813259998, 486.20071515129996,
          161.4760729038, 485.90055528029995, 162.1205338033),
      CubicToCommand(485.76636616149995, 162.4100997965, 485.30729812349995,
          162.6060865358, 485.30729812349995, 162.84268314),
      CubicToCommand(485.3090637698, 163.08104539049998, 485.69927160209994,
          163.3123450558, 485.9358682062999, 163.54894165999997),
      CubicToCommand(484.3150049028999, 164.996771626, 481.80249021799995,
          165.8389849111, 481.28162455949996, 167.86064992459998),
      CubicToCommand(479.59719798929996, 174.4111976976, 484.14020591919996,
          179.92884238509998, 487.0853039476, 185.5806761914),
      CubicToCommand(488.12880091089994, 187.5846847419, 486.8292852341,
          189.82882118919997, 485.48739404609995, 191.9617219196),
      CubicToCommand(484.71404096669994, 193.1888460981, 484.9047307671,
          195.17872947819998, 485.39204914589993, 196.690122711),
      CubicToCommand(486.7198151634999, 200.80584423629998, 489.52895842679993,
          203.876303152, 492.2392254972999, 207.37757976489996),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(426.6278089893, 239.84075263670002),
      CubicToCommand(424.0022929412, 243.10896393800002, 417.9779077656,
          247.6449092827, 423.12829802269994, 251.0490753491),
      CubicToCommand(423.47083340489996, 251.27684372180002, 424.12412253589997,
          251.283906307, 424.4295793458, 251.04730970280002),
      CubicToCommand(427.99795051809997, 248.2840732433, 431.53454005699996,
          246.6896946344, 435.83565444379997, 245.66208848780002),
      CubicToCommand(436.05459458499996, 245.6108847451, 436.5383816712,
          246.4354415672, 437.18990515589996, 246.15117251290002),
      CubicToCommand(440.0378926378, 244.90992316400002, 443.5868417008,
          245.0123306494, 445.67736692, 242.64989590000002),
      CubicToCommand(452.3285565321, 243.0454006712, 458.6230855916,
          241.0749394004, 464.6103921949, 238.76547404000002),
      CubicToCommand(466.66030754919996, 237.9744644976, 468.90267835019995,
          236.9874682159, 471.02321955649995, 236.1011137733),
      CubicToCommand(473.4527488653, 235.0841015045, 475.5785870105,
          233.4455817381, 477.54198569609997, 231.43097930980002),
      CubicToCommand(477.77681665399996, 231.19085141300002, 478.4018554442,
          231.34975958, 478.87328300629997, 231.34975958),
      CubicToCommand(478.80265715429994, 229.82600682310002, 480.50120889489995,
          229.601769743, 480.93732353099995, 228.5035377444),
      CubicToCommand(481.09976299059997, 228.0939078028, 480.8349160456,
          227.394711868, 481.06974700349997, 227.2146159454),
      CubicToCommand(484.8446987929, 224.3366124764, 486.4690933889,
          220.77353824300002, 484.4050528642, 216.57659698790002),
      CubicToCommand(483.9018436687, 215.5560534265, 483.46219773999997,
          214.4648840131, 482.4628419342, 213.6244363743),
      CubicToCommand(480.5471156987, 212.015932595, 478.6013734761,
          213.5237945352, 476.75274179999997, 212.98703806),
      CubicToCommand(476.4720040383, 214.0958639364, 475.1848478856,
          213.7921727728, 474.5033084138, 214.1417707402),
      CubicToCommand(472.9866182421, 214.9168894659, 470.6330117242,
          213.88398638040002, 469.1163215525, 214.6573394598),
      CubicToCommand(466.7115112919, 215.88446363830002, 464.5203442336,
          216.182857863, 462.009595195, 216.8485065181),
      CubicToCommand(461.4587135494, 216.9932895147, 460.08504072799997,
          216.8237874699, 459.80253732, 217.93084770000002),
      CubicToCommand(459.5659407158, 217.6942510958, 459.30462506339995,
          217.2810898616, 459.1174665556, 217.3199340802),
      CubicToCommand(455.7486134152, 218.019130015, 453.5238990772,
          218.39697832320002, 451.2267932409, 221.3844518628),
      CubicToCommand(451.044931672, 221.6192828207, 450.2645160074,
          221.303232133, 449.9837782457, 221.5415943835),
      CubicToCommand(448.2940547366, 222.9682365939, 447.5789679851,
          225.1470441281, 445.63499140880003, 226.3335584417),
      CubicToCommand(445.2800965025, 226.5507329366, 444.6585890049,
          226.25410435819998, 444.3160536227, 226.4818727309),
      CubicToCommand(443.1754461129, 227.2428662862, 442.5274539208,
          228.37464556449999, 441.3939089962, 229.1638894606),
      CubicToCommand(440.81301136350004, 229.5682224633, 440.1067528435,
          228.9943874158, 440.1632535251, 228.542381963),
      CubicToCommand(440.59583686860003, 225.1046686169, 441.7488039025,
          221.9494586788, 440.73355728, 218.63710622),
      CubicToCommand(444.4008046451, 214.187677544, 448.8449363822,
          210.7464329053, 452.0336936, 205.92445286),
      CubicToCommand(452.0601782945, 202.1000629742, 453.2820055341,
          198.3109860144, 453.0824875022, 194.6437386493),
      CubicToCommand(453.0648310392, 194.30296891339998, 452.5563249048,
          193.00875017549998, 452.333853471, 192.39607090939998),
      CubicToCommand(451.78297182539995, 190.88820896919998, 453.3826473732,
          189.0060300134, 451.892441896, 187.7277020922),
      CubicToCommand(449.4134744908, 185.60362959329998, 447.1322594712,
          187.15033575209998, 445.67736692, 189.6805069),
      CubicToCommand(442.4321090206, 190.36910895699998, 438.78428376479997,
          191.5927018429, 435.9980939034, 189.41389430869998),
      CubicToCommand(434.2200880793, 188.0243306706, 433.1995445179,
          186.4246551228, 431.78879312419997, 184.56013263),
      CubicToCommand(430.0496315187, 182.26126114739998, 430.6411230292,
          179.72579306059998, 430.7647182702, 176.9643222474),
      CubicToCommand(430.775312148, 176.738319521, 430.2191335635,
          176.4981916242, 430.2191335635, 176.26159501999996),
      CubicToCommand(430.2208992098, 176.0232327695, 430.6093413958,
          175.79193310419998, 430.845938, 175.55533649999998),
      CubicToCommand(429.5993917122, 174.45004191619998, 429.1138389797,
          172.58198813079997, 427.3146454, 172.02404389999998),
      CubicToCommand(427.8531675215, 170.0959581404, 426.65959062269997,
          168.53512681119997, 425.1217126954, 168.00190162859997),
      CubicToCommand(421.5992483269, 166.78184003529998, 418.6382594818,
          170.1577557609, 415.2976566822, 170.28664794079998),
      CubicToCommand(414.390114484, 170.32019522049995, 413.5655576619,
          168.4874543611, 412.4196532132, 167.91361931359998),
      CubicToCommand(411.6568940116, 167.5322397128, 410.41387901639996,
          167.47397338489998, 409.7747150558, 167.94363530069998),
      CubicToCommand(408.5599504014, 168.8335210359, 407.5199847307,
          169.0348047141, 406.1816248353, 169.3967622056),
      CubicToCommand(403.3265747682, 170.16658399239998, 401.0700787968,
          172.0982010446, 398.4569222728, 173.60782863109998),
      CubicToCommand(395.8349375173, 175.1209875102, 394.1487453008,
          177.65822124329998, 392.24184729679996, 179.98887435929998),
      CubicToCommand(390.5803741285, 182.02289889689996, 390.3402462317,
          186.28516906509998, 392.8474639777, 187.16799221509996),
      CubicToCommand(396.1015501086, 188.31566231009998, 398.4039528838,
          183.54312036119998, 401.8752135096, 184.11872105499998),
      CubicToCommand(402.42609515519996, 184.20876901629998, 402.789818293,
          184.75788501559998, 402.5955972, 185.44295577999998),
      CubicToCommand(403.28243361069997, 185.6354112267, 403.6673445041,
          185.231078224, 404.00811424, 184.73669725999997),
      CubicToCommand(405.5230387654, 186.5358908397, 407.57825105859996,
          187.13091364279998, 409.234427288, 188.67232286269999),
      CubicToCommand(410.94710419899997, 190.2684671179, 414.0299226388,
          189.53042696449998, 415.8220536333, 191.29077632559998),
      CubicToCommand(418.52172682599996, 193.94277706819997, 417.5347305443,
          198.67647479849998, 420.95831871999997, 200.98064322),
      CubicToCommand(419.9236499882, 203.29893681189998, 418.85190268409997,
          205.553667137, 418.2604111736, 208.0732444071),
      CubicToCommand(417.762498917, 210.2026138449, 419.5175513392,
          212.316092466, 421.6557490085, 212.15541865269998),
      CubicToCommand(423.87693205389996, 211.98944790049998, 424.3395313845,
          210.64932235879996, 425.19586984, 208.74948694),
      CubicToCommand(425.6672974021, 209.2209145021, 426.49538551679996,
          209.74531145319997, 426.4229940185, 210.126691054),
      CubicToCommand(425.6160936594, 214.34128877209997, 423.8027749093,
          217.86022184799998, 422.9941089039, 222.1525080033),
      CubicToCommand(422.88993577220003, 222.71221788039998, 422.3514136507,
          223.06887843299998, 421.66457723999997, 222.87465734),
      CubicToCommand(420.83825477159996, 230.20032383869997, 413.68385596400003,
          234.42728108089997, 409.1902861305, 240.01555162039998),
      CubicToCommand(408.47873067160003, 240.90190606299998, 408.4716680864,
          243.10719829169997, 409.1938174231, 243.81875375059997),
      CubicToCommand(411.671019182, 246.2677051687, 415.13168593,
          243.53801598889999, 418.13328464, 242.6498959),
      CubicToCommand(418.5093673019, 240.5205264622, 420.0260574736,
          238.85728764759997, 422.37789834520004, 238.9561638404),
      CubicToCommand(422.82990379800003, 238.97382030339998, 423.2448306785,
          238.0168400088, 423.8169000797, 237.7873059898),
      CubicToCommand(424.4313449921, 237.54364680039998, 425.3176994347,
          237.93915157159998, 425.82267427650004, 237.58955360419998),
      CubicToCommand(428.87547672920005, 235.47960627569998, 431.3615067196,
          233.5268014679, 434.430199989, 231.4274480172),
      CubicToCommand(434.7692040786, 231.19614835189998, 435.3765864058,
          231.4768861136, 435.7579660066, 231.28619631319998),
      CubicToCommand(436.3318010541, 231.00016161259998, 436.66197691220003,
          230.31685649449997, 437.23228066710004, 229.99021192899997),
      CubicToCommand(437.8467255795, 229.637082669, 438.2740119841,
          230.149120096, 438.61478172, 230.64350105999998),
      CubicToCommand(437.4741742102, 231.25971161869998, 437.46711162500003,
          232.94943512779997, 436.4395054784, 233.30609568039998),
      CubicToCommand(435.0711295959, 233.77928888879998, 434.08060202160004,
          234.6850654407, 432.8905564154, 235.4743093368),
      CubicToCommand(432.37498769580003, 235.81507907269997, 431.2114267841,
          235.37719879029999, 431.02779956890004, 235.69324947799998),
      CubicToCommand(429.9719430815, 237.50833387439997, 427.88141786230005,
          238.28168695379998, 426.62780898930004, 239.8407526367),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(328.79158185999995, 152.6019346),
      CubicToCommand(328.79158185999995, 152.6019346, 312.4805413406,
          147.5309984264, 292.77239734, 192.85867024),
      CubicToCommand(292.77239734, 192.85867024, 288.53484621999996, 202.040031,
          284.2972951, 205.5713236),
      CubicToCommand(280.05974397999995, 209.1026162, 260.28450541999996,
          215.45894288, 256.75321282, 222.52152808),
      LineToCommand(238.39049129999998, 250.77186888),
      CubicToCommand(238.39049129999998, 250.77186888, 264.52205654,
          222.52152808, 270.1721247, 218.28397696),
      CubicToCommand(270.1721247, 218.28397696, 284.2972951, 203.45254804,
          278.64722694, 215.45894288),
      CubicToCommand(278.64722694, 215.45894288, 253.92817873999996,
          234.52792292, 256.0469543, 250.77186888),
      CubicToCommand(256.0469543, 250.77186888, 246.15933501999996, 276.1971756,
          244.74681797999997, 279.7284682),
      CubicToCommand(244.74681797999997, 279.7284682, 272.99715877999995,
          223.2277866, 277.2347099, 221.10901103999998),
      CubicToCommand(281.47226101999996, 218.99023547999997, 283.59103658,
          218.99023548, 281.47226101999996, 225.34656216),
      CubicToCommand(279.35348545999994, 231.70288883999999, 278.64722694,
          260.65948815999997, 273.70341729999996, 264.19078076),
      CubicToCommand(273.70341729999996, 264.19078076, 287.82858769999996,
          228.17159623999999, 286.41607065999995, 222.52152808),
      CubicToCommand(286.41607065999995, 222.52152808, 292.06613882,
          216.16520139999997, 296.30368993999997, 225.34656216),
      LineToCommand(294.18491437999995, 253.59690296),
      LineToCommand(301.95375809999996, 274.78465855999997),
      CubicToCommand(301.95375809999996, 274.78465855999997, 297.71620698,
          255.00941999999998, 300.54124105999995, 227.46533771999998),
      CubicToCommand(300.54124105999995, 227.46533771999998, 297.00994846,
          209.10261619999997, 304.07253366, 218.99023547999997),
      CubicToCommand(311.13511886, 228.87785476, 328.08532333999995,
          239.47173256, 328.08532333999995, 247.94683479999998),
      CubicToCommand(328.08532333999995, 247.94683479999998, 318.90396258,
          216.87145991999998, 302.66001661999996, 208.39635768),
      LineToCommand(295.59743141999996, 218.99023547999997),
      LineToCommand(293.47865586, 215.45894288),
      CubicToCommand(293.47865586, 215.45894288, 287.12232917999995,
          214.04642583999998, 294.89117289999996, 202.04003099999997),
      CubicToCommand(302.66001661999996, 190.03363616, 301.95375809999996,
          188.62111911999997, 301.95375809999996, 188.62111911999997),
      CubicToCommand(301.95375809999996, 188.62111911999997, 313.25389442,
          201.33377248, 316.07892849999996, 201.33377248),
      CubicToCommand(316.07892849999996, 201.33377248, 339.38545966,
          187.9148606, 341.50423522, 230.99663031999998),
      CubicToCommand(341.50423522, 230.99663031999998, 353.51063006,
          205.57132359999997, 337.26668409999996, 193.56492876),
      CubicToCommand(337.26668409999996, 193.56492876, 311.13511886,
          190.03363616, 313.25389442, 180.8522754),
      LineToCommand(325.96654778, 158.95826128),
      CubicToCommand(332.32287446, 149.77690051999997, 329.49784037999996,
          154.72071015999998, 329.49784037999996, 154.72071015999998),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(293.47865586, 181.55853392),
      LineToCommand(265.22831506, 190.73989468000002),
      LineToCommand(252.51566169999998, 207.69009916000002),
      CubicToCommand(252.51566169999998, 207.69009916000002, 282.88477806,
          190.03363616000001, 289.94736326, 187.9148606),
      CubicToCommand(297.00994846, 185.79608503999998, 293.47865586,
          181.55853392, 293.47865586, 181.55853392),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(222.85280386, 192.85867024),
      CubicToCommand(222.85280386, 192.85867024, 219.32151125999997,
          194.9774458, 218.61525274, 199.92125544),
      CubicToCommand(217.90899421999998, 204.86506508, 213.67144309999998,
          205.5713236, 215.08396014, 210.51513324),
      CubicToCommand(216.49647718, 215.45894288, 220.02776977999997, 219.696494,
          220.02776977999997, 212.6339088),
      CubicToCommand(220.02776977999997, 205.5713236, 222.85280386, 202.040031,
          224.26532089999998, 199.92125544),
      CubicToCommand(225.67783793999996, 197.80247988, 228.50287201999998,
          190.03363616000001, 222.85280386, 192.85867024),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(207.31511641999998, 300.9162238),
      CubicToCommand(207.31511641999998, 300.9162238, 192.48368749999997,
          293.8536386, 186.83361933999998, 287.49731192),
      CubicToCommand(181.18355118000002, 281.14098524, 181.9816233076,
          290.2623140258, 173.41470746000002, 289.61608748000003),
      CubicToCommand(163.09097354390002, 288.8374374617, 164.93960522,
          260.65948816, 164.93960522, 260.65948816),
      LineToCommand(157.87702002, 274.07840004),
      CubicToCommand(157.87702002, 274.07840004, 155.75824446000001,
          299.50370676, 169.88341486000002, 295.26615564),
      CubicToCommand(176.7817949541, 293.19681817640003, 179.06477562,
          295.97241415999997, 176.23974153999998, 297.3849312),
      CubicToCommand(173.41470746, 298.79744824, 186.12736081999998,
          299.50370676, 181.18355118, 302.32874084),
      CubicToCommand(176.23974153999998, 305.15377492, 201.66504826,
          295.97241415999997, 197.42749714, 314.33513568),
      LineToCommand(207.31511641999998, 300.9162238),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(185.06797303999997, 326.34153052),
      CubicToCommand(185.06797303999997, 326.34153052, 157.87702001999997,
          334.11037424, 151.52069333999998, 317.16016976),
      CubicToCommand(151.52069333999998, 317.16016976, 143.04559109999997,
          321.39772088, 146.93001295999997, 326.69465978),
      CubicToCommand(150.81443481999997, 331.99159868, 152.93321038,
          332.6978572, 152.93321038, 332.6978572),
      CubicToCommand(152.93321038, 332.6978572, 162.4677004, 334.81663276,
          161.40831261999998, 336.22914979999996),
      CubicToCommand(160.34892483999997, 337.64166683999997, 156.11137372,
          343.64486425999996, 156.11137372, 343.64486425999996),
      CubicToCommand(156.11137372, 343.64486425999996, 174.12096598,
          333.05098646, 185.06797304, 326.34153052),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(588.34158796, 464.41507118),
      CubicToCommand(587.582360051, 468.193554262, 584.63373073,
          469.60607130200003, 581.2790027599999, 470.77139786),
      CubicToCommand(577.888961864, 469.076377412, 573.315937947, 463.602873882,
          569.9788664399999, 467.24010525999995),
      CubicToCommand(569.149012679, 466.392595036, 567.7718085649999,
          466.286656258, 567.15383236, 465.1213297),
      CubicToCommand(566.3416350619999, 463.53224803, 566.818359563,
          461.695975878, 566.2180398209999, 460.283458838),
      CubicToCommand(565.2469343559999, 458.023431574, 564.0109819459999,
          455.622152606, 564.32879828, 453.11493485999995),
      CubicToCommand(567.524618083, 451.861325987, 568.5663494, 448.488941554,
          567.7364956389999, 445.38140406599996),
      CubicToCommand(567.612900398, 444.922336028, 566.853672489, 444.586863231,
          567.206801749, 443.968887026),
      CubicToCommand(567.5422745459999, 443.38622374700003, 568.089624899,
          442.997781561, 568.5663494, 442.52105706),
      CubicToCommand(568.336815381, 442.76824754200004, 568.0719684359999,
          443.17434619100004, 567.877747343, 443.13903326499997),
      CubicToCommand(566.8007031, 442.944812172, 567.012580656,
          441.81479853999997, 567.242114675, 441.14385294600004),
      CubicToCommand(568.283845992, 438.05397192099997, 571.8327950549999,
          437.59490388300003, 574.21641756, 439.69602298),
      CubicToCommand(574.6754855979999, 438.70726105200004, 575.575965211,
          439.042733849, 576.33519312, 438.98976446),
      CubicToCommand(576.246910805, 437.965689606, 576.970825788, 437.029897067,
          577.3239550479999, 436.288325621),
      CubicToCommand(578.2420911239999, 434.363771154, 581.1024381299999,
          436.305982084, 582.5149551699999, 435.22893784100006),
      CubicToCommand(584.421853174, 433.763451412, 586.293438252, 432.545155465,
          588.2003362559999, 433.604543245),
      CubicToCommand(591.396156059, 435.387846008, 594.415411232, 437.524278031,
          596.5341867919999, 440.614159056),
      CubicToCommand(597.5406051829999, 442.079645485, 597.964360295,
          444.339672749, 597.8584215169999, 446.034693197),
      CubicToCommand(597.787795665, 447.182363292, 595.351203771, 446.546730624,
          594.750884029, 448.188781683),
      CubicToCommand(593.603213934, 451.278662708, 596.852003126,
          452.19679878399995, 598.176237851, 454.56276482600003),
      CubicToCommand(598.5293671109999, 455.180741031, 598.0702990729999,
          455.710434921, 597.505292257, 455.88699955100003),
      CubicToCommand(596.781377274, 456.11653357, 595.40417316,
          455.78106077300004, 595.6337071789999, 456.575601608),
      CubicToCommand(597.364040553, 462.208013305, 592.490856765,
          463.40865278900003, 588.34158796, 464.41507118),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(571.39138348, 499.02173866),
      CubicToCommand(571.373727017, 495.949514098, 568.5486929369999,
          492.85963307299994, 570.6851249599999, 489.8403779),
      CubicToCommand(570.9323154419999, 490.087568382, 571.161849461,
          490.476010568, 571.39138348, 490.476010568),
      CubicToCommand(571.638573962, 490.476010568, 571.868107981,
          490.08756838200003, 572.097642, 489.8403779),
      CubicToCommand(574.74611145, 493.760112686, 581.190720445,
          495.38450728199996, 580.943529963, 500.416599237),
      CubicToCommand(580.8905605739999, 501.21114007200003, 578.98366257,
          502.83553466800004, 580.5727442399999, 503.9655483),
      CubicToCommand(577.376924437, 506.34917080499997, 577.270985659,
          510.533752536, 575.6289345999999, 513.85316758),
      CubicToCommand(573.4395331879999, 513.358786616, 571.3031011649999,
          512.705497485, 569.2726079199999, 511.73439202),
      CubicToCommand(569.8905841249999, 509.12123549600005, 569.6963630319999,
          506.13729324900004, 571.1441929979999, 503.806640133),
      CubicToCommand(571.9034209069999, 502.570687723, 571.39138348,
          500.66378971899996, 571.39138348, 499.02173866),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(277.94096842, 483.13092196),
      CubicToCommand(277.94096842, 483.13092196, 248.17570309459998,
          501.03457544199995, 272.99715877999995, 473.94956119999995),
      CubicToCommand(288.53484621999996, 456.99935672, 306.19130922,
          447.11173743999996, 306.19130922, 447.11173743999996),
      CubicToCommand(306.19130922, 447.11173743999996, 324.55403074,
          439.34289372, 330.91035741999997, 437.22411816),
      CubicToCommand(337.26668409999996, 435.1053426, 364.10450785999996,
          425.92398184, 369.75457601999994, 425.21772332),
      CubicToCommand(375.40464418, 424.5114648, 392.35484866,
          417.44887959999994, 404.3612435, 424.5114648),
      CubicToCommand(416.36763834, 431.57404999999994, 430.49280874,
          439.34289372, 430.49280874, 439.34289372),
      CubicToCommand(430.49280874, 439.34289372, 401.53620942, 424.5114648,
          395.17988274, 428.74901592000003),
      CubicToCommand(388.82355606, 432.98656704, 376.1109027,
          432.28030851999995, 365.51702489999997, 437.93037668),
      CubicToCommand(365.51702489999997, 437.93037668, 339.38545966,
          445.6992204, 333.7353915, 449.230513),
      CubicToCommand(328.08532333999995, 452.7618056, 309.72260181999997,
          473.24330268, 306.89756774, 471.83078564),
      CubicToCommand(304.07253366, 470.41826860000003, 307.60382625999995,
          469.71201008, 309.72260181999997, 464.76820044),
      CubicToCommand(311.84137738, 459.8243908, 308.31008477999995,
          456.99935672, 294.18491437999995, 468.29949304),
      CubicToCommand(280.05974397999995, 479.59962936, 277.94096842,
          483.13092196, 277.94096842, 483.13092196),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(291.0155792715, 472.590013549),
      CubicToCommand(291.0155792715, 472.590013549, 293.5051405545,
          449.565985797, 308.47428988589996, 452.514615118),
      CubicToCommand(308.47428988589996, 452.514615118, 322.99849634969996,
          445.151870047, 327.80458557829996, 441.673546836),
      CubicToCommand(327.80458557829996, 441.673546836, 342.175180814,
          438.67194812599996, 344.48817746699996, 437.57724742000005),
      CubicToCommand(377.11555544469996, 422.21965590260004, 403.10410333439995,
          430.1986115323, 404.0699118605, 428.22108767630004),
      CubicToCommand(405.0339547403, 426.24532946659997, 439.6847633778,
          438.81319983000003, 446.05698087449997, 446.01703673400004),
      CubicToCommand(446.7473485778, 446.81157756900006, 427.99265357919995,
          436.147073917, 410.8694157618, 432.81000241000004),
      CubicToCommand(396.2622239219, 429.9549523429, 358.1207325493,
          433.233757522, 338.86459400149994, 443.015438024),
      CubicToCommand(333.6153275516, 445.681563937, 317.8216213981,
          455.88699955100003, 313.3527706128, 455.692778458),
      CubicToCommand(308.8839198275, 455.498557365, 291.0155792715,
          472.590013549, 291.0155792715, 472.590013549),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(284.2972951, 517.7375894400001),
      CubicToCommand(284.2972951, 517.7375894400001, 257.45947133999994,
          513.50003832, 287.12232917999995, 510.67500424),
      CubicToCommand(287.12232917999995, 510.67500424, 318.90396258,
          507.14371164, 325.96654778, 497.96235088000003),
      CubicToCommand(325.96654778, 497.96235088000003, 349.97933745999995,
          481.71840492000007, 354.9231471, 481.01214640000006),
      CubicToCommand(359.86695674, 480.30588788000006, 412.83634573999996,
          467.59323452000007, 413.54260425999996, 463.3556834000001),
      CubicToCommand(414.24886277999997, 459.11813228000005, 424.13648206,
          459.11813228000005, 426.96151613999996, 460.53064932000007),
      CubicToCommand(429.78655022, 461.9431663600001, 428.37403317999997,
          464.0619419200001, 423.43022354, 465.47445896000005),
      CubicToCommand(418.4864139, 466.88697600000006, 363.39824934,
          495.84357532000007, 352.09811301999997, 497.96235088000003),
      CubicToCommand(340.7979767, 500.08112644000005, 320.31647962,
          513.50003832, 311.84137738, 515.6188138800001),
      CubicToCommand(303.36627513999997, 517.7375894400001, 284.2972951,
          517.7375894400001, 284.2972951, 517.7375894400001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(318.76271087599997, 504.67180682000003),
      CubicToCommand(318.76271087599997, 504.67180682000003, 303.60993432939995,
          503.20632039099996, 318.7962581557, 501.776146888),
      CubicToCommand(318.7962581557, 501.776146888, 334.3621959365,
          495.71998007900004, 337.9782395589, 491.02336092100006),
      CubicToCommand(337.9782395589, 491.02336092100006, 350.2742003921,
          482.70716684800004, 352.80437154, 482.33638112500006),
      CubicToCommand(355.3363083342, 481.98325186500006, 379.9847306822,
          475.46801701800007, 380.3466881737, 473.29627206900005),
      CubicToCommand(380.7086456652, 471.12452712000004, 440.857152521,
          448.91269666600004, 448.661309167, 454.54510836300005),
      CubicToCommand(453.8011055463, 458.252965593, 436.31944152999995,
          455.30433627200006, 419.3092050758, 463.09083645500004),
      CubicToCommand(416.9167543393, 464.18553716100007, 357.1443301454,
          489.92866021500004, 351.3583072203, 491.02336092100006),
      CubicToCommand(345.5722842952, 492.10040516400005, 335.0861109195,
          498.96876927100004, 330.7461523141, 500.06346997700007),
      CubicToCommand(326.407959355, 501.14051422000006, 318.76271087599997,
          504.67180682000003, 318.76271087599997, 504.67180682000003),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(304.77879218, 508.55622868),
      CubicToCommand(304.77879218, 508.55622868, 313.96015294, 507.84997016,
          311.84137738, 510.67500423999996),
      CubicToCommand(309.72260181999997, 513.5000383199999, 305.4850507,
          512.08752128, 305.4850507, 512.08752128),
      LineToCommand(304.77879218, 508.55622868),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(292.06613882, 511.38126276),
      CubicToCommand(292.06613882, 511.38126276, 301.24749957999995,
          510.67500423999996, 299.12872402, 513.5000383199999),
      CubicToCommand(297.00994846, 516.3250724, 292.77239734, 514.9125553599999,
          292.77239734, 514.9125553599999),
      LineToCommand(292.06613882, 511.38126276),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(273.70341729999996, 514.20629684),
      CubicToCommand(273.70341729999996, 514.20629684, 282.88477806,
          513.50003832, 280.76600249999996, 516.3250724),
      CubicToCommand(278.64722694, 519.15010648, 274.40967581999996,
          517.7375894400001, 274.40967581999996, 517.7375894400001),
      LineToCommand(273.70341729999996, 514.20629684),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(260.28450541999996, 515.61881388),
      CubicToCommand(260.28450541999996, 515.61881388, 269.46586618,
          514.9125553599999, 267.34709061999996, 517.73758944),
      CubicToCommand(265.22831506, 520.56262352, 260.99076393999997,
          519.15010648, 260.99076393999997, 519.15010648),
      LineToCommand(260.28450541999996, 515.61881388),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(328.08532334, 445.6992204),
      LineToCommand(333.7353915, 448.52425447999997),
      CubicToCommand(331.61661594, 451.34928856, 325.96654778, 450.64303004,
          325.96654778, 450.64303004),
      LineToCommand(328.08532334, 445.6992204),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(310.42886033999997, 455.58683968),
      CubicToCommand(310.42886033999997, 455.58683968, 321.91615516779996,
          451.808356598, 317.49144554, 457.70561524000004),
      CubicToCommand(315.37266997999996, 460.53064931999995, 311.13511886,
          459.11813228, 311.13511886, 459.11813228),
      LineToCommand(310.42886033999997, 455.58683968),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(290.65362178, 464.06194192),
      CubicToCommand(290.65362178, 464.06194192, 299.83498254, 463.3556834,
          297.71620698, 466.18071748),
      CubicToCommand(295.59743141999996, 469.00575156, 291.3598803,
          467.59323452, 291.3598803, 467.59323452),
      LineToCommand(290.65362178, 464.06194192),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(277.2347099, 474.65581972),
      CubicToCommand(277.2347099, 474.65581972, 286.41607065999995, 473.9495612,
          284.2972951, 476.77459528),
      CubicToCommand(282.17851953999997, 479.59962936, 277.94096842,
          478.18711232, 277.94096842, 478.18711232),
      LineToCommand(277.2347099, 474.65581972),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(265.22831506, 483.13092196),
      CubicToCommand(265.22831506, 483.13092196, 274.40967581999996,
          482.42466344, 272.29090026, 485.2496975199999),
      CubicToCommand(270.1721247, 488.07473159999995, 265.93457358,
          486.66221456, 265.93457358, 486.66221456),
      LineToCommand(265.22831506, 483.13092196),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(334.2333037566, 494.43105828),
      CubicToCommand(334.2333037566, 494.43105828, 346.4533417989,
          493.495265741, 343.6336046578, 497.25609236),
      CubicToCommand(340.8138675167, 500.999262516, 335.1726275882,
          499.127677438, 335.1726275882, 499.127677438),
      LineToCommand(334.2333037566, 494.43105828),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(352.59602527659996, 485.95595604000005),
      CubicToCommand(352.59602527659996, 485.95595604000005, 364.8160633189,
          485.020163501, 361.9963261778, 488.78099012),
      CubicToCommand(359.17658903669997, 492.52416027600003, 353.53534910819997,
          490.652575198, 353.53534910819997, 490.652575198),
      LineToCommand(352.59602527659996, 485.95595604000005),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(371.66500531659995, 478.18711232),
      CubicToCommand(371.66500531659995, 478.18711232, 383.88504335889996,
          477.251319781, 381.06530621779996, 481.0121464),
      CubicToCommand(378.24556907669995, 484.755316556, 372.60432914819995,
          482.883731478, 372.60432914819995, 482.883731478),
      LineToCommand(371.66500531659995, 478.18711232),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(390.0277268366, 469.71201008),
      CubicToCommand(390.0277268366, 469.71201008, 402.24776487889994,
          468.776217541, 399.4280277378, 472.53704416),
      CubicToCommand(396.6082905967, 476.28021431599996, 390.96705066819993,
          474.408629238, 390.96705066819993, 474.408629238),
      LineToCommand(390.0277268366, 469.71201008),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(341.2958889566, 437.93037668),
      CubicToCommand(341.2958889566, 437.93037668, 353.5159269989,
          436.994584141, 350.6961898578, 440.75541076),
      CubicToCommand(347.8764527167, 444.498580916, 340.8226957482,
          444.039512878, 340.8226957482, 444.039512878),
      LineToCommand(341.2958889566, 437.93037668),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(358.95235195659995, 432.28030852),
      CubicToCommand(358.95235195659995, 432.28030852, 371.1723899989,
          431.3374533958, 368.35265285779997, 435.1053426),
      CubicToCommand(365.53291571669996, 438.848512756, 357.7729002282,
          438.389444718, 357.7729002282, 438.389444718),
      LineToCommand(358.95235195659995, 432.28030852),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(318.90396258, 502.90616052),
      CubicToCommand(318.90396258, 502.90616052, 328.08532334, 502.199902,
          325.96654778, 505.02493608),
      CubicToCommand(323.84777221999997, 507.84997016, 319.6102211,
          506.43745312, 319.6102211, 506.43745312),
      LineToCommand(318.90396258, 502.90616052),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(189.65865341999998, 327.75404756),
      CubicToCommand(189.65865341999998, 327.75404756, 181.88980969999997,
          343.291735, 181.18355118, 348.94180316),
      CubicToCommand(181.18355118, 348.94180316, 182.59606821999998,
          333.40411572000005, 184.71484378, 329.87282312),
      CubicToCommand(186.83361933999998, 326.34153052, 189.65865341999998,
          327.75404756, 189.65865341999998, 327.75404756),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(157.17076149999997, 352.47309576),
      CubicToCommand(157.17076149999997, 352.47309576, 151.52069333999998,
          377.89840248, 152.22695185999999, 382.84221212),
      CubicToCommand(152.22695185999999, 382.84221212, 150.10817629999997,
          362.36071504, 150.81443481999997, 360.24193948000004),
      CubicToCommand(151.52069334, 358.12316392, 157.17076149999997,
          352.47309576000004, 157.17076149999997, 352.47309576000004),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(193.89620453999999, 220.75588178),
      LineToCommand(193.54307527999995, 226.40594994),
      LineToCommand(189.65865341999995, 226.7590792),
      CubicToCommand(189.65865341999995, 226.7590792, 214.73083087999998,
          249.00622258, 215.79021865999994, 262.42513446),
      CubicToCommand(215.79021865999994, 262.42513446, 217.20273569999995,
          247.9468348, 193.89620453999996, 220.75588178),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(200.93053939919997, 222.9894243495),
      CubicToCommand(200.16954584389998, 222.2549154887, 200.5562223836,
          220.93950899520001, 199.83583869319997, 220.48044095720002),
      CubicToCommand(198.4074308365, 219.5693674664, 202.12764759059996,
          219.4687256273, 201.72508023419996, 218.2045228765),
      CubicToCommand(201.0488377013, 216.0751534387, 201.37901355939997,
          216.0380748664, 201.16360471079997, 213.7851101876),
      CubicToCommand(201.06296287169997, 212.7292537002, 202.1011628961,
          210.0101583982, 202.78093672159997, 209.2332740262),
      CubicToCommand(205.33406127139995, 206.3164263386, 202.99634557019996,
          201.139551387, 205.89200550219996, 198.4010339757),
      CubicToCommand(206.42876197739997, 197.890762195, 207.09264498619996,
          196.9161254374, 207.59585418169996, 196.17808528400002),
      CubicToCommand(208.75941509339998, 194.4777678971, 210.84994031259998,
          193.6161325027, 212.52730429759998, 192.1541773663),
      CubicToCommand(213.08877982099995, 191.6668589875, 212.73388491469996,
          190.20666949740001, 213.73853765939998, 190.36910895699998),
      CubicToCommand(214.99920911759997, 190.57215828149998, 217.19037617589998,
          190.3426242625, 217.11092209239996, 191.8275328008),
      CubicToCommand(216.91140406049996, 195.5707029568, 214.56486012779996,
          198.6076145928, 212.30483286379996, 201.5527126212),
      CubicToCommand(213.10113934509997, 202.7957276164, 212.29247333969997,
          203.9169130169, 211.79102979049995, 204.90037800599998),
      CubicToCommand(209.43389197999997, 209.52637131199998, 209.76759913069995,
          214.54257245029999, 209.46037667449997, 219.5570079423),
      CubicToCommand(209.45154844299998, 219.7070878778, 208.90949502889998,
          219.8448082892, 208.92362019929996, 219.9383875431),
      CubicToCommand(209.54689334319994, 224.06117165359998, 210.57803078239996,
          227.9438278673, 212.13003388009997, 231.87945347),
      CubicToCommand(212.77626042589998, 233.521504529, 213.60787983319997,
          235.1017579675, 213.8727267782, 236.7385120876),
      CubicToCommand(214.0687135175, 237.94974544939998, 214.25057508639998,
          239.4205288173, 213.53019139599996, 240.66530945879998),
      CubicToCommand(217.12328161649998, 245.7680272658, 214.81205060979997,
          250.4487556071, 216.87609113449997, 256.6832526924),
      CubicToCommand(217.24157991859997, 257.7867816299, 220.22905345819999,
          261.1662286481, 219.41155922129997, 260.8819595938),
      CubicToCommand(214.97449006939996, 259.3440816665, 214.77673768379998,
          258.6413544391, 214.46421828869995, 257.31182277519997),
      CubicToCommand(214.20643392889997, 256.2118251303, 213.6237706499,
          253.7805301752, 213.20531247679997, 252.7176111026),
      CubicToCommand(213.09231111359998, 252.4280451094, 212.79038559629998,
          249.1015674802, 212.65266518489997, 248.88615863159998),
      CubicToCommand(209.98124233299995, 244.680389145, 212.37899000839997,
          244.9911428938, 209.96005457739997, 240.8277489184),
      CubicToCommand(207.43871166099996, 239.62710943439998, 205.73309733519994,
          237.6778359192, 203.75027654029998, 235.62615491859998),
      CubicToCommand(203.4006785729, 235.2659630734, 205.41881229379996,
          233.9876351522, 205.09923031349996, 233.6115524903),
      CubicToCommand(203.17114455389998, 231.3356344096, 201.13535436999996,
          229.9813836975, 201.72861152679997, 227.3452737716),
      CubicToCommand(202.00228670329994, 226.1269778246, 202.24418024639996,
          224.26068968549998, 200.93053939919997, 222.98942434949998),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(194.60246306, 226.05282068),
      CubicToCommand(194.60246306, 226.05282068, 195.30872158, 238.05921552,
          199.54627269999997, 240.8842496),
      CubicToCommand(203.78382381999995, 243.70928368, 201.66504826,
          242.29676664000002, 196.01498009999997, 240.17799108),
      CubicToCommand(190.36491193999998, 238.05921552, 192.48368749999997,
          236.64669848, 192.48368749999997, 236.64669848),
      CubicToCommand(192.48368749999997, 236.64669848, 187.53987786, 237.352957,
          191.77742897999997, 240.8842496),
      CubicToCommand(196.01498009999995, 244.4155422, 202.37130677999997,
          248.65309332, 199.54627269999997, 248.65309332),
      CubicToCommand(196.72123861999998, 248.65309332, 183.30232673999998,
          241.59050812, 183.30232673999998, 236.64669848),
      CubicToCommand(183.30232673999998, 231.70288884, 181.53668043999997,
          224.46373901, 181.53668043999997, 224.46373901),
      CubicToCommand(181.53668043999997, 224.46373901, 183.47889136999996,
          223.05122197, 191.95399360999997, 223.2277866),
      CubicToCommand(191.95399360999997, 223.2277866, 194.42589843,
          224.46373901, 194.60246306, 226.05282068000002),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(193.18994601999998, 258.89384186),
      CubicToCommand(193.18994601999998, 258.89384186, 178.14663954399998,
          253.96592303670002, 145.51749592, 259.95322964),
      CubicToCommand(145.51749592, 259.95322964, 161.4630476553, 256.2842166286,
          194.60246306, 260.3063589),
      CubicToCommand(212.78861994999997, 262.513416775, 193.18994601999998,
          258.89384186, 193.18994601999998, 258.89384186),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(196.89427195739998, 258.7684809727),
      CubicToCommand(196.89427195739998, 258.7684809727, 182.3347525676,
          252.5569372893, 149.30833852609996, 255.7015533496),
      CubicToCommand(149.30833852609996, 255.7015533496, 165.51344026749996,
          253.4256352689, 198.17966246379996, 260.29753066850003),
      CubicToCommand(216.10803499399998, 264.0689511653, 196.89427195739998,
          258.7684809727, 196.89427195739998, 258.7684809727),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(200.05124754179997, 258.9326860786),
      CubicToCommand(200.05124754179997, 258.9326860786, 185.99317170119997,
          251.6564576763, 152.82550595569998, 252.3362315018),
      CubicToCommand(152.82550595569998, 252.3362315018, 169.15420293809998,
          251.26978113660002, 201.2201053924, 260.553549382),
      CubicToCommand(218.81653641819997, 265.6474389575, 200.05124754179997,
          258.9326860786, 200.05124754179997, 258.9326860786),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(202.29361834279996, 259.3264252035),
      CubicToCommand(202.29361834279996, 259.3264252035, 190.24484799159998,
          251.7217865894, 160.4513323254, 249.783106952),
      CubicToCommand(160.4513323254, 249.783106952, 175.1750568211,
          250.083266823, 203.21528571139999, 260.8696000697),
      CubicToCommand(218.60465886219998, 266.7898121136, 202.29361834279996,
          259.3264252035, 202.29361834279996, 259.3264252035),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(405.844386392, 277.8939616943),
      CubicToCommand(405.844386392, 277.8939616943, 404.20233533299995,
          279.0310379115, 404.5801836412, 276.9458096312),
      CubicToCommand(404.95979759569997, 274.8605813509, 454.7651484261,
          251.6070195799, 461.1461941543, 252.04843115490002),
      CubicToCommand(461.1461941543, 252.04843115490002, 407.73892487189994,
          275.3655561927, 405.844386392, 277.8939616943),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(399.8517828498, 279.02220968),
      CubicToCommand(399.8517828498, 279.02220968, 398.30507669099995,
          280.2846467845, 398.5187198933, 278.1764651023),
      CubicToCommand(398.73236309559996, 276.0682834201, 446.5584244237,
          248.9744409466, 452.9535953223, 248.9144089724),
      CubicToCommand(452.9535953223, 248.9144089724, 401.5432720051999,
          276.3543181207, 399.8517828498, 279.02220968),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(394.04986910799994, 281.4499733425),
      CubicToCommand(394.04986910799994, 281.4499733425, 392.58791397159996,
          282.8130522861, 392.66207111619997, 280.6942767261),
      CubicToCommand(392.7362282608, 278.5772668124, 427.7260409879,
          251.2150461013, 445.05056248349996, 247.9062249351),
      CubicToCommand(445.05056248349996, 247.9062249351, 413.21595969449993,
          262.2556324152, 394.04986910799994, 281.4499733425),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(388.9718703492, 284.7393723994),
      CubicToCommand(388.9718703492, 284.7393723994, 387.6564638557,
          285.9647309316, 387.7235584151, 284.0595985739),
      CubicToCommand(387.79065297449995, 282.1527005699, 419.2791890887,
          257.5272316238, 434.871611564, 254.550351962),
      CubicToCommand(434.871611564, 254.550351962, 406.2222347002,
          267.4642890002, 388.9718703492, 284.7393723994),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(333.02913298, 545.9879302400001),
      CubicToCommand(333.02913298, 545.9879302400001, 306.19130922,
          541.75037912, 335.85416705999995, 538.92534504),
      CubicToCommand(335.85416705999995, 538.92534504, 367.63580046,
          535.39405244, 374.69838566, 526.21269168),
      CubicToCommand(374.69838566, 526.21269168, 398.71117533999995,
          509.9687457200001, 403.65498498, 509.26248720000007),
      CubicToCommand(408.59879462, 508.55622868, 437.55539394,
          502.19990200000007, 438.26165245999994, 497.96235088000003),
      CubicToCommand(438.96791097999994, 493.72479976, 449.56178878,
          489.48724864, 452.38682285999994, 490.8997656800001),
      CubicToCommand(455.21185693999996, 492.3122827200001, 455.21185693999996,
          508.55622868, 450.2680472999999, 509.9687457200001),
      CubicToCommand(445.32423765999994, 511.38126276000014, 412.13008721999995,
          524.09391612, 400.8299509, 526.21269168),
      CubicToCommand(389.52981457999994, 528.33146724, 369.04831749999994,
          541.75037912, 360.5732152599999, 543.8691546800001),
      CubicToCommand(352.09811301999997, 545.9879302400001, 333.02913297999993,
          545.9879302400001, 333.02913297999993, 545.9879302400001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(461.92131287999996, 479.95275862000005),
      CubicToCommand(461.92131287999996, 479.95275862000005, 456.62437398,
          482.77779269999996, 454.50559841999996, 487.36847308),
      CubicToCommand(454.50559841999996, 487.36847308, 443.2054621,
          506.08432386, 418.13328463999994, 511.73439202),
      CubicToCommand(418.13328463999994, 511.73439202, 377.52341973999995,
          527.62520872, 363.75137859999995, 531.15650132),
      CubicToCommand(363.75137859999995, 531.15650132, 340.09171817999993,
          539.98473282, 327.02593555999994, 538.57221578),
      CubicToCommand(327.02593555999994, 538.57221578, 314.66641145999995,
          538.92534504, 325.61341852, 541.75037912),
      CubicToCommand(325.61341852, 541.75037912, 361.27947377999993,
          538.21908652, 367.2826712, 535.04092318),
      CubicToCommand(367.2826712, 535.04092318, 394.82675348, 525.85956242,
          400.12369237999997, 521.26888204),
      CubicToCommand(405.42063127999995, 516.6782016599999, 437.55539394,
          507.84997016, 441.43981579999996, 504.31867755999997),
      CubicToCommand(445.32423766, 500.78738496, 462.62757139999997,
          485.95595604, 461.92131287999996, 479.95275862),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(358.24609343659995, 535.588273533),
      CubicToCommand(358.24609343659995, 535.588273533, 367.4786579393,
          535.182174884, 365.44286775539996, 537.918926649),
      CubicToCommand(363.4070775715, 540.6556784139999, 359.0847754291,
          539.119566133, 359.0847754291, 539.119566133),
      LineToCommand(358.24609343659995, 535.588273533),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(345.529908784, 537.971896038),
      CubicToCommand(345.529908784, 537.971896038, 354.76070764039997,
          537.583453852, 352.7266831028, 540.320205617),
      CubicToCommand(350.6908929189, 543.0569573820001, 346.36859077649996,
          541.503188638, 346.36859077649996, 541.503188638),
      LineToCommand(345.529908784, 537.971896038),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(327.1159835213, 540.178953913),
      CubicToCommand(327.1159835213, 540.178953913, 336.34854802399997,
          539.772855264, 334.31275784009995, 542.509607029),
      CubicToCommand(332.2769676562, 545.246358794, 327.95466551379997,
          543.710246513, 327.95466551379997, 543.710246513),
      LineToCommand(327.1159835213, 540.178953913),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(313.6370396671, 541.150059378),
      CubicToCommand(313.6370396671, 541.150059378, 322.86960416979997,
          540.743960729, 320.83381398589995, 543.480712494),
      CubicToCommand(318.798023802, 546.2174642589999, 314.47572165959997,
          544.663695515, 314.47572165959997, 544.663695515),
      LineToCommand(313.6370396671, 541.1500593779999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(387.4375237145, 522.522490913),
      CubicToCommand(387.4375237145, 522.522490913, 399.72642196249996,
          521.992797023, 397.016154892, 525.630028401),
      CubicToCommand(394.3076534678, 529.284916242, 388.5534121761,
          527.2191100709999, 388.5534121761, 527.2191100709999),
      LineToCommand(387.4375237145, 522.522490913),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(405.650165299, 514.718334267),
      CubicToCommand(405.650165299, 514.718334267, 416.1716516007,
          508.89170147699997, 415.22879647649995, 517.825871755),
      CubicToCommand(414.7520719755, 522.3282698200001, 406.76605376059996,
          519.414953425, 406.76605376059996, 519.414953425),
      LineToCommand(405.650165299, 514.718334267),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(421.7740473106, 509.73921170100004),
      CubicToCommand(421.7740473106, 509.73921170100004, 434.41430917229997,
          503.2063203910001, 431.35267848809997, 512.8644056520001),
      CubicToCommand(429.9790056667, 517.172582624, 422.88817012589993,
          514.453487322, 422.88817012589993, 514.453487322),
      LineToCommand(421.77404731059994, 509.73921170100004),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(438.5724062088, 501.228796535),
      CubicToCommand(438.5724062088, 501.228796535, 446.26885843049996,
          492.577129665, 448.1510373863, 504.33633402299995),
      CubicToCommand(448.8678897841, 508.82107562499993, 439.68829467039996,
          505.925415693, 439.68829467039996, 505.925415693),
      LineToCommand(438.5724062088, 501.228796535),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(372.28651281419997, 530.4502428),
      CubicToCommand(372.28651281419997, 530.4502428, 381.51731167059995,
          530.0441441510001, 379.483287133, 532.780895916),
      CubicToCommand(377.44749694909996, 535.517647681, 373.12342916039995,
          533.9815354, 373.12342916039995, 533.9815354),
      LineToCommand(372.28651281419997, 530.4502428),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(435.14352109419997, 316.10607891890004),
      CubicToCommand(435.14352109419997, 316.10607891890004, 433.8616618804,
          317.28023370840003, 433.8598962341, 315.3892265211),
      CubicToCommand(433.8598962341, 313.4999849801, 464.7304561433,
          290.0804524569, 480.3440663742, 287.6367979777),
      CubicToCommand(480.3440663742, 287.6367979777, 451.91892659049995,
          299.5178319304, 435.14352109419997, 316.10607891890004),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(440.38042801999995, 428.74901592000003),
      CubicToCommand(440.38042801999995, 428.74901592000003, 479.22641226630003,
          468.29949304, 495.47035822629994, 474.65581972),
      CubicToCommand(495.47035822629994, 474.65581972, 511.71253853999997,
          494.43105828, 504.64995333999997, 540.33786208),
      CubicToCommand(504.64995333999997, 540.33786208, 499.00165082629997,
          553.75677396, 493.3515826663, 517.0313309200001),
      CubicToCommand(493.3515826663, 517.0313309200001, 499.00165082629997,
          472.53704416000005, 479.2264122663, 500.78738496000005),
      CubicToCommand(479.2264122663, 500.78738496000005, 464.3932177,
          483.30748659000005, 475.69335401999996, 483.8371804800001),
      CubicToCommand(475.69335401999996, 483.8371804800001, 481.34518782629993,
          487.36847308000006, 482.05144634629994, 484.54343900000015),
      CubicToCommand(482.75770486629995, 481.7184049200001, 468.63076881999996,
          457.7056152400001, 438.26165245999994, 432.2803085200001),
      CubicToCommand(407.8925360999999, 406.85500180000014, 440.38042801999995,
          428.74901592000015, 440.38042801999995, 428.74901592000015),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(337.26668409999996, 497.25609236),
      CubicToCommand(337.26668409999996, 497.25609236, 336.91355483999996,
          494.07792901999994, 340.09171818, 495.49044605999995),
      CubicToCommand(343.26988151999996, 496.90296309999997, 509.59376297999995,
          507.84997016, 565.38818606, 550.22548136),
      CubicToCommand(565.38818606, 550.22548136, 485.58273894629997,
          509.2624872, 337.26668409999996, 497.25609236),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(355.62940562, 489.48724864),
      CubicToCommand(355.62940562, 489.48724864, 355.27627636, 486.3090853,
          358.45443969999997, 487.72160234),
      CubicToCommand(361.63260304, 489.13411938, 602.8198876199999,
          487.36847308000006, 644.4891402999999, 544.5754132),
      CubicToCommand(644.4891402999999, 544.5754132, 605.6449216999999,
          500.08112644000005, 355.62940562, 489.48724864),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(376.1109027, 482.42466344),
      CubicToCommand(376.1109027, 482.42466344, 375.75777344,
          479.24650010000005, 378.93593677999996, 480.65901714000006),
      CubicToCommand(382.11410012, 482.07153418000007, 688.2771685399999,
          459.11813228000005, 729.94642122, 516.3250724),
      CubicToCommand(729.94642122, 516.3250724, 712.99621674,
          471.12452712000004, 376.1109027, 482.42466344),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(393.76736569999997, 473.9495612),
      CubicToCommand(393.76736569999997, 473.9495612, 393.41423643999997,
          470.77139786, 396.59239978, 472.1839149),
      CubicToCommand(399.77056312, 473.59643194, 615.53254098, 405.44248476,
          657.20179366, 462.64942487999997),
      CubicToCommand(657.20179366, 462.64942487999997, 633.5421332399999,
          419.2145259, 393.76736569999997, 473.9495612),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(291.3598803, 514.20629684),
      CubicToCommand(291.3598803, 514.20629684, 291.00675104,
          511.02813349999997, 294.18491437999995, 512.44065054),
      CubicToCommand(297.36307772, 513.85316758, 328.79158186,
          517.7375894400001, 332.32287446, 586.2446658800001),
      CubicToCommand(332.32287446, 586.2446658800001, 319.6102211, 512.08752128,
          291.3598803, 514.20629684),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(275.82219286, 517.03133092),
      CubicToCommand(275.82219286, 517.03133092, 275.46906359999997,
          513.85316758, 278.64722694, 515.26568462),
      CubicToCommand(281.82539027999997, 516.67820166, 306.89756774,
          508.55622868, 301.95375809999996, 577.06330512),
      CubicToCommand(301.95375809999996, 577.06330512, 304.07253366,
          514.9125553599999, 275.82219286, 517.03133092),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(261.69702245999997, 517.7375894400001),
      CubicToCommand(261.69702245999997, 517.7375894400001, 261.34389319999997,
          514.5594261, 264.52205654, 515.97194314),
      CubicToCommand(267.70021987999996, 517.38446018, 294.89117289999996,
          518.4438479600001, 272.99715878, 557.9943250800001),
      CubicToCommand(272.99715878, 557.9943250800001, 289.94736326,
          515.6188138800001, 261.69702245999997, 517.7375894400001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(345.2579992538, 439.448832498),
      CubicToCommand(345.2579992538, 439.448832498, 344.47405229659995,
          442.98012509800003, 347.2090384153, 440.84369307500003),
      CubicToCommand(375.5794431637, 418.5471115986, 432.86054042829994,
          314.547013236, 531.1893828753, 304.59936198180003),
      CubicToCommand(531.1893828753, 304.59936198180003, 463.5439418297,
          283.2173852888, 345.2668274853, 439.448832498),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(365.0332378138, 436.27066915800003),
      CubicToCommand(365.0332378138, 436.27066915800003, 362.6266619069,
          434.169550061, 365.92488919529995, 433.07484935499997),
      CubicToCommand(369.2231164837, 431.96249218599996, 567.7559177482999,
          303.953135436, 637.1281608753, 318.01827386179997),
      CubicToCommand(637.1281608753, 318.01827386179997, 589.2614896823,
          304.75827014879997, 365.0420660453, 436.27066915800003),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(328.23540327549995, 447.058768051),
      CubicToCommand(328.23540327549995, 447.058768051, 327.3366893088,
          449.883802131, 330.3577101281, 448.15346875700004),
      CubicToCommand(346.2043856706, 439.11335970100004, 352.58719704509997,
          338.0989692317, 429.5287658602, 335.8830831252),
      CubicToCommand(429.5287658602, 335.8830831252, 372.30240363089996,
          309.903363467, 328.2354032755, 447.058768051),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(293.0584320406, 466.516190277),
      CubicToCommand(293.0584320406, 466.516190277, 291.1568309755,
          468.79387400400003, 294.60513819939996, 468.33480596600003),
      CubicToCommand(312.6959501892, 465.986496387, 350.48960924069996,
          393.1218048786, 428.95316516639997, 402.08952243630006),
      CubicToCommand(428.95316516639997, 402.08952243630006, 372.51251554059996,
          376.75956061650004, 293.0584320406, 466.5161902770001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(312.90076516, 455.710434921),
      CubicToCommand(312.90076516, 455.710434921, 311.46882601069996,
          458.305934982, 314.76881894539997, 457.19357781300005),
      CubicToCommand(332.07038703909996, 451.419914412, 355.1721032283,
          372.6456047375, 433.8987404527, 366.3828573114),
      CubicToCommand(433.8987404527, 366.3828573114, 373.6442948189,
          352.35832875050005, 312.90076516, 455.710434921),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(280.6282820886, 475.55629933299997),
      CubicToCommand(280.6282820886, 475.55629933299997, 279.08687286869997,
          477.392571485, 281.8801253153, 477.039442225),
      CubicToCommand(296.533223959, 475.132544221, 327.1459995084,
          416.106988412, 390.7022037232, 423.3708572902),
      CubicToCommand(390.7022037232, 423.3708572902, 344.98432407729996,
          402.85404728419996, 280.6282820886, 475.55629933299997),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(267.21113585489996, 485.991268966),
      CubicToCommand(267.21113585489996, 485.991268966, 265.43666132339996,
          487.845197581, 268.2458045867, 487.633320025),
      CubicToCommand(275.60501836509997, 487.08596967200003, 329.70088970449996,
          428.678390068, 362.3088455729, 456.04590771799997),
      CubicToCommand(362.3088455729, 456.04590771799997, 341.09460527839997,
          422.9912433357, 267.21113585489996, 485.991268966),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(389.9800543865, 429.6283077774),
      CubicToCommand(389.9800543865, 429.6283077774, 387.8595131802,
          427.2358570409, 391.27074183179997, 426.5560832154),
      CubicToCommand(394.6819704834, 425.8780750362, 607.7919476008,
          323.9773301243, 674.8158811487999, 346.6941354201),
      CubicToCommand(674.8158811487999, 346.6941354201, 629.0150161268,
          327.49449755390003, 389.9818200328, 429.6283077774),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(330.91035741999997, 543.16289616),
      CubicToCommand(330.91035741999997, 543.16289616, 330.55722815999997,
          539.98473282, 333.7353915, 541.39724986),
      CubicToCommand(336.91355483999996, 542.8097669, 364.10450785999996,
          543.86915468, 342.21049374, 583.4196318),
      CubicToCommand(342.21049374, 583.4196318, 359.16069822, 541.0441206,
          330.91035741999997, 543.16289616),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(349.27307894, 540.33786208),
      CubicToCommand(349.27307894, 540.33786208, 348.91994968, 537.15969874,
          352.09811301999997, 538.57221578),
      CubicToCommand(355.27627636, 539.98473282, 386.70478049999997,
          543.86915468, 390.2360731, 612.3762311199999),
      CubicToCommand(390.2360731, 612.3762311199999, 377.52341974, 538.21908652,
          349.27307894, 540.3378620799999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(361.27947378, 537.512828),
      CubicToCommand(361.27947378, 537.512828, 360.92634452, 534.3346646599999,
          364.10450786, 535.7471817),
      CubicToCommand(367.2826712, 537.1596987400001, 410.71757018, 543.16289616,
          452.38682286, 600.36983628),
      CubicToCommand(452.38682286, 600.36983628, 389.52981458, 535.39405244,
          361.27947378, 537.512828),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(374.7425268175, 533.928566011),
      CubicToCommand(374.7425268175, 533.928566011, 373.97093938439997,
          530.821028523, 377.3080108914, 531.809790451),
      CubicToCommand(380.64508239839995, 532.7808959160001, 416.72429889259996,
          529.4261679460001, 483.99012598369995, 589.7759584800001),
      CubicToCommand(483.99012598369995, 589.7759584800001, 402.4614080812,
          528.0842767580001, 374.7425268175, 533.928566011),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(393.1052483375, 526.159722291),
      CubicToCommand(393.1052483375, 526.159722291, 392.33366090439995,
          523.052184803, 395.67073241139997, 524.040946731),
      CubicToCommand(399.0078039184, 525.012052196, 460.5123271325999,
          532.957460546, 551.7927095499999, 594.71976812),
      CubicToCommand(551.7927095499999, 594.71976812, 420.82412960119996,
          520.315433038, 393.1052483375, 526.159722291),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(321.72899665999995, 505.7311946),
      CubicToCommand(321.72899665999995, 505.7311946, 321.3758674, 502.55303126,
          324.55403074, 503.9655483),
      CubicToCommand(327.73219408, 505.37806534000003, 422.0177065,
          509.96874572, 475.69335401999996, 557.28806656),
      CubicToCommand(475.69335401999996, 557.28806656, 414.07053250369995,
          513.553007709, 321.72899665999995, 505.7311946),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(304.07253366, 512.7937798),
      CubicToCommand(304.07253366, 512.7937798, 303.7194044, 509.61561645999996,
          306.89756774, 511.02813349999997),
      CubicToCommand(310.07573107999997, 512.44065054, 353.51063006,
          518.44384796, 395.17988274, 575.65078808),
      CubicToCommand(395.17988274, 575.65078808, 332.32287446, 510.67500424,
          304.07253366, 512.7937798),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(412.3119487889, 518.020092848),
      CubicToCommand(412.3119487889, 518.020092848, 411.3143586294,
          514.983181212, 414.71499340319997, 515.724752658),
      CubicToCommand(418.11562817699996, 516.448667641, 480.036843918,
          519.856365, 575.5936216739999, 574.76796493),
      CubicToCommand(575.5936216739999, 574.76796493, 438.46823307709997,
          514.02973221, 412.31194878889994, 518.020092848),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(427.14337770889995, 513.782541728),
      CubicToCommand(427.14337770889995, 513.782541728, 426.1457875494,
          510.745630092, 429.5464223232, 511.487201538),
      CubicToCommand(432.94705709699997, 512.211116521, 494.86827283799994,
          515.61881388, 590.4250505939999, 570.53041381),
      CubicToCommand(590.4250505939999, 570.53041381, 454.3590497770999,
          509.08592257, 427.14337770889995, 513.782541728),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(444.0935821889, 504.954310228),
      CubicToCommand(444.0935821889, 504.954310228, 443.0959920294,
          501.91739859200004, 446.4966268032, 502.658970038),
      CubicToCommand(449.897261577, 503.382885021, 525.943647718,
          511.02813349999997, 684.3644963392001, 571.58980159),
      CubicToCommand(684.3644963392001, 571.58980159, 471.32161378119997,
          500.25769106999996, 444.09534783519996, 504.95431022799994),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(247.57185205999997, 517.03133092),
      CubicToCommand(247.57185205999997, 517.03133092, 256.75321282,
          516.3250724, 254.63443725999997, 519.15010648),
      CubicToCommand(252.51566169999998, 521.97514056, 248.27811057999998,
          520.56262352, 248.27811057999998, 520.56262352),
      LineToCommand(247.57185205999997, 517.03133092),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(301.95375809999996, 541.75037912),
      CubicToCommand(301.95375809999996, 541.75037912, 311.13511886,
          541.0441206, 309.01634329999996, 543.86915468),
      CubicToCommand(306.89756774, 546.69418876, 302.66001661999996,
          545.28167172, 302.66001661999996, 545.28167172),
      LineToCommand(301.95375809999996, 541.75037912),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(286.41607065999995, 541.0441206),
      CubicToCommand(286.41607065999995, 541.0441206, 295.59743141999996,
          540.33786208, 293.47865586, 543.16289616),
      CubicToCommand(291.3598803, 545.98793024, 287.12232917999995, 544.5754132,
          287.12232917999995, 544.5754132),
      LineToCommand(286.41607065999995, 541.0441206),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(118.02638302899996, 520.174181334),
      CubicToCommand(118.02638302899996, 520.174181334, 126.94289684399996,
          522.50483445, 124.01192398599997, 524.482358306),
      CubicToCommand(121.08095112799998, 526.459882162, 117.53200206499997,
          523.7407868600001, 117.53200206499997, 523.7407868600001),
      LineToCommand(118.02638302899996, 520.174181334),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(121.55767562899996, 503.22397685400006),
      CubicToCommand(121.55767562899996, 503.22397685400006, 130.47418944399996,
          505.55462997, 127.54321658599997, 507.532153826),
      CubicToCommand(124.61224372799998, 509.5096776820001, 121.06329466499997,
          506.79058238000005, 121.06329466499997, 506.79058238000005),
      LineToCommand(121.55767562899996, 503.22397685400006),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(108.84502226899997, 495.455133134),
      CubicToCommand(108.84502226899997, 495.455133134, 117.76153608399997,
          497.78578625, 114.83056322599998, 499.763310106),
      CubicToCommand(111.89959036799996, 501.740833962, 108.35064130499995,
          499.02173866000004, 108.35064130499995, 499.02173866000004),
      LineToCommand(108.84502226899997, 495.455133134),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(249.69062762, 627.91391856),
      LineToCommand(239.80300833999996, 631.44521116),
      CubicToCommand(236.27171574, 631.44521116, 216.49647717999997,
          637.8015378399999, 206.60885789999998, 655.45800084),
      CubicToCommand(206.60885789999998, 655.45800084, 228.50287201999998,
          638.5077963599999, 249.69062762, 627.91391856),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(404.5660584708, 791.501048255),
      CubicToCommand(404.8150145991, 791.94245983, 404.9121251456,
          792.684031276, 405.42769386519996, 792.719344202),
      CubicToCommand(406.5894891306, 792.789970054, 408.76653101849996,
          793.319663944, 408.545825231, 792.207306775),
      CubicToCommand(407.0485571686, 784.597371222, 405.5053823024, 775.8750785,
          398.2079661445, 772.69691516),
      CubicToCommand(397.0797181588, 772.202534196, 394.5336561942,
          772.926449179, 394.402998368, 774.4978743859999),
      CubicToCommand(394.1787612879, 777.1816567619999, 393.97218067079996,
          779.5652792669999, 394.5177653775, 782.1431228649999),
      CubicToCommand(395.04745926749996, 784.6679970739999, 398.8577239829,
          784.6679970739999, 400.47682163999997, 782.2314051799999),
      CubicToCommand(402.1294665768, 785.1800345009999, 402.89222577839996,
          788.4464801559999, 404.5660584708, 791.5010482549999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(385.00622875939996, 799.852555254),
      CubicToCommand(386.3269321918, 802.342116537, 386.1026951117,
          805.6262186549999, 388.60108462619996, 806.6326370459999),
      CubicToCommand(389.9076628882, 807.1446744729999, 393.17410854319996,
          805.4319975619999, 392.43606838979997, 803.525099558),
      CubicToCommand(391.0200200572, 799.8878681799999, 390.3349492928,
          795.9328204679999, 387.88246658209994, 792.7370006649999),
      CubicToCommand(387.5293373221, 792.2779326269999, 387.9530924341,
          791.3421400879998, 387.67058902609995, 790.7594768089999),
      CubicToCommand(386.6217951239, 788.6053883229998, 384.60013011039996,
          787.2988100609999, 382.11410012, 787.8814733399998),
      CubicToCommand(380.1454044955, 791.7658951999999, 382.1723664479,
          795.5267218189998, 384.8596801165, 798.545976992),
      CubicToCommand(385.0998080133, 798.8108239369999, 384.8067107275,
          799.4817695309999, 385.00622875939996, 799.852555254),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(315.0831039868, 790.688850957),
      CubicToCommand(314.8924141864, 790.017905363, 314.825319627,
          789.205708065, 315.11665126649996, 788.6407012489999),
      CubicToCommand(316.0542094518, 786.82208556, 317.45436696769997,
          784.844561704, 316.8593441646, 783.0259460149999),
      CubicToCommand(316.24489925219996, 781.1720173999998, 314.27443798139996,
          781.489833734, 313.1267678864, 782.4962521249998),
      CubicToCommand(311.12275933589996, 784.2442419619999, 311.0362426672,
          787.4753746909998, 309.8161810739, 789.8766536589999),
      CubicToCommand(309.4701143991, 790.5475992529999, 309.5601623604,
          791.5716741069998, 308.7815123421, 792.260276164),
      CubicToCommand(307.9445959959, 793.0018476099999, 307.1677116239,
          795.685629986, 307.3372136687, 796.6920483769999),
      CubicToCommand(307.43079292259995, 797.2570551929999, 307.1076796497,
          814.7369535629999, 307.4996531283, 814.2778855249999),
      CubicToCommand(308.592588188, 812.9889637259998, 313.977809403,
          795.7915687639999, 314.09963899769997, 794.2201435569998),
      CubicToCommand(314.20028083679995, 792.9312217579998, 315.49273392839996,
          792.1190244599999, 315.0831039868, 790.6888509569999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(269.81546414739995, 778.70011258),
      CubicToCommand(274.4661765016, 774.28599683, 279.3923296786,
          769.0596837820001, 278.611914014, 762.509136009),
      CubicToCommand(278.4070990432, 760.778802635, 275.2730768607,
          761.714595174, 274.94290100259997, 763.1977380659999),
      CubicToCommand(273.52685267, 769.6070341349999, 269.92669986429996,
          774.303653293, 265.39252016589995, 778.52354795),
      CubicToCommand(261.5151608911, 782.143122865, 258.2275274805,
          793.337320407, 257.8126006, 794.2378000199999),
      CubicToCommand(264.3401949711, 784.9505004819999, 268.32525867019996,
          780.1126296199999, 269.8154641474, 778.7001125799999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(245.84858127119998, 768.176860632),
      CubicToCommand(246.7720142861, 767.505915038, 246.23878910349998,
          766.640748351, 246.6219343506, 766.058085072),
      CubicToCommand(248.30459527449997, 763.4802414740001, 250.60170111079998,
          761.290840062, 250.63348274419997, 758.2186155),
      CubicToCommand(250.63877968309998, 757.724234536, 249.97136538169997,
          757.1768841830001, 249.37987387119998, 757.582982832),
      CubicToCommand(248.89078984609995, 757.900799166, 248.28693881149997,
          758.130333185, 248.09624901109999, 758.359867204),
      CubicToCommand(244.51198702209996, 762.685700639, 242.0400822021,
          767.3999762599999, 239.49225459119998, 772.3614423629999),
      CubicToCommand(239.16914131829998, 772.997075031, 237.14924195109998,
          780.924826918, 237.70188924299998, 781.1190480109999),
      CubicToCommand(238.12387870869998, 781.2779561779998, 241.1607903447,
          773.897554644, 241.53157606769997, 773.6856770879999),
      CubicToCommand(243.76158734459995, 772.4850376039999, 243.78277510019996,
          769.6246905979999, 245.84858127119998, 768.176860632),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(275.3931408091, 802.677589334),
      CubicToCommand(276.17708776629996, 801.141477053, 278.95974633509996,
          799.022701493, 278.7602283032, 797.451276286),
      CubicToCommand(278.5518820398, 795.8092252270001, 279.3782045082,
          793.2666945550001, 277.7679350826, 794.484990502),
      CubicToCommand(275.5485176835, 796.144698024, 269.4588035948,
          798.5283205290001, 268.9820790938, 808.7867255320001),
      CubicToCommand(268.93617229, 809.793143923, 274.1872043862,
          805.0435553760001, 275.3931408091, 802.6775893340001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(300.89437031999995, 772.3437859),
      CubicToCommand(301.60062883999996, 771.1608028789999, 302.8507064204,
          772.008313103, 303.66113807209996, 771.531588602),
      CubicToCommand(304.80527687449995, 770.878299471, 305.8840867638,
          769.889537543, 306.39965548339995, 768.741867448),
      CubicToCommand(308.11233239439997, 764.9633843660001, 311.23576069909996,
          761.7499081000001, 311.48824812, 757.51235698),
      CubicToCommand(308.8556694867, 755.0404521600001, 307.656795649,
          758.642370612, 306.54443848, 760.3373910600001),
      CubicToCommand(304.2084884251, 757.4240746650001, 302.4446077714,
          760.7434897090001, 300.14926758139995, 761.6616257850001),
      CubicToCommand(300.0256723404, 761.714595174, 299.6495896785,
          761.0966189690001, 299.51716620599996, 761.1495883580001),
      CubicToCommand(297.4390005109, 761.92647273, 296.23836102689995,
          763.833370734, 294.47624601949997, 765.2105748480001),
      CubicToCommand(294.1743205022, 765.440108867, 293.4592337507,
          765.1222925330001, 293.19968374459995, 765.369483015),
      CubicToCommand(292.04848235699995, 766.4288707950001, 290.3305085071,
          767.011534074, 289.83612754309996, 768.212173558),
      CubicToCommand(287.8762601501, 772.979418568, 282.3321307681,
          776.6872757980001, 279.0003562, 790.0002489),
      CubicToCommand(279.6730674403, 791.606987033, 286.9669523056,
          778.276357468, 287.82682205369997, 777.040405058),
      CubicToCommand(289.30290236049996, 774.921629498, 289.5112486239,
          779.971377916, 291.7642133027, 778.806051358),
      CubicToCommand(291.854261264, 778.753081969, 292.18267147579996,
          779.176837081, 292.41926808, 779.4063711),
      CubicToCommand(292.76180346219996, 778.911990136, 293.14671435559995,
          778.505891487, 293.83178511999995, 778.70011258),
      CubicToCommand(293.83178511999995, 777.9938540600001, 293.5951885158,
          777.0050921320001, 293.95008342209996, 776.740245187),
      CubicToCommand(296.1341878952, 775.0099118129999, 295.985873606,
          773.120670272, 297.36307772, 770.9312688599999),
      CubicToCommand(298.17174372539995, 772.326129437, 300.04509444969995,
          771.0548641009999, 300.89437031999995, 772.3437859),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(406.48001905999996, 868.3949446199999),
      CubicToCommand(406.48001905999996, 868.3949446199999, 419.54580167999995,
          832.3757601, 411.77695796, 812.6005215399999),
      CubicToCommand(411.77695796, 812.6005215399999, 431.90532578,
          850.7384816199999, 423.7833528, 870.51372018),
      CubicToCommand(423.7833528, 870.51372018, 423.07709428, 852.1509986599999,
          416.01450908, 843.32276716),
      CubicToCommand(416.01450908, 843.32276716, 408.95192388, 865.9230398,
          406.48001905999996, 868.3949446199999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(380.34845382, 863.80426424),
      CubicToCommand(380.34845382, 863.80426424, 389.88294383999994,
          848.2665767999999, 375.75777344, 815.77868488),
      CubicToCommand(375.75777344, 815.77868488, 374.3452564, 851.7978694,
          362.33886155999994, 871.2199787),
      CubicToCommand(362.33886155999994, 871.2199787, 387.41103902,
          835.55392344, 380.34845382, 863.80426424),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(362.69199082, 860.27297164),
      CubicToCommand(362.69199082, 860.27297164, 362.33886156, 824.96004564,
          363.04512007999995, 819.66310674),
      CubicToCommand(363.04512007999995, 819.66310674, 356.33566413999995,
          848.9728353200001, 338.32607188, 865.9230398),
      CubicToCommand(338.32607188, 865.9230398, 363.75137859999995, 844.7352842,
          362.69199082, 860.27297164),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(345.74178634, 803.77229004),
      CubicToCommand(345.74178634, 803.77229004, 356.33566413999995,
          827.78507972, 338.67920114, 860.27297164),
      CubicToCommand(338.67920114, 860.27297164, 349.97933745999995,
          838.73208678, 341.50423522, 826.37256268),
      CubicToCommand(341.50423522, 826.37256268, 346.0949156, 820.3693652600001,
          345.74178634, 803.77229004),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(311.84137738, 859.5667131199999),
      CubicToCommand(311.84137738, 859.5667131199999, 310.07573107999997,
          832.0226308399999, 313.25389442, 828.13820898),
      CubicToCommand(313.25389442, 828.13820898, 313.60702368, 816.83807266,
          312.90076516, 815.07242636),
      CubicToCommand(312.90076516, 815.07242636, 319.96335036, 804.1254193,
          320.31647962, 817.1912019199999),
      CubicToCommand(320.31647962, 817.1912019199999, 322.78838443999996,
          830.96324306, 327.73219408, 839.0852160399999),
      CubicToCommand(327.73219408, 839.0852160399999, 334.08852076,
          848.6197060599999, 333.7353915, 859.9198423799999),
      CubicToCommand(333.7353915, 859.9198423799999, 316.07892849999996,
          806.5973241199999, 311.84137738, 859.5667131199999),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(305.4850507, 810.83487524),
      CubicToCommand(305.4850507, 810.83487524, 293.83178511999995,
          829.90385528, 290.65362178, 863.45113498),
      CubicToCommand(290.65362178, 863.45113498, 288.18171695999996,
          852.5041279200001, 294.89117289999996, 827.0788212),
      CubicToCommand(294.89117289999996, 827.0788212, 302.30688735999996,
          799.88786818, 305.4850507, 810.83487524),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(266.99396135999996, 845.79467198),
      CubicToCommand(266.99396135999996, 845.79467198, 275.82219286,
          836.2601819600001, 278.29409768, 827.43195046),
      CubicToCommand(278.29409768, 827.43195046, 284.65042436, 799.53473892,
          273.35028803999995, 814.7192971000001),
      CubicToCommand(273.35028803999995, 814.7192971000001, 273.70341729999996,
          828.8444675000001, 259.22511763999995, 841.91025012),
      CubicToCommand(259.22511763999995, 841.91025012, 267.70021987999996,
          837.6726990000001, 266.99396135999996, 845.79467198),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(256.75321282, 836.9664404800001),
      CubicToCommand(256.75321282, 836.9664404800001, 262.75641024,
          806.2441948600001, 264.16892728, 804.83167782),
      CubicToCommand(264.16892728, 804.83167782, 267.34709061999996,
          798.8284804000001, 262.40328098, 804.47854856),
      CubicToCommand(262.40328098, 804.47854856, 246.86559353999996,
          838.3789575200001, 239.80300833999996, 850.0322231000001),
      CubicToCommand(239.80300833999996, 850.0322231000001, 253.92817873999996,
          833.7882771400001, 256.75321282, 836.9664404800001),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(246.51246427999996, 807.6567119),
      CubicToCommand(246.51246427999996, 807.6567119, 266.99396135999996,
          768.10623478, 228.50287201999998, 813.6599093199999),
      CubicToCommand(228.50287201999998, 813.6599093199999, 247.92498131999997,
          796.3565755799999, 246.51246428, 807.6567119),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(219.32151125999997, 781.87827592),
      CubicToCommand(219.32151125999997, 781.87827592, 227.79661349999998,
          748.6841254799999, 232.38729387999996, 749.03725474),
      LineToCommand(235.21232795999998, 751.86228882),
      CubicToCommand(235.21232795999998, 751.86228882, 224.61845015999998,
          768.8124933, 225.67783794, 786.1158270399999),
      CubicToCommand(225.67783794, 786.1158270399999, 224.61845015999998,
          769.1656225599999, 219.32151125999997, 781.87827592),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(802.51448415, 761.7499081),
      CubicToCommand(802.51448415, 761.7499081, 781.32672855, 744.0934451,
          776.9126128, 737.91368305),
      CubicToCommand(776.9126128, 737.91368305, 800.74883785, 770.5781396,
          800.74883785, 782.9376637),
      CubicToCommand(800.74883785, 782.9376637, 805.1629536, 769.69531645,
          802.51448415, 761.7499081),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(812.2255388, 722.9056895),
      CubicToCommand(812.2255388, 722.9056895, 775.1469665, 696.4209950000001,
          768.96720445, 683.17864775),
      CubicToCommand(768.96720445, 683.17864775, 815.7568314, 735.2652136,
          815.7568314, 743.21062195),
      CubicToCommand(815.7568314, 743.21062195, 816.6396545499999,
          727.3198052500001, 812.2255388, 722.9056895),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(842.2415258999999, 450.99615930000004),
      CubicToCommand(842.2415258999999, 450.99615930000004, 821.0537703,
          436.87098890000004, 818.40530085, 440.4022815),
      CubicToCommand(818.40530085, 440.4022815, 836.944587, 451.87898244999997,
          841.35870275, 466.886976),
      CubicToCommand(841.35870275, 466.886976, 838.7102333, 450.99615930000004,
          842.2415258999999, 450.99615930000004),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(857.24951945, 593.13068645),
      LineToCommand(826.3507092, 571.94293085),
      CubicToCommand(826.3507092, 571.94293085, 859.8979889, 601.95891795,
          860.78081205, 609.0215031500001),
      LineToCommand(857.24951945, 593.13068645),
      CloseCommand()
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(167.32322772499998, 553.4036447),
      LineToCommand(206.16744632499996, 561.790464625)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(256.0469543, 839.4383452999999),
      CubicToCommand(256.0469543, 839.4383452999999, 255.16413114999997,
          833.25858325, 239.27331445, 851.7978694)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(265.75800895, 848.2665767999999),
      CubicToCommand(265.75800895, 848.2665767999999, 269.28930155,
          836.7898758499999, 257.8126006, 844.7352842)
    ],
  ),
  Path(
    commands: const <PathCommand>[
      MoveToCommand(361.10290914999996, 863.27457035),
      CubicToCommand(361.10290914999996, 863.27457035, 363.75137859999995,
          843.85246105, 343.44644615, 866.80586295)
    ],
  ),
];
