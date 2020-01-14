// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animations/src/fade_transition.dart';
import 'package:animations/src/modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets(
    'FadeTransitionConfiguration builds a new route',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(builder: (BuildContext context) {
              return Center(
                child: RaisedButton(
                  onPressed: () {
                    showModal(
                      context: context,
                      configuration: FadeTransitionConfiguration(),
                      builder: (BuildContext context) {
                        return const _FlutterLogoModal();
                      },
                    );
                  },
                  child: Icon(Icons.add),
                ),
              );
            }),
          ),
        ),
      );
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();
      expect(find.byType(_FlutterLogoModal), findsOneWidget);
    },
  );

  // runs forward
  testWidgets(
    'FadeTransitionConfiguration runs forward',
    (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(builder: (BuildContext context) {
              return Center(
                child: RaisedButton(
                  onPressed: () {
                    showModal(
                      context: context,
                      configuration: FadeTransitionConfiguration(),
                      builder: (BuildContext context) {
                        return _FlutterLogoModal(key: key);
                      },
                    );
                  },
                  child: Icon(Icons.add),
                ),
              );
            }),
          ),
        ),
      );
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();
      // Opacity duration: First 30ms linear transition at the
      // start
      double topFadeTransitionOpacity = _getOpacity(key, tester);
      expect(topFadeTransitionOpacity, 0.0);

      await tester.pump(const Duration(milliseconds: 23));
      topFadeTransitionOpacity = _getOpacity(key, tester);
      expect(topFadeTransitionOpacity, closeTo(0.5, 0.05));

      await tester.pump(const Duration(milliseconds: 45));
      expect(find.byType(_FlutterLogoModal), findsOneWidget);
      topFadeTransitionOpacity = _getOpacity(key, tester);
      expect(topFadeTransitionOpacity, 1.0);
    },
  );

  // runs backwards

  // does not get interrupted when run in reverse

  // state is not lost when transitioning
}

double _getOpacity(GlobalKey key, WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byKey(key),
    matching: find.byType(FadeTransition),
  );
  return tester.widgetList(finder).fold<double>(1.0, (double a, Widget widget) {
    final FadeTransition transition = widget as FadeTransition;
    return a * transition.opacity.value;
  });
}

class _FlutterLogoModal extends StatelessWidget {
  const _FlutterLogoModal({
    Key key,
  })  : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Material(
          child: Center(
            child: FlutterLogo(size: 250),
          ),
        ),
      ),
    );
  }
}
