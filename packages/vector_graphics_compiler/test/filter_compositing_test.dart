// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

const String defs = '<defs><filter id="f"><feFlood/></filter></defs>';
void main() {
  for (final kind in <String>['path', 'group', 'text', 'use', 'root']) {
    for (final opacity in <double>[0, .5, 1]) {
      test('$kind opacity $opacity surrounds exactly one filter', () {
        final String shape = switch (kind) {
          'path' => '<rect width="32" height="32" opacity="$opacity" filter="url(#f)"/>',
          'group' => '<g opacity="$opacity" filter="url(#f)"><rect width="32" height="32"/></g>',
          'text' => '<text x="4" y="24" opacity="$opacity" filter="url(#f)">Hello</text>',
          'use' =>
            '<defs><rect id="r" width="32" height="32"/></defs><use href="#r" opacity="$opacity" filter="url(#f)"/>',
          _ => '<rect width="32" height="32"/>',
        };
        final VectorInstructions result = parseWithoutOptimizers(
          '<svg width="64" height="64" ${kind == 'root' ? 'opacity="$opacity" filter="url(#f)"' : ''}>$defs$shape</svg>',
        );
        final List<DrawCommandType> types = result.commands.map((DrawCommand c) => c.type).toList();
        expect(types.where((DrawCommandType t) => t == DrawCommandType.beginFilter), hasLength(1));
        expect(types.where((DrawCommandType t) => t == DrawCommandType.endFilter), hasLength(1));
        if (opacity != 1) {
          expect(types.first, DrawCommandType.saveLayer);
          expect(types[1], DrawCommandType.beginFilter);
          expect(types[types.length - 2], DrawCommandType.endFilter);
          expect(types.last, DrawCommandType.restore);
          expect(
            result.paints[result.commands.first.paintId!].fill!.color.a,
            closeTo(opacity * 255, 1),
          );
        } else {
          expect(types.first, DrawCommandType.beginFilter);
          expect(types.last, DrawCommandType.endFilter);
        }
      });
    }
  }
  test('nested reuse of one mask preserves both masks', () {
    final VectorInstructions result = parseWithoutOptimizers(
      '<svg width="64" height="64"><defs><mask id="m"><rect width="64" height="64" fill="white"/></mask></defs><g mask="url(#m)"><g mask="url(#m)"><rect width="32" height="32"/></g></g></svg>',
    );
    expect(result.commands.where((DrawCommand c) => c.type == DrawCommandType.mask), hasLength(2));
  });
  test('recursive mask definition still terminates', () {
    final VectorInstructions result = parseWithoutOptimizers(
      '<svg width="64" height="64"><defs><mask id="m"><g mask="url(#m)"><rect width="64" height="64" fill="white"/></g></mask></defs><rect width="32" height="32" mask="url(#m)"/></svg>',
    );
    expect(result.commands.length, lessThan(16));
  });
}
