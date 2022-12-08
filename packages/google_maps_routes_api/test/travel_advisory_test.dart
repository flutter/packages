// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/index.dart';
import 'package:test/test.dart';

void main() {
  group('RouteTravelAdvisory', () {
    test('fromJson() correctly decodes JSON to a RouteTravelAdvisory object',
        () {
      // Load the expected JSON
      final Map<String, dynamic> jsonData = <String, dynamic>{
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
      };

      // Decode the JSON to a RouteTravelAdvisory object
      final RouteTravelAdvisory? routeTravelAdvisory =
          RouteTravelAdvisory.fromJson(jsonData);

      // Verify the properties of the decoded object
      expect(routeTravelAdvisory?.tollInfo, isA<TollInfo>());
      expect(routeTravelAdvisory?.speedReadingIntervals,
          isA<List<SpeedReadingInterval>>());
      expect(routeTravelAdvisory?.fuelConsumptionMicroliters, equals('1234'));
    });

    test('toJson() correctly encodes a RouteTravelAdvisory object to JSON', () {
      // Create a RouteTravelAdvisory object
      const RouteTravelAdvisory routeTravelAdvisory = RouteTravelAdvisory(
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
        fuelConsumptionMicroliters: '1234',
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
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
      };

      expect(routeTravelAdvisory.toJson(), equals(expectedJson));
    });
  });

  group('RouteLegTravelAdvisory', () {
    test('fromJson() correctly decodes JSON to a RouteLegTravelAdvisory object',
        () {
      // Load the expected JSON
      final Map<String, dynamic> jsonData = <String, dynamic>{
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
      };

      // Decode the JSON to a RouteLegTravelAdvisory object
      final RouteLegTravelAdvisory? routeTravelAdvisory =
          RouteLegTravelAdvisory.fromJson(jsonData);

      // Verify the properties of the decoded object
      expect(routeTravelAdvisory?.tollInfo, isA<TollInfo>());
      expect(routeTravelAdvisory?.speedReadingIntervals,
          isA<List<SpeedReadingInterval>>());
    });

    test('toJson() correctly encodes a RouteLegTravelAdvisory object to JSON',
        () {
      // Create a RouteTravelAdvisory object
      const RouteLegTravelAdvisory routeLegTravelAdvisory =
          RouteLegTravelAdvisory(
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
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
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
      };

      expect(routeLegTravelAdvisory.toJson(), equals(expectedJson));
    });
  });

  group('RouteLegStepTravelAdvisory', () {
    test(
        'fromJson() correctly decodes JSON to a RouteLegStepTravelAdvisory object',
        () {
      // Load the expected JSON
      final Map<String, dynamic> jsonData = <String, dynamic>{
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
      };

      // Decode the JSON to a RouteLegStepTravelAdvisory object
      final RouteLegStepTravelAdvisory? routeTravelAdvisory =
          RouteLegStepTravelAdvisory.fromJson(jsonData);

      // Verify the properties of the decoded object
      expect(routeTravelAdvisory?.speedReadingIntervals,
          isA<List<SpeedReadingInterval>>());
    });

    test(
        'toJson() correctly encodes a RouteLegStepTravelAdvisory object to JSON',
        () {
      // Create a RouteTravelAdvisory object
      const RouteLegStepTravelAdvisory routeLegStepTravelAdvisory =
          RouteLegStepTravelAdvisory(
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
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
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
      };

      expect(routeLegStepTravelAdvisory.toJson(), equals(expectedJson));
    });
  });

  group('SpeedReadingInterval', () {
    test('fromJson() correctly decodes JSON to a SpeedReadingInterval object',
        () {
      // Load the expected JSON
      final Map<String, dynamic> jsonData = <String, dynamic>{
        'speed': 'NORMAL',
        'startPolylinePointIndex': 0,
        'endPolylinePointIndex': 10,
      };

      // Decode the JSON to a SpeedReadingInterval object
      final SpeedReadingInterval? speedReadingInterval =
          SpeedReadingInterval.fromJson(jsonData);

      // Verify the properties of the decoded object
      expect(speedReadingInterval?.speed, equals(Speed.NORMAL));
      expect(speedReadingInterval?.startPolylinePointIndex, equals(0));
      expect(speedReadingInterval?.endPolylinePointIndex, equals(10));
    });

    test('toJson() correctly encodes a SpeedReadingInterval object to JSON',
        () {
      // Create a SpeedReadingInterval object
      const SpeedReadingInterval speedReadingInterval = SpeedReadingInterval(
        speed: Speed.NORMAL,
        startPolylinePointIndex: 0,
        endPolylinePointIndex: 10,
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'speed': 'NORMAL',
        'startPolylinePointIndex': 0,
        'endPolylinePointIndex': 10,
      };

      expect(speedReadingInterval.toJson(), equals(expectedJson));
    });
  });
}
