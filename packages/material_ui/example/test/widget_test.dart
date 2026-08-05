// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui_examples/main.dart';

import 'package:material_ui_examples/app_bar/app_bar.1.dart' as app_bar_1;
import 'package:material_ui_examples/badge/badge.0.dart' as badge_0;
import 'package:material_ui_examples/button_style/button_style.0.dart'
    as button_style_0;
import 'package:material_ui_examples/floating_action_button/floating_action_button.1.dart'
    as floating_action_button_1;
import 'package:material_ui_examples/icon_button/icon_button.3.dart'
    as icon_button_3;
import 'package:material_ui_examples/segmented_button/segmented_button.0.dart'
    as segmented_button_0;
import 'package:material_ui_examples/card/card.2.dart' as card_2;
import 'package:material_ui_examples/carousel/carousel.0.dart' as carousel_0;
import 'package:material_ui_examples/checkbox/checkbox.1.dart' as checkbox_1;
import 'package:material_ui_examples/action_chip/action_chip.0.dart'
    as action_chip_0;
import 'package:material_ui_examples/choice_chip/choice_chip.0.dart'
    as choice_chip_0;
import 'package:material_ui_examples/filter_chip/filter_chip.0.dart'
    as filter_chip_0;
import 'package:material_ui_examples/input_chip/input_chip.0.dart'
    as input_chip_0;
import 'package:material_ui_examples/date_picker/show_date_picker.0.dart'
    as show_date_picker_0;
import 'package:material_ui_examples/time_picker/show_time_picker.0.dart'
    as show_time_picker_0;
import 'package:material_ui_examples/dialog/alert_dialog.1.dart'
    as alert_dialog_1;
import 'package:material_ui_examples/divider/divider.1.dart' as divider_1;
import 'package:material_ui_examples/list_tile/list_tile.2.dart' as list_tile_2;
import 'package:material_ui_examples/progress_indicator/linear_progress_indicator.0.dart'
    as linear_progress_indicator_0;
import 'package:material_ui_examples/progress_indicator/circular_progress_indicator.0.dart'
    as circular_progress_indicator_0;
import 'package:material_ui_examples/dropdown_menu/dropdown_menu.1.dart'
    as dropdown_menu_1;
import 'package:material_ui_examples/navigation_bar/navigation_bar.1.dart'
    as navigation_bar_1;
import 'package:material_ui_examples/navigation_rail/navigation_rail.0.dart'
    as navigation_rail_0;
import 'package:material_ui_examples/navigation_drawer/navigation_drawer.0.dart'
    as navigation_drawer_0;
import 'package:material_ui_examples/radio/radio.1.dart' as radio_1;
import 'package:material_ui_examples/search_anchor/search_anchor.0.dart'
    as search_anchor_0;
import 'package:material_ui_examples/bottom_sheet/show_modal_bottom_sheet.2.dart'
    as show_modal_bottom_sheet_2;
import 'package:material_ui_examples/slider/slider.0.dart' as slider_0;
import 'package:material_ui_examples/range_slider/range_slider.0.dart'
    as range_slider_0;
import 'package:material_ui_examples/snack_bar/snack_bar.2.dart' as snack_bar_2;
import 'package:material_ui_examples/switch/switch.2.dart' as switch_2;
import 'package:material_ui_examples/tabs/tab_bar.0.dart' as tab_bar_0;
import 'package:material_ui_examples/text_field/text_field.2.dart'
    as text_field_2;
import 'package:material_ui_examples/tooltip/tooltip.0.dart' as tooltip_0;

