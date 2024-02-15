// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_choice_details_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserChoiceDetailsWrapper _$UserChoiceDetailsWrapperFromJson(Map json) =>
    UserChoiceDetailsWrapper(
      originalExternalTransactionId:
          json['originalExternalTransactionId'] as String? ?? '',
      externalTransactionToken:
          json['externalTransactionToken'] as String? ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => UserChoiceDetailsProductWrapper.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );

UserChoiceDetailsProductWrapper _$UserChoiceDetailsProductWrapperFromJson(
        Map json) =>
    UserChoiceDetailsProductWrapper(
      id: json['id'] as String? ?? '',
      offerToken: json['offerToken'] as String? ?? '',
      productType: json['productType'] as String? ?? '',
    );
