// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_config_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillingConfigWrapper _$BillingConfigWrapperFromJson(Map json) =>
    BillingConfigWrapper(
      responseCode: const BillingResponseConverter()
          .fromJson((json['responseCode'] as num?)?.toInt()),
      debugMessage: json['debugMessage'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
    );
