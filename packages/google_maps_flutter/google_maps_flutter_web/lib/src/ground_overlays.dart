// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// This class manages all the [GroundOverlayController]s associated to a [GoogleMapController].
class GroundOverlaysController extends GeometryController {
  /// Creates a new [GroundOverlaysController] instance.
  ///
  /// The [stream] parameter is a required [StreamController] used for
  /// emitting ground overlay tap events.
  GroundOverlaysController({
    required StreamController<MapEvent<Object?>> stream,
  })  : _streamController = stream,
        _groundOverlayIdToController =
            <GroundOverlayId, GroundOverlayController>{};

  final Map<GroundOverlayId, GroundOverlayController>
      _groundOverlayIdToController;

  // The stream over which ground overlays broadcast their events
  final StreamController<MapEvent<Object?>> _streamController;

  /// Adds new [GroundOverlay]s to this controller.
  ///
  /// Wraps the [GroundOverlay]s in corresponding [GroundOverlayController]s.
  void addGroundOverlays(Set<GroundOverlay> groundOverlaysToAdd) {
    groundOverlaysToAdd.forEach(_addGroundOverlay);
  }

  void _addGroundOverlay(GroundOverlay groundOverlay) {
    assert(groundOverlay.bounds != null,
        'On Web platform, bounds must be provided for GroundOverlay');

    final gmaps.LatLngBounds bounds =
        latLngBoundsToGmlatLngBounds(groundOverlay.bounds!);

    final gmaps.GroundOverlayOptions groundOverlayOptions =
        gmaps.GroundOverlayOptions()
          ..opacity = 1.0 - groundOverlay.transparency
          ..clickable = groundOverlay.clickable
          ..map = groundOverlay.visible ? googleMap : null;

    final gmaps.GroundOverlay overlay = gmaps.GroundOverlay(
        urlFromMapBitmap(groundOverlay.image), bounds, groundOverlayOptions);

    final GroundOverlayController controller = GroundOverlayController(
      groundOverlay: overlay,
      onTap: () {
        _onGroundOverlayTap(groundOverlay.groundOverlayId);
      },
    );

    _groundOverlayIdToController[groundOverlay.groundOverlayId] = controller;
  }

  /// Updates [GroundOverlay]s with new options.
  void changeGroundOverlays(Set<GroundOverlay> groundOverlays) {
    groundOverlays.forEach(_changeGroundOverlay);
  }

  void _changeGroundOverlay(GroundOverlay groundOverlay) {
    final GroundOverlayController? controller =
        _groundOverlayIdToController[groundOverlay.groundOverlayId];

    if (controller == null || controller.groundOverlay == null) {
      return;
    }

    assert(groundOverlay.bounds != null,
        'On Web platform, bounds must be provided for GroundOverlay');

    controller.groundOverlay!.set('clickable', groundOverlay.clickable.toJS);
    controller.groundOverlay!.map = groundOverlay.visible ? googleMap : null;
    controller.groundOverlay!.opacity = 1.0 - groundOverlay.transparency;
  }

  /// Removes the ground overlays associated with the given [GroundOverlayId]s.
  void removeGroundOverlays(Set<GroundOverlayId> groundOverlayIds) {
    groundOverlayIds.forEach(_removeGroundOverlay);
  }

  void _removeGroundOverlay(GroundOverlayId groundOverlayId) {
    final GroundOverlayController? controller =
        _groundOverlayIdToController.remove(groundOverlayId);
    if (controller != null) {
      controller.remove();
    }
  }

  void _onGroundOverlayTap(GroundOverlayId groundOverlayId) {
    _streamController.add(GroundOverlayTapEvent(mapId, groundOverlayId));
  }

  /// Returns the [GroundOverlay] with the given [GroundOverlayId].
  /// Only used for testing.
  gmaps.GroundOverlay? getGroundOverlay(GroundOverlayId groundOverlayId) {
    final GroundOverlayController? controller =
        _groundOverlayIdToController.remove(groundOverlayId);
    return controller?.groundOverlay;
  }
}
