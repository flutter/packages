// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/index.dart';
import 'package:test/test.dart';

void main() {
  group('RouteLeg', () {
    test('fromJson() correctly decodes JSON to a RouteLeg object', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'distanceMeters': 1000,
        'duration': '600s',
        'staticDuration': '300s',
        'polyline': <String, dynamic>{'encodedPolyline': 'encoded-polyline'},
        'startLocation': <String, dynamic>{
          'latLng': <String, double>{'latitude': 1.0, 'longitude': 2.0}
        },
        'endLocation': <String, dynamic>{
          'latLng': <String, double>{'latitude': 3.0, 'longitude': 4.0}
        },
        'steps': <Map<String, dynamic>>[
          <String, dynamic>{
            'distanceMeters': 100,
          }
        ],
        'travelAdvisory': <String, dynamic>{
          'tollInfo': <String, dynamic>{
            'estimatedPrice': <Map<String, dynamic>>[
              <String, dynamic>{
                'currencyCode': 'USD',
                'units': '100',
                'nanos': 0,
              },
            ],
          },
          'speedReadingIntervals': <Map<String, dynamic>>[
            <String, dynamic>{
              'startPolylinePointIndex': 0,
              'endPolylinePointIndex': 10,
              'speed': 'NORMAL',
            },
            <String, dynamic>{
              'startPolylinePointIndex': 10,
              'endPolylinePointIndex': 20,
              'speed': 'NORMAL',
            },
          ],
          'fuelConsumptionMicroliters': '1234',
        }
      };

      final RouteLeg? routeLeg = RouteLeg.fromJson(json);
      expect(routeLeg?.distanceMeters, 1000);
      expect(routeLeg?.duration, '600s');
      expect(routeLeg?.staticDuration, '300s');
      expect(routeLeg?.polyline, isA<Polyline>());
      expect(routeLeg?.startLocation, isA<Location>());
      expect(routeLeg?.endLocation, isA<Location>());
      expect(routeLeg?.steps, isA<List<RouteLegStep>>());
      expect(routeLeg?.travelAdvisory, isA<RouteLegTravelAdvisory>());
    });

    test('toJson() correctly encodes a RouteLeg object to JSON', () {
      const RouteLeg routeLeg = RouteLeg(
        distanceMeters: 1000,
        duration: '600s',
        staticDuration: '300s',
        polyline: Polyline(
          encodedPolyline: 'encoded-polyline',
        ),
        startLocation: Location(
          latLng: LatLng(1.0, 2.0),
        ),
        endLocation: Location(
          latLng: LatLng(
            3.0,
            4.0,
          ),
        ),
        steps: <RouteLegStep>[
          RouteLegStep(distanceMeters: 100),
        ],
        travelAdvisory: RouteLegTravelAdvisory(
          tollInfo: TollInfo(
            estimatedPrice: <Money>[
              Money(
                currencyCode: 'USD',
                units: '100',
                nanos: 0,
              ),
            ],
          ),
          speedReadingIntervals: <SpeedReadingInterval>[
            SpeedReadingInterval(
              startPolylinePointIndex: 0,
              endPolylinePointIndex: 10,
              speed: Speed.NORMAL,
            ),
            SpeedReadingInterval(
              startPolylinePointIndex: 10,
              endPolylinePointIndex: 20,
              speed: Speed.NORMAL,
            ),
          ],
        ),
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'distanceMeters': 1000,
        'duration': '600s',
        'staticDuration': '300s',
        'polyline': <String, dynamic>{'encodedPolyline': 'encoded-polyline'},
        'startLocation': <String, dynamic>{
          'latLng': <String, dynamic>{'latitude': 1.0, 'longitude': 2.0}
        },
        'endLocation': <String, dynamic>{
          'latLng': <String, dynamic>{'latitude': 3.0, 'longitude': 4.0}
        },
        'steps': <Map<String, dynamic>>[
          <String, dynamic>{
            'distanceMeters': 100,
          }
        ],
        'travelAdvisory': <String, dynamic>{
          'tollInfo': <String, dynamic>{
            'estimatedPrice': <Map<String, dynamic>>[
              <String, dynamic>{
                'currencyCode': 'USD',
                'units': '100',
                'nanos': 0,
              },
            ],
          },
          'speedReadingIntervals': <Map<String, dynamic>>[
            <String, dynamic>{
              'startPolylinePointIndex': 0,
              'endPolylinePointIndex': 10,
              'speed': 'NORMAL',
            },
            <String, dynamic>{
              'startPolylinePointIndex': 10,
              'endPolylinePointIndex': 20,
              'speed': 'NORMAL',
            },
          ],
        }
      };

      expect(routeLeg.toJson(), equals(expectedJson));
    });
  });

  group('RouteLegStep', () {
    test('fromJson() correctly decodes JSON to a RouteLegStep object', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'distanceMeters': 1000,
        'staticDuration': '300s',
        'polyline': <String, dynamic>{'encodedPolyline': 'encoded-polyline'},
        'startLocation': <String, dynamic>{
          'latLng': <String, double>{'latitude': 1.0, 'longitude': 2.0}
        },
        'endLocation': <String, dynamic>{
          'latLng': <String, double>{'latitude': 3.0, 'longitude': 4.0}
        },
        'navigationInstruction': <String, dynamic>{
          'maneuver': 'TURN_LEFT',
          'instructions': 'Turn left onto Main St.',
        },
        'travelAdvisory': <String, dynamic>{
          'tollInfo': <String, dynamic>{
            'estimatedPrice': <Map<String, dynamic>>[
              <String, dynamic>{
                'currencyCode': 'USD',
                'units': '100',
                'nanos': 0,
              },
            ],
          },
          'speedReadingIntervals': <Map<String, dynamic>>[
            <String, dynamic>{
              'startPolylinePointIndex': 0,
              'endPolylinePointIndex': 10,
              'speed': 'NORMAL',
            },
            <String, dynamic>{
              'startPolylinePointIndex': 10,
              'endPolylinePointIndex': 20,
              'speed': 'NORMAL',
            },
          ],
          'fuelConsumptionMicroliters': '1234',
        }
      };

      final RouteLegStep? routeLegStep = RouteLegStep.fromJson(json);
      expect(routeLegStep?.distanceMeters, 1000);
      expect(routeLegStep?.staticDuration, '300s');
      expect(routeLegStep?.polyline, isA<Polyline>());
      expect(routeLegStep?.startLocation, isA<Location>());
      expect(routeLegStep?.endLocation, isA<Location>());
      expect(routeLegStep?.navigationInstruction, isA<NavigationInstruction>());
      expect(routeLegStep?.travelAdvisory, isA<RouteLegStepTravelAdvisory>());
    });

    test('toJson() correctly encodes a RouteLegStep object to JSON', () {
      const RouteLegStep routeLegStep = RouteLegStep(
        distanceMeters: 1000,
        staticDuration: '300s',
        polyline: Polyline(
          encodedPolyline: 'encoded-polyline',
        ),
        startLocation: Location(
          latLng: LatLng(1.0, 2.0),
        ),
        endLocation: Location(
          latLng: LatLng(3.0, 4.0),
        ),
        navigationInstruction: NavigationInstruction(
          maneuver: Maneuver.TURN_LEFT,
          instructions: 'Turn left onto Main St.',
        ),
        travelAdvisory: RouteLegStepTravelAdvisory(
          speedReadingIntervals: <SpeedReadingInterval>[
            SpeedReadingInterval(
              startPolylinePointIndex: 0,
              endPolylinePointIndex: 10,
              speed: Speed.NORMAL,
            ),
            SpeedReadingInterval(
              startPolylinePointIndex: 10,
              endPolylinePointIndex: 20,
              speed: Speed.NORMAL,
            ),
          ],
        ),
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'distanceMeters': 1000,
        'staticDuration': '300s',
        'polyline': <String, dynamic>{'encodedPolyline': 'encoded-polyline'},
        'startLocation': <String, dynamic>{
          'latLng': <String, dynamic>{'latitude': 1.0, 'longitude': 2.0}
        },
        'endLocation': <String, dynamic>{
          'latLng': <String, dynamic>{'latitude': 3.0, 'longitude': 4.0}
        },
        'navigationInstruction': <String, dynamic>{
          'maneuver': 'TURN_LEFT',
          'instructions': 'Turn left onto Main St.',
        },
        'travelAdvisory': <String, dynamic>{
          'speedReadingIntervals': <Map<String, dynamic>>[
            <String, dynamic>{
              'startPolylinePointIndex': 0,
              'endPolylinePointIndex': 10,
              'speed': 'NORMAL',
            },
            <String, dynamic>{
              'startPolylinePointIndex': 10,
              'endPolylinePointIndex': 20,
              'speed': 'NORMAL',
            },
          ],
        }
      };

      expect(routeLegStep.toJson(), equals(expectedJson));
    });
  });
}
