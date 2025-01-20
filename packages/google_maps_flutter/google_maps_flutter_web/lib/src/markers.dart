// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// This class manages a set of [MarkerController]s associated to a [GoogleMapController].
///
/// * [LegacyMarkersController] implements the [MarkersController] for the
/// legacy [gmaps.Marker] class.
/// * [AdvancedMarkersController] implements the [MarkersController] for the
/// advanced [gmaps.AdvancedMarkerElement] class.
abstract class MarkersController<T extends JSObject, O>
    extends GeometryController {
  /// Initialize the cache. The [StreamController] comes from the [GoogleMapController], and is shared with other controllers.
  MarkersController({
    required StreamController<MapEvent<Object?>> stream,
    required ClusterManagersController<T> clusterManagersController,
  })  : _streamController = stream,
        _clusterManagersController = clusterManagersController,
        _markerIdToController = <MarkerId, MarkerController<T, O>>{};

  // A cache of [MarkerController]s indexed by their [MarkerId].
  final Map<MarkerId, MarkerController<T, O>> _markerIdToController;

  // The stream over which markers broadcast their events
  final StreamController<MapEvent<Object?>> _streamController;

  final ClusterManagersController<T> _clusterManagersController;

  /// Returns the cache of [MarkerController]s. Test only.
  @visibleForTesting
  Map<MarkerId, MarkerController<T, O>> get markers => _markerIdToController;

  /// Adds a set of [Marker] objects to the cache.
  ///
  /// Wraps each [Marker] into its corresponding [MarkerController].
  Future<void> addMarkers(Set<Marker> markersToAdd) async {
    await Future.wait(markersToAdd.map(_addMarker));
  }

  Future<void> _addMarker(Marker marker) async {
    final gmaps.InfoWindowOptions? infoWindowOptions =
        _infoWindowOptionsFromMarker(marker);
    gmaps.InfoWindow? gmInfoWindow;

    if (infoWindowOptions != null) {
      gmInfoWindow = gmaps.InfoWindow(infoWindowOptions);
      // Google Maps' JS SDK does not have a click event on the InfoWindow, so
      // we make one...
      if (infoWindowOptions.content != null &&
          infoWindowOptions.content is HTMLElement) {
        final HTMLElement content = infoWindowOptions.content! as HTMLElement;

        content.onclick = (JSAny? _) {
          _onInfoWindowTap(marker.markerId);
        }.toJS;
      }
    }

    final MarkerController<T, O>? markerController =
        _markerIdToController[marker.markerId];
    final T? currentMarker = markerController?.marker;
    final MarkerController<T, O> controller =
        await createMarkerController(marker, currentMarker, gmInfoWindow);
    _markerIdToController[marker.markerId] = controller;
  }

  /// Creates a [MarkerController] for a [Marker] object.
  Future<MarkerController<T, O>> createMarkerController(
    Marker marker,
    T? currentMarker,
    gmaps.InfoWindow? gmInfoWindow,
  );

  /// Updates a set of [Marker] objects with new options.
  Future<void> changeMarkers(Set<Marker> markersToChange) async {
    await Future.wait(markersToChange.map(_changeMarker));
  }

  Future<void> _changeMarker(Marker marker) async {
    final MarkerController<T, O>? markerController =
        _markerIdToController[marker.markerId];
    if (markerController != null) {
      final ClusterManagerId? oldClusterManagerId =
          markerController.clusterManagerId;
      final ClusterManagerId? newClusterManagerId = marker.clusterManagerId;

      if (oldClusterManagerId != newClusterManagerId) {
        // If clusterManagerId changes. Remove existing marker and create new one.
        _removeMarker(marker.markerId);
        await _addMarker(marker);
      } else {
        final O markerOptions = await _markerOptionsFromMarker(
          marker,
          markerController.marker,
        );
        final gmaps.InfoWindowOptions? infoWindow =
            _infoWindowOptionsFromMarker(marker);
        markerController.update(
          markerOptions,
          newInfoWindowContent: infoWindow?.content as HTMLElement?,
        );
      }
    }
  }

  /// Removes a set of [MarkerId]s from the cache.
  void removeMarkers(Set<MarkerId> markerIdsToRemove) {
    markerIdsToRemove.forEach(_removeMarker);
  }

  void _removeMarker(MarkerId markerId) {
    final MarkerController<T, O>? markerController =
        _markerIdToController[markerId];
    if (markerController?.clusterManagerId != null) {
      _clusterManagersController.removeItem(
          markerController!.clusterManagerId!, markerController.marker);
    }
    markerController?.remove();
    _markerIdToController.remove(markerId);
  }

  // InfoWindow...

  /// Shows the [InfoWindow] of a [MarkerId].
  ///
  /// See also [hideMarkerInfoWindow] and [isInfoWindowShown].
  void showMarkerInfoWindow(MarkerId markerId) {
    _hideAllMarkerInfoWindow();
    final MarkerController<T, O>? markerController =
        _markerIdToController[markerId];
    markerController?.showInfoWindow();
  }

  /// Hides the [InfoWindow] of a [MarkerId].
  ///
  /// See also [showMarkerInfoWindow] and [isInfoWindowShown].
  void hideMarkerInfoWindow(MarkerId markerId) {
    final MarkerController<T, O>? markerController =
        _markerIdToController[markerId];
    markerController?.hideInfoWindow();
  }

  /// Returns whether or not the [InfoWindow] of a [MarkerId] is shown.
  ///
  /// See also [showMarkerInfoWindow] and [hideMarkerInfoWindow].
  bool isInfoWindowShown(MarkerId markerId) {
    final MarkerController<T, O>? markerController =
        _markerIdToController[markerId];
    return markerController?.infoWindowShown ?? false;
  }

  // Handle internal events

  bool _onMarkerTap(MarkerId markerId) {
    // Have you ended here on your debugging? Is this wrong?
    // Comment here: https://github.com/flutter/flutter/issues/64084
    _streamController.add(MarkerTapEvent(mapId, markerId));
    return _markerIdToController[markerId]?.consumeTapEvents ?? false;
  }

  void _onInfoWindowTap(MarkerId markerId) {
    _streamController.add(InfoWindowTapEvent(mapId, markerId));
  }

  void _onMarkerDragStart(MarkerId markerId, gmaps.LatLng latLng) {
    _streamController.add(MarkerDragStartEvent(
      mapId,
      gmLatLngToLatLng(latLng),
      markerId,
    ));
  }

  void _onMarkerDrag(MarkerId markerId, gmaps.LatLng latLng) {
    _streamController.add(MarkerDragEvent(
      mapId,
      gmLatLngToLatLng(latLng),
      markerId,
    ));
  }

  void _onMarkerDragEnd(MarkerId markerId, gmaps.LatLng latLng) {
    _streamController.add(MarkerDragEndEvent(
      mapId,
      gmLatLngToLatLng(latLng),
      markerId,
    ));
  }

  void _hideAllMarkerInfoWindow() {
    _markerIdToController.values
        .where((MarkerController<T, O>? controller) =>
            controller?.infoWindowShown ?? false)
        .forEach((MarkerController<T, O> controller) {
      controller.hideInfoWindow();
    });
  }
}

