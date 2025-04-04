// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/src/messages.g.dart';
import 'package:in_app_purchase_storekit/src/store_kit_2_wrappers/sk2_product_wrapper.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

void main() {
  final SKPriceLocaleWrapper locale = SKPriceLocaleWrapper(
      currencySymbol: r'$', currencyCode: 'USD', countryCode: 'USA');

  final SKProductSubscriptionPeriodWrapper subPeriod =
      SKProductSubscriptionPeriodWrapper(
          numberOfUnits: 1, unit: SKSubscriptionPeriodUnit.month);

  final SKProductDiscountWrapper discount = SKProductDiscountWrapper(
      price: '0.99',
      priceLocale: locale,
      numberOfPeriods: 1,
      paymentMode: SKProductDiscountPaymentMode.payUpFront,
      subscriptionPeriod: subPeriod,
      identifier: 'discount',
      type: SKProductDiscountType.subscription);

  final SKProductWrapper product = SKProductWrapper(
      productIdentifier: 'fake_product',
      localizedTitle: 'title',
      localizedDescription: 'description',
      priceLocale: locale,
      price: '3.99',
      subscriptionGroupIdentifier: 'sub_group',
      discounts: <SKProductDiscountWrapper>[discount]);

  final SkProductResponseWrapper productResponse = SkProductResponseWrapper(
      products: <SKProductWrapper>[product],
      invalidProductIdentifiers: const <String>['invalid_identifier']);

  test('test SKPriceLocale pigeon converters', () {
    final SKPriceLocaleMessage msg =
        SKPriceLocaleWrapper.convertToPigeon(locale);
    expect(msg.currencySymbol, r'$');
    expect(msg.currencyCode, 'USD');
    expect(msg.countryCode, 'USA');

    final SKPriceLocaleWrapper convertedWrapper =
        SKPriceLocaleWrapper.convertFromPigeon(msg);
    expect(convertedWrapper, locale);
  });

  test('test SKProductSubscription pigeon converters', () {
    final SKProductSubscriptionPeriodMessage msg =
        SKProductSubscriptionPeriodWrapper.convertToPigeon(subPeriod);
    expect(msg.unit, SKSubscriptionPeriodUnitMessage.month);
    expect(msg.numberOfUnits, 1);
    final SKProductSubscriptionPeriodWrapper convertedWrapper =
        SKProductSubscriptionPeriodWrapper.convertFromPigeon(msg);
    expect(convertedWrapper, subPeriod);
  });

  test('test SKProductDiscount pigeon converters', () {
    final SKProductDiscountMessage msg =
        SKProductDiscountWrapper.convertToPigeon(discount);
    expect(msg.price, '0.99');
    expect(msg.numberOfPeriods, 1);
    expect(msg.paymentMode, SKProductDiscountPaymentModeMessage.payUpFront);
    expect(msg.identifier, 'discount');
    expect(msg.type, SKProductDiscountTypeMessage.subscription);

    final SKProductDiscountWrapper convertedWrapper =
        SKProductDiscountWrapper.convertFromPigeon(msg);
    expect(convertedWrapper, discount);
  });

  test('test SKProduct pigeon converters', () {
    final SKProductMessage msg = SKProductWrapper.convertToPigeon(product);
    expect(msg.productIdentifier, 'fake_product');
    expect(msg.localizedTitle, 'title');
    expect(msg.localizedDescription, 'description');
    expect(msg.price, '3.99');
    expect(msg.discounts?.length, 1);

    final SKProductWrapper convertedWrapper =
        SKProductWrapper.convertFromPigeon(msg);
    expect(convertedWrapper, product);
  });

  test('test SKProductResponse pigeon converters', () {
    final SKProductsResponseMessage msg =
        SkProductResponseWrapper.convertToPigeon(productResponse);
    expect(msg.products?.length, 1);
    expect(msg.invalidProductIdentifiers, <String>['invalid_identifier']);

    final SkProductResponseWrapper convertedWrapper =
        SkProductResponseWrapper.convertFromPigeon(msg);
    expect(convertedWrapper, productResponse);
  });

  test('test SKerror pigeon converter', () {
    final SKErrorMessage msg = SKErrorMessage(code: 99, domain: 'domain');
    final SKError wrapper = SKError.convertFromPigeon(msg);

    expect(wrapper.code, 99);
    expect(wrapper.domain, 'domain');
    expect(wrapper.userInfo, <String, Object>{});
  });

  test('test AppStoreProduct2Details conversion', () {
    final SK2Product product = SK2Product(
        id: '123',
        displayName: 'name',
        displayPrice: '0.99',
        description: 'description',
        price: 9.99,
        type: SK2ProductType.consumable,
        priceLocale: SK2PriceLocale(currencyCode: 'USD', currencySymbol: r'$'));

    final AppStoreProduct2Details details =
        AppStoreProduct2Details.fromSK2Product(product);

    expect(details.sk2Product, product);
    expect(details.price, product.displayPrice);
    expect(details.id, product.id);
    expect(details.description, product.description);
    expect(details.currencySymbol, product.priceLocale.currencySymbol);
  });
}
