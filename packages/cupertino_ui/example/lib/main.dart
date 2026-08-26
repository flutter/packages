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
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  static const title = 'Cupertino Examples';

  static final _examples = <_Example>[
    _Example(
      filepath: 'activity_indicator/cupertino_activity_indicator.0.dart',
      title: 'CupertinoActivityIndicator',
      builder: (BuildContext context) =>
          const cupertino_activity_indicator_0.CupertinoIndicatorApp(),
    ),
    _Example(
      filepath: 'activity_indicator/cupertino_linear_activity_indicator.0.dart',
      title: 'CupertinoLinearActivityIndicator',
      builder: (BuildContext context) =>
          const cupertino_linear_activity_indicator_0.CupertinoLinearActivityIndicatorApp(),
    ),
    _Example(
      filepath: 'bottom_tab_bar/cupertino_tab_bar.0.dart',
      title: 'CupertinoTabBar',
      builder: (BuildContext context) =>
          const cupertino_tab_bar_0.CupertinoTabBarApp(),
    ),
    _Example(
      filepath: 'button/cupertino_button.0.dart',
      title: 'CupertinoButton',
      builder: (BuildContext context) =>
          const cupertino_button_0.CupertinoButtonApp(),
    ),
    _Example(
      filepath: 'checkbox/cupertino_checkbox.0.dart',
      title: 'CupertinoCheckbox',
      builder: (BuildContext context) =>
          const cupertino_checkbox_0.CupertinoCheckboxApp(),
    ),
    _Example(
      filepath: 'context_menu/cupertino_context_menu.0.dart',
      title: 'CupertinoContextMenu',
      builder: (BuildContext context) =>
          const cupertino_context_menu_0.ContextMenuApp(),
    ),
    _Example(
      filepath: 'context_menu/cupertino_context_menu.1.dart',
      title: 'CupertinoContextMenu.builder',
      builder: (BuildContext context) =>
          const cupertino_context_menu_1.ContextMenuApp(),
    ),
    _Example(
      filepath: 'date_picker/cupertino_date_picker.0.dart',
      title: 'CupertinoDatePicker',
      builder: (BuildContext context) =>
          const cupertino_date_picker_0.DatePickerApp(),
    ),
    _Example(
      filepath: 'date_picker/cupertino_timer_picker.0.dart',
      title: 'CupertinoTimerPicker',
      builder: (BuildContext context) =>
          const cupertino_timer_picker_0.TimerPickerApp(),
    ),
    _Example(
      filepath: 'dialog/cupertino_action_sheet.0.dart',
      title: 'CupertinoActionSheet',
      builder: (BuildContext context) =>
          const cupertino_action_sheet_0.ActionSheetApp(),
    ),
    _Example(
      filepath: 'dialog/cupertino_alert_dialog.0.dart',
      title: 'CupertinoAlertDialog',
      builder: (BuildContext context) =>
          const cupertino_alert_dialog_0.AlertDialogApp(),
    ),
    _Example(
      filepath: 'dialog/cupertino_popup_surface.0.dart',
      title: 'CupertinoPopupSurface',
      builder: (BuildContext context) =>
          const cupertino_popup_surface_0.PopupSurfaceApp(),
    ),
    _Example(
      filepath: 'expansion_tile/cupertino_expansion_tile.0.dart',
      title: 'CupertinoExpansionTile',
      builder: (BuildContext context) =>
          const cupertino_expansion_tile_0.CupertinoExpansionTileApp(),
    ),
    _Example(
      filepath: 'form_row/cupertino_form_row.0.dart',
      title: 'CupertinoFormRow',
      builder: (BuildContext context) =>
          const cupertino_form_row_0.CupertinoFormRowApp(),
    ),
    _Example(
      filepath: 'list_section/list_section_base.0.dart',
      title: 'CupertinoListSection',
      builder: (BuildContext context) =>
          const list_section_base_0.CupertinoListSectionBaseApp(),
    ),
    _Example(
      filepath: 'list_section/list_section_inset.0.dart',
      title: 'CupertinoListSection.insetGrouped',
      builder: (BuildContext context) =>
          const list_section_inset_0.CupertinoListSectionInsetApp(),
    ),
    _Example(
      filepath: 'list_tile/cupertino_list_tile.0.dart',
      title: 'CupertinoListTile',
      builder: (BuildContext context) =>
          const cupertino_list_tile_0.CupertinoListTileApp(),
    ),
    _Example(
      filepath: 'magnifier/cupertino_magnifier.0.dart',
      title: 'CupertinoMagnifier',
      builder: (BuildContext context) =>
          const cupertino_magnifier_0.CupertinoMagnifierApp(),
    ),
    _Example(
      filepath: 'magnifier/cupertino_text_magnifier.0.dart',
      title: 'CupertinoTextMagnifier',
      builder: (BuildContext context) =>
          const cupertino_text_magnifier_0.CupertinoTextMagnifierApp(),
    ),
    _Example(
      filepath: 'magnifier/text_magnifier.0.dart',
      title: 'TextMagnifier',
      builder: (BuildContext context) =>
          const text_magnifier_0.TextMagnifierExampleApp(text: 'Hello world!'),
    ),
    _Example(
      filepath: 'menu_anchor/menu_anchor.0.dart',
      title: 'CupertinoMenuAnchor',
      builder: (BuildContext context) =>
          const menu_anchor_0.CupertinoMenuAnchorApp(),
    ),
    _Example(
      filepath: 'menu_anchor/menu_anchor.1.dart',
      title: 'CupertinoMenuAnchor with multiple items',
      builder: (BuildContext context) =>
          const menu_anchor_1.CupertinoMenuAnchorApp(),
    ),
    _Example(
      filepath: 'nav_bar/cupertino_navigation_bar.0.dart',
      title: 'CupertinoNavigationBar',
      builder: (BuildContext context) =>
          const cupertino_navigation_bar_0.NavBarApp(),
    ),
    _Example(
      filepath: 'nav_bar/cupertino_navigation_bar.1.dart',
      title: 'CupertinoNavigationBar with search field',
      builder: (BuildContext context) =>
          const cupertino_navigation_bar_1.NavBarApp(),
    ),
    _Example(
      filepath: 'nav_bar/cupertino_navigation_bar.2.dart',
      title: 'CupertinoNavigationBar.large',
      builder: (BuildContext context) =>
          const cupertino_navigation_bar_2.NavBarApp(),
    ),
    _Example(
      filepath: 'nav_bar/cupertino_sliver_nav_bar.0.dart',
      title: 'CupertinoSliverNavigationBar',
      builder: (BuildContext context) =>
          const cupertino_sliver_nav_bar_0.SliverNavBarApp(),
    ),
    _Example(
      filepath: 'nav_bar/cupertino_sliver_nav_bar.1.dart',
      title: 'CupertinoSliverNavigationBar.search',
      builder: (BuildContext context) =>
          const cupertino_sliver_nav_bar_1.SliverNavBarApp(),
    ),
    _Example(
      filepath: 'nav_bar/cupertino_sliver_nav_bar.2.dart',
      title: 'CupertinoSliverNavigationBar with bottom widget',
      builder: (BuildContext context) =>
          const cupertino_sliver_nav_bar_2.SliverNavBarApp(),
    ),
    _Example(
      filepath: 'page_scaffold/cupertino_page_scaffold.0.dart',
      title: 'CupertinoPageScaffold',
      builder: (BuildContext context) =>
          const cupertino_page_scaffold_0.PageScaffoldApp(),
    ),
    _Example(
      filepath: 'picker/cupertino_picker.0.dart',
      title: 'CupertinoPicker',
      builder: (BuildContext context) =>
          const cupertino_picker_0.CupertinoPickerApp(),
    ),
    _Example(
      filepath: 'radio/cupertino_radio.0.dart',
      title: 'CupertinoRadio',
      builder: (BuildContext context) =>
          const cupertino_radio_0.CupertinoRadioApp(),
    ),
    _Example(
      filepath: 'radio/cupertino_radio.toggleable.0.dart',
      title: 'CupertinoRadio.toggleable',
      builder: (BuildContext context) =>
          const cupertino_radio_toggleable_0.CupertinoRadioApp(),
    ),
    _Example(
      filepath: 'refresh/cupertino_sliver_refresh_control.0.dart',
      title: 'CupertinoSliverRefreshControl',
      builder: (BuildContext context) =>
          const cupertino_sliver_refresh_control_0.RefreshControlApp(),
    ),
    _Example(
      filepath: 'route/show_cupertino_dialog.0.dart',
      title: 'showCupertinoDialog',
      builder: (BuildContext context) =>
          const show_cupertino_dialog_0.CupertinoDialogApp(),
    ),
    _Example(
      filepath: 'route/show_cupertino_modal_popup.0.dart',
      title: 'showCupertinoModalPopup',
      builder: (BuildContext context) =>
          const show_cupertino_modal_popup_0.ModalPopupApp(),
    ),
    _Example(
      filepath: 'scrollbar/cupertino_scrollbar.0.dart',
      title: 'CupertinoScrollbar',
      builder: (BuildContext context) =>
          const cupertino_scrollbar_0.ScrollbarApp(),
    ),
    _Example(
      filepath: 'scrollbar/cupertino_scrollbar.1.dart',
      title: 'CupertinoScrollbar with ScrollController',
      builder: (BuildContext context) =>
          const cupertino_scrollbar_1.ScrollbarApp(),
    ),
    _Example(
      filepath: 'search_field/cupertino_search_field.0.dart',
      title: 'CupertinoSearchTextField',
      builder: (BuildContext context) =>
          const cupertino_search_field_0.SearchTextFieldApp(),
    ),
    _Example(
      filepath: 'search_field/cupertino_search_field.1.dart',
      title: 'CupertinoSearchTextField with callbacks',
      builder: (BuildContext context) =>
          const cupertino_search_field_1.SearchTextFieldApp(),
    ),
    _Example(
      filepath: 'segmented_control/cupertino_segmented_control.0.dart',
      title: 'CupertinoSegmentedControl',
      builder: (BuildContext context) =>
          const cupertino_segmented_control_0.SegmentedControlApp(),
    ),
    _Example(
      filepath: 'segmented_control/cupertino_sliding_segmented_control.0.dart',
      title: 'CupertinoSlidingSegmentedControl',
      builder: (BuildContext context) =>
          const cupertino_sliding_segmented_control_0.SegmentedControlApp(),
    ),
    _Example(
      filepath: 'sheet/cupertino_sheet.0.dart',
      title: 'CupertinoSheetRoute',
      builder: (BuildContext context) =>
          const cupertino_sheet_0.CupertinoSheetApp(),
    ),
    _Example(
      filepath: 'sheet/cupertino_sheet.1.dart',
      title: 'showCupertinoSheet',
      builder: (BuildContext context) =>
          const cupertino_sheet_1.CupertinoSheetApp(),
    ),
    _Example(
      filepath: 'sheet/cupertino_sheet.2.dart',
      title: 'CupertinoSheetRoute with restorable state',
      builder: (BuildContext context) =>
          const cupertino_sheet_2.RestorableSheetExampleApp(),
    ),
    _Example(
      filepath: 'sheet/cupertino_sheet.3.dart',
      title: 'CupertinoSheetRoute with ScrollController',
      builder: (BuildContext context) =>
          const cupertino_sheet_3.CupertinoSheetApp(),
    ),
    _Example(
      filepath: 'slider/cupertino_slider.0.dart',
      title: 'CupertinoSlider',
      builder: (BuildContext context) =>
          const cupertino_slider_0.CupertinoSliderApp(),
    ),
    _Example(
      filepath: 'switch/cupertino_switch.0.dart',
      title: 'CupertinoSwitch',
      builder: (BuildContext context) =>
          const cupertino_switch_0.CupertinoSwitchApp(),
    ),
    _Example(
      filepath: 'tab_scaffold/cupertino_tab_controller.0.dart',
      title: 'CupertinoTabController',
      builder: (BuildContext context) =>
          const cupertino_tab_controller_0.TabControllerApp(),
    ),
    _Example(
      filepath: 'tab_scaffold/cupertino_tab_scaffold.0.dart',
      title: 'CupertinoTabScaffold',
      builder: (BuildContext context) =>
          const cupertino_tab_scaffold_0.TabScaffoldApp(),
    ),
    _Example(
      filepath: 'text_field/cupertino_text_field.0.dart',
      title: 'CupertinoTextField',
      builder: (BuildContext context) =>
          const cupertino_text_field_0.CupertinoTextFieldApp(),
    ),
    _Example(
      filepath: 'text_form_field_row/cupertino_text_form_field_row.1.dart',
      title: 'CupertinoTextFormFieldRow',
      builder: (BuildContext context) =>
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
      title: Text(example.title),
    );
  }
}

/// A self-contained Cupertino example.
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
    assert(filenameSegments.length >= 3);
    final number = filenameSegments[filenameSegments.length - 2];

    return '/$directory/$filename/$number';
  }
}
