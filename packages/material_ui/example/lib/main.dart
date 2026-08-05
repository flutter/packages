// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

import 'app_bar/app_bar.1.dart' as app_bar_1;
import 'badge/badge.0.dart' as badge_0;
import 'button_style/button_style.0.dart' as button_style_0;
import 'floating_action_button/floating_action_button.1.dart'
    as floating_action_button_1;
import 'icon_button/icon_button.3.dart' as icon_button_3;
import 'segmented_button/segmented_button.0.dart' as segmented_button_0;
import 'card/card.2.dart' as card_2;
import 'carousel/carousel.0.dart' as carousel_0;
import 'checkbox/checkbox.1.dart' as checkbox_1;
import 'action_chip/action_chip.0.dart' as action_chip_0;
import 'choice_chip/choice_chip.0.dart' as choice_chip_0;
import 'filter_chip/filter_chip.0.dart' as filter_chip_0;
import 'input_chip/input_chip.0.dart' as input_chip_0;
import 'date_picker/show_date_picker.0.dart' as show_date_picker_0;
import 'time_picker/show_time_picker.0.dart' as show_time_picker_0;
import 'dialog/alert_dialog.1.dart' as alert_dialog_1;
import 'divider/divider.1.dart' as divider_1;
import 'list_tile/list_tile.2.dart' as list_tile_2;
import 'progress_indicator/linear_progress_indicator.0.dart'
    as linear_progress_indicator_0;
import 'progress_indicator/circular_progress_indicator.0.dart'
    as circular_progress_indicator_0;
import 'dropdown_menu/dropdown_menu.1.dart' as dropdown_menu_1;
import 'navigation_bar/navigation_bar.1.dart' as navigation_bar_1;
import 'navigation_rail/navigation_rail.0.dart' as navigation_rail_0;
import 'navigation_drawer/navigation_drawer.0.dart' as navigation_drawer_0;
import 'radio/radio.1.dart' as radio_1;
import 'search_anchor/search_anchor.0.dart' as search_anchor_0;
import 'bottom_sheet/show_modal_bottom_sheet.2.dart'
    as show_modal_bottom_sheet_2;
