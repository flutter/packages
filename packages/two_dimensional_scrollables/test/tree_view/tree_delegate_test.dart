// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

const TreeRow span = TreeRow(extent: FixedTreeRowExtent(50));

void main() {
  test('TreeVicinity converts ChildVicinity', () {
    const TreeVicinity vicinity = TreeVicinity(depth: 5, row: 10);
    expect(vicinity.xIndex, 5);
    expect(vicinity.yIndex, 10);
    expect(vicinity.row, 10);
    expect(vicinity.depth, 5);
    expect(vicinity.toString(), '(row: 10, depth: 5)');
  });

  group('TreeRowBuilderDelegate', () {
    test('exposes addAutomaticKeepAlives from super class', () {
      final TreeRowBuilderDelegate delegate = TreeRowBuilderDelegate(
        nodeBuilder: (_, __) => const SizedBox(),
        rowBuilder: (_) => span,
        rowCount: 6,
        addAutomaticKeepAlives: false,
      );
      expect(delegate.addAutomaticKeepAlives, isFalse);
    });

    test('asserts  valid counts for rows', () {
      TreeRowBuilderDelegate? delegate;
      expect(
        () {
          delegate = TreeRowBuilderDelegate(
            nodeBuilder: (_, __) => const SizedBox(),
            rowBuilder: (_) => span,
            rowCount: -1, // asserts
          );
        },
        throwsA(
          isA<AssertionError>().having(
            (AssertionError error) => error.toString(),
            'description',
            contains('rowCount >= 0'),
          ),
        ),
      );

      expect(delegate, isNull);
    });

    test('sets max y index (not x) of super class', () {
      final TreeRowBuilderDelegate delegate = TreeRowBuilderDelegate(
        nodeBuilder: (_, __) => const SizedBox(),
        rowBuilder: (_) => span,
        rowCount: 6,
      );
      expect(delegate.maxYIndex, 5); // rows
      expect(delegate.maxXIndex, isNull); // unknown max depth
    });

    test('Notifies listeners & rebuilds', () {
      bool notified = false;
      TreeRowBuilderDelegate oldDelegate;

      final TreeRowBuilderDelegate delegate = TreeRowBuilderDelegate(
        nodeBuilder: (_, __) => const SizedBox(),
        rowBuilder: (_) => span,
        rowCount: 6,
      );
      delegate.addListener(() {
        notified = true;
      });

      // change row count
      oldDelegate = delegate;
      delegate.rowCount = 7;
      expect(notified, isTrue);
      expect(delegate.shouldRebuild(oldDelegate), isTrue);

      // Builder delegate always returns true.
      expect(delegate.shouldRebuild(delegate), isTrue);
    });
  });
}
