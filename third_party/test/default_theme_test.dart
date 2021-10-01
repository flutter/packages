// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/src/svg/default_theme.dart';
import 'package:flutter_svg/src/svg/theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultSvgTheme', () {
    testWidgets('changes propagate to SvgPicture', (WidgetTester tester) async {
      const SvgTheme svgTheme = SvgTheme(
        currentColor: Color(0xFF733821),
      );

      final SvgPicture svgPictureWidget = SvgPicture.string('''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="10" height="10" fill="currentColor" />
</svg>''');

      await tester.pumpWidget(DefaultSvgTheme(
        theme: svgTheme,
        child: svgPictureWidget,
      ));

      SvgPicture svgPicture = tester.firstWidget(find.byType(SvgPicture));
      expect(svgPicture, isNotNull);
      expect(
        svgPicture.pictureProvider.currentColor,
        equals(svgTheme.currentColor),
      );

      const SvgTheme anotherSvgTheme = SvgTheme(
        currentColor: Color(0xFF05290E),
      );

      await tester.pumpWidget(DefaultSvgTheme(
        theme: anotherSvgTheme,
        child: svgPictureWidget,
      ));

      svgPicture = tester.firstWidget(find.byType(SvgPicture));
      expect(svgPicture, isNotNull);
      expect(
        svgPicture.pictureProvider.currentColor,
        equals(anotherSvgTheme.currentColor),
      );
    });

    testWidgets(
        'currentColor widget property takes precedence over '
        'the theme from DefaultSvgTheme', (WidgetTester tester) async {
      const SvgTheme svgTheme = SvgTheme(
        currentColor: Color(0xFF733821),
      );

      final SvgPicture svgPictureWidget = SvgPicture.string(
        '''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="10" height="10" fill="currentColor" />
</svg>''',
        currentColor: Color(0xFF05290E),
      );

      await tester.pumpWidget(DefaultSvgTheme(
        theme: svgTheme,
        child: svgPictureWidget,
      ));

      final SvgPicture svgPicture = tester.firstWidget(find.byType(SvgPicture));
      expect(svgPicture, isNotNull);
      expect(
        svgPicture.pictureProvider.currentColor,
        equals(Color(0xFF05290E)),
      );
    });
  });
}
