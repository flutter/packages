import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/src/render_picture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Picture createPicture(Color color) {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawPaint(Paint()..color = color);
    return recorder.endRecording();
  }

  test('RenderPicture.picture setter avoids unnecessary painting', () {
    final Picture picture = createPicture(const Color(0xFFABCDEF));
    final Picture picture2 = createPicture(const Color(0xFF123456));

    // A and B are render compatible. C is not.
    final PictureInfo pictureInfoA = PictureInfo(
      picture: picture,
      viewport: Rect.zero,
      compatibilityTester: const CacheCompatibilityTester(),
    );

    final PictureInfo pictureInfoB = PictureInfo(
      picture: picture,
      viewport: Rect.zero,
      compatibilityTester: const CacheCompatibilityTester(),
    );

    final PictureInfo pictureInfoC = PictureInfo(
      picture: picture2,
      viewport: Rect.zero,
      compatibilityTester: const CacheCompatibilityTester(),
    );

    expect(pictureInfoA == pictureInfoB, false);
    expect(pictureInfoA == pictureInfoC, false);
    expect(picture == picture2, false);

    final RenderPicture renderPicture = RenderPicture(picture: pictureInfoA);

    expect(renderPicture.debugNeedsPaint, true);
    renderPicture.layout(const BoxConstraints());
    PaintingContext(ContainerLayer(), Rect.largest).paintChild(
      renderPicture,
      Offset.zero,
    );
    expect(renderPicture.debugNeedsPaint, false);

    renderPicture.picture = pictureInfoB;
    expect(renderPicture.debugNeedsPaint, false);

    renderPicture.picture = pictureInfoC;
    expect(renderPicture.debugNeedsPaint, true);
  });
}
