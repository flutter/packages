// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';

import 'activity_indicator/cupertino_activity_indicator.0.dart'
    as cupertino_activity_indicator_0;
import 'activity_indicator/cupertino_linear_activity_indicator.0.dart'
    as cupertino_linear_activity_indicator_0;
import 'bottom_tab_bar/cupertino_tab_bar.0.dart' as cupertino_tab_bar_0;
import 'button/cupertino_button.0.dart' as cupertino_button_0;
import 'checkbox/cupertino_checkbox.0.dart' as cupertino_checkbox_0;
import 'context_menu/cupertino_context_menu.0.dart' as cupertino_context_menu_0;
import 'context_menu/cupertino_context_menu.1.dart' as cupertino_context_menu_1;
import 'date_picker/cupertino_date_picker.0.dart' as cupertino_date_picker_0;
import 'date_picker/cupertino_timer_picker.0.dart' as cupertino_timer_picker_0;
import 'dialog/cupertino_action_sheet.0.dart' as cupertino_action_sheet_0;
import 'dialog/cupertino_alert_dialog.0.dart' as cupertino_alert_dialog_0;
import 'dialog/cupertino_popup_surface.0.dart' as cupertino_popup_surface_0;
import 'expansion_tile/cupertino_expansion_tile.0.dart'
    as cupertino_expansion_tile_0;
import 'form_row/cupertino_form_row.0.dart' as cupertino_form_row_0;
import 'list_section/list_section_base.0.dart' as list_section_base_0;
import 'list_section/list_section_inset.0.dart' as list_section_inset_0;
import 'list_tile/cupertino_list_tile.0.dart' as cupertino_list_tile_0;
import 'magnifier/cupertino_magnifier.0.dart' as cupertino_magnifier_0;
import 'magnifier/cupertino_text_magnifier.0.dart'
    as cupertino_text_magnifier_0;
import 'magnifier/text_magnifier.0.dart' as text_magnifier_0;
import 'menu_anchor/menu_anchor.0.dart' as menu_anchor_0;
import 'menu_anchor/menu_anchor.1.dart' as menu_anchor_1;
import 'nav_bar/cupertino_navigation_bar.0.dart' as cupertino_navigation_bar_0;
import 'nav_bar/cupertino_navigation_bar.1.dart' as cupertino_navigation_bar_1;
import 'nav_bar/cupertino_navigation_bar.2.dart' as cupertino_navigation_bar_2;
import 'nav_bar/cupertino_sliver_nav_bar.0.dart' as cupertino_sliver_nav_bar_0;
import 'nav_bar/cupertino_sliver_nav_bar.1.dart' as cupertino_sliver_nav_bar_1;
import 'nav_bar/cupertino_sliver_nav_bar.2.dart' as cupertino_sliver_nav_bar_2;
import 'page_scaffold/cupertino_page_scaffold.0.dart'
    as cupertino_page_scaffold_0;
import 'picker/cupertino_picker.0.dart' as cupertino_picker_0;
import 'radio/cupertino_radio.0.dart' as cupertino_radio_0;
import 'radio/cupertino_radio.toggleable.0.dart'
    as cupertino_radio_toggleable_0;
import 'refresh/cupertino_sliver_refresh_control.0.dart'
    as cupertino_sliver_refresh_control_0;
import 'route/show_cupertino_dialog.0.dart' as show_cupertino_dialog_0;
import 'route/show_cupertino_modal_popup.0.dart'
    as show_cupertino_modal_popup_0;
import 'scrollbar/cupertino_scrollbar.0.dart' as cupertino_scrollbar_0;
import 'scrollbar/cupertino_scrollbar.1.dart' as cupertino_scrollbar_1;
import 'search_field/cupertino_search_field.0.dart' as cupertino_search_field_0;
import 'search_field/cupertino_search_field.1.dart' as cupertino_search_field_1;
import 'segmented_control/cupertino_segmented_control.0.dart'
    as cupertino_segmented_control_0;
import 'segmented_control/cupertino_sliding_segmented_control.0.dart'
    as cupertino_sliding_segmented_control_0;
import 'sheet/cupertino_sheet.0.dart' as cupertino_sheet_0;
import 'sheet/cupertino_sheet.1.dart' as cupertino_sheet_1;
import 'sheet/cupertino_sheet.2.dart' as cupertino_sheet_2;
import 'sheet/cupertino_sheet.3.dart' as cupertino_sheet_3;
import 'slider/cupertino_slider.0.dart' as cupertino_slider_0;
import 'switch/cupertino_switch.0.dart' as cupertino_switch_0;
import 'tab_scaffold/cupertino_tab_controller.0.dart'
    as cupertino_tab_controller_0;
