import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of an authentication operation
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(User user) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, errorMessage: message);
  }
}

/// Centralized authentication service
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(username.trim());

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username.trim());
        await prefs.setString('name', username.trim());
        await prefs.setString('email', email.trim());
        await prefs.setString('userEmail', email.trim());

        return AuthResult.success(user);
      }

      return AuthResult.failure('Failed to create account');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      debugPrint('SignUp error: $e');
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user != null) {
        // Update SharedPreferences with email
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email.trim());
        await prefs.setString('userEmail', email.trim());

        // Try to restore username from display name
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          await prefs.setString('username', user.displayName!);
          await prefs.setString('name', user.displayName!);
        }

        return AuthResult.success(user);
      }

      return AuthResult.failure('Failed to sign in');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      debugPrint('SignIn error: $e');
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        errorMessage: null,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      debugPrint('Password reset error: $e');
      return AuthResult.failure('Failed to send reset email. Please try again.');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Clear some preferences but keep username
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final name = prefs.getString('name');

      // Keep username for next login
      if (username != null) {
        await prefs.setString('username', username);
      }
      if (name != null) {
        await prefs.setString('name', name);
      }
    } catch (e) {
      debugPrint('SignOut error: $e');
    }
  }

  /// Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      await currentUser?.delete();

      // Clear all preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      debugPrint('Delete account error: $e');
      return AuthResult.failure('Failed to delete account. Please try again.');
    }
  }

  /// Update password
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword.trim());
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      debugPrint('Update password error: $e');
      return AuthResult.failure('Failed to update password. Please try again.');
    }
  }

  /// Map Firebase errors to user-friendly messages
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters with letters and numbers.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        debugPrint('Unhandled Firebase error: ${e.code} - ${e.message}');
        return 'An error occurred. Please try again.';
    }
  }

  /// Validate email format
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      return 'Password must contain letters and numbers';
    }
    return null;
  }

  /// Validate username
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Please enter your name';
    }
    if (username.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirm(String? password, String? confirm) {
    if (confirm == null || confirm.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirm) {
      return 'Passwords do not match';
    }
    return null;
  }
}
