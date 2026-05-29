// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_3_expressive.dart';

void main() {
  // Helper to create a testable icon button.
  Widget buildApp({required Widget child, ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData(useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );
  }

  Finder iconButtonMaterialFinder() {
    return find.descendant(of: find.byType(IconButton), matching: find.byType(Material));
  }

  Material iconButtonMaterial(WidgetTester tester) {
    return tester.widget<Material>(iconButtonMaterialFinder());
  }

  Size iconButtonMaterialSize(WidgetTester tester) {
    return tester.getSize(iconButtonMaterialFinder());
  }

  ColorScheme colorScheme(WidgetTester tester) {
    return Theme.of(tester.element(find.byType(IconButton))).colorScheme;
  }

  Color? iconColor(WidgetTester tester, IconData icon) {
    return IconTheme.of(tester.element(find.byIcon(icon))).color;
  }

  group('M3E IconButton size variants', () {
    testWidgets('default size is small (40x40)', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ),
      );

      // ButtonStyleButton renders with minimum size 40x40, but tap target
      // padding brings it to 48x48.
      expect(iconButtonMaterialSize(tester), const Size(40.0, 40.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(48.0, 48.0));
    });

    testWidgets('xSmall size renders at 32dp minimum', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: const ButtonStyle(size: ButtonSize.xSmall),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(32.0, 32.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(48.0, 48.0));
    });

    testWidgets('styleFrom sets the size variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(size: ButtonSize.medium),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(56.0, 56.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(56.0, 56.0));
    });

    testWidgets('medium size renders at 56dp minimum', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: const ButtonStyle(size: ButtonSize.medium),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(56.0, 56.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(56.0, 56.0));
    });

    testWidgets('large size renders at 96dp minimum', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: const ButtonStyle(size: ButtonSize.large),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(96.0, 96.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(96.0, 96.0));
    });

    testWidgets('xLarge size renders at 136dp minimum', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: const ButtonStyle(size: ButtonSize.xLarge),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(136.0, 136.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(136.0, 136.0));
    });
  });

  group('M3E IconButton width variants', () {
    testWidgets('small IconButton supports narrow, standard, and wide widths', (
      WidgetTester tester,
    ) async {
      Future<Size> materialSizeFor(IconButtonWidth width) async {
        await tester.pumpWidget(
          buildApp(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add),
              style: ButtonStyle(iconButtonWidth: width),
            ),
          ),
        );
        return iconButtonMaterialSize(tester);
      }

      expect(await materialSizeFor(IconButtonWidth.narrow), const Size(32.0, 40.0));
      expect(await materialSizeFor(IconButtonWidth.standard), const Size(40.0, 40.0));
      expect(await materialSizeFor(IconButtonWidth.wide), const Size(52.0, 40.0));

      expect(iconButtonMaterial(tester).animationDuration, kThemeChangeDuration);
    });

    testWidgets('IconButtonThemeData style width sets default width', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          theme: ThemeData(
            useMaterial3: true,
            iconButtonTheme: const IconButtonThemeData(
              style: ButtonStyle(iconButtonWidth: IconButtonWidth.wide),
            ),
          ),
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(52.0, 40.0));
    });
  });

  group('M3E IconButton shape', () {
    OutlinedBorder materialShape(WidgetTester tester) {
      final Material material = tester.widget<Material>(
        find.descendant(of: find.byType(IconButton), matching: find.byType(Material)),
      );
      return material.shape! as OutlinedBorder;
    }

    testWidgets('default shape resolves M3E token shapes by state', (WidgetTester tester) async {
      final statesController = MaterialStatesController();
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            statesController: statesController,
            isSelected: true,
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ),
      );
      expect(
        materialShape(tester),
        const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
      );

      statesController.update(WidgetState.pressed, true);
      await tester.pumpAndSettle();

      expect(
        materialShape(tester),
        const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      );
      statesController.dispose();
    });

    testWidgets('ButtonStyle.shape remains the stateful shape override API', (
      WidgetTester tester,
    ) async {
      final statesController = MaterialStatesController();
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            statesController: statesController,
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: ButtonStyle(
              shape: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  );
                }
                return const StadiumBorder();
              }),
            ),
          ),
        ),
      );

      expect(materialShape(tester), const StadiumBorder());

      statesController.update(WidgetState.pressed, true);
      await tester.pumpAndSettle();

      expect(
        materialShape(tester),
        const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
      );
      statesController.dispose();
    });
  });

  group('M3E IconButton variants', () {
    testWidgets('standard variant has transparent background', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ),
      );

      expect(iconButtonMaterial(tester).color, Colors.transparent);
      expect(iconButtonMaterial(tester).shape, const StadiumBorder());
    });

    testWidgets('filled variant resolves default container color', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton.filled(onPressed: () {}, icon: const Icon(Icons.add)),
        ),
      );

      expect(iconButtonMaterial(tester).color, colorScheme(tester).primary);
      expect(iconButtonMaterial(tester).shape, const StadiumBorder());
    });

    testWidgets('filledTonal variant resolves default container color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.add)),
        ),
      );

      expect(iconButtonMaterial(tester).color, colorScheme(tester).secondaryContainer);
      expect(iconButtonMaterial(tester).shape, const StadiumBorder());
    });

    testWidgets('outlined variant resolves default side and transparent background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton.outlined(onPressed: () {}, icon: const Icon(Icons.add)),
        ),
      );

      final shape = iconButtonMaterial(tester).shape! as StadiumBorder;
      expect(iconButtonMaterial(tester).color, Colors.transparent);
      expect(shape.side, BorderSide(color: colorScheme(tester).outlineVariant));
    });

    testWidgets('filled variant with style size', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton.filled(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: const ButtonStyle(size: ButtonSize.large),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(96.0, 96.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(96.0, 96.0));
    });

    testWidgets('outlined variant with style size', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton.outlined(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: const ButtonStyle(size: ButtonSize.medium),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(56.0, 56.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(56.0, 56.0));
    });
  });

  group('M3E IconButton theme integration', () {
    testWidgets('IconButtonThemeData style size sets default size', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          theme: ThemeData(
            useMaterial3: true,
            iconButtonTheme: const IconButtonThemeData(style: ButtonStyle(size: ButtonSize.large)),
          ),
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(96.0, 96.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(96.0, 96.0));
    });

    testWidgets('widget size overrides theme size', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          theme: ThemeData(
            useMaterial3: true,
            iconButtonTheme: const IconButtonThemeData(style: ButtonStyle(size: ButtonSize.large)),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: const ButtonStyle(size: ButtonSize.xSmall),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(32.0, 32.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(48.0, 48.0));
    });

    testWidgets('IconButtonTheme wrapping sets size', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButtonTheme(
            data: const IconButtonThemeData(style: ButtonStyle(size: ButtonSize.medium)),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(56.0, 56.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(56.0, 56.0));
    });
  });

  group('M3E IconButton selection', () {
    testWidgets('isSelected shows selectedIcon', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            isSelected: true,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('isSelected exposes selected semantics', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            isSelected: true,
            icon: const Icon(Icons.favorite_border, semanticLabel: 'favorite'),
            selectedIcon: const Icon(Icons.favorite, semanticLabel: 'favorite'),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(IconButton)),
        matchesSemantics(
          hasTapAction: true,
          hasFocusAction: true,
          hasEnabledState: true,
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasSelectedState: true,
          isSelected: true,
          label: 'favorite',
        ),
      );
      handle.dispose();
    });

    testWidgets('external selected state does not affect non-toggleable visual state', (
      WidgetTester tester,
    ) async {
      final statesController = MaterialStatesController();
      statesController.update(WidgetState.selected, true);

      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            statesController: statesController,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
          ),
        ),
      );

      final Material material = tester.widget<Material>(
        find.descendant(of: find.byType(IconButton), matching: find.byType(Material)),
      );
      expect(material.shape, const StadiumBorder());
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('isSelected false shows regular icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            isSelected: false,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('isSelected updates selected widget state when toggled through null', (
      WidgetTester tester,
    ) async {
      final statesController = MaterialStatesController();

      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            isSelected: true,
            statesController: statesController,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
          ),
        ),
      );
      expect(statesController.value, contains(WidgetState.selected));

      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            statesController: statesController,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
          ),
        ),
      );
      expect(statesController.value, isNot(contains(WidgetState.selected)));

      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            isSelected: false,
            statesController: statesController,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
          ),
        ),
      );
      expect(statesController.value, isNot(contains(WidgetState.selected)));

      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            isSelected: true,
            statesController: statesController,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
          ),
        ),
      );
      expect(statesController.value, contains(WidgetState.selected));
    });
  });

  group('M3E IconButton disabled state', () {
    testWidgets('disabled button has reduced opacity colors', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(child: const IconButton(icon: Icon(Icons.add))));

      expect(iconButtonMaterial(tester).color, Colors.transparent);
      expect(iconColor(tester, Icons.add), colorScheme(tester).onSurface.withOpacity(0.38));
    });

    testWidgets('onLongPress without onPressed keeps button enabled', (WidgetTester tester) async {
      var longPressed = false;
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onLongPress: () {
              longPressed = true;
            },
            icon: const Icon(Icons.add, semanticLabel: 'add'),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(IconButton)),
        matchesSemantics(
          hasLongPressAction: true,
          hasFocusAction: true,
          hasEnabledState: true,
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          label: 'add',
        ),
      );

      await tester.longPress(find.byType(IconButton));
      expect(longPressed, isTrue);
      handle.dispose();
    });

    testWidgets('disabled filled button has reduced background', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp(child: const IconButton.filled(icon: Icon(Icons.add))));

      expect(iconButtonMaterial(tester).color, colorScheme(tester).onSurface.withOpacity(0.1));
      expect(iconColor(tester, Icons.add), colorScheme(tester).onSurface.withOpacity(0.38));
    });
  });

  group('IconButtonThemeData', () {
    test('equality', () {
      const a = IconButtonThemeData(
        style: ButtonStyle(size: ButtonSize.small, iconButtonWidth: IconButtonWidth.standard),
      );
      const b = IconButtonThemeData(
        style: ButtonStyle(size: ButtonSize.small, iconButtonWidth: IconButtonWidth.standard),
      );
      const c = IconButtonThemeData(
        style: ButtonStyle(size: ButtonSize.large, iconButtonWidth: IconButtonWidth.wide),
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode', () {
      const a = IconButtonThemeData(
        style: ButtonStyle(size: ButtonSize.small, iconButtonWidth: IconButtonWidth.narrow),
      );
      const b = IconButtonThemeData(
        style: ButtonStyle(size: ButtonSize.small, iconButtonWidth: IconButtonWidth.narrow),
      );

      expect(a.hashCode, equals(b.hashCode));
    });

    test('lerp', () {
      const a = IconButtonThemeData(
        style: ButtonStyle(size: ButtonSize.small, iconButtonWidth: IconButtonWidth.narrow),
      );
      const b = IconButtonThemeData(
        style: ButtonStyle(size: ButtonSize.large, iconButtonWidth: IconButtonWidth.wide),
      );

      expect(IconButtonThemeData.lerp(a, b, 0.0)?.style?.size, ButtonSize.small);
      expect(IconButtonThemeData.lerp(a, b, 0.4)?.style?.size, ButtonSize.small);
      expect(IconButtonThemeData.lerp(a, b, 0.5)?.style?.size, ButtonSize.large);
      expect(IconButtonThemeData.lerp(a, b, 1.0)?.style?.size, ButtonSize.large);
      expect(IconButtonThemeData.lerp(a, b, 0.4)?.style?.iconButtonWidth, IconButtonWidth.narrow);
      expect(IconButtonThemeData.lerp(a, b, 0.5)?.style?.iconButtonWidth, IconButtonWidth.wide);
    });

    test('debugFillProperties includes size and width', () {
      const data = IconButtonThemeData(
        style: ButtonStyle(size: ButtonSize.medium, iconButtonWidth: IconButtonWidth.wide),
      );
      final builder = DiagnosticPropertiesBuilder();
      data.debugFillProperties(builder);

      final List<String> descriptions = builder.properties
          .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
          .map((DiagnosticsNode node) => node.toString())
          .toList();

      expect(descriptions, contains(contains('size: medium')));
      expect(descriptions, contains(contains('iconButtonWidth: wide')));
    });
  });

  group('M3E IconButton barrel file import', () {
    testWidgets('material_3_expressive.dart import provides M3E IconButton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: const ButtonStyle(size: ButtonSize.medium),
          ),
        ),
      );

      expect(iconButtonMaterialSize(tester), const Size(56.0, 56.0));
      expect(tester.getSize(find.byType(IconButton)), const Size(56.0, 56.0));
    });
  });
}
