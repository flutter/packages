# google_maps_flutter_web

The web implementation of [google_maps_flutter](https://pub.dev/packages/google_maps_flutter).

Powered by [a14n](https://github.com/a14n)'s [google_maps](https://pub.dev/packages/google_maps) Dart JS interop layer.

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `google_maps_flutter` normally. This package will
be automatically included in your app when you do, so you do not need to add it
to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

### Modify web/index.html

Get an API Key for Google Maps JavaScript API. Get started [here](https://developers.google.com/maps/documentation/javascript/get-api-key).

Modify the `<head>` tag of your `web/index.html` to load the Google Maps JavaScript API, like so:

```html
<head>

  <!-- // Other stuff -->

  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
</head>
```

The Google Maps Web SDK splits some of its functionality in [separate libraries](https://developers.google.com/maps/documentation/javascript/libraries#libraries-for-dynamic-library-import).

If your app needs the `drawing` library (to draw polygons, rectangles, polylines,
circles or markers on a map), include it like this:

```html
<script
  src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=drawing">
</script>
```

To request multiple libraries, separate them with commas:

```html
<script
  src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=drawing,visualization,places">
</script>
```

Now you should be able to use the Google Maps plugin normally.

## Limitations of the web version

The following map options are not available in web, because the map doesn't rotate there:

* `compassEnabled`
* `rotateGesturesEnabled`
* `tiltGesturesEnabled`

There's no "Map Toolbar" in web, so the `mapToolbarEnabled` option is unused.

There's no `defaultMarkerWithHue` in web. If you need colored pins/markers, you may need to use your own asset images.

Indoor and building layers are still not available on the web. Traffic is.

Only Android supports "[Lite Mode](https://developers.google.com/maps/documentation/android-sdk/lite)", so the `liteModeEnabled` constructor argument can't be set to `true` on web apps.

Google Maps for web uses `HtmlElementView` to render maps. When a `GoogleMap` is stacked below other widgets, [`package:pointer_interceptor`](https://www.pub.dev/packages/pointer_interceptor) must be used to capture mouse events on the Flutter overlays. See issue [#73830](https://github.com/flutter/flutter/issues/73830).
