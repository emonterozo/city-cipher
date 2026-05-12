import 'package:city_cipher/core/enums/app_enums.dart';
import 'package:city_cipher/models/reward/reward_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme.dart';

class RewardDetail extends StatelessWidget {
  final Reward reward;

  const RewardDetail({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reward.store.name.toUpperCase(),
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CityCipherTheme.foreground,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          reward.title,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: CityCipherTheme.secondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          reward.description,
          style: TextStyle(
            fontSize: 16,
            color: CityCipherTheme.mutedForeground,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Terms & Conditions",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CityCipherTheme.foreground,
          ),
        ),
        const SizedBox(height: 12),
        ...reward.rules.map((rule) => _buildRuleItem(rule)),
        _buildRuleDetailRow(
          "Use within ${reward.claimValidDays} days after claiming or it will expire",
        ),
        _buildRuleDetailRow(
          "Claim period will end on ${DateFormat('MMM dd, yyyy').format(reward.endDate)}",
        ),
      ],
    );
  }

  Widget _buildRuleItem(RewardRule rule) {
    final formattedValue = NumberFormat.decimalPattern().format(rule.value);
    String text = "";
    if (rule.type == RewardRuleType.minPurchase) {
      text = "Minimum spend of ₱$formattedValue required";
    }
    if (rule.type == RewardRuleType.maxDiscount) {
      text = "Maximum discount limited to ₱$formattedValue";
    }

    return _buildRuleDetailRow(text);
  }

  Widget _buildRuleDetailRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.check,
            size: 18,
            color: CityCipherTheme.mutedForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: "Poppins",
                color: CityCipherTheme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
