// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductWrapper _$ProductWrapperFromJson(Map json) => ProductWrapper(
      productId: json['productId'] as String? ?? '',
      productType: $enumDecode(_$ProductTypeEnumMap, json['productType']),
    );

Map<String, dynamic> _$ProductWrapperToJson(ProductWrapper instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productType': _$ProductTypeEnumMap[instance.productType]!,
    };

const _$ProductTypeEnumMap = {
  ProductType.inapp: 'inapp',
  ProductType.subs: 'subs',
};
