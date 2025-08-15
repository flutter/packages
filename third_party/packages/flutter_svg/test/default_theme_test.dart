import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultSvgTheme', () {
    testWidgets('changes propagate to SvgPicture', (WidgetTester tester) async {
      const SvgTheme svgTheme = SvgTheme(
        currentColor: Color(0xFF733821),
        xHeight: 6.0,
      );

      final SvgPicture svgPictureWidget = SvgPicture.string('''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="10em" height="10" fill="currentColor" />
</svg>''');

      await tester.pumpWidget(DefaultSvgTheme(
        theme: svgTheme,
        child: svgPictureWidget,
      ));

      SvgPicture svgPicture = tester.firstWidget(find.byType(SvgPicture));
      expect(svgPicture, isNotNull);
      BuildContext context = tester.element(find.byType(SvgPicture));
      expect(
        (svgPicture.bytesLoader as SvgStringLoader).getTheme(context),
        equals(svgTheme),
      );

      const SvgTheme anotherSvgTheme = SvgTheme(
        currentColor: Color(0xFF05290E),
        fontSize: 12.0,
        xHeight: 7.0,
      );

      await tester.pumpWidget(DefaultSvgTheme(
        theme: anotherSvgTheme,
        child: svgPictureWidget,
      ));
      context = tester.element(find.byType(SvgPicture));

      svgPicture = tester.firstWidget(find.byType(SvgPicture));
      expect(svgPicture, isNotNull);
      expect(
        (svgPicture.bytesLoader as SvgStringLoader).getTheme(context),
        equals(anotherSvgTheme),
      );
    });

    testWidgets(
        "currentColor from the widget's theme takes precedence over "
        'the theme from DefaultSvgTheme', (WidgetTester tester) async {
      const SvgTheme svgTheme = SvgTheme(
        currentColor: Color(0xFF733821),
      );

      final SvgPicture svgPictureWidget = SvgPicture.string(
        '''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="10" height="10" fill="currentColor" />
</svg>''',
        theme: const SvgTheme(
          currentColor: Color(0xFF05290E),
        ),
      );

      await tester.pumpWidget(DefaultSvgTheme(
        theme: svgTheme,
        child: svgPictureWidget,
      ));
      final BuildContext context = tester.element(find.byType(SvgPicture));
      final SvgPicture svgPicture = tester.firstWidget(find.byType(SvgPicture));
      expect(svgPicture, isNotNull);
      expect(
        (svgPicture.bytesLoader as SvgStringLoader)
            .getTheme(context)
            .currentColor,
        equals(const Color(0xFF05290E)),
      );
    });

    testWidgets(
        "fontSize from the widget's theme takes precedence over "
        'the theme from DefaultSvgTheme', (WidgetTester tester) async {
      const SvgTheme svgTheme = SvgTheme();

      final SvgPicture svgPictureWidget = SvgPicture.string(
        '''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="10em" height="10em" />
</svg>''',
        theme: const SvgTheme(
          fontSize: 12.0,
        ),
      );

      await tester.pumpWidget(DefaultSvgTheme(
        theme: svgTheme,
        child: svgPictureWidget,
      ));

      final SvgPicture svgPicture = tester.firstWidget(find.byType(SvgPicture));
      final BuildContext context = tester.element(find.byType(SvgPicture));

      expect(svgPicture, isNotNull);
      expect(
        (svgPicture.bytesLoader as SvgStringLoader).getTheme(context).fontSize,
        equals(12.0),
      );
    });

    testWidgets(
        'fontSize defaults to 14 '
        "if no widget's theme, DefaultSvgTheme or DefaultTextStyle is provided",
        (WidgetTester tester) async {
      final SvgPicture svgPictureWidget = SvgPicture.string(
        '''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="10em" height="10em" />
</svg>''',
      );

      await tester.pumpWidget(svgPictureWidget);

      final SvgPicture svgPicture = tester.firstWidget(find.byType(SvgPicture));
      final BuildContext context = tester.element(find.byType(SvgPicture));
      expect(svgPicture, isNotNull);
      expect(
        (svgPicture.bytesLoader as SvgStringLoader).getTheme(context).fontSize,
        equals(14.0),
      );
    });

    testWidgets(
        "xHeight from the widget's theme takes precedence over "
        'the theme from DefaultSvgTheme', (WidgetTester tester) async {
      const SvgTheme svgTheme = SvgTheme(
        xHeight: 6.5,
      );

      final SvgPicture svgPictureWidget = SvgPicture.string(
        '''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="10ex" height="10ex" />
</svg>''',
        theme: const SvgTheme(
          fontSize: 12.0,
          xHeight: 7.0,
        ),
      );

      await tester.pumpWidget(DefaultSvgTheme(
        theme: svgTheme,
        child: svgPictureWidget,
      ));

      final SvgPicture svgPicture = tester.firstWidget(find.byType(SvgPicture));
      final BuildContext context = tester.element(find.byType(SvgPicture));
      expect(svgPicture, isNotNull);
      expect(
        (svgPicture.bytesLoader as SvgStringLoader).getTheme(context).xHeight,
        equals(7.0),
      );
    });

    testWidgets(
        'xHeight defaults to the font size divided by 2 (7.0) '
        "if no widget's theme or DefaultSvgTheme is provided",
        (WidgetTester tester) async {
      final SvgPicture svgPictureWidget = SvgPicture.string(
        '''
<svg viewBox="0 0 10 10">
  <rect x="0" y="0" width="10ex" height="10ex" />
</svg>''',
      );

      await tester.pumpWidget(svgPictureWidget);

      final SvgPicture svgPicture = tester.firstWidget(find.byType(SvgPicture));
      final BuildContext context = tester.element(find.byType(SvgPicture));
      expect(svgPicture, isNotNull);
      expect(
        (svgPicture.bytesLoader as SvgStringLoader).getTheme(context).xHeight,
        equals(7.0),
      );
    });
  });
}
