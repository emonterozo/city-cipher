import 'package:city_cipher/core/providers/auth_provider.dart';
import 'package:city_cipher/core/providers/game_provider.dart';
import 'package:city_cipher/screens/login_screen.dart';
import 'package:city_cipher/shared/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppDialogs {
  static void sessionExpired(
    BuildContext context, {
    WidgetRef? ref,
    bool dismissible = false,
    String secondaryText = "Later",
    VoidCallback? onSecondary,
  }) {
    final navigator = Navigator.of(context);
    showDialog(
      barrierDismissible: dismissible,
      context: context,
      builder: (_) => AppDialog(
        title: "Session Expired",
        message:
            "Your session has expired. Please log in again to continue.",
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
        onSecondary: () async {
          final storage = FlutterSecureStorage();
          await storage.deleteAll();
          ref?.read(gameProvider.notifier).clear();
          ref?.read(authProvider.notifier).logout();
          navigator.pop();
          if (onSecondary != null) {
            onSecondary();
          }
        },
      ),
    );
  }
}
