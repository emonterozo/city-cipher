import 'dart:async';
import 'package:city_cipher/core/theme.dart';
import 'package:city_cipher/screens/game_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/enums/app_enums.dart';
import '../services/api_service.dart';
import '../shared/utils/toast.dart';
import '../shared/widgets/custom_app_bar.dart';

class RegistrationVerificationScreen extends StatefulWidget {
  final int resendDuration;
  final String id;

  const RegistrationVerificationScreen({
    super.key,
    required this.resendDuration,
    required this.id,
  });

  @override
  State<RegistrationVerificationScreen> createState() =>
      _RegistrationVerificationScreenState();
}

class _RegistrationVerificationScreenState
    extends State<RegistrationVerificationScreen> {
  final ApiService apiService = ApiService();
  AppState resendState = AppState.initialize;
  AppState verifyState = AppState.initialize;
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isLocked = false;

  String get _otp => _controllers.map((e) => e.text).join();
  bool get _isValid => _otp.length == 4;

  Future<void> resendOtp() async {
    try {
      _controllers.clear();
      setState(() {
        resendState = AppState.loading;
      });
      final response = await apiService.sendOtp(
        widget.id,
        OtpType.registration,
      );
      setState(() {
        resendState = AppState.loaded;
      });

      if (response.success) {
        setState(() {
          _secondsRemaining = response.retryAfter;
        });
        _startTimer();
      } else {
        setState(() {
          _isLocked = true;
        });
      }
    } catch (e) {
      setState(() {
        resendState = AppState.error;
      });
      ToastHelper.show();
    }
  }

  Future<void> submitOtp() async {
    try {
      setState(() {
        verifyState = AppState.loading;
      });
      final response = await apiService.verifyOtp(
        widget.id,
        _otp,
        OtpType.registration,
      );
      setState(() {
        verifyState = AppState.loaded;
      });

      if (!mounted) return;

      if (response.success) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => GameTab()),
        // );
      } else {
        ToastHelper.show(message: response.message);
      }
    } catch (e) {
      setState(() {
        verifyState = AppState.error;
      });
      ToastHelper.show();
    }
  }

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.resendDuration;
    _startTimer();
    for (var controller in _controllers) {
      controller.addListener(() => setState(() {}));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }

    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _handleResend() {
    if (_secondsRemaining == 0 && !_isLocked) {
      resendOtp();
    }
  }

  void _handleVerify() {
    if (_isValid) {
      submitOtp();
    }
  }

  Widget _buildOtpField(int index) {
    return Opacity(
      opacity: _isLocked ? 0.5 : 1.0,
      child: Container(
        width: 65,
        height: 70,
        decoration: BoxDecoration(
          color: Color(0xFF16243A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          enabled: !_isLocked && verifyState != AppState.loading,
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontFamily: CityCipherTheme.fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CityCipherTheme.foreground,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: CityCipherTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: CityCipherTheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: CityCipherTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: CustomAppBar(
        icon: LucideIcons.x,
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(
                _isLocked ? "Account Locked" : "Verification Code",
                style: const TextStyle(
                  color: CityCipherTheme.foreground,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isLocked
                    ? "Too many failed attempts. Please try again in 24 hours."
                    : "Please enter the 4-digit code sent to your mobile number.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isLocked
                      ? CityCipherTheme.error
                      : CityCipherTheme.mutedForeground,
                  fontSize: 16,
                  fontFamily: CityCipherTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, _buildOtpField),
              ),
              if (!_isLocked) ...[
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code?",
                      style: const TextStyle(
                        color: CityCipherTheme.mutedForeground,
                        fontFamily: CityCipherTheme.fontFamily,
                      ),
                    ),
                    const SizedBox(width: 5),
                    resendState == AppState.loading
                        ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CityCipherTheme.primary,
                            ),
                          )
                        : GestureDetector(
                            onTap: _secondsRemaining == 0
                                ? _handleResend
                                : null,
                            child: Text(
                              _secondsRemaining > 0
                                  ? "Resend code in ${_secondsRemaining}s"
                                  : "Resend",
                              style: TextStyle(
                                fontFamily: CityCipherTheme.fontFamily,
                                color: _secondsRemaining == 0
                                    ? CityCipherTheme.secondary
                                    : CityCipherTheme.mutedForeground
                                          .withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: verifyState == AppState.loading
                      ? null
                      : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CityCipherTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: verifyState == AppState.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CityCipherTheme.primary,
                          ),
                        )
                      : Text(
                          _isLocked ? "LOCKED" : "SUBMIT",
                          style: TextStyle(
                            color: _isLocked
                                ? CityCipherTheme.error
                                : CityCipherTheme.primaryForeground,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: CityCipherTheme.fontFamily,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
