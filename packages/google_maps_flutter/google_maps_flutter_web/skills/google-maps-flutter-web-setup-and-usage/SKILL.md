---
name: google-maps-flutter-web-setup-and-usage
description: Set up and configure google_maps_flutter_web, the web implementation of google_maps_flutter using the Google Maps JavaScript API.
---

# Setting Up and Using google_maps_flutter_web

`google_maps_flutter_web` is the endorsed Web platform implementation of the [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) plugin, powered by the Google Maps JavaScript API.

## 1. Installation

Because `google_maps_flutter_web` is endorsed, adding `google_maps_flutter` to your `pubspec.yaml` automatically includes it when building for Web:

```yaml
dependencies:
  google_maps_flutter: ^2.18.1
```

If you need to depend on `google_maps_flutter_web` directly, add it to your `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.18.1
  google_maps_flutter_web: ^0.6.3+1
```

## 2. Platform-Specific Configuration (`web/index.html`)

1. Obtain an API key with the **Maps JavaScript API** enabled from the [Google Cloud Console](https://developers.google.com/maps/documentation/javascript/get-api-key).
2. Load the Google Maps JavaScript API in the `<head>` section of your `web/index.html` file. Include any required libraries (`drawing` for polygons/polylines/circles, `marker` for Advanced Markers):

```html
<!DOCTYPE html>
<html>
<head>
  <!-- Other head elements -->

  <!-- Load Google Maps JavaScript API with drawing and marker libraries -->
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=drawing,marker"></script>

  <!-- Optional: Include MarkerClusterer 2.5.3 if using marker clustering -->
  <script src="https://cdn.jsdelivr.net/npm/@googlemaps/markerclusterer@2.5.3/dist/index.umd.min.js"></script>
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

## 3. Usage, Web Limitations, and Pointer Interception

### Standard Usage

Use the `GoogleMap` widget from `package:google_maps_flutter/google_maps_flutter.dart` as normal:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WebMapScreen extends StatelessWidget {
  const WebMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapId: 'YOUR_MAP_ID',
        markerType: GoogleMapMarkerType.advancedMarker,
        initialCameraPosition: const CameraPosition(
          target: LatLng(51.5074, -0.1278),
          zoom: 13,
        ),
        markers: <Marker>{
          const Marker(
            markerId: MarkerId('london'),
            position: LatLng(51.5074, -0.1278),
            infoWindow: InfoWindow(title: 'London'),
          ),
        },
      ),
    );
  }
}
```

### Handling Flutter Overlays (`pointer_interceptor`)

On the Web, `GoogleMap` renders using an `HtmlElementView` (`<iframe>`/DOM element). If you stack Flutter widgets (such as floating action buttons, search bars, or custom dialogs) on top of the map, mouse clicks and touch events may be swallowed by the underlying map DOM element.

Wrap any interactive Flutter widget stacked over a `GoogleMap` with [`PointerInterceptor`](https://pub.dev/packages/pointer_interceptor):

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MapWithOverlayButton extends StatelessWidget {
  const MapWithOverlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(37.7749, -122.4194),
            zoom: 12,
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: PointerInterceptor(
            child: ElevatedButton(
              onPressed: () {
                // Clicks are safely intercepted by Flutter instead of panning the map.
              },
              child: const Text('Overlay Action'),
            ),
          ),
        ),
      ],
    );
  }
}
```

### Notable Web Limitations
- Rotation and tilt options (`compassEnabled`, `rotateGesturesEnabled`, `tiltGesturesEnabled`) are not supported because the 2D web map view does not rotate.
- `myLocationEnabled`, `myLocationButtonEnabled`, and `liteModeEnabled` are ignored on web.
