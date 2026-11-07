// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'span.dart';

/// The mutable runtime state and layout metrics for a [Span] in a two
/// dimensional viewport.
///
/// Manages layout offsets, [GestureRecognizer]s, mouse tracking, interactive
/// [WidgetState]s, and [SpanDecoration] animations for a row or column.
///
/// The type [T] represents the [Span] configuration managed by this instance.
@internal
class SpanState<T extends Span>
    with Diagnosticable
    implements HitTestTarget, MouseTrackerAnnotation {
  /// Creates a [SpanState].
  SpanState({this.onStateChanged});

  /// Called when the interactive state or active decoration animation of this
  /// span changes and the viewport needs to repaint.
  final VoidCallback? onStateChanged;

  /// The leading pixel offset of this span.
  double get leadingOffset => _leadingOffset;
  late double _leadingOffset;

  /// The layout extent of this span along its axis.
  double get extent => _extent;
  late double _extent;

  /// The [Span] configuration for this state.
  T get configuration => _configuration!;
  T? _configuration;

  /// The trailing pixel offset of this span, including leading and trailing
  /// [SpanPadding].
  double get trailingOffset {
    return leadingOffset + extent + configuration.padding.leading + configuration.padding.trailing;
  }

  /// The current interactive [WidgetState]s of this span.
  Set<WidgetState> get states =>
      _states.isEmpty ? const <WidgetState>{} : Set<WidgetState>.unmodifiable(_states);
  final Set<WidgetState> _states = <WidgetState>{};

  /// The interactive [WidgetState]s of this span prior to the latest
  /// transition.
  ///
  /// Used together with [stateAnimationProgress] to interpolate between
  /// states when [SpanDecoration.animationStyle] is configured.
  Set<WidgetState> get previousStates => _previousStates.isEmpty
      ? const <WidgetState>{}
      : Set<WidgetState>.unmodifiable(_previousStates);
  Set<WidgetState> _previousStates = const <WidgetState>{};

  /// The progress of the current state transition animation, from 0.0 to 1.0.
  ///
  /// Defaults to 1.0 when no state transition animation is active.
  double get stateAnimationProgress => _stateAnimationProgress;
  double _stateAnimationProgress = 1.0;

  /// The most recent pointer down position on this span in viewport
  /// coordinates.
  ///
  /// Used as the origin for tap splash animations when
  /// [SpanDecoration.splashColor] is configured.
  Offset? get pointerPosition => _pointerPosition;
  Offset? _pointerPosition;

  /// The progress of the current tap splash animation, from 0.0 to 1.0.
  ///
  /// Defaults to 0.0 when no splash animation is active.
  double get splashProgress => _splashProgress;
  double _splashProgress = 0.0;

  bool _disposed = false;
  final Set<int> _activePointers = <int>{};
  bool _splashAnimating = false;
  int? _frameCallbackId;
  Duration? _stateAnimationStartTime;
  double _stateAnimationRawProgress = 1.0;
  double _stateAnimationInitialProgress = 0.0;
  bool _stateAnimationReversed = false;
  Duration? _splashAnimationStartTime;
  Map<Type, GestureRecognizer>? _recognizers;

  /// Updates the layout metrics and [configuration] for this span.
  ///
  /// If [configuration] has changed and [GestureRecognizer]s have already been
  /// initialized, they will be synchronized with the new
  /// [Span.recognizerFactories].
  @mustCallSuper
  void update({required T configuration, required double leadingOffset, required double extent}) {
    _leadingOffset = leadingOffset;
    _extent = extent;
    if (configuration == _configuration) {
      return;
    }
    _configuration = configuration;
    if (!_hasDecorations) {
      if (configuration.onExit == null) {
        _states.remove(WidgetState.hovered);
      }
      _previousStates = const <WidgetState>{};
      _stateAnimationProgress = 1.0;
      _stateAnimationRawProgress = 1.0;
      _stateAnimationStartTime = null;
      _splashAnimating = false;
      _splashProgress = 0.0;
      _splashAnimationStartTime = null;
      if (_frameCallbackId != null) {
        SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
        _frameCallbackId = null;
      }
    }
    // Only sync recognizers if they are in use already.
    if (_recognizers != null) {
      _syncRecognizers();
    }
  }

  /// Releases any resources held by this span, including active frame callbacks
  /// and [GestureRecognizer]s.
  @mustCallSuper
  void dispose() {
    _disposed = true;
    if (_frameCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
      _frameCallbackId = null;
    }
    _activePointers.clear();
    _states.clear();
    _disposeRecognizers();
  }

  bool get _hasDecorations =>
      _configuration != null &&
      ((_configuration!.backgroundDecoration?.isInteractive ?? false) ||
          (_configuration!.foregroundDecoration?.isInteractive ?? false));

  Duration get _stateAnimationDuration {
    if (_configuration == null) {
      return Duration.zero;
    }
    final Duration bgDuration =
        _configuration!.backgroundDecoration?.animationStyle?.duration ?? Duration.zero;
    final Duration fgDuration =
        _configuration!.foregroundDecoration?.animationStyle?.duration ?? Duration.zero;
    return bgDuration >= fgDuration ? bgDuration : fgDuration;
  }

  Curve get _stateAnimationCurve {
    if (_configuration == null) {
      return Curves.linear;
    }
    return _configuration!.backgroundDecoration?.animationStyle?.curve ??
        _configuration!.foregroundDecoration?.animationStyle?.curve ??
        Curves.linear;
  }

  Duration get _splashAnimationDuration {
    if (_configuration == null) {
      return Duration.zero;
    }
    final SpanDecoration? bg = _configuration!.backgroundDecoration;
    final SpanDecoration? fg = _configuration!.foregroundDecoration;
    final bool hasSplash = bg?.splashColor != null || fg?.splashColor != null;
    if (!hasSplash) {
      return Duration.zero;
    }
    final Duration? styleDuration =
        bg?.splashAnimationStyle?.duration ?? fg?.splashAnimationStyle?.duration;
    return styleDuration ?? SpanDecoration.defaultSplashDuration;
  }

  Curve get _splashAnimationCurve {
    if (_configuration == null) {
      return SpanDecoration.defaultSplashCurve;
    }
    return _configuration!.backgroundDecoration?.splashAnimationStyle?.curve ??
        _configuration!.foregroundDecoration?.splashAnimationStyle?.curve ??
        SpanDecoration.defaultSplashCurve;
  }

  void _ensureFrameScheduled() {
    if (_disposed || _frameCallbackId != null) {
      return;
    }
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_onFrame);
  }

  void _onFrame(Duration timeStamp) {
    _frameCallbackId = null;
    if (_disposed) {
      return;
    }
    var needsMoreFrames = false;

    if (_stateAnimationProgress < 1.0) {
      final Duration duration = _stateAnimationDuration;
      if (duration <= Duration.zero) {
        _stateAnimationProgress = 1.0;
        _stateAnimationRawProgress = 1.0;
        _stateAnimationInitialProgress = 0.0;
        _stateAnimationReversed = false;
        _stateAnimationStartTime = null;
      } else {
        _stateAnimationStartTime ??= timeStamp;
        final Duration elapsed = timeStamp - _stateAnimationStartTime!;
        final double rawProgress =
            (_stateAnimationInitialProgress + (elapsed.inMicroseconds / duration.inMicroseconds))
                .clamp(0.0, 1.0);
        _stateAnimationRawProgress = rawProgress;
        final Curve curve = _stateAnimationReversed
            ? _stateAnimationCurve.flipped
            : _stateAnimationCurve;
        _stateAnimationProgress = curve.transform(rawProgress);
        if (rawProgress < 1.0) {
          needsMoreFrames = true;
        } else {
          _stateAnimationProgress = 1.0;
          _stateAnimationRawProgress = 1.0;
          _stateAnimationInitialProgress = 0.0;
          _stateAnimationReversed = false;
          _stateAnimationStartTime = null;
        }
      }
    }

    if (_splashAnimating) {
      final Duration duration = _splashAnimationDuration;
      if (duration <= Duration.zero) {
        _splashAnimating = false;
        _splashProgress = 0.0;
        _splashAnimationStartTime = null;
      } else {
        _splashAnimationStartTime ??= timeStamp;
        final Duration elapsed = timeStamp - _splashAnimationStartTime!;
        final double rawProgress = (elapsed.inMicroseconds / duration.inMicroseconds).clamp(
          0.0,
          1.0,
        );
        _splashProgress = _splashAnimationCurve.transform(rawProgress);
        if (rawProgress < 1.0) {
          needsMoreFrames = true;
        } else {
          _splashAnimating = false;
          _splashProgress = 0.0;
          _splashAnimationStartTime = null;
        }
      }
    }

    onStateChanged?.call();
    if (needsMoreFrames) {
      _ensureFrameScheduled();
    }
  }

  void _updateState(WidgetState state, bool value) {
    final bool willChange = value ? !_states.contains(state) : _states.contains(state);
    if (!willChange) {
      return;
    }
    if (!_hasDecorations) {
      if (value) {
        _states.add(state);
      } else {
        _states.remove(state);
      }
      return;
    }
    final Set<WidgetState> oldPreviousStates = _previousStates;
    _previousStates = Set<WidgetState>.of(_states);
    if (value) {
      _states.add(state);
    } else {
      _states.remove(state);
    }
    if (_stateAnimationDuration > Duration.zero) {
      if (_stateAnimationProgress < 1.0 && setEquals(_states, oldPreviousStates)) {
        _stateAnimationReversed = !_stateAnimationReversed;
        _stateAnimationRawProgress = 1.0 - _stateAnimationRawProgress;
        _stateAnimationInitialProgress = _stateAnimationRawProgress;
        _stateAnimationProgress = 1.0 - _stateAnimationProgress;
      } else {
        _stateAnimationReversed = false;
        _stateAnimationRawProgress = 0.0;
        _stateAnimationInitialProgress = 0.0;
        _stateAnimationProgress = 0.0;
      }
      _stateAnimationStartTime = null;
      _ensureFrameScheduled();
    } else {
      _stateAnimationReversed = false;
      _stateAnimationRawProgress = 1.0;
      _stateAnimationInitialProgress = 0.0;
      _stateAnimationProgress = 1.0;
    }
    onStateChanged?.call();
  }

  void _syncRecognizers() {
    if (configuration.recognizerFactories.isEmpty) {
      _disposeRecognizers();
      return;
    }
    final newRecognizers = <Type, GestureRecognizer>{};
    for (final Type type in configuration.recognizerFactories.keys) {
      assert(!newRecognizers.containsKey(type));
      newRecognizers[type] =
          _recognizers?.remove(type) ?? configuration.recognizerFactories[type]!.constructor();
      assert(
        newRecognizers[type].runtimeType == type,
        'GestureRecognizerFactory of type $type created a GestureRecognizer of '
        'type ${newRecognizers[type].runtimeType}. The '
        'GestureRecognizerFactory must be specialized with the type of the '
        'class that it returns from its constructor method.',
      );
      configuration.recognizerFactories[type]!.initializer(newRecognizers[type]!);
    }
    _disposeRecognizers(); // only disposes the ones that were not re-used above.
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

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent) {
      _pointerPosition = event.localPosition;
      _activePointers.add(event.pointer);
      _updateState(WidgetState.pressed, true);
      if (_splashAnimationDuration > Duration.zero) {
        _splashAnimating = true;
        _splashProgress = 0.0;
        _splashAnimationStartTime = null;
        _ensureFrameScheduled();
        onStateChanged?.call();
      }
      if (configuration.recognizerFactories.isNotEmpty) {
        if (_recognizers == null) {
          _syncRecognizers();
        }
        assert(_recognizers != null);
        for (final GestureRecognizer recognizer in _recognizers!.values) {
          recognizer.addPointer(event);
        }
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _activePointers.remove(event.pointer);
      if (_activePointers.isEmpty) {
        _updateState(WidgetState.pressed, false);
      }
    }
  }

  void _handleEnter(PointerEnterEvent event) {
    _updateState(WidgetState.hovered, true);
    configuration.onEnter?.call(event);
  }

  void _handleExit(PointerExitEvent event) {
    _updateState(WidgetState.hovered, false);
    configuration.onExit?.call(event);
  }

  @override
  MouseCursor get cursor => configuration.cursor;

  @override
  PointerEnterEventListener? get onEnter =>
      configuration.onEnter != null || _hasDecorations ? _handleEnter : null;

  @override
  PointerExitEventListener? get onExit =>
      configuration.onExit != null || _hasDecorations ? _handleExit : null;

  @override
  bool get validForMouseTracker => true;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('leadingOffset', _leadingOffset));
    properties.add(DoubleProperty('extent', _extent));
    properties.add(DiagnosticsProperty<T>('configuration', _configuration));
    properties.add(IterableProperty<WidgetState>('states', _states));
  }
}
