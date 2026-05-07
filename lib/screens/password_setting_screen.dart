import 'package:city_cipher/screens/login_screen.dart';
import 'package:city_cipher/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/enums/app_enums.dart';
import '../core/providers/api_service_provider.dart';
import '../core/theme.dart';
import '../core/validators/password_validators.dart';
import '../shared/utils/toast.dart';

class PasswordSettingScreen extends ConsumerStatefulWidget {
  final String id;
  const PasswordSettingScreen({super.key, required this.id});

  @override
  ConsumerState<PasswordSettingScreen> createState() =>
      _PasswordSettingScreenState();
}

class _PasswordSettingScreenState extends ConsumerState<PasswordSettingScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _submitted = false;

  PasswordInput _password = const PasswordInput.pure();
  String _confirmPassword = '';

  AppState resetPasswordState = AppState.initialize;

  Future<void> resetPassword() async {
    setState(() {
      resetPasswordState = AppState.loading;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.resetPassword(
        widget.id,
        _password.value,
      );

      if (!mounted) return;

      setState(() {
        resetPasswordState = response.success
            ? AppState.loaded
            : AppState.error;
      });

      if (response.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
        return;
      }
      ToastHelper.show(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        resetPasswordState = AppState.error;
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
                "Create New Password",
                style: TextStyle(
                  color: CityCipherTheme.foreground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your new password to secure your account.",
                style: TextStyle(
                  color: CityCipherTheme.mutedForeground,
                  fontSize: 14,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 48),
              _buildLabel("PASSWORD"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _password = PasswordInput.dirty(value: value);
                  });
                },
                obscureText: _obscurePassword,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
                cursorColor: CityCipherTheme.primary,
                decoration: InputDecoration(
                  hintText: "••••••••••",
                  errorText: _submitted && _password.isNotValid
                      ? _password.errorMessage
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 22,
                      color: CityCipherTheme.mutedForeground,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildLabel("CONFIRM PASSWORD"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _confirmPassword = value;
                  });
                },
                obscureText: _obscureConfirmPassword,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
                cursorColor: CityCipherTheme.primary,
                decoration: InputDecoration(
                  hintText: "••••••••••",
                  errorText: _submitted
                      ? (_confirmPassword.isEmpty
                            ? "Confirm password is required"
                            : (_confirmPassword != _password.value
                                  ? "Passwords do not match"
                                  : null))
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? LucideIcons.eye
                          : LucideIcons.eyeOff,
                      size: 22,
                      color: CityCipherTheme.mutedForeground,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: resetPasswordState == AppState.loading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _submitted = true;
                          });

                          final isValid =
                              _password.isValid &&
                              _confirmPassword == _password.value;

                          if (!isValid) return;
                          resetPassword();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CityCipherTheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: resetPasswordState == AppState.loading
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
