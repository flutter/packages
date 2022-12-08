# Google Maps Routes API for Dart

<?code-excerpt path-base="excerpts/packages/google_maps_routes_api_example"?>

A Dart package for making API requests to the [Google Routes API](https://developers.google.com/maps/documentation/routes).

With this package, you can easily get routes, estimated travel times, distance between locations and much more in your Dart or Flutter application.

## Features

- Compute routes using Google Routes API [computeRoutes](https://developers.google.com/maps/documentation/routes/compute_route_directions) endpoint.

- Compute route matrixes using Google Routes API [computeRouteMatrixes](https://developers.google.com/maps/documentation/routes/compute_route_matrix) endpoint.

## Getting started

* Get an API key at https://cloud.google.com/maps-platform/.

* Enable [Google Routes API](https://console.cloud.google.com/marketplace/product/google/routes.googleapis.com?q=search&referrer=search&project=need-277508) for your project.


To use this package, add google_maps_routes_api as a dependency in your pubspec.yaml file.

Next, create an instance of the RoutesService class, providing your API key as a parameter:

`final RoutesService routesService = RoutesService(apiKey: "YOUR_GOOGLE_API_KEY_HERE");`

You can then use the routesService object to make requests to the Google Routes API.

## Sample usage

<?code-excerpt "readme_excerpts.dart (SampleUsage)"?>
```dart

import 'package:google_maps_routes_api/routes_service.dart';

final RoutesService routesService = RoutesService(apiKey: 'GOOGLE_API_KEY');

const Waypoint origin = Waypoint(
  location: Location(
    latLng: LatLng(37.419734, -122.0827784),
  ),
);
const Waypoint destination = Waypoint(
  location: Location(
    latLng: LatLng(37.417670, -122.079595),
  ),
);

final ComputeRoutesRequest body = ComputeRoutesRequest(
  origin: origin,
  destination: destination,
);
// ···

  final ComputeRoutesResponse response = await routesService.computeRoute(body);
```


You can specify the [field mask](https://developers.google.com/maps/documentation/routes/choose_fields) for your request by giving a `fields` parameter or by using the `X-Goog-FieldMask` header:

<?code-excerpt "readme_excerpts.dart (CustomFieldmask)"?>
```dart

const String fields =
    'status,originIndex,destinationIndex,condition,distanceMeters,duration';

final ComputeRoutesResponse response =
    await routesService.computeRoute(body, fields: fields);
```

You can override and add [headers](https://cloud.google.com/apis/docs/system-parameters) to your request:

<?code-excerpt "readme_excerpts.dart (CustomHeaders)"?>
```dart

final Map<String, String> headers = <String, String>{
  'X-Goog-Fieldmask':
      'status,originIndex,destinationIndex,condition,distanceMeters,duration'
};

final ComputeRoutesResponse response =
    await routesService.computeRoute(body, headers: headers);
```


For a complete sample app, look at the [example](example/lib/main.dart).

Example app can be run with:
`dart run --define=GOOGLE_API_KEY={YOUR GOOGLE API KEY HERE} example/lib/main.dart`
