// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../google_maps_flutter_platform_interface.dart';

/// Generic Event coming from the native side of Maps.
///
/// All MapEvents contain the `mapId` that originated the event. This should
/// never be `null`.
///
/// The `<T>` on this event represents the type of the `value` that is
/// contained within the event.
///
/// This class is used as a base class for all the events that might be
/// triggered from a Map, but it is never used directly as an event type.
///
/// Do NOT instantiate new events like `MapEvent<ValueType>(mapId, val)` directly,
/// use a specific class instead:
///
/// Do `class NewEvent extend MapEvent<ValueType>` when creating your own events.
/// See below for examples: `CameraMoveStartedEvent`, `MarkerDragEndEvent`...
/// These events are more semantic and pleasant to use than raw generics. They
/// can be (and in fact, are) filtered by the `instanceof`-operator.
///
/// (See [MethodChannelGoogleMapsFlutter.onCameraMoveStarted], for example)
///
/// If your event needs a `position`, alongside the `value`, do
/// `extends _PositionedMapEvent<ValueType>` instead. This adds a `LatLng position`
/// attribute.
///
/// If your event *only* needs a `position`, do `extend _PositionedMapEvent<void>`
/// do NOT `extend MapEvent<LatLng>`. The former lets consumers of these
/// events to access the `.position` property, rather than the more generic `.value`
/// yielded from the latter.
class MapEvent<T> {
  /// Build a Map Event, that relates a mapId with a given value.
  ///
  /// The `mapId` is the id of the map that triggered the event.
  /// `value` may be `null` in events that don't transport any meaningful data.
  MapEvent(this.mapId, this.value);

  /// The ID of the Map this event is associated to.
  final int mapId;

  /// The value wrapped by this event
  final T value;
}

/// A `MapEvent` associated to a `position`.
class _PositionedMapEvent<T> extends MapEvent<T> {
  /// Build a Positioned MapEvent, that relates a mapId and a position with a value.
  ///
  /// The `mapId` is the id of the map that triggered the event.
  /// `value` may be `null` in events that don't transport any meaningful data.
  _PositionedMapEvent(int mapId, this.position, T value) : super(mapId, value);

  /// The position where this event happened.
  final LatLng position;
}

// The following events are the ones exposed to the end user. They are semantic extensions
// of the two base classes above.
//
// These events are used to create the appropriate [Stream] objects, with information
// coming from the native side.

/// An event fired when the Camera of a [mapId] starts moving.
class CameraMoveStartedEvent extends MapEvent<void> {
  /// Build a CameraMoveStarted Event triggered from the map represented by `mapId`.
  CameraMoveStartedEvent(int mapId) : super(mapId, null);
}

/// An event fired while the Camera of a [mapId] moves.
class CameraMoveEvent extends MapEvent<CameraPosition> {
  /// Build a CameraMove Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [CameraPosition] object with the current position of the Camera.
  CameraMoveEvent(super.mapId, super.position);
}

/// An event fired when the Camera of a [mapId] becomes idle.
class CameraIdleEvent extends MapEvent<void> {
  /// Build a CameraIdle Event triggered from the map represented by `mapId`.
  CameraIdleEvent(int mapId) : super(mapId, null);
}

/// An event fired when a [Marker] is tapped.
class MarkerTapEvent extends MapEvent<MarkerId> {
  /// Build a MarkerTap Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [MarkerId] object that represents the tapped Marker.
  MarkerTapEvent(super.mapId, super.markerId);
}

/// An event fired when an [InfoWindow] is tapped.
class InfoWindowTapEvent extends MapEvent<MarkerId> {
  /// Build an InfoWindowTap Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [MarkerId] object that represents the tapped InfoWindow.
  InfoWindowTapEvent(super.mapId, super.markerId);
}

/// An event fired when a [Marker] is starting to be dragged to a new [LatLng].
class MarkerDragStartEvent extends _PositionedMapEvent<MarkerId> {
  /// Build a MarkerDragStart Event triggered from the map represented by `mapId`.
  ///
  /// The `position` on this event is the [LatLng] on which the Marker was picked up from.
  /// The `value` of this event is a [MarkerId] object that represents the Marker.
  MarkerDragStartEvent(super.mapId, super.position, super.markerId);
}

/// An event fired when a [Marker] is being dragged to a new [LatLng].
class MarkerDragEvent extends _PositionedMapEvent<MarkerId> {
  /// Build a MarkerDrag Event triggered from the map represented by `mapId`.
  ///
  /// The `position` on this event is the [LatLng] on which the Marker was dragged to.
  /// The `value` of this event is a [MarkerId] object that represents the Marker.
  MarkerDragEvent(super.mapId, super.position, super.markerId);
}

/// An event fired when a [Marker] is dragged to a new [LatLng].
class MarkerDragEndEvent extends _PositionedMapEvent<MarkerId> {
  /// Build a MarkerDragEnd Event triggered from the map represented by `mapId`.
  ///
  /// The `position` on this event is the [LatLng] on which the Marker was dropped.
  /// The `value` of this event is a [MarkerId] object that represents the moved Marker.
  MarkerDragEndEvent(super.mapId, super.position, super.markerId);
}

/// An event fired when a [Polyline] is tapped.
class PolylineTapEvent extends MapEvent<PolylineId> {
  /// Build an PolylineTap Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [PolylineId] object that represents the tapped Polyline.
  PolylineTapEvent(super.mapId, super.polylineId);
}

/// An event fired when a [Polygon] is tapped.
class PolygonTapEvent extends MapEvent<PolygonId> {
  /// Build an PolygonTap Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [PolygonId] object that represents the tapped Polygon.
  PolygonTapEvent(super.mapId, super.polygonId);
}

/// An event fired when a [Circle] is tapped.
class CircleTapEvent extends MapEvent<CircleId> {
  /// Build an CircleTap Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [CircleId] object that represents the tapped Circle.
  CircleTapEvent(super.mapId, super.circleId);
}

/// An event fired when a Map is tapped.
class MapTapEvent extends _PositionedMapEvent<void> {
  /// Build an MapTap Event triggered from the map represented by `mapId`.
  ///
  /// The `position` of this event is the LatLng where the Map was tapped.
  MapTapEvent(int mapId, LatLng position) : super(mapId, position, null);
}

/// An event fired when a Map is long pressed.
class MapLongPressEvent extends _PositionedMapEvent<void> {
  /// Build an MapTap Event triggered from the map represented by `mapId`.
  ///
  /// The `position` of this event is the LatLng where the Map was long pressed.
  MapLongPressEvent(int mapId, LatLng position) : super(mapId, position, null);
}

/// An event fired when a cluster icon managed by [ClusterManager] is tapped.
class ClusterTapEvent extends MapEvent<Cluster> {
  /// Build a ClusterTapEvent Event triggered from the map represented by `mapId`.
  ///
  /// The `value` of this event is a [Cluster] object that represents the tapped
  /// cluster icon managed by [ClusterManager].
  ClusterTapEvent(super.mapId, super.cluster);
}
