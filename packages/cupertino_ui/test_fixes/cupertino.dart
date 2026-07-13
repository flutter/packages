// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';

void main() {
  // Generic reference variables.
  BuildContext context;
  RenderObjectWidget renderObjectWidget;
  RenderObject renderObject;
  Object object;

  // Change made in https://github.com/flutter/flutter/pull/41859
  CupertinoTextThemeData themeData = CupertinoTextThemeData(
    brightness: Brightness.dark,
  );
  themeData.copyWith(brightness: Brightness.light);
  themeData = CupertinoTextThemeData(error: '');
  themeData.copyWith(error: '');

  // Changes made in https://github.com/flutter/flutter/pull/68905
  CupertinoDynamicColor.resolve(Color(0), context, nullOk: true);
  CupertinoDynamicColor.resolve(Color(0), context, nullOk: false);
  CupertinoDynamicColor.resolve(error: '');
  CupertinoDynamicColor.resolveFrom(error: '');
  CupertinoDynamicColor.resolveFrom(context, nullOk: true);
  CupertinoDynamicColor.resolveFrom(context, nullOk: false);
  CupertinoUserInterfaceLevel.of(context, nullOk: true);
  CupertinoUserInterfaceLevel.of(context, nullOk: false);
  CupertinoUserInterfaceLevel.of(error: '');

  // Changes made in https://github.com/flutter/flutter/pull/68736
  CupertinoTheme.brightnessOf(context, nullOk: true);
  CupertinoTheme.brightnessOf(context, nullOk: false);
  CupertinoTheme.brightnessOf(error: '');

  // Changes made in https://github.com/flutter/flutter/pull/68905
  CupertinoThemeData.resolveFrom(context, nullOk: true);
  CupertinoThemeData.resolveFrom(context, nullOk: false);
  CupertinoThemeData.resolveFrom(error: '');
  NoDefaultCupertinoThemeData.resolveFrom(error: '');
  NoDefaultCupertinoThemeData.resolveFrom(context, nullOk: true);
  NoDefaultCupertinoThemeData.resolveFrom(context, nullOk: false);
  CupertinoTextThemeData.resolveFrom(context, nullOk: true);
  CupertinoTextThemeData.resolveFrom(context, nullOk: false);
  CupertinoTextThemeData.resolveFrom(error: '');

  // Changes made in https://github.com/flutter/flutter/pull/72043
  CupertinoTextField(maxLengthEnforced: true);
  CupertinoTextField(maxLengthEnforced: false);
  CupertinoTextField(error: '');
  CupertinoTextField.borderless(error: '');
  CupertinoTextField.borderless(maxLengthEnforced: true);
  CupertinoTextField.borderless(maxLengthEnforced: false);
  final CupertinoTextField textField;
  textField.maxLengthEnforced;

  // Changes made in https://github.com/flutter/flutter/pull/96957
  CupertinoScrollbar scrollbar = CupertinoScrollbar(isAlwaysShown: true);
  bool nowShowing = scrollbar.isAlwaysShown;

  // Changes made in https://github.com/flutter/flutter/pull/78588
  final CupertinoScrollBehavior cupertinoScrollBehavior =
      CupertinoScrollBehavior();
  cupertinoScrollBehavior.buildViewportChrome(context, child, axisDirection);

  // Changes made in https://github.com/flutter/flutter/pull/151367
  final cupertinoSwitch = CupertinoSwitch(
    value: value,
    onChanged: onChanged,
    activeColor: Colors.red,
  );
  Color? activeTrackColor = cupertinoSwitch.activeColor;

  // Changes made in https://github.com/flutter/flutter/pull/151367
  final cupertinoSwitch = CupertinoSwitch(
    value: value,
    onChanged: onChanged,
    trackColor: Colors.red,
  );
  Color? inactiveTrackColor = cupertinoSwitch.trackColor;

  // https://github.com/flutter/flutter/pull/152981
  CupertinoCheckbox(inactiveColor: Colors.red);
  CupertinoCheckbox(inactiveColor: Colors.red, activeColor: Colors.white);
  CupertinoCheckbox(
    inactiveColor: Colors.red,
    fillColor: WidgetStatePropertyAll(CupertinoColors.white),
  );

  // https://github.com/flutter/flutter/pull/161295
  CupertinoButton(minSize: 60.0);

  // https://github.com/flutter/flutter/pull/170625
  showCupertinoSheet(
    context: context,
    pageBuilder: (BuildContext context) => Container(),
  );

  // https://github.com/flutter/flutter/pull/171160
  CupertinoDynamicColor dynamicColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF000000),
    darkColor: Color(0xFF000001),
  );
  dynamicColor.opacity;
  dynamicColor.value;
  dynamicColor = dynamicColor.withOpacity(0.55);

  // Changes made in https://github.com/flutter/flutter/pull/177337
  showCupertinoSheet(
    context: context,
    builder: (BuildContext context) => Container(),
  );

  // Changes made in https://github.com/flutter/flutter/pull/177337
  CupertinoSheetRoute<void>(
    context: context,
    builder: (BuildContext context) => Container(),
  );
}
