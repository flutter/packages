// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

const _kMyLocationButtonId = 'my_location_button';

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
  gmaps.Marker? _blueDot;

  /// Watch current location and update blue dot
  void displayAndWatchMyLocation(gmaps.Map map) {
    if (_watchId != null) {
      return;
    }

    _watchId = _geolocationApi.watchPosition((double latitude, double longitude) {
      _lastKnownLocation = LatLng(latitude, longitude);

      // TODO(Zubii12): https://github.com/flutter/plugins/pull/6868#discussion_r1057898052
      // We're discarding a lot of information from coords, like its accuracy, heading and speed. Those can be used to:
      // - Render a bigger "blue halo" around the current position marker when the accuracy is low.
      // - Render the direction in which we're looking at with a small "cone" using the heading information.
      // - Render the current position marker as an arrow when the current position is "moving" (speed > certain threshold), and the direction in which the arrow should point (again, with the heading information).

      if (_lastKnownLocation != null) {
        _updateBlueDot(map, _lastKnownLocation!);
      }
    }, (dynamic error) => myLocationButton?.doneAnimation());
  }

  void _updateBlueDot(gmaps.Map map, LatLng position) {
    final gmaps.LatLng gmPosition = _latLngToGmLatLng(position);
    final gmaps.Marker? blueDot = _blueDot;
    if (blueDot != null) {
      blueDot.position = gmPosition;
      return;
    }
    _blueDot = gmaps.Marker(
      gmaps.MarkerOptions()
        ..map = map
        ..position = gmPosition
        ..clickable = false
        ..icon = (gmaps.Icon()
          ..url = ui_web.assetManager.getAssetUrl(
            'packages/google_maps_flutter_web/assets/blue-dot.png',
          )
          ..scaledSize = gmaps.Size(18, 18)
          ..anchor = gmaps.Point(9, 9)),
    );
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
    if (!_geolocationApi.isAvailable) {
      return;
    }

    myLocationButton = MyLocationButton();
    myLocationButton?.addClickListener((_) => centerMyCurrentLocation(controller));
    _dragEndListener = map.addListener(
      'dragend',
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
  }

  /// Remove blue dot from map
  void removeBlueDot() {
    _blueDot?.map = null;
    _blueDot = null;
  }

  /// Stop watching current location
  void stopWatchingMyLocation() {
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

  static bool _cssAdded = false;

  /// Add animation css
  void _addCss() {
    if (_cssAdded) {
      return;
    }
    _cssAdded = true;
    final styleElement = web.HTMLStyleElement();
    web.document.head?.append(styleElement);
    final web.CSSStyleSheet? sheet = styleElement.sheet;
    var rule =
        '.gmf-my-location-waiting { animation: 1000ms infinite step-end blink-position-icon;}';
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
    _btnChild.title = 'Your Location';
    _btnChild.setAttribute('aria-label', 'Your Location');
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
        'url(${ui_web.assetManager.getAssetUrl('packages/google_maps_flutter_web/assets/my_location-sprite-2x.png')})';
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
    _imageChild.classList.add('gmf-my-location-waiting');
  }

  /// Done animation
  void doneAnimation() {
    if (_btnChild.disabled) {
      return;
    }
    _imageChild.classList.remove('gmf-my-location-waiting');
    _imageChild.style.backgroundPosition = '-192px 0px';
  }

  /// Disable button
  void disableBtn() {
    _btnChild.disabled = true;
    _imageChild.classList.remove('gmf-my-location-waiting');
    _imageChild.style.backgroundPosition = '-24px 0px';
  }

  /// Check button disabled or enabled
  bool isDisabled() => _btnChild.disabled;
}
