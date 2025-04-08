// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart' show parseLibraryFile;
import 'package:rfw/rfw.dart';

import 'utils.dart';

void main() {
  testWidgets('String example', (WidgetTester tester) async {
    Duration? duration;
    Curve? curve;
    int buildCount = 0;
    final Widget builder = Builder(
      builder: (BuildContext context) {
        buildCount += 1;
        duration = AnimationDefaults.durationOf(context);
        curve = AnimationDefaults.curveOf(context);
        return const SizedBox.shrink();
      },
    );
    await tester.pumpWidget(
      AnimationDefaults(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
        child: builder,
      ),
    );
    expect(duration, const Duration(milliseconds: 500));
    expect(curve, Curves.easeIn);
    expect(buildCount, 1);
    await tester.pumpWidget(
      AnimationDefaults(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
        child: builder,
      ),
    );
    expect(buildCount, 1);
    await tester.pumpWidget(
      AnimationDefaults(
        duration: const Duration(milliseconds: 501),
        curve: Curves.easeIn,
        child: builder,
      ),
    );
    expect(buildCount, 2);
  });

  testWidgets('spot checks', (WidgetTester tester) async {
    Duration? duration;
    Curve? curve;
    int buildCount = 0;
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets())
      ..update(const LibraryName(<String>['builder']), LocalWidgetLibrary(<String, LocalWidgetBuilder>{
        'Test': (BuildContext context, DataSource source) {
          buildCount += 1;
          duration = AnimationDefaults.durationOf(context);
          curve = AnimationDefaults.curveOf(context);
          return const SizedBox.shrink();
        },
      }))
      ..update(const LibraryName(<String>['test']), parseLibraryFile('import core; widget root = SizedBox();'));
    addTearDown(runtime.dispose);
    final DynamicContent data = DynamicContent();
    final List<String> eventLog = <String>[];
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
        onEvent: (String eventName, DynamicMap eventArguments) {
          eventLog.add(eventName);
          expect(eventArguments, const <String, Object?>{ 'argument': true });
        },
      ),
    );
    expect(find.byType(SizedBox), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Align(alignment: { x: 0.25, y: 0.75 });
    '''));
    await tester.pump();
    expect(tester.widget<Align>(find.byType(Align)).alignment, const Alignment(0.25, 0.75));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Align(alignment: { start: 0.25, y: 0.75 });
    '''));
    await tester.pump();
    expect(tester.widget<Align>(find.byType(Align)).alignment, const Alignment(0.25, 0.75));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      import builder;
      widget root = AnimationDefaults(curve: "easeOut", duration: 5000, child: Test());
    '''));
    await tester.pump();
    expect(buildCount, 1);
    expect(duration, const Duration(seconds: 5));
    expect(curve, Curves.easeOut);

    ArgumentDecoders.curveDecoders['saw3'] = (DataSource source, List<Object> key) => const SawTooth(3);
    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      import builder;
      widget root = AnimationDefaults(curve: "saw3", child: Test());
    '''));
    await tester.pump();
    expect(curve, isA<SawTooth>());

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = AspectRatio(aspectRatio: 0.5);
    '''));
    await tester.pump();
    expect(tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio, 0.5);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Center(widthFactor: 0.25);
    '''));
    await tester.pump();
    expect(tester.widget<Center>(find.byType(Center)).widthFactor, 0.25);
    expect(tester.widget<Center>(find.byType(Center)).heightFactor, null);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = ColoredBox(color: 0xFF112233);
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF112233));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Column(
        mainAxisAlignment: "center",
        children: [ ColoredBox(color: 1), ColoredBox(color: 2) ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<Column>(find.byType(Column)).mainAxisAlignment, MainAxisAlignment.center);
    expect(tester.widget<Column>(find.byType(Column)).crossAxisAlignment, CrossAxisAlignment.center);
    expect(tester.widget<Column>(find.byType(Column)).verticalDirection, VerticalDirection.down);
    expect(tester.widget<Column>(find.byType(Column)).children, hasLength(2));
    expect(tester.widgetList<ColoredBox>(find.byType(ColoredBox)).toList()[0].color, const Color(0x00000001));
    expect(tester.widgetList<ColoredBox>(find.byType(ColoredBox)).toList()[1].color, const Color(0x00000002));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = ColoredBox(color: 0xFF112233);
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF112233));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = DefaultTextStyle(
        textHeightBehavior: { applyHeightToLastDescent: false },
        child: SizedBoxShrink(),
      );
    '''));
    await tester.pump();
    expect(
      tester.widget<DefaultTextStyle>(find.byType(DefaultTextStyle)).textHeightBehavior,
      const TextHeightBehavior(applyHeightToLastDescent: false),
    );

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "ltr",
        child: SizedBoxShrink(),
      );
    '''));
    await tester.pump();
    expect(tester.widget<Directionality>(find.byType(Directionality)).textDirection, TextDirection.ltr);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = FittedBox(
        fit: "cover",
      );
    '''));
    await tester.pump();
    expect(tester.widget<FittedBox>(find.byType(FittedBox)).fit, BoxFit.cover);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = GestureDetector(
        onTap: event 'tap' { argument: true },
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    await tester.tap(find.byType(ColoredBox));
    expect(eventLog, <String>['tap']);
    eventLog.clear();

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "ltr",
        child: Icon(
          icon: 0x0001,
          fontFamily: 'FONT',
        ),
      );
    '''));
    await tester.pump();
    expect(tester.widget<Icon>(find.byType(Icon)).icon!.codePoint, 1);
    expect(tester.widget<Icon>(find.byType(Icon)).icon!.fontFamily, 'FONT');

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = IconTheme(
        color: 0x12345678,
        child: SizedBoxShrink(),
      );
    '''));
    await tester.pump();
    expect(tester.widget<IconTheme>(find.byType(IconTheme)).data.color, const Color(0x12345678));
  });

  testWidgets('golden checks', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets())
      ..update(const LibraryName(<String>['test']), parseLibraryFile('import core; widget root = SizedBox();'));
      addTearDown(runtime.dispose);
    final DynamicContent data = DynamicContent();
    final List<String> eventLog = <String>[];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: RemoteWidget(
          runtime: runtime,
          data: data,
          widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
          onEvent: (String eventName, DynamicMap eventArguments) {
            eventLog.add('$eventName $eventArguments');
          },
        ),
      ),
    );
    expect(find.byType(RemoteWidget), findsOneWidget);

    ArgumentDecoders.decorationDecoders['tab'] = (DataSource source, List<Object> key) {
      return UnderlineTabIndicator(
        borderSide: ArgumentDecoders.borderSide(source, <Object>[...key, 'side']) ?? const BorderSide(width: 2.0, color: Color(0xFFFFFFFF)),
        insets: ArgumentDecoders.edgeInsets(source, <Object>['insets']) ?? EdgeInsets.zero,
      );
    };
    ArgumentDecoders.gradientDecoders['custom'] = (DataSource source, List<Object> key) {
      return const RadialGradient(
        center: Alignment(0.7, -0.6),
        radius: 0.2,
        colors: <Color>[ Color(0xFFFFFF00), Color(0xFF0099FF) ],
        stops: <double>[0.4, 1.0],
      );
    };
    ArgumentDecoders.shapeBorderDecoders['custom'] = (DataSource source, List<Object> key) {
      return StarBorder(
        side: ArgumentDecoders.borderSide(source, <Object>[...key, 'side']) ?? const BorderSide(width: 2.0, color: Color(0xFFFFFFFF)),
        points: source.v<double>(<Object>[...key, 'points']) ?? 5.0,
      );
    };

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Container(
        margin: [20.0, 10.0, 30.0, 5.0],
        padding: [10.0],
        decoration: {
          type: 'box',
          borderRadius: [ { x: 120.0 }, { x: 130.0, y: 40.0 } ],
          image: {
            // this image doesn't exist so nothing much happens here
            // we check the results of this parse in a separate expect
            source: 'asset',
            color: 0xFF00BBCC,
            centerSlice: { x: 5.0, y: 8.0, w: 100.0, h: 70.0 },
            colorFilter: {
              type: 'matrix', matrix: [
                1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 1.0, 1.0,
              ],
            },
            filterQuality: "none",
          },
          gradient: {
            type: 'sweep',
          },
        },
        foregroundDecoration: {
          type: 'box',
          border: [ { width: 10.0, color: 0xFFFFFF00 }, { width: 3.0, color: 0xFF00FFFF } ],
          boxShadow: [ { offset: { x: 25.0, y: 25.0 }, color: 0x5F000000, } ],
          image: {
            // this image also doesn't exist
            // we check the results of this parse in a separate expect
            source: 'x-invalid://',
            colorFilter: {
              type: 'mode',
              color: 0xFF8811FF,
              blendMode: "xor",
            },
            onError: event 'image-error-event' { },
            filterQuality: "high",
          },
          gradient: {
            type: 'linear',
            colors: [ 0x1F009900, 0x1F33CC33, 0x7F777700 ],
            stops: [ 0.0, 0.75, 1.0 ],
          },
        },
        alignment: { x: 0.0, y: -0.5, },
        transform: [
          0.9, 0.2, 0.1, 0.0,
          -0.1, 1.1, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          50.0, -20.0, 0.0, 1.0,
        ],
        child: Container(
          constraints: { maxWidth: 400.0, maxHeight: 350.0 },
          margin: [5.0, 25.0, 10.0, 20.0],
          decoration: {
            type: 'box',
            color: 0xFF9911CC,
            gradient: { type: 'custom' },
          },
          foregroundDecoration: {
            type: 'flutterLogo',
            margin: [ 100.0 ],
          },
          child: Container(
            margin: [5.0],
            decoration: {
              type: 'tab',
              side: { width: 20.0, color: 0xFFFFFFFF },
            },
            foregroundDecoration: {
              type: 'shape',
              shape: [
                { type: 'box', border: { width: 10.0, color: 0xFF0000FF } },
                { type: 'beveled', borderRadius: [ { x: 60.0 } ], side: { width: 10.0, color: 0xFF0033FF } },
                { type: 'circle', side: { width: 10.0, color: 0xFF0066FF } },
                { type: 'continuous', borderRadius: [ { x: 60.0 }, { x: 80.0 }, { x: 0.0 }, { x: 20.0, y: 50.0 } ], side: { width: 10.0, color: 0xFFEEFF33 } },
                { type: 'rounded', borderRadius: [ { x: 20.0 } ], side: { width: 10.0, color: 0xFF00CCFF } },
                { type: 'stadium', side: { width: 10.0, color: 0xFF00FFFF } },
                { type: 'custom', side: { width: 5.0, color: 0xFFFFFF00 }, points: 6 }, // star
              ],
              gradient: {
                type: 'radial',
              },
            },
          ),
        ),
      );
    '''));
    await tester.pump();
    if (!kIsWeb) {
      expect(eventLog, hasLength(1));
      expect(eventLog.first, startsWith('image-error-event {exception: HTTP request failed, statusCode: 400, x-invalid:'));
      eventLog.clear();
    }
    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile('goldens/argument_decoders_test.containers.png'),
      // TODO(louisehsu): Unskip once golden file is updated. See
      // https://github.com/flutter/flutter/issues/151995
      skip: !runGoldens || true,
    );
    expect(find.byType(DecoratedBox), findsNWidgets(6));
    const String matrix = kIsWeb ? '1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1'
                                 : '1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0';
    expect(
      (tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).toList()[1].decoration as BoxDecoration).image.toString(),
      'DecorationImage(AssetImage(bundle: null, name: "asset"), ' // this just seemed like the easiest way to check all this...
      'ColorFilter.matrix([$matrix]), '
      'Alignment.center, centerSlice: Rect.fromLTRB(5.0, 8.0, 105.0, 78.0), scale 1.0, opacity 1.0, FilterQuality.none)',
    );
    expect(
      (tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).toList()[0].decoration as BoxDecoration).image.toString(),
      'DecorationImage(NetworkImage("x-invalid://", scale: 1.0), '
      'ColorFilter.mode(${const Color(0xff8811ff)}, BlendMode.xor), Alignment.center, scale 1.0, '
      'opacity 1.0, FilterQuality.high)',
    );

    ArgumentDecoders.colorFilterDecoders['custom'] = (DataSource source, List<Object> key) {
      return const ColorFilter.mode(Color(0x12345678), BlendMode.xor);
    };
    ArgumentDecoders.maskFilterDecoders['custom'] = (DataSource source, List<Object> key) {
      return const MaskFilter.blur(BlurStyle.outer, 0.5);
    };
    ArgumentDecoders.shaderDecoders['custom'] = (DataSource source, List<Object> key) {
      return ui.Gradient.linear(Offset.zero, const Offset(100.0, 100.0), const <Color>[Color(0xFFFFFF00), Color(0xFF00FFFF)]);
    };

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Column(
        children: [
          Text(
            text: [
              'Hello World Hello World Hello World Hello World Hello World Hello World Hello World',
              'Hello World Hello World Hello World Hello World Hello World Hello World Hello World',
            ],
            locale: "en-US",
            style: {
              fontFamilyFallback: [ "a", "b" ],
              fontSize: 30.0,
            },
            strutStyle: {
              fontSize: 50.0,
            },
          ),
          Expanded(
            flex: 2,
            child: Text(
              text: 'Aaaa Aaaaaaa Aaaaa',
              locale: "en",
              style: {
                decoration: [ "underline", "overline" ],
                decorationColor: 0xFF00FF00,
                fontFeatures: [ { feature: 'sups' } ],
                foreground: {
                  blendMode: 'color',
                  color: 0xFFEEDDCC,
                  colorFilter: { type: 'srgbToLinearGamma' },
                  filterQuality: "high",
                  isAntiAlias: true,
                  maskFilter: { type: 'blur' },
                  shader: { type: 'linear', rect: { x: 0.0, y: 0.0, w: 300.0, h: 200.0, } }
                },
                background: {
                  colorFilter: { type: 'custom' },
                  maskFilter: { type: 'custom' },
                  shader: { type: 'custom' },
                },
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              text: 'B',
              locale: "en-latin-GB",
            ),
          ),
        ],
      );
    '''));
    await tester.pump();
    expect(tester.firstWidget<Text>(find.byType(Text)).style!.fontFamilyFallback, <String>[ 'a', 'b' ]);
    expect(tester.widgetList<Text>(find.byType(Text)).map<Locale>((Text widget) => widget.locale!), const <Locale>[Locale('en', 'US'), Locale('en'), Locale.fromSubtags(languageCode: 'en', scriptCode: 'latin', countryCode: 'GB')]);
    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile('goldens/argument_decoders_test.text.png'),
      skip: !runGoldens,
    );

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = GridView(
        gridDelegate: { type: 'fixedCrossAxisCount', crossAxisCount: 3 },
        children: [
          ColoredBox(color: 0xFF118844),
          ColoredBox(color: 0xFFEE8844),
          ColoredBox(color: 0xFF882244),
          ColoredBox(color: 0xFF449999),
          ColoredBox(color: 0xFF330088),
          ColoredBox(color: 0xFF8822CC),
          ColoredBox(color: 0xFF330000),
          ColoredBox(color: 0xFF992288),
        ],
      );
    '''));
    await tester.pump();
    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile('goldens/argument_decoders_test.gridview.fixed.png'),
      skip: !runGoldens,
    );

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = GridView(
        gridDelegate: { type: 'maxCrossAxisExtent', maxCrossAxisExtent: 50.0 },
        children: [
          ColoredBox(color: 0xFF118844),
          ColoredBox(color: 0xFFEE8844),
          ColoredBox(color: 0xFF882244),
          ColoredBox(color: 0xFF449999),
          ColoredBox(color: 0xFF330088),
          ColoredBox(color: 0xFF8822CC),
          ColoredBox(color: 0xFF330000),
          ColoredBox(color: 0xFF992288),
        ],
      );
    '''));
    await tester.pump();
    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile('goldens/argument_decoders_test.gridview.max.png'),
      skip: !runGoldens,
    );

    int sawGridDelegateDecoder = 0;
    ArgumentDecoders.gridDelegateDecoders['custom'] = (DataSource source, List<Object> key) {
      sawGridDelegateDecoder += 1;
      return null;
    };
    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = GridView(
        gridDelegate: { type: 'custom' },
        children: [
          ColoredBox(color: 0xFF118844),
          ColoredBox(color: 0xFFEE8844),
          ColoredBox(color: 0xFF882244),
          ColoredBox(color: 0xFF449999),
          ColoredBox(color: 0xFF330088),
          ColoredBox(color: 0xFF8822CC),
          ColoredBox(color: 0xFF330000),
          ColoredBox(color: 0xFF992288),
        ],
      );
    '''));
    expect(sawGridDelegateDecoder, 0);
    await tester.pump();
    expect(sawGridDelegateDecoder, 1);
    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile('goldens/argument_decoders_test.gridview.custom.png'),
      skip: !runGoldens,
    );

    expect(eventLog, isEmpty);
  }, skip: kIsWeb || !isMainChannel); // https://github.com/flutter/flutter/pull/129851
}
