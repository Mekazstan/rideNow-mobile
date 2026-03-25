import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/app_provider.dart';
import 'package:ridenowappsss/core/navigation/app_router.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/core/services/service_locator.dart';
import 'package:ridenowappsss/core/utils/theme/app_theme.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    setupServiceLocator();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: false,
      child: MultiProvider(
        providers: [
          ...appProviders,
          ChangeNotifierProvider<RideProvider>(
            create: (_) => getIt<RideProvider>(),
          ),
        ],
        child: Builder(
          builder: (context) {
            final authProvider = context.read<AuthProvider>();
            authProvider.onSessionExpired = () {
              if (context.mounted) {
                AppRouter.router.goNamed(RouteConstants.login);
              }
            };

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'RideNow',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.light,
              scrollBehavior: const _AppScrollBehavior(),
              routeInformationProvider:
                  AppRouter.router.routeInformationProvider,
              routeInformationParser: AppRouter.router.routeInformationParser,
              routerDelegate: AppRouter.router.routerDelegate,
              builder: (context, child) {
                return child!;
              },
            );
          },
        ),
      ),
    );
  }
}

class _AppScrollBehavior extends ScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
