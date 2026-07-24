// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

const _kMyLocationButtonId = 'my_location_button';
const _kMyLocationBlueDot = 'my_location_blue_dot';

/// This class manages the current location and the my location button.
class MyLocationController {
  /// Creates a [MyLocationController] with the given [GeolocationApi].
  MyLocationController({required GeolocationApi geolocationApi}) : _geolocationApi = geolocationApi;

  final GeolocationApi _geolocationApi;

  /// The my location button
  MyLocationButton? myLocationButton;
  LatLng? _lastKnownLocation;
  int? _watchId;

  gmaps.MapsEventListener? _dragEndListener;
  gmaps.MapsEventListener? _centerChangedListener;

  /// Watch current location and update blue dot
  Future<void> displayAndWatchMyLocation(
    MarkersController<Object?, Object> markersController,
  ) async {
    if (_watchId != null) {
      _geolocationApi.clearWatch(_watchId!);
      _watchId = null;
    }

    final Marker marker = await _createBlueDotMarker();

    if (_lastKnownLocation != null) {
      _setBlueDotMarker(markersController, marker.copyWith(positionParam: _lastKnownLocation));
    }

    _watchId = _geolocationApi.watchPosition((double latitude, double longitude) {
      _lastKnownLocation = LatLng(latitude, longitude);

      // TODO(Zubii12): https://github.com/flutter/plugins/pull/6868#discussion_r1057898052
      // We're discarding a lot of information from coords, like its accuracy, heading and speed. Those can be used to:
      // - Render a bigger "blue halo" around the current position marker when the accuracy is low.
      // - Render the direction in which we're looking at with a small "cone" using the heading information.
      // - Render the current position marker as an arrow when the current position is "moving" (speed > certain threshold), and the direction in which the arrow should point (again, with the heading information).

      final Marker markerUpdate = marker.copyWith(positionParam: _lastKnownLocation);

      _setBlueDotMarker(markersController, markerUpdate);
    }, (dynamic error) => myLocationButton?.doneAnimation());
  }

  void _setBlueDotMarker(MarkersController<Object?, Object> markersController, Marker marker) {
    if (markersController.markers.containsKey(marker.markerId)) {
      markersController.changeMarkers({marker});
    } else {
      markersController.addMarkers(<Marker>{marker});
    }
  }

  /// Get current location
  Future<LatLng?> _getCurrentLocation() async {
    if (_lastKnownLocation != null) {
      return _lastKnownLocation;
    }

    final completer = Completer<LatLng?>();

    _geolocationApi.getCurrentPosition(
      (double latitude, double longitude) {
        if (completer.isCompleted) {
          return;
        }
        final latLng = LatLng(latitude, longitude);
        _lastKnownLocation = latLng;
        completer.complete(latLng);
      },
      (dynamic error) {
        if (completer.isCompleted) {
          return;
        }
        completer.complete(null);
      },
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 31));
    } on TimeoutException {
      return null;
    }
  }

  /// Find and move to current location
  Future<void> centerMyCurrentLocation(GoogleMapController controller) async {
    try {
      myLocationButton?.startAnimation();
      final LatLng? location = await _getCurrentLocation();

      if (location != null) {
        await controller.moveCamera(CameraUpdate.newLatLng(location));
      }
      myLocationButton?.doneAnimation();
    } catch (e) {
      myLocationButton?.disableBtn();
    }
  }

  /// Add my location to map
  void addMyLocationButton(gmaps.Map map, GoogleMapController controller) {
    myLocationButton = MyLocationButton();
    myLocationButton?.addClickListener((_) => centerMyCurrentLocation(controller));
    _dragEndListener = map.addListener(
      'dragend',
      () {
        myLocationButton?.resetAnimation();
      }.toJS,
    );
    _centerChangedListener = map.addListener(
      'center_changed',
      () {
        myLocationButton?.resetAnimation();
      }.toJS,
    );
    if (myLocationButton != null) {
      map.controls[gmaps.ControlPosition.RIGHT_BOTTOM as int].push(myLocationButton!.getButton);
    }
  }

  /// Remove my location button from map
  void removeMyLocationButton(gmaps.Map map) {
    if (myLocationButton != null) {
      map.controls[gmaps.ControlPosition.RIGHT_BOTTOM as int].pop();
      myLocationButton = null;
    }
    _dragEndListener?.remove();
    _dragEndListener = null;
    _centerChangedListener?.remove();
    _centerChangedListener = null;
  }

  /// Remove blue dot from map
  void removeBlueDot(MarkersController<Object?, Object?> markersController) {
    const markerId = MarkerId(_kMyLocationBlueDot);

    if (markersController.markers.containsKey(markerId)) {
      markersController.removeMarkers({markerId});
    }
  }

  /// Create blue dot marker
  Future<Marker> _createBlueDotMarker() async {
    final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(18, 18)),
      'assets/blue-dot.png',
      package: 'google_maps_flutter_web',
    );

    return Marker(markerId: const MarkerId(_kMyLocationBlueDot), icon: icon, zIndex: .5);
  }

  /// Dispose the controller and stop watching the position
  void dispose() {
    if (_watchId == null) {
      return;
    }

    _geolocationApi.clearWatch(_watchId!);
    _watchId = null;
  }
}

