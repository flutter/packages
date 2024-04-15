// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'span.dart';

// This file is NOT exported as part of the package.

/// A contextual used by the [RenderTableViewport].
///
/// Used to track the layout information, and additional configurations of the
/// span during multiple layout passes.
abstract class ImplementedSpan
    with Diagnosticable
    implements HitTestTarget, MouseTrackerAnnotation {
  /// The leading edge of the span in the viewport, orientated to the column or
  /// row it represents.
  double get leadingOffset => _leadingOffset;
  late double _leadingOffset;

  /// The extent of the span.
  double get extent => _extent;
  late double _extent;

  /// The Span that was used to populate this implemented span.
  Span get configuration => _configuration!;
  Span? _configuration;

  /// The trailing offset of the span.
  ///
  /// Includes any padding the span may have.
  double get trailingOffset {
    return leadingOffset +
        extent +
        configuration.padding.leading +
        configuration.padding.trailing;
  }

  // ---- Span Management ----

  /// Called to update the span as needed by [RenderTableViewport].
  void update({
    required Span configuration,
    required double leadingOffset,
    required double extent,
  }) {
    _leadingOffset = leadingOffset;
    _extent = extent;
    if (configuration == _configuration) {
      return;
    }
    _configuration = configuration;
    // Only sync recognizers if they are in use already.
    if (_recognizers != null) {
      _syncRecognizers();
    }
  }

  /// Disposes of the span and its recognizers.
  void dispose() {
    _disposeRecognizers();
  }

  // ---- Recognizers management ----

  Map<Type, GestureRecognizer>? _recognizers;

  void _syncRecognizers() {
    if (configuration.recognizerFactories.isEmpty) {
      _disposeRecognizers();
      return;
    }
    final Map<Type, GestureRecognizer> newRecognizers =
        <Type, GestureRecognizer>{};
    for (final Type type in configuration.recognizerFactories.keys) {
      assert(!newRecognizers.containsKey(type));
      newRecognizers[type] = _recognizers?.remove(type) ??
          configuration.recognizerFactories[type]!.constructor();
      assert(
        newRecognizers[type].runtimeType == type,
        'GestureRecognizerFactory of type $type created a GestureRecognizer of '
        'type ${newRecognizers[type].runtimeType}. The '
        'GestureRecognizerFactory must be specialized with the type of the '
        'class that it returns from its constructor method.',
      );
      configuration.recognizerFactories[type]!
          .initializer(newRecognizers[type]!);
    }
    _disposeRecognizers(); // only disposes the ones that where not re-used above.
    _recognizers = newRecognizers;
  }

  void _disposeRecognizers() {
    if (_recognizers != null) {
      for (final GestureRecognizer recognizer in _recognizers!.values) {
        recognizer.dispose();
      }
      _recognizers = null;
    }
  }

  // ---- HitTestTarget ----

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent &&
        configuration.recognizerFactories.isNotEmpty) {
      if (_recognizers == null) {
        _syncRecognizers();
      }
      assert(_recognizers != null);
      for (final GestureRecognizer recognizer in _recognizers!.values) {
        recognizer.addPointer(event);
      }
    }
  }

  // ---- MouseTrackerAnnotation ----

  @override
  MouseCursor get cursor => configuration.cursor;

  @override
  PointerEnterEventListener? get onEnter => configuration.onEnter;

  @override
  PointerExitEventListener? get onExit => configuration.onExit;

  @override
  bool get validForMouseTracker => true;
}
