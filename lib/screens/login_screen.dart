import 'package:city_cipher/screens/registration_verification_screen.dart';
import 'package:city_cipher/screens/registration_screen.dart';
import 'package:city_cipher/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final bool isFullView;

  const LoginScreen({super.key, this.onClose, this.isFullView = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: CustomAppBar(icon: LucideIcons.x, onBack: widget.onClose),
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
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: "Poppins",
                ),
                cursorColor: CityCipherTheme.primary,
                decoration: InputDecoration(
                  hintText: "09123456789",
                  hintStyle: TextStyle(
                    color: CityCipherTheme.mutedForeground,
                    fontSize: 16,
                    fontFamily: "Poppins",
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
              const SizedBox(height: 24),
              _buildLabel("PASSWORD"),
              TextField(
                obscureText: _obscurePassword,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: "Poppins",
                ),
                cursorColor: CityCipherTheme.primary,
                decoration: InputDecoration(
                  hintText: "••••••••••",
                  hintStyle: TextStyle(
                    color: CityCipherTheme.mutedForeground,
                    fontSize: 16,
                    fontFamily: "Poppins",
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,

                child: GestureDetector(
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CityCipherTheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RegistrationScreen(onClose: widget.onClose),
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
