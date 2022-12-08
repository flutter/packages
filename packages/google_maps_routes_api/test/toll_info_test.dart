// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/index.dart';
import 'package:test/test.dart';

void main() {
  group('TollInfo & Money', () {
    test('fromJson() correctly decodes a JSON object to a TollInfo', () {
      const Map<String, dynamic> json = <String, dynamic>{
        'estimatedPrice': <Map<String, dynamic>>[
          <String, dynamic>{
            'currencyCode': 'USD',
            'units': '1',
            'nanos': 0,
          }
        ],
      };

      final TollInfo? tollInfo = TollInfo.fromJson(json);

      expect(tollInfo?.estimatedPrice[0].currencyCode, 'USD');
      expect(tollInfo?.estimatedPrice[0].units, '1');
      expect(tollInfo?.estimatedPrice[0].nanos, 0);
    });
    test('toJson() correctly encodes TollInfo to JSON', () async {
      const List<Money> estimatedPrice = <Money>[
        Money(
          currencyCode: 'USD',
          units: '1',
          nanos: -750000000,
        ),
        Money(
          currencyCode: 'CAD',
          units: '2',
          nanos: -250000000,
        ),
      ];
      const TollInfo tollInfo = TollInfo(
        estimatedPrice: estimatedPrice,
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'estimatedPrice': <Map<String, dynamic>>[
          <String, dynamic>{
            'currencyCode': 'USD',
            'units': '1',
            'nanos': -750000000,
          },
          <String, dynamic>{
            'currencyCode': 'CAD',
            'units': '2',
            'nanos': -250000000,
          },
        ],
      };

      expect(tollInfo.toJson(), equals(expectedJson));
    });
  });
}
