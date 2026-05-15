import 'package:flutter/material.dart';

class AppConstants {
  // Admin registration hidden code
  static const String adminCode = "235857";

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  
  // Colors
  static const Color primaryColor = Color(0xFF1B3A57);
  static const Color secondaryColor = Color(0xFF145DA0);
  static const Color accentColor = Color(0xFF2EC4B6);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color errorColor = Color(0xFFC62828);
  static const Color warningColor = Color(0xFFF9A825);
  static const Color scaffoldBackground = Color(0xFFF5F7FB);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );
  
  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );
  
  // Common Functions
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final Color backgroundColor = isError ? errorColor : successColor;
    final String title = isError ? 'Error' : 'Success';
    final IconData icon = isError ? Icons.error_outline : Icons.check_circle_outline;
    final ScaffoldMessengerState? messenger =
        messengerKey.currentState ?? ScaffoldMessenger.maybeOf(context);

    if (messenger == null) {
      return;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$title: $message',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static String formatError(Object error) {
    final String message = error.toString().replaceFirst('Exception: ', '');
    final String lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('invalid-credential') ||
        lowerMessage.contains('invalid-login-credentials') ||
        lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('password is invalid') ||
        lowerMessage.contains('user does not have a password')) {
      return 'Wrong email or password. Please try again.';
    }
    if (lowerMessage.contains('no user record') ||
        lowerMessage.contains('user record') && lowerMessage.contains('does not exist')) {
      return 'No account found with this email.';
    }
    if (lowerMessage.contains('wrong-password')) {
      return 'Wrong password. Please try again.';
    }
    if (lowerMessage.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (lowerMessage.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (lowerMessage.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }
    if (lowerMessage.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (lowerMessage.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (lowerMessage.contains('permission-denied')) {
      return 'Permission denied. Please contact support.';
    }
    if (lowerMessage.contains('failed-precondition')) {
      return 'Missing index. Please contact support to enable this view.';
    }
    if (lowerMessage.contains('insufficient balance')) {
      return 'Insufficient balance. Please add funds.';
    }
    if (lowerMessage.contains('no seats available')) {
      return 'No seats are available for this flight.';
    }

    return message;
  }
}
