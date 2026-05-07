import 'package:city_cipher/main.dart';
import 'package:city_cipher/screens/forgot_password_screen.dart';
import 'package:city_cipher/screens/verification_screen.dart';
import 'package:city_cipher/screens/registration_screen.dart';
import 'package:city_cipher/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/enums/app_enums.dart';
import '../core/providers/api_service_provider.dart' show apiServiceProvider;
import '../core/providers/auth_provider.dart';
import '../core/providers/game_provider.dart';
import '../core/theme.dart';
import '../shared/utils/toast.dart';
import 'game_tab.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  String _mobileNumber = '';
  String _password = '';

  AppState loginState = AppState.initialize;

  Future<void> login() async {
    setState(() {
      loginState = AppState.loading;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.login(_mobileNumber, _password);

      if (!mounted) return;

      setState(() {
        loginState = response.success ? AppState.loaded : AppState.error;
      });

      if (response.isLocked) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              resendDuration: 0,
              isLocked: true,
              lockedSecondsRemaining: response.retryAfter,
              id: response.id ?? '',
              type: OtpType.registration,
            ),
          ),
        );
        return;
      }

      if (response.remainingSend != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              resendDuration: response.retryAfter ?? 0,
              id: response.id ?? '',
              type: OtpType.registration,
              onSuccess: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => GameTab()),
                );
              },
            ),
          ),
        );
        return;
      }

      if (response.success) {
        if (response.accessToken != null) {
          await ref
              .read(authProvider.notifier)
              .setAuth(
                userId: response.id ?? '',
                accessToken: response.accessToken ?? '',
                refreshToken: response.refreshToken ?? '',
              );
          ref.read(gameProvider.notifier).loadGameData();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GameTab()),
          );
        }
      } else {
        ToastHelper.show(context, message: response.message);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loginState = AppState.error;
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
                "Login to your account",
                style: TextStyle(
                  color: CityCipherTheme.foreground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your details to continue your journey.",
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
                cursorColor: CityCipherTheme.primary,
                decoration: InputDecoration(hintText: "09123456789"),
              ),
              const SizedBox(height: 24),
              _buildLabel("PASSWORD"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _password = value;
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,

                child: GestureDetector(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    ),
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontFamily: CityCipherTheme.fontFamily,
                      color: CityCipherTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: loginState == AppState.loading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();

                          final isValid =
                              _mobileNumber.isNotEmpty && _password.isNotEmpty;

                          if (!isValid) return;
                          login();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CityCipherTheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: loginState == AppState.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CityCipherTheme.primary,
                          ),
                        )
                      : const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontFamily: "Poppins",
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
                    "Don't have an account?",
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
                        MaterialPageRoute(
                          builder: (context) => RegistrationScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        fontFamily: CityCipherTheme.fontFamily,
                        color: CityCipherTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