import 'tab_scaffold/cupertino_tab_scaffold.0.dart' as cupertino_tab_scaffold_0;
import 'text_field/cupertino_text_field.0.dart' as cupertino_text_field_0;
import 'text_form_field_row/cupertino_text_form_field_row.1.dart'
    as cupertino_text_form_field_row_1;

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  ExampleApp({super.key});

  static const title = 'Cupertino Examples';

  final _examples = <_Example>[
    _Example(
      'activity_indicator/cupertino_activity_indicator.0.dart',
      (BuildContext context) =>
          const cupertino_activity_indicator_0.CupertinoIndicatorApp(),
    ),
    _Example(
      'activity_indicator/cupertino_linear_activity_indicator.0.dart',
      (BuildContext context) =>
          const cupertino_linear_activity_indicator_0.CupertinoLinearActivityIndicatorApp(),
    ),
    _Example(
      'bottom_tab_bar/cupertino_tab_bar.0.dart',
      (BuildContext context) => const cupertino_tab_bar_0.CupertinoTabBarApp(),
    ),
    _Example(
      'button/cupertino_button.0.dart',
      (BuildContext context) => const cupertino_button_0.CupertinoButtonApp(),
    ),
    _Example(
      'checkbox/cupertino_checkbox.0.dart',
      (BuildContext context) =>
          const cupertino_checkbox_0.CupertinoCheckboxApp(),
    ),
    _Example(
      'context_menu/cupertino_context_menu.0.dart',
      (BuildContext context) => const cupertino_context_menu_0.ContextMenuApp(),
    ),
    _Example(
      'context_menu/cupertino_context_menu.1.dart',
      (BuildContext context) => const cupertino_context_menu_1.ContextMenuApp(),
    ),
    _Example(
      'date_picker/cupertino_date_picker.0.dart',
      (BuildContext context) => const cupertino_date_picker_0.DatePickerApp(),
    ),
    _Example(
      'date_picker/cupertino_timer_picker.0.dart',
      (BuildContext context) => const cupertino_timer_picker_0.TimerPickerApp(),
    ),
    _Example(
      'dialog/cupertino_action_sheet.0.dart',
      (BuildContext context) => const cupertino_action_sheet_0.ActionSheetApp(),
    ),
    _Example(
      'dialog/cupertino_alert_dialog.0.dart',
      (BuildContext context) => const cupertino_alert_dialog_0.AlertDialogApp(),
    ),
    _Example(
      'dialog/cupertino_popup_surface.0.dart',
      (BuildContext context) =>
          const cupertino_popup_surface_0.PopupSurfaceApp(),
    ),
    _Example(
      'expansion_tile/cupertino_expansion_tile.0.dart',
      (BuildContext context) =>
          const cupertino_expansion_tile_0.CupertinoExpansionTileApp(),
    ),
    _Example(
      'form_row/cupertino_form_row.0.dart',
      (BuildContext context) =>
          const cupertino_form_row_0.CupertinoFormRowApp(),
    ),
    _Example(
      'list_section/list_section_base.0.dart',
      (BuildContext context) =>
          const list_section_base_0.CupertinoListSectionBaseApp(),
    ),
    _Example(
      'list_section/list_section_inset.0.dart',
      (BuildContext context) =>
          const list_section_inset_0.CupertinoListSectionInsetApp(),
    ),
    _Example(
      'list_tile/cupertino_list_tile.0.dart',
      (BuildContext context) =>
          const cupertino_list_tile_0.CupertinoListTileApp(),
    ),
    _Example(
      'magnifier/cupertino_magnifier.0.dart',
      (BuildContext context) =>
          const cupertino_magnifier_0.CupertinoMagnifierApp(),
    ),
    _Example(
      'magnifier/cupertino_text_magnifier.0.dart',
      (BuildContext context) =>
          const cupertino_text_magnifier_0.CupertinoTextMagnifierApp(),
    ),
    _Example(
      'magnifier/text_magnifier.0.dart',
      (BuildContext context) =>
          const text_magnifier_0.TextMagnifierExampleApp(text: 'Hello world!'),
    ),
    _Example(
      'menu_anchor/menu_anchor.0.dart',
      (BuildContext context) => const menu_anchor_0.CupertinoMenuAnchorApp(),
    ),
    _Example(
      'menu_anchor/menu_anchor.1.dart',
      (BuildContext context) => const menu_anchor_1.CupertinoMenuAnchorApp(),
    ),
    _Example(
      'nav_bar/cupertino_navigation_bar.0.dart',
      (BuildContext context) => const cupertino_navigation_bar_0.NavBarApp(),
    ),
    _Example(
      'nav_bar/cupertino_navigation_bar.1.dart',
      (BuildContext context) => const cupertino_navigation_bar_1.NavBarApp(),
    ),
    _Example(
      'nav_bar/cupertino_navigation_bar.2.dart',
      (BuildContext context) => const cupertino_navigation_bar_2.NavBarApp(),
    ),
    _Example(
      'nav_bar/cupertino_sliver_nav_bar.0.dart',
      (BuildContext context) =>
          const cupertino_sliver_nav_bar_0.SliverNavBarApp(),
    ),
    _Example(
      'nav_bar/cupertino_sliver_nav_bar.1.dart',
      (BuildContext context) =>
          const cupertino_sliver_nav_bar_1.SliverNavBarApp(),
    ),
    _Example(
      'nav_bar/cupertino_sliver_nav_bar.2.dart',
      (BuildContext context) =>
          const cupertino_sliver_nav_bar_2.SliverNavBarApp(),
    ),
    _Example(
      'page_scaffold/cupertino_page_scaffold.0.dart',
      (BuildContext context) =>
          const cupertino_page_scaffold_0.PageScaffoldApp(),
    ),
    _Example(
      'picker/cupertino_picker.0.dart',
      (BuildContext context) => const cupertino_picker_0.CupertinoPickerApp(),
    ),
    _Example(
      'radio/cupertino_radio.0.dart',
      (BuildContext context) => const cupertino_radio_0.CupertinoRadioApp(),
    ),
    _Example(
      'radio/cupertino_radio.toggleable.0.dart',
      (BuildContext context) =>
          const cupertino_radio_toggleable_0.CupertinoRadioApp(),
    ),
    _Example(
      'refresh/cupertino_sliver_refresh_control.0.dart',
      (BuildContext context) =>
          const cupertino_sliver_refresh_control_0.RefreshControlApp(),
    ),
    _Example(
      'route/show_cupertino_dialog.0.dart',
      (BuildContext context) =>
          const show_cupertino_dialog_0.CupertinoDialogApp(),
    ),
    _Example(
      'route/show_cupertino_modal_popup.0.dart',
      (BuildContext context) =>
          const show_cupertino_modal_popup_0.ModalPopupApp(),
    ),
    _Example(
      'scrollbar/cupertino_scrollbar.0.dart',
      (BuildContext context) => const cupertino_scrollbar_0.ScrollbarApp(),
    ),
    _Example(
      'scrollbar/cupertino_scrollbar.1.dart',
      (BuildContext context) => const cupertino_scrollbar_1.ScrollbarApp(),
    ),
    _Example(
      'search_field/cupertino_search_field.0.dart',
      (BuildContext context) =>
          const cupertino_search_field_0.SearchTextFieldApp(),
    ),
    _Example(
      'search_field/cupertino_search_field.1.dart',
      (BuildContext context) =>
          const cupertino_search_field_1.SearchTextFieldApp(),
    ),
    _Example(
      'segmented_control/cupertino_segmented_control.0.dart',
      (BuildContext context) =>
          const cupertino_segmented_control_0.SegmentedControlApp(),
    ),
    _Example(
      'segmented_control/cupertino_sliding_segmented_control.0.dart',
      (BuildContext context) =>
          const cupertino_sliding_segmented_control_0.SegmentedControlApp(),
    ),
    _Example(
      'sheet/cupertino_sheet.0.dart',
      (BuildContext context) => const cupertino_sheet_0.CupertinoSheetApp(),
    ),
    _Example(
      'sheet/cupertino_sheet.1.dart',
      (BuildContext context) => const cupertino_sheet_1.CupertinoSheetApp(),
    ),
    _Example(
      'sheet/cupertino_sheet.2.dart',
      (BuildContext context) =>
          const cupertino_sheet_2.RestorableSheetExampleApp(),
    ),
    _Example(
      'sheet/cupertino_sheet.3.dart',
      (BuildContext context) => const cupertino_sheet_3.CupertinoSheetApp(),
    ),
    _Example(
      'slider/cupertino_slider.0.dart',
      (BuildContext context) => const cupertino_slider_0.CupertinoSliderApp(),
    ),
    _Example(
      'switch/cupertino_switch.0.dart',
      (BuildContext context) => const cupertino_switch_0.CupertinoSwitchApp(),
    ),
    _Example(
      'tab_scaffold/cupertino_tab_controller.0.dart',
      (BuildContext context) =>
          const cupertino_tab_controller_0.TabControllerApp(),
    ),
    _Example(
      'tab_scaffold/cupertino_tab_scaffold.0.dart',
      (BuildContext context) => const cupertino_tab_scaffold_0.TabScaffoldApp(),
    ),
    _Example(
      'text_field/cupertino_text_field.0.dart',
      (BuildContext context) =>
          const cupertino_text_field_0.CupertinoTextFieldApp(),
    ),
    _Example(
      'text_form_field_row/cupertino_text_form_field_row.1.dart',
      (BuildContext context) =>
          const cupertino_text_form_field_row_1.FormSectionApp(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: title,
      home: _ExampleHome(examples: _examples),
      routes: <String, WidgetBuilder>{
        for (_Example example in _examples) example.url: example.builder,
      },
    );
  }
}

class _ExampleHome extends StatelessWidget {
  const _ExampleHome({required this.examples});

  final List<_Example> examples;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(ExampleApp.title),
      ),
      child: SafeArea(
        child: ListView(
          children: examples
              .map((_Example example) => _ExampleListItem(example: example))
              .toList(),
        ),
      ),
    );
  }
}

/// One item that opens its example when tapped.
class _ExampleListItem extends StatelessWidget {
  const _ExampleListItem({required this.example});

  final _Example example;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      onTap: () {
        Navigator.of(context).pushNamed(example.url);
      },
      title: Text(example.filepath),
    );
  }
}

/// A self-contained Cupertino example.
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
    assert(filenameSegments.length >= 3);
    final number = filenameSegments[filenameSegments.length - 2];

    return '/$directory/$filename/$number';
  }
}
