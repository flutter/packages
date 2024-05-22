// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_client_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

const _$BillingResponseEnumMap = {
  BillingResponse.serviceTimeout: -3,
  BillingResponse.featureNotSupported: -2,
  BillingResponse.serviceDisconnected: -1,
  BillingResponse.ok: 0,
  BillingResponse.userCanceled: 1,
  BillingResponse.serviceUnavailable: 2,
  BillingResponse.billingUnavailable: 3,
  BillingResponse.itemUnavailable: 4,
  BillingResponse.developerError: 5,
  BillingResponse.error: 6,
  BillingResponse.itemAlreadyOwned: 7,
  BillingResponse.itemNotOwned: 8,
  BillingResponse.networkError: 12,
};

const _$BillingChoiceModeEnumMap = {
  BillingChoiceMode.playBillingOnly: 0,
  BillingChoiceMode.alternativeBillingOnly: 1,
  BillingChoiceMode.userChoiceBilling: 2,
};

const _$ProductTypeEnumMap = {
  ProductType.inapp: 'inapp',
  ProductType.subs: 'subs',
};

const _$ProrationModeEnumMap = {
  ProrationMode.unknownSubscriptionUpgradeDowngradePolicy: 0,
  ProrationMode.immediateWithTimeProration: 1,
  ProrationMode.immediateAndChargeProratedPrice: 2,
  ProrationMode.immediateWithoutProration: 3,
  ProrationMode.deferred: 4,
  ProrationMode.immediateAndChargeFullPrice: 5,
};

const _$ReplacementModeEnumMap = {
  ReplacementMode.unknownReplacementMode: 0,
  ReplacementMode.withTimeProration: 1,
  ReplacementMode.chargeProratedPrice: 2,
  ReplacementMode.withoutProration: 3,
  ReplacementMode.deferred: 6,
  ReplacementMode.chargeFullPrice: 5,
};

const _$BillingClientFeatureEnumMap = {
  BillingClientFeature.inAppItemsOnVR: 'inAppItemsOnVr',
  BillingClientFeature.priceChangeConfirmation: 'priceChangeConfirmation',
  BillingClientFeature.productDetails: 'fff',
  BillingClientFeature.subscriptions: 'subscriptions',
  BillingClientFeature.subscriptionsOnVR: 'subscriptionsOnVr',
  BillingClientFeature.subscriptionsUpdate: 'subscriptionsUpdate',
};
