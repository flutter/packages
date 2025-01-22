// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:core';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/src/svg/masking_optimizer.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'helpers.dart';
import 'test_svg_strings.dart';

Node parseAndResolve(String source) {
  final Node node = parseToNodeTree(source);
  final ResolvingVisitor visitor = ResolvingVisitor();
  return node.accept(visitor, AffineMatrix.identity);
}

const String xmlString =
    '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 41 40.93"><defs><mask id="a" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="b" x="8.03" y="11.41" width="24.93" height="20.38" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="c" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="d" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="e" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="g" x="6.9" y="10.28" width="28.35" height="19.23" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="h" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><radialGradient id="i" cx="-133.17" cy="442.69" r="1" gradientTransform="matrix(29.44 0 0 -21.38 3929.33 9474.46)" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#fff" stop-opacity=".1"/><stop offset="1" stop-color="#fff" stop-opacity=".01"/></radialGradient><linearGradient id="f" x1="17.79" y1="71.96" x2="25.86" y2="54.08" gradientTransform="matrix(1 0 0 -1 0 79.12)" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#262626" stop-opacity=".2"/><stop offset="1" stop-color="#262626" stop-opacity=".02"/></linearGradient></defs><g data-name="Layer 2"><g data-name="Layer 1"><path d="M20.5 40.43a20 20 0 10-20-20 20 20 0 0020 20z" fill="#fafafa" stroke="#e8eaed"/><g mask="url(#a)"><path fill="#e1e1e1" d="M10.86 15.52h19.26v14H10.86z"/></g><g mask="url(#b)"><path style="isolation:isolate" fill="none" opacity=".2" d="M9.73 14.38H32.4v17.41H9.73z"/><path d="M20.5 22.52l-9.64 7h19.27v-14z" fill="#eee"/></g><g mask="url(#a)"><path d="M20.5 22.52l-9.64 7h.2l9.44-6.85 9.63-7v-.14z" fill-opacity=".4" fill="#fff"/></g><g mask="url(#c)"><path fill="#d23f31" d="M8.03 13.11h2.83v16.4H8.03z"/></g><g mask="url(#d)"><path fill="#c53929" d="M30.13 13.11h2.83v16.4h-2.83z"/></g><g mask="url(#e)"><path d="M8.53 14.31l15.23 15.21H33V13.11z" fill="url(#f)"/></g><g mask="url(#g)"><path style="isolation:isolate" fill="none" opacity=".2" d="M6.9 10.28h28.35V24.8H6.9z"/><path d="M31.26 11.41L20.5 18.77 9.73 11.41H8v1.7a1.68 1.68 0 00.74 1.4l11.73 8 11.72-8a1.68 1.68 0 00.74-1.4v-1.7z" fill="#db4437"/></g><g mask="url(#h)"><path d="M31.26 11.41l-.2.15h.2A1.7 1.7 0 0133 13.25v-.14a1.7 1.7 0 00-1.74-1.7z" fill-opacity=".2" fill="#fff"/></g><g mask="url(#a)"><path d="M9.73 11.41l.21.15h-.21A1.7 1.7 0 008 13.25v-.14a1.71 1.71 0 011.73-1.7z" fill-opacity=".2" fill="#fff"/></g><g mask="url(#d)"><path d="M32.22 14.37l-11.72 8-11.73-8A1.68 1.68 0 018 13v.14a1.68 1.68 0 00.74 1.4l11.73 8 11.72-8a1.68 1.68 0 00.74-1.4V13a1.68 1.68 0 01-.71 1.37z" fill="#3e2723" fill-opacity=".25"/></g><g mask="url(#a)"><path d="M9.73 11.41l10.77 7.36 10.76-7.36z" fill="#f1f1f1"/></g><g mask="url(#a)"><path d="M9.73 11.41l.21.49h21.12l.2-.49z" fill="#262626" fill-opacity=".02"/></g><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="url(#i)"/></g></g></svg>''';

