import 'package:json_annotation/json_annotation.dart';

part 'payment_method_models.g.dart';

enum PaymentMethodType {
  @JsonValue('card')
  card,
  @JsonValue('wallet')
  wallet,
  @JsonValue('bank_transfer')
  bankTransfer,
}

@JsonSerializable()
class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String name;
  @JsonKey(name: 'last_four')
  final String? lastFour;
  final String? brand;
  final double? balance;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'authorization_code')
  final String? authorizationCode;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.lastFour,
    this.brand,
    this.balance,
    this.isDefault = false,
    this.authorizationCode,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);

  bool get isWallet => type == PaymentMethodType.wallet;
  bool get isCard => type == PaymentMethodType.card;
}

@JsonSerializable()
class PaymentMethodsResponse {
  @JsonKey(name: 'payment_methods')
  final List<PaymentMethod> paymentMethods;

  PaymentMethodsResponse({required this.paymentMethods});

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodsResponseToJson(this);
}
