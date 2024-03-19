// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

/// Defines the configuration of the overall visual [Theme] for a [MaterialApp]
/// or a widget subtree within the app in accordance with Material
/// Design specifications no longer supported by the Flutter framework.
///
/// The [MaterialApp] theme property can be used to configure the appearance
/// of the entire app. Widget subtrees within an app can override the app's
/// theme by including a [Theme] widget at the top of the subtree.
///
/// Widgets whose appearance should align with the overall theme can obtain the
/// current theme's configuration with [Theme.of]. Material components typically
/// depend exclusively on the [colorScheme] and [textTheme]. These properties
/// are guaranteed to have non-null values.
///
/// The static [Theme.of] method finds the [ThemeData] value specified for the
/// nearest [BuildContext] ancestor. This lookup is inexpensive, essentially
/// just a single HashMap access. It can sometimes be a little confusing
/// because [Theme.of] can not see a [Theme] widget that is defined in the
/// current build method's context. To overcome that, create a new custom widget
/// for the subtree that appears below the new [Theme], or insert a widget
/// that creates a new BuildContext, like [Builder].
class LegacyThemeData extends ThemeData {
  /// Create a [LegacyThemeData] that's used to configure a [Theme] in legacy
  /// style Material Design.
  ///
  /// The [colorScheme] and [textTheme] are used by the Material components to
  /// compute default values for visual properties. The API documentation for
  /// each component widget explains exactly how the defaults are computed.
  ///
  /// When providing a [ColorScheme], apps can either provide one directly
  /// with the [colorScheme] parameter, or have one generated for them by
  /// using the [colorSchemeSeed] and [brightness] parameters. A generated
  /// color scheme will be based on the tones of [colorSchemeSeed] and all of
  /// its contrasting color will meet accessibility guidelines for readability.
  /// (See [ColorScheme.fromSeed] for more details.)
  ///
  /// If the app wants to customize a generated color scheme, it can use
  /// [ColorScheme.fromSeed] directly and then [ColorScheme.copyWith] on the
  /// result to override any colors that need to be replaced. The result of
  /// this can be used as the [colorScheme] directly.
  ///
  /// For historical reasons, instead of using a [colorSchemeSeed] or
  /// [colorScheme], you can provide either a [primaryColor] or [primarySwatch]
  /// to construct the [colorScheme], but the results will not be as complete
  /// as when using generation from a seed color.
  ///
  /// If [colorSchemeSeed] is non-null then [colorScheme], [primaryColor] and
  /// [primarySwatch] must all be null.
  ///
  /// The [textTheme] [TextStyle] colors are black if the color scheme's
  /// brightness is [Brightness.light], and white for [Brightness.dark].
  ///
  /// To override the appearance of specific components, provide
  /// a component theme parameter like [sliderTheme], [toggleButtonsTheme],
  /// or [bottomNavigationBarTheme].
  ///
  /// See also:
  ///
  ///  * [LegacyThemeData.from], which creates a LegacyThemeData from a
  ///    [ColorScheme].
  ///  * [LegacyThemeData.light], which creates a light blue theme.
  ///  * [LegacyThemeData.dark], which creates dark theme with a teal secondary
  ///    [ColorScheme] color.
  ///  * [ColorScheme.fromSeed], which is used to create a [ColorScheme] from a
  ///    seed color.
  factory LegacyThemeData({
    // For the sanity of the reader, make sure these properties are in the same
    // order in every place that they are separated by section comments (e.g.
    // GENERAL CONFIGURATION). Each section except for deprecations should be
    // alphabetical by symbol name.

    // GENERAL CONFIGURATION
    Iterable<Adaptation<Object>>? adaptations,
    bool? applyElevationOverlayColor,
    NoDefaultCupertinoThemeData? cupertinoOverrideTheme,
    Iterable<ThemeExtension<dynamic>>? extensions,
    InputDecorationTheme? inputDecorationTheme,
    MaterialTapTargetSize? materialTapTargetSize,
    PageTransitionsTheme? pageTransitionsTheme,
    TargetPlatform? platform,
    ScrollbarThemeData? scrollbarTheme,
    InteractiveInkFeatureFactory? splashFactory,
    VisualDensity? visualDensity,
    // COLOR
    // [colorScheme] is the preferred way to configure colors. The other color
    // properties (as well as primarySwatch) will gradually be phased out, see
    // https://github.com/flutter/flutter/issues/91772.
    Brightness? brightness,
    Color? canvasColor,
    Color? cardColor,
    ColorScheme? colorScheme,
    Color? colorSchemeSeed,
    Color? dialogBackgroundColor,
    Color? disabledColor,
    Color? dividerColor,
    Color? focusColor,
    Color? highlightColor,
    Color? hintColor,
    Color? hoverColor,
    Color? indicatorColor,
    Color? primaryColor,
    Color? primaryColorDark,
    Color? primaryColorLight,
    MaterialColor? primarySwatch,
    Color? scaffoldBackgroundColor,
    Color? secondaryHeaderColor,
    Color? shadowColor,
    Color? splashColor,
    Color? unselectedWidgetColor,
    // TYPOGRAPHY & ICONOGRAPHY
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    IconThemeData? iconTheme,
    IconThemeData? primaryIconTheme,
    TextTheme? primaryTextTheme,
    TextTheme? textTheme,
    Typography? typography,
    // COMPONENT THEMES
    ActionIconThemeData? actionIconTheme,
    AppBarTheme? appBarTheme,
    BadgeThemeData? badgeTheme,
    MaterialBannerThemeData? bannerTheme,
    BottomAppBarTheme? bottomAppBarTheme,
    BottomNavigationBarThemeData? bottomNavigationBarTheme,
    BottomSheetThemeData? bottomSheetTheme,
    ButtonBarThemeData? buttonBarTheme,
    ButtonThemeData? buttonTheme,
    CardTheme? cardTheme,
    CheckboxThemeData? checkboxTheme,
    ChipThemeData? chipTheme,
    DataTableThemeData? dataTableTheme,
    DatePickerThemeData? datePickerTheme,
    DialogTheme? dialogTheme,
    DividerThemeData? dividerTheme,
    DrawerThemeData? drawerTheme,
    DropdownMenuThemeData? dropdownMenuTheme,
    ElevatedButtonThemeData? elevatedButtonTheme,
    ExpansionTileThemeData? expansionTileTheme,
    FilledButtonThemeData? filledButtonTheme,
    FloatingActionButtonThemeData? floatingActionButtonTheme,
    IconButtonThemeData? iconButtonTheme,
    ListTileThemeData? listTileTheme,
    MenuBarThemeData? menuBarTheme,
    MenuButtonThemeData? menuButtonTheme,
    MenuThemeData? menuTheme,
    NavigationBarThemeData? navigationBarTheme,
    NavigationDrawerThemeData? navigationDrawerTheme,
    NavigationRailThemeData? navigationRailTheme,
    OutlinedButtonThemeData? outlinedButtonTheme,
    PopupMenuThemeData? popupMenuTheme,
    ProgressIndicatorThemeData? progressIndicatorTheme,
    RadioThemeData? radioTheme,
    SearchBarThemeData? searchBarTheme,
    SearchViewThemeData? searchViewTheme,
    SegmentedButtonThemeData? segmentedButtonTheme,
    SliderThemeData? sliderTheme,
    SnackBarThemeData? snackBarTheme,
    SwitchThemeData? switchTheme,
    TabBarTheme? tabBarTheme,
    TextButtonThemeData? textButtonTheme,
    TextSelectionThemeData? textSelectionTheme,
    TimePickerThemeData? timePickerTheme,
    ToggleButtonsThemeData? toggleButtonsTheme,
    TooltipThemeData? tooltipTheme,
  }) {
    // GENERAL CONFIGURATION
    cupertinoOverrideTheme = cupertinoOverrideTheme?.noDefault();
    extensions ??= <ThemeExtension<dynamic>>[];
    adaptations ??= <Adaptation<Object>>[];
    inputDecorationTheme ??= const InputDecorationTheme();
    platform ??= defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        materialTapTargetSize ??= MaterialTapTargetSize.padded;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        materialTapTargetSize ??= MaterialTapTargetSize.shrinkWrap;
    }
    pageTransitionsTheme ??= const PageTransitionsTheme();
    scrollbarTheme ??= const ScrollbarThemeData();
    visualDensity ??= VisualDensity.defaultDensityForPlatform(platform);
    splashFactory ??= InkSplash.splashFactory;

