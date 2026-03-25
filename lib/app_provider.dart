import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ridenowappsss/core/navigation/bottom_navigation.dart';
import 'package:ridenowappsss/core/services/location_service.dart';
import 'package:ridenowappsss/core/storage/local_storage.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/subscription_plan_provider.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/support_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/emergency_contact_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/user_provider.dart';
import 'package:ridenowappsss/modules/community/presentation/providers/community_provider.dart';
import 'package:ridenowappsss/modules/ride/data/data_sources/driver_remote_data_source.dart';
import 'package:ridenowappsss/modules/ride/data/repositories/driver_repository.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/driver_provider.dart';
import 'package:ridenowappsss/modules/wallet/domain/services/bank_account_service.dart';
import 'package:ridenowappsss/modules/wallet/domain/services/bank_validation_service.dart';
import 'package:ridenowappsss/modules/wallet/domain/services/wallet_service.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/bank_account_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/banks_provider.dart';
import 'package:ridenowappsss/modules/wallet/presentation/providers/wallet_provider.dart';

final List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => SupportProvider()),
  ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
  ChangeNotifierProvider(create: (_) => UserProvider()),

  ChangeNotifierProvider(
    create:
        (_) => BankAccountProvider(
          bankAccountService: BankAccountService(),
          validationService: BankValidationService(),
        ),
  ),
  ChangeNotifierProvider(
    create: (_) => WalletProvider(walletService: WalletService()),
  ),
  ChangeNotifierProvider(
    create: (_) => BanksProvider(bankAccountService: BankAccountService()),
  ),
  ChangeNotifierProvider(create: (_) => BottomNavVisibilityProvider()),
  ChangeNotifierProvider(create: (_) => EmergencyContactProvider()),
  ChangeNotifierProvider(create: (_) => CommunityProvider()),
  ChangeNotifierProvider(
    create:
        (_) => DriverProvider(
          repository: DriverRepositoryImpl(
            remoteDataSource: DriverRemoteDataSourceImpl(
              storageService: SecureStorageService(),
            ),
          ),
          locationService: LocationServiceImpl(),
        ),
  ),
];
