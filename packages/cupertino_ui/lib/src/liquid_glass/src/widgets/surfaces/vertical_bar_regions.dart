// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/surfaces/glass_vertical_bar.dart'
    show GlassVerticalBarEdge;

/// The parts of the view UIKit reserves for system elements, as
/// [DisplayFeature]s in logical pixels: on iPhone Duo, the status cluster and
/// the camera as [DisplayFeatureType.cutout]s, and the fold of a half-folded
/// display as a [DisplayFeatureType.hinge].
///
/// UIKit reports them as the view's reserved regions: occlusion regions,
/// `UIView.reservedRegions(kind: .occlusion)`, which move — the status
/// cluster grows with live activities and goes with the status bar — and the
/// division region, `.division`, while the display is half folded. Android
/// cutouts reach [MediaQueryData.displayFeatures], but Flutter sends none on
/// iOS yet (flutter/flutter#193025), so the package's iOS plugin reads the
/// regions and this publishes them in the same shape. Once Flutter reports
/// them, [MediaQueryData.displayFeatures] carries the same rects and this can
/// go without the strip moving.
class VerticalBarRegions extends ValueNotifier<List<DisplayFeature>> {
  VerticalBarRegions._() : super(const <DisplayFeature>[]);

  /// The regions of the app's view.
  static final VerticalBarRegions instance = VerticalBarRegions._();

  static const MethodChannel _channel =
      MethodChannel('liquid_glass_widgets/reserved_regions');

  bool _observing = false;

  /// The side UIKit wants the strip on (`UITraitCollection.verticalBarEdge`),
  /// or null where it places none.
  ///
  /// Where the system insets the view for the strip, the insets already say
  /// where it is. Where it leaves the strip's space to the app, as for the
  /// left-hand app in Split View, this is all the app is told.
  final ValueNotifier<GlassVerticalBarEdge?> edge =
      ValueNotifier<GlassVerticalBarEdge?>(null);

  /// Starts following the regions, if it has not already.
  ///
  /// Leaves them empty where the plugin is not registered: in a widget test,
  /// or in an app that embeds Flutter without registering its plugins.
  void observe() {
    if (_observing) return;
    _observing = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'didChange':
          value = _decode(call.arguments);
        case 'didChangeVerticalBarEdge':
          edge.value = _decodeEdge(call.arguments);
      }
    });
    unawaited(_observe());
  }

  Future<void> _observe() async {
    try {
      value = _decode(await _channel.invokeListMethod<Object?>('observe'));
      edge.value =
          _decodeEdge(await _channel.invokeMethod<Object?>('verticalBarEdge'));
    } on MissingPluginException {
      // Not registered; the strip keeps to its measured geometry.
    }
  }

  /// Stops following the regions and forgets them, between tests.
  @visibleForTesting
  void debugReset() {
    _channel.setMethodCallHandler(null);
    _observing = false;
    value = const <DisplayFeature>[];
    edge.value = null;
  }

  static GlassVerticalBarEdge? _decodeEdge(Object? edge) => switch (edge) {
        'leading' => GlassVerticalBarEdge.leading,
        'trailing' => GlassVerticalBarEdge.trailing,
        _ => null,
      };

  static List<DisplayFeature> _decode(Object? regions) => [
        for (final region in (regions as List<Object?>? ?? const []))
          DisplayFeature(
            bounds: Rect.fromLTRB(
              ((region as List<Object?>)[0]! as num).toDouble(),
              (region[1]! as num).toDouble(),
              (region[2]! as num).toDouble(),
              (region[3]! as num).toDouble(),
            ),
            // The division is only reported while the display is half folded.
            type: region.length > 4 && region[4] == 1
                ? DisplayFeatureType.hinge
                : DisplayFeatureType.cutout,
            state: region.length > 4 && region[4] == 1
                ? DisplayFeatureState.postureHalfOpened
                : DisplayFeatureState.unknown,
          ),
      ];
}
