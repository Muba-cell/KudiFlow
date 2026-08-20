import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kudiflow/firebase_options.dart';
import 'package:kudiflow/core/theme/app_theme.dart';
import 'package:kudiflow/core/routes/app_routes.dart';
import 'package:kudiflow/shared/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AuthService.initializeGoogleSignIn();

  runApp(const KudiFlowApp());
}

class KudiFlowApp extends StatelessWidget {
  const KudiFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KudiFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