void main() {
  setUpAll(() {
    if (!initializePathOpsFromFlutterCache()) {
      fail('error in setup');
    }
  });

  test('Only remove MaskNode if the mask is described by a singular PathNode',
      () {
    final Node node = parseAndResolve('''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <mask id="a" maskUnits="userSpaceOnUse" x="3" y="7" width="18" height="11">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M15.094 17.092a.882.882 0 01-.623-1.503l2.656-2.66H4.28a.883.883 0 010-1.765h12.846L14.47 8.503a.88.88 0 011.245-1.245l4.611 4.611a.252.252 0 010 .354l-4.611 4.611a.876.876 0 01-.622.258z" fill="#fff" />
  </mask>
  <g mask="url(#a)">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M0 0h24v24.375H0V0z" fill="#fff" />
  </g>
</svg>''');

    final MaskingOptimizer visitor = MaskingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedMaskNode> maskNodesNew =
        queryChildren<ResolvedMaskNode>(newNode);

    expect(maskNodesNew.length, 0);
  });

  test("Don't remove MaskNode if the mask is described by multiple PathNodes",
      () {
    final Node node = parseAndResolve('''
<svg viewBox="-10 -10 120 120">
  <mask id="myMask">
    <rect x="0" y="0" width="100" height="100" fill="white" />
      <path d="M10,35 A20,20,0,0,1,50,35 A20,20,0,0,1,90,35 Q90,65,50,95 Q10,65,10,35 Z" fill="black" />
    </mask>

    <circle cx="50" cy="50" r="50" mask="url(#myMask)" />
</svg>
''');
    final MaskingOptimizer visitor = MaskingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedMaskNode> maskNodesNew =
        queryChildren<ResolvedMaskNode>(newNode);

    expect(maskNodesNew.length, 1);
  });

  test(
      "Don't resolve a MaskNode if one of PathNodes it's applied to has stroke.width set",
      () {
    final Node node = parseAndResolve('''
<svg xmlns="http://www.w3.org/2000/svg" width="94" height="92" viewBox="0 0 94 92" fill="none">
  <mask id="c" maskUnits="userSpaceOnUse" x="46" y="16" width="15" height="15">
    <path d="M58.645 16.232L46.953 28.72l2.024 1.895 11.691-12.486" fill="#fff"/>
  </mask>
  <g mask="url(#c)">
    <path d="M51.797 28.046l-2.755-2.578" stroke="#FDDA73" stroke-width="2"/>
  </g>
</svg>
''');

    final MaskingOptimizer visitor = MaskingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedMaskNode> maskNodesNew =
        queryChildren<ResolvedMaskNode>(newNode);

    expect(maskNodesNew.length, 1);
  });

  test("Don't remove MaskNode if intersection of Mask and Path is empty", () {
    final Node node = parseAndResolve('''
<svg width="24px" height="24px" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <mask id="a">
    <path d="M58.645 16.232L46.953 28.72l2.024 1.895 11.691-12.486"/>
  </mask>
  <path mask="url(#a)" d="M0 0 z"/>
</svg>
''');
    final MaskingOptimizer visitor = MaskingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedMaskNode> maskNodesNew =
        queryChildren<ResolvedMaskNode>(newNode);
    expect(maskNodesNew.length, 1);
  });
  test('ParentNode and PathNode count should stay the same', () {
    final Node node = parseAndResolve(xmlString);

    final List<ResolvedPathNode> pathNodesOld =
        queryChildren<ResolvedPathNode>(node);
    final List<ParentNode> parentNodesOld = queryChildren<ParentNode>(node);

    final MaskingOptimizer visitor = MaskingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedPathNode> pathNodesNew =
        queryChildren<ResolvedPathNode>(newNode);
    final List<ParentNode> parentNodesNew = queryChildren<ParentNode>(newNode);

    expect(pathNodesOld.length, pathNodesNew.length);
    expect(parentNodesOld.length, parentNodesNew.length);
  });

  test('Masks on groups', () {
    final VectorInstructions instructions =
        parse(groupMask, enableMaskingOptimizer: false);
    expect(instructions.paths, <Path>[
      parseSvgPathData(
              'M 17.438 8.438 C 17.748 8.438 18 8.69 18 9 L 18 16.313 C 17.99834725871 17.24440923535 17.24341005121 17.99889920517 16.312 18 L 1.688 18 C 0.75620021668 17.99889792932 0.00110207068 17.24379978332 0 16.312 L 0 9 C 0.01271270943 8.69855860173 0.26079065383 8.46072235233 0.5625 8.46072235233 C 0.86420934617 8.46072235233 1.11228729057 8.69855860173 1.125 9 L 1.125 16.313 C 1.125 16.622 1.377 16.875 1.688 16.875 L 16.312 16.875 C 16.622 16.875 16.875 16.622 16.875 16.312 L 16.875 9 C 16.875 8.69 17.127 8.437 17.438 8.437 Z M 9 0 C 9.169 0 9.316 0.079 9.418 0.196 L 9.423 0.192 L 13.361 4.692 C 13.443 4.795 13.5 4.921 13.5 5.062 C 13.5 5.373 13.248 5.625 12.937 5.625 C 12.77572417052 5.6238681172 12.62300981305 5.55226042805 12.519 5.429 L 12.514 5.433 L 9.563 2.06 L 9.563 11.812 C 9.56299999183 12.12293630838 9.31093630838 12.3749999852 9 12.3749999852 C 8.68906369162 12.3749999852 8.43700000817 12.12293630838 8.437 11.812 L 8.437 2.06 L 5.486 5.433 C 5.37775998399 5.5529360201 5.22453705399 5.62248401669 5.063 5.625 C 4.75206368585 5.625 4.5 5.37293631415 4.5 5.062 C 4.5 4.921 4.557 4.795 4.644 4.696 L 4.639 4.692 L 8.577 0.192 C 8.68524001601 0.0720639799 8.83846294601 0.00251598331 9 0 Z',
              PathFillType.evenOdd)
          .transformed(const AffineMatrix(0.00000000000000006123233995736766, 1,
              -1, 0.00000000000000006123233995736766, 21, 3)),
      parseSvgPathData(
              'M -3 -3 L 21 -3 L 21 21 L -3 21 Z', PathFillType.evenOdd)
          .transformed(const AffineMatrix(1, 0, 0, 1, 3, 3)),
      parseSvgPathData(
              'M 17.438 8.438 C 17.748 8.438 18 8.69 18 9 L 18 16.313 C 17.99834725871 17.24440923535 17.24341005121 17.99889920517 16.312 18 L 1.688 18 C 0.75620021668 17.99889792932 0.00110207068 17.24379978332 0 16.312 L 0 9 C 0.01271270943 8.69855860173 0.26079065383 8.46072235233 0.5625 8.46072235233 C 0.86420934617 8.46072235233 1.11228729057 8.69855860173 1.125 9 L 1.125 16.313 C 1.125 16.622 1.377 16.875 1.688 16.875 L 16.312 16.875 C 16.622 16.875 16.875 16.622 16.875 16.312 L 16.875 9 C 16.875 8.69 17.127 8.437 17.438 8.437 Z M 9 0 C 9.169 0 9.316 0.079 9.418 0.196 L 9.423 0.192 L 13.361 4.692 C 13.443 4.795 13.5 4.921 13.5 5.062 C 13.5 5.373 13.248 5.625 12.937 5.625 C 12.77572417052 5.6238681172 12.62300981305 5.55226042805 12.519 5.429 L 12.514 5.433 L 9.563 2.06 L 9.563 11.812 C 9.56299999183 12.12293630838 9.31093630838 12.3749999852 9 12.3749999852 C 8.68906369162 12.3749999852 8.43700000817 12.12293630838 8.437 11.812 L 8.437 2.06 L 5.486 5.433 C 5.37775998399 5.5529360201 5.22453705399 5.62248401669 5.063 5.625 C 4.75206368585 5.625 4.5 5.37293631415 4.5 5.062 C 4.5 4.921 4.557 4.795 4.644 4.696 L 4.639 4.692 L 8.577 0.192 C 8.68524001601 0.0720639799 8.83846294601 0.00251598331 9 0 Z',
              PathFillType.evenOdd)
          .transformed(const AffineMatrix(1, 0, 0, 1, 3, 3)),
    ]);

    final VectorInstructions instructionsWithOptimizer = parse(groupMask);
    expect(instructionsWithOptimizer.paths, groupMaskForMaskingOptimizer);

    expect(instructions.paints, const <Paint>[
      Paint(fill: Fill(color: Color(0xff727272))),
      Paint(fill: Fill()),
      Paint(fill: Fill(color: Color(0xff8e93a1))),
      Paint(fill: Fill(color: Color(0xffffffff)))
    ]);

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.saveLayer, paintId: 1),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 2),
      DrawCommand(DrawCommandType.mask),
      DrawCommand(DrawCommandType.path, objectId: 2, paintId: 3),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.restore)
    ]);
  });

  test('Handles masks with blends and gradients correctly', () {
    final VectorInstructions instructions = parse(
      blendAndMask,
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    expect(
      instructions.paths,
      <Path>[
        PathBuilder().addOval(const Rect.fromCircle(50, 50, 50)).toPath(),
        PathBuilder().addOval(const Rect.fromCircle(50, 50, 40)).toPath(),
      ],
    );

    final VectorInstructions instructionsWithOptimizer = parse(blendAndMask);
    expect(instructionsWithOptimizer.paths, blendsAndMasksForMaskingOptimizer);

    const LinearGradient gradient1 = LinearGradient(
      id: 'url(#linearGradient-3)',
      from: Point(46.9782516, 60.9121966),
      to: Point(60.42279469999999, 90.6839734),
      colors: <Color>[Color(0xffffffff), Color(0xff0000ff)],
      offsets: <double>[0.0, 1.0],
      tileMode: TileMode.clamp,
      unitMode: GradientUnitMode.transformed,
    );
    const LinearGradient gradient2 = LinearGradient(
      id: 'url(#linearGradient-3)',
      from: Point(47.58260128, 58.72975728),
      to: Point(58.338235759999996, 82.54717871999999),
      colors: <Color>[Color(0xffffffff), Color(0xff0000ff)],
      offsets: <double>[0.0, 1.0],
      tileMode: TileMode.clamp,
      unitMode: GradientUnitMode.transformed,
    );
    expect(instructions.paints, const <Paint>[
      Paint(fill: Fill(color: Color(0xffadd8e6))),
      Paint(
        blendMode: BlendMode.multiply,
        fill: Fill(),
      ),
      Paint(
        blendMode: BlendMode.multiply,
        fill: Fill(color: Color(0x98ffffff), shader: gradient1),
      ),
      Paint(fill: Fill(color: Color(0x98ffffff), shader: gradient2)),
    ]);

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 0),
      DrawCommand(DrawCommandType.saveLayer, paintId: 1),
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 2),
      DrawCommand(DrawCommandType.mask),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 3),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.restore)
    ]);
  });

  test('Does not partially apply mask to some children but not others', () {
    final VectorInstructions instructions = parse('''
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

    expect(instructions.commands, const <DrawCommand>[
      DrawCommand(DrawCommandType.saveLayer, paintId: 0),
      DrawCommand(DrawCommandType.path, objectId: 0, paintId: 1),
      DrawCommand(DrawCommandType.path, objectId: 1, paintId: 2),
      DrawCommand(DrawCommandType.mask),
      DrawCommand(DrawCommandType.path, objectId: 2, paintId: 3),
      DrawCommand(DrawCommandType.restore),
      DrawCommand(DrawCommandType.restore),
    ]);

    expect(instructions.paths, <Path>[
      Path(
        commands: const <PathCommand>[
          MoveToCommand(44.1855, 464.814),
          LineToCommand(244.564, 464.814),
          LineToCommand(244.564, 64.0564),
          LineToCommand(44.1855, 64.0564),
          LineToCommand(44.1855, 464.814),
          CloseCommand(),
          MoveToCommand(45.8428, 462.333),
          LineToCommand(242.081, 462.333),
          LineToCommand(242.081, 65.7158),
          LineToCommand(45.8428, 65.7158),
          LineToCommand(45.8428, 462.333),
          CloseCommand()
        ],
        fillType: PathFillType.evenOdd,
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(103.803, 481.375),
          LineToCommand(184.948, 481.375)
        ],
      ),
      Path(
        commands: const <PathCommand>[
          MoveToCommand(21.5625, 0.0),
          LineToCommand(267.1875, 0.0),
          CubicToCommand(279.0881677156519, 0.0, 288.75, 9.661832284348126,
              288.75, 21.5625),
          LineToCommand(288.75, 506.4375),
          CubicToCommand(288.75, 518.3381677156518, 279.0881677156519, 528.0,
              267.1875, 528.0),
          LineToCommand(21.5625, 528.0),
          CubicToCommand(
              9.661832284348126, 528.0, 0.0, 518.3381677156518, 0.0, 506.4375),
          LineToCommand(0.0, 21.5625),
          CubicToCommand(
              0.0, 9.661832284348126, 9.661832284348126, 0.0, 21.5625, 0.0),
          CloseCommand()
        ],
      ),
    ]);
  });
}
