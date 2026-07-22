// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// A pure-Dart interface that Mockito can easily mock.
abstract class GeolocationApi {
  /// Watches the current position and calls [onSuccess] with the coordinates whenever they change.
  ///
  /// [onError] is called if there is an error while watching the position.
  int watchPosition(
    void Function(double latitude, double longitude) onSuccess,
    void Function(dynamic error) onError,
  );

  /// Fetches the current position and calls [onSuccess] with the coordinates.
  ///
  /// [onError] is called if there is an error while fetching the position.
  ///
  /// [timeoutMs] specifies the maximum time in milliseconds
  void getCurrentPosition(
    void Function(double latitude, double longitude) onSuccess,
    void Function(dynamic error) onError, {
    int timeoutMs = 30000,
  });

  /// Stops watching the position for the given [watchId].
  void clearWatch(int watchId);
}

/// The real implementation that uses package:web.
class WebGeolocationApi implements GeolocationApi {
  final web.Geolocation _geolocation = web.window.navigator.geolocation;

  @override
  int watchPosition(
    void Function(double latitude, double longitude) onSuccess,
    void Function(dynamic error) onError,
  ) {
    return _geolocation.watchPosition(
      (web.GeolocationPosition location) {
        onSuccess(location.coords.latitude, location.coords.longitude);
      }.toJS,
      (web.GeolocationPositionError error) {
        onError(error);
      }.toJS,
      web.PositionOptions(),
    );
  }

  @override
  void getCurrentPosition(
    void Function(double latitude, double longitude) onSuccess,
    void Function(dynamic error) onError, {
    int timeoutMs = 30000,
  }) {
    _geolocation.getCurrentPosition(
      (web.GeolocationPosition location) {
        onSuccess(location.coords.latitude, location.coords.longitude);
      }.toJS,
      (web.GeolocationPositionError error) {
        onError(error);
      }.toJS,
      web.PositionOptions(timeout: timeoutMs),
    );
  }

  @override
  void clearWatch(int watchId) => _geolocation.clearWatch(watchId);
}
