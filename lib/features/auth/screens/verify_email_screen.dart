import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/auth_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isChecking = false;
  bool isResending = false;
  String? message;
  bool messageIsError = false;

  Future<void> _checkVerified() async {
    setState(() {
      isChecking = true;
      message = null;
    });

    final verified = await AuthService.checkEmailVerified();

    if (!mounted) return;
    setState(() => isChecking = false);

    if (verified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() {
        message = "Not verified yet. Check your inbox and tap the link, then try again.";
        messageIsError = false;
      });
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      isResending = true;
      message = null;
    });

    try {
      await AuthService.sendVerificationEmail();
      if (!mounted) return;
      setState(() {
        isResending = false;
        message = "Verification email sent again. Check your inbox.";
        messageIsError = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        isResending = false;
        messageIsError = true;
        if (e.code == 'too-many-requests') {
          message = "Too many attempts. Please wait a few minutes before trying again.";
        } else {
          message = e.message ?? "Couldn't send the email. Please try again shortly.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isResending = false;
        messageIsError = true;
        message = "Something went wrong sending the email: $e";
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService.currentUser?.email ?? "your email";

    return Scaffold(
      backgroundColor: AppTheme.eclipseMint,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mark_email_unread_outlined,
                  color: AppTheme.moonlitMint, size: 64),
              const SizedBox(height: 20),
              const Text(
                "Verify your email",
                style: TextStyle(
                  color: AppTheme.moonlitMint,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We sent a confirmation link to $email. Click it, then come back and tap the button below.",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              if (message != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: messageIsError ? Colors.red.shade50 : AppTheme.cloudWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message!,
                    style: TextStyle(
                      color: messageIsError ? Colors.red.shade900 : AppTheme.eclipseMint,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isChecking ? null : _checkVerified,
                  child: isChecking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("I've verified — Continue"),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isResending ? null : _resendEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.moonlitMint,
                    side: const BorderSide(color: AppTheme.moonlitMint),
                  ),
                  child: isResending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Resend Email"),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _logout,
                child: const Text(
                  "Use a different account",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
