import 'dart:ui';

const colorBlack = const Color.fromARGB(255, 0, 0, 0);

Color parseColor(String colorString) {
  if (colorString == null || colorString.length == 0) {
    return const Color.fromARGB(255, 0, 0, 0);
  }
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

  final namedColor = _namedColors[colorString];
  if (namedColor != null) {
    return namedColor;
  }

  throw new ArgumentError.value(
      colorString, "colorString", "Unknown color $colorString");
}

// https://www.w3.org/TR/SVG11/types.html#ColorKeywords
const Map<String, Color> _namedColors = const {
  'aliceblue': const Color.fromARGB(255, 240, 248, 255),
  'antiquewhite': const Color.fromARGB(255, 250, 235, 215),
  'aqua': const Color.fromARGB(255, 0, 255, 255),
  'aquamarine': const Color.fromARGB(255, 127, 255, 212),
  'azure': const Color.fromARGB(255, 240, 255, 255),
  'beige': const Color.fromARGB(255, 245, 245, 220),
  'bisque': const Color.fromARGB(255, 255, 228, 196),
  'black': const Color.fromARGB(255, 0, 0, 0),
  'blanchedalmond': const Color.fromARGB(255, 255, 235, 205),
  'blue': const Color.fromARGB(255, 0, 0, 255),
  'blueviolet': const Color.fromARGB(255, 138, 43, 226),
  'brown': const Color.fromARGB(255, 165, 42, 42),
  'burlywood': const Color.fromARGB(255, 222, 184, 135),
  'cadetblue': const Color.fromARGB(255, 95, 158, 160),
  'chartreuse': const Color.fromARGB(255, 127, 255, 0),
  'chocolate': const Color.fromARGB(255, 210, 105, 30),
  'coral': const Color.fromARGB(255, 255, 127, 80),
  'cornflowerblue': const Color.fromARGB(255, 100, 149, 237),
  'cornsilk': const Color.fromARGB(255, 255, 248, 220),
  'crimson': const Color.fromARGB(255, 220, 20, 60),
  'cyan': const Color.fromARGB(255, 0, 255, 255),
  'darkblue': const Color.fromARGB(255, 0, 0, 139),
  'darkcyan': const Color.fromARGB(255, 0, 139, 139),
  'darkgoldenrod': const Color.fromARGB(255, 184, 134, 11),
  'darkgray': const Color.fromARGB(255, 169, 169, 169),
  'darkgreen': const Color.fromARGB(255, 0, 100, 0),
  'darkgrey': const Color.fromARGB(255, 169, 169, 169),
  'darkkhaki': const Color.fromARGB(255, 189, 183, 107),
  'darkmagenta': const Color.fromARGB(255, 139, 0, 139),
  'darkolivegreen': const Color.fromARGB(255, 85, 107, 47),
  'darkorange': const Color.fromARGB(255, 255, 140, 0),
  'darkorchid': const Color.fromARGB(255, 153, 50, 204),
  'darkred': const Color.fromARGB(255, 139, 0, 0),
  'darksalmon': const Color.fromARGB(255, 233, 150, 122),
  'darkseagreen': const Color.fromARGB(255, 143, 188, 143),
  'darkslateblue': const Color.fromARGB(255, 72, 61, 139),
  'darkslategray': const Color.fromARGB(255, 47, 79, 79),
  'darkslategrey': const Color.fromARGB(255, 47, 79, 79),
  'darkturquoise': const Color.fromARGB(255, 0, 206, 209),
  'darkviolet': const Color.fromARGB(255, 148, 0, 211),
  'deeppink': const Color.fromARGB(255, 255, 20, 147),
  'deepskyblue': const Color.fromARGB(255, 0, 191, 255),
  'dimgray': const Color.fromARGB(255, 105, 105, 105),
  'dimgrey': const Color.fromARGB(255, 105, 105, 105),
  'dodgerblue': const Color.fromARGB(255, 30, 144, 255),
  'firebrick': const Color.fromARGB(255, 178, 34, 34),
  'floralwhite': const Color.fromARGB(255, 255, 250, 240),
  'forestgreen': const Color.fromARGB(255, 34, 139, 34),
  'fuchsia': const Color.fromARGB(255, 255, 0, 255),
  'gainsboro': const Color.fromARGB(255, 220, 220, 220),
  'ghostwhite': const Color.fromARGB(255, 248, 248, 255),
  'gold': const Color.fromARGB(255, 255, 215, 0),
  'goldenrod': const Color.fromARGB(255, 218, 165, 32),
  'gray': const Color.fromARGB(255, 128, 128, 128),
  'grey': const Color.fromARGB(255, 128, 128, 128),
  'green': const Color.fromARGB(255, 0, 128, 0),
  'greenyellow': const Color.fromARGB(255, 173, 255, 47),
  'honeydew': const Color.fromARGB(255, 240, 255, 240),
  'hotpink': const Color.fromARGB(255, 255, 105, 180),
  'indianred': const Color.fromARGB(255, 205, 92, 92),
  'indigo': const Color.fromARGB(255, 75, 0, 130),
  'ivory': const Color.fromARGB(255, 255, 255, 240),
  'khaki': const Color.fromARGB(255, 240, 230, 140),
  'lavender': const Color.fromARGB(255, 230, 230, 250),
  'lavenderblush': const Color.fromARGB(255, 255, 240, 245),
  'lawngreen': const Color.fromARGB(255, 124, 252, 0),
  'lemonchiffon': const Color.fromARGB(255, 255, 250, 205),
  'lightblue': const Color.fromARGB(255, 173, 216, 230),
  'lightcoral': const Color.fromARGB(255, 240, 128, 128),
  'lightcyan': const Color.fromARGB(255, 224, 255, 255),
  'lightgoldenrodyellow': const Color.fromARGB(255, 250, 250, 210),
  'lightgray': const Color.fromARGB(255, 211, 211, 211),
  'lightgreen': const Color.fromARGB(255, 144, 238, 144),
  'lightgrey': const Color.fromARGB(255, 211, 211, 211),
  'lightpink': const Color.fromARGB(255, 255, 182, 193),
  'lightsalmon': const Color.fromARGB(255, 255, 160, 122),
  'lightseagreen': const Color.fromARGB(255, 32, 178, 170),
  'lightskyblue': const Color.fromARGB(255, 135, 206, 250),
  'lightslategray': const Color.fromARGB(255, 119, 136, 153),
  'lightslategrey': const Color.fromARGB(255, 119, 136, 153),
  'lightsteelblue': const Color.fromARGB(255, 176, 196, 222),
  'lightyellow': const Color.fromARGB(255, 255, 255, 224),
  'lime': const Color.fromARGB(255, 0, 255, 0),
  'limegreen': const Color.fromARGB(255, 50, 205, 50),
  'linen': const Color.fromARGB(255, 250, 240, 230),
  'magenta': const Color.fromARGB(255, 255, 0, 255),
  'maroon': const Color.fromARGB(255, 128, 0, 0),
  'mediumaquamarine': const Color.fromARGB(255, 102, 205, 170),
  'mediumblue': const Color.fromARGB(255, 0, 0, 205),
  'mediumorchid': const Color.fromARGB(255, 186, 85, 211),
  'mediumpurple': const Color.fromARGB(255, 147, 112, 219),
  'mediumseagreen': const Color.fromARGB(255, 60, 179, 113),
  'mediumslateblue': const Color.fromARGB(255, 123, 104, 238),
  'mediumspringgreen': const Color.fromARGB(255, 0, 250, 154),
  'mediumturquoise': const Color.fromARGB(255, 72, 209, 204),
  'mediumvioletred': const Color.fromARGB(255, 199, 21, 133),
  'midnightblue': const Color.fromARGB(255, 25, 25, 112),
  'mintcream': const Color.fromARGB(255, 245, 255, 250),
  'mistyrose': const Color.fromARGB(255, 255, 228, 225),
  'moccasin': const Color.fromARGB(255, 255, 228, 181),
  'navajowhite': const Color.fromARGB(255, 255, 222, 173),
  'navy': const Color.fromARGB(255, 0, 0, 128),
  'oldlace': const Color.fromARGB(255, 253, 245, 230),
  'olive': const Color.fromARGB(255, 128, 128, 0),
  'olivedrab': const Color.fromARGB(255, 107, 142, 35),
  'orange': const Color.fromARGB(255, 255, 165, 0),
  'orangered': const Color.fromARGB(255, 255, 69, 0),
  'orchid': const Color.fromARGB(255, 218, 112, 214),
  'palegoldenrod': const Color.fromARGB(255, 238, 232, 170),
  'palegreen': const Color.fromARGB(255, 152, 251, 152),
  'paleturquoise': const Color.fromARGB(255, 175, 238, 238),
  'palevioletred': const Color.fromARGB(255, 219, 112, 147),
  'papayawhip': const Color.fromARGB(255, 255, 239, 213),
  'peachpuff': const Color.fromARGB(255, 255, 218, 185),
  'peru': const Color.fromARGB(255, 205, 133, 63),
  'pink': const Color.fromARGB(255, 255, 192, 203),
  'plum': const Color.fromARGB(255, 221, 160, 221),
  'powderblue': const Color.fromARGB(255, 176, 224, 230),
  'purple': const Color.fromARGB(255, 128, 0, 128),
  'red': const Color.fromARGB(255, 255, 0, 0),
  'rosybrown': const Color.fromARGB(255, 188, 143, 143),
  'royalblue': const Color.fromARGB(255, 65, 105, 225),
  'saddlebrown': const Color.fromARGB(255, 139, 69, 19),
  'salmon': const Color.fromARGB(255, 250, 128, 114),
  'sandybrown': const Color.fromARGB(255, 244, 164, 96),
  'seagreen': const Color.fromARGB(255, 46, 139, 87),
  'seashell': const Color.fromARGB(255, 255, 245, 238),
  'sienna': const Color.fromARGB(255, 160, 82, 45),
  'silver': const Color.fromARGB(255, 192, 192, 192),
  'skyblue': const Color.fromARGB(255, 135, 206, 235),
  'slateblue': const Color.fromARGB(255, 106, 90, 205),
  'slategray': const Color.fromARGB(255, 112, 128, 144),
  'slategrey': const Color.fromARGB(255, 112, 128, 144),
  'snow': const Color.fromARGB(255, 255, 250, 250),
  'springgreen': const Color.fromARGB(255, 0, 255, 127),
  'steelblue': const Color.fromARGB(255, 70, 130, 180),
  'tan': const Color.fromARGB(255, 210, 180, 140),
  'teal': const Color.fromARGB(255, 0, 128, 128),
  'thistle': const Color.fromARGB(255, 216, 191, 216),
  'tomato': const Color.fromARGB(255, 255, 99, 71),
  'turquoise': const Color.fromARGB(255, 64, 224, 208),
  'violet': const Color.fromARGB(255, 238, 130, 238),
  'wheat': const Color.fromARGB(255, 245, 222, 179),
  'white': const Color.fromARGB(255, 255, 255, 255),
  'whitesmoke': const Color.fromARGB(255, 245, 245, 245),
  'yellow': const Color.fromARGB(255, 255, 255, 0),
  'yellowgreen': const Color.fromARGB(255, 154, 205, 50),
};
