// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// There's a lot of <Object>[] lists in this file so to avoid making this
// file even less readable we relax our usual stance on verbose typing.
// ignore_for_file: always_specify_types

// This file is hand-formatted.

import 'dart:math' as math show pi;
// ignore: unnecessary_import, see https://github.com/flutter/flutter/pull/138881
import 'dart:ui' show FontFeature; // TODO(ianh): https://github.com/flutter/flutter/issues/87235

import 'package:flutter/material.dart';

import 'runtime.dart';

/// Default duration and curve for animations in remote flutter widgets.
///
/// This inherited widget allows a duration and a curve (defaulting to 200ms and
/// [Curves.fastOutSlowIn]) to be set as the default to use when local widgets
/// use the [ArgumentsDecoder.curve] and [ArgumentsDecoder.duration] methods and
/// find that the [DataSource] has no explicit curve or duration.
class AnimationDefaults extends InheritedWidget {
  /// Configures an [AnimanionDefaults] widget.
  ///
  /// The [duration] and [curve] are optional, and default to 200ms and
  /// [Curves.fastOutSlowIn] respectively.
  const AnimationDefaults({
    super.key,
    this.duration,
    this.curve,
    required super.child,
  });

  /// The default duration that [ArgumentsDecoder.duration] should use.
  ///
  /// Defaults to 200ms when this is null.
  final Duration? duration;

  /// The default curve that [ArgumentsDecoder.curve] should use.
  ///
  /// Defaults to [Curves.fastOutSlowIn] when this is null.
  final Curve? curve;

  /// Return the ambient [AnimationDefaults.duration], or 200ms if there is no
  /// ambient [AnimationDefaults] or if the nearest [AnimationDefaults] has a
  /// null [duration].
  static Duration durationOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnimationDefaults>()?.duration ?? const Duration(milliseconds: 200);
  }

  /// Return the ambient [AnimationDefaults.curve], or [Curves.fastOutSlowIn] if
  /// there is no ambient [AnimationDefaults] or if the nearest
  /// [AnimationDefaults] has a null [curve].
  static Curve curveOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnimationDefaults>()?.curve ?? Curves.fastOutSlowIn;
  }

  @override
  bool updateShouldNotify(AnimationDefaults oldWidget) => duration != oldWidget.duration || curve != oldWidget.curve;
}

/// Signature for methods that decode structured values from a [DataSource],
/// such as the static methods of [ArgumentDecoders].
///
/// Used to make some of the methods of that class extensible.
typedef ArgumentDecoder<T> = T Function(DataSource source, List<Object> key);

/// A set of methods for decoding structured values from a [DataSource].
///
/// Specifically, these methods decode types that are used by local widgets
/// (q.v. [createCoreWidgets]).
///
/// These methods take a [DataSource] and a `key`. The `key` is a path to the
/// part of the [DataSource] that the value should be read from. This may
/// identify a map, a list, or a leaf value, depending on the needs of the
/// method.
class ArgumentDecoders {
  const ArgumentDecoders._();

  /// This is a workaround for https://github.com/dart-lang/sdk/issues/47021
  static const ArgumentDecoders __ = ArgumentDecoders._(); // ignore: unused_field

  // (in alphabetical order)

