import 'package:city_cipher/screens/login_screen.dart';
import 'package:city_cipher/shared/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppDialogs {
  static void sessionExpired(
    BuildContext context, {
    bool dismissible = true,
    String secondaryText = "Later",
    VoidCallback? onSecondary,
  }) {
    showDialog(
      barrierDismissible: dismissible,
      context: context,
      builder: (_) => AppDialog(
        title: "Session Expired",
        message:
            "Your session has expired. Please log in again to continue playing and save your progress.",
        icon: LucideIcons.octagonAlert,
        iconColor: Colors.redAccent,
        primaryColor: Colors.redAccent,
        primaryText: "Login",
        secondaryText: secondaryText,
        onPrimary: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        },
        onSecondary: () {
          if (onSecondary != null) {
            onSecondary();
          } else if (dismissible) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