/// This class support create my location button & handle animation
class MyLocationButton {
  /// Add css and create my location button
  MyLocationButton() {
    _addCss();
    _createButton();
  }

  late web.HTMLButtonElement _btnChild;
  late web.HTMLDivElement _imageChild;
  late web.HTMLDivElement _controlDiv;

  /// Add animation css
  void _addCss() {
    final styleElement = web.HTMLStyleElement();
    web.document.head?.append(styleElement);
    final web.CSSStyleSheet? sheet = styleElement.sheet;
    var rule = '.waiting { animation: 1000ms infinite step-end blink-position-icon;}';
    sheet?.insertRule(rule);
    rule =
        '@keyframes blink-position-icon {0% {background-position: -24px 0px;} '
        '50% {background-position: 0px 0px;}}';
    sheet?.insertRule(rule);
  }

  /// Add My Location widget to right bottom
  void _createButton() {
    _controlDiv = web.HTMLDivElement();

    _controlDiv.style.marginRight = '10px';

    _btnChild = web.HTMLButtonElement();
    _btnChild.className = 'gm-control-active';
    _btnChild.style.backgroundColor = '#fff';
    _btnChild.style.border = 'none';
    _btnChild.style.outline = 'none';
    _btnChild.style.width = '40px';
    _btnChild.style.height = '40px';
    _btnChild.style.borderRadius = '2px';
    _btnChild.style.boxShadow = '0 1px 4px rgba(0,0,0,0.3)';
    _btnChild.style.cursor = 'pointer';
    _btnChild.style.padding = '8px';
    _controlDiv.append(_btnChild);

    _imageChild = web.HTMLDivElement();
    _imageChild.style.width = '24px';
    _imageChild.style.height = '24px';
    _imageChild.style.backgroundImage =
        'url(assets/packages/google_maps_flutter_web/assets/my_location-sprite-2x.png)';
    _imageChild.style.backgroundSize = '240px 24px';
    _imageChild.style.backgroundPosition = '0px 0px';
    _imageChild.style.backgroundRepeat = 'no-repeat';
    _imageChild.id = _kMyLocationButtonId;
    _btnChild.append(_imageChild);
  }

  /// Get button element
  web.HTMLElement get getButton => _controlDiv;

  /// Add click listener
  void addClickListener(void Function(web.Event)? listener) {
    _btnChild.addEventListener('click', listener?.toJS);
  }

  /// Reset animation
  void resetAnimation() {
    if (_btnChild.disabled) {
      _imageChild.style.backgroundPosition = '-24px 0px';
    } else {
      _imageChild.style.backgroundPosition = '0px 0px';
    }
  }

  /// Start animation
  void startAnimation() {
    if (_btnChild.disabled) {
      return;
    }
    _imageChild.classList.add('waiting');
  }

  /// Done animation
  void doneAnimation() {
    if (_btnChild.disabled) {
      return;
    }
    _imageChild.classList.remove('waiting');
    _imageChild.style.backgroundPosition = '-192px 0px';
  }

  /// Disable button
  void disableBtn() {
    _btnChild.disabled = true;
    _imageChild.classList.remove('waiting');
    _imageChild.style.backgroundPosition = '-24px 0px';
  }

  /// Check button disabled or enabled
  bool isDisabled() => _btnChild.disabled;
}
