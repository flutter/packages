// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/types/google_play_user_choice_details.dart';
import 'package:in_app_purchase_android/src/types/translator.dart';
import 'package:test/test.dart';

void main() {
  group('Translator ', () {
    test('convertToPlayProductType', () {
      expect(
        Translator.convertToPlayProductType(ProductType.inapp),
        GooglePlayProductType.inapp,
      );
      expect(
        Translator.convertToPlayProductType(ProductType.subs),
        GooglePlayProductType.subs,
      );
      expect(GooglePlayProductType.values.length, ProductType.values.length);
    });

    test('convertToUserChoiceDetailsProduct', () {
      const expected = GooglePlayUserChoiceDetailsProduct(
        id: 'id',
        offerToken: 'offerToken',
        productType: GooglePlayProductType.inapp,
      );
      expect(
        Translator.convertToUserChoiceDetailsProduct(
          UserChoiceDetailsProductWrapper(
            id: expected.id,
            offerToken: expected.offerToken,
            productType: ProductType.inapp,
          ),
        ),
        expected,
      );
    });
    test('convertToUserChoiceDetailsProduct', () {
      const expectedProduct1 = GooglePlayUserChoiceDetailsProduct(
        id: 'id1',
        offerToken: 'offerToken1',
        productType: GooglePlayProductType.inapp,
      );
      const expectedProduct2 = GooglePlayUserChoiceDetailsProduct(
        id: 'id2',
        offerToken: 'offerToken2',
        productType: GooglePlayProductType.subs,
      );
      const expected = GooglePlayUserChoiceDetails(
        originalExternalTransactionId: 'originalExternalTransactionId',
        externalTransactionToken: 'externalTransactionToken',
        products: <GooglePlayUserChoiceDetailsProduct>[
          expectedProduct1,
          expectedProduct2,
        ],
      );

      expect(
        Translator.convertToUserChoiceDetails(
          UserChoiceDetailsWrapper(
            originalExternalTransactionId:
                expected.originalExternalTransactionId,
            externalTransactionToken: expected.externalTransactionToken,
            products: <UserChoiceDetailsProductWrapper>[
              UserChoiceDetailsProductWrapper(
                id: expectedProduct1.id,
                offerToken: expectedProduct1.offerToken,
                productType: ProductType.inapp,
              ),
              UserChoiceDetailsProductWrapper(
                id: expectedProduct2.id,
                offerToken: expectedProduct2.offerToken,
                productType: ProductType.subs,
              ),
            ],
          ),
        ),
        expected,
      );
    });
  });
}