/// A [MarkersController] for the legacy [gmaps.Marker] class.
class LegacyMarkersController
    extends MarkersController<gmaps.Marker, gmaps.MarkerOptions> {
  /// Initialize the markers controller for the legacy [gmaps.Marker] class.
  LegacyMarkersController({
    required super.stream,
    required super.clusterManagersController,
  });

  @override
  Future<LegacyMarkerController> createMarkerController(
    Marker marker,
    gmaps.Marker? currentMarker,
    gmaps.InfoWindow? gmInfoWindow,
  ) async {
    final gmaps.MarkerOptions markerOptions =
        await _markerOptionsFromMarker<gmaps.Marker, gmaps.MarkerOptions>(
            marker, currentMarker);

    final gmaps.Marker gmMarker = gmaps.Marker(markerOptions);
    gmMarker.set('markerId', marker.markerId.value.toJS);

    if (marker.clusterManagerId != null) {
      _clusterManagersController.addItem(marker.clusterManagerId!, gmMarker);
    } else {
      gmMarker.map = googleMap;
    }

    return LegacyMarkerController(
      marker: gmMarker,
      clusterManagerId: marker.clusterManagerId,
      infoWindow: gmInfoWindow,
      consumeTapEvents: marker.consumeTapEvents,
      onTap: () {
        showMarkerInfoWindow(marker.markerId);
        _onMarkerTap(marker.markerId);
      },
      onDragStart: (gmaps.LatLng latLng) {
        _onMarkerDragStart(marker.markerId, latLng);
      },
      onDrag: (gmaps.LatLng latLng) {
        _onMarkerDrag(marker.markerId, latLng);
      },
      onDragEnd: (gmaps.LatLng latLng) {
        _onMarkerDragEnd(marker.markerId, latLng);
      },
    );
  }
}

/// A [MarkersController] for the advanced [gmaps.AdvancedMarkerElement] class.
class AdvancedMarkersController extends MarkersController<
    gmaps.AdvancedMarkerElement, gmaps.AdvancedMarkerElementOptions> {
  /// Initialize the markers controller for advanced markers
  /// ([gmaps.AdvancedMarkerElement]).
  AdvancedMarkersController({
    required super.stream,
    required super.clusterManagersController,
  });

  @override
  Future<AdvancedMarkerController> createMarkerController(
    Marker marker,
    gmaps.AdvancedMarkerElement? currentMarker,
    gmaps.InfoWindow? gmInfoWindow,
  ) async {
    assert(marker is AdvancedMarker, 'Marker must be an AdvancedMarker.');

    final gmaps.AdvancedMarkerElementOptions markerOptions =
        await _markerOptionsFromMarker(marker, currentMarker);
    final gmaps.AdvancedMarkerElement gmMarker =
        gmaps.AdvancedMarkerElement(markerOptions);
    gmMarker.setAttribute('id', marker.markerId.value);

    if (marker.clusterManagerId != null) {
      _clusterManagersController.addItem(marker.clusterManagerId!, gmMarker);
    } else {
      gmMarker.map = googleMap;
    }

    return AdvancedMarkerController(
      marker: gmMarker,
      clusterManagerId: marker.clusterManagerId,
      infoWindow: gmInfoWindow,
      consumeTapEvents: marker.consumeTapEvents,
      onTap: () {
        showMarkerInfoWindow(marker.markerId);
        _onMarkerTap(marker.markerId);
      },
      onDragStart: (gmaps.LatLng latLng) {
        _onMarkerDragStart(marker.markerId, latLng);
      },
      onDrag: (gmaps.LatLng latLng) {
        _onMarkerDrag(marker.markerId, latLng);
      },
      onDragEnd: (gmaps.LatLng latLng) {
        _onMarkerDragEnd(marker.markerId, latLng);
      },
    );
  }
}
