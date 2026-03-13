import 'package:json_annotation/json_annotation.dart';

part 'wallet_models.g.dart';

// Wallet Balance Model
@JsonSerializable()
class WalletBalance {
  final double balance;
  final String currency;
  @JsonKey(name: 'last_updated')
  final String lastUpdated;

  WalletBalance({
    required this.balance,
    required this.currency,
    required this.lastUpdated,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$WalletBalanceToJson(this);
}

// Transaction Model
@JsonSerializable()
class WalletTransaction {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String description;
  final String status;
  @JsonKey(name: 'reference_id')
  final dynamic referenceId;
  @JsonKey(name: 'external_reference')
  final dynamic externalReference;
  @JsonKey(name: 'balance_before')
  final dynamic balanceBefore;
  @JsonKey(name: 'balance_after')
  final double balanceAfter;
  @JsonKey(name: 'created_at')
  final String createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.status,
    this.referenceId,
    this.externalReference,
    this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$WalletTransactionToJson(this);

  // Helper method to get formatted date
  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final transactionDate = DateTime(date.year, date.month, date.day);

      if (transactionDate == today) {
        return 'Today';
      } else if (transactionDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      } else {
        return '${date.day}${_getDaySuffix(date.day)} ${_getMonthName(date.month)} ${date.year}';
      }
    } catch (e) {
      return createdAt;
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Helper method to check if transaction is withdrawal
  bool get isWithdrawal =>
      type.toLowerCase().contains('withdrawal') ||
      type.toLowerCase().contains('debit');

  // Helper method to check if transaction is deposit
  bool get isDeposit =>
      type.toLowerCase().contains('deposit') ||
      type.toLowerCase().contains('credit');
}

// Pagination Model
@JsonSerializable()
class Pagination {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_count')
  final int totalCount;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'has_next')
  final bool? hasNext;
  @JsonKey(name: 'has_prev')
  final bool? hasPrev;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.perPage,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationToJson(this);

  // Helper getters to safely access nullable boolean values
  bool get hasNextPage => hasNext ?? false;
  bool get hasPrevPage => hasPrev ?? false;
}

// Transactions Response Model
@JsonSerializable()
class TransactionsResponse {
  final List<WalletTransaction> transactions;
  final Pagination pagination;

  TransactionsResponse({required this.transactions, required this.pagination});

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionsResponseToJson(this);
}

// Account Validation Result
class AccountValidationResult {
  final bool isSuccess;
  final String? accountHolderName;
  final String? errorMessage;

  AccountValidationResult({
    required this.isSuccess,
    this.accountHolderName,
    this.errorMessage,
  });
}

class BankAccount {
  final String id;
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final bool isDefault;
  final bool? isVerified;
  final DateTime? verificationDate;
  final double? dailyWithdrawalLimit;
  final double? monthlyWithdrawalLimit;
  final DateTime? createdAt;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    this.isDefault = false,
    this.isVerified,
    this.verificationDate,
    this.dailyWithdrawalLimit,
    this.monthlyWithdrawalLimit,
    this.createdAt,
  });

  // Getter for backward compatibility
  String get accountHolderName => accountName;

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id']?.toString() ?? '',
      bankName:
          json['bankName']?.toString() ?? json['bank_name']?.toString() ?? '',
      bankCode:
          json['bankCode']?.toString() ?? json['bank_code']?.toString() ?? '',
      accountNumber:
          json['accountNumber']?.toString() ??
          json['account_number']?.toString() ??
          '',
      accountName:
          json['accountName']?.toString() ??
          json['account_name']?.toString() ??
          '',
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
      isVerified: json['isVerified'] ?? json['is_verified'],
      verificationDate:
          json['verificationDate'] != null
              ? DateTime.tryParse(json['verificationDate'].toString())
              : json['verification_date'] != null
              ? DateTime.tryParse(json['verification_date'].toString())
              : null,
      dailyWithdrawalLimit:
          json['dailyWithdrawalLimit']?.toDouble() ??
          json['daily_withdrawal_limit']?.toDouble(),
      monthlyWithdrawalLimit:
          json['monthlyWithdrawalLimit']?.toDouble() ??
          json['monthly_withdrawal_limit']?.toDouble(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'bankCode': bankCode,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'isDefault': isDefault,
      'isVerified': isVerified,
      'verificationDate': verificationDate?.toIso8601String(),
      'dailyWithdrawalLimit': dailyWithdrawalLimit,
      'monthlyWithdrawalLimit': monthlyWithdrawalLimit,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  BankAccount copyWith({
    String? id,
    String? bankName,
    String? bankCode,
    String? accountNumber,
    String? accountName,
    bool? isDefault,
    bool? isVerified,
    DateTime? verificationDate,
    double? dailyWithdrawalLimit,
    double? monthlyWithdrawalLimit,
    DateTime? createdAt,
  }) {
    return BankAccount(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      verificationDate: verificationDate ?? this.verificationDate,
      dailyWithdrawalLimit: dailyWithdrawalLimit ?? this.dailyWithdrawalLimit,
      monthlyWithdrawalLimit:
          monthlyWithdrawalLimit ?? this.monthlyWithdrawalLimit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Bank accounts response model
class BankAccountsResponse {
  final bool success;
  final List<BankAccount> accounts;
  final String? message;

  BankAccountsResponse({
    required this.success,
    required this.accounts,
    this.message,
  });

  factory BankAccountsResponse.fromJson(dynamic json) {
    List<dynamic> accountsList;

    if (json is List) {
      accountsList = json;
    } else if (json is Map<String, dynamic>) {
      accountsList =
          json['data'] as List<dynamic>? ??
          json['accounts'] as List<dynamic>? ??
          json['bank_accounts'] as List<dynamic>? ??
          [];
    } else {
      accountsList = [];
    }

    return BankAccountsResponse(
      success: json is Map ? (json['success'] ?? true) : true,
      accounts:
          accountsList
              .map(
                (account) =>
                    BankAccount.fromJson(account as Map<String, dynamic>),
              )
              .toList(),
      message: json is Map ? json['message']?.toString() : null,
    );
  }
}

/// Bank validation result
class BankValidationResult {
  final bool isSuccess;
  final String? accountHolderName;
  final String? errorMessage;

  BankValidationResult({
    required this.isSuccess,
    this.accountHolderName,
    this.errorMessage,
  });
}

/// Validation state enum
enum ValidationState { idle, loading, success, error }

/// Bank model for bank list
class Bank {
  final String id;
  final String name;
  final String code;
  final String? logo;

  Bank({required this.id, required this.name, required this.code, this.logo});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['bank_name']?.toString() ?? '',
      code: json['code']?.toString() ?? json['bank_code']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'logo': logo};
  }
}

/// Banks response model
class BanksResponse {
  final bool success;
  final List<Bank> banks;
  final String? message;

  BanksResponse({required this.success, required this.banks, this.message});

  factory BanksResponse.fromJson(dynamic json) {
    List<dynamic> banksList;
    if (json is List) {
      banksList = json;
    } else if (json is Map<String, dynamic>) {
      banksList =
          json['data'] as List<dynamic>? ??
          json['banks'] as List<dynamic>? ??
          [];
    } else {
      banksList = [];
    }

    return BanksResponse(
      success: json is Map ? (json['success'] ?? true) : true,
      banks:
          banksList
              .map((bank) => Bank.fromJson(bank as Map<String, dynamic>))
              .toList(),
      message: json is Map ? json['message']?.toString() : null,
    );
  }
}
