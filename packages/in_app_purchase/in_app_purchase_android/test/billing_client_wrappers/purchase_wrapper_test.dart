// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:test/test.dart';

const PurchaseWrapper dummyPurchase = PurchaseWrapper(
  orderId: 'orderId',
  packageName: 'packageName',
  purchaseTime: 0,
  signature: 'signature',
  products: <String>['product'],
  purchaseToken: 'purchaseToken',
  isAutoRenewing: false,
  originalJson: '',
  developerPayload: 'dummy payload',
  isAcknowledged: true,
  purchaseState: PurchaseStateWrapper.purchased,
  obfuscatedAccountId: 'Account101',
  obfuscatedProfileId: 'Profile103',
);

const PurchaseWrapper dummyMultipleProductsPurchase = PurchaseWrapper(
  orderId: 'orderId',
  packageName: 'packageName',
  purchaseTime: 0,
  signature: 'signature',
  products: <String>['product', 'product2'],
  purchaseToken: 'purchaseToken',
  isAutoRenewing: false,
  originalJson: '',
  developerPayload: 'dummy payload',
  isAcknowledged: true,
  purchaseState: PurchaseStateWrapper.purchased,
);

const PurchaseWrapper dummyUnacknowledgedPurchase = PurchaseWrapper(
  orderId: 'orderId',
  packageName: 'packageName',
  purchaseTime: 0,
  signature: 'signature',
  products: <String>['product'],
  purchaseToken: 'purchaseToken',
  isAutoRenewing: false,
  originalJson: '',
  developerPayload: 'dummy payload',
  isAcknowledged: false,
  purchaseState: PurchaseStateWrapper.purchased,
);

void main() {
  group('PurchaseWrapper', () {
    test('fromPurchase() should return correct PurchaseDetail object', () {
      final List<GooglePlayPurchaseDetails> details =
          GooglePlayPurchaseDetails.fromPurchase(dummyMultipleProductsPurchase);

      expect(details[0].purchaseID, dummyMultipleProductsPurchase.orderId);
      expect(details[0].productID, dummyMultipleProductsPurchase.products[0]);
      expect(details[0].transactionDate,
          dummyMultipleProductsPurchase.purchaseTime.toString());
      expect(details[0].verificationData, isNotNull);
      expect(details[0].verificationData.source, kIAPSource);
      expect(details[0].verificationData.localVerificationData,
          dummyMultipleProductsPurchase.originalJson);
      expect(details[0].verificationData.serverVerificationData,
          dummyMultipleProductsPurchase.purchaseToken);
      expect(details[0].billingClientPurchase, dummyMultipleProductsPurchase);
      expect(details[0].pendingCompletePurchase, false);

      expect(details[1].purchaseID, dummyMultipleProductsPurchase.orderId);
      expect(details[1].productID, dummyMultipleProductsPurchase.products[1]);
      expect(details[1].transactionDate,
          dummyMultipleProductsPurchase.purchaseTime.toString());
      expect(details[1].verificationData, isNotNull);
      expect(details[1].verificationData.source, kIAPSource);
      expect(details[1].verificationData.localVerificationData,
          dummyMultipleProductsPurchase.originalJson);
      expect(details[1].verificationData.serverVerificationData,
          dummyMultipleProductsPurchase.purchaseToken);
      expect(details[1].billingClientPurchase, dummyMultipleProductsPurchase);
      expect(details[1].pendingCompletePurchase, false);
    });

    test(
        'fromPurchase() should return set pendingCompletePurchase to true for unacknowledged purchase',
        () {
      final GooglePlayPurchaseDetails details =
          GooglePlayPurchaseDetails.fromPurchase(dummyUnacknowledgedPurchase)
              .first;

      expect(details.purchaseID, dummyPurchase.orderId);
      expect(details.productID, dummyPurchase.products.first);
      expect(details.transactionDate, dummyPurchase.purchaseTime.toString());
      expect(details.verificationData, isNotNull);
      expect(details.verificationData.source, kIAPSource);
      expect(details.verificationData.localVerificationData,
          dummyPurchase.originalJson);
      expect(details.verificationData.serverVerificationData,
          dummyPurchase.purchaseToken);
      expect(details.billingClientPurchase, dummyUnacknowledgedPurchase);
      expect(details.pendingCompletePurchase, true);
    });
  });
}
