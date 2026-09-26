// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

class RetryState {
  bool fail = true;
  int loads = 0;
}

class RetryLoader extends BytesLoader {
  RetryLoader(this.decodeError);
  final bool decodeError;
  final RetryState state = RetryState();
  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    state.loads++;
    if (state.fail && !decodeError) {
      throw StateError('resource unavailable');
    }
    final Uint8List data = encodeSvg(
      xml: state.fail
          ? '<svg width="32" height="32"><defs><filter id="f"><feUnsupported/></filter></defs><rect width="32" height="32" filter="url(#f)"/></svg>'
          : '<svg width="32" height="32"><rect width="32" height="32" fill="red"/></svg>',
      debugName: 'retry',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    return data.buffer.asByteData();
  }
}

void main() {
  for (final decode in <bool>[false, true]) {
    for (final copies in <int>[1, 2]) {
      testWidgets(
        'failed ${decode ? 'filter decode' : 'loader'} with $copies subscribers is handled and retryable',
        (WidgetTester tester) async {
          final loader = RetryLoader(decode);
          Object? lastError;
          Widget widgets() => Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: List<Widget>.generate(
                copies,
                (int i) => VectorGraphic(
                  loader: loader,
                  width: 32,
                  height: 32,
                  errorBuilder: (BuildContext context, Object error, StackTrace stack) {
                    lastError = error;
                    return const Text('load failed');
                  },
                ),
              ),
            ),
          );
          await tester.pumpWidget(widgets());
          await tester.runAsync(() => vg.waitForPendingDecodes());
          await tester.pumpAndSettle();
          expect(find.text('load failed'), findsNWidgets(copies));
          expect(loader.state.loads, 1);
          expect(lastError.toString(), contains(decode ? 'feUnsupported' : 'resource unavailable'));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          loader.state.fail = false;
          await tester.pumpWidget(widgets());
          await tester.runAsync(() => vg.waitForPendingDecodes());
          await tester.pumpAndSettle();
          expect(loader.state.loads, 2);
          expect(find.text('load failed'), findsNothing, reason: lastError.toString());
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
