import 'package:city_cipher/screens/login_screen.dart';
import 'package:city_cipher/screens/password_setting_screen.dart';
import 'package:city_cipher/screens/verification_screen.dart';
import 'package:city_cipher/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/enums/app_enums.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../shared/utils/toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _mobileNumber = '';

  final ApiService apiService = ApiService();
  AppState forgotPasswordState = AppState.initialize;

  Future<void> forgotPassword() async {
    setState(() {
      forgotPasswordState = AppState.loading;
    });

    try {
      final response = await apiService.forgotPassword(_mobileNumber);

      if (!mounted) return;

      setState(() {
        forgotPasswordState = response.success
            ? AppState.loaded
            : AppState.error;
      });
      if (response.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              resendDuration: response.retryAfter,
              id: response.id,
              type: OtpType.forgot,
              onSuccess: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PasswordSettingScreen(id: response.id),
                  ),
                );
              },
            ),
          ),
        );
        return;
      } else {
        if (response.isLocked) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                resendDuration: 0,
                isLocked: true,
                lockedSecondsRemaining: response.retryAfter,
                id: response.id,
                type: OtpType.forgot,
              ),
            ),
          );
          return;
        }

        if (response.remainingSend > 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                resendDuration: response.retryAfter,
                id: response.id,
                type: OtpType.forgot,
                onSuccess: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PasswordSettingScreen(id: response.id),
                    ),
                  );
                },
              ),
            ),
          );
          return;
        }

        ToastHelper.show(context, message: response.message);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        forgotPasswordState = AppState.error;
      });

      ToastHelper.show(context);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: CustomAppBar(icon: LucideIcons.x),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Reset Your Password",
                style: TextStyle(
                  color: CityCipherTheme.foreground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your registered mobile number and we’ll send you a verification code to reset your password.",
                style: TextStyle(
                  color: CityCipherTheme.mutedForeground,
                  fontSize: 14,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 48),
              _buildLabel("MOBILE NUMBER"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _mobileNumber = value;
                  });
                },
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
                cursorColor: CityCipherTheme.primary,
                decoration: InputDecoration(
                  hintText: "09123456789",
                  hintStyle: TextStyle(
                    color: CityCipherTheme.mutedForeground,
                    fontSize: 16,
                    fontFamily: CityCipherTheme.fontFamily,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF334155), width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CityCipherTheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: forgotPasswordState == AppState.loading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();

                          final isValid = _mobileNumber.isNotEmpty;

                          if (!isValid) return;
                          forgotPassword();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CityCipherTheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: forgotPasswordState == AppState.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CityCipherTheme.primary,
                          ),
                        )
                      : const Text(
                          "SUBMIT",
                          style: TextStyle(
                            fontFamily: CityCipherTheme.fontFamily,
                            color: CityCipherTheme.primaryForeground,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: CityCipherTheme.fontFamily,
          color: CityCipherTheme.mutedForeground,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
