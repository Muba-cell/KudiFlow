import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool isAuthenticating = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    setState(() {
      isAuthenticating = true;
      errorMessage = null;
    });

    try {
      final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canCheck) {
        _unlock();
        return;
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Unlock KudiFlow to view your finances',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;

      if (didAuthenticate) {
        _unlock();
      } else {
        setState(() {
          isAuthenticating = false;
          errorMessage = "Authentication cancelled or failed.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isAuthenticating = false;
        errorMessage = "Couldn't verify identity: $e";
      });
    }
  }

  void _unlock() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.eclipseMint,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, color: AppTheme.moonlitMint, size: 64),
                const SizedBox(height: 20),
                const Text(
                  "KudiFlow is locked",
                  style: TextStyle(
                    color: AppTheme.moonlitMint,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Verify it's you to continue.",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 30),

                if (errorMessage != null) ...[
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                ],

                if (isAuthenticating)
                  const CircularProgressIndicator(color: AppTheme.moonlitMint)
                else
                  ElevatedButton.icon(
                    onPressed: _authenticate,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text("Try Again"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