import 'slider/slider.0.dart' as slider_0;
import 'range_slider/range_slider.0.dart' as range_slider_0;
import 'snack_bar/snack_bar.2.dart' as snack_bar_2;
import 'switch/switch.2.dart' as switch_2;
import 'tabs/tab_bar.0.dart' as tab_bar_0;
import 'text_field/text_field.2.dart' as text_field_2;
import 'tooltip/tooltip.0.dart' as tooltip_0;

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  ExampleApp({super.key});

  static const title = 'Material Examples';

  final _examples = <_Example>[
    _Example(
      'app_bar/app_bar.1.dart',
      (BuildContext context) => const app_bar_1.AppBarApp(),
    ),
    _Example(
      'badge/badge.0.dart',
      (BuildContext context) => const badge_0.BadgeExampleApp(),
    ),
    _Example(
      'button_style/button_style.0.dart',
      (BuildContext context) => const button_style_0.ButtonApp(),
    ),
    _Example(
      'floating_action_button/floating_action_button.1.dart',
      (BuildContext context) =>
          const floating_action_button_1.FloatingActionButtonExampleApp(),
    ),
    _Example(
      'icon_button/icon_button.3.dart',
      (BuildContext context) => const icon_button_3.IconButtonToggleApp(),
    ),
    _Example(
      'segmented_button/segmented_button.0.dart',
      (BuildContext context) => const segmented_button_0.SegmentedButtonApp(),
    ),
    _Example(
      'card/card.2.dart',
      (BuildContext context) => const card_2.CardExamplesApp(),
    ),
    _Example(
      'carousel/carousel.0.dart',
      (BuildContext context) => const carousel_0.CarouselExampleApp(),
    ),
    _Example(
      'checkbox/checkbox.1.dart',
      (BuildContext context) => const checkbox_1.CheckboxExampleApp(),
    ),
    _Example(
      'action_chip/action_chip.0.dart',
      (BuildContext context) => const action_chip_0.ChipApp(),
    ),
    _Example(
      'choice_chip/choice_chip.0.dart',
      (BuildContext context) => const choice_chip_0.ChipApp(),
    ),
    _Example(
      'filter_chip/filter_chip.0.dart',
      (BuildContext context) => const filter_chip_0.ChipApp(),
    ),
    _Example(
      'input_chip/input_chip.0.dart',
      (BuildContext context) => const input_chip_0.ChipApp(),
    ),
    _Example(
      'date_picker/show_date_picker.0.dart',
      (BuildContext context) => const show_date_picker_0.DatePickerApp(),
    ),
    _Example(
      'time_picker/show_time_picker.0.dart',
      (BuildContext context) => const show_time_picker_0.ShowTimePickerApp(),
    ),
    _Example(
      'dialog/alert_dialog.1.dart',
      (BuildContext context) => const alert_dialog_1.AlertDialogExampleApp(),
    ),
    _Example(
      'divider/divider.1.dart',
      (BuildContext context) => const divider_1.DividerExampleApp(),
    ),
    _Example(
      'list_tile/list_tile.2.dart',
      (BuildContext context) => const list_tile_2.ListTileApp(),
    ),
    _Example(
      'progress_indicator/linear_progress_indicator.0.dart',
      (BuildContext context) =>
          const linear_progress_indicator_0.ProgressIndicatorExampleApp(),
    ),
    _Example(
      'progress_indicator/circular_progress_indicator.0.dart',
      (BuildContext context) =>
          const circular_progress_indicator_0.ProgressIndicatorExampleApp(),
    ),
    _Example(
      'dropdown_menu/dropdown_menu.1.dart',
      (BuildContext context) => const dropdown_menu_1.DropdownMenuApp(),
    ),
    _Example(
      'navigation_bar/navigation_bar.1.dart',
      (BuildContext context) => const navigation_bar_1.NavigationBarApp(),
    ),
    _Example(
      'navigation_rail/navigation_rail.0.dart',
      (BuildContext context) =>
          const navigation_rail_0.NavigationRailExampleApp(),
    ),
    _Example(
      'navigation_drawer/navigation_drawer.0.dart',
      (BuildContext context) => const navigation_drawer_0.NavigationDrawerApp(),
    ),
    _Example(
      'radio/radio.1.dart',
      (BuildContext context) => const radio_1.RadioExampleApp(),
    ),
    _Example(
      'search_anchor/search_anchor.0.dart',
      (BuildContext context) => const search_anchor_0.SearchBarApp(),
    ),
    _Example(
      'bottom_sheet/show_modal_bottom_sheet.2.dart',
      (BuildContext context) =>
          const show_modal_bottom_sheet_2.ModalBottomSheetApp(),
    ),
    _Example(
      'slider/slider.0.dart',
      (BuildContext context) => const slider_0.SliderExampleApp(),
    ),
    _Example(
      'range_slider/range_slider.0.dart',
      (BuildContext context) => const range_slider_0.RangeSliderExampleApp(),
    ),
    _Example(
      'snack_bar/snack_bar.2.dart',
      (BuildContext context) => const snack_bar_2.SnackBarExampleApp(),
    ),
    _Example(
      'switch/switch.2.dart',
      (BuildContext context) => const switch_2.SwitchApp(),
    ),
    _Example(
      'tabs/tab_bar.0.dart',
      (BuildContext context) => const tab_bar_0.TabBarApp(),
    ),
    _Example(
      'text_field/text_field.2.dart',
      (BuildContext context) => const text_field_2.TextFieldExamplesApp(),
    ),
    _Example(
      'tooltip/tooltip.0.dart',
      (BuildContext context) => const tooltip_0.TooltipExampleApp(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: _ExampleHome(examples: _examples),
      routes: <String, WidgetBuilder>{
        for (_Example example in _examples) example.url: example.builder,
      },
    );
  }
}

class _ExampleHome extends StatelessWidget {
  const _ExampleHome({required this._examples});

  final List<_Example> _examples;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ExampleApp.title)),
      body: Center(
        child: ListView(
          children: _examples
              .map((_Example example) => _ExampleListItem(example: example))
              .toList(),
        ),
      ),
    );
  }
}

/// One item that opens its example when tapped.
class _ExampleListItem extends StatelessWidget {
  const _ExampleListItem({required this._example});

  final _Example _example;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(_example.url);
      },
      title: Text(_example.filepath),
    );
  }
}

/// A self-contained Material example.
class _Example {
  const _Example(this.filepath, this.builder);

  final String filepath;
  final WidgetBuilder builder;

  String get url {
    final segments = filepath.split('/');
    assert(segments.length == 2);
    final directory = segments.first;
    final filename = segments.last;

    final filenameSegments = filename.split('.');
    assert(filenameSegments.length == 3);
    final number = filenameSegments[1];

    return '/$directory/$filename/$number';
  }
}
