import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/auth/screens/app_lock_screen.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Widget nextScreen;
    if (!AuthService.isLoggedIn) {
      nextScreen = const LoginScreen();
    } else if (!AuthService.isEmailVerified) {
      nextScreen = const VerifyEmailScreen();
    } else {
      nextScreen = const AppLockScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.eclipseMint,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 110,
                height: 110,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'KudiFlow',
              style: TextStyle(
                color: AppTheme.moonlitMint,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Flow Smarter. Grow Wealthier.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
