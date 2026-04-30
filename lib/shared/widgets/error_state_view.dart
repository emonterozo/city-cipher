import 'package:flutter/material.dart';
import 'package:city_cipher/core/theme.dart';

class ErrorStateView extends StatelessWidget {
  final String? description;
  final String? buttonText;
  final VoidCallback? onRetry;

  const ErrorStateView({
    super.key,
    this.description = "Something went wrong.\nPlease try again",
    this.buttonText = "Try again",
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/error/error.png',
              width: 300,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CityCipherTheme.mutedForeground,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 13),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  backgroundColor: CityCipherTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                ),
                child: Text(
                  buttonText!,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CityCipherTheme.background,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
