# Migration Guide from 0.2.x to 0.3.0

Starting November 2023, Android Billing Client V4 is no longer supported,
requiring app developers using the plugin to migrate to 0.3.0.
Version 0.3.0 introduces breaking changes to the API as a result of changes in
the underlying Google Play Billing Library.
For context around the changes see the [recent changes to subscriptions in Play Console][1]
and the [Android Billing Client V5 migration guide][2].

## SKUs become Products

SKUs have been replaced with products. For example, the `SkuDetailsWrapper`
class has been replaced by `ProductDetailsWrapper`, and the `SkuType` enum has
been replaced by `ProductType`.

Products are used to represent both in-app purchases (also referred to as
one-time purchases) and subscriptions. There are a few changes to the data model
that are important to note.

Previously, an SKU of `SkuType.subs` would contain a `freeTrialPeriod`,
`introductoryPrice` and some related properties. In the new model, this has been
replaced by a more generic approach.
A subscription product can have multiple pricing phases, each with its own
price, subscription period etc. This allows for more flexibility in the pricing
model.

In the next section we will look at how to migrate code that uses the old model
to the new model. Instead of listing all possible use cases, we will focus on
two: getting the price of a one time purchase, and handling free trials for
subscriptions. Other use cases can be migrated in a similar way.

### Use case: getting the price of a one time purchase

Below code shows how to get the price of a one time purchase before and after
the migration. Other properties can be obtained in a similar way.

Code before migration:

```dart
SkuDetailsWrapper sku;

if (sku.type == SkuType.inapp) {
  String price = sku.price;
}
```

Code after migration:

```dart
ProductDetailsWrapper product;

if (product.productType == ProductType.inapp) {
  OneTimePurchaseOfferDetailsWrapper offer = product.oneTimePurchaseOfferDetails!;
  String price = offer.formattedPrice;
}
```

### Use case: free trial subscriptions

Below code shows how to handle free trials for subscriptions before and after
the migration. As subscriptions can contain multiple offers, each containing
multiple price phases, the logic is more involved. Other use cases such as
dealing with introductory prices follow a similar pattern.

Code before migration:

```dart
SkuDetailsWrapper sku;

if (sku.type == SkuType.subs) {
  if (sku.freeTrialPeriod.isNotEmpty) {
    // Free trial period logic.
  }
}
```

Code after migration:

```dart
ProductDetailsWrapper product;

if (product.productType == ProductType.subs) {
  List<SubscriptionOfferDetailsWrapper> offers = product.subscriptionOfferDetails!;

  Iterable<SubscriptionOfferDetailsWrapper> freeTrialOffers = offers
    .where((SubscriptionOfferDetailsWrapper offer) => offer.pricingPhases.first.priceAmountMicros == 0);

  if (freeTrialOffers.isNotEmpty) {
    SubscriptionOfferDetailsWrapper freeTrialOffer = freeTrialOffers.first;
    // Free trial period logic.
  }
}
```

## Removal of `launchPriceChangeConfirmationFlow`

The method `launchPriceChangeConfirmationFlow` has been removed. Price changes
are no longer handled by the application but are instead handled by the Google
Play Store automatically. See [subscription price changes][3] for more
information.

<!-- References -->
[1]: https://support.google.com/googleplay/android-developer/answer/12124625
[2]: https://developer.android.com/google/play/billing/migrate-gpblv5
[3]: https://developer.android.com/google/play/billing/subscriptions#price-change
