import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kudiflow/core/theme/app_theme.dart';
import 'package:kudiflow/features/auth/screens/app_lock_screen.dart';
import 'package:kudiflow/features/auth/screens/verify_email_screen.dart';
import 'package:kudiflow/shared/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSignUpMode = false;
  bool isSubmitting = false;
  String? errorMessage;
  bool errorIsSuccess = false;

  final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  Future<void> _submit() async {
    setState(() {
      errorMessage = null;
      errorIsSuccess = false;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final error = isSignUpMode
        ? await AuthService.register(
            emailController.text,
            passwordController.text,
          )
        : await AuthService.login(
            emailController.text,
            passwordController.text,
          );

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (error != null) {
      setState(() => errorMessage = error);
      return;
    }

    if (AuthService.isEmailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppLockScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );
    }
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !_emailRegex.hasMatch(email)) {
      setState(() {
        errorMessage = "Enter your email above first, then tap 'Forgot password?'";
        errorIsSuccess = false;
      });
      return;
    }

    setState(() {
      errorMessage = null;
      isSubmitting = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        errorMessage = "Password reset email sent to $email. Check your inbox.";
        errorIsSuccess = true;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        errorIsSuccess = false;
        if (e.code == 'user-not-found') {
          errorMessage = "No account found with that email.";
        } else {
          errorMessage = e.message ?? "Couldn't send reset email. Try again.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.eclipseMint,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "KudiFlow",
                    style: TextStyle(
                      color: AppTheme.moonlitMint,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Flow Smarter.\nGrow Wealthier.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cloudWhite,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        isSignUpMode ? "Create Your Account" : "Log In",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.eclipseMint,
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your email";
                          }
                          if (!_emailRegex.hasMatch(value.trim())) {
                            return "Enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          helperText: isSignUpMode
                              ? "6+ characters, with a letter and a number"
                              : null,
                          helperMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a password";
                          }
                          if (isSignUpMode) {
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
                            final hasDigit = RegExp(r'[0-9]').hasMatch(value);
                            if (!hasLetter || !hasDigit) {
                              return "Include at least one letter and one number";
                            }
                          }
                          return null;
                        },
                      ),

                      if (!isSignUpMode) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isSubmitting ? null : _forgotPassword,
                            child: const Text("Forgot password?"),
                          ),
                        ),
                      ],

                      if (errorMessage != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            color: errorIsSuccess ? Colors.green.shade700 : Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submit,
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(isSignUpMode ? "Sign Up" : "Login"),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            isSignUpMode = !isSignUpMode;
                            errorMessage = null;
                          });
                        },
                        child: Text(
                          isSignUpMode
                              ? "Already have an account? Log in"
                              : "Don't have an account? Sign up",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
