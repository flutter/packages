// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// This class manages all the [HeatmapController]s associated to a [GoogleMapController].
class HeatmapsController extends GeometryController {
  /// Initialize the cache
  HeatmapsController()
    : _heatmapIdToController = <HeatmapId, HeatmapController>{};

  // A cache of [HeatmapController]s indexed by their [HeatmapId].
  final Map<HeatmapId, HeatmapController> _heatmapIdToController;

  // A cache of pending [Heatmap]s that are queued while the visualization library is loading.
  final Set<Heatmap> _pendingHeatmaps = <Heatmap>{};

  bool _warningLogged = false;

  /// Returns the cache of [HeatmapController]s. Test only.
  @visibleForTesting
  Map<HeatmapId, HeatmapController> get heatmaps => _heatmapIdToController;

  /// Returns the cache of pending [Heatmap]s. Test only.
  @visibleForTesting
  Set<Heatmap> get pendingHeatmaps => _pendingHeatmaps;

  /// Flushes all pending heatmaps that were bypassed due to the visualization
  /// library not being loaded at the time of creation.
  void flushPendingHeatmaps() {
    if (_pendingHeatmaps.isEmpty) {
      return;
    }
    if (isHeatmapSupported()) {
      final pending = Set<Heatmap>.from(_pendingHeatmaps);
      _pendingHeatmaps.clear();
      pending.forEach(_addHeatmap);
    }
  }

  /// Adds a set of [Heatmap] objects to the cache.
  ///
  /// Wraps each [Heatmap] into its corresponding [HeatmapController].
  void addHeatmaps(Set<Heatmap> heatmapsToAdd) {
    if (heatmapsToAdd.isEmpty) {
      return;
    }
    if (!isHeatmapSupported()) {
      _pendingHeatmaps.addAll(heatmapsToAdd);
      if (!_warningLogged) {
        _warningLogged = true;
        debugPrint(
          'The Heatmap Layer functionality is not supported by the loaded version of the Google Maps JavaScript API. Bypassing heatmap creation.',
        );
      }
      return;
    }
    flushPendingHeatmaps();
    heatmapsToAdd.forEach(_addHeatmap);
  }

  void _addHeatmap(Heatmap heatmap) {
    final visualization.HeatmapLayerOptions heatmapOptions =
        _heatmapOptionsFromHeatmap(heatmap);
    try {
      final gmHeatmap = visualization.HeatmapLayer(heatmapOptions);
      gmHeatmap.map = googleMap;
      final controller = HeatmapController(heatmap: gmHeatmap);
      _heatmapIdToController[heatmap.heatmapId] = controller;
    } catch (e) {
      _pendingHeatmaps.add(heatmap);
      if (!_warningLogged) {
        _warningLogged = true;
        debugPrint(
          'The Heatmap Layer functionality is not supported by the loaded version of the Google Maps JavaScript API. Bypassing heatmap creation.',
        );
      }
    }
  }

  /// Updates a set of [Heatmap] objects with new options.
  void changeHeatmaps(Set<Heatmap> heatmapsToChange) {
    if (heatmapsToChange.isEmpty) {
      return;
    }
    if (!isHeatmapSupported()) {
      for (final heatmap in heatmapsToChange) {
        _pendingHeatmaps.removeWhere(
          (Heatmap h) => h.heatmapId == heatmap.heatmapId,
        );
        _pendingHeatmaps.add(heatmap);
      }
      return;
    }
    flushPendingHeatmaps();
    heatmapsToChange.forEach(_changeHeatmap);
  }

  void _changeHeatmap(Heatmap heatmap) {
    final HeatmapController? heatmapController =
        _heatmapIdToController[heatmap.heatmapId];
    heatmapController?.update(_heatmapOptionsFromHeatmap(heatmap));
  }

  /// Removes a set of [HeatmapId]s from the cache.
  void removeHeatmaps(Set<HeatmapId> heatmapIdsToRemove) {
    if (heatmapIdsToRemove.isEmpty) {
      return;
    }
    _pendingHeatmaps.removeWhere(
      (Heatmap h) => heatmapIdsToRemove.contains(h.heatmapId),
    );
    if (!isHeatmapSupported()) {
      return;
    }
    flushPendingHeatmaps();
    for (final heatmapId in heatmapIdsToRemove) {
      final HeatmapController? heatmapController =
          _heatmapIdToController[heatmapId];
      heatmapController?.remove();
      _heatmapIdToController.remove(heatmapId);
    }
  }
}
