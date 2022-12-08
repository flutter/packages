// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/fallback_info.dart';
import 'package:test/test.dart';

void main() {
  group('FallbackInfo', () {
    test('fromJson() correctly decodes a JSON object to a FallbackInfo', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'routingMode': 'FALLBACK_TRAFFIC_AWARE',
        'reason': 'SERVER_ERROR',
      };

      final FallbackInfo? fallbackInfo = FallbackInfo.fromJson(json);

      expect(fallbackInfo?.routingMode,
          equals(FallbackRoutingMode.FALLBACK_TRAFFIC_AWARE));
      expect(fallbackInfo?.reason, equals(FallbackReason.SERVER_ERROR));
    });

    test('toJson() encodes FallbackInfo to JSON', () {
      const FallbackInfo fallbackInfo = FallbackInfo(
        routingMode: FallbackRoutingMode.FALLBACK_TRAFFIC_UNAWARE,
        reason: FallbackReason.LATENCY_EXCEEDED,
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'routingMode': 'FALLBACK_TRAFFIC_UNAWARE',
        'reason': 'LATENCY_EXCEEDED',
      };

      expect(fallbackInfo.toJson(), equals(expectedJson));
    });
  });
}
