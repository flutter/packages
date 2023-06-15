<?code-excerpt path-base="excerpts/packages/in_app_purchase_android_example"?>
# Migration Guide from 0.2.x to 0.3.0

Starting November 2023, Android Billing Client V4 is no longer supported,
requiring app developers using the plugin to migrate to 0.3.0.
Version 0.3.0 introduces breaking changes to the API as a result of changes in
the underlying Google Play Billing Library.
For context around the changes see the [recent changes to subscriptions in Play Console][1]
and the [Google Play Billing Library migration guide][2].

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
three: getting the price of a one time purchase, and handling both free trials
and introductory prices for subscriptions. Other use cases can be migrated in a
similar way.

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

<?code-excerpt "migration_guide_examples.dart (one-time-purchase-price)"?>
```dart
/// Handles the one time purchase price of a product.
void handleOneTimePurchasePrice(ProductDetails productDetails) {
  if (productDetails is GooglePlayProductDetails) {
    final ProductDetailsWrapper product = productDetails.productDetails;
    if (product.productType == ProductType.inapp) {
      // Unwrapping is safe because the product is a one time purchase.
      final OneTimePurchaseOfferDetailsWrapper offer =
          product.oneTimePurchaseOfferDetails!;
      final String price = offer.formattedPrice;
    }
  }
}
```

### Use case: free trials

Below code shows how to handle free trials for subscriptions before and after
the migration. As subscriptions can contain multiple offers, each containing
multiple price phases, the logic is more involved.

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

<?code-excerpt "migration_guide_examples.dart (subscription-free-trial)"?>
```dart
/// Handles the free trial period of a subscription.
void handleFreeTrialPeriod(ProductDetails productDetails) {
  if (productDetails is GooglePlayProductDetails) {
    final ProductDetailsWrapper product = productDetails.productDetails;
    if (product.productType == ProductType.subs) {
      // Unwrapping is safe because the product is a subscription.
      final SubscriptionOfferDetailsWrapper offer =
          product.subscriptionOfferDetails![productDetails.subscriptionIndex!];
      final List<PricingPhaseWrapper> pricingPhases = offer.pricingPhases;
      if (pricingPhases.first.priceAmountMicros == 0) {
        // Free trial period logic.
      }
    }
  }
}
```

### Use case: introductory prices

Below code shows how to handle introductory prices for subscriptions before and
after the migration. As subscriptions can contain multiple offers, each
containing multiple price phases, the logic is more involved.

Code before migration:

```dart
SkuDetailsWrapper sku;

if (sku.type == SkuType.subs) {
  if (sku.introductoryPriceAmountMicros != 0) {
    // Introductory price period logic.
  }
}
```

Code after migration:

<?code-excerpt "migration_guide_examples.dart (subscription-introductory-price)"?>
```dart
/// Handles the introductory price period of a subscription.
void handleIntroductoryPricePeriod(ProductDetails productDetails) {
  if (productDetails is GooglePlayProductDetails) {
    final ProductDetailsWrapper product = productDetails.productDetails;
    if (product.productType == ProductType.subs) {
      // Unwrapping is safe because the product is a subscription.
      final SubscriptionOfferDetailsWrapper offer =
          product.subscriptionOfferDetails![productDetails.subscriptionIndex!];
      final List<PricingPhaseWrapper> pricingPhases = offer.pricingPhases;
      if (pricingPhases.length >= 2 &&
          pricingPhases.first.priceAmountMicros <
              pricingPhases[1].priceAmountMicros) {
        // Introductory pricing period logic.
      }
    }
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
[2]: https://developer.android.com/google/play/billing/migrate-gpblv6#5-or-6
[3]: https://developer.android.com/google/play/billing/subscriptions#price-change
