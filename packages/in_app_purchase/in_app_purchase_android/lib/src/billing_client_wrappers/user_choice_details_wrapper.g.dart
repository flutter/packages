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

Map<String, dynamic> _$UserChoiceDetailsWrapperToJson(
        UserChoiceDetailsWrapper instance) =>
    <String, dynamic>{
      'originalExternalTransactionId': instance.originalExternalTransactionId,
      'externalTransactionToken': instance.externalTransactionToken,
      'products': instance.products.map((e) => e.toJson()).toList(),
    };

UserChoiceDetailsProductWrapper _$UserChoiceDetailsProductWrapperFromJson(
        Map json) =>
    UserChoiceDetailsProductWrapper(
      id: json['id'] as String? ?? '',
      offerToken: json['offerToken'] as String? ?? '',
      productType:
          const ProductTypeConverter().fromJson(json['productType'] as String?),
    );

Map<String, dynamic> _$UserChoiceDetailsProductWrapperToJson(
        UserChoiceDetailsProductWrapper instance) =>
    <String, dynamic>{
      'id': instance.id,
      'offerToken': instance.offerToken,
      'productType': const ProductTypeConverter().toJson(instance.productType),
    };
