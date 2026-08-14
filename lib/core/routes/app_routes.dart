import 'package:flutter/material.dart';

import '../../shared/widgets/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';

class AppRoutes {

  static const String splash = '/';

  static const String login = '/login';

  static const String dashboard = '/dashboard';

  static const String addTransaction = '/add-transaction';
  static final Map<String, WidgetBuilder> routes = {

    splash: (context) => const SplashScreen(),

    login: (context) => const LoginScreen(),

    dashboard: (context) => const DashboardScreen(),
    addTransaction: (context) =>
    const AddTransactionPage(),

  };
}