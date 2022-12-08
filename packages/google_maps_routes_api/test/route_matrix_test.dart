// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/index.dart';
import 'package:test/test.dart';

void main() {
  group('RouteMatrixElement', () {
    test('fromJson() decodes JSON to RouteMatrixElement', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'condition': 'ROUTE_EXISTS',
        'distanceMeters': 5000,
        'duration': '600s',
        'staticDuration': '300s',
        'travelAdvisory': <String, dynamic>{
          'fuelConsumptionMicroliters': '200'
        },
        'fallbackInfo': <String, dynamic>{
          'routingMode': 'FALLBACK_TRAFFIC_AWARE',
          'reason': 'LATENCY_EXCEEDED',
        },
        'originIndex': 0,
        'destinationIndex': 1,
      };

      final RouteMatrixElement? element = RouteMatrixElement.fromJson(json);
      expect(element?.condition, RouteMatrixElementCondition.ROUTE_EXISTS);
      expect(element?.distanceMeters, 5000);
      expect(element?.duration, '600s');
      expect(element?.staticDuration, '300s');
      expect(element?.travelAdvisory, isA<RouteTravelAdvisory>());
      expect(element?.fallbackInfo, isA<FallbackInfo>());
      expect(element?.originIndex, 0);
      expect(element?.destinationIndex, 1);
    });

    test('toJson() encodes RouteMatrixElement to JSON', () {
      const RouteMatrixElement element = RouteMatrixElement(
        condition: RouteMatrixElementCondition.ROUTE_EXISTS,
        distanceMeters: 5000,
        duration: '600s',
        staticDuration: '300s',
        travelAdvisory: RouteTravelAdvisory(fuelConsumptionMicroliters: '200'),
        fallbackInfo: FallbackInfo(
          routingMode: FallbackRoutingMode.FALLBACK_TRAFFIC_AWARE,
          reason: FallbackReason.LATENCY_EXCEEDED,
        ),
        originIndex: 0,
        destinationIndex: 1,
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'condition': 'ROUTE_EXISTS',
        'distanceMeters': 5000,
        'duration': '600s',
        'staticDuration': '300s',
        'travelAdvisory': <String, dynamic>{
          'fuelConsumptionMicroliters': '200'
        },
        'fallbackInfo': <String, dynamic>{
          'routingMode': 'FALLBACK_TRAFFIC_AWARE',
          'reason': 'LATENCY_EXCEEDED',
        },
        'originIndex': 0,
        'destinationIndex': 1,
      };

      final Map<String, dynamic> json = element.toJson();
      expect(json, expectedJson);
    });
  });
}
