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

const Map<String, Type> _examples = <String, Type>{
  'App bars': app_bar_1.AppBarApp,
  'Badges': badge_0.BadgeExampleApp,
  'Common buttons': button_style_0.ButtonApp,
  'Floating action buttons':
      floating_action_button_1.FloatingActionButtonExampleApp,
  'Icon buttons': icon_button_3.IconButtonToggleApp,
  'Segmented buttons': segmented_button_0.SegmentedButtonApp,
  'Cards': card_2.CardExamplesApp,
  'Carousel': carousel_0.CarouselExampleApp,
  'Checkbox': checkbox_1.CheckboxExampleApp,
  'Assist chip': action_chip_0.ChipApp,
  'Single select filter chip': choice_chip_0.ChipApp,
  'Multiple select filter chip': filter_chip_0.ChipApp,
  'Input chip': input_chip_0.ChipApp,
  'Date pickers': show_date_picker_0.DatePickerApp,
  'Time pickers': show_time_picker_0.ShowTimePickerApp,
  'Dialogs': alert_dialog_1.AlertDialogExampleApp,
  'Divider': divider_1.DividerExampleApp,
  'Lists': list_tile_2.ListTileApp,
  'Linear progress indicators':
      linear_progress_indicator_0.ProgressIndicatorExampleApp,
  'Circular progress indicators':
      circular_progress_indicator_0.ProgressIndicatorExampleApp,
  'Menu': dropdown_menu_1.DropdownMenuApp,
  'Navigation bar': navigation_bar_1.NavigationBarApp,
  'Navigation rail': navigation_rail_0.NavigationRailExampleApp,
  'Navigation drawer': navigation_drawer_0.NavigationDrawerApp,
  'Radio button': radio_1.RadioExampleApp,
  'Search': search_anchor_0.SearchBarApp,
  'Bottom sheets': show_modal_bottom_sheet_2.ModalBottomSheetApp,
  'Sliders': slider_0.SliderExampleApp,
  'Range sliders': range_slider_0.RangeSliderExampleApp,
  'Snackbar': snack_bar_2.SnackBarExampleApp,
  'Switch': switch_2.SwitchApp,
  'Tabs': tab_bar_0.TabBarApp,
  'Text fields': text_field_2.TextFieldExamplesApp,
  'Tooltip': tooltip_0.TooltipExampleApp,
};

void main() {
  setUpAll(() {
    // This is needed for the carousel.1 example, which uses a NetworkImage.
    HttpOverrides.global = null;
  });
  for (final MapEntry<String, Type> entry in _examples.entries) {
    testWidgets(entry.key, (WidgetTester tester) async {
      await tester.pumpWidget(ExampleApp());

      final Finder finder = find.text(entry.key);
      await tester.scrollUntilVisible(finder, 200.0);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(entry.value), findsOneWidget);
    });
  }
}
