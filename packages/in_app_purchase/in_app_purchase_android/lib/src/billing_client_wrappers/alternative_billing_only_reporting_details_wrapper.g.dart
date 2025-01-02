// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alternative_billing_only_reporting_details_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlternativeBillingOnlyReportingDetailsWrapper
    _$AlternativeBillingOnlyReportingDetailsWrapperFromJson(Map json) =>
        AlternativeBillingOnlyReportingDetailsWrapper(
          responseCode: const BillingResponseConverter()
              .fromJson((json['responseCode'] as num?)?.toInt()),
          debugMessage: json['debugMessage'] as String? ?? '',
          externalTransactionToken:
              json['externalTransactionToken'] as String? ?? '',
        );
