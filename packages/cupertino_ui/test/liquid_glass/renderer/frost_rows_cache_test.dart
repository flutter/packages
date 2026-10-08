import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/rendering/liquid_glass_render_object.dart';

// The frost blurs into the odd pass-relative pixel rows of a glass and leaves
// the even ones sharp for the shader. The rows used to be rebuilt on every
// frame the glass moved on screen (a scroll, a sheet sliding in); now they are
// built once per size and scale and shifted by the glass's row phase. These
// check that the shifted rows are still exactly the odd rows, and that moving
// doesn't rebuild them.

const _bounds = Rect.fromLTWH(0, 0, 120, 44);
const _pass = Rect.fromLTWH(0, 0, 1290, 2796);

Matrix4 _at(double dx, double dy, [double scale = 1]) =>
    Matrix4.translationValues(dx, dy, 0)..scaleByDouble(scale, scale, 1, 1);

/// Checks every physical row the glass covers: odd rows are in the path
/// (sampled at their centre), even rows are not.
void _expectOddRows(Path rows, Matrix4 transform, double dpr) {
  final inverse = Matrix4.inverted(transform);
  final screen = MatrixUtils.transformRect(transform, _bounds);
  final first = (screen.top * dpr).ceil();
  final last = (screen.bottom * dpr).floor() - 1;
  expect(last, greaterThan(first));
  for (var row = first; row <= last; row++) {
    final centre = MatrixUtils.transformPoint(
      inverse,
      Offset(screen.center.dx, (row + 0.5) / dpr),
    );
    expect(rows.contains(centre), row.isOdd,
        reason: 'row $row at ${transform.getTranslation()}');
  }
}

void main() {
  test('odd rows only, wherever the glass sits', () {
    for (final dpr in [2.0, 3.0]) {
      final cache = FrostRows();
      for (final dy in [0.0, 0.25, 1 / 3, 0.5, 1.0, 13.7, 100.0, 333.33]) {
        final transform = _at(16, dy);
        final rows = cache.rows(
          transform: transform,
          bounds: _bounds,
          passPhysical: _pass,
          dpr: dpr,
        )!;
        _expectOddRows(rows, transform, dpr);
      }
    }
  });

  test('a pass that starts lower counts its rows from its own top', () {
    final cache = FrostRows();
    const pass = Rect.fromLTWH(0, 7, 1290, 400);
    final transform = _at(0, 20);
    final rows = cache.rows(
      transform: transform,
      bounds: _bounds,
      passPhysical: pass,
      dpr: 3,
    )!;
    final inverse = Matrix4.inverted(transform);
    for (var row = 0; row < 120; row++) {
      final y = (pass.top + row + 0.5) / 3;
      if (y < 20 || y > 64) continue;
      final centre = MatrixUtils.transformPoint(inverse, Offset(60, y));
      expect(rows.contains(centre), row.isOdd, reason: 'pass row $row');
    }
  });

  test('moving shifts the rows, resizing or scaling rebuilds them', () {
    final cache = FrostRows();
    Path? rows(Matrix4 transform, [Rect bounds = _bounds]) => cache.rows(
          transform: transform,
          bounds: bounds,
          passPhysical: _pass,
          dpr: 3,
        );
    rows(_at(0, 0));
    expect(cache.builds, 1);
    // A scroll: sixty frames at fractional offsets.
    for (var frame = 0; frame < 60; frame++) {
      rows(_at(0, 400 - frame * 6.37));
    }
    expect(cache.builds, 1);
    // The same phase hands back the same path, so the clip layer is untouched.
    final a = rows(_at(0, 10));
    final b = rows(_at(0, 10 + 2 / 3));
    expect(identical(a, b), isTrue, reason: '2 physical px at 3x');

    rows(_at(0, 0), const Rect.fromLTWH(0, 0, 120, 60));
    expect(cache.builds, 2);
    rows(_at(0, 0, 1.04), const Rect.fromLTWH(0, 0, 120, 60));
    expect(cache.builds, 3);
  });

  test('no rows under a rotation or a flip', () {
    final cache = FrostRows();
    expect(
      cache.rows(
        transform: Matrix4.rotationZ(0.1),
        bounds: _bounds,
        passPhysical: _pass,
        dpr: 3,
      ),
      isNull,
    );
    expect(
      cache.rows(
        transform: Matrix4.diagonal3Values(1, -1, 1),
        bounds: _bounds,
        passPhysical: _pass,
        dpr: 3,
      ),
      isNull,
    );
  });
}