  /// Decodes an [AlignmentDirectional] or [Alignment] object out of the
  /// specified map.
  ///
  /// If the map has `start` and `y` keys, then it is interpreted as an
  /// [AlignmentDirectional] with those values. Otherwise if it has `x` and `y`
  /// it's an [Alignment] with those values. Otherwise it returns null.
  static AlignmentGeometry? alignment(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return null;
    }
    final double? x = source.v<double>([...key, 'x']);
    final double? start = source.v<double>([...key, 'start']);
    final double? y = source.v<double>([...key, 'y']);
    if (x == null && start == null) {
      return null;
    }
    if (y == null) {
      return null;
    }
    if (start != null) {
      return AlignmentDirectional(start, y);
    }
    x!;
    return Alignment(x, y);
  }

  /// Decodes the specified map into a [BoxConstraints].
  ///
  /// The keys used are `minWidth`, `maxWidth`, `minHeight`, and `maxHeight`.
  /// Omitted keys are defaulted to 0.0 for minimums and infinity for maximums.
  static BoxConstraints? boxConstraints(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return null;
    }
    return BoxConstraints(
      minWidth: source.v<double>([...key, 'minWidth']) ?? 0.0,
      maxWidth: source.v<double>([...key, 'maxWidth']) ?? double.infinity,
      minHeight: source.v<double>([...key, 'minHeight']) ?? 0.0,
      maxHeight: source.v<double>([...key, 'maxHeight']) ?? double.infinity,
    );
  }

  /// Returns a [BorderDirectional] from the specified list.
  ///
  /// The list is a list of values as interpreted by [borderSide]. An empty or
  /// missing list results in a null return value. The list should have one
  /// through four items. Extra items are ignored.
  ///
  /// The values are interpreted as follows:
  ///
  ///  * start: first value.
  ///  * top: second value, defaulting to same as start.
  ///  * end: third value, defaulting to same as start.
  ///  * bottom: fourth value, defaulting to same as top.
  static BoxBorder? border(DataSource source, List<Object> key) {
    final BorderSide? a = borderSide(source, [...key, 0]);
    if (a == null) {
      return null;
    }
    final BorderSide? b = borderSide(source, [...key, 1]);
    final BorderSide? c = borderSide(source, [...key, 2]);
    final BorderSide? d = borderSide(source, [...key, 3]);
    return BorderDirectional(
      start: a,
      top: b ?? a,
      end: c ?? a,
      bottom: d ?? b ?? a,
    );
  }

  /// Returns a [BorderRadiusDirectional] from the specified list.
  ///
  /// The list is a list of values as interpreted by [radius]. An empty or
  /// missing list results in a null return value. The list should have one
  /// through four items. Extra items are ignored.
  ///
  /// The values are interpreted as follows:
  ///
  ///  * topStart: first value.
  ///  * topEnd: second value, defaulting to same as topStart.
  ///  * bottomStart: third value, defaulting to same as topStart.
  ///  * bottomEnd: fourth value, defaulting to same as topEnd.
  static BorderRadiusGeometry? borderRadius(DataSource source, List<Object> key) {
    final Radius? a = radius(source, [...key, 0]);
    if (a == null) {
      return null;
    }
    final Radius? b = radius(source, [...key, 1]);
    final Radius? c = radius(source, [...key, 2]);
    final Radius? d = radius(source, [...key, 3]);
    return BorderRadiusDirectional.only(
      topStart: a,
      topEnd: b ?? a,
      bottomStart: c ?? a,
      bottomEnd: d ?? b ?? a,
    );
  }

  /// Returns a [BorderSide] from the specified map.
  ///
  /// If the map is absent, returns null.
  ///
  /// Otherwise (even if it has no keys), the [BorderSide] is created from the
  /// keys `color` (see [color], defaults to black), `width` (a double, defaults
  /// to 1.0), and `style` (see [enumValue] for [BorderStyle], defaults to
  /// [BorderStyle.solid]).
  static BorderSide? borderSide(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return null;
    }
    return BorderSide(
      color: color(source, [...key, 'color']) ?? const Color(0xFF000000),
      width: source.v<double>([...key, 'width']) ?? 1.0,
      style: enumValue<BorderStyle>(BorderStyle.values, source, [...key, 'style']) ?? BorderStyle.solid,
    );
  }

  /// Returns a [BoxShadow] from the specified map.
  ///
  /// If the map is absent, returns null.
  ///
  /// Otherwise (even if it has no keys), the [BoxShadow] is created from the
  /// keys `color` (see [color], defaults to black), `offset` (see [offset],
  /// defaults to [Offset.zero]), `blurRadius` (double, defaults to zero), and
  /// `spreadRadius` (double, defaults to zero).
  static BoxShadow boxShadow(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return const BoxShadow();
    }
    return BoxShadow(
      color: color(source, [...key, 'color']) ?? const Color(0xFF000000),
      offset: offset(source, [...key, 'offset']) ?? Offset.zero,
      blurRadius: source.v<double>([...key, 'blurRadius']) ?? 0.0,
      spreadRadius: source.v<double>([...key, 'spreadRadius']) ?? 0.0,
    );
  }

  /// Returns a [Color] from the specified integer.
  ///
  /// Returns null if it's not an integer; otherwise, passes it to the [
  /// Color] constructor.
  static Color? color(DataSource source, List<Object> key) {
    final int? value = source.v<int>(key);
    if (value == null) {
      return null;
    }
    return Color(value);
  }

  /// Returns a [ColorFilter] from the specified map.
  ///
  /// The `type` key specifies the kind of filter.
  ///
  /// A type of `linearToSrgbGamma` creates a [ColorFilter.linearToSrgbGamma].
  ///
  /// A type of `matrix` creates a [ColorFilter.matrix], parsing the `matrix`
  /// key as per [colorMatrix]). If there is no `matrix` key, returns null.
  ///
  /// A type of `mode` creates a [ColorFilter.mode], using the `color` key
  /// (see[color], defaults to black) and the `blendMode` key (see [enumValue] for
  /// [BlendMdoe], defaults to [BlendMode.srcOver])
  ///
  /// A type of `srgbToLinearGamma` creates a [ColorFilter.srgbToLinearGamma].
  ///
  /// If the type is none of these, but is not null, then the type is looked up
  /// in [colorFilterDecoders], and if an entry is found, this method defers to
  /// that callback.
  ///
  /// Otherwise, returns null.
  static ColorFilter? colorFilter(DataSource source, List<Object> key) {
    final String? type = source.v<String>([...key, 'type']);
    switch (type) {
      case null:
        return null;
      case 'linearToSrgbGamma':
        return const ColorFilter.linearToSrgbGamma();
      case 'matrix':
        final List<double>? matrix = colorMatrix(source, [...key, 'matrix']);
        if (matrix == null) {
          return null;
        }
        return ColorFilter.matrix(matrix);
      case 'mode':
        return ColorFilter.mode(
          color(source, [...key, 'color']) ?? const Color(0xFF000000),
          enumValue<BlendMode>(BlendMode.values, source, [...key, 'blendMode']) ?? BlendMode.srcOver,
        );
      case 'srgbToLinearGamma':
        return const ColorFilter.srgbToLinearGamma();
      default:
        final ArgumentDecoder<ColorFilter?>? decoder = colorFilterDecoders[type];
        if (decoder == null) {
          return null;
        }
        return decoder(source, key);
    }
  }

  /// Extension mechanism for [colorFilter].
  static final Map<String, ArgumentDecoder<ColorFilter?>> colorFilterDecoders = <String, ArgumentDecoder<ColorFilter?>>{};

  /// Returns a list of 20 doubles from the specified list.
  ///
  /// If the specified key does not identify a list, returns null instead.
  ///
  /// If the list has fewer than 20 entries or if any of the entries are not
  /// doubles, any entries that could not be obtained are replaced by zero.
  ///
  /// Used by [colorFilter] in the `matrix` mode.
  static List<double>? colorMatrix(DataSource source, List<Object> key) {
    if (!source.isList(key)) {
      return null;
    }
    return <double>[
      source.v<double>([...key, 0]) ?? 0.0,
      source.v<double>([...key, 1]) ?? 0.0,
      source.v<double>([...key, 2]) ?? 0.0,
      source.v<double>([...key, 3]) ?? 0.0,
      source.v<double>([...key, 4]) ?? 0.0,
      source.v<double>([...key, 5]) ?? 0.0,
      source.v<double>([...key, 6]) ?? 0.0,
      source.v<double>([...key, 7]) ?? 0.0,
      source.v<double>([...key, 8]) ?? 0.0,
      source.v<double>([...key, 9]) ?? 0.0,
      source.v<double>([...key, 10]) ?? 0.0,
      source.v<double>([...key, 11]) ?? 0.0,
      source.v<double>([...key, 12]) ?? 0.0,
      source.v<double>([...key, 13]) ?? 0.0,
      source.v<double>([...key, 14]) ?? 0.0,
      source.v<double>([...key, 15]) ?? 0.0,
      source.v<double>([...key, 16]) ?? 0.0,
      source.v<double>([...key, 17]) ?? 0.0,
      source.v<double>([...key, 18]) ?? 0.0,
      source.v<double>([...key, 19]) ?? 0.0,
    ];
  }

  /// Returns a [Color] from the specified integer.
  ///
  /// Returns black if it's not an integer; otherwise, passes it to the [
  /// Color] constructor.
  ///
  /// This is useful in situations where null is not acceptable, for example,
  /// when providing a decoder to [list]. Otherwise, prefer using [DataSource.v]
  /// directly.
  static Color colorOrBlack(DataSource source, List<Object> key) {
    return color(source, key) ?? const Color(0xFF000000);
  }

  /// Returns a [Curve] from the specified string.
  ///
  /// The given key should specify a string. If that string matches one of the
  /// names of static curves defined in the [Curves] class, then that curve is
  /// returned. Otherwise, if the string was not null, and is present as a key
  /// in the [curveDecoders] map, then the matching decoder from that map is
  /// invoked. Otherwise, the default obtained from [AnimationDefaults.curveOf]
  /// is used (which is why a [BuildContext] is required).
  static Curve curve(DataSource source, List<Object> key, BuildContext context) {
    final String? type = source.v<String>(key);
    switch (type) {
      case 'linear':
        return Curves.linear;
      case 'decelerate':
        return Curves.decelerate;
      case 'fastLinearToSlowEaseIn':
        return Curves.fastLinearToSlowEaseIn;
      case 'ease':
        return Curves.ease;
      case 'easeIn':
        return Curves.easeIn;
      case 'easeInToLinear':
        return Curves.easeInToLinear;
      case 'easeInSine':
        return Curves.easeInSine;
      case 'easeInQuad':
        return Curves.easeInQuad;
      case 'easeInCubic':
        return Curves.easeInCubic;
      case 'easeInQuart':
        return Curves.easeInQuart;
      case 'easeInQuint':
        return Curves.easeInQuint;
      case 'easeInExpo':
        return Curves.easeInExpo;
      case 'easeInCirc':
        return Curves.easeInCirc;
      case 'easeInBack':
        return Curves.easeInBack;
      case 'easeOut':
        return Curves.easeOut;
      case 'linearToEaseOut':
        return Curves.linearToEaseOut;
      case 'easeOutSine':
        return Curves.easeOutSine;
      case 'easeOutQuad':
        return Curves.easeOutQuad;
      case 'easeOutCubic':
        return Curves.easeOutCubic;
      case 'easeOutQuart':
        return Curves.easeOutQuart;
      case 'easeOutQuint':
        return Curves.easeOutQuint;
      case 'easeOutExpo':
        return Curves.easeOutExpo;
      case 'easeOutCirc':
        return Curves.easeOutCirc;
      case 'easeOutBack':
        return Curves.easeOutBack;
      case 'easeInOut':
        return Curves.easeInOut;
      case 'easeInOutSine':
        return Curves.easeInOutSine;
      case 'easeInOutQuad':
        return Curves.easeInOutQuad;
      case 'easeInOutCubic':
        return Curves.easeInOutCubic;
      case 'easeInOutCubicEmphasized':
        return Curves.easeInOutCubicEmphasized;
      case 'easeInOutQuart':
        return Curves.easeInOutQuart;
      case 'easeInOutQuint':
        return Curves.easeInOutQuint;
      case 'easeInOutExpo':
        return Curves.easeInOutExpo;
      case 'easeInOutCirc':
        return Curves.easeInOutCirc;
      case 'easeInOutBack':
        return Curves.easeInOutBack;
      case 'fastOutSlowIn':
        return Curves.fastOutSlowIn;
      case 'slowMiddle':
        return Curves.slowMiddle;
      case 'bounceIn':
        return Curves.bounceIn;
      case 'bounceOut':
        return Curves.bounceOut;
      case 'bounceInOut':
        return Curves.bounceInOut;
      case 'elasticIn':
        return Curves.elasticIn;
      case 'elasticOut':
        return Curves.elasticOut;
      case 'elasticInOut':
        return Curves.elasticInOut;
      default:
        if (type != null) {
          final ArgumentDecoder<Curve>? decoder = curveDecoders[type];
          if (decoder != null) {
            return decoder(source, key);
          }
        }
        return AnimationDefaults.curveOf(context);
    }
  }

  /// Extension mechanism for [curve].
  ///
  /// The decoders must not return null.
  ///
  /// The given key will specify a string, which is known to not match any of
  /// the values in [Curves].
  static final Map<String, ArgumentDecoder<Curve>> curveDecoders = <String, ArgumentDecoder<Curve>>{};

  /// Returns a [Decoration] from the specified map.
  ///
  /// The `type` key specifies the kind of decoration.
  ///
  /// A type of `box` creates a [BoxDecoration] using the keys `color`
  /// ([color]), `image` ([decorationImage]), `border` ([border]),
  /// `borderRadius` ([borderRadius]), `boxShadow` (a [list] of [boxShadow]),
  /// `gradient` ([gradient]), `backgroundBlendMode` (an [enumValue] of [BlendMode]),
  /// and `shape` (an [enumValue] of [BoxShape]), these keys each corresponding to
  /// the properties of [BoxDecoration] with the same name.
  ///
  /// A type of `flutterLogo` creates a [FlutterLogoDecoration] using the keys
  /// `color` ([color], corresponds to [FlutterLogoDecoration.textColor]),
  /// `style` ([enumValue] of [FlutterLogoStyle], defaults to
  /// [FlutterLogoStyle.markOnly]), and `margin` ([edgeInsets], always with a
  /// left-to-right direction), the latter two keys corresponding to
  /// the properties of [FlutterLogoDecoration] with the same name.
  ///
  /// A type of `shape` creates a [ShapeDecoration] using the keys `color`
  /// ([color]), `image` ([decorationImage]), `gradient` ([gradient]), `shadows`
  /// (a [list] of [boxShadow]), and `shape` ([shapeBorder]), these keys each
  /// corresponding to the properties of [ShapeDecoration] with the same name.
  ///
  /// If the type is none of these, but is not null, then the type is looked up
  /// in [decorationDecoders], and if an entry is found, this method defers to
  /// that callback.
  ///
  /// Otherwise, returns null.
  static Decoration? decoration(DataSource source, List<Object> key) {
    final String? type = source.v<String>([...key, 'type']);
    switch (type) {
      case null:
        return null;
      case 'box':
        return BoxDecoration(
          color: color(source, [...key, 'color']),
          image: decorationImage(source, [...key, 'image']),
          border: border(source, [...key, 'border']),
          borderRadius: borderRadius(source, [...key, 'borderRadius']),
          boxShadow: list<BoxShadow>(source, [...key, 'boxShadow'], boxShadow),
          gradient: gradient(source, [...key, 'gradient']),
          backgroundBlendMode: enumValue<BlendMode>(BlendMode.values, source, [...key, 'backgroundBlendMode']),
          shape: enumValue<BoxShape>(BoxShape.values, source, [...key, 'shape']) ?? BoxShape.rectangle,
        );
      case 'flutterLogo':
        return FlutterLogoDecoration(
          textColor: color(source, [...key, 'color']) ?? const Color(0xFF757575),
          style: enumValue<FlutterLogoStyle>(FlutterLogoStyle.values, source, [...key, 'style']) ?? FlutterLogoStyle.markOnly,
          margin: (edgeInsets(source, [...key, 'margin']) ?? EdgeInsets.zero).resolve(TextDirection.ltr),
        );
      case 'shape':
        return ShapeDecoration(
          color: color(source, [...key, 'color']),
          image: decorationImage(source, [...key, 'image']),
          gradient: gradient(source, [...key, 'gradient']),
          shadows: list<BoxShadow>(source, [...key, 'shadows'], boxShadow),
          shape: shapeBorder(source, [...key, 'shape']) ?? const Border(),
        );
      default:
        final ArgumentDecoder<Decoration?>? decoder = decorationDecoders[type];
        if (decoder == null) {
          return null;
        }
        return decoder(source, key);
    }
  }

  /// Extension mechanism for [decoration].
  static final Map<String, ArgumentDecoder<Decoration?>> decorationDecoders = <String, ArgumentDecoder<Decoration?>>{};

  /// Returns a [DecorationImage] from the specified map.
  ///
  /// The [DecorationImage.image] is determined by interpreting the same key as
  /// per [imageProvider]. If that method returns null, then this returns null
  /// also. Otherwise, the return value is used as the provider and additional
  /// keys map to the identically-named properties of [DecorationImage]:
  /// `onError` (must be an event handler; the payload map is augmented by an
  /// `exception` key that contains the text serialization of the exception and
  /// a `stackTrace` key that contains the stack trace, also as a string),
  /// `colorFilter` ([colorFilter]), `fit` ([enumValue] of [BoxFit]), `alignment`
  /// ([alignment], defaults to [Alignment.center]), `centerSlice` ([rect]),
  /// `repeat` ([enumValue] of [ImageRepeat], defaults to [ImageRepeat.noRepeat]),
  /// `matchTextDirection` (boolean, defaults to false).
  static DecorationImage? decorationImage(DataSource source, List<Object> key) {
    final ImageProvider? provider = imageProvider(source, key);
    if (provider == null) {
      return null;
    }
    return DecorationImage(
      image: provider,
      onError: (Object exception, StackTrace? stackTrace) {
        final VoidCallback? handler = source.voidHandler([...key, 'onError'], { 'exception': exception.toString(), 'stackTrack': stackTrace.toString() });
        if (handler != null) {
          handler();
        }
      },
      colorFilter: colorFilter(source, [...key, 'colorFilter']),
      fit: enumValue<BoxFit>(BoxFit.values, source, [...key, 'fit']),
      alignment: alignment(source, [...key, 'alignment']) ?? Alignment.center,
      centerSlice: rect(source, [...key, 'centerSlice']),
      repeat: enumValue<ImageRepeat>(ImageRepeat.values, source, [...key, 'repeat']) ?? ImageRepeat.noRepeat,
      matchTextDirection: source.v<bool>([...key, 'matchTextDirection']) ?? false,
      filterQuality: enumValue<FilterQuality>(FilterQuality.values, source, [...key, 'filterQuality']) ?? FilterQuality.medium,
    );
  }

  /// Returns a double from the specified double.
  ///
  /// Returns 0.0 if it's not a double.
  ///
  /// This is useful in situations where null is not acceptable, for example,
  /// when providing a decoder to [list]. Otherwise, prefer using [DataSource.v]
  /// directly.
  static double doubleOrZero(DataSource source, List<Object> key) {
    return source.v<double>(key) ?? 0.0;
  }

  /// Returns a [Duration] from the specified integer.
  ///
  /// If it's not an integer, the default obtained from
  /// [AnimationDefaults.durationOf] is used (which is why a [BuildContext] is
  /// required).
  static Duration duration(DataSource source, List<Object> key, BuildContext context) {
    final int? value = source.v<int>(key);
    if (value == null) {
      return AnimationDefaults.durationOf(context);
    }
    return Duration(milliseconds: value);
  }

  /// Returns an [EdgeInsetsDirectional] from the specified list.
  ///
  /// The list is a list of doubles. An empty or missing list results in a null
  /// return value. The list should have one through four items. Extra items are
  /// ignored.
  ///
  /// The values are interpreted as follows:
  ///
  ///  * start: first value.
  ///  * top: second value, defaulting to same as start.
  ///  * end: third value, defaulting to same as start.
  ///  * bottom: fourth value, defaulting to same as top.
  static EdgeInsetsGeometry? edgeInsets(DataSource source, List<Object> key) {
    final double? a = source.v<double>([...key, 0]);
    if (a == null) {
      return null;
    }
    final double? b = source.v<double>([...key, 1]);
    final double? c = source.v<double>([...key, 2]);
    final double? d = source.v<double>([...key, 3]);
    return EdgeInsetsDirectional.fromSTEB(
      a,
      b ?? a,
      c ?? a,
      d ?? b ?? a,
    );
  }

  /// Returns one of the values of the specified enum `T`, from the specified string.
  ///
  /// The string must match the name of the enum value, excluding the enum type
  /// name (the part of its [toString] after the dot).
  ///
  /// The first argument must be the `values` list for that enum; this is the
  /// list of values that is searched.
  ///
  /// For example, `enumValue<TileMode>(TileMode.values, source, ['tileMode']) ??
  /// TileMode.clamp` reads the `tileMode` key of `source`, and looks for the
  /// first match in [TileMode.values], defaulting to [TileMode.clamp] if
  /// nothing matches; thus, the string `mirror` would return [TileMode.mirror].
  static T? enumValue<T>(List<T> values, DataSource source, List<Object> key) {
    final String? value = source.v<String>(key);
    if (value == null) {
      return null;
    }
    for (int index = 0; index < values.length; index += 1) {
      if (value == values[index].toString().split('.').last) {
        return values[index];
      }
    }
    return null;
  }

  /// Returns a [FontFeature] from the specified map.
  ///
  /// The `feature` key is used as the font feature name (defaulting to the
  /// probably-useless private value "NONE"), and the `value` key is used as the
  /// value (defaulting to 1, which typically means "enabled").
  ///
  /// As this never returns null, it is possible to use it with [list].
  static FontFeature fontFeature(DataSource source, List<Object> key) {
    return FontFeature(source.v<String>([...key, 'feature']) ?? 'NONE', source.v<int>([...key, 'value']) ?? 1);
  }

  /// Returns a [Gradient] from the specified map.
  ///
  /// The `type` key specifies the kind of gradient.
  ///
  /// A type of `linear` creates a [LinearGradient] using the keys `begin`
  /// ([alignment], defaults to [Alignment.centerLeft]), `end` ([alignment],
  /// defaults to [Alignment.centerRight]), `colors` ([list] of [colorOrBlack],
  /// defaults to a two-element list with black and white), `stops` ([list] of
  /// [doubleOrZero]), and `tileMode` ([enumValue] of [TileMode], defaults to
  /// [TileMode.clamp]), these keys each corresponding to the properties of
  /// [BoxDecoration] with the same name.
  ///
  /// A type of `radial` creates a [RadialGradient] using the keys `center`
  /// ([alignment], defaults to [Alignment.center]), `radius' (double, defaults
  /// to 0.5), `colors` ([list] of [colorOrBlack], defaults to a two-element
  /// list with black and white), `stops` ([list] of [doubleOrZero]), `tileMode`
  /// ([enumValue] of [TileMode], defaults to [TileMode.clamp]), `focal`
  /// (([alignment]), and `focalRadius` (double, defaults to zero), these keys
  /// each corresponding to the properties of [BoxDecoration] with the same
  /// name.
  ///
  /// A type of `linear` creates a [LinearGradient] using the keys `center`
  /// ([alignment], defaults to [Alignment.center]), `startAngle` (double,
  /// defaults to 0.0), `endAngle` (double, defaults to 2π), `colors` ([list] of
  /// [colorOrBlack], defaults to a two-element list with black and white),
  /// `stops` ([list] of [doubleOrZero]), and `tileMode` ([enumValue] of [TileMode],
  /// defaults to [TileMode.clamp]), these keys each corresponding to the
  /// properties of [BoxDecoration] with the same name.
  ///
  /// The `transform` property of these gradient classes is not supported.
  // TODO(ianh): https://github.com/flutter/flutter/issues/87208
  ///
  /// If the type is none of these, but is not null, then the type is looked up
  /// in [gradientDecoders], and if an entry is found, this method defers to
  /// that callback.
  ///
  /// Otherwise, returns null.
  static Gradient? gradient(DataSource source, List<Object> key) {
    final String? type = source.v<String>([...key, 'type']);
    switch (type) {
      case null:
        return null;
      case 'linear':
        return LinearGradient(
          begin: alignment(source, [...key, 'begin']) ?? Alignment.centerLeft,
          end: alignment(source, [...key, 'end']) ?? Alignment.centerRight,
          colors: list<Color>(source, [...key, 'colors'], colorOrBlack) ?? const <Color>[Color(0xFF000000), Color(0xFFFFFFFF)],
          stops: list<double>(source, [...key, 'stops'], doubleOrZero),
          tileMode: enumValue<TileMode>(TileMode.values, source, [...key, 'tileMode']) ?? TileMode.clamp,
          // transform: GradientTransformMatrix(matrix(source, [...key, 'transform'])), // blocked by https://github.com/flutter/flutter/issues/87208
        );
      case 'radial':
        return RadialGradient(
          center: alignment(source, [...key, 'center']) ?? Alignment.center,
          radius: source.v<double>([...key, 'radius']) ?? 0.5,
          colors: list<Color>(source, [...key, 'colors'], colorOrBlack) ?? const <Color>[Color(0xFF000000), Color(0xFFFFFFFF)],
          stops: list<double>(source, [...key, 'stops'], doubleOrZero),
          tileMode: enumValue<TileMode>(TileMode.values, source, [...key, 'tileMode']) ?? TileMode.clamp,
          focal: alignment(source, [...key, 'focal']),
          focalRadius: source.v<double>([...key, 'focalRadius']) ?? 0.0,
          // transform: GradientTransformMatrix(matrix(source, [...key, 'transform'])), // blocked by https://github.com/flutter/flutter/issues/87208
        );
      case 'sweep':
        return SweepGradient(
          center: alignment(source, [...key, 'center']) ?? Alignment.center,
          startAngle: source.v<double>([...key, 'startAngle']) ?? 0.0,
          endAngle: source.v<double>([...key, 'endAngle']) ?? math.pi * 2,
          colors: list<Color>(source, [...key, 'colors'], colorOrBlack) ?? const <Color>[Color(0xFF000000), Color(0xFFFFFFFF)],
          stops: list<double>(source, [...key, 'stops'], doubleOrZero),
          tileMode: enumValue<TileMode>(TileMode.values, source, [...key, 'tileMode']) ?? TileMode.clamp,
          // transform: GradientTransformMatrix(matrix(source, [...key, 'transform'])), // blocked by https://github.com/flutter/flutter/issues/87208
        );
      default:
        final ArgumentDecoder<Gradient?>? decoder = gradientDecoders[type];
        if (decoder == null) {
          return null;
        }
        return decoder(source, key);
    }
  }

  /// Extension mechanism for [gradient].
  static final Map<String, ArgumentDecoder<Gradient?>> gradientDecoders = <String, ArgumentDecoder<Gradient?>>{};

  /// Returns a [SliverGridDelegate] from the specified map.
  ///
  /// The `type` key specifies the kind of grid delegate.
  ///
  /// A type of `fixedCrossAxisCount` creates a
  /// [SliverGridDelegateWithFixedCrossAxisCount] using the keys
  /// `crossAxisCount`, `mainAxisSpacing`, `crossAxisSpacing`,
  /// `childAspectRatio`, and `mainAxisExtent`.
  ///
  /// A type of `maxCrossAxisExtent` creates a
  /// [SliverGridDelegateWithMaxCrossAxisExtent] using the keys
  /// maxCrossAxisExtent:`, `mainAxisSpacing`, `crossAxisSpacing`,
  /// `childAspectRatio`, and `mainAxisExtent`.
  ///
  /// The types (int or double) and defaults for these keys match the
  /// identically named arguments to the default constructors of those classes.
  ///
  /// If the type is none of these, but is not null, then the type is looked up
  /// in [gridDelegateDecoders], and if an entry is found, this method defers to
  /// that callback.
  ///
  /// Otherwise, returns null.
  static SliverGridDelegate? gridDelegate(DataSource source, List<Object> key) {
    final String? type = source.v<String>([...key, 'type']);
    switch (type) {
      case null:
        return null;
      case 'fixedCrossAxisCount':
        return SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: source.v<int>([...key, 'crossAxisCount']) ?? 2,
          mainAxisSpacing: source.v<double>([...key, 'mainAxisSpacing']) ?? 0.0,
          crossAxisSpacing: source.v<double>([...key, 'crossAxisSpacing']) ?? 0.0,
          childAspectRatio: source.v<double>([...key, 'childAspectRatio']) ?? 1.0,
          mainAxisExtent: source.v<double>([...key, 'mainAxisExtent']),
        );
      case 'maxCrossAxisExtent':
        return SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: source.v<double>([...key, 'maxCrossAxisExtent']) ?? 100.0,
          mainAxisSpacing: source.v<double>([...key, 'mainAxisSpacing']) ?? 0.0,
          crossAxisSpacing: source.v<double>([...key, 'crossAxisSpacing']) ?? 0.0,
          childAspectRatio: source.v<double>([...key, 'childAspectRatio']) ?? 1.0,
          mainAxisExtent: source.v<double>([...key, 'mainAxisExtent']),
        );
      default:
        final ArgumentDecoder<SliverGridDelegate?>? decoder = gridDelegateDecoders[type];
        if (decoder == null) {
          return null;
        }
        return decoder(source, key);
    }
  }

  /// Extension mechanism for [gridDelegate].
  static final Map<String, ArgumentDecoder<SliverGridDelegate?>> gridDelegateDecoders = <String, ArgumentDecoder<SliverGridDelegate?>>{};

  /// Returns an [IconData] from the specified map.
  ///
  /// If the map does not have an `icon` key that is an integer, returns null.
  ///
  /// Otherwise, returns an [IconData] with the [IconData.codePoint] set to the
  /// integer from the `icon` key, the [IconData.fontFamily] set to the string
  /// from the `fontFamily` key, and the [IconData.matchTextDirection] set to
  /// the boolean from the `matchTextDirection` key (defaulting to false).
  ///
  /// For Material Design icons (those from the [Icons] class), the code point
  /// can be obtained from the documentation for the icon, and the font family
  /// is `MaterialIcons`. For example, [Icons.chalet] would correspond to
  /// `{ icon: 0xe14f, fontFamily: 'MaterialIcons' }`.
  ///
  /// When building the release build of an application that uses the RFW
  /// package, because this method creates non-const [IconData] objects
  /// dynamically, the `--no-tree-shake-icons` option must be used.
  static IconData? iconData(DataSource source, List<Object> key) {
    final int? icon = source.v<int>([...key, 'icon']);
    if (icon == null) {
      return null;
    }
    return IconData(
      icon,
      fontFamily: source.v<String>([...key, 'fontFamily']),
      matchTextDirection: source.v<bool>([...key, 'matchTextDirection']) ?? false,
    );
  }

  /// Returns an [IconThemeData] from the specified map.
  ///
  /// If the map is absent, returns null.
  ///
  /// Otherwise (even if it has no keys), the [IconThemeData] is created from
  /// the following keys: 'color` ([color]), `opacity` (double), `size`
  /// (double).
  static IconThemeData? iconThemeData(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return null;
    }
    return IconThemeData(
      color: color(source, [...key, 'color']),
      opacity: source.v<double>([...key, 'opacity']),
      size: source.v<double>([...key, 'size']),
    );
  }

  /// Returns an [ImageProvider] from the specifed map.
  ///
  /// The `source` key of the specified map is controlling. It must be a string.
  /// If its value is one of the keys in [imageProviderDecoders], then the
  /// relevant decoder is invoked and its return value is used (even if it is
  /// null).
  ///
  /// Otherwise, if the `source` key gives an absolute URL (one with a scheme),
  /// then a [NetworkImage] with that URL is returned. Its scale is given by the
  /// `scale` key (double, defaults to 1.0).
  ///
  /// Otherwise, if the `source` key gives a relative URL (i.e. it can be parsed
  /// as a URL and has no scheme), an [AssetImage] with the name given by the
  /// `source` key is returned.
  ///
  /// Otherwise, if there is no `source` key in the map, or if that cannot be
  /// parsed as a URL (absolute or relative), null is returned.
  static ImageProvider? imageProvider(DataSource source, List<Object> key) {
    final String? image = source.v<String>([...key, 'source']);
    if (image == null) {
      return null;
    }
    if (imageProviderDecoders.containsKey(image)) {
      return imageProviderDecoders[image]!(source, key);
    }
    final Uri? imageUrl = Uri.tryParse(image);
    if (imageUrl == null) {
      return null;
    }
    if (!imageUrl.hasScheme) {
      return AssetImage(image);
    }
    return NetworkImage(image, scale: source.v<double>([...key, 'scale']) ?? 1.0);
  }

  /// Extension mechanism for [imageProvider].
  static final Map<String, ArgumentDecoder<ImageProvider?>> imageProviderDecoders = <String, ArgumentDecoder<ImageProvider?>>{};

  /// Returns a [List] of `T` values from the specified list, using the given
  /// `decoder` to parse each value.
  ///
  /// If the list is absent _or empty_, returns null (not an empty list).
  ///
  /// Otherwise, returns a list with as many items as the specified list, with
  /// each entry in the list decoded using `decoder`.
  ///
  /// If `T` is non-nullable, the decoder must also be non-nullable.
  static List<T>? list<T>(DataSource source, List<Object> key, ArgumentDecoder<T> decoder) {
    final int count = source.length(key);
    if (count == 0) {
      return null;
    }
    return List<T>.generate(count, (int index) {
      return decoder(source, [...key, index]);
    });
  }

  /// Returns a [Locale] from the specified string.
  ///
  /// The string is split on hyphens ("-").
  ///
  /// If the string is null, returns null.
  ///
  /// If there is no hyphen in the list, uses the one-argument form of [
  /// Locale], passing the whole string.
  ///
  /// If there is one hyphen in the list, uses the two-argument form of [
  /// Locale], passing the parts before and after the hyphen respectively.
  ///
  /// If there are two or more hyphens, uses the [Locale.fromSubtags]
  /// constructor.
  static Locale? locale(DataSource source, List<Object> key) {
    final String? value = source.v<String>(key);
    if (value == null) {
      return null;
    }
    final List<String> subtags = value.split('-');
    if (subtags.isEmpty) {
      return null;
    }
    if (subtags.length == 1) {
      return Locale(value);
    }
    if (subtags.length == 2) {
      return Locale(subtags[0], subtags[1]);
    }
    // TODO(ianh): verify this is correct (I tried looking up the Unicode spec but it was... confusing)
    return Locale.fromSubtags(languageCode: subtags[0], scriptCode: subtags[1], countryCode: subtags[2]);
  }

  /// Returns a list of 16 doubles from the specified list.
  ///
  /// If the list is missing or has fewer than 16 entries, returns null.
  ///
  /// Otherwise, returns a list of 16 entries, corresponding to the first 16
  /// entries of the specified list, with any non-double values replaced by 0.0.
  static Matrix4? matrix(DataSource source, List<Object> key) {
    final double? arg15 = source.v<double>([...key, 15]);
    if (arg15 == null) {
      return null;
    }
    return Matrix4(
      source.v<double>([...key, 0]) ?? 0.0,
      source.v<double>([...key, 1]) ?? 0.0,
      source.v<double>([...key, 2]) ?? 0.0,
      source.v<double>([...key, 3]) ?? 0.0,
      source.v<double>([...key, 4]) ?? 0.0,
      source.v<double>([...key, 5]) ?? 0.0,
      source.v<double>([...key, 6]) ?? 0.0,
      source.v<double>([...key, 7]) ?? 0.0,
      source.v<double>([...key, 8]) ?? 0.0,
      source.v<double>([...key, 9]) ?? 0.0,
      source.v<double>([...key, 10]) ?? 0.0,
      source.v<double>([...key, 11]) ?? 0.0,
      source.v<double>([...key, 12]) ?? 0.0,
      source.v<double>([...key, 13]) ?? 0.0,
      source.v<double>([...key, 14]) ?? 0.0,
      arg15,
    );
  }

  /// Returns a [MaskFilter] from the specified map.
  ///
  /// The `type` key specifies the kind of mask filter.
  ///
  /// A type of `blur` creates a [MaskFilter.blur]. The `style` key ([enumValue] of
  /// [BlurStyle], defaults to [BlurStyle.normal]) is used as the blur style,
  /// and the `sigma` key (double, defaults to 1.0) is used as the blur sigma.
  ///
  /// If the type is none of these, but is not null, then the type is looked up
  /// in [maskFilterDecoders], and if an entry is found, this method defers to
  /// that callback.
  ///
  /// Otherwise, returns null.
  static MaskFilter? maskFilter(DataSource source, List<Object> key) {
    final String? type = source.v<String>([...key, 'type']);
    switch (type) {
      case null:
        return null;
      case 'blur':
        return MaskFilter.blur(
          enumValue<BlurStyle>(BlurStyle.values, source, [...key, 'style']) ?? BlurStyle.normal,
          source.v<double>([...key, 'sigma']) ?? 1.0,
        );
      default:
        final ArgumentDecoder<MaskFilter?>? decoder = maskFilterDecoders[type];
        if (decoder == null) {
          return null;
        }
        return decoder(source, key);
    }
  }

  /// Extension mechanism for [maskFilter].
  static final Map<String, ArgumentDecoder<MaskFilter?>> maskFilterDecoders = <String, ArgumentDecoder<MaskFilter?>>{};

  /// Returns an [Offset] from the specified map.
  ///
  /// The map must have an `x` key and a `y` key, doubles.
  static Offset? offset(DataSource source, List<Object> key) {
    final double? x = source.v<double>([...key, 'x']);
    if (x == null) {
      return null;
    }
    final double? y = source.v<double>([...key, 'y']);
    if (y == null) {
      return null;
    }
    return Offset(x, y);
  }

  /// Returns a [Paint] from the specified map.
  ///
  /// If the map is absent, returns null.
  ///
  /// Otherwise (even if it has no keys), a new [Paint] is created and its
  /// properties are set according to the identically-named properties of the
  /// map, as follows:
  ///
  ///  * `blendMode`: [enumValue] of [BlendMode].
  ///  * `color`: [color].
  ///  * `colorFilter`: [colorFilter].
  ///  * `filterQuality`: [enumValue] of [FilterQuality].
  //  * `imageFilter`: [imageFilter].
  //  * `invertColors`: boolean.
  ///  * `isAntiAlias`: boolean.
  ///  * `maskFilter`: [maskFilter].
  ///  * `shader`: [shader].
  //  * `strokeCap`: [enumValue] of [StrokeCap].
  //  * `strokeJoin`: [enumValue] of [StrokeJoin].
  //  * `strokeMiterLimit`: double.
  //  * `strokeWidth`: double.
  //  * `style`: [enumValue] of [PaintingStyle].
  ///
  /// (Some values are not supported, because there is no way for them to be
  /// used currently in RFW contexts.)
  static Paint? paint(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return null;
    }
    final Paint result = Paint();
    final BlendMode? paintBlendMode = enumValue<BlendMode>(BlendMode.values, source, [...key, 'blendMode']);
    if (paintBlendMode != null) {
      result.blendMode = paintBlendMode;
    }
    final Color? paintColor = color(source, [...key, 'color']);
    if (paintColor != null) {
      result.color = paintColor;
    }
    final ColorFilter? paintColorFilter = colorFilter(source, [...key, 'colorFilter']);
    if (paintColorFilter != null) {
      result.colorFilter = paintColorFilter;
    }
    final FilterQuality? paintFilterQuality = enumValue<FilterQuality>(FilterQuality.values, source, [...key, 'filterQuality']);
    if (paintFilterQuality != null) {
      result.filterQuality = paintFilterQuality;
    }
    // final ImageFilter? paintImageFilter = imageFilter(source, [...key, 'imageFilter']);
    // if (paintImageFilter != null) {
    //   result.imageFilter = paintImageFilter;
    // }
    // final bool? paintInvertColors = source.v<bool>([...key, 'invertColors']);
    // if (paintInvertColors != null) {
    //   result.invertColors = paintInvertColors;
    // }
    final bool? paintIsAntiAlias = source.v<bool>([...key, 'isAntiAlias']);
    if (paintIsAntiAlias != null) {
      result.isAntiAlias = paintIsAntiAlias;
    }
    final MaskFilter? paintMaskFilter = maskFilter(source, [...key, 'maskFilter']);
    if (paintMaskFilter != null) {
      result.maskFilter = paintMaskFilter;
    }
    final Shader? paintShader = shader(source, [...key, 'shader']);
    if (paintShader != null) {
      result.shader = paintShader;
    }
    // final StrokeCap? paintStrokeCap = enumValue<StrokeCap>(StrokeCap.values, source, [...key, 'strokeCap']),
    // if (paintStrokeCap != null) {
    //   result.strokeCap = paintStrokeCap;
    // }
    // final StrokeJoin? paintStrokeJoin = enumValue<StrokeJoin>(StrokeJoin.values, source, [...key, 'strokeJoin']),
    // if (paintStrokeJoin != null) {
    //   result.strokeJoin = paintStrokeJoin;
    // }
    // final double paintStrokeMiterLimit? = source.v<double>([...key, 'strokeMiterLimit']),
    // if (paintStrokeMiterLimit != null) {
    //   result.strokeMiterLimit = paintStrokeMiterLimit;
    // }
    // final double paintStrokeWidth? = source.v<double>([...key, 'strokeWidth']),
    // if (paintStrokeWidth != null) {
    //   result.strokeWidth = paintStrokeWidth;
    // }
    // final PaintingStyle? paintStyle = enumValue<PaintingStyle>(PaintingStyle.values, source, [...key, 'style']),
    // if (paintStyle != null) {
    //   result.style = paintStyle;
    // }
    return result;
  }

  /// Returns a [Radius] from the specified map.
  ///
  /// The map must have an `x` value corresponding to [Radius.x], and may have a
  /// `y` value corresponding to [Radius.y].
  ///
  /// If the map only has an `x` key, the `y` value is assumed to be the same
  /// (as in [Radius.circular]).
  ///
  /// If the `x` key is absent, the returned value is null.
  static Radius? radius(DataSource source, List<Object> key) {
    final double? x = source.v<double>([...key, 'x']);
    if (x == null) {
      return null;
    }
    final double y = source.v<double>([...key, 'y']) ?? x;
    return Radius.elliptical(x, y);
  }

  /// Returns a [Rect] from the specified map.
  ///
  /// If the map is absent, returns null.
  ///
  /// Otherwise, returns a [Rect.fromLTWH] whose x, y, width, and height
  /// components are determined from the `x`, `y`, `w`, and `h` properties of
  /// the map, with missing (or non-double) values replaced by zeros.
  static Rect? rect(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return null;
    }
    final double x = source.v<double>([...key, 'x']) ?? 0.0;
    final double y = source.v<double>([...key, 'y']) ?? 0.0;
    final double w = source.v<double>([...key, 'w']) ?? 0.0;
    final double h = source.v<double>([...key, 'h']) ?? 0.0;
    return Rect.fromLTWH(x, y, w, h);
  }

  /// Returns a [ShapeBorder] from the specified map or list.
  ///
  /// If the key identifies a list, then each entry in the list is decoded by
  /// recursively invoking [shapeBorder], and the result is the combination of
  /// those [ShapeBorder] values as obtained using the [ShapeBorder.+] operator.
  ///
  /// Otherwise, if the key identifies a map with a `type` value, the map is
  /// interpreted according to the `type` as follows:
  ///
  ///  * `box`: the map's `sides` key is interpreted as a list by [border] and
  ///     the resulting [BoxBorder] (actually, [BorderDirectional]) is returned.
  ///
  ///  * `beveled`: a [BeveledRectangleBorder] is returned; the `side` key is
  ///    interpreted by [borderSide] to set the [BeveledRectangleBorder.side]
  ///    (default of [BorderSide.none)), and the `borderRadius` key is
  ///    interpreted by [borderRadius] to set the
  ///    [BeveledRectangleBorder.borderRadius] (default [BorderRadius.zero]).
  ///
  ///  * `circle`: a [CircleBorder] is returned; the `side` key is interpreted
  ///    by [borderSide] to set the [BeveledRectangleBorder.side] (default of
  ///    [BorderSide.none)).
  ///
  ///  * `continuous`: a [ContinuousRectangleBorder] is returned; the `side` key
  ///    is interpreted by [borderSide] to set the [BeveledRectangleBorder.side]
  ///    (default of [BorderSide.none)), and the `borderRadius` key is
  ///    interpreted by [borderRadius] to set the
  ///    [BeveledRectangleBorder.borderRadius] (default [BorderRadius.zero]).
  ///
  ///  * `rounded`: a [RoundedRectangleBorder] is returned; the `side` key is
  ///    interpreted by [borderSide] to set the [BeveledRectangleBorder.side]
  ///    (default of [BorderSide.none)), and the `borderRadius` key is
  ///    interpreted by [borderRadius] to set the
  ///    [BeveledRectangleBorder.borderRadius] (default [BorderRadius.zero]).
  ///
  ///  * `stadium`: a [StadiumBorder] is returned; the `side` key is interpreted
  ///    by [borderSide] to set the [BeveledRectangleBorder.side] (default of
  ///    [BorderSide.none)).
  ///
  /// If the type is none of these, then the type is looked up in
  /// [shapeBorderDecoders], and if an entry is found, this method defers to
  /// that callback.
  ///
  /// Otherwise, if type is null or is not found in [shapeBorderDecoders], returns null.
  static ShapeBorder? shapeBorder(DataSource source, List<Object> key) {
    final List<ShapeBorder?>? shapes = list<ShapeBorder?>(source, key, shapeBorder);
    if (shapes != null) {
      return shapes.where((ShapeBorder? a) => a != null).reduce((ShapeBorder? a, ShapeBorder? b) => a! + b!);
    }
    final String? type = source.v<String>([...key, 'type']);
    switch (type) {
      case null:
        return null;
      case 'box':
        return border(source, [...key, 'sides']) ?? const Border();
      case 'beveled':
        return BeveledRectangleBorder(
          side: borderSide(source, [...key, 'side']) ?? BorderSide.none,
          borderRadius: borderRadius(source, [...key, 'borderRadius']) ?? BorderRadius.zero,
        );
      case 'circle':
        return CircleBorder(
          side: borderSide(source, [...key, 'side']) ?? BorderSide.none,
        );
      case 'continuous':
        return ContinuousRectangleBorder(
          side: borderSide(source, [...key, 'side']) ?? BorderSide.none,
          borderRadius: borderRadius(source, [...key, 'borderRadius']) ?? BorderRadius.zero,
        );
      case 'rounded':
        return RoundedRectangleBorder(
          side: borderSide(source, [...key, 'side']) ?? BorderSide.none,
          borderRadius: borderRadius(source, [...key, 'borderRadius']) ?? BorderRadius.zero,
        );
      case 'stadium':
        return StadiumBorder(
          side: borderSide(source, [...key, 'side']) ?? BorderSide.none,
        );
      default:
        final ArgumentDecoder<ShapeBorder>? decoder = shapeBorderDecoders[type];
        if (decoder == null) {
          return null;
        }
        return decoder(source, key);
    }
  }

  /// Extension mechanism for [shapeBorder].
  static final Map<String, ArgumentDecoder<ShapeBorder>> shapeBorderDecoders = <String, ArgumentDecoder<ShapeBorder>>{};

  /// Returns a [Shader] based on the specified map.
  ///
  /// The `type` key specifies the kind of shader.
  ///
  /// A type of `linear`, `radial`, or `sweep` is interpreted as described by
  /// [gradient]; then, the gradient is compiled to a shader by applying the
  /// `rect` (interpreted by [rect]) and `textDirection` (interpreted as an
  /// [enumValue] of [TextDirection]) using the [Gradient.createShader] method.
  ///
  /// If the type is none of these, but is not null, then the type is looked up
  /// in [shaderDecoders], and if an entry is found, this method defers to
  /// that callback.
  ///
  /// Otherwise, returns null.
  static Shader? shader(DataSource source, List<Object> key) {
    final String? type = source.v<String>([...key, 'type']);
    switch (type) {
      case null:
        return null;
      case 'linear':
      case 'radial':
      case 'sweep':
        return gradient(source, key)!.createShader(
          rect(source, [...key, 'rect']) ?? Rect.zero,
          textDirection: enumValue<TextDirection>(TextDirection.values, source, ['textDirection']) ?? TextDirection.ltr,
        );
      default:
        final ArgumentDecoder<Shader?>? decoder = shaderDecoders[type];
        if (decoder == null) {
          return null;
        }
        return decoder(source, key);
    }
  }

  /// Extension mechanism for [shader].
  static final Map<String, ArgumentDecoder<Shader?>> shaderDecoders = <String, ArgumentDecoder<Shader?>>{};

  /// Returns a string from the specified string.
  ///
  /// Returns the empty string if it's not a string.
  ///
  /// This is useful in situations where null is not acceptable, for example,
  /// when providing a decoder to [list]. Otherwise, prefer using [DataSource.v]
  /// directly.
  static String string(DataSource source, List<Object> key) {
    return source.v<String>(key) ?? '';
  }

  /// Returns a [StrutStyle] from the specified map.
  ///
  /// If the map is absent, returns null.
  ///
  /// Otherwise (even if it has no keys), the [StrutStyle] is created from the
  /// following keys: 'fontFamily` (string), `fontFamilyFallback` ([list] of
  /// [string]), `fontSize` (double), `height` (double), `leadingDistribution`
  /// ([enumValue] of [TextLeadingDistribution]), `leading` (double),
  /// `fontWeight` ([enumValue] of [FontWeight]), `fontStyle` ([enumValue] of
  /// [FontStyle]), `forceStrutHeight` (boolean).
  static StrutStyle? strutStyle(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return null;
    }
    return StrutStyle(
      fontFamily: source.v<String>([...key, 'fontFamily']),
      fontFamilyFallback: list<String>(source, [...key, 'fontFamilyFallback'], string),
      fontSize: source.v<double>([...key, 'fontSize']),
      height: source.v<double>([...key, 'height']),
      leadingDistribution: enumValue<TextLeadingDistribution>(TextLeadingDistribution.values, source, [...key, 'leadingDistribution']),
      leading: source.v<double>([...key, 'leading']),
      fontWeight: enumValue<FontWeight>(FontWeight.values, source, [...key, 'fontWeight']),
      fontStyle: enumValue<FontStyle>(FontStyle.values, source, [...key, 'fontStyle']),
      forceStrutHeight: source.v<bool>([...key, 'forceStrutHeight']),
    );
  }

  /// Returns a [TextHeightBehavior] from the specified map.
  ///
  /// If the map is absent, returns null.
  ///
  /// Otherwise (even if it has no keys), the [TextHeightBehavior] is created
  /// from the following keys: 'applyHeightToFirstAscent` (boolean; defaults to
  /// true), `applyHeightToLastDescent` (boolean, defaults to true), and
  /// `leadingDistribution` ([enumValue] of [TextLeadingDistribution], deafults
  /// to [TextLeadingDistribution.proportional]).
  static TextHeightBehavior? textHeightBehavior(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return null;
    }
    return TextHeightBehavior(
      applyHeightToFirstAscent: source.v<bool>([...key, 'applyHeightToFirstAscent']) ?? true,
      applyHeightToLastDescent: source.v<bool>([...key, 'applyHeightToLastDescent']) ?? true,
      leadingDistribution: enumValue<TextLeadingDistribution>(TextLeadingDistribution.values, source, [...key, 'leadingDistribution']) ?? TextLeadingDistribution.proportional,
    );
  }

  /// Returns a [TextDecoration] from the specified list or string.
  ///
  /// If the key identifies a list, then each entry in the list is decoded by
  /// recursively invoking [textDecoration], and the result is the combination
  /// of those [TextDecoration] values as obtained using
  /// [TextDecoration.combine].
  ///
  /// Otherwise, if the key identifies a string, then the value `lineThrough` is
  /// mapped to [TextDecoration.lineThrough], `overline` to
  /// [TextDecoration.overline], and `underline` to [TextDecoration.underline].
  /// Other values (and the abscence of a value) are interpreted as
  /// [TextDecoration.none].
  static TextDecoration textDecoration(DataSource source, List<Object> key) {
    final List<TextDecoration>? decorations = list<TextDecoration>(source, key, textDecoration);
    if (decorations != null) {
      return TextDecoration.combine(decorations);
    }
    switch (source.v<String>([...key])) {
      case 'lineThrough':
        return TextDecoration.lineThrough;
      case 'overline':
        return TextDecoration.overline;
      case 'underline':
        return TextDecoration.underline;
      default:
        return TextDecoration.none;
    }
  }

  /// Returns a [TextStyle] from the specified map.
  ///
  /// If the map is absent, returns null.
  ///
  /// Otherwise (even if it has no keys), the [TextStyle] is created from the
  /// following keys: `color` ([color]), `backgroundColor` ([color]), `fontSize`
  /// (double), `fontWeight` ([enumValue] of [FontWeight]), `fontStyle`
  /// ([enumValue] of [FontStyle]), `letterSpacing` (double), `wordSpacing`
  /// (double), `textBaseline` ([enumValue] of [TextBaseline]), `height`
  /// (double), `leadingDistribution` ([enumValue] of
  /// [TextLeadingDistribution]), `locale` ([locale]), `foreground` ([paint]),
  /// `background` ([paint]), `shadows` ([list] of [boxShadow]s), `fontFeatures`
  /// ([list] of [fontFeature]s), `decoration` ([textDecoration]),
  /// `decorationColor` ([color]), `decorationStyle` ([enumValue] of
  /// [TextDecorationStyle]), `decorationThickness` (double), 'fontFamily`
  /// (string), `fontFamilyFallback` ([list] of [string]), and `overflow`
  /// ([enumValue] of [TextOverflow]).
  static TextStyle? textStyle(DataSource source, List<Object> key) {
    if (!source.isMap(key)) {
      return null;
    }
    return TextStyle(
      color: color(source, [...key, 'color']),
      backgroundColor: color(source, [...key, 'backgroundColor']),
      fontSize: source.v<double>([...key, 'fontSize']),
      fontWeight: enumValue<FontWeight>(FontWeight.values, source, [...key, 'fontWeight']),
      fontStyle: enumValue<FontStyle>(FontStyle.values, source, [...key, 'fontStyle']),
      letterSpacing: source.v<double>([...key, 'letterSpacing']),
      wordSpacing: source.v<double>([...key, 'wordSpacing']),
      textBaseline: enumValue<TextBaseline>(TextBaseline.values, source, ['textBaseline']),
      height: source.v<double>([...key, 'height']),
      leadingDistribution: enumValue<TextLeadingDistribution>(TextLeadingDistribution.values, source, [...key, 'leadingDistribution']),
      locale: locale(source, [...key, 'locale']),
      foreground: paint(source, [...key, 'foreground']),
      background: paint(source, [...key, 'background']),
      shadows: list<BoxShadow>(source, [...key, 'shadows'], boxShadow),
      fontFeatures: list<FontFeature>(source, [...key, 'fontFeatures'], fontFeature),
      decoration: textDecoration(source, [...key, 'decoration']),
      decorationColor: color(source, [...key, 'decorationColor']),
      decorationStyle: enumValue<TextDecorationStyle>(TextDecorationStyle.values, source, [...key, 'decorationStyle']),
      decorationThickness: source.v<double>([...key, 'decorationThickness']),
      fontFamily: source.v<String>([...key, 'fontFamily']),
      fontFamilyFallback: list<String>(source, [...key, 'fontFamilyFallback'], string),
      overflow: enumValue<TextOverflow>(TextOverflow.values, source, ['overflow']),
    );
  }

  /// Returns a [VisualDensity] from the specified string or map.
  ///
  /// If the specified value is a string, then it is interpreted as follows:
  ///
  ///  * `adaptivePlatformDensity`: returns
  ///    [VisualDensity.adaptivePlatformDensity] (which varies by platform).
  ///  * `comfortable`: returns [VisualDensity.comfortable].
  ///  * `compact`: returns [VisualDensity.compact].
  ///  * `standard`: returns [VisualDensity.standard].
  ///
  /// Otherwise, if the specified value is a map, then the keys `horizontal` and
  /// `vertical` (doubles) are used to create a custom [VisualDensity]. The
  /// specified values must be in the range given by
  /// [VisualDensity.minimumDensity] to [VisualDensity.maximumDensity]. Missing
  /// values are interpreted as zero.
  static VisualDensity? visualDensity(DataSource source, List<Object> key) {
    final String? type = source.v<String>(key);
    switch (type) {
      case 'adaptivePlatformDensity':
        return VisualDensity.adaptivePlatformDensity;
      case 'comfortable':
        return VisualDensity.comfortable;
      case 'compact':
        return VisualDensity.compact;
      case 'standard':
        return VisualDensity.standard;
      default:
        if (!source.isMap(key)) {
          return null;
        }
        return VisualDensity(
          horizontal: source.v<double>([...key, 'horizontal']) ?? 0.0,
          vertical: source.v<double>([...key, 'vertical']) ?? 0.0,
        );
    }
  }
}
