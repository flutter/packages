// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// There's a lot of <Object>[] lists in this file so to avoid making this
// file even less readable we relax our usual stance on verbose typing.
// ignore_for_file: always_specify_types

// This file is hand-formatted.

// ignore: unnecessary_import, see https://github.com/flutter/flutter/pull/138881
import 'dart:ui' show FontFeature;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import 'argument_decoders.dart';
import 'runtime.dart';

/// A widget library for Remote Flutter Widgets that defines widgets that are
/// implemented on the client in terms of Flutter widgets from the `widgets`
/// Dart library.
///
/// The following widgets are implemented:
///
///  * [Align]
///  * [AspectRatio]
///  * [Center]
///  * [ClipRRect]
///  * [ColoredBox]
///  * [Column]
///  * [Container] (actually uses [AnimatedContainer])
///  * [DefaultTextStyle]
///  * [Directionality]
///  * [Expanded]
///  * [FittedBox]
///  * [FractionallySizedBox]
///  * [GestureDetector]
///  * [GridView] (actually uses [GridView.builder])
///  * [Icon]
///  * [IconTheme]
///  * [IntrinsicHeight]
///  * [IntrinsicWidth]
///  * [Image] (see below)
///  * [ListBody]
///  * [ListView] (actually uses [ListView.builder])
///  * [Opacity] (actually uses [AnimatedOpacity])
///  * [Padding] (actually uses [AnimatedPadding])
///  * [Placeholder]
///  * [Positioned] (actually uses [AnimatedPositionedDirectional])
///  * [Rotation] (actually uses [AnimatedRotation])
///  * [Row]
///  * [SafeArea]
///  * [Scale] (actually uses [AnimatedScale])
///  * [SingleChildScrollView]
///  * [SizedBox]
///  * `SizedBoxExpand` (actually [SizedBox.expand])
///  * `SizedBoxShrink` (actually [SizedBox.shrink])
///  * [Spacer]
///  * [Stack]
///  * [Text]
///  * [Wrap]
///
/// For each, every parameter is implemented using the same name. Parameters
/// that take structured types are represented using maps, with each named
/// parameter of that type's default constructor represented by a key, with the
/// following notable caveats and exceptions:
///
///  * Enums are represented as strings with the unqualified name of the value.
///    For example, [MainAxisAlignment.start] is represented as the string
///    `"start"`.
///
///  * Types that have multiple subclasses (or multiple very unrelated
///    constructors, like [ColorFilter]) are represented as maps where the `type`
///    key specifies the type. Typically these have an extension mechanism.
///
///  * Matrices are represented as **column-major** flattened arrays. [Matrix4]
///    values must have exactly 16 doubles in the array.
///
///  * [AlignmentGeometry] values can be represented either as `{x: ..., y:
///    ...}` for a non-directional variant or `{start: ..., y: ...}` for a
///    directional variant.
///
///  * [BoxBorder] instances are defined as arrays of [BorderSide] maps. If the
///    array has length 1, then that value is used for all four sides. Two
///    values become the horizontal and vertical sides respectively. Three
///    values become the start, top-and-bottom, and end respectively. Four
///    values become the start, top, end, and bottom respectively.
///
///  * [BorderRadiusGeometry] values work similarly to [BoxBorder], as an array
///    of [Radius] values. If the array has one value, it's used for all corners.
///    With two values, the first becomes the `topStart` and `bottomStart`
///    corners and the second the `topEnd` and `bottomEnd`. With three, the
///    values are used for `topStart`, `topEnd`-and-`bottomEnd`, and
///    `bottomStart` respectively. Four values map to the `topStart`, `topEnd`,
///    `bottomStart`, and `bottomEnd` respectively.
///
///  * [Color] values are represented as integers. The hex literal values are
///    most convenient for this, the alpha, red, green, and blue channels map to
///    the 32 bit hex integer as 0xAARRGGBB.
///
///  * [ColorFilter] is represented as a map with a `type` key that matches the
///    constructor name (e.g. `linearToSrgbGamma`). The `matrix` version uses
///    the `matrix` key for the matrix, expecting a 20-value array. The `mode`
///    version expects a `color` key for the color (defaults to black) and a
///    `blendMode` key for the blend mode (defaults to [BlendMode.srcOver]).
///    Other types are looked up in [ArgumentDecoders.colorFilterDecoders].
///
///  * [Curve] values are represented as a string giving the kind of curve from
///    the predefined [Curves], e.g. `easeInOutCubicEmphasized`. More types may
///    be added using [ArgumentDecoders.curveDecoders].
///
///  * The types supported for [Decoration] are `box` for [BoxDecoration],
///    `flutterLogo` for [FlutterLogoDecoration], and `shape` for
///    [ShapeDecoration]. More types can be added with [decorationDecoders].
///
///  * [DecorationImage] expects a `source` key that gives either an absolute
///    URL (to use a [NetworkImage]) or the name of an asset in the client
///    binary (to use [AssetImage]). In the case of a URL, the `scale` key gives
///    the scale to pass to the [NetworkImage] constructor.
///    [DecorationImage.onError] is supported as an event handler with arguments
///    giving the stringified exception and stack trace. Values can be added to
///    [ArgumentDecoders.imageProviderDecoders] to override the behavior described here.
///
///  * [Duration] is represented by an integer giving milliseconds.
///
///  * [EdgeInsetsGeometry] values work like [BoxBorder], with each value in the
///    array being a double rather than a map.
///
///  * [FontFeature] values are a map with a `feature` key and a `value` key.
///    The `value` defaults to 1. (Technically the `feature` defaults to `NONE`,
///    too, but that's hardly useful.)
///
///  * The [dart:ui.Gradient] and [painting.Gradient] types are both represented
///    as a map with a type that is either `linear` (for [LinearGradient]),
///    `radial` (for [RadialGradient]), or `sweep` (for [SweepGradient]), using
///    the conventions from the [painting.Gradient] version. The `transform`
///    property on these objects is not currently supported. New gradient types
///    can be implemented using [ArgumentDecoders.gradientDecoders].
///
///  * The [GridDelegate] type is represented as a map with a `type` key that is
///    either `fixedCrossAxisCount` for
///    [SliverGridDelegateWithFixedCrossAxisCount] or `maxCrossAxisExtent` for
///    [SliverGridDelegateWithMaxCrossAxisExtent]. New delegate types can be
///    supported using [ArgumentDecoders.gridDelegateDecoders].
///
///  * [IconData] is represented as a map with an `icon` key giving the
///    [IconData.codePoint] (and corresponding keys for the other parameters of
///    the [IconData] constructor). To determine the values to use for icons in
///    the MaterialIcons font, see how the icons are defined in [Icons]. For
///    example, [Icons.flutter_dash] is `IconData(0xe2a0, fontFamily:
///    'MaterialIcons')` so it would be represented here as `{ icon: 0xE2A0,
///    fontFamily: "MaterialIcons" }`. (The client must have the font as a
///    defined asset.)
///
///  * [Locale] values are defined as a string in the form `languageCode`,
///    `languageCode-countryCode`, or
///    `languageCode-scriptCode-countryCode-ignoredSubtags`. The string is split
///    on hyphens.
///
///  * [MaskFilter] is represented as a map with a `type` key that must be
///    `blur`; only [MaskFilter.blur] is supported. (The other keys must be
///    `style`, the [BlurStyle], and `sigma`.)
///
///  * [Offset]s are a map with an `x` key and a `y` key.
///
///  * [Paint] objects are represented as maps; each property of [Paint] is a
///    key as if there was a constructor that could set all of [Paint]'s
///    properties with named parameters. In principle all properties are
///    supported, though since [Paint] is only used as part of
///    [painting.TextStyle.background] and [painting.TextStyle.foreground], in
///    practice some of the properties are ignored since they would be no-ops
///    (e.g. `invertColors`).
///
///  * [Radius] is represented as a map with an `x` value and optionally a `y`
///    value; if the `y` value is absent, the `x` value is used for both.
///
///  * [Rect] values are represented as an array with four doubles, giving the
///    x, y, width, and height respectively.
///
///  * [ShapeBorder] values are represented as either maps with a `type` _or_ as
///    an array of [ShapeBorder] values. In the array case, the values are
///    reduced together using [ShapeBorder.+]. When represented as maps, the
///    type must be one of `box` ([BoxBorder]), `beveled`
///    ([BeveledRectangleBorder]), `circle` ([CircleBorder]), `continuous`
///    ([ContinuousRectangleBorder]), `rounded` ([RoundedRectangleBorder]), or
///    `stadium` ([StadiumBorder]). In the case of `box`, there must be a
///    `sides` key whose value is an array that is interpreted as per
///    [BoxBorder] above. Support for new types can be added using the
///    [ArgumentDecoders.shapeBorderDecoders] map.
///
///  * [Shader] values are a map with a `type` that is either `linear`,
///    `radial`, or `sweep`; in each case, the data is interpreted as per the
///    [Gradient] case above, except that the gradient is specifically applied
///    to a [Rect] given by the `rect` key and a [TextDirection] given by the
///    `textDirection` key. New shader types can be added using
///    [ArgumentDecoders.shaderDecoders].
///
///  * [TextDecoration] is represented either as an array of [TextDecoration]
///    values (combined via [TextDecoration.combine]) or a string which matches
///    the name of one of the [TextDecoration] constants (e.g. `underline`).
///
///  * [VisualDensity] is either represented as a string which matches one of the
///    predefined values (`adaptivePlatformDensity`, `comfortable`, etc), or as
///    a map with keys `horizontal` and `vertical` to define a custom density.
///
/// Some of the widgets have special considerations:
///
///  * [Image] does not support the builder callbacks or the [Image.opacity]
///    parameter (because builders are code and code can't be represented in RFW
///    arguments). The map should have a `source` key that is interpreted as
///    described above for [DecorationImage]. If the `source` is omitted, an
///    [AssetImage] with the name `error.png` is used instead (which will likely
///    fail unless such an asset is declared in the client).
///
///  * Parameters of type [ScrollController] and [ScrollPhysics] are not
///    supported, because they can't really be exposed to declarative code (they
///    expect to be configured using code that implements delegates or that
///    interacts with controllers).
///
///  * The [Text] widget's first argument, the string, is represented using the
///    key `text`, which must be either a string or an array of strings to be
///    concatenated.
///
/// One additional widget is defined, [AnimationDefaults]. It has a `duration`
/// argument and `curve` argument. It sets the default animation duration and
/// curve for widgets in the library that use the animated variants. If absent,
/// a default of 200ms and [Curves.fastOutSlowIn] is used.
LocalWidgetLibrary createCoreWidgets() => LocalWidgetLibrary(_coreWidgetsDefinitions);

