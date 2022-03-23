import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

const VectorGraphicsCodec codec = VectorGraphicsCodec();

void main() {
  test('Can decode a message without a stroke and vertices', () {
    final buffer = VectorGraphicsBuffer();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
    final int paintId = codec.writeStroke(buffer, 44, 1, 2, 3, 4.0, 6.0);
    codec.writeDrawVertices(
        buffer,
        Float32List.fromList([
          0.0,
          2.0,
          3.0,
          4.0,
          2.0,
          4.0,
        ]),
        null,
        paintId);

    codec.decode(buffer.done(), listener);

    expect(listener.toPicture, returnsNormally);
  });

  test('Can decode a message with a fill and path', () {
    final buffer = VectorGraphicsBuffer();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
    final int paintId = codec.writeFill(buffer, 23, 0);
    final int pathId = codec.writeStartPath(buffer, 0);
    codec.writeMoveTo(buffer, 1, 2);
    codec.writeLineTo(buffer, 2, 3);
    codec.writeClose(buffer);
    codec.writeFinishPath(buffer);
    codec.writeDrawPath(buffer, pathId, paintId);

    codec.decode(buffer.done(), listener);

    expect(listener.toPicture, returnsNormally);
  });

  test('Asserts if toPicture is called more than once', () {
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
    listener.toPicture();

    expect(listener.toPicture, throwsAssertionError);
  });

  testWidgets('Creates layout widgets when VectorGraphic is sized',
      (WidgetTester tester) async {
    final buffer = VectorGraphicsBuffer();
    await tester.pumpWidget(VectorGraphic(
      bytesLoader: TestBytesLoader(buffer.done()),
      width: 100,
      height: 100,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SizedBox), findsNWidgets(2));

    final SizedBox sizedBox =
        (find.byType(SizedBox).evaluate().first.widget as SizedBox);

    expect(sizedBox.width, 100);
    expect(sizedBox.height, 100);
  });

  testWidgets('Creates alignment widgets when VectorGraphic is aligned',
      (WidgetTester tester) async {
    final buffer = VectorGraphicsBuffer();
    await tester.pumpWidget(VectorGraphic(
      bytesLoader: TestBytesLoader(buffer.done()),
      alignment: Alignment.centerLeft,
      fit: BoxFit.fitHeight,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(FittedBox), findsOneWidget);

    final FittedBox fittedBox =
        (find.byType(FittedBox).evaluate().first.widget as FittedBox);

    expect(fittedBox.fit, BoxFit.fitHeight);
    expect(fittedBox.alignment, Alignment.centerLeft);
  });

  testWidgets('Sizes VectorGraphic based on encoded viewbox information',
      (WidgetTester tester) async {
    final buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 100, 200);

    await tester.pumpWidget(VectorGraphic(
      bytesLoader: TestBytesLoader(buffer.done()),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SizedBox), findsNWidgets(2));

    final SizedBox sizedBox =
        (find.byType(SizedBox).evaluate().last.widget as SizedBox);

    expect(sizedBox.width, 100);
    expect(sizedBox.height, 200);
  });
}

class TestBytesLoader extends BytesLoader {
  TestBytesLoader(this.data);

  final ByteData data;

  @override
  Future<ByteData> loadBytes() async {
    return data;
  }
}
