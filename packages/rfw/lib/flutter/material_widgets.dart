// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// There's a lot of <Object>[] lists in this file so to avoid making this
// file even less readable we relax our usual stance on verbose typing.
// ignore_for_file: always_specify_types

// This file is hand-formatted.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'argument_decoders.dart';
import 'runtime.dart';

/// A widget library for Remote Flutter Widgets that defines widgets that are
/// implemented on the client in terms of Flutter widgets from the `material`
/// Dart library.
///
/// The following widgets are implemented:
///
///  * [AboutListTile]
///  * [AppBar]
///  * [ButtonBar]
///  * [Card]
///  * [CircularProgressIndicator]
///  * [Divider]
///  * [DrawerHeader]
///  * [ElevatedButton]
///  * [FloatingActionButton]
///  * [InkWell]
///  * [LinearProgressIndicator]
///  * [ListTile]
///  * [OutlinedButton]
///  * [Scaffold]
///  * [TextButton]
///  * [VerticalDivider]
///
/// For each, every parameter is implemented using the same name. Parameters
/// that take structured types are represented using maps, with each named
/// parameter of that type's default constructor represented by a key. The
/// conventions edscribed for [createCoreWidgets] are reused here.
///
/// In addition, the following conventions are introduced:
///
///  * Hero tags are always strings.
///
///  * [VisualDensity] is represented in the manner described in the documentation
///    of the [ArgumentDecoders.visualDensity] method.
///
/// Some features are not supported:
///
///  * [AppBar]s do not support [AppBar.bottom], [AppBar.flexibleSpace], and
///    related properties. Also, [AppBar.systemOverlayStyle] is not suported.
///
///  * Theming in general is not currently supported.
///
///  * Properties whose values are [Animation]s or based on
///    [MaterialStateProperty] are not supported.
///
///  * Features related to focus or configuring mouse support are not
///    implemented.
///
///  * Callbacks such as [Scafford.onDrawerChanged] are not exposed.
///
///  * The [Scaffold]'s floating action button position and animation features
///    are not supported.
///
/// In general, the trend will all of these unsupported features is that this
/// library doesn't support features that can't be trivially expressed using the
/// JSON-like structures of RFW. For example, [MaterialStateProperty] is
/// designed to be used with code to select the values, which doesn't work well
/// in the RFW structure.
LocalWidgetLibrary createMaterialWidgets() => LocalWidgetLibrary(_materialWidgetsDefinitions);

