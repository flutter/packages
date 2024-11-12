import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Spacing without width or height', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          child: ColumnsAndRows(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile('golden_widget/columns_and_rows.png'),
      skip: 'This golden needs updating',
    );
  }, skip: !isLinux);
}

class ColumnsAndRows extends StatelessWidget {
  const ColumnsAndRows({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        Row(children: <Widget>[
          ImageWithText(),
        ]),
        Row(
          children: <Widget>[
            ImageWithText(),
            ImageWithText(),
          ],
        ),
        Row(
          children: <Widget>[
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
          ],
        ),
        Row(
          children: <Widget>[
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
          ],
        ),
        Row(
          children: <Widget>[
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
            ImageWithText(),
          ],
        ),
      ],
    );
  }
}

class ImageWithText extends StatelessWidget {
  const ImageWithText({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget image = SvgPicture.string(circleSvg);
    final Widget imageContainer = ColoredBox(
      color: Colors.amber,
      child: image,
    );
    const Widget text = Text('Hello');
    final Widget column = Column(
      children: <Widget>[
        imageContainer,
        text,
      ],
    );
    return Expanded(
      child: column,
    );
  }
}

const String circleSvg = '''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100" version="1.1">
   <g id="layer1" transform="translate(-33.785712,-125.41666)">
      <circle id="path118" cx="83.785713" cy="175.41666" style="fill:#00a100;fill-opacity:1;stroke:#586f00;stroke-width:4.76190472;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" r="47.619049" />
   </g>
</svg>
''';
