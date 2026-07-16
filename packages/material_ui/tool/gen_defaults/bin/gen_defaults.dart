// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// ## Usage
//
// Run from the root of flutter/packages:
//
// ```
// dart packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart [-v]
// ```

import 'package:args/args.dart';

// import '../templates/action_chip_template.dart';
import '../templates/app_bar_template.dart';
import '../templates/badge_template.dart';

// import '../templates/banner_template.dart';
// import '../templates/bottom_app_bar_template.dart';
// import '../templates/bottom_sheet_template.dart';
// import '../templates/button_template.dart';
// import '../templates/card_template.dart';
// import '../templates/checkbox_template.dart';
// import '../templates/chip_template.dart';
// import '../templates/color_scheme_template.dart';
// import '../templates/date_picker_template.dart';
// import '../templates/dialog_template.dart';
// import '../templates/divider_template.dart';
// import '../templates/drawer_template.dart';
// import '../templates/expansion_tile_template.dart';
// import '../templates/fab_template.dart';
// import '../templates/filter_chip_template.dart';
// import '../templates/icon_button_template.dart';
// import '../templates/input_chip_template.dart';
// import '../templates/input_decorator_template.dart';
// import '../templates/list_tile_template.dart';
// import '../templates/menu_template.dart';
// import '../templates/motion_template.dart';
// import '../templates/navigation_bar_template.dart';
// import '../templates/navigation_drawer_template.dart';
// import '../templates/navigation_rail_template.dart';
// import '../templates/popup_menu_template.dart';
// import '../templates/progress_indicator_template.dart';
// import '../templates/radio_template.dart';
// import '../templates/range_slider_template.dart';
// import '../templates/search_bar_template.dart';
// import '../templates/search_view_template.dart';
// import '../templates/segmented_button_template.dart';
// import '../templates/slider_template.dart';
// import '../templates/snackbar_template.dart';
// import '../templates/surface_tint_template.dart';
// import '../templates/switch_template.dart';
// import '../templates/tabs_template.dart';
// import '../templates/text_field_template.dart';
// import '../templates/time_picker_template.dart';
// import '../templates/typography_template.dart';

Future<void> main(List<String> args) async {
  // Parse arguments
  final parser = ArgParser();
  parser.addFlag('verbose', abbr: 'v', help: 'Enable verbose output', negatable: false);
  final ArgResults argResults = parser.parse(args);
  // TODO(elliette): Add token logger when verbose flag is used.
  final verbose = argResults['verbose'] as bool;

  // const ActionChipTemplateM3().generateFile(verbose: verbose);
  const AppBarTemplateM3().generateFile(verbose: verbose);
  const BadgeTemplateM3().generateFile(verbose: verbose);
  // const BannerTemplateM3().generateFile(verbose: verbose);
  // const BottomAppBarTemplateM3().generateFile(verbose: verbose);
  // const BottomSheetTemplateM3().generateFile(verbose: verbose);
  // const ButtonTemplateM3().generateFile(verbose: verbose);
  // const CardTemplateM3().generateFile(verbose: verbose);
  // const CheckboxTemplateM3().generateFile(verbose: verbose);
  // const ChipTemplateM3().generateFile(verbose: verbose);
  // const ColorSchemeTemplateM3().generateFile(verbose: verbose);
  // const DatePickerTemplateM3().generateFile(verbose: verbose);
  // const DialogTemplateM3().generateFile(verbose: verbose);
  // const DividerTemplateM3().generateFile(verbose: verbose);
  // const DrawerTemplateM3().generateFile(verbose: verbose);
  // const ExpansionTileTemplateM3().generateFile(verbose: verbose);
  // const FabTemplateM3().generateFile(verbose: verbose);
  // const FilterChipTemplateM3().generateFile(verbose: verbose);
  // const IconButtonTemplateM3().generateFile(verbose: verbose);
  // const InputChipTemplateM3().generateFile(verbose: verbose);
  // const InputDecoratorTemplateM3().generateFile(verbose: verbose);
  // const ListTileTemplateM3().generateFile(verbose: verbose);
  // const MenuTemplateM3().generateFile(verbose: verbose);
  // const MotionTemplateM3().generateFile(verbose: verbose);
  // const NavigationBarTemplateM3().generateFile(verbose: verbose);
  // const NavigationDrawerTemplateM3().generateFile(verbose: verbose);
  // const NavigationRailTemplateM3().generateFile(verbose: verbose);
  // const PopupMenuTemplateM3().generateFile(verbose: verbose);
  // const ProgressIndicatorTemplateM3().generateFile(verbose: verbose);
  // const RadioTemplateM3().generateFile(verbose: verbose);
  // const RangeSliderTemplateM3().generateFile(verbose: verbose);
  // const SearchBarTemplateM3().generateFile(verbose: verbose);
  // const SearchViewTemplateM3().generateFile(verbose: verbose);
  // const SegmentedButtonTemplateM3().generateFile(verbose: verbose);
  // const SliderTemplateM3().generateFile(verbose: verbose);
  // const SnackbarTemplateM3().generateFile(verbose: verbose);
  // const SurfaceTintTemplateM3().generateFile(verbose: verbose);
  // const SwitchTemplateM3().generateFile(verbose: verbose);
  // const TabsTemplateM3().generateFile(verbose: verbose);
  // const TextFieldTemplateM3().generateFile(verbose: verbose);
  // const TimePickerTemplateM3().generateFile(verbose: verbose);
  // const TypographyTemplateM3().generateFile(verbose: verbose);
}