    // COLOR
    assert(
      colorScheme?.brightness == null ||
          brightness == null ||
          colorScheme!.brightness == brightness,
      'ThemeData.brightness does not match ColorScheme.brightness. '
      'Either override ColorScheme.brightness or ThemeData.brightness to '
      'match the other.',
    );
    assert(colorSchemeSeed == null || colorScheme == null);
    assert(colorSchemeSeed == null || primarySwatch == null);
    assert(colorSchemeSeed == null || primaryColor == null);
    final Brightness effectiveBrightness =
        brightness ?? colorScheme?.brightness ?? Brightness.light;
    final bool isDark = effectiveBrightness == Brightness.dark;
    if (colorSchemeSeed != null) {
      colorScheme = ColorScheme.fromSeed(
        seedColor: colorSchemeSeed,
        brightness: effectiveBrightness,
      );

      // For surfaces that use primary color in light themes and surface color
      // in dark.
      final Color primarySurfaceColor =
          isDark ? colorScheme.surface : colorScheme.primary;
      final Color onPrimarySurfaceColor =
          isDark ? colorScheme.onSurface : colorScheme.onPrimary;

      // Default some of the color settings to values from the color scheme
      primaryColor ??= primarySurfaceColor;
      canvasColor ??= colorScheme.background;
      scaffoldBackgroundColor ??= colorScheme.background;
      cardColor ??= colorScheme.surface;
      dividerColor ??= colorScheme.outline;
      dialogBackgroundColor ??= colorScheme.background;
      indicatorColor ??= onPrimarySurfaceColor;
      applyElevationOverlayColor ??= brightness == Brightness.dark;
    }
    applyElevationOverlayColor ??= false;
    primarySwatch ??= Colors.blue;
    primaryColor ??= isDark ? Colors.grey[900]! : primarySwatch;
    final Brightness estimatedPrimaryColorBrightness =
        ThemeData.estimateBrightnessForColor(primaryColor);
    primaryColorLight ??= isDark ? Colors.grey[500]! : primarySwatch[100]!;
    primaryColorDark ??= isDark ? Colors.black : primarySwatch[700]!;
    final bool primaryIsDark =
        estimatedPrimaryColorBrightness == Brightness.dark;
    focusColor ??= isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.12);
    hoverColor ??= isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.black.withOpacity(0.04);
    shadowColor ??= Colors.black;
    canvasColor ??= isDark ? Colors.grey[850]! : Colors.grey[50]!;
    scaffoldBackgroundColor ??= canvasColor;
    cardColor ??= isDark ? Colors.grey[800]! : Colors.white;
    dividerColor ??= isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000);
    // Create a ColorScheme that is backwards compatible as possible
    // with the existing default ThemeData color values.
    colorScheme ??= ColorScheme.fromSwatch(
      primarySwatch: primarySwatch,
      accentColor: isDark ? Colors.tealAccent[200]! : primarySwatch[500]!,
      cardColor: cardColor,
      backgroundColor: isDark ? Colors.grey[700]! : primarySwatch[200]!,
      errorColor: Colors.red[700],
      brightness: effectiveBrightness,
    );
    unselectedWidgetColor ??= isDark ? Colors.white70 : Colors.black54;
    // Spec doesn't specify a dark theme secondaryHeaderColor, this is a guess.
    secondaryHeaderColor ??= isDark ? Colors.grey[700]! : primarySwatch[50]!;
    dialogBackgroundColor ??= isDark ? Colors.grey[800]! : Colors.white;
    indicatorColor ??= colorScheme.secondary == primaryColor
        ? Colors.white
        : colorScheme.secondary;
    hintColor ??= isDark ? Colors.white60 : Colors.black.withOpacity(0.6);
    // The default [buttonTheme] is here because it doesn't use the defaults for
    // [disabledColor], [highlightColor], and [splashColor].
    buttonTheme ??= ButtonThemeData(
      colorScheme: colorScheme,
      buttonColor: isDark ? primarySwatch[600]! : Colors.grey[300]!,
      disabledColor: disabledColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      materialTapTargetSize: materialTapTargetSize,
    );
    disabledColor ??= isDark ? Colors.white38 : Colors.black38;
    highlightColor ??= isDark
        ? LegacyMaterialConstants.kDarkThemeHighlightColor
        : LegacyMaterialConstants.kLightThemeHighlightColor;
    splashColor ??= isDark
        ? LegacyMaterialConstants.kDarkThemeSplashColor
        : LegacyMaterialConstants.kLightThemeSplashColor;

    // TYPOGRAPHY & ICONOGRAPHY
    typography ??= Typography.material2014(platform: platform);
    TextTheme defaultTextTheme = isDark ? typography.white : typography.black;
    TextTheme defaultPrimaryTextTheme =
        primaryIsDark ? typography.white : typography.black;
    if (fontFamily != null) {
      defaultTextTheme = defaultTextTheme.apply(fontFamily: fontFamily);
      defaultPrimaryTextTheme = defaultPrimaryTextTheme.apply(
        fontFamily: fontFamily,
      );
    }
    if (fontFamilyFallback != null) {
      defaultTextTheme = defaultTextTheme.apply(
        fontFamilyFallback: fontFamilyFallback,
      );
      defaultPrimaryTextTheme = defaultPrimaryTextTheme.apply(
        fontFamilyFallback: fontFamilyFallback,
      );
    }
    if (package != null) {
      defaultTextTheme = defaultTextTheme.apply(package: package);
      defaultPrimaryTextTheme = defaultPrimaryTextTheme.apply(package: package);
    }
    textTheme = defaultTextTheme.merge(textTheme);
    primaryTextTheme = defaultPrimaryTextTheme.merge(primaryTextTheme);
    iconTheme ??= isDark
        ? IconThemeData(color: kDefaultIconLightColor)
        : IconThemeData(color: kDefaultIconDarkColor);
    primaryIconTheme ??= primaryIsDark
        ? const IconThemeData(color: Colors.white)
        : const IconThemeData(color: Colors.black);

    // COMPONENT THEMES
    // TODO(Piinks): We may need to create custom component themes as we go
    //  forward here to get the right styling. For example, we may need to
    //  create LegacyAppBarTheme, that includes more properties than the default
    //  theme provides. The default themes could be expanded upon as well, but
    //  should be done separately so that development of this package is not
    //  stalled by having to wait for stable releases.
    appBarTheme ??= const AppBarTheme();
    badgeTheme ??= const BadgeThemeData();
    bannerTheme ??= const MaterialBannerThemeData();
    bottomAppBarTheme ??= const BottomAppBarTheme();
    bottomNavigationBarTheme ??= const BottomNavigationBarThemeData();
    bottomSheetTheme ??= const BottomSheetThemeData();
    buttonBarTheme ??= const ButtonBarThemeData();
    cardTheme ??= const CardTheme();
    checkboxTheme ??= const CheckboxThemeData();
    chipTheme ??= const ChipThemeData();
    dataTableTheme ??= const DataTableThemeData();
    datePickerTheme ??= const DatePickerThemeData();
    dialogTheme ??= const DialogTheme();
    dividerTheme ??= const DividerThemeData();
    drawerTheme ??= const DrawerThemeData();
    dropdownMenuTheme ??= const DropdownMenuThemeData();
    elevatedButtonTheme ??= const ElevatedButtonThemeData();
    expansionTileTheme ??= const ExpansionTileThemeData();
    filledButtonTheme ??= const FilledButtonThemeData();
    floatingActionButtonTheme ??= const FloatingActionButtonThemeData();
    iconButtonTheme ??= const IconButtonThemeData();
    listTileTheme ??= const ListTileThemeData();
    menuBarTheme ??= const MenuBarThemeData();
    menuButtonTheme ??= const MenuButtonThemeData();
    menuTheme ??= const MenuThemeData();
    navigationBarTheme ??= const NavigationBarThemeData();
    navigationDrawerTheme ??= const NavigationDrawerThemeData();
    navigationRailTheme ??= const NavigationRailThemeData();
    outlinedButtonTheme ??= const OutlinedButtonThemeData();
    popupMenuTheme ??= const PopupMenuThemeData();
    progressIndicatorTheme ??= const ProgressIndicatorThemeData();
    radioTheme ??= const RadioThemeData();
    searchBarTheme ??= const SearchBarThemeData();
    searchViewTheme ??= const SearchViewThemeData();
    segmentedButtonTheme ??= const SegmentedButtonThemeData();
    sliderTheme ??= const SliderThemeData();
    snackBarTheme ??= const SnackBarThemeData();
    switchTheme ??= const SwitchThemeData();
    tabBarTheme ??= const TabBarTheme();
    textButtonTheme ??= const TextButtonThemeData();
    textSelectionTheme ??= const TextSelectionThemeData();
    timePickerTheme ??= const TimePickerThemeData();
    toggleButtonsTheme ??= const ToggleButtonsThemeData();
    tooltipTheme ??= const TooltipThemeData();

    return LegacyThemeData.raw(
      // For the sanity of the reader, make sure these properties are in the
      // same order in every place that they are separated by section comments
      // (e.g. GENERAL CONFIGURATION).

      // GENERAL CONFIGURATION
      adaptationMap: _createAdaptationMap(adaptations),
      applyElevationOverlayColor: applyElevationOverlayColor,
      cupertinoOverrideTheme: cupertinoOverrideTheme,
      extensions: _themeExtensionIterableToMap(extensions),
      inputDecorationTheme: inputDecorationTheme,
      materialTapTargetSize: materialTapTargetSize,
      pageTransitionsTheme: pageTransitionsTheme,
      platform: platform,
      scrollbarTheme: scrollbarTheme,
      splashFactory: splashFactory,
      visualDensity: visualDensity,
      // COLOR
      canvasColor: canvasColor,
      cardColor: cardColor,
      colorScheme: colorScheme,
      dialogBackgroundColor: dialogBackgroundColor,
      disabledColor: disabledColor,
      dividerColor: dividerColor,
      focusColor: focusColor,
      highlightColor: highlightColor,
      hintColor: hintColor,
      hoverColor: hoverColor,
      indicatorColor: indicatorColor,
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      primaryColorLight: primaryColorLight,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      secondaryHeaderColor: secondaryHeaderColor,
      shadowColor: shadowColor,
      splashColor: splashColor,
      unselectedWidgetColor: unselectedWidgetColor,
      // TYPOGRAPHY & ICONOGRAPHY
      iconTheme: iconTheme,
      primaryTextTheme: primaryTextTheme,
      textTheme: textTheme,
      typography: typography,
      primaryIconTheme: primaryIconTheme,
      // COMPONENT THEMES
      actionIconTheme: actionIconTheme,
      appBarTheme: appBarTheme,
      badgeTheme: badgeTheme,
      bannerTheme: bannerTheme,
      bottomAppBarTheme: bottomAppBarTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      bottomSheetTheme: bottomSheetTheme,
      buttonBarTheme: buttonBarTheme,
      buttonTheme: buttonTheme,
      cardTheme: cardTheme,
      checkboxTheme: checkboxTheme,
      chipTheme: chipTheme,
      dataTableTheme: dataTableTheme,
      datePickerTheme: datePickerTheme,
      dialogTheme: dialogTheme,
      dividerTheme: dividerTheme,
      drawerTheme: drawerTheme,
      dropdownMenuTheme: dropdownMenuTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      expansionTileTheme: expansionTileTheme,
      filledButtonTheme: filledButtonTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      iconButtonTheme: iconButtonTheme,
      listTileTheme: listTileTheme,
      menuBarTheme: menuBarTheme,
      menuButtonTheme: menuButtonTheme,
      menuTheme: menuTheme,
      navigationBarTheme: navigationBarTheme,
      navigationDrawerTheme: navigationDrawerTheme,
      navigationRailTheme: navigationRailTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      popupMenuTheme: popupMenuTheme,
      progressIndicatorTheme: progressIndicatorTheme,
      radioTheme: radioTheme,
      searchBarTheme: searchBarTheme,
      searchViewTheme: searchViewTheme,
      segmentedButtonTheme: segmentedButtonTheme,
      sliderTheme: sliderTheme,
      snackBarTheme: snackBarTheme,
      switchTheme: switchTheme,
      tabBarTheme: tabBarTheme,
      textButtonTheme: textButtonTheme,
      textSelectionTheme: textSelectionTheme,
      timePickerTheme: timePickerTheme,
      toggleButtonsTheme: toggleButtonsTheme,
      tooltipTheme: tooltipTheme,
    );
  }

  /// Create a [LegacyThemeData] given a set of exact values. Most values must
  /// be specified. They all must also be non-null except for
  /// [cupertinoOverrideTheme], and deprecated members.
  ///
  /// This will rarely be used directly. It is used by [lerp] to
  /// create intermediate themes based on two themes created with the
  /// [LegacyThemeData] constructor.
  @override
  const LegacyThemeData.raw({
    // For the sanity of the reader, make sure these properties are in the same
    // order in every place that they are separated by section comments (e.g.
    // GENERAL CONFIGURATION). Each section except for deprecations should be
    // alphabetical by symbol name.

    // GENERAL CONFIGURATION
    required super.adaptationMap,
    required super.applyElevationOverlayColor,
    required super.cupertinoOverrideTheme,
    required super.extensions,
    required super.inputDecorationTheme,
    required super.materialTapTargetSize,
    required super.pageTransitionsTheme,
    required super.platform,
    required super.scrollbarTheme,
    required super.splashFactory,
    // required super.useMaterial3,
    required super.visualDensity,
    // COLO
    required super.canvasColor,
    required super.cardColor,
    required super.colorScheme,
    required super.dialogBackgroundColor,
    required super.disabledColor,
    required super.dividerColor,
    required super.focusColor,
    required super.highlightColor,
    required super.hintColor,
    required super.hoverColor,
    required super.indicatorColor,
    required super.primaryColor,
    required super.primaryColorDark,
    required super.primaryColorLight,
    required super.scaffoldBackgroundColor,
    required super.secondaryHeaderColor,
    required super.shadowColor,
    required super.splashColor,
    required super.unselectedWidgetColor,
    // TYPOGRAPHY & ICONOGRAPHY
    required super.iconTheme,
    required super.primaryIconTheme,
    required super.primaryTextTheme,
    required super.textTheme,
    required super.typography,
    // COMPONENT THEMES
    required super.actionIconTheme,
    required super.appBarTheme,
    required super.badgeTheme,
    required super.bannerTheme,
    required super.bottomAppBarTheme,
    required super.bottomNavigationBarTheme,
    required super.bottomSheetTheme,
    required super.buttonBarTheme,
    required super.buttonTheme,
    required super.cardTheme,
    required super.checkboxTheme,
    required super.chipTheme,
    required super.dataTableTheme,
    required super.datePickerTheme,
    required super.dialogTheme,
    required super.dividerTheme,
    required super.drawerTheme,
    required super.dropdownMenuTheme,
    required super.elevatedButtonTheme,
    required super.expansionTileTheme,
    required super.filledButtonTheme,
    required super.floatingActionButtonTheme,
    required super.iconButtonTheme,
    required super.listTileTheme,
    required super.menuBarTheme,
    required super.menuButtonTheme,
    required super.menuTheme,
    required super.navigationBarTheme,
    required super.navigationDrawerTheme,
    required super.navigationRailTheme,
    required super.outlinedButtonTheme,
    required super.popupMenuTheme,
    required super.progressIndicatorTheme,
    required super.radioTheme,
    required super.searchBarTheme,
    required super.searchViewTheme,
    required super.segmentedButtonTheme,
    required super.sliderTheme,
    required super.snackBarTheme,
    required super.switchTheme,
    required super.tabBarTheme,
    required super.textButtonTheme,
    required super.textSelectionTheme,
    required super.timePickerTheme,
    required super.toggleButtonsTheme,
    required super.tooltipTheme,
  }) : super.raw(useMaterial3: true);

  /// Create a [ThemeData] based on the colors in the given [colorScheme] and
  /// text styles of the optional [textTheme].
  ///
  /// If [colorScheme].brightness is [Brightness.dark] then
  /// [ThemeData.applyElevationOverlayColor] will be set to true to support
  /// the Material dark theme method for indicating elevation by applying
  /// a semi-transparent onSurface color on top of the surface color.
  ///
  /// This is the recommended method to theme your application. As we move
  /// forward we will be converting all the widget implementations to only use
  /// colors or colors derived from those in [ColorScheme].
  factory LegacyThemeData.from({
    required ColorScheme colorScheme,
    TextTheme? textTheme,
  }) {
    final bool isDark = colorScheme.brightness == Brightness.dark;

    // For surfaces that use primary color in light themes and surface color in
    // dark.
    final Color primarySurfaceColor =
        isDark ? colorScheme.surface : colorScheme.primary;
    final Color onPrimarySurfaceColor =
        isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    return LegacyThemeData(
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      primaryColor: primarySurfaceColor,
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      cardColor: colorScheme.surface,
      dividerColor: colorScheme.onSurface.withOpacity(0.12),
      dialogBackgroundColor: colorScheme.background,
      indicatorColor: onPrimarySurfaceColor,
      textTheme: textTheme,
      applyElevationOverlayColor: isDark,
    );
  }

  /// A default light theme.
  ///
  /// This theme does not contain text geometry. Instead, it is expected that
  /// this theme is localized using text geometry using
  /// [LegacyThemeData.localize].
  factory LegacyThemeData.light() {
    return LegacyThemeData(brightness: Brightness.light);
  }

  /// A default dark theme.
  ///
  /// This theme does not contain text geometry. Instead, it is expected that
  /// this theme is localized using text geometry using
  /// [LegacyThemeData.localize].
  factory LegacyThemeData.dark() {
    return LegacyThemeData(brightness: Brightness.dark);
  }

  /// The default color theme. Same as [LegacyThemeData.light].
  ///
  /// This theme does not contain text geometry. Instead, it is expected that
  /// this theme is localized using text geometry using
  /// [LegacyThemeData.localize].
  factory LegacyThemeData.fallback() => LegacyThemeData.light();

  /// Creates a copy of this theme but with the given fields replaced with the
  /// new values.
  ///
  /// The [brightness] value is applied to the [colorScheme].
  @override
  LegacyThemeData copyWith({
    // For the sanity of the reader, make sure these properties are in the same
    // order in every place that they are separated by section comments (e.g.
    // GENERAL CONFIGURATION). Each section except for deprecations should be
    // alphabetical by symbol name.

    // GENERAL CONFIGURATION
    Iterable<Adaptation<Object>>? adaptations,
    bool? applyElevationOverlayColor,
    NoDefaultCupertinoThemeData? cupertinoOverrideTheme,
    Iterable<ThemeExtension<dynamic>>? extensions,
    InputDecorationTheme? inputDecorationTheme,
    MaterialTapTargetSize? materialTapTargetSize,
    PageTransitionsTheme? pageTransitionsTheme,
    TargetPlatform? platform,
    ScrollbarThemeData? scrollbarTheme,
    InteractiveInkFeatureFactory? splashFactory,
    VisualDensity? visualDensity,
    // COLOR
    Brightness? brightness,
    Color? canvasColor,
    Color? cardColor,
    ColorScheme? colorScheme,
    Color? dialogBackgroundColor,
    Color? disabledColor,
    Color? dividerColor,
    Color? focusColor,
    Color? highlightColor,
    Color? hintColor,
    Color? hoverColor,
    Color? indicatorColor,
    Color? primaryColor,
    Color? primaryColorDark,
    Color? primaryColorLight,
    Color? scaffoldBackgroundColor,
    Color? secondaryHeaderColor,
    Color? shadowColor,
    Color? splashColor,
    Color? unselectedWidgetColor,
    // TYPOGRAPHY & ICONOGRAPHY
    IconThemeData? iconTheme,
    IconThemeData? primaryIconTheme,
    TextTheme? primaryTextTheme,
    TextTheme? textTheme,
    Typography? typography,
    // COMPONENT THEMES
    ActionIconThemeData? actionIconTheme,
    AppBarTheme? appBarTheme,
    BadgeThemeData? badgeTheme,
    MaterialBannerThemeData? bannerTheme,
    BottomAppBarTheme? bottomAppBarTheme,
    BottomNavigationBarThemeData? bottomNavigationBarTheme,
    BottomSheetThemeData? bottomSheetTheme,
    ButtonBarThemeData? buttonBarTheme,
    ButtonThemeData? buttonTheme,
    CardTheme? cardTheme,
    CheckboxThemeData? checkboxTheme,
    ChipThemeData? chipTheme,
    DataTableThemeData? dataTableTheme,
    DatePickerThemeData? datePickerTheme,
    DialogTheme? dialogTheme,
    DividerThemeData? dividerTheme,
    DrawerThemeData? drawerTheme,
    DropdownMenuThemeData? dropdownMenuTheme,
    ElevatedButtonThemeData? elevatedButtonTheme,
    ExpansionTileThemeData? expansionTileTheme,
    FilledButtonThemeData? filledButtonTheme,
    FloatingActionButtonThemeData? floatingActionButtonTheme,
    IconButtonThemeData? iconButtonTheme,
    ListTileThemeData? listTileTheme,
    MenuBarThemeData? menuBarTheme,
    MenuButtonThemeData? menuButtonTheme,
    MenuThemeData? menuTheme,
    NavigationBarThemeData? navigationBarTheme,
    NavigationDrawerThemeData? navigationDrawerTheme,
    NavigationRailThemeData? navigationRailTheme,
    OutlinedButtonThemeData? outlinedButtonTheme,
    PopupMenuThemeData? popupMenuTheme,
    ProgressIndicatorThemeData? progressIndicatorTheme,
    RadioThemeData? radioTheme,
    SearchBarThemeData? searchBarTheme,
    SearchViewThemeData? searchViewTheme,
    SegmentedButtonThemeData? segmentedButtonTheme,
    SliderThemeData? sliderTheme,
    SnackBarThemeData? snackBarTheme,
    SwitchThemeData? switchTheme,
    TabBarTheme? tabBarTheme,
    TextButtonThemeData? textButtonTheme,
    TextSelectionThemeData? textSelectionTheme,
    TimePickerThemeData? timePickerTheme,
    ToggleButtonsThemeData? toggleButtonsTheme,
    TooltipThemeData? tooltipTheme,
    // TODO(Piinks): Remove these once they are removed from the super class.
    @Deprecated('Do not use') Color? toggleableActiveColor,
    @Deprecated('Do not use') Color? errorColor,
    @Deprecated('Do not use') Color? backgroundColor,
    @Deprecated('Do not use') Color? bottomAppBarColor,
    @Deprecated('Do not use') bool? useMaterial3,
  }) {
    cupertinoOverrideTheme = cupertinoOverrideTheme?.noDefault();
    return LegacyThemeData.raw(
      // For the sanity of the reader, make sure these properties are in the
      // same order in every place that they are separated by section comments
      // (e.g. GENERAL CONFIGURATION). Each section except for deprecations
      // should be alphabetical by symbol name.

      // GENERAL CONFIGURATION
      adaptationMap: adaptations != null
          ? _createAdaptationMap(adaptations)
          : adaptationMap,
      applyElevationOverlayColor:
          applyElevationOverlayColor ?? this.applyElevationOverlayColor,
      cupertinoOverrideTheme:
          cupertinoOverrideTheme ?? this.cupertinoOverrideTheme,
      extensions: (extensions != null)
          ? _themeExtensionIterableToMap(extensions)
          : this.extensions,
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      materialTapTargetSize:
          materialTapTargetSize ?? this.materialTapTargetSize,
      pageTransitionsTheme: pageTransitionsTheme ?? this.pageTransitionsTheme,
      platform: platform ?? this.platform,
      scrollbarTheme: scrollbarTheme ?? this.scrollbarTheme,
      splashFactory: splashFactory ?? this.splashFactory,
      visualDensity: visualDensity ?? this.visualDensity,
      // COLOR
      canvasColor: canvasColor ?? this.canvasColor,
      cardColor: cardColor ?? this.cardColor,
      colorScheme:
          (colorScheme ?? this.colorScheme).copyWith(brightness: brightness),
      dialogBackgroundColor:
          dialogBackgroundColor ?? this.dialogBackgroundColor,
      disabledColor: disabledColor ?? this.disabledColor,
      dividerColor: dividerColor ?? this.dividerColor,
      focusColor: focusColor ?? this.focusColor,
      highlightColor: highlightColor ?? this.highlightColor,
      hintColor: hintColor ?? this.hintColor,
      hoverColor: hoverColor ?? this.hoverColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      primaryColor: primaryColor ?? this.primaryColor,
      primaryColorDark: primaryColorDark ?? this.primaryColorDark,
      primaryColorLight: primaryColorLight ?? this.primaryColorLight,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      secondaryHeaderColor: secondaryHeaderColor ?? this.secondaryHeaderColor,
      shadowColor: shadowColor ?? this.shadowColor,
      splashColor: splashColor ?? this.splashColor,
      unselectedWidgetColor:
          unselectedWidgetColor ?? this.unselectedWidgetColor,
      // TYPOGRAPHY & ICONOGRAPHY
      iconTheme: iconTheme ?? this.iconTheme,
      primaryIconTheme: primaryIconTheme ?? this.primaryIconTheme,
      primaryTextTheme: primaryTextTheme ?? this.primaryTextTheme,
      textTheme: textTheme ?? this.textTheme,
      typography: typography ?? this.typography,
      // COMPONENT THEMES
      actionIconTheme: actionIconTheme ?? this.actionIconTheme,
      appBarTheme: appBarTheme ?? this.appBarTheme,
      badgeTheme: badgeTheme ?? this.badgeTheme,
      bannerTheme: bannerTheme ?? this.bannerTheme,
      bottomAppBarTheme: bottomAppBarTheme ?? this.bottomAppBarTheme,
      bottomNavigationBarTheme:
          bottomNavigationBarTheme ?? this.bottomNavigationBarTheme,
      bottomSheetTheme: bottomSheetTheme ?? this.bottomSheetTheme,
      buttonBarTheme: buttonBarTheme ?? this.buttonBarTheme,
      buttonTheme: buttonTheme ?? this.buttonTheme,
      cardTheme: cardTheme ?? this.cardTheme,
      checkboxTheme: checkboxTheme ?? this.checkboxTheme,
      chipTheme: chipTheme ?? this.chipTheme,
      dataTableTheme: dataTableTheme ?? this.dataTableTheme,
      datePickerTheme: datePickerTheme ?? this.datePickerTheme,
      dialogTheme: dialogTheme ?? this.dialogTheme,
      dividerTheme: dividerTheme ?? this.dividerTheme,
      drawerTheme: drawerTheme ?? this.drawerTheme,
      dropdownMenuTheme: dropdownMenuTheme ?? this.dropdownMenuTheme,
      elevatedButtonTheme: elevatedButtonTheme ?? this.elevatedButtonTheme,
      expansionTileTheme: expansionTileTheme ?? this.expansionTileTheme,
      filledButtonTheme: filledButtonTheme ?? this.filledButtonTheme,
      floatingActionButtonTheme:
          floatingActionButtonTheme ?? this.floatingActionButtonTheme,
      iconButtonTheme: iconButtonTheme ?? this.iconButtonTheme,
      listTileTheme: listTileTheme ?? this.listTileTheme,
      menuBarTheme: menuBarTheme ?? this.menuBarTheme,
      menuButtonTheme: menuButtonTheme ?? this.menuButtonTheme,
      menuTheme: menuTheme ?? this.menuTheme,
      navigationBarTheme: navigationBarTheme ?? this.navigationBarTheme,
      navigationDrawerTheme:
          navigationDrawerTheme ?? this.navigationDrawerTheme,
      navigationRailTheme: navigationRailTheme ?? this.navigationRailTheme,
      outlinedButtonTheme: outlinedButtonTheme ?? this.outlinedButtonTheme,
      popupMenuTheme: popupMenuTheme ?? this.popupMenuTheme,
      progressIndicatorTheme:
          progressIndicatorTheme ?? this.progressIndicatorTheme,
      radioTheme: radioTheme ?? this.radioTheme,
      searchBarTheme: searchBarTheme ?? this.searchBarTheme,
      searchViewTheme: searchViewTheme ?? this.searchViewTheme,
      segmentedButtonTheme: segmentedButtonTheme ?? this.segmentedButtonTheme,
      sliderTheme: sliderTheme ?? this.sliderTheme,
      snackBarTheme: snackBarTheme ?? this.snackBarTheme,
      switchTheme: switchTheme ?? this.switchTheme,
      tabBarTheme: tabBarTheme ?? this.tabBarTheme,
      textButtonTheme: textButtonTheme ?? this.textButtonTheme,
      textSelectionTheme: textSelectionTheme ?? this.textSelectionTheme,
      timePickerTheme: timePickerTheme ?? this.timePickerTheme,
      toggleButtonsTheme: toggleButtonsTheme ?? this.toggleButtonsTheme,
      tooltipTheme: tooltipTheme ?? this.tooltipTheme,
    );
  }

  /// Linearly interpolate between two themes.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static LegacyThemeData lerp(LegacyThemeData a, LegacyThemeData b, double t) {
    if (identical(a, b)) {
      return a;
    }
    return LegacyThemeData.raw(
      // For the sanity of the reader, make sure these properties are in the same
      // order in every place that they are separated by section comments (e.g.
      // GENERAL CONFIGURATION). Each section except for deprecations should be
      // alphabetical by symbol name.

      // GENERAL CONFIGURATION
      adaptationMap: t < 0.5 ? a.adaptationMap : b.adaptationMap,
      applyElevationOverlayColor:
          t < 0.5 ? a.applyElevationOverlayColor : b.applyElevationOverlayColor,
      cupertinoOverrideTheme:
          t < 0.5 ? a.cupertinoOverrideTheme : b.cupertinoOverrideTheme,
      extensions: _lerpThemeExtensions(a, b, t),
      inputDecorationTheme:
          t < 0.5 ? a.inputDecorationTheme : b.inputDecorationTheme,
      materialTapTargetSize:
          t < 0.5 ? a.materialTapTargetSize : b.materialTapTargetSize,
      pageTransitionsTheme:
          t < 0.5 ? a.pageTransitionsTheme : b.pageTransitionsTheme,
      platform: t < 0.5 ? a.platform : b.platform,
      scrollbarTheme: ScrollbarThemeData.lerp(
        a.scrollbarTheme,
        b.scrollbarTheme,
        t,
      ),
      splashFactory: t < 0.5 ? a.splashFactory : b.splashFactory,
      visualDensity: VisualDensity.lerp(a.visualDensity, b.visualDensity, t),
      // COLOR
      canvasColor: Color.lerp(a.canvasColor, b.canvasColor, t)!,
      cardColor: Color.lerp(a.cardColor, b.cardColor, t)!,
      colorScheme: ColorScheme.lerp(a.colorScheme, b.colorScheme, t),
      dialogBackgroundColor: Color.lerp(
        a.dialogBackgroundColor,
        b.dialogBackgroundColor,
        t,
      )!,
      disabledColor: Color.lerp(a.disabledColor, b.disabledColor, t)!,
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t)!,
      focusColor: Color.lerp(a.focusColor, b.focusColor, t)!,
      highlightColor: Color.lerp(a.highlightColor, b.highlightColor, t)!,
      hintColor: Color.lerp(a.hintColor, b.hintColor, t)!,
      hoverColor: Color.lerp(a.hoverColor, b.hoverColor, t)!,
      indicatorColor: Color.lerp(a.indicatorColor, b.indicatorColor, t)!,
      primaryColor: Color.lerp(a.primaryColor, b.primaryColor, t)!,
      primaryColorDark: Color.lerp(a.primaryColorDark, b.primaryColorDark, t)!,
      primaryColorLight: Color.lerp(
        a.primaryColorLight,
        b.primaryColorLight,
        t,
      )!,
      scaffoldBackgroundColor: Color.lerp(
        a.scaffoldBackgroundColor,
        b.scaffoldBackgroundColor,
        t,
      )!,
      secondaryHeaderColor: Color.lerp(
        a.secondaryHeaderColor,
        b.secondaryHeaderColor,
        t,
      )!,
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t)!,
      splashColor: Color.lerp(a.splashColor, b.splashColor, t)!,
      unselectedWidgetColor: Color.lerp(
        a.unselectedWidgetColor,
        b.unselectedWidgetColor,
        t,
      )!,
      // TYPOGRAPHY & ICONOGRAPHY
      iconTheme: IconThemeData.lerp(a.iconTheme, b.iconTheme, t),
      primaryIconTheme:
          IconThemeData.lerp(a.primaryIconTheme, b.primaryIconTheme, t),
      primaryTextTheme: TextTheme.lerp(
        a.primaryTextTheme,
        b.primaryTextTheme,
        t,
      ),
      textTheme: TextTheme.lerp(a.textTheme, b.textTheme, t),
      typography: Typography.lerp(a.typography, b.typography, t),
      // COMPONENT THEMES
      actionIconTheme: ActionIconThemeData.lerp(
        a.actionIconTheme,
        b.actionIconTheme,
        t,
      ),
      appBarTheme: AppBarTheme.lerp(a.appBarTheme, b.appBarTheme, t),
      badgeTheme: BadgeThemeData.lerp(a.badgeTheme, b.badgeTheme, t),
      bannerTheme: MaterialBannerThemeData.lerp(
        a.bannerTheme,
        b.bannerTheme,
        t,
      ),
      bottomAppBarTheme: BottomAppBarTheme.lerp(
        a.bottomAppBarTheme,
        b.bottomAppBarTheme,
        t,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData.lerp(
        a.bottomNavigationBarTheme,
        b.bottomNavigationBarTheme,
        t,
      ),
      bottomSheetTheme: BottomSheetThemeData.lerp(
        a.bottomSheetTheme,
        b.bottomSheetTheme,
        t,
      )!,
      buttonBarTheme: ButtonBarThemeData.lerp(
        a.buttonBarTheme,
        b.buttonBarTheme,
        t,
      )!,
      buttonTheme: t < 0.5 ? a.buttonTheme : b.buttonTheme,
      cardTheme: CardTheme.lerp(a.cardTheme, b.cardTheme, t),
      checkboxTheme: CheckboxThemeData.lerp(
        a.checkboxTheme,
        b.checkboxTheme,
        t,
      ),
      chipTheme: ChipThemeData.lerp(a.chipTheme, b.chipTheme, t)!,
      dataTableTheme: DataTableThemeData.lerp(
        a.dataTableTheme,
        b.dataTableTheme,
        t,
      ),
      datePickerTheme: DatePickerThemeData.lerp(
        a.datePickerTheme,
        b.datePickerTheme,
        t,
      ),
      dialogTheme: DialogTheme.lerp(a.dialogTheme, b.dialogTheme, t),
      dividerTheme: DividerThemeData.lerp(a.dividerTheme, b.dividerTheme, t),
      drawerTheme: DrawerThemeData.lerp(a.drawerTheme, b.drawerTheme, t)!,
      dropdownMenuTheme: DropdownMenuThemeData.lerp(
        a.dropdownMenuTheme,
        b.dropdownMenuTheme,
        t,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData.lerp(
        a.elevatedButtonTheme,
        b.elevatedButtonTheme,
        t,
      )!,
      expansionTileTheme: ExpansionTileThemeData.lerp(
        a.expansionTileTheme,
        b.expansionTileTheme,
        t,
      )!,
      filledButtonTheme: FilledButtonThemeData.lerp(
        a.filledButtonTheme,
        b.filledButtonTheme,
        t,
      )!,
      floatingActionButtonTheme: FloatingActionButtonThemeData.lerp(
        a.floatingActionButtonTheme,
        b.floatingActionButtonTheme,
        t,
      )!,
      iconButtonTheme: IconButtonThemeData.lerp(
        a.iconButtonTheme,
        b.iconButtonTheme,
        t,
      )!,
      listTileTheme: ListTileThemeData.lerp(
        a.listTileTheme,
        b.listTileTheme,
        t,
      )!,
      menuBarTheme: MenuBarThemeData.lerp(a.menuBarTheme, b.menuBarTheme, t)!,
      menuButtonTheme: MenuButtonThemeData.lerp(
        a.menuButtonTheme,
        b.menuButtonTheme,
        t,
      )!,
      menuTheme: MenuThemeData.lerp(a.menuTheme, b.menuTheme, t)!,
      navigationBarTheme: NavigationBarThemeData.lerp(
        a.navigationBarTheme,
        b.navigationBarTheme,
        t,
      )!,
      navigationDrawerTheme: NavigationDrawerThemeData.lerp(
        a.navigationDrawerTheme,
        b.navigationDrawerTheme,
        t,
      )!,
      navigationRailTheme: NavigationRailThemeData.lerp(
        a.navigationRailTheme,
        b.navigationRailTheme,
        t,
      )!,
      outlinedButtonTheme: OutlinedButtonThemeData.lerp(
        a.outlinedButtonTheme,
        b.outlinedButtonTheme,
        t,
      )!,
      popupMenuTheme: PopupMenuThemeData.lerp(
        a.popupMenuTheme,
        b.popupMenuTheme,
        t,
      )!,
      progressIndicatorTheme: ProgressIndicatorThemeData.lerp(
        a.progressIndicatorTheme,
        b.progressIndicatorTheme,
        t,
      )!,
      radioTheme: RadioThemeData.lerp(a.radioTheme, b.radioTheme, t),
      searchBarTheme: SearchBarThemeData.lerp(
        a.searchBarTheme,
        b.searchBarTheme,
        t,
      )!,
      searchViewTheme: SearchViewThemeData.lerp(
        a.searchViewTheme,
        b.searchViewTheme,
        t,
      )!,
      segmentedButtonTheme: SegmentedButtonThemeData.lerp(
        a.segmentedButtonTheme,
        b.segmentedButtonTheme,
        t,
      ),
      sliderTheme: SliderThemeData.lerp(a.sliderTheme, b.sliderTheme, t),
      snackBarTheme: SnackBarThemeData.lerp(
        a.snackBarTheme,
        b.snackBarTheme,
        t,
      ),
      switchTheme: SwitchThemeData.lerp(a.switchTheme, b.switchTheme, t),
      tabBarTheme: TabBarTheme.lerp(a.tabBarTheme, b.tabBarTheme, t),
      textButtonTheme: TextButtonThemeData.lerp(
        a.textButtonTheme,
        b.textButtonTheme,
        t,
      )!,
      textSelectionTheme: TextSelectionThemeData.lerp(
        a.textSelectionTheme,
        b.textSelectionTheme,
        t,
      )!,
      timePickerTheme: TimePickerThemeData.lerp(
        a.timePickerTheme,
        b.timePickerTheme,
        t,
      ),
      toggleButtonsTheme: ToggleButtonsThemeData.lerp(
        a.toggleButtonsTheme,
        b.toggleButtonsTheme,
        t,
      )!,
      tooltipTheme: TooltipThemeData.lerp(a.tooltipTheme, b.tooltipTheme, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LegacyThemeData &&
        // For the sanity of the reader, make sure these properties are in the
        // same order in every place that they are separated by section comments
        // (e.g. GENERAL CONFIGURATION). Each section except for deprecations
        // should be alphabetical by symbol name.

        // GENERAL CONFIGURATION
        mapEquals(other.adaptationMap, adaptationMap) &&
        other.applyElevationOverlayColor == applyElevationOverlayColor &&
        other.cupertinoOverrideTheme == cupertinoOverrideTheme &&
        mapEquals(other.extensions, extensions) &&
        other.inputDecorationTheme == inputDecorationTheme &&
        other.materialTapTargetSize == materialTapTargetSize &&
        other.pageTransitionsTheme == pageTransitionsTheme &&
        other.platform == platform &&
        other.scrollbarTheme == scrollbarTheme &&
        other.splashFactory == splashFactory &&
        other.visualDensity == visualDensity &&
        // COLOR
        other.canvasColor == canvasColor &&
        other.cardColor == cardColor &&
        other.colorScheme == colorScheme &&
        other.dialogBackgroundColor == dialogBackgroundColor &&
        other.disabledColor == disabledColor &&
        other.dividerColor == dividerColor &&
        other.focusColor == focusColor &&
        other.highlightColor == highlightColor &&
        other.hintColor == hintColor &&
        other.hoverColor == hoverColor &&
        other.indicatorColor == indicatorColor &&
        other.primaryColor == primaryColor &&
        other.primaryColorDark == primaryColorDark &&
        other.primaryColorLight == primaryColorLight &&
        other.scaffoldBackgroundColor == scaffoldBackgroundColor &&
        other.secondaryHeaderColor == secondaryHeaderColor &&
        other.shadowColor == shadowColor &&
        other.splashColor == splashColor &&
        other.unselectedWidgetColor == unselectedWidgetColor &&
        // TYPOGRAPHY & ICONOGRAPHY
        other.iconTheme == iconTheme &&
        other.primaryIconTheme == primaryIconTheme &&
        other.primaryTextTheme == primaryTextTheme &&
        other.textTheme == textTheme &&
        other.typography == typography &&
        // COMPONENT THEMES
        other.actionIconTheme == actionIconTheme &&
        other.appBarTheme == appBarTheme &&
        other.badgeTheme == badgeTheme &&
        other.bannerTheme == bannerTheme &&
        other.bottomAppBarTheme == bottomAppBarTheme &&
        other.bottomNavigationBarTheme == bottomNavigationBarTheme &&
        other.bottomSheetTheme == bottomSheetTheme &&
        other.buttonBarTheme == buttonBarTheme &&
        other.buttonTheme == buttonTheme &&
        other.cardTheme == cardTheme &&
        other.checkboxTheme == checkboxTheme &&
        other.chipTheme == chipTheme &&
        other.dataTableTheme == dataTableTheme &&
        other.datePickerTheme == datePickerTheme &&
        other.dialogTheme == dialogTheme &&
        other.dividerTheme == dividerTheme &&
        other.drawerTheme == drawerTheme &&
        other.dropdownMenuTheme == dropdownMenuTheme &&
        other.elevatedButtonTheme == elevatedButtonTheme &&
        other.expansionTileTheme == expansionTileTheme &&
        other.filledButtonTheme == filledButtonTheme &&
        other.floatingActionButtonTheme == floatingActionButtonTheme &&
        other.iconButtonTheme == iconButtonTheme &&
        other.listTileTheme == listTileTheme &&
        other.menuBarTheme == menuBarTheme &&
        other.menuButtonTheme == menuButtonTheme &&
        other.menuTheme == menuTheme &&
        other.navigationBarTheme == navigationBarTheme &&
        other.navigationDrawerTheme == navigationDrawerTheme &&
        other.navigationRailTheme == navigationRailTheme &&
        other.outlinedButtonTheme == outlinedButtonTheme &&
        other.popupMenuTheme == popupMenuTheme &&
        other.progressIndicatorTheme == progressIndicatorTheme &&
        other.radioTheme == radioTheme &&
        other.searchBarTheme == searchBarTheme &&
        other.searchViewTheme == searchViewTheme &&
        other.segmentedButtonTheme == segmentedButtonTheme &&
        other.sliderTheme == sliderTheme &&
        other.snackBarTheme == snackBarTheme &&
        other.switchTheme == switchTheme &&
        other.tabBarTheme == tabBarTheme &&
        other.textButtonTheme == textButtonTheme &&
        other.textSelectionTheme == textSelectionTheme &&
        other.timePickerTheme == timePickerTheme &&
        other.toggleButtonsTheme == toggleButtonsTheme &&
        other.tooltipTheme == tooltipTheme;
  }

  @override
  int get hashCode {
    final List<Object?> values = <Object?>[
      // For the sanity of the reader, make sure these properties are in the same
      // order in every place that they are separated by section comments (e.g.
      // GENERAL CONFIGURATION). Each section except for deprecations should be
      // alphabetical by symbol name.

      // GENERAL CONFIGURATION
      ...adaptationMap.keys,
      ...adaptationMap.values,
      applyElevationOverlayColor,
      cupertinoOverrideTheme,
      ...extensions.keys,
      ...extensions.values,
      inputDecorationTheme,
      materialTapTargetSize,
      pageTransitionsTheme,
      platform,
      scrollbarTheme,
      splashFactory,
      visualDensity,
      // COLOR
      canvasColor,
      cardColor,
      colorScheme,
      dialogBackgroundColor,
      disabledColor,
      dividerColor,
      focusColor,
      highlightColor,
      hintColor,
      hoverColor,
      indicatorColor,
      primaryColor,
      primaryColorDark,
      primaryColorLight,
      scaffoldBackgroundColor,
      secondaryHeaderColor,
      shadowColor,
      splashColor,
      unselectedWidgetColor,
      // TYPOGRAPHY & ICONOGRAPHY
      iconTheme,
      primaryIconTheme,
      primaryTextTheme,
      textTheme,
      typography,
      // COMPONENT THEMES
      actionIconTheme,
      appBarTheme,
      badgeTheme,
      bannerTheme,
      bottomAppBarTheme,
      bottomNavigationBarTheme,
      bottomSheetTheme,
      buttonBarTheme,
      buttonTheme,
      cardTheme,
      checkboxTheme,
      chipTheme,
      dataTableTheme,
      datePickerTheme,
      dialogTheme,
      dividerTheme,
      drawerTheme,
      dropdownMenuTheme,
      elevatedButtonTheme,
      expansionTileTheme,
      filledButtonTheme,
      floatingActionButtonTheme,
      iconButtonTheme,
      listTileTheme,
      menuBarTheme,
      menuButtonTheme,
      menuTheme,
      navigationBarTheme,
      navigationDrawerTheme,
      navigationRailTheme,
      outlinedButtonTheme,
      popupMenuTheme,
      progressIndicatorTheme,
      radioTheme,
      searchBarTheme,
      searchViewTheme,
      segmentedButtonTheme,
      sliderTheme,
      snackBarTheme,
      switchTheme,
      tabBarTheme,
      textButtonTheme,
      textSelectionTheme,
      timePickerTheme,
      toggleButtonsTheme,
      tooltipTheme,
    ];
    return Object.hashAll(values);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final ThemeData defaultData = ThemeData.fallback();
    // For the sanity of the reader, make sure these properties are in the same
    // order in every place that they are separated by section comments (e.g.
    // GENERAL CONFIGURATION).

    // GENERAL CONFIGURATION
    properties.add(IterableProperty<Adaptation<dynamic>>(
      'adaptations',
      adaptationMap.values,
      defaultValue: defaultData.adaptationMap.values,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<bool>(
      'applyElevationOverlayColor',
      applyElevationOverlayColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<NoDefaultCupertinoThemeData>(
      'cupertinoOverrideTheme',
      cupertinoOverrideTheme,
      defaultValue: defaultData.cupertinoOverrideTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(IterableProperty<ThemeExtension<dynamic>>(
      'extensions',
      extensions.values,
      defaultValue: defaultData.extensions.values,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<InputDecorationTheme>(
      'inputDecorationTheme',
      inputDecorationTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<MaterialTapTargetSize>(
      'materialTapTargetSize',
      materialTapTargetSize,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<PageTransitionsTheme>(
      'pageTransitionsTheme',
      pageTransitionsTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(EnumProperty<TargetPlatform>(
      'platform',
      platform,
      defaultValue: defaultTargetPlatform,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ScrollbarThemeData>(
      'scrollbarTheme',
      scrollbarTheme,
      defaultValue: defaultData.scrollbarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<InteractiveInkFeatureFactory>(
      'splashFactory',
      splashFactory,
      defaultValue: defaultData.splashFactory,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<VisualDensity>(
      'visualDensity',
      visualDensity,
      defaultValue: defaultData.visualDensity,
      level: DiagnosticLevel.debug,
    ));
    // COLORS
    properties.add(ColorProperty(
      'canvasColor',
      canvasColor,
      defaultValue: defaultData.canvasColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'cardColor',
      cardColor,
      defaultValue: defaultData.cardColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ColorScheme>(
      'colorScheme',
      colorScheme,
      defaultValue: defaultData.colorScheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'dialogBackgroundColor',
      dialogBackgroundColor,
      defaultValue: defaultData.dialogBackgroundColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'disabledColor',
      disabledColor,
      defaultValue: defaultData.disabledColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'dividerColor',
      dividerColor,
      defaultValue: defaultData.dividerColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'focusColor',
      focusColor,
      defaultValue: defaultData.focusColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'highlightColor',
      highlightColor,
      defaultValue: defaultData.highlightColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'hintColor',
      hintColor,
      defaultValue: defaultData.hintColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'hoverColor',
      hoverColor,
      defaultValue: defaultData.hoverColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'indicatorColor',
      indicatorColor,
      defaultValue: defaultData.indicatorColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'primaryColorDark',
      primaryColorDark,
      defaultValue: defaultData.primaryColorDark,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'primaryColorLight',
      primaryColorLight,
      defaultValue: defaultData.primaryColorLight,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'primaryColor',
      primaryColor,
      defaultValue: defaultData.primaryColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'scaffoldBackgroundColor',
      scaffoldBackgroundColor,
      defaultValue: defaultData.scaffoldBackgroundColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'secondaryHeaderColor',
      secondaryHeaderColor,
      defaultValue: defaultData.secondaryHeaderColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'shadowColor',
      shadowColor,
      defaultValue: defaultData.shadowColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'splashColor',
      splashColor,
      defaultValue: defaultData.splashColor,
      level: DiagnosticLevel.debug,
    ));
    properties.add(ColorProperty(
      'unselectedWidgetColor',
      unselectedWidgetColor,
      defaultValue: defaultData.unselectedWidgetColor,
      level: DiagnosticLevel.debug,
    ));
    // TYPOGRAPHY & ICONOGRAPHY
    properties.add(DiagnosticsProperty<IconThemeData>(
      'iconTheme',
      iconTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<IconThemeData>(
      'primaryIconTheme',
      primaryIconTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<TextTheme>(
      'primaryTextTheme',
      primaryTextTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<TextTheme>(
      'textTheme',
      textTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<Typography>(
      'typography',
      typography,
      defaultValue: defaultData.typography,
      level: DiagnosticLevel.debug,
    ));
    // COMPONENT THEMES
    properties.add(DiagnosticsProperty<ActionIconThemeData>(
      'actionIconTheme',
      actionIconTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<AppBarTheme>(
      'appBarTheme',
      appBarTheme,
      defaultValue: defaultData.appBarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<BadgeThemeData>(
      'badgeTheme',
      badgeTheme,
      defaultValue: defaultData.badgeTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<MaterialBannerThemeData>(
      'bannerTheme',
      bannerTheme,
      defaultValue: defaultData.bannerTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<BottomAppBarTheme>(
      'bottomAppBarTheme',
      bottomAppBarTheme,
      defaultValue: defaultData.bottomAppBarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<BottomNavigationBarThemeData>(
      'bottomNavigationBarTheme',
      bottomNavigationBarTheme,
      defaultValue: defaultData.bottomNavigationBarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<BottomSheetThemeData>(
      'bottomSheetTheme',
      bottomSheetTheme,
      defaultValue: defaultData.bottomSheetTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ButtonBarThemeData>(
      'buttonBarTheme',
      buttonBarTheme,
      defaultValue: defaultData.buttonBarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ButtonThemeData>(
      'buttonTheme',
      buttonTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<CardTheme>(
      'cardTheme',
      cardTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<CheckboxThemeData>(
      'checkboxTheme',
      checkboxTheme,
      defaultValue: defaultData.checkboxTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ChipThemeData>(
      'chipTheme',
      chipTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<DataTableThemeData>(
      'dataTableTheme',
      dataTableTheme,
      defaultValue: defaultData.dataTableTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<DatePickerThemeData>(
      'datePickerTheme',
      datePickerTheme,
      defaultValue: defaultData.datePickerTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<DialogTheme>(
      'dialogTheme',
      dialogTheme,
      defaultValue: defaultData.dialogTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<DividerThemeData>(
      'dividerTheme',
      dividerTheme,
      defaultValue: defaultData.dividerTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<DrawerThemeData>(
      'drawerTheme',
      drawerTheme,
      defaultValue: defaultData.drawerTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<DropdownMenuThemeData>(
      'dropdownMenuTheme',
      dropdownMenuTheme,
      defaultValue: defaultData.dropdownMenuTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ElevatedButtonThemeData>(
      'elevatedButtonTheme',
      elevatedButtonTheme,
      defaultValue: defaultData.elevatedButtonTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ExpansionTileThemeData>(
      'expansionTileTheme',
      expansionTileTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<FilledButtonThemeData>(
      'filledButtonTheme',
      filledButtonTheme,
      defaultValue: defaultData.filledButtonTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<FloatingActionButtonThemeData>(
      'floatingActionButtonTheme',
      floatingActionButtonTheme,
      defaultValue: defaultData.floatingActionButtonTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<IconButtonThemeData>(
      'iconButtonTheme',
      iconButtonTheme,
      defaultValue: defaultData.iconButtonTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ListTileThemeData>(
      'listTileTheme',
      listTileTheme,
      defaultValue: defaultData.listTileTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<MenuBarThemeData>(
      'menuBarTheme',
      menuBarTheme,
      defaultValue: defaultData.menuBarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<MenuButtonThemeData>(
      'menuButtonTheme',
      menuButtonTheme,
      defaultValue: defaultData.menuButtonTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<MenuThemeData>(
      'menuTheme',
      menuTheme,
      defaultValue: defaultData.menuTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<NavigationBarThemeData>(
      'navigationBarTheme',
      navigationBarTheme,
      defaultValue: defaultData.navigationBarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<NavigationDrawerThemeData>(
      'navigationDrawerTheme',
      navigationDrawerTheme,
      defaultValue: defaultData.navigationDrawerTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<NavigationRailThemeData>(
      'navigationRailTheme',
      navigationRailTheme,
      defaultValue: defaultData.navigationRailTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<OutlinedButtonThemeData>(
      'outlinedButtonTheme',
      outlinedButtonTheme,
      defaultValue: defaultData.outlinedButtonTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<PopupMenuThemeData>(
      'popupMenuTheme',
      popupMenuTheme,
      defaultValue: defaultData.popupMenuTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ProgressIndicatorThemeData>(
      'progressIndicatorTheme',
      progressIndicatorTheme,
      defaultValue: defaultData.progressIndicatorTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<RadioThemeData>(
      'radioTheme',
      radioTheme,
      defaultValue: defaultData.radioTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<SearchBarThemeData>(
      'searchBarTheme',
      searchBarTheme,
      defaultValue: defaultData.searchBarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<SearchViewThemeData>(
      'searchViewTheme',
      searchViewTheme,
      defaultValue: defaultData.searchViewTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<SegmentedButtonThemeData>(
      'segmentedButtonTheme',
      segmentedButtonTheme,
      defaultValue: defaultData.segmentedButtonTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<SliderThemeData>(
      'sliderTheme',
      sliderTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<SnackBarThemeData>(
      'snackBarTheme',
      snackBarTheme,
      defaultValue: defaultData.snackBarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<SwitchThemeData>(
      'switchTheme',
      switchTheme,
      defaultValue: defaultData.switchTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<TabBarTheme>(
      'tabBarTheme',
      tabBarTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<TextButtonThemeData>(
      'textButtonTheme',
      textButtonTheme,
      defaultValue: defaultData.textButtonTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<TextSelectionThemeData>(
      'textSelectionTheme',
      textSelectionTheme,
      defaultValue: defaultData.textSelectionTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<TimePickerThemeData>(
      'timePickerTheme',
      timePickerTheme,
      defaultValue: defaultData.timePickerTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<ToggleButtonsThemeData>(
      'toggleButtonsTheme',
      toggleButtonsTheme,
      level: DiagnosticLevel.debug,
    ));
    properties.add(DiagnosticsProperty<TooltipThemeData>(
      'tooltipTheme',
      tooltipTheme,
      level: DiagnosticLevel.debug,
    ));
  }

  // PRIVATE METHODS COPIED FROM THEMEDATA ------------------------------------

  static Map<Type, Adaptation<Object>> _createAdaptationMap(
    Iterable<Adaptation<Object>> adaptations,
  ) {
    final Map<Type, Adaptation<Object>> adaptationMap =
        <Type, Adaptation<Object>>{
      for (final Adaptation<Object> adaptation in adaptations)
        adaptation.type: adaptation
    };
    return adaptationMap;
  }

  static Map<Object, ThemeExtension<dynamic>> _themeExtensionIterableToMap(
    Iterable<ThemeExtension<dynamic>> extensionsIterable,
  ) {
    return Map<Object, ThemeExtension<dynamic>>.unmodifiable(<Object,
        ThemeExtension<dynamic>>{
      // Strangely, the cast is necessary for tests to run.
      for (final ThemeExtension<dynamic> extension in extensionsIterable)
        extension.type: extension as ThemeExtension<ThemeExtension<dynamic>>,
    });
  }

  // Linearly interpolate between two [extensions].
  //
  // Includes all theme extensions in [a] and [b].
  static Map<Object, ThemeExtension<dynamic>> _lerpThemeExtensions(
    ThemeData a,
    ThemeData b,
    double t,
  ) {
    // Lerp [a].
    final Map<Object, ThemeExtension<dynamic>> newExtensions =
        a.extensions.map((Object id, ThemeExtension<dynamic> extensionA) {
      final ThemeExtension<dynamic>? extensionB = b.extensions[id];
      return MapEntry<Object, ThemeExtension<dynamic>>(
        id,
        extensionA.lerp(extensionB, t),
      );
    });
    // Add [b]-only extensions.
    newExtensions.addEntries(
      b.extensions.entries.where(
        (MapEntry<Object, ThemeExtension<dynamic>> entry) {
          return !a.extensions.containsKey(entry.key);
        },
      ),
    );

    return newExtensions;
  }
}
