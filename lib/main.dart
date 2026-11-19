import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobo_appointment_project/core/providers/role_provider.dart';
import 'package:mobo_appointment_project/core/theme/theme_provider.dart';
import 'package:mobo_appointment_project/core/widgets/app_lock_gate.dart';
import 'package:mobo_appointment_project/features/login/provider/auth_provider.dart';
import 'package:mobo_appointment_project/features/login/server/provider/server_provider.dart';
import 'package:mobo_appointment_project/core/routing/app_router.dart';
import 'package:mobo_appointment_project/features/profile/providers/profile_provider.dart';
import 'package:mobo_appointment_project/features/settings/providers/currency_provider.dart';
import 'package:mobo_appointment_project/features/settings/providers/language_provider.dart';
import 'package:mobo_appointment_project/features/settings/providers/timezone_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'core/theme/app_theme.dart';

void main() {
  tz_data.initializeTimeZones(); // initializing the timezone
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ServerProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TimezoneProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: appRouter,

      builder: (context, child) {
        return AppLockGate(child: child ?? SizedBox.shrink());
      },
    );
  }
}
