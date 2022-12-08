// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/index.dart';
import 'package:test/test.dart';

void main() {
  group('ComputeRoutesResponse', () {
    test('fromJson() decodes JSON to ComputeRoutesResponse', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'routes': <Map<String, dynamic>>[
          <String, dynamic>{
            'distanceMeters': 100,
            'legs': <Map<String, dynamic>>[
              <String, dynamic>{
                'distanceMeters': 100,
              },
            ],
          },
        ],
        'fallbackInfo': <String, dynamic>{
          'routingMode': 'FALLBACK_TRAFFIC_AWARE',
          'reason': 'LATENCY_EXCEEDED',
        },
      };

      final ComputeRoutesResponse? response =
          ComputeRoutesResponse.fromJson(json);
      expect(response?.routes, isA<List<Route>>());
      expect(response?.fallbackInfo, isA<FallbackInfo>());
    });

    test('toJson() encodes ComputeRoutesResponse to JSON', () {
      const ComputeRoutesResponse response = ComputeRoutesResponse(
        routes: <Route>[
          Route(
            distanceMeters: 100,
            legs: <RouteLeg>[
              RouteLeg(
                distanceMeters: 100,
              ),
            ],
          ),
        ],
        fallbackInfo: FallbackInfo(
          routingMode: FallbackRoutingMode.FALLBACK_TRAFFIC_AWARE,
          reason: FallbackReason.LATENCY_EXCEEDED,
        ),
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'routes': <Map<String, dynamic>>[
          <String, dynamic>{
            'distanceMeters': 100,
            'legs': <Map<String, dynamic>>[
              <String, dynamic>{
                'distanceMeters': 100,
              },
            ],
          },
        ],
        'fallbackInfo': <String, dynamic>{
          'routingMode': 'FALLBACK_TRAFFIC_AWARE',
          'reason': 'LATENCY_EXCEEDED',
        },
      };

      expect(response.toJson(), expectedJson);
    });
  });
}
