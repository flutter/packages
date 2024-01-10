// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_offer_details_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionOfferDetailsWrapper _$SubscriptionOfferDetailsWrapperFromJson(
        Map json) =>
    SubscriptionOfferDetailsWrapper(
      basePlanId: json['basePlanId'] as String? ?? '',
      offerId: json['offerId'] as String?,
      offerTags: (json['offerTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      offerIdToken: json['offerIdToken'] as String? ?? '',
      pricingPhases: (json['pricingPhases'] as List<dynamic>?)
              ?.map((e) => PricingPhaseWrapper.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );

PricingPhaseWrapper _$PricingPhaseWrapperFromJson(Map json) =>
    PricingPhaseWrapper(
      billingCycleCount: json['billingCycleCount'] as int? ?? 0,
      billingPeriod: json['billingPeriod'] as String? ?? '',
      formattedPrice: json['formattedPrice'] as String? ?? '',
      priceAmountMicros: json['priceAmountMicros'] as int? ?? 0,
      priceCurrencyCode: json['priceCurrencyCode'] as String? ?? '',
      recurrenceMode: json['recurrenceMode'] == null
          ? RecurrenceMode.nonRecurring
          : const RecurrenceModeConverter()
              .fromJson(json['recurrenceMode'] as int?),
    );
