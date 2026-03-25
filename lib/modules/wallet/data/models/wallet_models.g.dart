// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletBalance _$WalletBalanceFromJson(Map<String, dynamic> json) =>
    WalletBalance(
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
      lastUpdated: json['last_updated'] as String,
    );

Map<String, dynamic> _$WalletBalanceToJson(WalletBalance instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'currency': instance.currency,
      'last_updated': instance.lastUpdated,
    };

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) =>
    WalletTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      referenceId: json['reference_id'],
      externalReference: json['external_reference'],
      balanceBefore: json['balance_before'],
      balanceAfter: (json['balance_after'] as num).toDouble(),
      createdAt: json['created_at'] as String,
      paymentUrl: json['payment_url'] as String?,
      paymentMetadata: json['payment_metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$WalletTransactionToJson(WalletTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'currency': instance.currency,
      'description': instance.description,
      'status': instance.status,
      'reference_id': instance.referenceId,
      'external_reference': instance.externalReference,
      'balance_before': instance.balanceBefore,
      'balance_after': instance.balanceAfter,
      'created_at': instance.createdAt,
      'payment_url': instance.paymentUrl,
      'payment_metadata': instance.paymentMetadata,
    };

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  currentPage: (json['current_page'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
  totalCount: (json['total_count'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  hasNext: json['has_next'] as bool?,
  hasPrev: json['has_prev'] as bool?,
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'total_pages': instance.totalPages,
      'total_count': instance.totalCount,
      'per_page': instance.perPage,
      'has_next': instance.hasNext,
      'has_prev': instance.hasPrev,
    };

TransactionsResponse _$TransactionsResponseFromJson(
  Map<String, dynamic> json,
) => TransactionsResponse(
  transactions:
      (json['transactions'] as List<dynamic>)
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TransactionsResponseToJson(
  TransactionsResponse instance,
) => <String, dynamic>{
  'transactions': instance.transactions,
  'pagination': instance.pagination,
};
