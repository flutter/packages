import 'dart:ui';

Rect parseViewBox(String viewbox) {
  if (viewbox == null || viewbox == '') {
    return Rect.zero;
  }

  final parts = viewbox.split(' ');
  return new Rect.fromLTWH(double.parse(parts[0]), double.parse(parts[1]),
      double.parse(parts[2]), double.parse(parts[3]));
}

Color parseColor(String colorString) {
  if (colorString[0] == '#') {
    if (colorString.length == 4) {
      final r = colorString[1];
      final g = colorString[2];
      final b = colorString[3];
      colorString = '#$r$r$g$g$b$b';
    }
    int color = int.parse(colorString.substring(1),
        radix: 16, onError: (source) => null);

    if (colorString.length == 7) {
      return new Color(color |= 0x00000000ff000000);
    }

    if (colorString.length == 9) {
      return new Color(color);
    }
  }

  throw new ArgumentError.value(
      colorString, "colorString", "Unknown color $colorString");
}
