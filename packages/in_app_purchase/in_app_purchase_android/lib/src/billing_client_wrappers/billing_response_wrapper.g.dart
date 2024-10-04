// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_response_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillingResultWrapper _$BillingResultWrapperFromJson(Map json) =>
    BillingResultWrapper(
      responseCode: const BillingResponseConverter()
          .fromJson((json['responseCode'] as num?)?.toInt()),
      debugMessage: json['debugMessage'] as String?,
    );