void main() {
  testWidgets('app_bar.1', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('app_bar/app_bar.1.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(app_bar_1.AppBarApp), findsOneWidget);
  });

  testWidgets('badge.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('badge/badge.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(badge_0.BadgeExampleApp), findsOneWidget);
  });

  testWidgets('button_style.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('button_style/button_style.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(button_style_0.ButtonApp), findsOneWidget);
  });

  testWidgets('floating_action_button.1', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text(
      'floating_action_button/floating_action_button.1.dart',
    );
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.byType(floating_action_button_1.FloatingActionButtonExampleApp),
      findsOneWidget,
    );
  });

  testWidgets('icon_button.3', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('icon_button/icon_button.3.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(icon_button_3.IconButtonToggleApp), findsOneWidget);
  });

  testWidgets('segmented_button.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('segmented_button/segmented_button.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(segmented_button_0.SegmentedButtonApp), findsOneWidget);
  });

  testWidgets('card.2', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('card/card.2.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(card_2.CardExamplesApp), findsOneWidget);
  });

  testWidgets('carousel.0', (WidgetTester tester) async {
    HttpOverrides.global = null;

    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('carousel/carousel.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(carousel_0.CarouselExampleApp), findsOneWidget);
  });

  testWidgets('checkbox.1', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('checkbox/checkbox.1.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(checkbox_1.CheckboxExampleApp), findsOneWidget);
  });

  testWidgets('action_chip.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('action_chip/action_chip.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(action_chip_0.ChipApp), findsOneWidget);
  });

  testWidgets('choice_chip.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('choice_chip/choice_chip.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(choice_chip_0.ChipApp), findsOneWidget);
  });

  testWidgets('filter_chip.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('filter_chip/filter_chip.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(filter_chip_0.ChipApp), findsOneWidget);
  });

  testWidgets('input_chip.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('input_chip/input_chip.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(input_chip_0.ChipApp), findsOneWidget);
  });

  testWidgets('show_date_picker.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('date_picker/show_date_picker.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(show_date_picker_0.DatePickerApp), findsOneWidget);
  });

  testWidgets('show_time_picker.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('time_picker/show_time_picker.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(show_time_picker_0.ShowTimePickerApp), findsOneWidget);
  });

  testWidgets('alert_dialog.1', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('dialog/alert_dialog.1.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(alert_dialog_1.AlertDialogExampleApp), findsOneWidget);
  });

  testWidgets('divider.1', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('divider/divider.1.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(divider_1.DividerExampleApp), findsOneWidget);
  });

  testWidgets('list_tile.2', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('list_tile/list_tile.2.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(list_tile_2.ListTileApp), findsOneWidget);
  });

  testWidgets('linear_progress_indicator.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text(
      'progress_indicator/linear_progress_indicator.0.dart',
    );
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.byType(linear_progress_indicator_0.ProgressIndicatorExampleApp),
      findsOneWidget,
    );
  });

  testWidgets('circular_progress_indicator.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text(
      'progress_indicator/circular_progress_indicator.0.dart',
    );
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.byType(circular_progress_indicator_0.ProgressIndicatorExampleApp),
      findsOneWidget,
    );
  });

  testWidgets('dropdown_menu.1', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('dropdown_menu/dropdown_menu.1.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(dropdown_menu_1.DropdownMenuApp), findsOneWidget);
  });

  testWidgets('navigation_bar.1', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('navigation_bar/navigation_bar.1.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(navigation_bar_1.NavigationBarApp), findsOneWidget);
  });

  testWidgets('navigation_rail.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('navigation_rail/navigation_rail.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.byType(navigation_rail_0.NavigationRailExampleApp),
      findsOneWidget,
    );
  });

  testWidgets('navigation_drawer.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text(
      'navigation_drawer/navigation_drawer.0.dart',
    );
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.byType(navigation_drawer_0.NavigationDrawerApp),
      findsOneWidget,
    );
  });

  testWidgets('radio.1', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('radio/radio.1.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(radio_1.RadioExampleApp), findsOneWidget);
  });

  testWidgets('search_anchor.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('search_anchor/search_anchor.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(search_anchor_0.SearchBarApp), findsOneWidget);
  });

  testWidgets('show_modal_bottom_sheet.2', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text(
      'bottom_sheet/show_modal_bottom_sheet.2.dart',
    );
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.byType(show_modal_bottom_sheet_2.ModalBottomSheetApp),
      findsOneWidget,
    );
  });

  testWidgets('slider.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('slider/slider.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(slider_0.SliderExampleApp), findsOneWidget);
  });

  testWidgets('range_slider.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('range_slider/range_slider.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(range_slider_0.RangeSliderExampleApp), findsOneWidget);
  });

  testWidgets('snack_bar.2', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('snack_bar/snack_bar.2.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(snack_bar_2.SnackBarExampleApp), findsOneWidget);
  });

  testWidgets('switch.2', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('switch/switch.2.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(switch_2.SwitchApp), findsOneWidget);
  });

  testWidgets('tab_bar.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('tabs/tab_bar.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(tab_bar_0.TabBarApp), findsOneWidget);
  });

  testWidgets('text_field.2', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('text_field/text_field.2.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(text_field_2.TextFieldExamplesApp), findsOneWidget);
  });

  testWidgets('tooltip.0', (WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp());

    final Finder finder = find.text('tooltip/tooltip.0.dart');
    await tester.scrollUntilVisible(finder, 200.0);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(tooltip_0.TooltipExampleApp), findsOneWidget);
  });
}
