// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_details_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDetailsWrapper _$ProductDetailsWrapperFromJson(Map json) =>
    ProductDetailsWrapper(
      description: json['description'] as String? ?? '',
      name: json['name'] as String? ?? '',
      oneTimePurchaseOfferDetails: json['oneTimePurchaseOfferDetails'] == null
          ? null
          : OneTimePurchaseOfferDetailsWrapper.fromJson(
              Map<String, dynamic>.from(
                  json['oneTimePurchaseOfferDetails'] as Map)),
      productId: json['productId'] as String? ?? '',
      productType: json['productType'] == null
          ? ProductType.subs
          : const ProductTypeConverter()
              .fromJson(json['productType'] as String?),
      subscriptionOfferDetails:
          (json['subscriptionOfferDetails'] as List<dynamic>?)
              ?.map((e) => SubscriptionOfferDetailsWrapper.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList(),
      title: json['title'] as String? ?? '',
    );

ProductDetailsResponseWrapper _$ProductDetailsResponseWrapperFromJson(
        Map json) =>
    ProductDetailsResponseWrapper(
      billingResult:
          BillingResultWrapper.fromJson((json['billingResult'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      )),
      productDetailsList: (json['productDetailsList'] as List<dynamic>?)
              ?.map((e) => ProductDetailsWrapper.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );

const _$RecurrenceModeEnumMap = {
  RecurrenceMode.finiteRecurring: 2,
  RecurrenceMode.infiniteRecurring: 1,
  RecurrenceMode.nonRecurring: 3,
};
