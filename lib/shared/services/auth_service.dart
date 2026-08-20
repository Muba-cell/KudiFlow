import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static User? get currentUser => _auth.currentUser;

  static bool get isLoggedIn => _auth.currentUser != null;

  static bool get isEmailVerified =>
      _auth.currentUser?.emailVerified ?? false;

  /// Initializes Google Sign-In.
  static Future<void> initializeGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

  /// Returns null on success, or a human-readable error message on failure.
  /// Also sends a verification email automatically on successful sign-up.
  static Future<String?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e);
    }
  }

  /// Returns null on success, or a human-readable error message on failure.
  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _auth.currentUser?.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e);
    }
  }

  /// Signs the user in with Google and authenticates them with Firebase.
  /// Returns null on success, or a human-readable error message on failure.
  static Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return 'Google sign-in was cancelled.';
      }

      return e.description ?? 'Unable to sign in with Google.';
    } catch (e) {
      return 'Unable to sign in with Google. Please try again.';
    }
  }

  static Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Refreshes the user's status from Firebase and returns whether
  /// their email is now verified.
  static Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  static Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  static String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}