// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

const menuItems = <String>['one', 'two', 'three', 'four'];

/// The test app for the [DropdownButton] and [DropdownButtonFormField] widget tests.
class TestApp extends StatefulWidget {
  const TestApp({super.key, required this.textDirection, required this.child, this.mediaSize});

  final TextDirection textDirection;
  final Widget child;
  final Size? mediaSize;

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('en', 'US'),
      delegates: const <LocalizationsDelegate<dynamic>>[
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      child: MediaQuery(
        data: const MediaQueryData().copyWith(size: widget.mediaSize),
        child: Directionality(
          textDirection: widget.textDirection,
          child: Navigator(
            onGenerateRoute: (RouteSettings settings) {
              assert(settings.name == '/');
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (BuildContext context) => widget.child,
              );
            },
          ),
        ),
      ),
    );
  }
}

List<DropdownMenuItem<String>>? _buildDropdownMenuItems(List<String>? items) {
  return items?.map<DropdownMenuItem<String>>((String item) {
    return DropdownMenuItem<String>(
      key: ValueKey<String>(item),
      value: item,
      child: Text(item, key: ValueKey<String>('${item}Text')),
    );
  }).toList();
}

/// Build a [DropdownButton] for testing.
Widget buildDropdownButton({
  Key? buttonKey,
  String? initialValue = 'two',
  ValueChanged<String?>? onChanged,
  VoidCallback? onTap,
  Widget? icon,
  Color? iconDisabledColor,
  Color? iconEnabledColor,
  double iconSize = 24.0,
  bool isDense = false,
  bool isExpanded = false,
  Widget? hint,
  Widget? disabledHint,
  Widget? underline,
  List<String>? items = menuItems,
  List<Widget> Function(BuildContext)? selectedItemBuilder,
  double? itemHeight = kMinInteractiveDimension,
  double? menuWidth,
  AlignmentDirectional alignment = AlignmentDirectional.centerStart,
  FocusNode? focusNode,
  bool autofocus = false,
  Color? focusColor,
  Color? dropdownColor,
  double? menuMaxHeight,
  EdgeInsetsGeometry? padding,
}) {
  return DropdownButton<String>(
    key: buttonKey,
    value: initialValue,
    hint: hint,
    disabledHint: disabledHint,
    onChanged: onChanged,
    onTap: onTap,
    icon: icon,
    iconSize: iconSize,
    iconDisabledColor: iconDisabledColor,
    iconEnabledColor: iconEnabledColor,
    isDense: isDense,
    isExpanded: isExpanded,
    underline: underline,
    focusNode: focusNode,
    autofocus: autofocus,
    focusColor: focusColor,
    dropdownColor: dropdownColor,
    items: _buildDropdownMenuItems(items),
    selectedItemBuilder: selectedItemBuilder,
    itemHeight: itemHeight,
    menuWidth: menuWidth,
    alignment: alignment,
    menuMaxHeight: menuMaxHeight,
    padding: padding,
  );
}

/// Build a [DropdownButtonFormField] for testing.
Widget buildDropdownFormField({
  Key? buttonKey,
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  int elevation = 8,
  String? initialValue = 'two',
  ValueChanged<String?>? onChanged,
  VoidCallback? onTap,
  Widget? icon,
  Color? iconDisabledColor,
  Color? iconEnabledColor,
  double iconSize = 24.0,
  bool isDense = false,
  bool isExpanded = false,
  Widget? hint,
  Widget? disabledHint,
  Widget? underline,
  FocusNode? focusNode,
  bool autofocus = false,
  Color? focusColor,
  Color? dropdownColor,
  double? menuMaxHeight,
  List<String>? items = menuItems,
  double? itemHeight = kMinInteractiveDimension,
  List<Widget> Function(BuildContext)? selectedItemBuilder,
  AlignmentGeometry buttonAlignment = AlignmentDirectional.centerStart,
  EdgeInsetsGeometry? padding,
  InputDecoration? decoration,
}) {
  return Form(
    child: DropdownButtonFormField<String>(
      key: buttonKey,
      autovalidateMode: autovalidateMode,
      initialValue: initialValue,
      elevation: elevation,
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged,
      onTap: onTap,
      icon: icon,
      iconSize: iconSize,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      isDense: isDense,
      isExpanded: isExpanded,
      // No underline attribute
      focusNode: focusNode,
      autofocus: autofocus,
      focusColor: focusColor,
      dropdownColor: dropdownColor,
      items: _buildDropdownMenuItems(items),
      selectedItemBuilder: selectedItemBuilder,
      itemHeight: itemHeight,
      alignment: buttonAlignment,
      menuMaxHeight: menuMaxHeight,
      padding: padding,
      decoration: decoration,
    ),
  );
}

/// Build the [TestApp] frame for the dropdown test.
Widget buildFrame({
  required Widget child,
  TextDirection textDirection = TextDirection.ltr,
  Size? mediaSize,
  AlignmentDirectional dropdownAlignment = AlignmentDirectional.center,
  bool? useMaterial3,
  InputDecorationThemeData? localInputDecorationTheme,
}) {
  return Theme(
    data: ThemeData(useMaterial3: useMaterial3),
    child: TestApp(
      textDirection: textDirection,
      mediaSize: mediaSize,
      child: Material(
        child: Align(
          alignment: dropdownAlignment,
          child: RepaintBoundary(
            child: InputDecorationTheme(data: localInputDecorationTheme, child: child),
          ),
        ),
      ),
    ),
  );
}
