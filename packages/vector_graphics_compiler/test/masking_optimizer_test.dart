// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:core';
import 'package:test/test.dart';
import 'package:vector_graphics_compiler/src/svg/node.dart';
import 'package:vector_graphics_compiler/src/svg/masking_optimizer.dart';
import 'package:vector_graphics_compiler/src/svg/resolver.dart';
import 'package:vector_graphics_compiler/src/svg/parser.dart';
import 'package:vector_graphics_compiler/src/geometry/matrix.dart';

Future<Node> parseAndResolve(String source) async {
  final Node node = await parseToNodeTree(source);
  final ResolvingVisitor visitor = ResolvingVisitor();
  return node.accept(visitor, AffineMatrix.identity);
}

List<T> queryChildren<T extends Node>(Node node) {
  final List<T> children = <T>[];
  void visitor(Node child) {
    if (child is T) {
      children.add(child);
    }
    child.visitChildren(visitor);
  }

  node.visitChildren(visitor);
  return children;
}

const String xmlString =
    '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 41 40.93"><defs><mask id="a" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="b" x="8.03" y="11.41" width="24.93" height="20.38" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="c" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="d" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="e" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="g" x="6.9" y="10.28" width="28.35" height="19.23" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><mask id="h" x="8.03" y="11.41" width="24.93" height="18.1" maskUnits="userSpaceOnUse"><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="#fff"/></mask><radialGradient id="i" cx="-133.17" cy="442.69" r="1" gradientTransform="matrix(29.44 0 0 -21.38 3929.33 9474.46)" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#fff" stop-opacity=".1"/><stop offset="1" stop-color="#fff" stop-opacity=".01"/></radialGradient><linearGradient id="f" x1="17.79" y1="71.96" x2="25.86" y2="54.08" gradientTransform="matrix(1 0 0 -1 0 79.12)" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#262626" stop-opacity=".2"/><stop offset="1" stop-color="#262626" stop-opacity=".02"/></linearGradient></defs><g data-name="Layer 2"><g data-name="Layer 1"><path d="M20.5 40.43a20 20 0 10-20-20 20 20 0 0020 20z" fill="#fafafa" stroke="#e8eaed"/><g mask="url(#a)"><path fill="#e1e1e1" d="M10.86 15.52h19.26v14H10.86z"/></g><g mask="url(#b)"><path style="isolation:isolate" fill="none" opacity=".2" d="M9.73 14.38H32.4v17.41H9.73z"/><path d="M20.5 22.52l-9.64 7h19.27v-14z" fill="#eee"/></g><g mask="url(#a)"><path d="M20.5 22.52l-9.64 7h.2l9.44-6.85 9.63-7v-.14z" fill-opacity=".4" fill="#fff"/></g><g mask="url(#c)"><path fill="#d23f31" d="M8.03 13.11h2.83v16.4H8.03z"/></g><g mask="url(#d)"><path fill="#c53929" d="M30.13 13.11h2.83v16.4h-2.83z"/></g><g mask="url(#e)"><path d="M8.53 14.31l15.23 15.21H33V13.11z" fill="url(#f)"/></g><g mask="url(#g)"><path style="isolation:isolate" fill="none" opacity=".2" d="M6.9 10.28h28.35V24.8H6.9z"/><path d="M31.26 11.41L20.5 18.77 9.73 11.41H8v1.7a1.68 1.68 0 00.74 1.4l11.73 8 11.72-8a1.68 1.68 0 00.74-1.4v-1.7z" fill="#db4437"/></g><g mask="url(#h)"><path d="M31.26 11.41l-.2.15h.2A1.7 1.7 0 0133 13.25v-.14a1.7 1.7 0 00-1.74-1.7z" fill-opacity=".2" fill="#fff"/></g><g mask="url(#a)"><path d="M9.73 11.41l.21.15h-.21A1.7 1.7 0 008 13.25v-.14a1.71 1.71 0 011.73-1.7z" fill-opacity=".2" fill="#fff"/></g><g mask="url(#d)"><path d="M32.22 14.37l-11.72 8-11.73-8A1.68 1.68 0 018 13v.14a1.68 1.68 0 00.74 1.4l11.73 8 11.72-8a1.68 1.68 0 00.74-1.4V13a1.68 1.68 0 01-.71 1.37z" fill="#3e2723" fill-opacity=".25"/></g><g mask="url(#a)"><path d="M9.73 11.41l10.77 7.36 10.76-7.36z" fill="#f1f1f1"/></g><g mask="url(#a)"><path d="M9.73 11.41l.21.49h21.12l.2-.49z" fill="#262626" fill-opacity=".02"/></g><path d="M31.26 11.41H9.73A1.71 1.71 0 008 13.11v14.71a1.7 1.7 0 001.7 1.69h21.56A1.7 1.7 0 0033 27.82V13.11a1.7 1.7 0 00-1.74-1.7z" fill="url(#i)"/></g></g></svg>''';

void main() {
  test('Only resolve MaskNode if the mask is described by a singular PathNode',
      () async {
    final Node node = await parseAndResolve(
        ''' <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
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

  test("Don't resolve MaskNode if the mask is described by multiple PathNodes",
      () async {
    final Node node = await parseAndResolve('''<svg viewBox="-10 -10 120 120">
      <mask id="myMask">
        <rect x="0" y="0" width="100" height="100" fill="white" />
        <path d="M10,35 A20,20,0,0,1,50,35 A20,20,0,0,1,90,35 Q90,65,50,95 Q10,65,10,35 Z" fill="black" />
      </mask>

      <circle cx="50" cy="50" r="50" mask="url(#myMask)" />
      </svg>''');
    final MaskingOptimizer visitor = MaskingOptimizer();
    final Node newNode = visitor.apply(node);

    final List<ResolvedMaskNode> maskNodesNew =
        queryChildren<ResolvedMaskNode>(newNode);

    expect(maskNodesNew.length, 1);
  });

  test(
      "Don't resolve a MaskNode if one of PathNodes it's applied to has stroke.width set",
      () async {
    final Node node = await parseAndResolve(
        ''' <svg xmlns="http://www.w3.org/2000/svg" width="94" height="92" viewBox="0 0 94 92" fill="none">
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

  test("Don't resolve MaskNode if intersection of Mask and Path is empty",
      () async {
    final Node node = await parseAndResolve(
        '''<svg width="24px" height="24px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <mask id="a">
        <path  d="M58.645 16.232L46.953 28.72l2.024 1.895 11.691-12.486"/>
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
  test('ParentNode and PathNode count should stay the same', () async {
    final Node node = await parseAndResolve(xmlString);

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
}
