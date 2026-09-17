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
      filepath: 'app_bar/app_bar.1.dart',
      title: 'App bars',
      builder: (BuildContext context) => const app_bar_1.AppBarApp(),
    ),
    _Example(
      filepath: 'badge/badge.0.dart',
      title: 'Badges',
      builder: (BuildContext context) => const badge_0.BadgeExampleApp(),
    ),
    _Example(
      filepath: 'button_style/button_style.0.dart',
      title: 'Common buttons',
      builder: (BuildContext context) => const button_style_0.ButtonApp(),
    ),
    _Example(
      filepath: 'floating_action_button/floating_action_button.1.dart',
      title: 'Floating action buttons',
      builder: (BuildContext context) =>
          const floating_action_button_1.FloatingActionButtonExampleApp(),
    ),
    _Example(
      filepath: 'icon_button/icon_button.3.dart',
      title: 'Icon buttons',
      builder: (BuildContext context) =>
          const icon_button_3.IconButtonToggleApp(),
    ),
    _Example(
      filepath: 'segmented_button/segmented_button.0.dart',
      title: 'Segmented buttons',
      builder: (BuildContext context) =>
          const segmented_button_0.SegmentedButtonApp(),
    ),
    _Example(
      filepath: 'card/card.2.dart',
      title: 'Cards',
      builder: (BuildContext context) => const card_2.CardExamplesApp(),
    ),
    _Example(
      filepath: 'carousel/carousel.0.dart',
      title: 'Carousel',
      builder: (BuildContext context) => const carousel_0.CarouselExampleApp(),
    ),
    _Example(
      filepath: 'checkbox/checkbox.1.dart',
      title: 'Checkbox',
      builder: (BuildContext context) => const checkbox_1.CheckboxExampleApp(),
    ),
    _Example(
      filepath: 'action_chip/action_chip.0.dart',
      title: 'Assist chip',
      builder: (BuildContext context) => const action_chip_0.ChipApp(),
    ),
    _Example(
      filepath: 'choice_chip/choice_chip.0.dart',
      title: 'Single select filter chip',
      builder: (BuildContext context) => const choice_chip_0.ChipApp(),
    ),
    _Example(
      filepath: 'filter_chip/filter_chip.0.dart',
      title: 'Multiple select filter chip',
      builder: (BuildContext context) => const filter_chip_0.ChipApp(),
    ),
    _Example(
      filepath: 'input_chip/input_chip.0.dart',
      title: 'Input chip',
      builder: (BuildContext context) => const input_chip_0.ChipApp(),
    ),
    _Example(
      filepath: 'date_picker/show_date_picker.0.dart',
      title: 'Date pickers',
      builder: (BuildContext context) =>
          const show_date_picker_0.DatePickerApp(),
    ),
    _Example(
      filepath: 'time_picker/show_time_picker.0.dart',
      title: 'Time pickers',
      builder: (BuildContext context) =>
          const show_time_picker_0.ShowTimePickerApp(),
    ),
    _Example(
      filepath: 'dialog/alert_dialog.1.dart',
      title: 'Dialogs',
      builder: (BuildContext context) =>
          const alert_dialog_1.AlertDialogExampleApp(),
    ),
    _Example(
      filepath: 'divider/divider.1.dart',
      title: 'Divider',
      builder: (BuildContext context) => const divider_1.DividerExampleApp(),
    ),
    _Example(
      filepath: 'list_tile/list_tile.2.dart',
      title: 'Lists',
      builder: (BuildContext context) => const list_tile_2.ListTileApp(),
    ),
    _Example(
      filepath: 'progress_indicator/linear_progress_indicator.0.dart',
      title: 'Linear progress indicators',
      builder: (BuildContext context) =>
          const linear_progress_indicator_0.ProgressIndicatorExampleApp(),
    ),
    _Example(
      filepath: 'progress_indicator/circular_progress_indicator.0.dart',
      title: 'Circular progress indicators',
      builder: (BuildContext context) =>
          const circular_progress_indicator_0.ProgressIndicatorExampleApp(),
    ),
    _Example(
      filepath: 'dropdown_menu/dropdown_menu.1.dart',
      title: 'Menu',
      builder: (BuildContext context) =>
          const dropdown_menu_1.DropdownMenuApp(),
    ),
    _Example(
      filepath: 'navigation_bar/navigation_bar.1.dart',
      title: 'Navigation bar',
      builder: (BuildContext context) =>
          const navigation_bar_1.NavigationBarApp(),
    ),
    _Example(
      filepath: 'navigation_rail/navigation_rail.0.dart',
      title: 'Navigation rail',
      builder: (BuildContext context) =>
          const navigation_rail_0.NavigationRailExampleApp(),
    ),
    _Example(
      filepath: 'navigation_drawer/navigation_drawer.0.dart',
      title: 'Navigation drawer',
      builder: (BuildContext context) =>
          const navigation_drawer_0.NavigationDrawerApp(),
    ),
    _Example(
      filepath: 'radio/radio.1.dart',
      title: 'Radio button',
      builder: (BuildContext context) => const radio_1.RadioExampleApp(),
    ),
    _Example(
      filepath: 'search_anchor/search_anchor.0.dart',
      title: 'Search',
      builder: (BuildContext context) => const search_anchor_0.SearchBarApp(),
    ),
    _Example(
      filepath: 'bottom_sheet/show_modal_bottom_sheet.2.dart',
      title: 'Bottom sheets',
      builder: (BuildContext context) =>
          const show_modal_bottom_sheet_2.ModalBottomSheetApp(),
    ),
    _Example(
      filepath: 'slider/slider.0.dart',
      title: 'Sliders',
      builder: (BuildContext context) => const slider_0.SliderExampleApp(),
    ),
    _Example(
      filepath: 'range_slider/range_slider.0.dart',
      title: 'Range sliders',
      builder: (BuildContext context) =>
          const range_slider_0.RangeSliderExampleApp(),
    ),
    _Example(
      filepath: 'snack_bar/snack_bar.2.dart',
      title: 'Snackbar',
      builder: (BuildContext context) => const snack_bar_2.SnackBarExampleApp(),
    ),
    _Example(
      filepath: 'switch/switch.2.dart',
      title: 'Switch',
      builder: (BuildContext context) => const switch_2.SwitchApp(),
    ),
    _Example(
      filepath: 'tabs/tab_bar.0.dart',
      title: 'Tabs',
      builder: (BuildContext context) => const tab_bar_0.TabBarApp(),
    ),
    _Example(
      filepath: 'text_field/text_field.2.dart',
      title: 'Text fields',
      builder: (BuildContext context) =>
          const text_field_2.TextFieldExamplesApp(),
    ),
    _Example(
      filepath: 'tooltip/tooltip.0.dart',
      title: 'Tooltip',
      builder: (BuildContext context) => const tooltip_0.TooltipExampleApp(),
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
      title: Text(_example.title),
    );
  }
}

/// A self-contained Material example.
class _Example {
  const _Example({
    required this.filepath,
    required this.title,
    required this.builder,
  });

  final WidgetBuilder builder;
  final String filepath;
  final String title;

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