Map<String, LocalWidgetBuilder> get _materialWidgetsDefinitions => <String, LocalWidgetBuilder>{

  // Keep these in alphabetical order.

  'AboutListTile': (BuildContext context, DataSource source) {
    return AboutListTile(
      icon: source.optionalChild(['icon']),
      child: source.optionalChild(['child']),
      applicationName: source.v<String>(['applicationName']),
      applicationVersion: source.v<String>(['applicationVersion']),
      applicationIcon: source.optionalChild(['applicationIcon']),
      applicationLegalese: source.v<String>(['applicationLegalese']),
      aboutBoxChildren: source.childList(['aboutBoxChildren']),
      dense: source.v<bool>(['dense']),
    );
  },

  'AppBar': (BuildContext context, DataSource source) {
    // not implemented: bottom (and bottomOpacity), flexibleSpace; systemOverlayStyle
    return AppBar(
      leading: source.optionalChild(['leading']),
      automaticallyImplyLeading: source.v<bool>(['automaticallyImplyLeading']) ?? true,
      title: source.optionalChild(['title']),
      actions: source.childList(['actions']),
      elevation: source.v<double>(['elevation']),
      shadowColor: ArgumentDecoders.color(source, ['shadowColor']),
      shape: ArgumentDecoders.shapeBorder(source, ['shape']),
      backgroundColor: ArgumentDecoders.color(source, ['backgroundColor']),
      foregroundColor: ArgumentDecoders.color(source, ['foregroundColor']),
      iconTheme: ArgumentDecoders.iconThemeData(source, ['iconTheme']),
      actionsIconTheme: ArgumentDecoders.iconThemeData(source, ['actionsIconTheme']),
      primary: source.v<bool>(['primary']) ?? true,
      centerTitle: source.v<bool>(['centerTitle']),
      excludeHeaderSemantics: source.v<bool>(['excludeHeaderSemantics']) ?? false,
      titleSpacing: source.v<double>(['titleSpacing']),
      toolbarOpacity: source.v<double>(['toolbarOpacity']) ?? 1.0,
      toolbarHeight: source.v<double>(['toolbarHeight']),
      leadingWidth: source.v<double>(['leadingWidth']),
      toolbarTextStyle: ArgumentDecoders.textStyle(source, ['toolbarTextStyle']),
      titleTextStyle: ArgumentDecoders.textStyle(source, ['titleTextStyle']),
    );
  },

  'ButtonBar': (BuildContext context, DataSource source) {
    // not implemented: buttonTextTheme
    return ButtonBar(
      alignment: ArgumentDecoders.enumValue<MainAxisAlignment>(MainAxisAlignment.values, source, ['alignment']) ?? MainAxisAlignment.start,
      mainAxisSize: ArgumentDecoders.enumValue<MainAxisSize>(MainAxisSize.values, source, ['mainAxisSize']) ?? MainAxisSize.max,
      buttonMinWidth: source.v<double>(['buttonMinWidth']),
      buttonHeight: source.v<double>(['buttonHeight']),
      buttonPadding: ArgumentDecoders.edgeInsets(source, ['buttonPadding']),
      buttonAlignedDropdown: source.v<bool>(['buttonAlignedDropdown']) ?? false,
      layoutBehavior: ArgumentDecoders.enumValue<ButtonBarLayoutBehavior>(ButtonBarLayoutBehavior.values, source, ['layoutBehavior']),
      overflowDirection: ArgumentDecoders.enumValue<VerticalDirection>(VerticalDirection.values, source, ['overflowDirection']),
      overflowButtonSpacing: source.v<double>(['overflowButtonSpacing']),
      children: source.childList(['children']),
    );
  },

  'Card': (BuildContext context, DataSource source) {
    return Card(
      color: ArgumentDecoders.color(source, ['color']),
      shadowColor: ArgumentDecoders.color(source, ['shadowColor']),
      elevation: source.v<double>(['elevation']),
      shape: ArgumentDecoders.shapeBorder(source, ['shape']),
      borderOnForeground: source.v<bool>(['borderOnForeground']) ?? true,
      margin: ArgumentDecoders.edgeInsets(source, ['margin']),
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.none,
      child: source.optionalChild(['child']),
      semanticContainer: source.v<bool>(['semanticContainer']) ?? true,
    );
  },

  'CircularProgressIndicator': (BuildContext context, DataSource source) {
    // not implemented: valueColor
    return CircularProgressIndicator(
      value: source.v<double>(['value']),
      color: ArgumentDecoders.color(source, ['color']),
      backgroundColor: ArgumentDecoders.color(source, ['backgroundColor']),
      strokeWidth: source.v<double>(['strokeWidth']) ?? 4.0,
      semanticsLabel: source.v<String>(['semanticsLabel']),
      semanticsValue: source.v<String>(['semanticsValue']),
    );
  },

  'Divider': (BuildContext context, DataSource source) {
    return Divider(
      height: source.v<double>(['height']),
      thickness: source.v<double>(['thickness']),
      indent: source.v<double>(['indent']),
      endIndent: source.v<double>(['endIndent']),
      color: ArgumentDecoders.color(source, ['color']),
    );
  },

  'Drawer': (BuildContext context, DataSource source) {
    return Drawer(
      elevation: source.v<double>(['elevation']) ?? 16.0,
      semanticLabel: source.v<String>(['semanticLabel']),
      child: source.optionalChild(['child']),
    );
  },

  'DrawerHeader': (BuildContext context, DataSource source) {
    return DrawerHeader(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      decoration: ArgumentDecoders.decoration(source, ['decoration']),
      margin: ArgumentDecoders.edgeInsets(source, ['margin']) ?? const EdgeInsets.only(bottom: 8.0),
      padding: ArgumentDecoders.edgeInsets(source, ['padding']) ?? const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: source.optionalChild(['child']),
    );
  },

  'ElevatedButton': (BuildContext context, DataSource source) {
    // not implemented: buttonStyle, focusNode
    return ElevatedButton(
      onPressed: source.voidHandler(['onPressed']),
      onLongPress: source.voidHandler(['onLongPress']),
      autofocus: source.v<bool>(['autofocus']) ?? false,
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.none,
      child: source.child(['child']),
    );
  },

  'FloatingActionButton': (BuildContext context, DataSource source) {
    // not implemented: mouseCursor, focusNode
    return FloatingActionButton(
      child: source.child(['child']),
      tooltip: source.v<String>(['tooltip']),
      foregroundColor: ArgumentDecoders.color(source, ['foregroundColor']),
      backgroundColor: ArgumentDecoders.color(source, ['backgroundColor']),
      focusColor: ArgumentDecoders.color(source, ['focusColor']),
      hoverColor: ArgumentDecoders.color(source, ['hoverColor']),
      splashColor: ArgumentDecoders.color(source, ['splashColor']),
      heroTag: source.v<String>(['heroTag']),
      elevation: source.v<double>(['elevation']),
      focusElevation: source.v<double>(['focusElevation']),
      hoverElevation: source.v<double>(['hoverElevation']),
      highlightElevation: source.v<double>(['highlightElevation']),
      disabledElevation: source.v<double>(['disabledElevation']),
      onPressed: source.voidHandler(['onPressed']),
      mini: source.v<bool>(['mini']) ?? false,
      shape: ArgumentDecoders.shapeBorder(source, ['shape']),
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.none,
      autofocus: source.v<bool>(['autofocus']) ?? false,
      materialTapTargetSize: ArgumentDecoders.enumValue<MaterialTapTargetSize>(MaterialTapTargetSize.values, source, ['materialTapTargetSize']),
      isExtended: source.v<bool>(['isExtended']) ?? false,
      enableFeedback: source.v<bool>(['enableFeedback']),
    );
  },

  'InkWell': (BuildContext context, DataSource source) {
    // not implemented: onHighlightChanged, onHover; mouseCursor; focusColor, hoverColor, highlightColor, overlayColor, splashColor; splashFactory; focusNode, onFocusChange
    return InkWell(
      onTap: source.voidHandler(['onTap']),
      onDoubleTap: source.voidHandler(['onDoubleTap']),
      onLongPress: source.voidHandler(['onLongPress']),
      onTapDown: source.handler(['onTapDown'], (VoidCallback trigger) => (TapDownDetails details) => trigger()),
      onTapCancel: source.voidHandler(['onTapCancel']),
      radius: source.v<double>(['radius']),
      borderRadius: ArgumentDecoders.borderRadius(source, ['borderRadius'])?.resolve(Directionality.of(context)),
      customBorder: ArgumentDecoders.shapeBorder(source, ['customBorder']),
      enableFeedback: source.v<bool>(['enableFeedback']) ?? true,
      excludeFromSemantics: source.v<bool>(['excludeFromSemantics']) ?? false,
      autofocus: source.v<bool>(['autofocus']) ?? false,
      child: source.optionalChild(['child']),
    );
  },

  'LinearProgressIndicator': (BuildContext context, DataSource source) {
    // not implemented: valueColor
    return LinearProgressIndicator(
      value: source.v<double>(['value']),
      color: ArgumentDecoders.color(source, ['color']),
      backgroundColor: ArgumentDecoders.color(source, ['backgroundColor']),
      minHeight: source.v<double>(['minHeight']),
      semanticsLabel: source.v<String>(['semanticsLabel']),
      semanticsValue: source.v<String>(['semanticsValue']),
    );
  },

  'ListTile': (BuildContext context, DataSource source) {
    // not implemented: mouseCursor, focusNode
    return ListTile(
      leading: source.optionalChild(['leading']),
      title: source.optionalChild(['title']),
      subtitle: source.optionalChild(['subtitle']),
      trailing: source.optionalChild(['trailing']),
      isThreeLine: source.v<bool>(['isThreeLine']) ?? false,
      dense: source.v<bool>(['dense']),
      visualDensity: ArgumentDecoders.visualDensity(source, ['visualDensity']),
      shape: ArgumentDecoders.shapeBorder(source, ['shape']),
      contentPadding: ArgumentDecoders.edgeInsets(source, ['contentPadding']),
      enabled: source.v<bool>(['enabled']) ?? true,
      onTap: source.voidHandler(['onTap']),
      onLongPress: source.voidHandler(['onLongPress']),
      selected: source.v<bool>(['selected']) ?? false,
      focusColor: ArgumentDecoders.color(source, ['focusColor']),
      hoverColor: ArgumentDecoders.color(source, ['hoverColor']),
      autofocus: source.v<bool>(['autofocus']) ?? false,
      tileColor: ArgumentDecoders.color(source, ['tileColor']),
      selectedTileColor: ArgumentDecoders.color(source, ['selectedTileColor']),
      enableFeedback: source.v<bool>(['enableFeedback']),
      horizontalTitleGap: source.v<double>(['horizontalTitleGap']),
      minVerticalPadding: source.v<double>(['minVerticalPadding']),
      minLeadingWidth: source.v<double>(['minLeadingWidth']),
    );
  },

  'OutlinedButton': (BuildContext context, DataSource source) {
    // not implemented: buttonStyle, focusNode
    return OutlinedButton(
      onPressed: source.voidHandler(['onPressed']),
      onLongPress: source.voidHandler(['onLongPress']),
      autofocus: source.v<bool>(['autofocus']) ?? false,
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.none,
      child: source.child(['child']),
    );
  },

  'Scaffold': (BuildContext context, DataSource source) {
    // not implemented: floatingActionButtonLocation, floatingActionButtonAnimator; onDrawerChanged, onEndDrawerChanged
    final Widget? appBarWidget = source.optionalChild(['appBar']);
    final List<Widget> persistentFooterButtons = source.childList(['persistentFooterButtons']);
    return Scaffold(
      appBar: appBarWidget == null ? null : PreferredSize(
        preferredSize: Size.fromHeight(source.v<double>(['bottomHeight']) ?? 56.0),
        child: appBarWidget,
      ),
      body: source.optionalChild(['body']),
      floatingActionButton: source.optionalChild(['floatingActionButton']),
      persistentFooterButtons: persistentFooterButtons.isEmpty ? null : persistentFooterButtons,
      drawer: source.optionalChild(['drawer']),
      endDrawer: source.optionalChild(['endDrawer']),
      bottomNavigationBar: source.optionalChild(['bottomNavigationBar']),
      bottomSheet: source.optionalChild(['bottomSheet']),
      backgroundColor: ArgumentDecoders.color(source, ['backgroundColor']),
      resizeToAvoidBottomInset: source.v<bool>(['resizeToAvoidBottomInset']),
      primary: source.v<bool>(['primary']) ?? true,
      drawerDragStartBehavior: ArgumentDecoders.enumValue<DragStartBehavior>(DragStartBehavior.values, source, ['drawerDragStartBehavior']) ?? DragStartBehavior.start,
      extendBody: source.v<bool>(['extendBody']) ?? false,
      extendBodyBehindAppBar: source.v<bool>(['extendBodyBehindAppBar']) ?? false,
      drawerScrimColor: ArgumentDecoders.color(source, ['drawerScrimColor']),
      drawerEdgeDragWidth: source.v<double>(['drawerEdgeDragWidth']),
      drawerEnableOpenDragGesture: source.v<bool>(['drawerEnableOpenDragGesture']) ?? true,
      endDrawerEnableOpenDragGesture: source.v<bool>(['endDrawerEnableOpenDragGesture']) ?? true,
      restorationId: source.v<String>(['restorationId']),
    );
  },

  'TextButton': (BuildContext context, DataSource source) {
    // not implemented: buttonStyle, focusNode
    return TextButton(
      onPressed: source.voidHandler(['onPressed']),
      onLongPress: source.voidHandler(['onLongPress']),
      autofocus: source.v<bool>(['autofocus']) ?? false,
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.none,
      child: source.child(['child']),
    );
  },

  'VerticalDivider': (BuildContext context, DataSource source) {
    return VerticalDivider(
      width: source.v<double>(['width']),
      thickness: source.v<double>(['thickness']),
      indent: source.v<double>(['indent']),
      endIndent: source.v<double>(['endIndent']),
      color: ArgumentDecoders.color(source, ['color']),
    );
  },

};
