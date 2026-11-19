// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  RenderObject getOverlayColor(WidgetTester tester) {
    return tester.allRenderObjects.firstWhere(
      (RenderObject object) => object.runtimeType.toString() == '_RenderInkFeatures',
    );
  }

  test('IconButtonThemeData lerp special cases', () {
    expect(IconButtonThemeData.lerp(null, null, 0), null);
    const data = IconButtonThemeData();
    expect(identical(IconButtonThemeData.lerp(data, data, 0.5), data), true);
  });

  test('IconButtonThemeData supports Material 3 Expressive variant', () {
    const data = IconButtonThemeData(variant: StyleVariant.material3Expressive);

    expect(data.variant, StyleVariant.material3Expressive);
  });

  test('IconButtonThemeData variant defaults to null', () {
    const data = IconButtonThemeData();

    expect(data.variant, isNull);
  });

  testWidgets('IconButton supports Material 3 Expressive style variants', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(
          body: IconButtonTheme(
            data: IconButtonThemeData(variant: StyleVariant.material3Expressive),
            child: IconButton(onPressed: null, icon: Icon(Icons.ac_unit)),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('Passing no IconButtonTheme returns defaults', (WidgetTester tester) async {
    const colorScheme = ColorScheme.light();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.from(colorScheme: colorScheme),
        home: Scaffold(
          body: Center(
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.ac_unit)),
          ),
        ),
      ),
    );

    final Finder buttonMaterial = find.descendant(
      of: find.byType(IconButton),
      matching: find.byType(Material),
    );

    final Material material = tester.widget<Material>(buttonMaterial);
    expect(material.animationDuration, const Duration(milliseconds: 200));
    expect(material.borderRadius, null);
    expect(material.color, Colors.transparent);
    expect(material.elevation, 0.0);
    expect(material.shadowColor, Colors.transparent);
    expect(material.shape, const StadiumBorder());
    expect(material.textStyle, null);
    expect(material.type, MaterialType.button);

    final Align align = tester.firstWidget<Align>(
      find.ancestor(of: find.byIcon(Icons.ac_unit), matching: find.byType(Align)),
    );
    expect(align.alignment, Alignment.center);
  });

  group('[Theme, IconTheme, IconButton style overrides]', () {
    const foregroundColor = Color(0xff000001);
    const disabledForegroundColor = Color(0xff000002);
    const backgroundColor = Color(0xff000003);
    const shadowColor = Color(0xff000004);
    const double elevation = 3;
    const padding = EdgeInsets.all(3);
    const minimumSize = Size(200, 200);
    const side = BorderSide(color: Colors.green, width: 2);
    const OutlinedBorder shape = RoundedRectangleBorder(
      side: side,
      borderRadius: BorderRadius.all(Radius.circular(2)),
    );
    const MouseCursor enabledMouseCursor = SystemMouseCursors.text;
    const MouseCursor disabledMouseCursor = SystemMouseCursors.grab;
    const MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.shrinkWrap;
    const animationDuration = Duration(milliseconds: 25);
    const enableFeedback = false;
    const AlignmentGeometry alignment = Alignment.centerLeft;

    final ButtonStyle style = IconButton.styleFrom(
      foregroundColor: foregroundColor,
      disabledForegroundColor: disabledForegroundColor,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      elevation: elevation,
      padding: padding,
      minimumSize: minimumSize,
      side: side,
      shape: shape,
      enabledMouseCursor: enabledMouseCursor,
      disabledMouseCursor: disabledMouseCursor,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
    );

    Widget buildFrame({
      ButtonStyle? buttonStyle,
      ButtonStyle? themeStyle,
      ButtonStyle? overallStyle,
    }) {
      final Widget child = Builder(
        builder: (BuildContext context) {
          return IconButton(style: buttonStyle, onPressed: () {}, icon: const Icon(Icons.ac_unit));
        },
      );
      return MaterialApp(
        theme: ThemeData.from(colorScheme: const ColorScheme.light())
            .copyWith(iconButtonTheme: IconButtonThemeData(style: overallStyle)),
        home: Scaffold(
          body: Center(
            // If the IconButtonTheme widget is present, it's used
            // instead of the Theme's ThemeData.iconButtonTheme.
            child: themeStyle == null
                ? child
                : IconButtonTheme(
                    data: IconButtonThemeData(style: themeStyle),
                    child: child,
                  ),
          ),
        ),
      );
    }

    final Finder findMaterial = find.descendant(
      of: find.byType(IconButton),
      matching: find.byType(Material),
    );

    final Finder findInkWell = find.descendant(
      of: find.byType(IconButton),
      matching: find.byType(InkWell),
    );

    const enabled = <WidgetState>{};
    const disabled = <WidgetState>{WidgetState.disabled};
    const hovered = <WidgetState>{WidgetState.hovered};
    const focused = <WidgetState>{WidgetState.focused};
    const pressed = <WidgetState>{WidgetState.pressed};

    void checkButton(WidgetTester tester) {
      final Material material = tester.widget<Material>(findMaterial);
      final InkWell inkWell = tester.widget<InkWell>(findInkWell);
      expect(material.textStyle, null);
      expect(material.color, backgroundColor);
      expect(material.shadowColor, shadowColor);
      expect(material.elevation, elevation);
      expect(
        WidgetStateProperty.resolveAs<MouseCursor?>(inkWell.mouseCursor, enabled),
        enabledMouseCursor,
      );
      expect(
        WidgetStateProperty.resolveAs<MouseCursor?>(inkWell.mouseCursor, disabled),
        disabledMouseCursor,
      );
      expect(inkWell.overlayColor!.resolve(hovered), foregroundColor.withOpacity(0.08));
      expect(inkWell.overlayColor!.resolve(focused), foregroundColor.withOpacity(0.1));
      expect(inkWell.overlayColor!.resolve(pressed), foregroundColor.withOpacity(0.1));
      expect(inkWell.enableFeedback, enableFeedback);
      expect(material.borderRadius, null);
      expect(material.shape, shape);
      expect(material.animationDuration, animationDuration);
      expect(tester.getSize(find.byType(IconButton)), const Size(200, 200));
      final Align align = tester.firstWidget<Align>(
        find.ancestor(of: find.byIcon(Icons.ac_unit), matching: find.byType(Align)),
      );
      expect(align.alignment, alignment);
    }

    testWidgets('Button style overrides defaults', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(buttonStyle: style));
      await tester.pumpAndSettle(); // allow the animations to finish
      checkButton(tester);
    });

    testWidgets('Button theme style overrides defaults', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(themeStyle: style));
      await tester.pumpAndSettle();
      checkButton(tester);
    });

    testWidgets('Overall Theme button theme style overrides defaults', (WidgetTester tester) async {
      await tester.pumpWidget(buildFrame(overallStyle: style));
      await tester.pumpAndSettle();
      checkButton(tester);
    });

    // Same as the previous tests with empty ButtonStyle's instead of null.

    testWidgets('Button style overrides defaults, empty theme and overall styles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFrame(
          buttonStyle: style,
          themeStyle: const ButtonStyle(),
          overallStyle: const ButtonStyle(),
        ),
      );
      await tester.pumpAndSettle(); // allow the animations to finish
      checkButton(tester);
    });

    testWidgets('Button theme style overrides defaults, empty button and overall styles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildFrame(
          buttonStyle: const ButtonStyle(),
          themeStyle: style,
          overallStyle: const ButtonStyle(),
        ),
      );
      await tester.pumpAndSettle(); // allow the animations to finish
      checkButton(tester);
    });

    testWidgets(
      'Overall Theme button theme style overrides defaults, null theme and empty overall style',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildFrame(buttonStyle: const ButtonStyle(), overallStyle: style));
        await tester.pumpAndSettle(); // allow the animations to finish
        checkButton(tester);
      },
    );
  });

  testWidgets('Theme shadowColor', (WidgetTester tester) async {
    const colorScheme = ColorScheme.light();
    const shadowColor = Color(0xff000001);
    const overriddenColor = Color(0xff000002);

    Widget buildFrame({Color? overallShadowColor, Color? themeShadowColor, Color? shadowColor}) {
      return MaterialApp(
        theme: ThemeData.from(colorScheme: colorScheme).copyWith(shadowColor: overallShadowColor),
        home: Scaffold(
          body: Center(
            child: IconButtonTheme(
              data: IconButtonThemeData(style: IconButton.styleFrom(shadowColor: themeShadowColor)),
              child: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    style: IconButton.styleFrom(shadowColor: shadowColor),
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    final Finder buttonMaterialFinder = find.descendant(
      of: find.byType(IconButton),
      matching: find.byType(Material),
    );

    await tester.pumpWidget(buildFrame());
    Material material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, Colors.transparent); //default

    await tester.pumpWidget(buildFrame(overallShadowColor: shadowColor));
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, Colors.transparent);

    await tester.pumpWidget(buildFrame(themeShadowColor: shadowColor));
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, shadowColor);

    await tester.pumpWidget(buildFrame(shadowColor: shadowColor));
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, shadowColor);

    await tester.pumpWidget(
      buildFrame(overallShadowColor: overriddenColor, themeShadowColor: shadowColor),
    );
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, shadowColor);

    await tester.pumpWidget(
      buildFrame(themeShadowColor: overriddenColor, shadowColor: shadowColor),
    );
    await tester.pumpAndSettle(); // theme animation
    material = tester.widget<Material>(buttonMaterialFinder);
    expect(material.shadowColor, shadowColor);
  });

  testWidgets('IconButtonTheme IconButton.styleFrom overlayColor overrides default overlay color', (
    WidgetTester tester,
  ) async {
    const overlayColor = Color(0xffff0000);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: IconButtonTheme(
              data: IconButtonThemeData(style: IconButton.styleFrom(overlayColor: overlayColor)),
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            ),
          ),
        ),
      ),
    );

    // Hovered.
    final Offset center = tester.getCenter(find.byType(IconButton));
    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(center);
    await tester.pumpAndSettle();
    expect(getOverlayColor(tester), paints..rect(color: overlayColor.withOpacity(0.08)));

    // Highlighted (pressed).
    await gesture.down(center);
    await tester.pumpAndSettle();
    expect(
      getOverlayColor(tester),
      paints
        ..rect(color: overlayColor.withOpacity(0.08))
        ..rect(color: overlayColor.withOpacity(0.1)),
    );
    // Remove pressed and hovered states,
    await gesture.up();
    await tester.pumpAndSettle();
    await gesture.moveTo(const Offset(0, 50));
    await tester.pumpAndSettle();

    // Focused.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(getOverlayColor(tester), paints..rect(color: overlayColor.withOpacity(0.1)));
  });

  group('IconButtonTheme.variantOf', () {
    // A square icon button uses a RoundedRectangleBorder in Material 3
    // Expressive. Material 3 ignores shapeVariant and uses a StadiumBorder.
    const buttonKey = Key('button');
    const squareButton = IconButton(
      key: buttonKey,
      onPressed: _onPressed,
      style: ButtonStyle(shapeVariant: ButtonShapeVariant.square),
      icon: Icon(Icons.add),
    );
    const customStyle = ButtonStyle(
      foregroundColor: WidgetStatePropertyAll<Color>(Color(0xffff0000)),
    );

    ShapeBorder? buttonShape(WidgetTester tester) {
      return tester
          .widget<Material>(
            find.descendant(of: find.byKey(buttonKey), matching: find.byType(Material)),
          )
          .shape;
    }

    // Builds the square button and reports the variant that applies to it.
    Widget buttonWithVariant(ValueSetter<StyleVariant> onVariant) {
      return Builder(
        builder: (BuildContext context) {
          onVariant(IconButtonTheme.variantOf(context));
          return squareButton;
        },
      );
    }

    testWidgets('returns material3 when no theme specifies a variant', (WidgetTester tester) async {
      StyleVariant? variant;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: IconButtonTheme(
              data: const IconButtonThemeData(style: customStyle),
              child: buttonWithVariant((StyleVariant value) => variant = value),
            ),
          ),
        ),
      );

      expect(variant, StyleVariant.material3);
      expect(buttonShape(tester), isA<StadiumBorder>());
    });

    testWidgets('returns the variant of ThemeData.iconButtonTheme', (WidgetTester tester) async {
      StyleVariant? variant;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconButtonTheme: const IconButtonThemeData(variant: StyleVariant.material3Expressive),
          ),
          home: Center(child: buttonWithVariant((StyleVariant value) => variant = value)),
        ),
      );

      expect(variant, StyleVariant.material3Expressive);
      expect(buttonShape(tester), isA<RoundedRectangleBorder>());
    });

    testWidgets('a nested IconButtonTheme without a variant inherits it from an IconButtonTheme', (
      WidgetTester tester,
    ) async {
      StyleVariant? variant;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: IconButtonTheme(
              data: const IconButtonThemeData(variant: StyleVariant.material3Expressive),
              child: IconButtonTheme(
                data: const IconButtonThemeData(style: customStyle),
                child: buttonWithVariant((StyleVariant value) => variant = value),
              ),
            ),
          ),
        ),
      );

      expect(variant, StyleVariant.material3Expressive);
      expect(buttonShape(tester), isA<RoundedRectangleBorder>());
    });

    testWidgets('an IconButtonTheme without a variant inherits it from ThemeData.iconButtonTheme', (
      WidgetTester tester,
    ) async {
      StyleVariant? variant;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconButtonTheme: const IconButtonThemeData(variant: StyleVariant.material3Expressive),
          ),
          home: Center(
            child: IconButtonTheme(
              data: const IconButtonThemeData(style: customStyle),
              child: buttonWithVariant((StyleVariant value) => variant = value),
            ),
          ),
        ),
      );

      expect(variant, StyleVariant.material3Expressive);
      expect(buttonShape(tester), isA<RoundedRectangleBorder>());
    });

    testWidgets('an explicit variant overrides the variant of the ancestors', (
      WidgetTester tester,
    ) async {
      StyleVariant? variant;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: IconButtonTheme(
              data: const IconButtonThemeData(variant: StyleVariant.material3Expressive),
              child: IconButtonTheme(
                data: const IconButtonThemeData(
                  style: customStyle,
                  variant: StyleVariant.material3,
                ),
                child: buttonWithVariant((StyleVariant value) => variant = value),
              ),
            ),
          ),
        ),
      );

      expect(variant, StyleVariant.material3);
      expect(buttonShape(tester), isA<StadiumBorder>());
    });

    testWidgets('an enclosing IconButtonTheme takes precedence over a closer Theme', (
      WidgetTester tester,
    ) async {
      StyleVariant? variant;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: IconButtonTheme(
              data: const IconButtonThemeData(variant: StyleVariant.material3Expressive),
              child: Theme(
                data: ThemeData(
                  iconButtonTheme: const IconButtonThemeData(variant: StyleVariant.material3),
                ),
                child: buttonWithVariant((StyleVariant value) => variant = value),
              ),
            ),
          ),
        ),
      );

      expect(variant, StyleVariant.material3Expressive);
      expect(buttonShape(tester), isA<RoundedRectangleBorder>());
    });

    testWidgets('IconButton is rebuilt when an IconButtonTheme above the closest one changes', (
      WidgetTester tester,
    ) async {
      final variant = ValueNotifier<StyleVariant?>(StyleVariant.material3Expressive);
      addTearDown(variant.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ValueListenableBuilder<StyleVariant?>(
              valueListenable: variant,
              // The subtree is const, so it is only rebuilt through its
              // dependency on the outer IconButtonTheme.
              child: const IconButtonTheme(
                data: IconButtonThemeData(style: customStyle),
                child: squareButton,
              ),
              builder: (BuildContext context, StyleVariant? value, Widget? child) {
                return IconButtonTheme(
                  data: IconButtonThemeData(variant: value),
                  child: child!,
                );
              },
            ),
          ),
        ),
      );
      expect(buttonShape(tester), isA<RoundedRectangleBorder>());

      variant.value = StyleVariant.material3;
      await tester.pumpAndSettle();
      expect(buttonShape(tester), isA<StadiumBorder>());
    });

    testWidgets('IconButton in a ListTile uses the inherited variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconButtonTheme: const IconButtonThemeData(variant: StyleVariant.material3Expressive),
          ),
          home: const Material(
            child: ListTile(title: Text('Title'), trailing: squareButton),
          ),
        ),
      );

      expect(buttonShape(tester), isA<RoundedRectangleBorder>());
    });

    testWidgets('IconButton in an InputDecorator suffix icon uses the inherited variant', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconButtonTheme: const IconButtonThemeData(variant: StyleVariant.material3Expressive),
          ),
          home: const Material(
            child: TextField(decoration: InputDecoration(suffixIcon: squareButton)),
          ),
        ),
      );

      expect(buttonShape(tester), isA<RoundedRectangleBorder>());
    });

    testWidgets(
      'IconButton in an AppBar with a custom foregroundColor uses the inherited variant',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              iconButtonTheme: const IconButtonThemeData(variant: StyleVariant.material3Expressive),
            ),
            home: Scaffold(
              appBar: AppBar(
                foregroundColor: const Color(0xffff0000),
                actions: const <Widget>[squareButton],
              ),
            ),
          ),
        );

        expect(buttonShape(tester), isA<RoundedRectangleBorder>());
      },
    );
  });
}

void _onPressed() {}
