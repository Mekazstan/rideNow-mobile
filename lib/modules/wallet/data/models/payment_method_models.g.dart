// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      id: json['id'] as String,
      type: $enumDecode(_$PaymentMethodTypeEnumMap, json['type']),
      name: json['name'] as String,
      lastFour: json['last_four'] as String?,
      brand: json['brand'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      authorizationCode: json['authorization_code'] as String?,
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$PaymentMethodTypeEnumMap[instance.type]!,
      'name': instance.name,
      'last_four': instance.lastFour,
      'brand': instance.brand,
      'balance': instance.balance,
      'is_default': instance.isDefault,
      'authorization_code': instance.authorizationCode,
    };

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.card: 'card',
  PaymentMethodType.wallet: 'wallet',
  PaymentMethodType.bankTransfer: 'bank_transfer',
};

PaymentMethodsResponse _$PaymentMethodsResponseFromJson(
        Map<String, dynamic> json) =>
    PaymentMethodsResponse(
      paymentMethods: (json['payment_methods'] as List<dynamic>)
          .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaymentMethodsResponseToJson(
        PaymentMethodsResponse instance) =>
    <String, dynamic>{
      'payment_methods':
          instance.paymentMethods.map((e) => e.toJson()).toList(),
    };
