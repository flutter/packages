// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/overdraw_optimizer.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';
import 'helpers.dart';
import 'test_svg_strings.dart';

Node parseAndResolve(String source) {
  final Node node = parseToNodeTree(source);
  final ResolvingVisitor visitor = ResolvingVisitor();
  return node.accept(visitor, AffineMatrix.identity);
}

void main() {
  setUpAll(() {
    if (!initializePathOpsFromFlutterCache()) {
      fail('error in setup');
    }
  });

  test(
      'Basic case of two opaque shapes overlapping with a stroke (cannot be optimized yet)',
      () {
    final Node node = parseAndResolve(basicOverlapWithStroke);
    final VectorInstructions instructions = parse(basicOverlapWithStroke);

    final List<ResolvedPathNode> pathNodesOld =
        queryChildren<ResolvedPathNode>(node);

    final OverdrawOptimizer visitor = OverdrawOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedPathNode> pathNodesNew =
        queryChildren<ResolvedPathNode>(newNode);

    expect(pathNodesOld.length, pathNodesNew.length);

    expect(instructions.paints, const <Paint>[
      Paint(
          blendMode: BlendMode.srcOver,
          stroke: Stroke(color: Color(0xff008000)),
          fill: Fill(color: Color(0xffff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xff0000ff)))
    ]);

    expect(instructions.paths, <Path>[
      Path(
        commands: const <PathCommand>[
          MoveToCommand(99.0, 221.5),
          LineToCommand(692.0, 221.5),
          LineToCommand(692.0, 316.5),
          LineToCommand(99.0, 316.5),
          CloseCommand()
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(367.0, 41.50001),
          LineToCommand(448.0, 41.50001),
          LineToCommand(448.0, 527.49999),
          LineToCommand(367.0, 527.49999),
          CloseCommand()
        ],
      )
    ]);
  });

  test('Basic case of two opaque shapes overlapping', () {
    final Node node = parseAndResolve(basicOverlap);
    final VectorInstructions instructions = parse(basicOverlap);

    final List<ResolvedPathNode> pathNodesOld =
        queryChildren<ResolvedPathNode>(node);

    final OverdrawOptimizer visitor = OverdrawOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedPathNode> pathNodesNew =
        queryChildren<ResolvedPathNode>(newNode);

    expect(pathNodesOld.length, pathNodesNew.length);

    expect(instructions.paints, const <Paint>[
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xffff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xff0000ff)))
    ]);

    expect(instructions.paths, <Path>[
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(367.0, 221.5),
          LineToCommand(99.0, 221.5),
          LineToCommand(99.0, 316.5),
          LineToCommand(367.0, 316.5),
          LineToCommand(367.0, 221.5),
          CloseCommand(),
          MoveToCommand(448.0, 221.5),
          LineToCommand(448.0, 316.5),
          LineToCommand(692.0, 316.5),
          LineToCommand(692.0, 221.5),
          LineToCommand(448.0, 221.5),
          CloseCommand()
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(367.0, 41.50001),
          LineToCommand(448.0, 41.50001),
          LineToCommand(448.0, 527.49999),
          LineToCommand(367.0, 527.49999),
          CloseCommand()
        ],
      )
    ]);
  });

  test('Basic case of two shapes with opacity < 1.0 overlapping', () {
    final Node node = parseAndResolve(opacityOverlap);
    final VectorInstructions instructions = parse(opacityOverlap);

    final OverdrawOptimizer visitor = OverdrawOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedPathNode> pathNodesNew =
        queryChildren<ResolvedPathNode>(newNode);

    expect(pathNodesNew.length, 3);

    expect(instructions.paints, const <Paint>[
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x7fff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x4c0000ff))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xa58a0075)))
    ]);

    expect(instructions.paths, <Path>[
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(343.0, 240.5),
          LineToCommand(88.0, 240.5),
          LineToCommand(88.0, 366.5),
          LineToCommand(343.0, 366.5),
          LineToCommand(343.0, 240.5),
          CloseCommand(),
          MoveToCommand(484.0, 240.5),
          LineToCommand(484.0, 366.5),
          LineToCommand(711.0, 366.5),
          LineToCommand(711.0, 240.5),
          LineToCommand(484.0, 240.5),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(484.0, 63.5),
          LineToCommand(343.0, 63.5),
          LineToCommand(343.0, 240.5),
          LineToCommand(484.0, 240.5),
          LineToCommand(484.0, 63.5),
          CloseCommand(),
          MoveToCommand(484.0, 366.5),
          LineToCommand(343.0, 366.5),
          LineToCommand(343.0, 565.5),
          LineToCommand(484.0, 565.5),
          LineToCommand(484.0, 366.5),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(343.0, 240.5),
          LineToCommand(484.0, 240.5),
          LineToCommand(484.0, 366.5),
          LineToCommand(343.0, 366.5),
          CloseCommand()
        ],
      )
    ]);
  });

  test('Solid shape overlapping semi-transparent shape', () {
    final Node node = parseAndResolve(solidOverTrasnparent);
    final VectorInstructions instructions = parse(solidOverTrasnparent);

    final OverdrawOptimizer visitor = OverdrawOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedPathNode> pathNodesNew =
        queryChildren<ResolvedPathNode>(newNode);

    expect(pathNodesNew.length, 2);

    expect(instructions.paints, const <Paint>[
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x7fff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xff0000ff)))
    ]);

    expect(instructions.paths, <Path>[
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(343.0, 240.5),
          LineToCommand(88.0, 240.5),
          LineToCommand(88.0, 366.5),
          LineToCommand(343.0, 366.5),
          LineToCommand(343.0, 240.5),
          CloseCommand(),
          MoveToCommand(484.0, 240.5),
          LineToCommand(484.0, 366.5),
          LineToCommand(711.0, 366.5),
          LineToCommand(711.0, 240.5),
          LineToCommand(484.0, 240.5),
          CloseCommand()
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(343.0, 63.5),
          LineToCommand(484.0, 63.5),
          LineToCommand(484.0, 565.50001),
          LineToCommand(343.0, 565.50001),
          CloseCommand()
        ],
      )
    ]);
  });

  test('Semi-transparent shape overlapping solid shape', () {
    final Node node = parseAndResolve(transparentOverSolid);
    final VectorInstructions instructions = parse(transparentOverSolid);

    final OverdrawOptimizer visitor = OverdrawOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedPathNode> pathNodesNew =
        queryChildren<ResolvedPathNode>(newNode);

    expect(pathNodesNew.length, 3);

    expect(instructions.paints, const <Paint>[
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xffff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x7f0000ff))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xff80007f)))
    ]);

    expect(instructions.paths, <Path>[
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(343.0, 240.5),
          LineToCommand(88.0, 240.5),
          LineToCommand(88.0, 366.5),
          LineToCommand(343.0, 366.5),
          LineToCommand(343.0, 240.5),
          CloseCommand(),
          MoveToCommand(484.0, 240.5),
          LineToCommand(484.0, 366.5),
          LineToCommand(711.0, 366.5),
          LineToCommand(711.0, 240.5),
          LineToCommand(484.0, 240.5),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(484.0, 63.5),
          LineToCommand(343.0, 63.5),
          LineToCommand(343.0, 240.5),
          LineToCommand(484.0, 240.5),
          LineToCommand(484.0, 63.5),
          CloseCommand(),
          MoveToCommand(484.0, 366.5),
          LineToCommand(343.0, 366.5),
          LineToCommand(343.0, 565.5),
          LineToCommand(484.0, 565.5),
          LineToCommand(484.0, 366.5),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(343.0, 240.5),
          LineToCommand(484.0, 240.5),
          LineToCommand(484.0, 366.5),
          LineToCommand(343.0, 366.5),
          CloseCommand()
        ],
      )
    ]);
  });

  test('Does not attempt to optimize overdraw when a mask is involved', () {
    final Node node = parseAndResolve('''
<svg width="289" height="528" viewBox="0 0 289 528" fill="none" xmlns="http://www.w3.org/2000/svg">
  <mask id="mask0" x="0" y="0" width="289" height="528">
    <rect width="288.75" height="528" rx="21.5625" fill="white" />
  </mask>
  <g mask="url(#mask0)">
    <path fill-rule="evenodd" clip-rule="evenodd"
      d="M44.1855 464.814H244.564V64.0564H44.1855V464.814ZM45.8428 462.333H242.081V65.7158H45.8428V462.333Z"
      fill="#DADCE0" />
    <path d="M103.803 481.375H184.948" stroke="#DADCE0" stroke-width="3.77344" />
  </g>
</svg>
''');

    final Node result = OverdrawOptimizer().apply(node);
    expect(
      queryChildren<ResolvedPathNode>(result),
      queryChildren<ResolvedPathNode>(node),
    );
  });

  test('Multiple opaque and semi-trasnparent shapes', () {
    final Node node = parseAndResolve(complexOpacityTest);
    final VectorInstructions instructions = parse(complexOpacityTest);

    final OverdrawOptimizer visitor = OverdrawOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedPathNode> pathNodesNew =
        queryChildren<ResolvedPathNode>(newNode);

    expect(pathNodesNew.length, 22);

    expect(instructions.paints, const <Paint>[
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xff0000ff))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xffff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xccff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x99ff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x66ff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x33ff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xff008000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xbfff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0xbf008000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x7fff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x7f008000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x3fff0000))),
      Paint(blendMode: BlendMode.srcOver, fill: Fill(color: Color(0x3f008000)))
    ]);

    expect(instructions.paths, <Path>[
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(150.0, 100.0),
          LineToCommand(100.0, 100.0),
          LineToCommand(100.0, 250.0),
          LineToCommand(1100.0, 250.0),
          LineToCommand(1100.0, 100.0),
          LineToCommand(250.0, 100.0),
          CubicToCommand(250.0, 127.59574890136719, 227.5957489013672, 150.0,
              200.0, 150.0),
          CubicToCommand(172.4042510986328, 150.0, 150.0, 127.59574890136719,
              150.0, 100.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(200.0, 50.0),
          CubicToCommand(
              227.5957489013672, 50.0, 250.0, 72.40425109863281, 250.0, 100.0),
          CubicToCommand(250.0, 127.59574890136719, 227.5957489013672, 150.0,
              200.0, 150.0),
          CubicToCommand(172.4042510986328, 150.0, 150.0, 127.59574890136719,
              150.0, 100.0),
          CubicToCommand(
              150.0, 72.40425109863281, 172.4042510986328, 50.0, 200.0, 50.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(400.0, 50.0),
          CubicToCommand(
              427.59576416015625, 50.0, 450.0, 72.40425109863281, 450.0, 100.0),
          CubicToCommand(450.0, 127.59574890136719, 427.59576416015625, 150.0,
              400.0, 150.0),
          CubicToCommand(372.40423583984375, 150.0, 350.0, 127.59574890136719,
              350.0, 100.0),
          CubicToCommand(
              350.0, 72.40425109863281, 372.40423583984375, 50.0, 400.0, 50.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(600.0, 50.0),
          CubicToCommand(
              627.5957641601562, 50.0, 650.0, 72.40425109863281, 650.0, 100.0),
          CubicToCommand(650.0, 127.59574890136719, 627.5957641601562, 150.0,
              600.0, 150.0),
          CubicToCommand(572.4042358398438, 150.0, 550.0, 127.59574890136719,
              550.0, 100.0),
          CubicToCommand(
              550.0, 72.40425109863281, 572.4042358398438, 50.0, 600.0, 50.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(800.0, 50.0),
          CubicToCommand(
              827.5957641601562, 50.0, 850.0, 72.40425109863281, 850.0, 100.0),
          CubicToCommand(850.0, 127.59574890136719, 827.5957641601562, 150.0,
              800.0, 150.0),
          CubicToCommand(772.4042358398438, 150.0, 750.0, 127.59574890136719,
              750.0, 100.0),
          CubicToCommand(
              750.0, 72.40425109863281, 772.4042358398438, 50.0, 800.0, 50.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(1000.0, 50.0),
          CubicToCommand(
              1027.595703125, 50.0, 1050.0, 72.40425109863281, 1050.0, 100.0),
          CubicToCommand(
              1050.0, 127.59574890136719, 1027.595703125, 150.0, 1000.0, 150.0),
          CubicToCommand(972.4042358398438, 150.0, 950.0, 127.59574890136719,
              950.0, 100.0),
          CubicToCommand(
              950.0, 72.40425109863281, 972.4042358398438, 50.0, 1000.0, 50.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(200.0000457763672, 203.1529998779297),
          CubicToCommand(194.55233764648438, 201.1146697998047,
              188.6553192138672, 200.0, 182.5, 200.0),
          CubicToCommand(
              154.9042510986328, 200.0, 132.5, 222.4042510986328, 132.5, 250.0),
          CubicToCommand(132.5, 277.59576416015625, 154.9042510986328, 300.0,
              182.5, 300.0),
          CubicToCommand(188.65528869628906, 300.0, 194.55230712890625,
              298.88531494140625, 200.0, 296.8470153808594),
          CubicToCommand(181.02427673339844, 289.7470703125, 167.5,
              271.4404602050781, 167.5, 250.0),
          CubicToCommand(167.5, 228.55953979492188, 181.02427673339844,
              210.2529296875, 200.0000457763672, 203.1529998779297),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(217.5, 200.0),
          CubicToCommand(
              245.0957489013672, 200.0, 267.5, 222.4042510986328, 267.5, 250.0),
          CubicToCommand(267.5, 277.59576416015625, 245.0957489013672, 300.0,
              217.5, 300.0),
          CubicToCommand(189.9042510986328, 300.0, 167.5, 277.59576416015625,
              167.5, 250.0),
          CubicToCommand(
              167.5, 222.4042510986328, 189.9042510986328, 200.0, 217.5, 200.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(382.5, 200.0),
          CubicToCommand(410.09576416015625, 200.0, 432.5, 222.4042510986328,
              432.5, 250.0),
          CubicToCommand(432.5, 277.59576416015625, 410.09576416015625, 300.0,
              382.5, 300.0),
          CubicToCommand(354.90423583984375, 300.0, 332.5, 277.59576416015625,
              332.5, 250.0),
          CubicToCommand(332.5, 222.4042510986328, 354.90423583984375, 200.0,
              382.5, 200.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(417.5, 200.0),
          CubicToCommand(445.09576416015625, 200.0, 467.5, 222.4042510986328,
              467.5, 250.0),
          CubicToCommand(467.5, 277.59576416015625, 445.09576416015625, 300.0,
              417.5, 300.0),
          CubicToCommand(389.90423583984375, 300.0, 367.5, 277.59576416015625,
              367.5, 250.0),
          CubicToCommand(367.5, 222.4042510986328, 389.90423583984375, 200.0,
              417.5, 200.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(582.5, 200.0),
          CubicToCommand(
              610.0957641601562, 200.0, 632.5, 222.4042510986328, 632.5, 250.0),
          CubicToCommand(632.5, 277.59576416015625, 610.0957641601562, 300.0,
              582.5, 300.0),
          CubicToCommand(554.9042358398438, 300.0, 532.5, 277.59576416015625,
              532.5, 250.0),
          CubicToCommand(
              532.5, 222.4042510986328, 554.9042358398438, 200.0, 582.5, 200.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(617.5, 200.0),
          CubicToCommand(
              645.0957641601562, 200.0, 667.5, 222.4042510986328, 667.5, 250.0),
          CubicToCommand(667.5, 277.59576416015625, 645.0957641601562, 300.0,
              617.5, 300.0),
          CubicToCommand(589.9042358398438, 300.0, 567.5, 277.59576416015625,
              567.5, 250.0),
          CubicToCommand(
              567.5, 222.4042510986328, 589.9042358398438, 200.0, 617.5, 200.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(817.5, 200.0),
          CubicToCommand(
              845.0957641601562, 200.0, 867.5, 222.4042510986328, 867.5, 250.0),
          CubicToCommand(867.5, 277.59576416015625, 845.0957641601562, 300.0,
              817.5, 300.0),
          CubicToCommand(789.9042358398438, 300.0, 767.5, 277.59576416015625,
              767.5, 250.0),
          CubicToCommand(
              767.5, 222.4042510986328, 789.9042358398438, 200.0, 817.5, 200.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(782.5, 200.0),
          CubicToCommand(
              810.0957641601562, 200.0, 832.5, 222.4042510986328, 832.5, 250.0),
          CubicToCommand(832.5, 277.59576416015625, 810.0957641601562, 300.0,
              782.5, 300.0),
          CubicToCommand(754.9042358398438, 300.0, 732.5, 277.59576416015625,
              732.5, 250.0),
          CubicToCommand(
              732.5, 222.4042510986328, 754.9042358398438, 200.0, 782.5, 200.0),
          CloseCommand()
        ],
      ),
      Path(
        fillType: PathFillType.evenOdd,
        commands: const <PathCommand>[
          MoveToCommand(982.5, 200.0),
          CubicToCommand(1010.0957641601562, 200.0, 1032.5, 222.4042510986328,
              1032.5, 250.0),
          CubicToCommand(1032.5, 277.59576416015625, 1010.0957641601562, 300.0,
              982.5, 300.0),
          CubicToCommand(954.9042358398438, 300.0, 932.5, 277.59576416015625,
              932.5, 250.0),
          CubicToCommand(
              932.5, 222.4042510986328, 954.9042358398438, 200.0, 982.5, 200.0),
          CloseCommand()
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(1017.5, 200.0),
          CubicToCommand(
              1045.0957512247, 200.0, 1067.5, 222.4042487753, 1067.5, 250.0),
          CubicToCommand(
              1067.5, 277.5957512247, 1045.0957512247, 300.0, 1017.5, 300.0),
          CubicToCommand(
              989.9042487753, 300.0, 967.5, 277.5957512247, 967.5, 250.0),
          CubicToCommand(
              967.5, 222.4042487753, 989.9042487753, 200.0, 1017.5, 200.0),
          CloseCommand()
        ],
      )
    ]);
  });
}
