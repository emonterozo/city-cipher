import 'package:city_cipher/core/validators/mobile_validators.dart';
import 'package:city_cipher/core/validators/password_validators.dart';
import 'package:city_cipher/main.dart';
import 'package:city_cipher/screens/login_screen.dart';
import 'package:city_cipher/screens/verification_screen.dart';
import 'package:city_cipher/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/enums/app_enums.dart';
import '../core/theme.dart';
import '../core/validators/name_validators.dart';
import '../services/api_service.dart';
import '../shared/utils/toast.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _submitted = false;

  NameInput _firstName = const NameInput.pure(fieldName: "First name");
  NameInput _lastName = const NameInput.pure(fieldName: "Last name");
  MobileNumberInput _mobileNumber = const MobileNumberInput.pure();
  PasswordInput _password = const PasswordInput.pure();
  String _confirmPassword = '';

  final ApiService apiService = ApiService();
  AppState registrationState = AppState.initialize;

  Future<void> register() async {
    setState(() {
      registrationState = AppState.loading;
    });

    try {
      final response = await apiService.userRegistration(
        _firstName.value,
        _lastName.value,
        _mobileNumber.value,
        _password.value,
      );

      if (!mounted) return;

      setState(() {
        registrationState = response.success ? AppState.loaded : AppState.error;
      });

      if (response.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              resendDuration: response.retryAfter,
              id: response.userId,
              type: OtpType.registration,
            ),
          ),
        );
      } else {
        ToastHelper.show(context, message: response.message);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        registrationState = AppState.error;
      });

      ToastHelper.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: CustomAppBar(
        icon: LucideIcons.x,
        onBack: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainNavigation()),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Create your account",
                style: TextStyle(
                  color: CityCipherTheme.foreground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your details to start your journey.",
                style: TextStyle(
                  color: CityCipherTheme.mutedForeground,
                  fontSize: 14,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 48),
              _buildLabel("FIRST NAME"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _firstName = NameInput.dirty(
                      fieldName: "First name",
                      value: value,
                    );
                  });
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
                cursorColor: CityCipherTheme.primary,
                decoration: InputDecoration(
                  errorText: _submitted && _firstName.isNotValid
                      ? _firstName.errorMessage
                      : null,
                  hintText: "John",
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel("LAST NAME"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _lastName = NameInput.dirty(
                      fieldName: "Last name",
                      value: value,
                    );
                  });
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
                cursorColor: CityCipherTheme.primary,
                decoration: InputDecoration(
                  errorText: _submitted && _lastName.isNotValid
                      ? _lastName.errorMessage
                      : null,
                  hintText: "Doe",
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel("MOBILE NUMBER"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _mobileNumber = MobileNumberInput.dirty(value: value);
                  });
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
                cursorColor: CityCipherTheme.primary,
                decoration: InputDecoration(
                  errorText: _submitted && _mobileNumber.isNotValid
                      ? _mobileNumber.errorMessage
                      : null,
                  hintText: "09123456789",
                ),
              ),
              const SizedBox(height: 24),
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
                  onPressed: registrationState == AppState.loading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _submitted = true;
                            _firstName = NameInput.dirty(
                              fieldName: "First name",
                              value: _firstName.value,
                            );
                            _lastName = NameInput.dirty(
                              fieldName: "Last name",
                              value: _lastName.value,
                            );
                            _mobileNumber = MobileNumberInput.dirty(
                              value: _mobileNumber.value,
                            );
                          });

                          final isValid =
                              _firstName.isValid &&
                              _lastName.isValid &&
                              _mobileNumber.isValid &&
                              _password.isValid &&
                              _confirmPassword == _password.value;

                          if (!isValid) return;
                          register();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CityCipherTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: registrationState == AppState.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CityCipherTheme.primary,
                          ),
                        )
                      : const Text(
                          "REGISTER",
                          style: TextStyle(
                            fontFamily: CityCipherTheme.fontFamily,
                            color: CityCipherTheme.primaryForeground,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: CityCipherTheme.mutedForeground,
                      fontFamily: CityCipherTheme.fontFamily,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontFamily: CityCipherTheme.fontFamily,
                        color: CityCipherTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