// In these widgets we make an effort to expose every single argument available.
Map<String, LocalWidgetBuilder> get _coreWidgetsDefinitions => <String, LocalWidgetBuilder>{

  // Keep these in alphabetical order and add any new widgets to the list
  // in the documentation above.

  'AnimationDefaults': (BuildContext context, DataSource source) {
    return AnimationDefaults(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      child: source.child(['child']),
    );
  },

  'Align': (BuildContext context, DataSource source) {
    return AnimatedAlign(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      alignment: ArgumentDecoders.alignment(source, ['alignment']) ?? Alignment.center,
      widthFactor: source.v<double>(['widthFactor']),
      heightFactor: source.v<double>(['heightFactor']),
      onEnd: source.voidHandler(['onEnd']),
      child: source.optionalChild(['child']),
    );
  },

  'AspectRatio': (BuildContext context, DataSource source) {
    return AspectRatio(
      aspectRatio: source.v<double>(['aspectRatio']) ?? 1.0,
      child: source.optionalChild(['child']),
    );
  },

  'Center': (BuildContext context, DataSource source) {
    return Center(
      widthFactor: source.v<double>(['widthFactor']),
      heightFactor: source.v<double>(['heightFactor']),
      child: source.optionalChild(['child']),
    );
  },

  'ClipRRect': (BuildContext context, DataSource source) {
    return ClipRRect(
      borderRadius: ArgumentDecoders.borderRadius(source, ['borderRadius']) ?? BorderRadius.zero,
      // CustomClipper<RRect> clipper,
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.antiAlias,
      child: source.optionalChild(['child']),
    );
  }, 

  'ColoredBox': (BuildContext context, DataSource source) {
    return ColoredBox(
      color: ArgumentDecoders.color(source, ['color']) ?? const Color(0xFF000000),
      child: source.optionalChild(['child']),
    );
  },

  'Column': (BuildContext context, DataSource source) {
    return Column(
      mainAxisAlignment: ArgumentDecoders.enumValue<MainAxisAlignment>(MainAxisAlignment.values, source, ['mainAxisAlignment']) ?? MainAxisAlignment.start,
      mainAxisSize: ArgumentDecoders.enumValue<MainAxisSize>(MainAxisSize.values, source, ['mainAxisSize']) ?? MainAxisSize.max,
      crossAxisAlignment: ArgumentDecoders.enumValue<CrossAxisAlignment>(CrossAxisAlignment.values, source, ['crossAxisAlignment']) ?? CrossAxisAlignment.center,
      textDirection: ArgumentDecoders.enumValue<TextDirection>(TextDirection.values, source, ['textDirection']),
      verticalDirection: ArgumentDecoders.enumValue<VerticalDirection>(VerticalDirection.values, source, ['verticalDirection']) ?? VerticalDirection.down,
      textBaseline: ArgumentDecoders.enumValue<TextBaseline>(TextBaseline.values, source, ['textBaseline']),
      children: source.childList(['children']),
    );
  },

  'Container': (BuildContext context, DataSource source) {
    return AnimatedContainer(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      alignment: ArgumentDecoders.alignment(source, ['alignment']),
      padding: ArgumentDecoders.edgeInsets(source, ['padding']),
      color: ArgumentDecoders.color(source, ['color']),
      decoration: ArgumentDecoders.decoration(source, ['decoration']),
      foregroundDecoration: ArgumentDecoders.decoration(source, ['foregroundDecoration']),
      width: source.v<double>(['width']),
      height: source.v<double>(['height']),
      constraints: ArgumentDecoders.boxConstraints(source, ['constraints']),
      margin: ArgumentDecoders.edgeInsets(source, ['margin']),
      transform: ArgumentDecoders.matrix(source, ['transform']),
      transformAlignment: ArgumentDecoders.alignment(source, ['transformAlignment']),
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.none,
      onEnd: source.voidHandler(['onEnd']),
      child: source.optionalChild(['child']),
    );
  },

  'DefaultTextStyle': (BuildContext context, DataSource source) {
    return AnimatedDefaultTextStyle(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      style: ArgumentDecoders.textStyle(source, ['style']) ?? const TextStyle(),
      textAlign: ArgumentDecoders.enumValue<TextAlign>(TextAlign.values, source, ['textAlign']),
      softWrap: source.v<bool>(['softWrap']) ?? true,
      overflow: ArgumentDecoders.enumValue<TextOverflow>(TextOverflow.values, source, ['overflow']) ?? TextOverflow.clip,
      maxLines: source.v<int>(['maxLines']),
      textWidthBasis: ArgumentDecoders.enumValue<TextWidthBasis>(TextWidthBasis.values, source, ['textWidthBasis']) ?? TextWidthBasis.parent,
      textHeightBehavior: ArgumentDecoders.textHeightBehavior(source, ['textHeightBehavior']),
      onEnd: source.voidHandler(['onEnd']),
      child: source.child(['child']),
    );
  },

  'Directionality': (BuildContext context, DataSource source) {
    return Directionality(
      textDirection: ArgumentDecoders.enumValue<TextDirection>(TextDirection.values, source, ['textDirection']) ?? TextDirection.ltr,
      child: source.child(['child']),
    );
  },

  'Expanded': (BuildContext context, DataSource source) {
    return Expanded(
      flex: source.v<int>(['flex']) ?? 1,
      child: source.child(['child']),
    );
  },

  'FittedBox': (BuildContext context, DataSource source) {
    return FittedBox(
      fit: ArgumentDecoders.enumValue<BoxFit>(BoxFit.values, source, ['fit']) ?? BoxFit.contain,
      alignment: ArgumentDecoders.alignment(source, ['alignment']) ?? Alignment.center,
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.none,
      child: source.optionalChild(['child']),
    );
  },

  'FractionallySizedBox': (BuildContext context, DataSource source) {
    return FractionallySizedBox(
      alignment: ArgumentDecoders.alignment(source, ['alignment']) ?? Alignment.center,
      widthFactor: source.v<double>(['widthFactor']),
      heightFactor: source.v<double>(['heightFactor']),
      child: source.child(['child']),
    );
  },

  'GestureDetector': (BuildContext context, DataSource source) {
    return GestureDetector(
      onTap: source.voidHandler(['onTap']),
      onTapDown: source.handler(['onTapDown'], (VoidCallback trigger) => (TapDownDetails details) => trigger()),
      onTapUp: source.handler(['onTapUp'], (VoidCallback trigger) => (TapUpDetails details) => trigger()),
      onTapCancel: source.voidHandler(['onTapCancel']),
      onDoubleTap: source.voidHandler(['onDoubleTap']),
      onLongPress: source.voidHandler(['onLongPress']),
      behavior: ArgumentDecoders.enumValue<HitTestBehavior>(HitTestBehavior.values, source, ['behavior']),
      child: source.optionalChild(['child']),
    );
  },

  'GridView': (BuildContext context, DataSource source) {
    return GridView.builder(
      scrollDirection: ArgumentDecoders.enumValue<Axis>(Axis.values, source, ['scrollDirection']) ?? Axis.vertical,
      reverse: source.v<bool>(['reverse']) ?? false,
      // controller,
      primary: source.v<bool>(['primary']),
      // physics,
      shrinkWrap: source.v<bool>(['shrinkWrap']) ?? false,
      padding: ArgumentDecoders.edgeInsets(source, ['padding']),
      gridDelegate: ArgumentDecoders.gridDelegate(source, ['gridDelegate']) ?? const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (BuildContext context, int index) => source.child(['children', index]),
      itemCount: source.length(['children']),
      addAutomaticKeepAlives: source.v<bool>(['addAutomaticKeepAlives']) ?? true,
      addRepaintBoundaries: source.v<bool>(['addRepaintBoundaries']) ?? true,
      addSemanticIndexes: source.v<bool>(['addSemanticIndexes']) ?? true,
      cacheExtent: source.v<double>(['cacheExtent']),
      semanticChildCount: source.v<int>(['semanticChildCount']),
      dragStartBehavior: ArgumentDecoders.enumValue<DragStartBehavior>(DragStartBehavior.values, source, ['dragStartBehavior']) ?? DragStartBehavior.start,
      keyboardDismissBehavior: ArgumentDecoders.enumValue<ScrollViewKeyboardDismissBehavior>(ScrollViewKeyboardDismissBehavior.values, source, ['keyboardDismissBehavior']) ?? ScrollViewKeyboardDismissBehavior.manual,
      restorationId: source.v<String>(['restorationId']),
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.hardEdge,
    );
  },

  'Icon': (BuildContext context, DataSource source) {
    return Icon(
      ArgumentDecoders.iconData(source, []) ?? Icons.flutter_dash,
      size: source.v<double>(['size']),
      color: ArgumentDecoders.color(source, ['color']),
      semanticLabel: source.v<String>(['semanticLabel']),
      textDirection: ArgumentDecoders.enumValue<TextDirection>(TextDirection.values, source, ['textDirection']),
    );
  },

  'IconTheme': (BuildContext context, DataSource source) {
    return IconTheme(
      data: ArgumentDecoders.iconThemeData(source, []) ?? const IconThemeData(),
      child: source.child(['child']),
    );
  },

  'IntrinsicHeight': (BuildContext context, DataSource source) {
    return IntrinsicHeight(
      child: source.optionalChild(['child']),
    );
  },

  'IntrinsicWidth': (BuildContext context, DataSource source) {
    return IntrinsicWidth(
      stepWidth: source.v<double>(['width']),
      stepHeight: source.v<double>(['height']),
      child: source.optionalChild(['child']),
    );
  },

  'Image': (BuildContext context, DataSource source) {
    return Image(
      image: ArgumentDecoders.imageProvider(source, []) ?? const AssetImage('error.png'),
      // ImageFrameBuilder? frameBuilder,
      // ImageLoadingBuilder? loadingBuilder,
      // ImageErrorWidgetBuilder? errorBuilder,
      semanticLabel: source.v<String>(['semanticLabel']),
      excludeFromSemantics: source.v<bool>(['excludeFromSemantics']) ?? false,
      width: source.v<double>(['width']),
      height: source.v<double>(['height']),
      color: ArgumentDecoders.color(source, ['color']),
      // Animation<double>? opacity,
      colorBlendMode: ArgumentDecoders.enumValue<BlendMode>(BlendMode.values, source, ['blendMode']),
      fit: ArgumentDecoders.enumValue<BoxFit>(BoxFit.values, source, ['fit']),
      alignment: ArgumentDecoders.alignment(source, ['alignment']) ?? Alignment.center,
      repeat: ArgumentDecoders.enumValue<ImageRepeat>(ImageRepeat.values, source, ['repeat']) ?? ImageRepeat.noRepeat,
      centerSlice: ArgumentDecoders.rect(source, ['centerSlice']),
      matchTextDirection: source.v<bool>(['matchTextDirection']) ?? false,
      gaplessPlayback: source.v<bool>(['gaplessPlayback']) ?? false,
      isAntiAlias: source.v<bool>(['isAntiAlias']) ?? false,
      filterQuality: ArgumentDecoders.enumValue<FilterQuality>(FilterQuality.values, source, ['filterQuality']) ?? FilterQuality.low,
    );
  },

  'ListBody': (BuildContext context, DataSource source) {
    return ListBody(
      mainAxis: ArgumentDecoders.enumValue<Axis>(Axis.values, source, ['mainAxis']) ?? Axis.vertical,
      reverse: source.v<bool>(['reverse']) ?? false,
      children: source.childList(['children']),
    );
  },

  'ListView': (BuildContext context, DataSource source) {
    return ListView.builder(
      scrollDirection: ArgumentDecoders.enumValue<Axis>(Axis.values, source, ['scrollDirection']) ?? Axis.vertical,
      reverse: source.v<bool>(['reverse']) ?? false,
      // ScrollController? controller,
      primary: source.v<bool>(['primary']),
      // ScrollPhysics? physics,
      shrinkWrap: source.v<bool>(['shrinkWrap']) ?? false,
      padding: ArgumentDecoders.edgeInsets(source, ['padding']),
      itemExtent: source.v<double>(['itemExtent']),
      prototypeItem: source.optionalChild(['prototypeItem']),
      itemCount: source.length(['children']),
      itemBuilder: (BuildContext context, int index) => source.child(['children', index]),
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.hardEdge,
      addAutomaticKeepAlives: source.v<bool>(['addAutomaticKeepAlives']) ?? true,
      addRepaintBoundaries: source.v<bool>(['addRepaintBoundaries']) ?? true,
      addSemanticIndexes: source.v<bool>(['addSemanticIndexes']) ?? true,
      cacheExtent: source.v<double>(['cacheExtent']),
      semanticChildCount: source.v<int>(['semanticChildCount']),
      dragStartBehavior: ArgumentDecoders.enumValue<DragStartBehavior>(DragStartBehavior.values, source, ['dragStartBehavior']) ?? DragStartBehavior.start,
      keyboardDismissBehavior: ArgumentDecoders.enumValue<ScrollViewKeyboardDismissBehavior>(ScrollViewKeyboardDismissBehavior.values, source, ['keyboardDismissBehavior']) ?? ScrollViewKeyboardDismissBehavior.manual,
      restorationId: source.v<String>(['restorationId']),
    );
  },

  'Opacity': (BuildContext context, DataSource source) {
    return AnimatedOpacity(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      opacity: source.v<double>(['opacity']) ?? 0.0,
      onEnd: source.voidHandler(['onEnd']),
      alwaysIncludeSemantics: source.v<bool>(['alwaysIncludeSemantics']) ?? true,
      child: source.optionalChild(['child']),
    );
  },

  'Padding': (BuildContext context, DataSource source) {
    return AnimatedPadding(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      padding: ArgumentDecoders.edgeInsets(source, ['padding']) ?? EdgeInsets.zero,
      onEnd: source.voidHandler(['onEnd']),
      child: source.optionalChild(['child']),
    );
  },

  'Placeholder': (BuildContext context, DataSource source) {
    return Placeholder(
      color: ArgumentDecoders.color(source, ['color']) ?? const Color(0xFF455A64),
      strokeWidth: source.v<double>(['strokeWidth']) ?? 2.0,
      fallbackWidth: source.v<double>(['placeholderWidth']) ?? 400.0,
      fallbackHeight: source.v<double>(['placeholderHeight']) ?? 400.0,
    );
  },

  'Positioned': (BuildContext context, DataSource source) {
    return AnimatedPositionedDirectional(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      start: source.v<double>(['start']),
      top: source.v<double>(['top']),
      end: source.v<double>(['end']),
      bottom: source.v<double>(['bottom']),
      width: source.v<double>(['width']),
      height: source.v<double>(['height']),
      onEnd: source.voidHandler(['onEnd']),
      child: source.child(['child']),
    );
  },

  'Rotation': (BuildContext context, DataSource source) {
    return AnimatedRotation(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      turns: source.v<double>(['turns']) ?? 0.0,
      alignment: (ArgumentDecoders.alignment(source, ['alignment']) ?? Alignment.center).resolve(Directionality.of(context)),
      filterQuality: ArgumentDecoders.enumValue<FilterQuality>(FilterQuality.values, source, ['filterQuality']),
      onEnd: source.voidHandler(['onEnd']),
      child: source.optionalChild(['child']),
    );
  },

  // The "#docregion" pragma below makes this accessible from the README.md file.
  // #docregion Row
  'Row': (BuildContext context, DataSource source) {
    return Row(
      mainAxisAlignment: ArgumentDecoders.enumValue<MainAxisAlignment>(MainAxisAlignment.values, source, ['mainAxisAlignment']) ?? MainAxisAlignment.start,
      mainAxisSize: ArgumentDecoders.enumValue<MainAxisSize>(MainAxisSize.values, source, ['mainAxisSize']) ?? MainAxisSize.max,
      crossAxisAlignment: ArgumentDecoders.enumValue<CrossAxisAlignment>(CrossAxisAlignment.values, source, ['crossAxisAlignment']) ?? CrossAxisAlignment.center,
      textDirection: ArgumentDecoders.enumValue<TextDirection>(TextDirection.values, source, ['textDirection']),
      verticalDirection: ArgumentDecoders.enumValue<VerticalDirection>(VerticalDirection.values, source, ['verticalDirection']) ?? VerticalDirection.down,
      textBaseline: ArgumentDecoders.enumValue<TextBaseline>(TextBaseline.values, source, ['textBaseline']),
      children: source.childList(['children']),
    );
  },
  // #enddocregion Row

  'SafeArea': (BuildContext context, DataSource source) {
    return SafeArea(
      left: source.v<bool>(['left']) ?? true,
      top: source.v<bool>(['top']) ?? true,
      right: source.v<bool>(['right']) ?? true,
      bottom: source.v<bool>(['bottom']) ?? true,
      minimum: (ArgumentDecoders.edgeInsets(source, ['minimum']) ?? EdgeInsets.zero).resolve(Directionality.of(context)),
      maintainBottomViewPadding: source.v<bool>(['maintainBottomViewPadding']) ?? false,
      child: source.child(['child']),
    );
  },

  'Scale': (BuildContext context, DataSource source) {
    return AnimatedScale(
      duration: ArgumentDecoders.duration(source, ['duration'], context),
      curve: ArgumentDecoders.curve(source, ['curve'], context),
      scale: source.v<double>(['scale']) ?? 1.0,
      alignment: (ArgumentDecoders.alignment(source, ['alignment']) ?? Alignment.center).resolve(Directionality.of(context)),
      filterQuality: ArgumentDecoders.enumValue<FilterQuality>(FilterQuality.values, source, ['filterQuality']),
      onEnd: source.voidHandler(['onEnd']),
      child: source.optionalChild(['child']),
    );
  },

  'SingleChildScrollView': (BuildContext context, DataSource source) {
    return SingleChildScrollView(
      scrollDirection: ArgumentDecoders.enumValue<Axis>(Axis.values, source, ['scrollDirection']) ?? Axis.vertical,
      reverse: source.v<bool>(['reverse']) ?? false,
      padding: ArgumentDecoders.edgeInsets(source, ['padding']),
      primary: source.v<bool>(['primary']) ?? true,
      dragStartBehavior: ArgumentDecoders.enumValue<DragStartBehavior>(DragStartBehavior.values, source, ['dragStartBehavior']) ?? DragStartBehavior.start,
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.hardEdge,
      restorationId: source.v<String>(['restorationId']),
      keyboardDismissBehavior: ArgumentDecoders.enumValue<ScrollViewKeyboardDismissBehavior>(ScrollViewKeyboardDismissBehavior.values, source, ['keyboardDismissBehavior']) ?? ScrollViewKeyboardDismissBehavior.manual,
      // ScrollPhysics? physics,
      // ScrollController? controller,
      child: source.optionalChild(['child']),
    );
  },

  'SizedBox': (BuildContext context, DataSource source) {
    return SizedBox(
      width: source.v<double>(['width']),
      height: source.v<double>(['height']),
      child: source.optionalChild(['child']),
    );
  },

  'SizedBoxExpand': (BuildContext context, DataSource source) {
    return SizedBox.expand(
      child: source.optionalChild(['child']),
    );
  },

  'SizedBoxShrink': (BuildContext context, DataSource source) {
    return SizedBox.shrink(
      child: source.optionalChild(['child']),
    );
  },

  'Spacer': (BuildContext context, DataSource source) {
    return Spacer(
      flex: source.v<int>(['flex']) ?? 1,
    );
  },

  'Stack': (BuildContext context, DataSource source) {
    return Stack(
      alignment: ArgumentDecoders.alignment(source, ['alignment']) ?? AlignmentDirectional.topStart,
      textDirection: ArgumentDecoders.enumValue<TextDirection>(TextDirection.values, source, ['textDirection']),
      fit: ArgumentDecoders.enumValue<StackFit>(StackFit.values, source, ['fit']) ?? StackFit.loose,
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.hardEdge,
      children: source.childList(['children']),
    );
  },

  'Text': (BuildContext context, DataSource source) {
    String? text = source.v<String>(['text']);
    if (text == null) {
      final StringBuffer builder = StringBuffer();
      final int count = source.length(['text']);
      for (int index = 0; index < count; index += 1) {
        builder.write(source.v<String>(['text', index]) ?? '');
      }
      text = builder.toString();
    }
    final double? textScaleFactor = source.v<double>(['textScaleFactor']);
    return Text(
      text,
      style: ArgumentDecoders.textStyle(source, ['style']),
      strutStyle: ArgumentDecoders.strutStyle(source, ['strutStyle']),
      textAlign: ArgumentDecoders.enumValue<TextAlign>(TextAlign.values, source, ['textAlign']),
      textDirection: ArgumentDecoders.enumValue<TextDirection>(TextDirection.values, source, ['textDirection']),
      locale: ArgumentDecoders.locale(source, ['locale']),
      softWrap: source.v<bool>(['softWrap']),
      overflow: ArgumentDecoders.enumValue<TextOverflow>(TextOverflow.values, source, ['overflow']),
      textScaler: textScaleFactor == null ? null : TextScaler.linear(textScaleFactor),
      maxLines: source.v<int>(['maxLines']),
      semanticsLabel: source.v<String>(['semanticsLabel']),
      textWidthBasis: ArgumentDecoders.enumValue<TextWidthBasis>(TextWidthBasis.values, source, ['textWidthBasis']),
      textHeightBehavior: ArgumentDecoders.textHeightBehavior(source, ['textHeightBehavior']),
    );
  },

  'Wrap': (BuildContext context, DataSource source) {
    return Wrap(
      direction: ArgumentDecoders.enumValue<Axis>(Axis.values, source, ['direction']) ?? Axis.horizontal,
      alignment: ArgumentDecoders.enumValue<WrapAlignment>(WrapAlignment.values, source, ['alignment']) ?? WrapAlignment.start,
      spacing: source.v<double>(['spacing']) ?? 0.0,
      runAlignment: ArgumentDecoders.enumValue<WrapAlignment>(WrapAlignment.values, source, ['runAlignment']) ?? WrapAlignment.start,
      runSpacing: source.v<double>(['runSpacing']) ?? 0.0,
      crossAxisAlignment: ArgumentDecoders.enumValue<WrapCrossAlignment>(WrapCrossAlignment.values, source, ['crossAxisAlignment']) ?? WrapCrossAlignment.start,
      textDirection: ArgumentDecoders.enumValue<TextDirection>(TextDirection.values, source, ['textDirection']),
      verticalDirection: ArgumentDecoders.enumValue<VerticalDirection>(VerticalDirection.values, source, ['verticalDirection']) ?? VerticalDirection.down,
      clipBehavior: ArgumentDecoders.enumValue<Clip>(Clip.values, source, ['clipBehavior']) ?? Clip.none,
      children: source.childList(['children']),
    );
  },

};
